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
import com.redprairie.wmd.WMDConstants;
import com.redprairie.wmd.WMDErrors;
import com.redprairie.wmd.mtfutil.CWmdMtfUtil;


public class UsrDirPalletMove extends AFormLogic {

    // Instance Variables
    public IWidgetActionValidator    actUsrDirPalletMove;
    public IFormSegment              segDef;
    private IStaticText              lblPressEnterToAcknowledge;
    public IEntryField               efAckflg;
    public IEntryField               efSrcloc;
    public IEntryField               efTotalPicks;

    public ICommand                  cmdFkeyBack;
    public ICommand                  cmdFkeyDeposit;
    
    public ITimerAction              timerForm;
    public CWmdMtfUtil               wmdMtf = (CWmdMtfUtil) session.getGlobalObjMap().get("WMDMTF");

    // Global session variables
    private String whId;
    public UsrDirPalletMove(IDisplay _display) throws Exception {

        super(_display);

        // Create form and default segment
        frmMain = display.createForm("USR_DIR_PALLET_MOVE");
        actUsrDirPalletMove = this.new UsrDirPalletMoveActions();
        frmMain.addWidgetAction(actUsrDirPalletMove);

        segDef = frmMain.createSegment("segDef", false);
        frmMain.setTitle("ttlUsrDirPalletMove");
        
        // Get a reference to global session variables
        whId = display.getVariable("global.wh_id");

        // Create widgets on the form
        efSrcloc = segDef.createEntryField("srcloc", "lblSrcloc");
        efSrcloc.setEnabled(false);
        efSrcloc.setVisible(true);
        efSrcloc.setEntryRequired(false);

        lblPressEnterToAcknowledge = segDef.createStaticText("lblPressEnterToAcknowledge");

        efAckflg = segDef.createEntryField("ackflg");
        efAckflg.setEnabled(true);
        efAckflg.setVisible(true);
        efAckflg.setEntryRequired(false);
        
        efTotalPicks = segDef.createEntryField("total_picks", "LblListTotalPicks");
        efTotalPicks.setEnabled(false);
        efTotalPicks.setVisible(true);
        efTotalPicks.setEntryRequired(false);
        
        // Create and bind function keys

        frmMain.unbind(frmMain.getCancelCommand());
        cmdFkeyBack = this.new FkeyBackCommand();
        cmdFkeyBack.setVisible(false);
        frmMain.bind(cmdFkeyBack);
        cmdFkeyBack.bind(MtfConstants.VK_FKEY_BACK);
        
        cmdFkeyDeposit = this.new FkeyDepositCommand();
        cmdFkeyDeposit.setVisible(false);
        frmMain.bind(cmdFkeyDeposit);
        cmdFkeyDeposit.bind(WMDConstants.VK_FKEY_DEPOSIT);

        timerForm = new FormTimerActions(MtfConstants.RF_TIMER_LENGTH_IN_SECONDS, true);
        frmMain.addTimerAction(timerForm);
    }
    
    /**
     * Display and run the form 
     */
    public void run() throws XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XFormAlreadyOnStack {

        timerForm.setEnabled(true);
        frmMain.interact();
        timerForm.setEnabled(false);
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
            AFormLogic     newFrm     = null;

            // If a user presses F1 before acknowledging the work, clear fields below to avoid unwanted form flow issues
            display.clearField("USR_UNDIR_PALLET_MOVE.list_id");
            display.clearField("USR_UNDIR_PALLET_MOVE.srcloc");
            display.clearField("USR_UNDIR_PALLET_MOVE.reqnum");
            
            newFrm = display.createFormLogic("CHANGE_MODE_UNDIR");
            newFrm.run();
        }

        private static final long serialVersionUID = 0L;
    }

    /**
     * Defines extended ACommand for FkeyDeposit 
     */
    private class FkeyDepositCommand extends ACommand {

        /**
         * Prime constructor.
         */
        public FkeyDepositCommand() {
            super("cmdFkeyDeposit", "FkeyDeposit", WMDConstants.FKEY_DEPOSIT_CAPTION, '6');
        }

        /**
         * Performs the actions for the function key.
         */
        public void execute(IContainer _container) throws NullPointerException, ClassNotFoundException, XFormAlreadyOnStack, XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, MocaException {

            AFormLogic     newFrm     = null;

            display.setVariable("INIT_POLICIES.prvfrm", "LOOK_WORK");
            display.setVariable("LOAD_SPLIT_DISPLAY.InitialRun", MtfConstants.RF_FLAG_TRUE);
            display.setVariable("LOAD_SPLIT_DISPLAY.prvfrm", "LOOK_WORK");
            newFrm = display.createFormLogic("LOAD_SPLIT_DISPLAY");
            newFrm.run();
        }

        private static final long serialVersionUID = 0L;
    }
    
    /**
     * Timer task class for form. 
     */
    private class FormTimerActions extends ATimerAction {

        public FormTimerActions(int durSec, boolean actFlg) {
            super(durSec, actFlg);
        }

        /**
         * Performs the actions for the timerForm timer.
         */
        public void onTimer(IForm _frm) throws Exception {

            AFormLogic     newFrm     = null;

            newFrm = display.createFormLogic("TIMED_OUT");
            newFrm.run();
        }

    }

    /**
     * This class contains the entry/exit actions for the form (frmMain) 
     */
    private class UsrDirPalletMoveActions extends CWidgetActionAdapter {

        public boolean onFormEntry(IForm _frm) throws Exception {

            AFormLogic     newFrm     = null;
            MocaResults    rs         = session.getGlobalMocaResults();
            int            retStatus  = WMDErrors.eOK;
            String         list_id    = "";

            // Reset form 
            frmMain.clearForm();
            // Reset form timer 
            timerForm.setTimerDuration(Integer.parseInt(display.getVariable("INIT_POLICIES.timerlength")));
            
            // Get work request pick list information 
            try {
                rs = null;
                retStatus = WMDErrors.eOK;
                rs = session.executeDSQL("[select distinct pcklst.list_id," +
                                         "        pckwrk_view.srcloc, " +
                                         "        wrkque.reqnum " +
                                         "   from pcklst " +
                                         "   join wrkque " +
                                         "     on pcklst.list_id = wrkque.list_id " +
                                         "   join pckwrk_view " +
                                         "     on pcklst.list_id = pckwrk_view.list_id " +
                                         "  where wrkque.reqnum = '" + wmdMtf.getWrkQue().getReqNum() + "']");
            }
            catch (MocaException e) {
                retStatus = e.getErrorCode();
            }

            if (rs != null && retStatus == WMDErrors.eOK) {
                retStatus = CMtfUtil.getResults(display);
                rs = session.getGlobalMocaResults();
            }

            // If pick list info is undefined, then run 'complete_work' form 
            
            if (retStatus != WMDErrors.eOK) {
                newFrm = display.createFormLogic("COMPLETE_WORK");
                newFrm.run();
            }
            
            // Update 'previous form in sequence' field
            display.setVariable("INIT_POLICIES.prvfrm", "USR_DIR_PALLET_MOVE");
            
            list_id = rs.getString("list_id");
            efSrcloc.setText(rs.getString("srcloc"));
            
            display.setVariable("USR_UNDIR_PALLET_MOVE.list_id", list_id);
            display.setVariable("USR_UNDIR_PALLET_MOVE.srcloc", rs.getString("srcloc"));
            display.setVariable("USR_UNDIR_PALLET_MOVE.reqnum", rs.getString("reqnum"));

            // Get the data for displaying total picks
            try {
                rs = null;
                retStatus = WMDErrors.eOK;
                rs = session.executeDSQL(" [select count(*) total_picks " +
                                         "    from pckwrk_hdr " +
                                         "   where list_id = '" + list_id + "'" +
                                         "     and wh_id = '" + display.getVariable("global.wh_id") + "']");
            }
            catch (MocaException e) {
                retStatus = e.getErrorCode();
            }

            if (rs != null && retStatus == WMDErrors.eOK) {
                rs.next();
                efTotalPicks.setText(rs.getString("total_picks"));
            }

            // If auto-acknowledge is enabled, then run 'assign_work' form 
            if (CMtfUtil.verify(display.getVariable("global.auto_acknowledge"), MtfConstants.RF_FLAG_YES) == 1) {
                newFrm = display.createFormLogic("ASSIGN_WORK");
                newFrm.run();
            }
            
            return true;
        }

        public boolean onFormExit(IForm _frm) throws Exception {

            AFormLogic     newFrm     = null;

            // Run 'assign_work' form 
            newFrm = display.createFormLogic("ASSIGN_WORK");
            newFrm.run();
            return false;
        }
    }
}
