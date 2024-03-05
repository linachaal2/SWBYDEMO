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
import com.redprairie.mtf.foundation.presentation.CVirtualKey;
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
import java.text.SimpleDateFormat;

public class UsrIdentifyLoadEx
        extends AFormLogic {

    /* Hidden fields */
    private IEntryField efPrevForm;
    private IEntryField efUsrId;
    private IEntryField efDevcod;
    private IEntryField efWhId;
    public IEntryField efReadOnly;
    public IEntryField efDisableBack;

    /* Other variables */
    public CWmdMtfUtil wmdMtf;
    private static final Logger log = Logger.getLogger(UsrIdentifyLoadEx.class);

    public IFormSegment segDef;

    public static final String FORM_ID = "USR_IDENTIFY_LOAD_EX";
    private static final String FORM_TITLE = "ttlUsrIdentifyLoadEx";

    public static final IVirtualKey VK_FKEY_REMOVE_HOLD = CVirtualKey.VK_F4;
    public static final String VK_FKEY_REMOVE_HOLD_CAPTION = "cmdRemoveHold";

    public static final String REACOD_FIXED_DEFAULT = "OVERIG";

    // Hidden fields
    public IEntryField efHldpfx;

    // Visible fields    
    public IEntryField efHldnum;
    public IEntryField efInvtyp;
    public IEntryField efAssetTyp;
    public IEntryField efNottxt;

    /* F1, Previous form. */
    public ICommand cmdFkeyBack;

    /* F4, Remove hold. */
    public ICommand cmdFkeyRemoveHold;

    public UsrIdentifyLoadEx(IDisplay _display) throws Exception {
        super(_display);

        wmdMtf = (CWmdMtfUtil) this.session.getGlobalObjMap().get("WMDMTF");

        /* Form */
        frmMain = this.display.createForm(this.FORM_ID);
        frmMain.setTitle(FORM_TITLE);
        frmMain.addWidgetAction(new UsrExceptionActions());

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

        efReadOnly = segDef.createEntryField("read_only");
        efReadOnly.setVisible(false);
        efReadOnly.setEnabled(false);
        efReadOnly.addWidgetAction(new ReadOnlyActions());

        efDisableBack = segDef.createEntryField("disable_back");
        efDisableBack.setVisible(false);

        /* Visible fields */
        efHldpfx = segDef.createEntryField("hldpfx");
        efHldpfx.setVisible(false);

        efHldnum = segDef.createEntryField("hldnum", "lbl_hldnum");
        efHldnum.setVisible(true);
        efHldnum.setEnabled(true);
        efHldnum.setEntryRequired(true);
        efHldnum.addWidgetAction(new HldnumActions());

        efAssetTyp = segDef.createEntryField("asset_typ", "lbl_asset_typ");
        efAssetTyp.setVisible(true);
        efAssetTyp.setEnabled(true);
        
        efInvtyp = segDef.createEntryField("invtyp", "lbl_invtyp");
        efInvtyp.setVisible(true);
        efInvtyp.setEnabled(true);

        efNottxt = segDef.createEntryField("nottxt", "lbl_nottxt");
        efNottxt.setVisible(true);
        efNottxt.setEnabled(true);

        efWhId.setText(display.getVariable("global.wh_id"));
        efUsrId.setText(display.getVariable("global.usr_id"));
        efDevcod.setText(display.getVariable("global.devcod"));

        // F1
        frmMain.unbind(frmMain.getCancelCommand());
        cmdFkeyBack = new FkeyBackCommand();
        cmdFkeyBack.setVisible(false);
        frmMain.bind(cmdFkeyBack);
        cmdFkeyBack.bind(MtfConstants.VK_FKEY_BACK);

        // F4
        cmdFkeyRemoveHold = new FkeyRemoveHoldCommand();
        cmdFkeyRemoveHold.setVisible(false);
        frmMain.bind(cmdFkeyRemoveHold);
        cmdFkeyRemoveHold.bind(VK_FKEY_REMOVE_HOLD);
    }

    public void run() throws XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XFormAlreadyOnStack {
        this.frmMain.interact();
    }

    public void resetForm() {
        efHldpfx.setVisible(false);
        efHldpfx.setEnabled(false);
        efHldpfx.clear();

        efHldnum.setVisible(true);
        efHldnum.setEnabled(true);
        efHldnum.clear();

        efInvtyp.setVisible(true);
        efInvtyp.setEnabled(true);
        efInvtyp.clear();

        efAssetTyp.setVisible(true);
        efAssetTyp.setEnabled(true);
        efAssetTyp.clear();

        efNottxt.setVisible(true);
        efNottxt.setEnabled(true);
        efNottxt.clear();

        efReadOnly.setVisible(false);
        efReadOnly.setEnabled(false);
        efReadOnly.clear();
        
        efDisableBack.clear();
    }

    private void processUsrRfIdentifyLoadException() throws MocaException {
        MocaResults rsProcess = session.executeCommand(String.format("process usr rf identify load exception "
                + " where devcod = '%s' "
                + "   and wh_id = '%s' "
                + "   and hldpfx = '%s' "
                + "   and hldnum = '%s' "
                + "   and invtyp = '%s' "
                + "   and asset_typ = '%s' "
                + "   and nottxt = '%s' ",
                efDevcod.getText(),
                efWhId.getText(),
                efHldpfx.getText(),
                efHldnum.getText(),
                efInvtyp.getText(),
                efAssetTyp.getText(),
                efNottxt.getText()
        ));
    }

    private class UsrExceptionActions
            extends CWidgetActionAdapter {

        public boolean onFormEntry(IForm _frm) throws Exception {
            boolean retStatus = false;

            try {
                //Update the enabled flag based on readonly.
                if (efReadOnly.getText().equals("1")) {
                    efReadOnly.setEnabled(true);
                    efReadOnly.setVisible(true);

                    efWhId.setEnabled(false);
                    efHldpfx.setEnabled(false);
                    efHldnum.setEnabled(false);
                    efInvtyp.setEnabled(false);
                    efAssetTyp.setEnabled(false);
                    efNottxt.setEnabled(false);
                }

                // If the hldnum is already set it means that the form is opened automatically with prefilled values.
                // Then we don't want to load existing values.
                if (efHldnum.getText() == null || efHldnum.getText().isEmpty()) {
                    MocaResults rsException = session.executeCommand(String.format(
                            "list usr rf identify load exception information "
                            + " where wh_id = '%s' "
                            + "   and devcod = '%s' ",
                            efWhId.getText(),
                            efDevcod.getText()
                    ));

                    if (rsException.next()) {
                        efHldpfx.setText(rsException.getString("hldpfx"));
                        efHldnum.setText(rsException.getString("hldnum"));
                        efInvtyp.setText(rsException.getString("invtyp"));
                        efAssetTyp.setText(rsException.getString("asset_typ"));
                        efNottxt.setText(rsException.getString("nottxt"));
                    }
                            
                }

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
                processUsrRfIdentifyLoadException();

                resetForm();
                //AFormLogic newFrm = display.createFormLogic(frmMain.getDisplay().getPreviousFormOnStack().getIdentifier());
                //newFrm.run();
                retStatus = true;
            } catch (MocaException e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
            }

            return retStatus;
        }
    }

    private class HldnumActions extends CWidgetActionAdapter {

        public boolean onFieldEntry(IInteractiveWidget _ef) throws Exception {
            return true;
        }

        public boolean onFieldExit(IInteractiveWidget _ef) throws Exception {
            boolean retStatus = false;

            try {
                if (efHldnum.getText() != null) {
                    efHldpfx.setText(efWhId.getText());
                } else {
                    efHldpfx.clear();
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

    private class ReadOnlyActions extends CWidgetActionAdapter {

        public boolean onFieldEntry(IInteractiveWidget _ef) throws Exception {
            return true;
        }

        public boolean onFieldExit(IInteractiveWidget _ef) throws Exception {
            return false;
        }
    }

    private class FkeyBackCommand extends ACommand {
 	    
    	private static final long serialVersionUID = 0L;
        public FkeyBackCommand() {
            super("cmdFkeyBack", "FkeyBack", MtfConstants.FKEY_BACK_CAPTION, '1');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            if (!efDisableBack.getText().equals("1")) {
                resetForm();
                frmMain.formReturn();
            }

            //AFormLogic newFrm = display.createFormLogic(frmMain.getDisplay().getPreviousFormOnStack().getIdentifier());
            //newFrm.run();
        }
    }

    private class FkeyRemoveHoldCommand extends ACommand {
    	
 	    private static final long serialVersionUID = 0L;
        public FkeyRemoveHoldCommand() {
            super("cmdFkeyRemoveHold", "FkeyRemoveHold", VK_FKEY_REMOVE_HOLD_CAPTION, '4');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            try {
                if (efHldnum.getText() != null) {
                    if (frmMain.promptMessageYN("Hold Verwijderen?") == 1) {
                        resetForm();

                        processUsrRfIdentifyLoadException();
                        frmMain.promptMessageAnyKey("Hold verwijderd");
                        frmMain.formReturn();
                    }
                }
            } catch (MocaException e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
            }
        }
    }
}
