package com.redprairie.les.formlogic;

import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.mtf.terminal.presentation.CForm;
import com.redprairie.mtf.terminal.presentation.CDisplay;
import com.redprairie.mtf.terminal.presentation.CKeyEvent;
import com.redprairie.mtf.foundation.presentation.CVirtualKey;
import com.redprairie.mtf.exceptions.XFailedRequest;
import com.redprairie.mtf.exceptions.XFormAlreadyOnStack;
import com.redprairie.mtf.exceptions.XInvalidArg;
import com.redprairie.mtf.exceptions.XInvalidRequest;
import com.redprairie.mtf.exceptions.XInvalidState;
import com.redprairie.mtf.exceptions.XMissingObject;


public class UsrForm extends CForm implements IForm {
    
    public UsrForm(String _strWidgetId, CDisplay _display) throws XInvalidArg, XInvalidRequest {
        super(_strWidgetId, _display);
    }
    
    public CKeyEvent getKeyEventWithoutPostPollingActions() throws XFormAlreadyOnStack {
        if (this.isInteractionComplete()) {
            return new CKeyEvent(CVirtualKey.VK_TIMEOUT);
        }
        else {
            return super.getKeyEventWithoutPostPollingActions();
        }
    }

    public CKeyEvent getKeyEvent() throws XFormAlreadyOnStack {
        if (this.isInteractionComplete()) {
            return new CKeyEvent(CVirtualKey.VK_TIMEOUT);
        }
        else {
            return super.getKeyEvent();
        }
    }

    public CKeyEvent getKeyEvent(boolean fForceToUpperCase) throws XFormAlreadyOnStack {
        if (this.isInteractionComplete()) {
            return new CKeyEvent(CVirtualKey.VK_TIMEOUT);
        }
        else {
            return super.getKeyEvent(fForceToUpperCase);
        }
    }
    
}