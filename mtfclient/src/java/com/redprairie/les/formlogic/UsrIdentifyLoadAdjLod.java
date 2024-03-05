package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
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
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.mtf.foundation.presentation.IFormSegment;
import com.redprairie.mtf.foundation.presentation.IInteractiveWidget;
import com.redprairie.wmd.WMDErrors;
import com.redprairie.wmd.mtfutil.CWmdMtfUtil;
import org.apache.log4j.Logger;
import java.text.SimpleDateFormat;

public class UsrIdentifyLoadAdjLod
        extends AFormLogic {

    /* Hidden fields */
    public IEntryField efPrevForm;
    public IEntryField efUsrId;
    public IEntryField efDevcod;
    public IEntryField efWhId;
    public IEntryField efReadOnly;

    /* Other variables */
    public CWmdMtfUtil wmdMtf;
    private static final Logger log = Logger.getLogger(UsrIdentifyLoadAdjLod.class);

    public IFormSegment segDef;

    public static final String FORM_ID = "USR_IDENTIFY_LOAD_ADJ_LOD";
    private static final String FORM_TITLE = "ttlUsrIdentifyLoadAdjLod";
    
    // Visible fields
    public IEntryField efInvAttrStr7;
    public IEntryField efInvAttrDte1;
    public IEntryField efInvAttrStr10;
    public IEntryField efInvAttrStr11;
    public IEntryField efLoadAttr1Flg;
    public IEntryField efAssetQty;

    /* F1, Previous form. */
    public ICommand cmdFkeyBack;

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");

    public UsrIdentifyLoadAdjLod(IDisplay _display) throws Exception {
        super(_display);

        wmdMtf = (CWmdMtfUtil) this.session.getGlobalObjMap().get("WMDMTF");

        /* Form */
        frmMain = this.display.createForm(this.FORM_ID);
        frmMain.setTitle(FORM_TITLE);
        frmMain.addWidgetAction(new UsrIdentifyLoadAdjLodActions());

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

        /* Visible fields */
        efLoadAttr1Flg = segDef.createEntryField("load_attr1_flg", "lbl_load_attr1_flg");
        efLoadAttr1Flg.setVisible(true);
        efLoadAttr1Flg.setEnabled(true);

        efAssetQty = segDef.createEntryField("asset_qty", "lbl_asset_qty");
        efAssetQty.setVisible(true);
        efAssetQty.setEnabled(true);
        efAssetQty.setEntryRequired(true);
        
        efInvAttrStr7 = segDef.createEntryField("inv_attr_str7", "lbl_inv_attr_str7");
        efInvAttrStr7.setVisible(true);
        efInvAttrStr7.setEnabled(true);

        efInvAttrDte1 = segDef.createEntryField("inv_attr_dte1", "lbl_inv_attr_dte1");
        efInvAttrDte1.setVisible(true);
        efInvAttrDte1.setEnabled(true);

        efInvAttrStr10 = segDef.createEntryField("inv_attr_str10", "lbl_inv_attr_str10");
        efInvAttrStr10.setVisible(true);
        efInvAttrStr10.setEnabled(true);

        efInvAttrStr11 = segDef.createEntryField("inv_attr_str11", "lbl_inv_attr_str11");
        efInvAttrStr11.setVisible(true);
        efInvAttrStr11.setEnabled(true);
        
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

    public void resetForm() {
        efLoadAttr1Flg.setEnabled(true);
        efLoadAttr1Flg.clear();

        efAssetQty.setEnabled(true);
        efAssetQty.clear();
    	
    	efInvAttrStr7.setEnabled(true);
        efInvAttrStr7.clear();

        efInvAttrDte1.setEnabled(true);
        efInvAttrDte1.clear();

        efInvAttrStr10.setEnabled(true);
        efInvAttrStr10.clear();

        efInvAttrStr11.setEnabled(true);
        efInvAttrStr11.clear();

        efReadOnly.setVisible(false);
        efReadOnly.setEnabled(false);
        efReadOnly.clear();
    }

    /*
    private String translateYNto10(String value){
        if(value != null && value.equals("Y")){
            return "1";
        }else{
            return "0";
        }
    }
    
    private String translate10toYN(String value){
        if(value != null && value.equals("1")){
            return "Y";
        }else{
            return "N";
        }
    }
    */
    
    public void run() throws XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XFormAlreadyOnStack {
        this.frmMain.interact();
    }

    private class UsrIdentifyLoadAdjLodActions
            extends CWidgetActionAdapter {

        public boolean onFormEntry(IForm _frm) throws Exception {
            boolean retStatus = false;
            int retErrorCode = WMDErrors.eOK;
            try {
                //Update the enabled flag based on readonly.
                if (efReadOnly.getText().equals("1")) {
                    efReadOnly.setEnabled(true);
                    efReadOnly.setVisible(true);

                    efLoadAttr1Flg.setEnabled(false);
                    efAssetQty.setEnabled(false);
                    efInvAttrStr7.setEnabled(false);
                    efInvAttrDte1.setEnabled(false);
                    efInvAttrStr10.setEnabled(false);
                    efInvAttrStr11.setEnabled(false);
                }

                MocaResults rsInventoryList = session.executeCommand(String.format("list usr rf identify load adjust load information "
                        + " where devcod = '%s' ",
                        efDevcod.getText()
                ));

                if (rsInventoryList.getRowCount() == 1 && rsInventoryList.hasNext()) {
                    rsInventoryList.next();
                    efLoadAttr1Flg.setText(rsInventoryList.getString("load_attr1_flg"));
                    efAssetQty.setText(rsInventoryList.getString("asset_qty"));
                    efInvAttrStr7.setText(rsInventoryList.getString("inv_attr_str7"));
                    efInvAttrStr10.setText(rsInventoryList.getString("inv_attr_str10"));
                    efInvAttrStr11.setText(rsInventoryList.getString("inv_attr_str11"));
                    efInvAttrDte1.setText(rsInventoryList.getString("inv_attr_dte1"));
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
                MocaResults rsDetailAdjustment = session.executeCommand(String.format("process usr rf identify load adjust load "
                        + " where devcod = '%s' "
                        + "   and inv_attr_str7 = '%s' "
                        + "   and inv_attr_str10 = '%s' "
                        + "   and inv_attr_str11 = '%s' "
                        + "   and inv_attr_dte1 = '%s' "
                        + "   and load_attr1_flg = '%s' "
                        + "   and asset_qty = '%s' ",
                        efDevcod.getText(),
                        efInvAttrStr7.getText(),
                        efInvAttrStr10.getText(),
                        efInvAttrStr11.getText(),
                        efInvAttrDte1.getText(),
                        efLoadAttr1Flg.getText(),
                        efAssetQty.getText()
                ));

                resetForm();

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
            frmMain.formReturn();
            //AFormLogic newFrm = display.createFormLogic(frmMain.getDisplay().getPreviousFormOnStack().getIdentifier());
            //newFrm.run();
        }
    }
}
