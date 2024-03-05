package com.redprairie.les.formlogic;

import com.redprairie.moca.MocaException;
import com.redprairie.moca.NotFoundException;
import com.redprairie.moca.MocaResults;
import com.redprairie.mtf.MtfConstants;
import com.redprairie.mtf.exceptions.XFailedRequest;
import com.redprairie.mtf.exceptions.XFormAlreadyOnStack;
import com.redprairie.mtf.exceptions.XInvalidArg;
import com.redprairie.mtf.exceptions.XInvalidRequest;
import com.redprairie.mtf.exceptions.XInvalidState;
import com.redprairie.mtf.foundation.presentation.ACommand;
import com.redprairie.mtf.foundation.presentation.AFormLogic;
import com.redprairie.mtf.foundation.presentation.CVirtualKey;
import com.redprairie.mtf.foundation.presentation.CWidgetActionAdapter;
import com.redprairie.mtf.foundation.presentation.ICommand;
import com.redprairie.mtf.foundation.presentation.IContainer;
import com.redprairie.mtf.foundation.presentation.IDisplay;
import com.redprairie.mtf.foundation.presentation.IEntryField;
import com.redprairie.mtf.foundation.presentation.IForm;
import com.redprairie.mtf.foundation.presentation.IFormSegment;
import com.redprairie.mtf.foundation.presentation.IInteractiveWidget;
import com.redprairie.mtf.foundation.presentation.IVirtualKey;
import com.redprairie.mtf.terminal.presentation.CForm;
import com.redprairie.wmd.WMDErrors;
import com.redprairie.wmd.mtfutil.CWmdMtfUtil;
import java.text.SimpleDateFormat;
import java.util.Date;
import org.apache.log4j.Logger;

public class UsrIdentifyLoad
        extends AFormLogic {

    /* Hidden fields */
    private IEntryField efPrevForm;
    private IEntryField efUsrId;
    private IEntryField efDevcod;
    private IEntryField efWhId;

    private IEntryField efInvtypAdjFlg;

    /* Visible fields */
 /* 1. Verplichting om locatie te scannen waar registratie plaatsvindt */
    public IEntryField efDstLoc;
    /* Ingegeven waarde. */
    public IEntryField efScanId;
    /* Laatst ingegeven waarde. */
    public IEntryField efLastScanId;
    /* stroomtype (Connect/Klok/Fulfilment) */
    public IEntryField efInvTyp;
    /* ladingdragertype (omschrijving) */
    public IEntryField efLodTyp;
    /* # fust */
    public IEntryField efSumUntQty;
    /* # partijen */
    public IEntryField efNoLotNum;
    /* #losse legborden */
    public IEntryField efNoAsset;
    /* Aanvullende diensten */
    public IEntryField efAddServ;
    /* Fout code */
    public IEntryField efHldNum;

    /* Other variables */
    public CWmdMtfUtil wmdMtf;
    private static final Logger log = Logger.getLogger(UsrIdentifyLoad.class);

    public IFormSegment segDef;

    public static final String FORM_ID = "USR_IDENTIFY_LOAD";
    private static final String FORM_TITLE = "ttlUsrIdentifyLoad";

    public static final IVirtualKey VK_FKEY_GENERATE_DUMMY_LOAD = CVirtualKey.VK_F3;
    public static final String VK_FKEY_GENERATE_DUMMY_LOAD_CAPTION = "cmdGenerateDummyLoad";

    public static final IVirtualKey VK_FKEY_ADJ_DTL = CVirtualKey.VK_F4;
    public static final String VK_FKEY_ADJ_DTL_CAPTION = "cmdAdjDtl";
    public static final String VK_FKEY_ADJ_DTL_OPT_TYP = "O";
    public static final String VK_FKEY_ADJ_DTL_OPT_NAM = "mtfoptUsrLoadIdentifyAdjDtl";
    
    public static final IVirtualKey VK_FKEY_ADJ_LOD = CVirtualKey.VK_F5;
    public static final String VK_FKEY_ADJ_LOD_CAPTION = "cmdAdjLod";
    public static final String VK_FKEY_ADJ_LOD_OPT_TYP = "O";
    public static final String VK_FKEY_ADJ_LOD_OPT_NAM = "mtfoptUsrLoadIdentifyAdjLod";
    
    public static final IVirtualKey VK_FKEY_RELABEL = CVirtualKey.VK_F6;
    public static final String VK_FKEY_RELABEL_CAPTION = "cmdRelabel";
    public static final String VK_FKEY_RELABEL_OPT_TYP = "O";
    public static final String VK_FKEY_RELABEL_OPT_NAM = "mtfoptUsrLoadIdentifyRelabel";
    
    public static final IVirtualKey VK_FKEY_TRAIN = CVirtualKey.VK_F7;
    public static final String VK_FKEY_TRAIN_CAPTION = "cmdTrain";

    public static final IVirtualKey VK_FKEY_EXCEPTION = CVirtualKey.VK_F8;
    public static final String VK_FKEY_EXCEPTION_CAPTION = "cmdException";
    public static final String VK_FKEY_EXCEPTION_OPT_TYP = "O";
    public static final String VK_FKEY_EXCEPTION_OPT_NAM = "mtfoptUsrLoadIdentifyEx";

    public static final IVirtualKey VK_FKEY_TOOLS = CVirtualKey.VK_F9;
    public static final String VK_FKEY_TOOLS_CAPTION = "cmdTools";
    
    //RLS
  	public static final IVirtualKey VK_FKEY_HGH_LOD = CVirtualKey.VK_F12;
    public static final String VK_FKEY_HGH_LOD_CAPTION = "cmdAdjLod";
    public static final String VK_FKEY_HGH_LOD_OPT_TYP = "O";
    public static final String VK_FKEY_HGH_LOD_OPT_NAM = "mtfoptUsrLoadIdentifyAdjLod";
    
    /* F1, Previous form. */
    public ICommand cmdFkeyBack;
    // F3, Generate Dummy Load Id
    public ICommand cmdFkeyGenerateDummyLoad;
    // F4, Adjust Detail
    public ICommand cmdFkeyAdjDtl;
    // F5, Adjust Load
    public ICommand cmdFkeyAdjLod;
    // F6, Relabel
    public ICommand cmdFkeyRelabel;
    // F8, Exception
    public ICommand cmdFkeyException;
    // F9, Train
    public ICommand cmdFkeyTrain;
	// F12, Highloaded  //RLS
	public ICommand cmdFkeyHighLoad;
    /*
    public enum FormStatus {
        ENTER(10),
        START(20),
        DSTLOC_SCANNED(30),
        EXCEPTION_REGISTERED(35),
        INITIAL_SCANNED(40),
        ADD_SCANNED(50),
        FINISH_SCANNED(60),
        FINISH(70);

        private final int sequence;

        FormStatus(int sequence) {
            this.sequence = sequence;
        }

        public int sequence() {
            return sequence;
        }

        public boolean equalsOrPassedStatus(FormStatus compareStatus) {
            return this.sequence() >= compareStatus.sequence();
        }

        public boolean equalsOrBeforeStatus(FormStatus compareStatus) {
            return this.sequence() <= compareStatus.sequence();
        }
    }

    private FormStatus formStatus = FormStatus.START;
    
    private String finishShowMessage = null;
    private String finishShowError = null;
     */
    public UsrIdentifyLoad(IDisplay _display) throws Exception {
        super(_display);

        wmdMtf = (CWmdMtfUtil) this.session.getGlobalObjMap().get("WMDMTF");

        /* Form */
        frmMain = this.display.createForm(this.FORM_ID);
        frmMain.setTitle(FORM_TITLE);
        frmMain.addWidgetAction(new UsrIdentifyLoadActions());

        segDef = frmMain.createSegment("segDef", false);

        /* Hidden fields. */
        efPrevForm = segDef.createEntryField("prev_form");
        efPrevForm.setVisible(false);

        efUsrId = segDef.createEntryField("usr_id");
        efUsrId.setVisible(false);

        efDevcod = segDef.createEntryField("devcod");
        efDevcod.setVisible(false);

        efWhId = segDef.createEntryField("wh_id");
        efWhId.setVisible(false);

        efInvtypAdjFlg = segDef.createEntryField("invtyp_adj_flg");
        efInvtypAdjFlg.setVisible(false);

        /* Visible fields */
        efScanId = segDef.createEntryField("scan_id", "lbl_scan_id");
        efScanId.setFieldRightJust(true);
        efScanId.setVisible(true);
        efScanId.setEnabled(true);
        efScanId.setEntryRequired(true);
        efScanId.addWidgetAction(new ScanIdActions());

        efDstLoc = segDef.createEntryField("dstloc", "lbl_dstloc");
        efDstLoc.setVisible(true);
        efDstLoc.setEnabled(false);
        //efDstLoc.addWidgetAction(new DstLocActions());

        efLastScanId = segDef.createEntryField("last_scan_id", "lbl_last_scan_id");
        efLastScanId.setVisible(true);
        efLastScanId.setEnabled(false);

        efInvTyp = segDef.createEntryField("invtyp", "lbl_invtyp");
        efInvTyp.setVisible(true);
        efInvTyp.setEnabled(false);

        efLodTyp = segDef.createEntryField("lodtyp", "lbl_lodtyp");
        efLodTyp.setVisible(true);
        efLodTyp.setEnabled(false);

        efSumUntQty = segDef.createEntryField("sum_untqty", "lbl_sum_untqty");
        efSumUntQty.setVisible(true);
        efSumUntQty.setEnabled(false);

        efNoLotNum = segDef.createEntryField("no_lotnum", "lbl_no_lotnum");
        efNoLotNum.setVisible(true);
        efNoLotNum.setEnabled(false);

        efNoAsset = segDef.createEntryField("no_asset", "lbl_no_asset");
        efNoAsset.setVisible(true);
        efNoAsset.setEnabled(false);

        efAddServ = segDef.createEntryField("add_serv", "lbl_add_serv");
        efAddServ.setVisible(true);
        efAddServ.setEnabled(false);

        efHldNum = segDef.createEntryField("hldnum");
        efHldNum.setVisible(true);
        efHldNum.setEnabled(false);

        efWhId.setText(display.getVariable("global.wh_id"));
        efUsrId.setText(display.getVariable("global.usr_id"));
        efDevcod.setText(display.getVariable("global.devcod"));

        // F1 
        frmMain.unbind(frmMain.getCancelCommand());
        cmdFkeyBack = new FkeyBackCommand();
        cmdFkeyBack.setVisible(false);
        frmMain.bind(cmdFkeyBack);
        cmdFkeyBack.bind(MtfConstants.VK_FKEY_BACK);


        // F3, Generate Dummy Load Id
        frmMain.unbind(frmMain.getNextNumberCommand());
        cmdFkeyGenerateDummyLoad = new FkeyGenerateDummyLoadCommand();
        cmdFkeyGenerateDummyLoad.setVisible(false);
        frmMain.bind(cmdFkeyGenerateDummyLoad);
        cmdFkeyGenerateDummyLoad.bind(VK_FKEY_GENERATE_DUMMY_LOAD);

        // F4, Adjust Detail
        cmdFkeyAdjDtl = new FkeyAdjDtlCommand();
        cmdFkeyAdjDtl.setVisible(false);
        frmMain.bind(cmdFkeyAdjDtl);
        cmdFkeyAdjDtl.bind(VK_FKEY_ADJ_DTL);

        // F5, Adjust Load
        cmdFkeyAdjLod = new FkeyAdjLodCommand();
        cmdFkeyAdjLod.setVisible(false);
        frmMain.bind(cmdFkeyAdjLod);
        cmdFkeyAdjLod.bind(VK_FKEY_ADJ_LOD);

        // F6, Relabel
        cmdFkeyRelabel = new FkeyRelabelCommand();
        cmdFkeyRelabel.setVisible(false);
        frmMain.bind(cmdFkeyRelabel);
        cmdFkeyRelabel.bind(VK_FKEY_RELABEL);

        // F7, Sleep afsluiten
        cmdFkeyTrain = new FkeyTrainCommand();
        cmdFkeyTrain.setVisible(false);
        frmMain.bind(cmdFkeyTrain);
        cmdFkeyTrain.bind(VK_FKEY_TRAIN);

        // F8, Exception
        cmdFkeyException = new FkeyExceptionCommand();
        cmdFkeyException.setVisible(false);
        frmMain.bind(cmdFkeyException);
        cmdFkeyException.bind(VK_FKEY_EXCEPTION);

        // F9, Tools
        frmMain.unbind(frmMain.getToolsCommand());
        for (IVirtualKey vk : frmMain.getToolsCommand().getVirtualKeys()) {
            frmMain.getToolsCommand().unbind(vk);
        }
        frmMain.getToolsCommand().setVisible(false);
        frmMain.bind(frmMain.getToolsCommand());
        frmMain.getToolsCommand().bind(VK_FKEY_TOOLS);
        
		// F12, Higloaded
        cmdFkeyHighLoad = new cmdFkeyHighLoad();
        cmdFkeyHighLoad.setVisible(false);
        frmMain.bind(cmdFkeyHighLoad);
        cmdFkeyHighLoad.bind(VK_FKEY_HGH_LOD);
    }

    public void run() throws XInvalidState, XInvalidRequest, XInvalidArg, XFailedRequest, XFormAlreadyOnStack {
        this.frmMain.interact();
    }

    private void resetForm() throws MocaException {
        resetForm(false);
    }

    private void resetForm(boolean clearDeviceContext) throws MocaException {
        if (clearDeviceContext) {
            MocaResults rsClearDeviceContext = session.executeCommand(String.format(
                    "clear usr rf device context "
                    + " where devcod = '%s' "
                    + " and clear_type = 'all' ",
                    efDevcod.getText()
            ));
        }

        efScanId.setEnabled(true);
        efScanId.clear();
        efScanId.setFocus();
        efDstLoc.clear();
        efLastScanId.clear();

        /* Clear the summary fields. */
        efInvTyp.clear();
        efLodTyp.clear();
        efSumUntQty.clear();
        efNoLotNum.clear();
        efNoAsset.clear();
        efAddServ.clear();
        efHldNum.clear();
    }

    /*
    private void updateFormLayout() {
        switch (formStatus) {
            case ENTER:
                efScanId.setEnabled(true);
                efScanId.clear();
                efScanId.setFocus();
                efDstLoc.clear();

                // Clear the summary fields.
                efInvTyp.clear();
                efLodTyp.clear();
                efSumUntQty.clear();
                efNoLotNum.clear();
                efNoAsset.clear();
                efAddServ.clear();
                efHldNum.clear();
                break;
            case START:
                efScanId.setEnabled(true);
                efScanId.clear();
                efScanId.setFocus();
                //efDstLoc.clear();

                // Clear the summary fields.
                efInvTyp.clear();
                efLodTyp.clear();
                efSumUntQty.clear();
                efNoLotNum.clear();
                efNoAsset.clear();
                efAddServ.clear();
                efHldNum.clear();
                break;
            case DSTLOC_SCANNED:
                efScanId.setEnabled(true);
                efScanId.clear();

                // Clear the summary fields. 
                efInvTyp.clear();
                efLodTyp.clear();
                efSumUntQty.clear();
                efNoLotNum.clear();
                efNoAsset.clear();
                efAddServ.clear();
                efHldNum.clear();
                break;
            case EXCEPTION_REGISTERED:
                efScanId.setEnabled(true);
                efScanId.clear();
                break;
            case INITIAL_SCANNED:
                //frmMain.displayMessage(session.getMlsCatalogEntry(FORM_ID, MSG_INITIAL_SCAN, 0));
                //efDstLoc.setEnabled(false);
                efScanId.setEnabled(true);
                efScanId.clear();
                break;
            case ADD_SCANNED:
                //frmMain.displayMessage(session.getMlsCatalogEntry(FORM_ID, MSG_ADD_SCAN, 0));
                //efDstLoc.setEnabled(false);
                efScanId.setEnabled(true);
                efScanId.clear();
                break;
            case FINISH_SCANNED:
                //frmMain.displayMessage(session.getMlsCatalogEntry(FORM_ID, MSG_FINISH_SCAN, 0));
                break;
            case FINISH:
                efScanId.clear();
                //efDstLoc.clear();                
                break;
            default:
                break;
        }
    }
     */
    private void updateFormInformation() {
    	int retErrorCode = WMDErrors.eOK;
        try {
            MocaResults rsListSrcIdInformation = session.executeCommand(String.format(
                    "list usr rf identify load summary information "
                    + " where devcod = '%s' ",
                    efDevcod.getText()
            ));

            if (rsListSrcIdInformation.next()) {
                /* Columns needed by the RF screen for display. */
                efInvTyp.setText(rsListSrcIdInformation.getString("invtyp"));
                efLodTyp.setText(rsListSrcIdInformation.getString("lodtyp"));
                efSumUntQty.setText(rsListSrcIdInformation.getString("sum_untqty"));
                efNoLotNum.setText(rsListSrcIdInformation.getString("no_lotnum"));
                efNoAsset.setText(rsListSrcIdInformation.getString("no_asset"));
                efAddServ.setText(rsListSrcIdInformation.getString("add_serv"));
                efHldNum.setText(rsListSrcIdInformation.getString("hldnum"));
            }

            frmMain.setRefreshRequired(true);
            frmMain.refresh();
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
    				/* If we get an exception, show the error and make the user enter another value.To be changed */
    				display.beep();
    				frmMain.promptMessageAnyKey(e.getMessage());
    			}
    		}
        }
    }

    private boolean processScanId(String scanId) throws Exception {
        return processScanId(scanId, false);
    }

    private boolean processScanId(String scanId, boolean manualScan) throws Exception {
        boolean retStatus = false;
        boolean reloadData = false;
        String haveConfirmation = null;
        String openRfFrm = null;

        do {
            /* Show the user we are working on it (processing). */
            frmMain.displayMessage(MtfConstants.RF_MSG_PROCESSING);

            /* Validate and process the scan ID. */
            MocaResults rsProcessScanId = session.executeCommand(String.format(
                    "process usr rf identify load scan_id "
                    + " where devcod = '%s' "
                    + "   and scan_id = '%s' "
                    + "   and manual_scan = %s "
                    + "   and have_confirmation = '%s' ",
                    efDevcod.getText(),
                    scanId,
                    (manualScan ? "1" : "0"),
                    (haveConfirmation != null ? haveConfirmation : "")
            ));

            //Reset the confirmation value/flag
            haveConfirmation = null;

            frmMain.resetMessageLine();

            if (rsProcessScanId.next()) {
                if (rsProcessScanId.getString("identifier_dsp") != null) {
                    efLastScanId.setText(rsProcessScanId.getString("identifier_dsp"));
                    frmMain.setRefreshRequired(true);
                    frmMain.refresh();
                }

                // Handle the actions which were returned by the logic map. Most are actually handled in the process scan id command.
                if (rsProcessScanId.getString("use_location").equals("1")) {
                    //formStatus = FormStatus.DSTLOC_SCANNED;
                }
                if (rsProcessScanId.getString("start_scan").equals("1")) {
                    //Do some logic for an initial scan here.
                    ;
                }
                if (rsProcessScanId.getString("add_scan").equals("1")) {
                    //formStatus = FormStatus.ADD_SCANNED;
                    reloadData = true;
                }
                if (rsProcessScanId.getString("finish_scan").equals("1")) {
                    //formStatus = FormStatus.FINISH_SCANNED;
                    //formStatus = FormStatus.FINISH;

                    reloadData = true;
                    // Set the return status to leave the form.
                    retStatus = true;
                }
                if (rsProcessScanId.getString("show_error") != null) {
                    display.beep();
                    if (rsProcessScanId.getString("show_parms") != null && !rsProcessScanId.getString("show_parms").isEmpty()) {
                        frmMain.promptMessageWParms(rsProcessScanId.getString("show_error"), rsProcessScanId.getString("show_parms"));
                    } else {
                        frmMain.promptMessageAnyKey(rsProcessScanId.getString("show_error"));
                    }
                }
                if (rsProcessScanId.getString("show_message") != null) {
                    if (rsProcessScanId.getString("show_parms") != null && !rsProcessScanId.getString("show_parms").isEmpty()) {
                        String mlsTextWParms = this.getMlsTextWParms(rsProcessScanId.getString("show_message"), rsProcessScanId.getString("show_parms"));
                        frmMain.displayMessage(mlsTextWParms);
                    } else {
                        frmMain.displayMessage(rsProcessScanId.getString("show_message"));
                    }
                }
                if (rsProcessScanId.getString("show_confirmation") != null) {
                    //frmMain.promptMessageYN(rsProcessScanId.getString("show_confirmation"));
                    //frmMain.promptMessageYNWParms(rsProcessScanId.getString("show_confirmation"), rsProcessScanId.getString("show_parms"));
                    String showConfirmation = rsProcessScanId.getString("show_confirmation");
                    String showConfirmationText, showConfirmationTextTranslated, showConfirmationOptions;
                    int indexOfOptionsBegin = showConfirmation.indexOf("[");
                    int indexOfOptionsEnd = showConfirmation.indexOf("]");
                    if (indexOfOptionsBegin >= 0 && indexOfOptionsEnd >= 0) {
                        showConfirmationText = showConfirmation.substring(0, indexOfOptionsBegin);
                        showConfirmationOptions = showConfirmation.substring(indexOfOptionsBegin + 1, indexOfOptionsEnd);
                    } else {
                        showConfirmationText = showConfirmation;
                        showConfirmationOptions = "Y|N";
                    }

                    if (rsProcessScanId.getString("show_parms") != null && !rsProcessScanId.getString("show_parms").isEmpty()) {
                        showConfirmationTextTranslated = this.getMlsTextWParms(showConfirmationText, rsProcessScanId.getString("show_parms"));
                    } else {
                        showConfirmationTextTranslated = showConfirmationText;
                    }

                    String respConfirmation = frmMain.promptMessage(showConfirmationTextTranslated, showConfirmationOptions);
                    haveConfirmation = showConfirmationText + "=" + respConfirmation;
                    // Check if we already had another confirmation, then we append it to make a comma separated list of confirmations.
                    if (rsProcessScanId.getString("i_have_confirmation") != null) {
                        haveConfirmation = rsProcessScanId.getString("i_have_confirmation") + "," + haveConfirmation;
                    }
                }
                if (rsProcessScanId.getString("open_rf_frm") != null) {
                    openRfFrm = rsProcessScanId.getString("open_rf_frm");
                    AFormLogic newFrm = display.createFormLogic(openRfFrm, MtfConstants.EFlow.SHOW_FORM);
                    if (rsProcessScanId.getString("open_rf_frm_parms_cmd") != null) {
                        MocaResults rsOpenRfFrmParms = session.executeCommand(frmMain.preProcessCommandString(rsProcessScanId.getString("open_rf_frm_parms_cmd").replaceAll("@", "&&")).replaceAll("&&", "@"));
                        //newFrm.applyDynVarConfig(rsOpenRfFrmParms);
                        ((CForm) newFrm.getForm()).applyDynVarConfig(rsOpenRfFrmParms);
                        //if (rsOpenRfFrmParms.next()) {
                        //    for (int c = 0; c < rsOpenRfFrmParms.getColumnCount(); c++) {
                        //        display.setVariable(openRfFrm + "." + rsOpenRfFrmParms.getColumnName(c), rsOpenRfFrmParms.getString(c));
                        //    }
                        //}
                    }
                    newFrm.run();
                }

                /* Show any of the device status values. */
                efDstLoc.setText(rsProcessScanId.getString("dc_stoloc"));

            }
        } while (haveConfirmation != null);

        efScanId.clear();
        //updateFormLayout();

        // Only if we scanned and added a new load do we need to refresh the summary information.
        //if (reloadData) {
        updateFormInformation();
        //}

        frmMain.setRefreshRequired(true);
        frmMain.refresh();

        // Trigger a post event if needed. Do it after the refresh so the user can see the latest information.
        if (UsrIdentifyLoadEx.FORM_ID.equals(openRfFrm)) {
            processScanId(UsrIdentifyLoadEx.FORM_ID + "-POST");
        }

        return false;
    }

    public String getMlsTextWParms(String mlsId, String parms) {
        String mlsText = session.getMlsCatalogEntry(mlsId);

        if (parms != null) {
            String[] arrParms = parms.split("[|]");
            for (String parm : arrParms) {
                String[] arrNameValue = parm.split("[=]");
                mlsText = mlsText.replaceAll("\\^" + arrNameValue[0] + "\\^", arrNameValue[1]);
            }
        }

        return mlsText;
    }

    public boolean hasPrivileges(String optionType, String optionName) throws Exception {
        boolean hasPrivs = false;
        int retErrorCode = WMDErrors.eOK;
    	try {
            MocaResults rsUserPrivileges = session.executeCommand(String.format(
                    "get user privileges "
                    + " where usr_id = '%s' "
                    + "   and opt_typ = '%s' "
                    + "   and opt_nam = '%s' ",
                    efUsrId.getText(),
                    optionType,
                    optionName
            ));

            hasPrivs = true;
        } catch (NotFoundException e) {retErrorCode = e.getErrorCode();
        	if (retErrorCode == 523) {frmMain.formBack();}
        	else if (retErrorCode != WMDErrors.eOK) {hasPrivs = false;}
        }
    	return hasPrivs;
    }
    
    private class UsrIdentifyLoadActions
            extends CWidgetActionAdapter {

        public boolean onFormEntry(IForm _frm) throws Exception {
            boolean retStatus = false;
            int retErrorCode = WMDErrors.eOK;
            try {
                /* When we come from the main menu we want to clear everything and start new. */
                if (display.getVariable("INIT_POLICIES.prvfrm").equals("UNDIR_MENU")) {
                    resetForm(true);
                }
                /*
                // Only reinitialize the form when the status is ENTER.
                if (formStatus.equals(FormStatus.ENTER)) {

                    updateFormLayout();

                    formStatus = FormStatus.START;
                } else {
                    updateFormInformation();
                }
                 */
                display.setVariable("INIT_POLICIES.prvfrm", FORM_ID);

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
            			display.beep();
            			frmMain.promptMessageAnyKey(e.getMessage());
            			retStatus = false;
                    }
            	}
            }
            return retStatus;
        }

        public boolean onFormExit(IForm _frm) throws Exception {
            boolean retStatus = false;
            /*
            try {
                // Reopen the current form to clear everything needed and start fresh.
                display.setVariable("INIT_POLICIES.prvfrm", FORM_ID);
                AFormLogic newFrm = display.createFormLogic(FORM_ID);
                newFrm.run();
            } catch (MocaException e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
            }
             */
            return retStatus;
        }
    }

    private class ScanIdActions extends CWidgetActionAdapter {

        public boolean onFieldEntry(IInteractiveWidget _ef) throws Exception {
            return true;
        }

        public boolean onFieldExit(IInteractiveWidget _ef) throws Exception {
            boolean retStatus = false;
            int retErrorCode = WMDErrors.eOK;
            try {
                retStatus = processScanId(efScanId.getText(), true);
                // Only continue if the user finished, otherwise just stay in the scan field and ask for another scan.
                //retStatus = (formStatus == FormStatus.FINISH);
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
        			display.beep();
        			frmMain.promptMessageAnyKey(e.getMessage());
					frmMain.formBack();
        			retStatus = false;
                }
        	}
        }

            return retStatus;
        }
    }

    private class FkeyBackCommand extends ACommand {

    	   private static final long serialVersionUID = 0L;
  
		public FkeyBackCommand() {
         
			super("cmdFkeyBack", "FkeyBack", MtfConstants.FKEY_BACK_CAPTION, '1');	
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack,XFailedRequest {
            int retErrorCode = WMDErrors.eOK;

        	try
            {
        	resetForm(true);

            
            //AFormLogic newFrm = display.createFormLogic(frmMain.getDisplay().getPreviousFormOnStack().getIdentifier());
            //newFrm.run();
            } catch (MocaException e) {retErrorCode = e.getErrorCode();
            	if(retErrorCode != WMDErrors.eDB_NO_ROWS_AFFECTED) {
            	               
            		display.beep();
            		frmMain.promptMessageAnyKey(e.getMessage());
            	}
            }
			frmMain.formBack();
            
        }
    }

    private class FkeyGenerateDummyLoadCommand extends ACommand {
 	   
    	private static final long serialVersionUID = 0L;
		
    	public FkeyGenerateDummyLoadCommand() {
            super("cmdGenerateDummyLoad", "FkeyGenerateDummyLoad", VK_FKEY_GENERATE_DUMMY_LOAD_CAPTION, '3');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            try {
                String dummyLodnum = wmdMtf.generateNextNumber(frmMain.getDisplay().getSession(), "lodnum");
                dummyLodnum = dummyLodnum.replace("L", "L" + (new SimpleDateFormat("MMdd")).format(new Date()));
                efScanId.setText(dummyLodnum);
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
            	
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
                return;
            }
           
        }
    }
   

    private class FkeyAdjDtlCommand extends ACommand {
 	   
    	private static final long serialVersionUID = 0L;
        public FkeyAdjDtlCommand() {
            super("cmdFkeyAdjDtl", "FkeyAdjDtl", VK_FKEY_ADJ_DTL_CAPTION, '4');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            try {
                if(hasPrivileges(VK_FKEY_ADJ_DTL_OPT_TYP, VK_FKEY_ADJ_DTL_OPT_NAM)) {
                	processScanId("^F4");
                }else {
                	processScanId("^F4-NOPRIVS");
                }
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
                return;
            }
        }
    }

    private class FkeyAdjLodCommand extends ACommand {

 	    private static final long serialVersionUID = 0L;
        public FkeyAdjLodCommand() {
            super("cmdFkeyAdjLod", "FkeyAdjLod", VK_FKEY_ADJ_LOD_CAPTION, '5');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            try {
                if(hasPrivileges(VK_FKEY_ADJ_LOD_OPT_TYP, VK_FKEY_ADJ_LOD_OPT_NAM)) {
                	processScanId("^F5");
                }else {
                	processScanId("^F5-NOPRIVS");
                }
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
                return;
            }

        }
    }

    private class FkeyRelabelCommand extends ACommand {
    	
 	    private static final long serialVersionUID = 0L;
        public FkeyRelabelCommand() {
            super("cmdFkeyRelabel", "FkeyRelabel", VK_FKEY_RELABEL_CAPTION, '6');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            try {
                if(hasPrivileges(VK_FKEY_RELABEL_OPT_TYP, VK_FKEY_RELABEL_OPT_NAM)) {
                	processScanId("^F6");
                }else {
                	processScanId("^F6-NOPRIVS");
                }
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
                return;
            }
        }
    }

    private class FkeyTrainCommand extends ACommand {

 	    private static final long serialVersionUID = 0L;
        public FkeyTrainCommand() {
            super("cmdFkeyTrain", "FkeyTrain", VK_FKEY_TRAIN_CAPTION, '9');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            try {
                processScanId("^F7");
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
                return;
            }
        }
    }
    
    private class FkeyExceptionCommand extends ACommand {

 	    private static final long serialVersionUID = 0L;
        public FkeyExceptionCommand() {
            super("cmdFkeyException", "FkeyException", VK_FKEY_EXCEPTION_CAPTION, '8');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            try {
                if(hasPrivileges(VK_FKEY_EXCEPTION_OPT_TYP, VK_FKEY_EXCEPTION_OPT_NAM)) {
                	processScanId("^F8");
                }else {
                	processScanId("^F8-NOPRIVS");
                }
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
                return;
            }
        }
    }
    
    private class cmdFkeyHighLoad extends ACommand {

 	    private static final long serialVersionUID = 0L;
        public cmdFkeyHighLoad() {
            super("cmdFkeyHighLoad", "FkeyHighLoad", VK_FKEY_HGH_LOD_CAPTION, '5');
        }

        public void execute(IContainer _container) throws MocaException, ClassNotFoundException, XFormAlreadyOnStack, XFailedRequest {
            try {
                
                if(hasPrivileges(VK_FKEY_HGH_LOD_OPT_TYP, VK_FKEY_HGH_LOD_OPT_NAM)) {
                	
						processScanId("^F12");               
                	 }else {
                     	processScanId("^F12-NOPRIVS");
                     }
            } catch (Exception e) {
                // If we get an exception, show the error and make the user enter another value.
                display.beep();
                frmMain.promptMessageAnyKey(e.getMessage());
                return;
            }
        }
    }

}
