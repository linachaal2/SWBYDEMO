package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.mtf.MtfConstants;
import com.redprairie.mtf.CMtfUtil;
import com.redprairie.mtf.exceptions.XFailedRequest;
import com.redprairie.mtf.exceptions.XFormAlreadyOnStack;
import com.redprairie.mtf.exceptions.XInvalidArg;
import com.redprairie.mtf.exceptions.XInvalidRequest;
import com.redprairie.mtf.exceptions.XInvalidState;
import com.redprairie.mtf.foundation.presentation.ACommand;
import com.redprairie.mtf.foundation.presentation.AFormLogic;
import com.redprairie.mtf.foundation.presentation.ATimerAction;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.ICommand;
import com.redprairie.mtf.foundation.presentation.IContainer;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.mtf.foundation.presentation.IFormSegment;
import com.redprairie.mtf.foundation.presentation.IStaticText;
import com.redprairie.mtf.foundation.presentation.ITimerAction;
import com.redprairie.mtf.foundation.presentation.IWidgetActionValidator;
import com.redprairie.mtf.foundation.presentation.IInteractiveWidget;
import com.redprairie.wmd.WMDConstants;
import com.redprairie.wmd.WMDErrors;
import com.redprairie.wmd.mtfutil.CWmdMtfUtil;
import com.redprairie.wmd.mtfutil.CVehLodLimit;


public class UsrUndirPalletMove extends AFormLogic {

    public IWidgetActionValidator    actUsrUndirPalletMove;
    public IFormSegment              segDef;
    public IEntryField               efSrcloc;
    public IEntryField               efTotalQty;
    public IEntryField               efLodnum;
    public IWidgetActionValidator    actLodnum;
    public IEntryField               efNoAsset;
    public IEntryField               efUntqty;
    public IWidgetActionValidator    actUntqty;
    public IEntryField               efUomcod;
    public IWidgetActionValidator    actUomcod;
    
    public IEntryField               efListId;
    public IEntryField               efReqnum;

    public ICommand                  cmdFkeyBack;

    public CWmdMtfUtil               wmdMtf = (CWmdMtfUtil) session.getGlobalObjMap().get("WMDMTF");
    
    String uomcod = "";
    
    public UsrUndirPalletMove(IDisplay _display) throws Exception {

        super(_display);

        // Create form and default segment
        frmMain = display.createForm("USR_UNDIR_PALLET_MOVE");
        actUsrUndirPalletMove = this.new UsrUndirPalletMoveActions();
        frmMain.addWidgetAction(actUsrUndirPalletMove);

        segDef = frmMain.createSegment("segDef", false);
        frmMain.setTitle("ttlUsrUndirPalletMove");

        // Create widgets on the form
        efSrcloc = segDef.createEntryField("srcloc", "lblSrcloc");
        efSrcloc.setEnabled(false);
        efSrcloc.setVisible(true);
        efSrcloc.setEntryRequired(false);

        efTotalQty = segDef.createEntryField("total_qty", "LblTotalQty");
        efTotalQty.setEnabled(false);
        efTotalQty.setVisible(true);
        efTotalQty.setEntryRequired(false);
        
        efNoAsset = segDef.createEntryField("no_asset", "lbl_no_asset");
        efNoAsset.setVisible(true);
        efNoAsset.setEnabled(false);
        efNoAsset.setEntryRequired(false);
        
        efLodnum = segDef.createEntryField("lodnum", "lblLodnum");
        efLodnum.setEnabled(true);
        efLodnum.setVisible(true);
        efLodnum.setEntryRequired(true);
        actLodnum = this.new LodnumActions();
        efLodnum.addWidgetAction(actLodnum);
        
        efUntqty = segDef.createEntryField("untqty", "lblUntqty");
        efUntqty.setEnabled(true);
        efUntqty.setVisible(true);
        efUntqty.setEntryRequired(true);
        actUntqty = this.new UntqtyActions();
        efUntqty.addWidgetAction(actUntqty);

        efUomcod = segDef.createEntryField("uomcod");
        efUomcod.setEnabled(true);
        efUomcod.setVisible(true);
        efUomcod.setEntryRequired(true);
        actUomcod = this.new UomcodActions();
        efUomcod.addWidgetAction(actUomcod);
        
        efListId = segDef.createEntryField("list_id");
        efListId.setEnabled(false);
        efListId.setVisible(false);
        efListId.setEntryRequired(false);
        
        efReqnum = segDef.createEntryField("reqnum");
        efReqnum.setEnabled(false);
        efReqnum.setVisible(false);
        efReqnum.setEntryRequired(false);
        
        // Create and bind function keys
        frmMain.unbind(frmMain.getCancelCommand());
        cmdFkeyBack = this.new FkeyBackCommand();
        cmdFkeyBack.setVisible(false);
        frmMain.bind(cmdFkeyBack);
        cmdFkeyBack.bind(MtfConstants.VK_FKEY_BACK);

    }
    
    /**
     * Display and run the form 
     */
    public void run() throws XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XFormAlreadyOnStack {

        frmMain.interact();
    }

    /**
     * Defines extended ACommand for FkeyBack 
     */
    private class FkeyBackCommand extends ACommand {

        /**
         * Prime constructor.
         */
        public FkeyBackCommand() {
            super("cmdFkeyBack", "FkeyBack",  MtfConstants.FKEY_BACK_CAPTION, '1');
        }

        /**
         * Performs the actions for the function key.
         */
        public void execute(IContainer _container) throws NullPointerException, ClassNotFoundException, XFormAlreadyOnStack, XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, MocaException {
            
            frmMain.clearForm();
            frmMain.formBack();
        }

        private static final long serialVersionUID = 0L;
    }
    
    /**
     * This class contains the entry/exit actions for the efLodnum field 
     */
    private class LodnumActions extends CWidgetActionAdapter {

        public boolean onFieldExit(IInteractiveWidget _ef) throws Exception {

            MocaResults    rs         = session.getGlobalMocaResults();
            int            retStatus  = WMDErrors.eOK;
            
            try {
                rs = null;
                retStatus = WMDErrors.eOK;
                rs = session.executeDSQL(" [select 'x' " +
                                         "    from invlod " +
                                         "    where stoloc = '" + efSrcloc.getText() + "'" +
                                         "      and lodnum = '" + efLodnum.getText() + "'" +
                                         "      and wh_id = '" + display.getVariable("global.wh_id") + "']");
            }
            catch (MocaException e) {
                retStatus = e.getErrorCode();
            }

            if (retStatus != WMDErrors.eOK) {
                display.beep();
                frmMain.promptMessageAnyKey("errInvalidLoadNumber");
                return false;
            }
            
            return true;
        }
    }
    
    private class UntqtyActions extends CWidgetActionAdapter {

        public boolean onFieldExit(IInteractiveWidget _ef) throws Exception {

            try {
                int input = Integer.parseInt(efUntqty.getText());
                if (input < 1){
                    frmMain.promptMessageAnyKey(WMDConstants.MSG_INV_QTY);
                    return false;
                }
            }
            catch (NumberFormatException e) {
                return false;
            }
            return true;
        }
    }
    
    private class UomcodActions extends CWidgetActionAdapter {

        public boolean onFieldExit(IInteractiveWidget _ef) throws Exception {
            
            if (!(efUomcod.getText().equals(uomcod))) {
                display.beep();
                frmMain.promptMessageAnyKey("errInvalidUomcod");
                return false;
            }
            
            if (!(efUntqty.getText().equals(efTotalQty.getText()) && efUomcod.getText().equals(uomcod))) {
                display.beep();
                frmMain.promptMessageAnyKey(WMDConstants.MSG_INV_QTY);
                return false;
            }
            return true;
        }
    }

   
    /**
     * This class contains the entry/exit actions for the form (frmMain) 
     */
    private class UsrUndirPalletMoveActions extends CWidgetActionAdapter {

        public boolean onFormEntry(IForm _frm) throws Exception {

            int  retStatus  = WMDErrors.eOK;
            MocaResults rs = session.getGlobalMocaResults();
            AFormLogic newFrm = null;
            
            efLodnum.clear();
            efNoAsset.clear();
            
            try {
                rs = session.executeDSQL("validate usr location for pallet move " +
                                         "   where srcloc = '" + efSrcloc.getText() + "'" +
                                         "     and list_id = '" + efListId.getText() + "'");
            }
            catch (MocaException e) {
                retStatus = e.getErrorCode();
            }

            if (retStatus != WMDErrors.eOK) {
                
                try {
                    session.executeDSQL("process usr skip pallet move " +
                                        "  where srcloc = '" + efSrcloc.getText() + "'" +
                                        "    and list_id = '" + efListId.getText() + "'" +
                                        "    and reqnum = '" + efReqnum.getText() + "'" +
                                        "    and excp_code = '" + retStatus + "'" +
                                        "    and wh_id = '" + display.getVariable("global.wh_id") + "'" +
                                        "    and devcod = '" + display.getVariable("global.devcod") + "'" +
                                        "    and locale_id = '" + display.getVariable("global.locale_id") + "'");
                }
                catch (MocaException e) {
                    retStatus = e.getErrorCode();
                }
                
                newFrm = display.createFormLogic("LOOK_WORK");
                newFrm.run();
            }
            else {
                rs.next();
                try {
                    if (Integer.parseInt(rs.getString("total_qty")) > 0) {
                        efTotalQty.setText(rs.getString("total_qty"));
                        efUntqty.setText(rs.getString("total_qty"));
                    }
                    else {
                        frmMain.clearForm();
                        frmMain.formBack();
                    }
                }
                catch (NumberFormatException e) {
                    frmMain.clearForm();
                    frmMain.formBack();
                }
                
                uomcod = rs.getString("uomcod");
                efUomcod.setText(uomcod);
                efNoAsset.setText(rs.getString("no_asset"));
            }

            return true;
        }

        public boolean onFormExit(IForm _frm) throws Exception {

            MocaResults    rs         = session.getGlobalMocaResults();
            int            retStatus  = WMDErrors.eOK;
            AFormLogic     newFrm     = null;
            
            frmMain.displayMessage(MtfConstants.RF_MSG_PROCESSING);
            
            try {
                rs = null;
                retStatus = WMDErrors.eOK;
                rs = session.executeDSQL(" process usr pallet move" +
                                         "     where srcloc = '" + efSrcloc.getText() + "'" +
                                         "       and lodnum = '" + efLodnum.getText() + "'" +
                                         "       and list_id = '" + efListId.getText() + "'" +
                                         "       and reqnum = '" + efReqnum.getText() + "'" +
                                         "       and wh_id = '" + display.getVariable("global.wh_id") + "'");
            }
            catch (MocaException e) {
                retStatus = e.getErrorCode();
            }

            if (retStatus != WMDErrors.eOK) {
                display.beep();
                frmMain.displayErrorMessage();
                return false;
            }
            
            //Flow to DEPOSIT_A
            retStatus = CVehLodLimit.checkVehLoadLimit(
                            display.getVariable("INIT_POLICIES.veh_lod_limit"),
                            display.getVariable("global.wh_id"),
                            display.getVariable("global.devcod"),
                            session);
                            
            if (retStatus != WMDErrors.eOK) {
                display.setVariable("DEPOSIT_A.lodnum", efLodnum.getText());
                newFrm = display.createFormLogic("DEPOSIT_A");
                newFrm.run();
            }
            return true;
        }
    }
}
