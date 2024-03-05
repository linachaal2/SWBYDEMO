package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IInteractiveWidget;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.wmd.formlogic.AssetIdentify;

public class UsrAssetIdentify extends AssetIdentify {

	public UsrAssetIdentify(IDisplay _display) throws Exception {
		super(_display);
        
        frmMain.removeValidator(actAssetIdentify);
        frmMain.addWidgetAction(new UsrAssetIdentifyActions());
	}

	private class UsrAssetIdentifyActions extends CWidgetActionAdapter {
        
		public boolean onFormEntry(IForm _frm) throws Exception {
            
            return actAssetIdentify.onFormEntry(_frm);
		}

		public boolean onFormExit(IForm _frm) throws Exception {

            UsrAssetIdentify.this.cmdFkeyBack.setEnabled(true);
            if (UsrAssetIdentify.this.display.getVariable("ASSET_IDENTIFY.slotFlg") != null && UsrAssetIdentify.this.display.getVariable("ASSET_IDENTIFY.slotFlg").trim().length() > 0) {
                UsrAssetIdentify.this.display.setVariable("ASSET_IDENTIFY.slotFlg", "0");
            }

            if (UsrAssetIdentify.this.efPickToIdFlg.getText().equals("2")) {
                //UsrAssetIdentify.this.processPickToId();
                actPickToId.onFieldExit((IInteractiveWidget)efPickToId);
                return true;
            }
            
            return actAssetIdentify.onFormExit(_frm);
		}
	}
}
