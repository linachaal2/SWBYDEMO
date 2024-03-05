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

public class UsrIdentifyLoadAdjDtl
        extends AFormLogic {

    /* Hidden fields */
    private IEntryField efPrevForm;
    private IEntryField efUsrId;
    private IEntryField efDevcod;
    private IEntryField efWhId;
    private IEntryField efReadOnly;

    /* Other variables */
    public CWmdMtfUtil wmdMtf;
    private static final Logger log = Logger.getLogger(UsrIdentifyLoadAdjDtl.class);

    public IFormSegment segDef;

    public static final String FORM_ID = "USR_IDENTIFY_LOAD_ADJ_DTL";
    private static final String FORM_TITLE = "ttlUsrIdentifyLoadAdjDtl";

    /* Visible fields */
    public IEntryField efDtlNum;
    public IEntryField efBarcode;
    public IEntryField efPrtnum;
    public IEntryField efPrtClientId;
    public IEntryField efLotnum;
    public IEntryField efUntqty;
    public IEntryField efReacod;

    /* F1, Previous form. */
    public ICommand cmdFkeyBack;

    public UsrIdentifyLoadAdjDtl(IDisplay _display) throws Exception {
        super(_display);

        wmdMtf = (CWmdMtfUtil) this.session.getGlobalObjMap().get("WMDMTF");

        /* Form */
        frmMain = this.display.createForm(this.FORM_ID);
        frmMain.setTitle(FORM_TITLE);
        frmMain.addWidgetAction(new UsrIdentifyLoadAdjDtlActions());

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
        efReadOnly.setEnabled(false);
        efReadOnly.addWidgetAction(new ReadOnlyActions());
        
        /* Visible fields */
        efDtlNum = segDef.createEntryField("dtlnum", "lbl_dtlnum");
        efDtlNum.setVisible(true);
        efDtlNum.setEnabled(false);
        efDtlNum.setEntryRequired(true);

        efBarcode = segDef.createEntryField("barcode", "lbl_barcode");
        efBarcode.setVisible(true);
        efBarcode.setEnabled(false);
        efBarcode.setEntryRequired(true);

        efPrtnum = segDef.createEntryField("prtnum", "lbl_prtnum");
        efPrtnum.setVisible(true);
        efPrtnum.setEnabled(false);
        efPrtnum.setEntryRequired(true);

        efPrtClientId = segDef.createEntryField("prt_client_id", "lbl_prt_client_id");
        efPrtClientId.setVisible(false);
        efPrtClientId.setEnabled(false);
        efPrtClientId.setEntryRequired(true);

        efLotnum = segDef.createEntryField("lotnum", "lbl_lotnum");
        efLotnum.setVisible(true);
        efLotnum.setEnabled(false);
        efLotnum.setEntryRequired(true);

        efUntqty = segDef.createEntryField("untqty", "lbl_untqty");
        efUntqty.setVisible(true);
        efUntqty.setEnabled(true);
        efUntqty.setEntryRequired(true);

        efReacod = segDef.createEntryField("reacod", "lbl_reacod");
        efReacod.setVisible(true);
        efReacod.setEnabled(true);
        efReacod.setEntryRequired(true);
        
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

    private void resetForm() {
        efDtlNum.setEnabled(false);
        efDtlNum.clear();
        
        efBarcode.setEnabled(false);
        efBarcode.clear();
        
        efPrtnum.setEnabled(false);
        efPrtnum.clear();
        
        efPrtClientId.setEnabled(false);
        efPrtClientId.clear();
        
        efLotnum.setEnabled(false);
        efLotnum.clear();
        
        efUntqty.setEnabled(true);
        efUntqty.clear();
        
        efReacod.setEnabled(true);
        efReacod.clear();
        
        efReadOnly.setVisible(false);
        efReadOnly.setEnabled(false);
        efReadOnly.clear();
    }

    public void run() throws XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XFormAlreadyOnStack {
        this.frmMain.interact();
    }

    private class UsrIdentifyLoadAdjDtlActions
            extends CWidgetActionAdapter {

        public boolean onFormEntry(IForm _frm) throws Exception {
            boolean retStatus = false;
            int retErrorCode = WMDErrors.eOK;
            try {
                //Update the enabled flag based on readonly.
                if(efReadOnly.getText().equals("1")){
                    efReadOnly.setEnabled(true);
                    efReadOnly.setVisible(true);

                    efDtlNum.setEnabled(false);
                    efBarcode.setEnabled(false);
                    efPrtnum.setEnabled(false);
                    efPrtClientId.setEnabled(false);
                    efLotnum.setEnabled(false);                    
                    efUntqty.setEnabled(false);
                    efReacod.setEnabled(false);
                }
                
                MocaResults rsInventoryList = session.executeCommand(String.format(
                        "list usr rf identify load detail information "
                        + " where devcod = '%s' "
                        + "   and dtlnum = '%s' ",
                        efDevcod.getText(),
                        efDtlNum.getText()
                ));

                if (rsInventoryList.getRowCount() == 1 && rsInventoryList.hasNext()) {
                    rsInventoryList.next();

                    efDtlNum.setText(rsInventoryList.getString("dtlnum"));
                    efPrtnum.setText(rsInventoryList.getString("prtnum"));
                    efBarcode.setText(rsInventoryList.getString("barcode"));
                    efPrtClientId.setText(rsInventoryList.getString("prt_client_id"));
                    efLotnum.setText(rsInventoryList.getString("lotnum"));
                    efUntqty.setText(rsInventoryList.getString("untqty"));
                    efReacod.setText(rsInventoryList.getString("reacod"));
                }

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
        			{
        				retStatus = false;
        			}
        		}
            }
            return retStatus;
        }

        public boolean onFormExit(IForm _frm) throws Exception {
            boolean retStatus = false;

            try {
                MocaResults rsDetailAdjustment = session.executeCommand(String.format(
                        "process usr rf identify load detail adjustment "
                        + " where devcod = '%s' "
                        + "   and dtlnum = '%s' "
                        + "   and untqty = '%s' "
                        + "   and reacod = '%s' ",
                        efDevcod.getText(),
                        efDtlNum.getText(),
                        efUntqty.getText(),
                        efReacod.getText()
                ));

                resetForm();
                
                retStatus = true;
            } catch (MocaException e) {
                /* If we get an exception, show the error and make the user enter another value. */
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
            resetForm();
            
            frmMain.formBack();
            //AFormLogic newFrm = display.createFormLogic(frmMain.getDisplay().getPreviousFormOnStack().getIdentifier());
            //newFrm.run();
        }
    }
}
