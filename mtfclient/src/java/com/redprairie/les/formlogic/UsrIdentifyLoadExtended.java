package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.mtf.exceptions.XFailedRequest;
import com.redprairie.mtf.exceptions.XFormAlreadyOnStack;
import com.redprairie.mtf.exceptions.XInvalidArg;
import com.redprairie.mtf.exceptions.XInvalidRequest;
import com.redprairie.mtf.exceptions.XInvalidState;
import com.redprairie.mtf.exceptions.XMissingObject;
import com.redprairie.mtf.foundation.presentation.ACommand;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IContainer;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.mtf.foundation.presentation.ICommand;
import com.redprairie.mtf.foundation.presentation.IInteractiveWidget;
import com.redprairie.wmd.WMDConstants;
import com.redprairie.wmd.WMDErrors;
import com.redprairie.mtf.MtfConstants;


public class UsrIdentifyLoadExtended extends com.redprairie.wmd.formlogic.IdentifyLoad {
    
    public ICommand cmdFkeyBackOverride;
    
	public UsrIdentifyLoadExtended(IDisplay _display) throws Exception {
		super(_display);
        this.frmMain.unbind(this.cmdFkeyBack);
        this.cmdFkeyBack.unbind(MtfConstants.VK_FKEY_BACK);
        
        this.cmdFkeyBackOverride = new FkeyBackOverrideCommand();
        this.cmdFkeyBackOverride.setVisible(false);
        this.frmMain.bind(this.cmdFkeyBackOverride);
        this.cmdFkeyBackOverride.bind(MtfConstants.VK_FKEY_BACK);
	}
    
    private class FkeyBackOverrideCommand extends ACommand {
        private static final long serialVersionUID = 0L;

        public FkeyBackOverrideCommand() {
            super("cmdFkeyBack", "FkeyBack", "lblFkeyBack", '1');
        }

        public void execute(IContainer _container) throws MocaException, NullPointerException, ClassNotFoundException, XFormAlreadyOnStack, XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XMissingObject {
            if (efWkoflg.getText().equals("Y")) {
                moveLpnBackOnProductionStaging(efWkonum.getText(), efInvnum.getText(), efClientId.getText());
            }
            cmdFkeyBack.execute(_container);
        }
    }
    
    
    private void moveLpnBackOnProductionStaging(String wkonum, String wkorev, String client_id) {
        MocaResults    rs         = null;
        int            retStatus  = WMDErrors.eOK;
        
        try {
            rs = session.executeDSQL("create usr move to production station staging " +
                                     "  where wkonum = '" + wkonum + "' " +
                                     "    and wkorev = '" + wkorev + "' " +
                                     "    and client_id = '" + client_id + "' " +
                                     "    and immediate = 1 " +
                                     "    and wh_id = '" + this.display.getVariable("global.wh_id") + "' ");
        }
        catch (MocaException e) {
            retStatus = e.getErrorCode();
        }
        
    }
}