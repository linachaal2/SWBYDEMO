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
import com.redprairie.wmd.WMDErrors;
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

public class UsrIdentifyLoadAdjDsp
        extends AFormLogic {

    /* Hidden fields */
    private IEntryField efPrevForm;
    private IEntryField efUsrId;
    private IEntryField efDevcod;
    private IEntryField efWhId;
    private IEntryField efReadOnly;

    /* Other variables */
    public CWmdMtfUtil wmdMtf;
    private static final Logger log = Logger.getLogger(UsrIdentifyLoadAdjDsp.class);

    public IFormSegment segDef;

    public static final String FORM_ID = "USR_IDENTIFY_LOAD_ADJ_DSP";
    private static final String FORM_TITLE = "ttlUsrIdentifyLoadAdjDsp";

    /* Visible fields */
    public ITextSelection tsListInv;

    /* F1, Previous form. */
    public ICommand cmdFkeyBack;

    public UsrIdentifyLoadAdjDsp(IDisplay _display) throws Exception {
        super(_display);

        wmdMtf = (CWmdMtfUtil) this.session.getGlobalObjMap().get("WMDMTF");

        /* Form */
        frmMain = this.display.createForm(this.FORM_ID);
        frmMain.setTitle(FORM_TITLE);
        frmMain.addWidgetAction(new UsrIdentifyLoadAdjDspActions());

        segDef = frmMain.createSegment("segDef", false);

        /* Hidden fields. */
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

        /* Visible fields */
        tsListInv = segDef.createTextSelection("list_inv");
        tsListInv.setEnabled(true);
        tsListInv.setVisible(true);
        tsListInv.setCompact(false);
        tsListInv.setShowSelection(false);
        tsListInv.setAutoAccept(true);
        tsListInv.addWidgetAction(new ListInvActions());

        /* F1 */
        frmMain.unbind(frmMain.getCancelCommand());
        cmdFkeyBack = this.new FkeyBackCommand();
        cmdFkeyBack.setVisible(false);
        frmMain.bind(cmdFkeyBack);
        cmdFkeyBack.bind(MtfConstants.VK_FKEY_BACK);

        efWhId.setText(display.getVariable("global.wh_id"));
        efUsrId.setText(display.getVariable("global.usr_id"));
        efDevcod.setText(display.getVariable("global.devcod"));
    }

    public void resetForm(){
        efReadOnly.clear();
        
        tsListInv.clear();
    }
    
    public void updateFormData() throws MocaException {
        MocaResults rsInventoryList = session.executeCommand(String.format(
                "list usr rf identify load detail information "
                + " where devcod = '%s' ",
                efDevcod.getText()
        ));

        if (rsInventoryList.hasNext()) {
            //tsListInv.setIdentifier("dtlnum");
            tsListInv.setRetFields("dtlnum");
            tsListInv.setDspFields("invadj_ind,barcode,lotnum,prtnum,untqty");
            tsListInv.addItemsMocaRs(rsInventoryList);
        }
    }

    public void run() throws XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XFormAlreadyOnStack {
        this.frmMain.interact();
    }

    private class UsrIdentifyLoadAdjDspActions
            extends CWidgetActionAdapter {

        public boolean onFormEntry(IForm _frm) throws Exception {
            boolean retStatus = false;
            int retErrorCode = WMDErrors.eOK;
            try {
                updateFormData();

                retStatus = true;
            } catch (MocaException e) {retErrorCode = e.getErrorCode();
        		if (retErrorCode != WMDErrors.eOK) 
        		{
        			if (retErrorCode != 523)
        			{
        				/* If we get an exception, show the error and make the user enter another value. */
        				display.beep();
        				frmMain.promptMessageAnyKey(e.getMessage());
        			}
        			else 
					{
        				retStatus = false;
                	}
        		}
            }

            return retStatus;
        }

        public boolean onFormExit(IForm _frm) throws Exception {
            boolean retStatus = false;
            int retErrorCode = WMDErrors.eOK;
            try {
                if (tsListInv.getSelectedItem() != null && !tsListInv.getSelectedItem().isEmpty()) {
                    /* Open the detail adjustment form. */
                    display.setVariable("INIT_POLICIES.prvfrm", FORM_ID);
                    AFormLogic newFrm = display.createFormLogic(UsrIdentifyLoadAdjDtl.FORM_ID, MtfConstants.EFlow.SHOW_FORM);
                    /* Set the detail number of the selected inventory so the adjustment detail form knows what to show. */
                    display.setVariable(UsrIdentifyLoadAdjDtl.FORM_ID + ".dtlnum", tsListInv.getSelectedItem());
                    display.setVariable(UsrIdentifyLoadAdjDtl.FORM_ID + ".read_only", efReadOnly.getText());
                    newFrm.run();

                    updateFormData();
                }
            } catch (MocaException e)  {retErrorCode = e.getErrorCode();
            	if (retErrorCode != WMDErrors.eOK) 
            	{
            		if (retErrorCode != 523)
            		{
            			/* If we get an exception, show the error and make the user enter another value. */
            			display.beep();
            			frmMain.promptMessageAnyKey(e.getMessage());
            		}
            		else 
            		{
            			retStatus = false;
            		}
            	}
            }

            return retStatus;
        }
    }

    private class ListInvActions extends CWidgetActionAdapter {

        public boolean onFieldExit(IInteractiveWidget _ef) throws Exception {
            boolean retStatus = false;
            int retErrorCode = WMDErrors.eOK;
            try {
                /* We do nothing here, we will handle it in FormExit */
                retStatus = true;
            } catch (Exception e)  {
                /* If we get an exception, show the error and make the user enter another value. */
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
            }

            return true;
        }
    }

    private class FkeyBackCommand extends ACommand {

        public FkeyBackCommand() {
            super("cmdFkeyBack", "FkeyBack", MtfConstants.FKEY_BACK_CAPTION, '1');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            resetForm();
            
            frmMain.formReturn();
            
            //AFormLogic newFrm = display.createFormLogic(frmMain.getDisplay().getPreviousFormOnStack().getIdentifier());
            //newFrm.run();
        }
    }

}
