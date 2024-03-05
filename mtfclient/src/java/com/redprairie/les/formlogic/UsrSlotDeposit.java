package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IInteractiveWidget;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.wmd.formlogic.SlotDeposit;

public class UsrSlotDeposit extends SlotDeposit {

	public UsrSlotDeposit(IDisplay _display) throws Exception {
		super(_display);

        frmMain.addWidgetAction(new UsrSlotDepositActions());
	}

	private class UsrSlotDepositActions extends CWidgetActionAdapter {

		public boolean onFormExit(IForm _frm) throws Exception {
            
            if (!efSlot.isEnabled()) {
                return actSlot.onFieldExit((IInteractiveWidget)efSlot);
            }
			return true;
		}
	}
}
