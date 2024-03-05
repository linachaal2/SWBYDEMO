package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.mtf.MtfConstants;
import com.redprairie.mtf.foundation.presentation.AFormLogic;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.wmd.formlogic.UndirTransfer;

public class UsrUndirTransfer extends UndirTransfer {

	public  IEntryField efnrofloadcarriers;

	public UsrUndirTransfer(IDisplay _display) throws Exception {
		super(_display);

        frmMain.addWidgetAction(new UsrUndirTransferActions());
		

        efnrofloadcarriers = segDef.createEntryField("nrofloadcarriers","lblnrofloadcarriers");
        efnrofloadcarriers.setVisible(true);
        efnrofloadcarriers.setEnabled(false);      
        
        
	}

	private class UsrUndirTransferActions extends CWidgetActionAdapter {

		public boolean onFormEntry(IForm _frm) throws Exception {
			boolean retStatus = false;
			
			try {
				// get the number of scanned lpns
				MocaResults rsprt_client_id = session.executeCommand(
						String.format(
								"get usr rf scanned lpn count " + 
								" where wh_id = '%s' " +
								"   and devcod = '%s' ",
								display.getVariable("global.wh_id")	,
								display.getVariable("global.devcod")	
								)
						);

				if (rsprt_client_id.next()) {
					efnrofloadcarriers.setText(rsprt_client_id.getString("scanned_lpn_cnt"));
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
	}

