package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.moca.NotFoundException;
import com.redprairie.mtf.CMtfUtil;
import com.redprairie.mtf.MtfConstants;
import com.redprairie.mtf.exceptions.XFailedRequest;
import com.redprairie.mtf.exceptions.XFormAlreadyOnStack;
import com.redprairie.mtf.exceptions.XInvalidArg;
import com.redprairie.mtf.exceptions.XInvalidRequest;
import com.redprairie.mtf.exceptions.XInvalidState;
import com.redprairie.mtf.foundation.presentation.ACommand;
import com.redprairie.mtf.foundation.presentation.AFormLogic;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.ICommand;
import com.redprairie.mtf.foundation.presentation.IContainer;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.ITextSelection;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.mtf.foundation.presentation.IFormSegment;
import com.redprairie.mtf.foundation.presentation.IInteractiveWidget;
import com.redprairie.mtf.foundation.presentation.IVirtualKey;
import com.redprairie.mtf.foundation.presentation.IWidgetActionValidator;
import com.redprairie.mtf.session.IFrameworkSession;
import com.redprairie.wmd.WMDConstants;
import com.redprairie.wmd.mtfutil.CCarMovMaxUsers;
import com.redprairie.wmd.mtfutil.CNonInventoryWrkflw;
import com.redprairie.wmd.mtfutil.CUdia;
import com.redprairie.wmd.mtfutil.CVehLodLimit;
import com.redprairie.wmd.mtfutil.CWmdMtfUtil;
import com.redprairie.wmd.mtfutil.CWrkQue;
import com.redprairie.wmd.mtfutil.FormUtils;
import com.redprairie.wmd.mtfutil.RePutawayUtils;
import com.redprairie.wmd.mtfutil.gs1.BarcodeActionAdapter;
import com.redprairie.wmd.mtfutil.gs1.CGs1Events;
import com.redprairie.wmd.mtfutil.gs1.TemplateIdentifier;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.apache.log4j.Logger;

public class UsrRelabelLoad
        extends AFormLogic {

    // Other variables
    public CWmdMtfUtil wmdMtf;
    private static final Logger log = Logger.getLogger(UsrRelabelLoad.class);

    public IFormSegment segDef;

    public static final String FORM_ID = "USR_RELABEL_LOAD";
    private static final String FORM_TITLE = "ttlUsrRelabelLoad";

    // Hidden fields
    private IEntryField efPrevForm;
    private IEntryField efUsrId;
    private IEntryField efDevcod;
    private IEntryField efWhId;

    // Visible fields
    public IEntryField efOrgId;
    public IEntryField efNewId;
    public IEntryField efReaCod;

    private String colnam = null;
    private String lodlvl = null;

    // F1, Previous form.
    public ICommand cmdFkeyBack;

    public UsrRelabelLoad(IDisplay _display) throws Exception {
        super(_display);

        wmdMtf = (CWmdMtfUtil) this.session.getGlobalObjMap().get("WMDMTF");

        // Form 
        frmMain = this.display.createForm(this.FORM_ID);
        frmMain.setTitle(FORM_TITLE);
        frmMain.addWidgetAction(new UsrIdentifyLoadAdjDtlActions());

        segDef = frmMain.createSegment("segDef", false);

        // Hidden fields.
        efPrevForm = segDef.createEntryField("prev_form");
        efPrevForm.setVisible(false);

        efUsrId = segDef.createEntryField("usr_id");
        efUsrId.setVisible(false);

        efDevcod = segDef.createEntryField("devcod");
        efDevcod.setVisible(false);

        efWhId = segDef.createEntryField("wh_id");
        efWhId.setVisible(false);

        // Visible fields
        efOrgId = segDef.createEntryField("org_id", "lbl_org_id");
        efOrgId.setFieldRightJust(true);
        efOrgId.setVisible(true);
        efOrgId.setEnabled(true);
        efOrgId.setEntryRequired(true);
        efOrgId.addWidgetAction(new OrgIdActions());

        efNewId = segDef.createEntryField("new_id", "lbl_new_id");
        efNewId.setFieldRightJust(true);
        efNewId.setVisible(true);
        efNewId.setEnabled(true);
        efNewId.setEntryRequired(true);
        efNewId.addWidgetAction(new NewIdActions());

        efReaCod = segDef.createEntryField("reacod", "lbl_reacod");
        efReaCod.setVisible(true);
        efReaCod.setEnabled(true);
        efReaCod.setEntryRequired(true);

        // F1
        frmMain.unbind(frmMain.getCancelCommand());
        cmdFkeyBack = new FkeyBackCommand();
        cmdFkeyBack.setVisible(false);
        frmMain.bind(cmdFkeyBack);
        cmdFkeyBack.bind(MtfConstants.VK_FKEY_BACK);

        efWhId.setText(display.getVariable("global.wh_id"));
        efUsrId.setText(display.getVariable("global.usr_id"));
        efDevcod.setText(display.getVariable("global.devcod"));
    }

    public void run() throws XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XFormAlreadyOnStack {
        this.frmMain.interact();
    }

    private class UsrIdentifyLoadAdjDtlActions
            extends CWidgetActionAdapter {

        public boolean onFormEntry(IForm _frm) throws Exception {
            boolean retStatus = false;

            try {
                efOrgId.clear();
                efNewId.clear();
                efReaCod.clear();

                colnam = null;
                lodlvl = null;

                retStatus = true;
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
            }

            return retStatus;
        }

        public boolean onFormExit(IForm _frm) throws Exception {
            boolean retStatus = false;

            try {
                // Show the user we are working on it (processing).
                frmMain.displayMessage(MtfConstants.RF_MSG_PROCESSING);
                
                MocaResults rsFormExit = session.executeCommand(String.format(
                        "process usr rf relabel load form_exit "
                        + " where wh_id = '%s' "
                        + "   and lodlvl = '%s' "
                        + "   and org_id = '%s' "
                        + "   and new_id = '%s' "
                        + "   and reacod = '%s' ",
                        efWhId.getText(),
                        lodlvl,
                        efOrgId.getText(),
                        efNewId.getText(),
                        efReaCod.getText()
                ));
                
                frmMain.promptMessageAnyKey("stsLoadRelabeled");
                
                // Reopen the current form to clear everything needed and start fresh. 
                display.setVariable("INIT_POLICIES.prvfrm", FORM_ID);
                AFormLogic newFrm = display.createFormLogic(FORM_ID);
                newFrm.run();
            } catch (MocaException e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
            }

            return retStatus;
        }
    }

    private class OrgIdActions extends CWidgetActionAdapter {

        public boolean onFieldEntry(IInteractiveWidget _ef) throws Exception {
            return true;
        }

        public boolean onFieldExit(IInteractiveWidget _ef) throws Exception {
            boolean retStatus = false;

            try {
                // Show the user we are working on it (processing).
                frmMain.displayMessage(MtfConstants.RF_MSG_PROCESSING);

                // Validate and process the scan ID.
                MocaResults rsProcessOrgId = session.executeCommand(String.format(
                        "process usr rf relabel load org_id "
                        + " where wh_id = '%s' "
                        + "   and org_id = '%s' ",
                        efWhId.getText(),
                        efOrgId.getText()
                ));

                frmMain.resetMessageLine();

                if (rsProcessOrgId.hasNext()) {
                    rsProcessOrgId.next();

                    colnam = rsProcessOrgId.getString("colnam");
                    lodlvl = rsProcessOrgId.getString("lodlvl");
                }

                retStatus = true;
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
            }

            return retStatus;
        }
    }

    private class NewIdActions extends CWidgetActionAdapter {

        public boolean onFieldEntry(IInteractiveWidget _ef) throws Exception {
            return true;
        }

        public boolean onFieldExit(IInteractiveWidget _ef) throws Exception {
            boolean retStatus = false;

            try {
                // Show the user we are working on it (processing).
                frmMain.displayMessage(MtfConstants.RF_MSG_PROCESSING);

                // Validate and process the scan ID. */
                MocaResults rsProcessOrgId = session.executeCommand(String.format(
                        "process usr rf relabel load new_id "
                        + " where wh_id = '%s' "
                        + "   and new_id = '%s' ",
                        efWhId.getText(),
                        efNewId.getText()
                ));

                frmMain.resetMessageLine();

                retStatus = true;
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
            }

            return retStatus;
        }
    }

    private class FkeyBackCommand extends ACommand {
    	
 	    private static final long serialVersionUID = 0L;
        public FkeyBackCommand() {
            super("cmdFkeyBack", "FkeyBack", MtfConstants.FKEY_BACK_CAPTION, '1');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            frmMain.formReturn();
        }
    }
}
