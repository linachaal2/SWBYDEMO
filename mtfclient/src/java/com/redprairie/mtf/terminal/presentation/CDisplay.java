/*
 * On request of Blue Yonder performance an overrule to avoid additional delays in the MTF handling,
 * subject is not part of stay current program
 */
package com.redprairie.mtf.terminal.presentation;

import com.redprairie.mtf.MtfInterruptedError;
import com.redprairie.mtf.contract.terminal.ITerminalDriver;
import com.redprairie.mtf.daemon.IDaemonExecutive;
import com.redprairie.mtf.daemon.SDaemonBootstrapper;
import com.redprairie.mtf.exceptions.XFailedRequest;
import com.redprairie.mtf.exceptions.XInvalidArg;
import com.redprairie.mtf.exceptions.XInvalidRequest;
import com.redprairie.mtf.exceptions.XInvalidState;
import com.redprairie.mtf.exceptions.XMissingObject;
import com.redprairie.mtf.foundation.concurrent.CWaitableBoolean;
import com.redprairie.mtf.foundation.presentation.ADisplay;
import com.redprairie.mtf.foundation.presentation.AFormLogic;
import com.redprairie.mtf.foundation.presentation.CVirtualKey;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.ICommand;
import com.redprairie.mtf.foundation.presentation.IEventDispatcher;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.mtf.foundation.presentation.IFormSegment;
import com.redprairie.mtf.foundation.presentation.IStaticText;
import com.redprairie.mtf.foundation.presentation.IVirtualKey;
import com.redprairie.mtf.foundation.presentation.IWidgetActionValidator;
import com.redprairie.mtf.foundation.presentation.IWidgetResourceProvider;
import com.redprairie.mtf.session.IFrameworkSession;
import com.redprairie.mtf.terminal.connection.CMtfTerminalConnection;
import com.redprairie.mtf.terminal.executive.CTerminalExecutive;
import com.redprairie.mtf.terminal.presentation.CEventDispatcher;
import com.redprairie.mtf.terminal.presentation.CForm;
import com.redprairie.les.formlogic.UsrForm;
import com.redprairie.mtf.terminal.util.CTerminalInputReader;
import java.text.MessageFormat;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class CDisplay
extends ADisplay {
    private boolean _beep = false;
    private boolean fDisplayDamaged;
    private int cchWidth;
    private int cchHeight;
    private int cchColumns;
    private CTerminalInputReader tirInputReader;
    private Map<String, AFormLogic> mapInstantiatedForms;
    private ReadWriteLock rwlckModel;
    private LinkedList<IForm> stkfrmFocusStack;
    private boolean fOpen;
    private Lock lckTerminal;
    private ITerminalDriver _termIO;
    private CMtfTerminalConnection _connection;
    private IWidgetResourceProvider wrpResourceProvider;
    private static final int CCH_MAX_COLUMN_WIDTH = 31;
    private static final Logger log = LogManager.getLogger(CDisplay.class);
    private static final long serialVersionUID = -2484332750341580494L;

    public CDisplay(CMtfTerminalConnection connection, String strAppName, String strAppDescription, IFrameworkSession fs) {
        if (fs != null) {
            this.setSession(fs);
        }
        if (strAppName == null || strAppName.length() == 0) {
            throw new XInvalidArg("Application name may not be null or empty");
        }
        this._connection = connection;
        this._termIO = this._connection.getITerminalDriver();
        if (this._termIO == null) {
            throw new XInvalidArg("Terminal may not be null");
        }
        this.lckTerminal = new ReentrantLock();
        this.fOpen = false;
        this.fDisplayDamaged = true;
        this.cchWidth = this._termIO.getColumns();
        this.cchHeight = this._termIO.getRows();
        this.setColumns(this.cchWidth / 31 + 1);
        this.tirInputReader = new CTerminalInputReader(this._connection, this.getSession());
        this.rwlckModel = new ReentrantReadWriteLock();
        this.stkfrmFocusStack = new LinkedList();
        this.mapInstantiatedForms = new HashMap<String, AFormLogic>();
        log.debug("Display created");
    }

    public CDisplay(CMtfTerminalConnection connection, IFrameworkSession fs) {
        this(connection, "Terminal", "A simple Terminal display", fs);
    }

    public CDisplay(CMtfTerminalConnection connection) {
        this(connection, "Terminal", "A simple Terminal display", null);
    }

    @Override
    public int getWidth() {
        return this.cchWidth;
    }

    public void setWidth(int _cchWidth) {
        this.cchWidth = _cchWidth;
    }

    @Override
    public int getHeight() {
        return this.cchHeight;
    }

    public void setHeight(int _cchHeight) {
        this.cchHeight = _cchHeight;
    }

    public int getColumns() {
        return this.cchColumns;
    }

    public void setColumns(int _cchColumns) {
        this.cchColumns = _cchColumns < 1 ? 1 : _cchColumns;
    }

    public int getColumnWidth() {
        return this.cchWidth / this.cchColumns;
    }

    @Override
    public void displayMessage(String _strMessageText) {
        this.displayMessage(_strMessageText, this.determineMessageType(_strMessageText), null);
    }

    @Override
    public void displayMessage(String _strMessageText, Object[] _aobjArgs) {
        this.displayMessage(_strMessageText, this.determineMessageType(_strMessageText), _aobjArgs);
    }

    @Override
    public /* varargs */ void displayMessage(String _strMessageId, int _nMessageType, Object ... _aobjArgs) {
        this.internalDisplayMessage(_strMessageId, _nMessageType, _aobjArgs, null);
    }

    public void displayMessageUntil(String _strMessageId, int _nMessageType, Object[] _aobjArgs, CWaitableBoolean _wbool) {
        this.internalDisplayMessage(_strMessageId, _nMessageType, _aobjArgs, _wbool);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void internalDisplayMessage(String _strMessageId, int _nMessageType, Object[] _aobjArgs, final CWaitableBoolean _wbool) {
        try {
            CForm frmMessage = (CForm)this.createForm("CDisplay.frmMessage");
            try {
                frmMessage.setPriority(CForm.EFormPriority.HIGH);
                switch (_nMessageType) {
                    case 2: {
                        frmMessage.setTitle("*Warning*");
                        break;
                    }
                    case 3: {
                        frmMessage.setTitle("*Error*");
                        break;
                    }
                    case 0: {
                        frmMessage.setTitle("*Working*");
                        break;
                    }
                    default: {
                        frmMessage.setTitle("");
                    }
                }
                frmMessage.getAcceptCommand().setDescription("Acknowledge the message");
                frmMessage.unbind(frmMessage.getCancelCommand());
                frmMessage.unbind(frmMessage.getHelpCommand());
                frmMessage.unbind(frmMessage.getLookupCommand());
                frmMessage.unbind(frmMessage.getNextNumberCommand());
                frmMessage.unbind(frmMessage.getShowKeysCommand());
                frmMessage.unbind(frmMessage.getToolsCommand());
                IFormSegment segMessage = frmMessage.createSegment("CDisplay.frmMessage.segMessage", false);
                IStaticText txtMessage = segMessage.createStaticText(this.getSession().getMlsCatalogEntry(_strMessageId));
                if (_aobjArgs != null) {
                    txtMessage.setText(MessageFormat.format(txtMessage.getText(), _aobjArgs));
                }
                if (_wbool != null) {
                    frmMessage.addWidgetAction(new CWidgetActionAdapter(){

                        @Override
                        public boolean onFormExit(IForm _frm) {
                            return !_wbool.get();
                        }
                    });
                }
                frmMessage.interact();
            }
            finally {
                frmMessage.release();
            }
        }
        catch (Exception ex) {
            log.warn("Failed to display message [" + _strMessageId + "]", (Throwable)ex);
        }
    }

    private int determineMessageType(String _strMessageId) {
        if (_strMessageId == null) {
            return 1;
        }
        int nMessageType = 1;
        try {
            String strMessageType = this.getWidgetResourceProvider().fetchString(this.getWidgetResourceProvider().normalizeWidgetId(_strMessageId), "type").toLowerCase();
            if (strMessageType.startsWith("inf")) {
                nMessageType = 1;
            } else if (strMessageType.startsWith("warn")) {
                nMessageType = 2;
            } else if (strMessageType.startsWith("err")) {
                nMessageType = 3;
            } else if (strMessageType.startsWith("busy") || strMessageType.startsWith("work")) {
                nMessageType = 0;
            }
        }
        catch (XMissingObject ex) {
            log.debug("Unable to determine message type from bundle: " + _strMessageId + ".text");
        }
        catch (Exception ex) {
            log.warn("Unable to determine message type of message [" + _strMessageId + "]", (Throwable)ex);
        }
        return nMessageType;
    }

    @Override
    public void beep() {
        CTerminalExecutive executive = null;
        try {
            executive = (CTerminalExecutive)SDaemonBootstrapper.getInstance().getExecutive("Terminal");
        }
        catch (XMissingObject e) {
            log.error("Failed to get reference to daemon executive thread [Terminal]", (Throwable)e);
            return;
        }
        if (executive.isBeepingEnabled()) {
            this.lockTerminal();
            this._beep = true;
            try {
                this.getTerminal().bell();
            }
            finally {
                this.unlockTerminal();
            }
        }
    }

    @Override
    public synchronized IWidgetResourceProvider getWidgetResourceProvider() {
        return this.wrpResourceProvider;
    }

    @Override
    public synchronized void open(IWidgetResourceProvider _wrpResourceProvider) throws XInvalidArg, XInvalidRequest, XFailedRequest {
        if (this.fOpen) {
            throw new XInvalidRequest("The display is already open");
        }
        if (_wrpResourceProvider == null) {
            throw new XInvalidArg("Widget resource provider may not be null");
        }
        this.fOpen = true;
        this.wrpResourceProvider = _wrpResourceProvider;
        this.tirInputReader.startup();
        log.info("Opened display");
    }

    @Override
    public synchronized void close() throws XInvalidRequest {
        if (!this.fOpen) {
            throw new XInvalidRequest("The display is not open");
        }
        this.tirInputReader.shutdown();
        this.tirInputReader.cleanup();
        this.tirInputReader = null;
        this.fOpen = false;
        this.wrpResourceProvider = null;
        log.info("Closed display");
    }

    @Override
    public synchronized boolean isOpen() {
        return this.fOpen;
    }

    public IEventDispatcher createEventDispatcher(IForm _frm) throws XInvalidArg, XInvalidState, XInvalidRequest, XFailedRequest {
        if (_frm == null) {
            throw new XInvalidArg("Form may not be null");
        }
        if (!(_frm instanceof CForm)) {
            throw new XInvalidRequest("Cannot create event dispatcher for non FormBlade forms");
        }
        if (!this.isOpen()) {
            throw new XInvalidState("Cannot create event dispatcher on closed display");
        }
        log.trace("Creating FormBlade event dispatcher");
        CEventDispatcher dispatcher = null;
        try {
            dispatcher = new CEventDispatcher((CForm)_frm);
            log.debug("Created FormBlade event dispatcher");
        }
        catch (Exception ex) {
            log.error("Failed to create event dispatcher due to exception: " + ex.toString(), (Throwable)ex);
            throw new XFailedRequest(ex, "Failed to create event dispatcher due to exception: " + ex.toString());
        }
        return dispatcher;
    }

    @Override
    public IForm createForm(String _strFormId) throws XFailedRequest {
        if (!this.isOpen()) {
            throw new XInvalidState("Cannot create form on closed display");
        }
        try {
            UsrForm frm;
            frm = new UsrForm(_strFormId, this);
            try {
                this.rwlckModel.writeLock().lock();
            }
            finally {
                this.rwlckModel.writeLock().unlock();
            }
            return frm;
        }
        catch (Exception ex) {
            log.error("Failed to create form [" + _strFormId + "]", (Throwable)ex);
            throw new XFailedRequest(ex, "Failed to create form [" + _strFormId + "]");
        }
    }

    @Override
    public void pushForm(IForm _frmGainingFocus) {
        if (!this.isOpen()) {
            throw new XInvalidState("Display is closed");
        }
        if (_frmGainingFocus == null) {
            throw new XInvalidArg("Form may not be null");
        }
        this.rwlckModel.writeLock().lock();
        try {
            this.stkfrmFocusStack.addFirst(_frmGainingFocus);
        }
        finally {
            this.rwlckModel.writeLock().unlock();
        }
        this.setDisplayDamaged(true);
    }

    @Override
    public void popForm(IForm _frmLosingFocus) {
        if (!this.isOpen()) {
            throw new XInvalidState("Display is closed");
        }
        if (_frmLosingFocus == null) {
            throw new XInvalidArg("Form may not be null");
        }
        this.rwlckModel.writeLock().lock();
        try {
            this.stkfrmFocusStack.remove(_frmLosingFocus);
        }
        finally {
            this.rwlckModel.writeLock().unlock();
        }
        this.setDisplayDamaged(true);
    }

    @Override
    public IForm getFormOnStack(String _frm) {
        if (this.isTerminalInputReaderAlive()) {
            return this.getTerminalInputReader().contains(_frm);
        }
        return null;
    }

    @Override
    public List<String> getFormStack() {
        if (this.isTerminalInputReaderAlive()) {
            return this.getTerminalInputReader().getFormStack();
        }
        return null;
    }

    @Override
    public IForm getPreviousFormOnStack() {
        if (this.isTerminalInputReaderAlive()) {
            return this.getTerminalInputReader().getPreviousForm();
        }
        return null;
    }

    @Override
    public IForm getCurrentFormOnStack() {
        if (this.isTerminalInputReaderAlive()) {
            return this.getTerminalInputReader().getTopForm();
        }
        return null;
    }

    @Override
    public IForm getFormWithFocus() {
        if (this.isTerminalInputReaderAlive()) {
            return this.getTerminalInputReader().getTopForm();
        }
        return null;
    }

    @Override
    public AFormLogic getInstantiatedForm(String _strFormId) {
        if (this.mapInstantiatedForms.containsKey(_strFormId)) {
            return this.mapInstantiatedForms.get(_strFormId);
        }
        return null;
    }

    @Override
    public Map<String, AFormLogic> getInstantiatedForms() {
        return this.mapInstantiatedForms;
    }

    @Override
    public void cleanFormsOnStack() {
        if (this.isTerminalInputReaderAlive()) {
            this.getTerminalInputReader().cleanup();
        }
    }

    @Override
    public void formReleased(IForm _frmReleased) {
        if (_frmReleased == null) {
            return;
        }
        try {
            this.rwlckModel.writeLock().lock();
            if (!this.stkfrmFocusStack.isEmpty()) {
                if (this.stkfrmFocusStack.getFirst() == _frmReleased) {
                    this.popForm(_frmReleased);
                } else {
                    this.stkfrmFocusStack.remove(_frmReleased);
                }
            }
        }
        catch (Throwable ex) {
            log.warn("Failed to process the form [" + _frmReleased.getIdentifier() + "] release from display", ex);
        }
        finally {
            this.rwlckModel.writeLock().unlock();
        }
    }

    public synchronized ITerminalDriver getTerminal() {
        return this._termIO;
    }

    @Override
    public synchronized CMtfTerminalConnection getConnection() {
        return this._connection;
    }

    public void lockTerminal() {
        try {
            this.lckTerminal.lockInterruptibly();
        }
        catch (InterruptedException e) {
            throw new MtfInterruptedError(e);
        }
    }

    public void unlockTerminal() {
        try {
            this.lckTerminal.unlock();
        }
        catch (IllegalMonitorStateException e) {
            log.error("Could not unlock the terminal due to illegal monitor on the object.");
        }
    }

    public synchronized void resetTerminal(CMtfTerminalConnection c) throws XFailedRequest, XInvalidRequest {
        this._connection = c;
        if (this.lckTerminal.tryLock()) {
            try {
                this._termIO = c.getITerminalDriver();
            }
            finally {
                this.unlockTerminal();
            }
        } else {
            log.warn("POSSIBLY UNSAFE:  Switching termIO outside of the lock");
            this._termIO = c.getITerminalDriver();
        }
        this.tirInputReader.shutdown();
        this.tirInputReader.setConnection(c);
        this.setDisplayDamaged(true);
        this.tirInputReader.startup();
    }

    public CTerminalInputReader getTerminalInputReader() {
        return this.tirInputReader;
    }

    private boolean isTerminalInputReaderAlive() {
        return this.getTerminalInputReader() != null;
    }

    public boolean isDisplayDamaged() {
        return this.fDisplayDamaged;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void setDisplayDamaged(boolean _fDamaged) {
        block8 : {
            if (this.lckTerminal.tryLock()) {
                try {
                    if (!_fDamaged || this.fDisplayDamaged) break block8;
                    CDisplay cDisplay = this;
                    synchronized (cDisplay) {
                        if (this._termIO != null) {
                            this._termIO.eraseScreen();
                            this._termIO.flush();
                        }
                    }
                }
                finally {
                    this.unlockTerminal();
                }
            }
        }
        this.fDisplayDamaged = _fDamaged;
    }

    @Override
    public IVirtualKey translatePhysicalToLogical(IVirtualKey _vkPhysical) {
        if (_vkPhysical == null) {
            log.trace("Translated null to " + CVirtualKey.VK_NONE.getVirtualKeyId());
            return CVirtualKey.VK_NONE;
        }
        IVirtualKey vkLogical = CVirtualKey.VK_NONE;
        if (_vkPhysical.getVirtualKeyId().equals("VKID_TIMEOUT")) {
            vkLogical = CVirtualKey.VK_TIMEOUT;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_ENTER")) {
            vkLogical = CVirtualKey.VK_EXIT_FORM;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_TAB")) {
            vkLogical = _vkPhysical.getStateModifierMask() == 1 ? CVirtualKey.VK_PREV_FIELD : CVirtualKey.VK_NEXT_FIELD;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_UP")) {
            vkLogical = CVirtualKey.VK_PREV_FIELD;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_DOWN")) {
            vkLogical = CVirtualKey.VK_NEXT_FIELD;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_LEFT")) {
            vkLogical = CVirtualKey.VK_PREV_CHAR;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_RIGHT")) {
            vkLogical = CVirtualKey.VK_NEXT_CHAR;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_HOME")) {
            vkLogical = CVirtualKey.VK_FIELD_START;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_END")) {
            vkLogical = CVirtualKey.VK_FIELD_END;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_PAGEUP")) {
            vkLogical = CVirtualKey.VK_PREV_PAGE;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_PAGEDOWN")) {
            vkLogical = CVirtualKey.VK_NEXT_PAGE;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F1")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F1;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F1;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F1;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F2")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F2;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F2;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F2;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F3")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F3;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F3;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F3;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F4")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F4;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F4;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F4;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F5")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F5;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F5;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F5;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F6")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F6;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F6;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F6;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F7")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F7;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F7;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F7;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F8")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F8;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F8;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F8;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F9")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F9;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F9;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F9;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_F10")) {
            switch (_vkPhysical.getStateModifierMask()) {
                case 0: {
                    vkLogical = CVirtualKey.VK_F10;
                    break;
                }
                case 1: {
                    vkLogical = CVirtualKey.VK_GOLD_F10;
                    break;
                }
                case 16: {
                    vkLogical = CVirtualKey.VK_SUPER_F10;
                    break;
                }
                default: {
                    break;
                }
            }
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_BS")) {
            vkLogical = CVirtualKey.VK_DELETE_PREV_CHAR;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_DEL")) {
            vkLogical = CVirtualKey.VK_DELETE_CURRENT_CHAR;
        } else if (_vkPhysical.getVirtualKeyId().equals("n") || _vkPhysical.getVirtualKeyId().equals("N")) {
            vkLogical = CVirtualKey.VK_CHAR_N;
        } else if (_vkPhysical.getVirtualKeyId().equals("y") || _vkPhysical.getVirtualKeyId().equals("Y")) {
            vkLogical = CVirtualKey.VK_CHAR_Y;
        } else if (_vkPhysical.getVirtualKeyId().equals("VKID_SPACE")) {
            vkLogical = CVirtualKey.VK_SPACE;
        }
        log.trace("Translated physical [" + _vkPhysical.getStateModifierMask() + ":" + _vkPhysical.getVirtualKeyId() + "] to logical [" + vkLogical.getStateModifierMask() + ":" + vkLogical.getVirtualKeyId() + "]");
        return vkLogical;
    }

    @Override
    public boolean getBeep() {
        return this._beep;
    }

    @Override
    public void setBeep(boolean beep) {
        this._beep = beep;
    }

}

