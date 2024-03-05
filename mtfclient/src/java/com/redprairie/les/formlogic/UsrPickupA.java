package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.wmd.formlogic.PickupA;

public class UsrPickupA extends PickupA {

	public IEntryField efUntqtyGp;

	public UsrPickupA(IDisplay _display) throws Exception {
		super(_display);

        frmMain.addWidgetAction(new UsrPickupAActions());
		
		efUntqtyGp = segDef.createEntryField("untqty_gp", "lbl_untqty_gp");
		efUntqtyGp.setVisible(true);
		efUntqtyGp.setEnabled(false);
		
	}

	private class UsrPickupAActions extends CWidgetActionAdapter {

		public boolean onFormEntry(IForm _frm) throws Exception {
			boolean retStatus = false;

			try {
				// Check if there is a GP qty which we need to show for this pick.
				MocaResults rsUntqtyGp = session.executeCommand(
						String.format(
								"list usr rf pickup_a untqty_gp " + 
								" where wh_id = '%s' " + 
								"   and wrkref = '%s' ",
								display.getVariable("global.wh_id"), 
								efWrkref.getText()
								)
						);

				if (rsUntqtyGp.next()) {
					efUntqtyGp.setText(rsUntqtyGp.getString("untqty_gp"));
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

			return true;
		}
	}
}
