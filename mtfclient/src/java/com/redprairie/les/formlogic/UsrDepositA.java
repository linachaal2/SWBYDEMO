package com.redprairie.les.formlogic;

import java.util.List;
import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.mtf.MtfConstants;
import com.redprairie.mtf.exceptions.XFailedRequest;
import com.redprairie.mtf.exceptions.XFormAlreadyOnStack;
import com.redprairie.mtf.foundation.presentation.ACommand;
import com.redprairie.mtf.foundation.presentation.AFormLogic;
import com.redprairie.mtf.foundation.presentation.CVirtualKey;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.ICommand;
import com.redprairie.mtf.foundation.presentation.IContainer;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.mtf.foundation.presentation.IInteractiveWidget;
import com.redprairie.mtf.foundation.presentation.IVirtualKey;
import com.redprairie.wmd.WMDErrors;
import com.redprairie.wmd.formlogic.DepositA;

public class UsrDepositA extends DepositA {


	public  IEntryField efnrofloadcarriers;
    
	public UsrDepositA(IDisplay _display) throws Exception {
		super(_display);

        frmMain.removeValidator(actDepositA);
        frmMain.addWidgetAction(new UsrDepositAActions());
        UsrDepositA.this.efDstloc.addWidgetAction(new NewDepositOptFlg());
        
        efnrofloadcarriers = segDef.createEntryField("nrofloadcarriers","lblnrofloadcarriers");
        efnrofloadcarriers.setVisible(true);
        efnrofloadcarriers.setEnabled(false); 
           
	}
    
    private boolean calledFromPickupAForm() {
        // Get the current form stack.
        List<String> formStack = display.getFormStack();
        
        for (int i = 0; i < formStack.size() ; i++)
        {
            if (formStack.get(i).equals("PICKUP_A")) {
                return true;
            }
        }
        return false;
    }

	
	private class UsrDepositAActions extends CWidgetActionAdapter {

		public boolean onFormEntry(IForm _frm) throws Exception {
			
			boolean retStatus = false;
			int retErrorCode = WMDErrors.eOK;
            
            if (UsrDepositA.this.calledFromPickupAForm()) {
                /* check for incomplete list and merge the slot loads into one */
                try {
                    UsrDepositA.this.session.executeDSQL("[select lodnum " +
                                                              "   from invlod " +
                                                              "  where stoloc = '" + UsrDepositA.this.display.getVariable("global.devcod") + "'" +
                                                              "    and rownum = 1] catch(-1403)" +
                                                              "| " +
                                                              "if (@? = 0) " +
                                                              "{ " +
                                                              "validate rf inventory picked for incomplete pick list " +
                                                              "where invtid = @lodnum " +
                                                              "  and wh_id = '" + UsrDepositA.this.display.getVariable("global.wh_id") + "' " +
                                                              "  and colnam = 'lodnum' catch(-1403)" +
                                                              "| " +
                                                              "if (@? = 0) " +
                                                              "{ " +
                                                              "process usr merge pick list slots " +
                                                              "  where list_id = @list_id " +
                                                              "  and wh_id = '" + UsrDepositA.this.display.getVariable("global.wh_id") + "' " +
                                                              "}" +
                                                              "}");
                }
                catch (MocaException e) {
                }
            }
            
            if (actDepositA.onFormEntry(_frm))
            {    
                try {
                    // Get the destination location
                    MocaResults rsusrdata = session.executeCommand(
                            String.format(
                                    "get usr hop location for mixed delivery locations " +
                                    " where wh_id = '%s' " +
                                    "   and devcod = '%s' ",
                                    display.getVariable("global.wh_id")	,
                                    display.getVariable("global.devcod")	
                                    )
                            );

                    if (rsusrdata.getRowCount() == 1 && rsusrdata.hasNext()) {
                        rsusrdata.next();
                        efnrofloadcarriers.setText(rsusrdata.getString("scanned_lpn_cnt"));
                        if (rsusrdata.getString("stoloc") != null  && rsusrdata.getString("dsploc2") != null)
                        {
                        UsrDepositA.this.efDsploc1.setText(rsusrdata.getString("stoloc"));
                        UsrDepositA.this.efDsploc2.setText(rsusrdata.getString("dsploc2"));
                        }
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
            }
			
			return retStatus;
		}	
        
        public boolean onFormExit(IForm _frm) throws Exception {
            return actDepositA.onFormExit(_frm);
        }
	}
		

	public class NewDepositOptFlg extends CWidgetActionAdapter {

		public boolean onFieldEntry(IInteractiveWidget _ef) throws Exception {
           boolean retStatus = false;            
           
           frmMain.refresh();
   		
            try {
                if(	UsrDepositA.this.efDepositOptFlg.getText().equals("1")) {
                	UsrDepositA.this.display.setVariable("INIT_POLICIES.exitpntpredeposit", "1");        			
                }
                	
                if (display.getVariable("INIT_POLICIES.exitpntpredeposit").equals("1")) {          
                if (UsrDepositA.this.efDsploc1.getText().length() > 0) {
                    AFormLogic newFrm = null;
                   	UsrDepositA.this.display.setVariable("GET_SERVICES.invtid", UsrDepositA.this.efLodnum.getText());
           			UsrDepositA.this.display.setVariable("GET_SERVICES.dstloc", UsrDepositA.this.efDsploc1.getText());
           			UsrDepositA.this.display.setVariable("GET_SERVICES.stoloc", UsrDepositA.this.efDsploc1.getText());
                    UsrDepositA.this.display.setVariable("GET_SERVICES.exitpnt_typ", "SERVICE-OUTBOUND");
                    UsrDepositA.this.display.setVariable("GET_SERVICES.exitpnt", "PRE-DEPOSIT");
                    newFrm = display.createFormLogic("GET_SERVICES", MtfConstants.EFlow.SHOW_FORM);
                    newFrm.run();
        			}
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







	
    
	

