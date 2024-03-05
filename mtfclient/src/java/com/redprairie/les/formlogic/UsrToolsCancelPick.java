package com.redprairie.les.formlogic;

import java.util.List;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.wmd.formlogic.ToolsCancelPick;
import com.redprairie.wmd.WMDConstants;
import com.redprairie.wmd.WMDErrors;
import com.redprairie.mtf.MtfConstants;
import com.redprairie.wmd.mtfutil.CWmdMtfUtil;
import com.redprairie.mtf.CMtfUtil;

public class UsrToolsCancelPick extends ToolsCancelPick {

	public UsrToolsCancelPick(IDisplay _display) throws Exception {
		super(_display);
        
        frmMain.removeValidator(actToolsCancelPick);

        frmMain.addWidgetAction(new UsrToolsCancelPickActions());
		
	}

	private class UsrToolsCancelPickActions extends CWidgetActionAdapter {

		public boolean onFormEntry(IForm _frm) throws Exception {
            
            if (calledFromPalletMoveForm()) {
                MocaResults    rs         = null;
                int            retStatus  = WMDErrors.eOK;
                
                efSrcloc.setText(display.getVariable("USR_UNDIR_PALLET_MOVE.srcloc"));
                
                efWrkref.setEnabled(false);
                efWrkref.setVisible(false);
                efWrkref.setEntryRequired(false);
                
                try {
                    rs = null;
                    retStatus = WMDErrors.eOK;
                    rs = session.executeDSQL("[select codval into :codval from cancod where rftflg=1 and defflg=1]");
                }
                catch (MocaException e) {
                    retStatus = e.getErrorCode();
                }

                if (rs != null && retStatus == WMDErrors.eOK) {
                    retStatus = CMtfUtil.getResults(display);
                    rs = session.getGlobalMocaResults();
                }

                display.setVariable("INIT_POLICIES.prvfrm", "TOOLS_CANCEL_PICK");
                return true;

            }
            else {            

			    return actToolsCancelPick.onFormEntry(frmMain);
            }
		}

		public boolean onFormExit(IForm _frm) throws Exception {

            if (calledFromPalletMoveForm()) {
                MocaResults    rs         = session.getGlobalMocaResults();
                int            retStatus  = WMDErrors.eOK;
                
                if (frmMain.promptMessageYN(DLG_OK_TO_CANCEL) == 0) {
                    frmMain.formBack();
                }
                
                frmMain.displayMessage(MtfConstants.RF_MSG_PROCESSING);
                
                if (CMtfUtil.verify(efErrflg.getText(), MtfConstants.RF_FLAG_TRUE) == 1) {
                    try {
                        rs = null;
                        retStatus = WMDErrors.eOK;
                        rs = session.executeDSQL("error location "+
                                                 "where stoloc = '" + efSrcloc.getText() + "' " +
                                                 "  and wh_id = '" + display.getVariable("global.wh_id") + "'");
                    }
                    catch (MocaException e) {
                        retStatus = e.getErrorCode();
                    }
                    
                    if (retStatus != WMDErrors.eOK) {
                        display.beep();
                        frmMain.promptMessageAnyKey("errErrorLocation");
                        frmMain.formBack();
                    }
                }
                
                try {
                    
                    rs = null;
                    rs = session.executeDSQL("process usr cancel pallet move " +
                                             "  where cancod = '" + efCodval.getText() + "'" +
                                             "    and oprcod = '" + wmdMtf.getWrkQue().getOprCod() + "'" +
                                             "    and devcod = '" + display.getVariable("global.devcod") + "'" +
                                             "    and list_id = '" + display.getVariable("USR_UNDIR_PALLET_MOVE.list_id") + "'" +
                                             "    and wh_id = '" + display.getVariable("global.wh_id") + "' ");
                    
                    if (efCodval.getText().equals(WMDConstants.CANCOD_REALLOC) 
                        || efCodval.getText().equals(WMDConstants.CANCOD_REALLOC_REUSE_LOC)) {
                        display.beep();
                        frmMain.promptMessageAnyKey(WMDConstants.STS_REALLOCATION_SUCCESSFUL);
                    }
                    else {
                        display.beep();
                        frmMain.promptMessageAnyKey(WMDConstants.STS_PICK_CANCEL);
                    }
                    
                    frmMain.formBack();
                }
                catch (MocaException e) {
                    display.beep();
                    frmMain.promptMessageAnyKey("errCancelPick");
                    frmMain.formBack();
                }
                return false;

            }
            else {            

			    return actToolsCancelPick.onFormExit(frmMain);
            }
		}
	}
    
    private boolean calledFromPalletMoveForm() {
        // Get the current form stack.
        List<String> formStack = display.getFormStack();

        if (!(formStack.get(1).equals("TOOLS_MENU") 
                 && formStack.get(2).equals("USR_UNDIR_PALLET_MOVE"))) {
            return false;
        }
        return true;
    }
}
