CREATE OR REPLACE FUNCTION "dbo"."IVRM_ModulesPagesMapping_Next"(
    p_SMI_Id bigint,
    p_MI_Id bigint,
    p_AppId bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_ARCount int;
    v_IMCCount int;
    v_IMRCount int;
    v_IMSCount int;
    v_IMCount int;
    v_IPCount int;
    v_ISMPCount int;
    v_IMGCount int;
    v_IMAPCount int;
    v_IRPCount int;
    v_IRTCount int;
    v_IIMCount int;
    v_IMNCount int;
    v_IMPMCount int;
    v_IMMPMICount int;
    v_IRMPCount int;
    v_IIRPCount int;
    v_IMALDCount int;
    v_IULPCount int;
    v_IMMICount int;
    v_IVRMMMI_Id bigint;
    v_CMI_Id bigint;
    v_IVRMMMI_MenuName text;
    v_IVRMM_Id bigint;
    v_IVRMMMI_ParentId bigint;
    v_IVRMMMI_PageNonPageFlag boolean;
    v_IVRMMMI_MenuOrder int;
    v_IVRMMM_Id bigint;
    v_CreatedDate timestamp;
    v_UpdatedDate timestamp;
    v_IVRMMMI_Icon text;
    v_IVRMMMI_Color text;
    v_PIVRMMMI_Id bigint;
    v_IVRMP_Id bigint;
    v_IVRMMMPMI_PageDisplayName text;
    v_MIVRMMMI_Id bigint;
    v_IVRMIM_Id bigint;
    v_IVRMIM_Flag int;
    v_IVRMIM_ModuleOrder int;
    v_IVRMIM_CDFlag text;
    v_IVRMIMP_Flag int;
    v_IVRMIMP_PageOrder int;
    v_IVRMIMP_Compulsory_Flag boolean;
    v_MIVRMIM_Id bigint;
    v_PIVRMIM_Id bigint;
    v_AYRcount int;
    v_SASMAY_Id bigint;
    v_ECCRcount bigint;
    v_CEMCA_Id int;
    v_CASMAY_Id bigint;
    v_CASMS_Id bigint;
    v_EMCA_CategoryName text;
    v_ASMCL_ClassName text;
    v_ASMC_SectionName text;
    v_ECAC_ActiveFlag boolean;
    v_ACCRCount int;
    v_AMC_Name text;
    v_CAMC_Id bigint;
    v_CASMCL_Id bigint;
    v_ACSectionRcount bigint;
    v_ASMCC_Id bigint;
    v_ASMS_Id bigint;
    v_roleid bigint;
    v_RoleTypeId bigint;
    v_ULRCount int;
    v_ULIRcount int;
    v_ISVRcount int;
    v_FMDRcount int;
    v_HMCORCount bigint;
    v_HTMLRCount bigint;
    v_MAACount bigint;
    v_DPMRcount bigint;
    v_SDPMRcount int;
    v_PDPMRcount int;
    v_CMERCount int;
    v_ECRcount bigint;
    v_EMERCount bigint;
    v_MSUBE int;
    v_MSubSubj int;
    v_SessionRcount int;
    v_MSRcount int;
    v_IMBRcount int;
    v_IMCCRcount int;
    v_IMCRcount int;
    v_IVSRcount bigint;
    v_School_Id bigint;
    v_Subdomain varchar(100);
    v_GenderRCount int;
    v_GovRcount int;
    v_IMMSRcount int;
    v_IMNRcount int;
    v_IMPRcount2 int;
    v_IOPRcount int;
    v_ISDRcount int;
    v_PMStatus bigint;
    v_ASCRCount int;
    v_ASMCRCount int;
    v_ASMSRCount int;
    v_AMCRcount int;
    v_PCRcount int;
    v_CAMCP_Id bigint;
    v_ISVRcount_temp int;
    v_FMDRcount_temp int;
    v_HMCORCount_temp bigint;
    v_HTMLRCount_temp bigint;
    v_MAACount_temp bigint;
    v_DPMRcount_temp bigint;
    v_SDPMRcount_temp int;
    v_PDPMRcount_temp int;
    v_CMERCount_temp int;
    v_ECRcount_temp bigint;
    v_EMERCount_temp bigint;
    v_MSUBE_temp int;
    v_MSubSubj_temp int;
    v_SessionRcount_temp int;
    v_MSRcount_temp int;
    v_IMBRcount_temp int;
    v_IMCCRcount_temp int;
    v_IMCRcount_temp int;
    v_IVSRcount_temp bigint;
    v_GenderRCount_temp int;
    v_GovRcount_temp int;
    v_IMMSRcount_temp int;
    v_IMNRcount_temp int;
    v_IMPRcount2_temp int;
    v_IOPRcount_temp int;
    v_ISDRcount_temp int;
    v_PMStatus_temp bigint;
    v_ASCRCount_temp int;
    v_ASMCRCount_temp int;
    v_ASMSRCount_temp int;
    v_AMCRcount_temp int;
    v_PCRcount_temp int;
    v_CEMGR_Id int;
    v_GMI_Id bigint;
    v_EMGR_GradeName text;
    v_EMGR_MarksPerFlag text;
    v_EMGR_ActiveFlag boolean;
    v_GDEMGR_Id int;
    v_EMGD_Name text;
    v_EMGD_From decimal(18,2);
    v_EMGD_To decimal(18,2);
    v_EMGD_Remarks text;
    v_EMGD_GradePoints decimal(18,2);
    v_EMGD_ActiveFlag boolean;
    v_NEMGR_Id int;
    v_CEMG_Id int;
    v_GSMI_Id bigint;
    v_EMG_GroupName text;
    v_EMG_TotSubjects int;
    v_EMG_MaxAplSubjects int;
    v_EMG_MinAplSubjects int;
    v_EMG_BestOff int;
    v_EMG_ElectiveFlg boolean;
    v_EMG_LangauageFlg boolean;
    v_EMG_ActiveFlag boolean;
    v_EMG_Id int;
    v_EMGS_ActiveFlag boolean;
    v_NEMG_Id int;
    v_NISMS_Id bigint;
    v_ISMS_SubjectName text;
    v_SGESG_Id int;
    v_SGMI_Id bigint;
    v_SGASMAY_Id bigint;
    v_ESG_SubjectGroupName text;
    v_ESG_ExamPromotionFlag text;
    v_ESG_CompulsoryFlag text;
    v_ESG_GroupMinMarks decimal(18,2);
    v_ESG_ActiveFlag boolean;
    v_ESG_GroupMaxMarks decimal(18,2);
    v_EESG_Id int;
    v_EME_ExamName text;
    v_EESGE_ActiveFlag boolean;
    v_NESG_Id int;
    v_NEME_Id int;
    v_ESGS_ActiveFlag boolean;
    v_EYC_Id int;
    v_MI_Id bigint;
    v_ASMAY_Id bigint;
    v_EYC_ActiveFlg boolean;
    v_EYC_ExamStartDate timestamp;
    v_EYC_ExamEndDate timestamp;
    v_EYC_MarksEntryLastDate timestamp;
    v_EYC_MarksProcessLastDate timestamp;
    v_EYC_MarksPublishDate timestamp;
    v_CEYC_Id int;
    v_EYCE_AttendanceFromDate timestamp;
    v_EYCE_AttendanceToDate timestamp;
    v_EYCE_SubExamFlg boolean;
    v_EYCE_SubSubjectFlg boolean;
    v_EYCE_ActiveFlg boolean;
    v_EYCE_PassToIndFlg boolean;
    v_EYCE_PassToOverallFlg boolean;
    v_EYCE_OverallPer decimal(18,2);
    v_EYCE_ExamStartDate timestamp;
    v_EYCE_ExamEndDate timestamp;
    v_EYCE_MarksEntryLastDate timestamp;
    v_EYCE_MarksProcessLastDate timestamp;
    v_EYCE_MarksPublishDate timestamp;
    v_EYCE_BestOfApplicableFlg boolean;
    v_EYCE_BestOf bigint;
    v_EyEYCG_Id int;
    v_EyEYC_Id int;
    v_EyEMG_GroupName text;
    v_EyEYCG_ActiveFlg boolean;
    v_SuEYCG_Id int;
    v_SuISMS_SubjectName text;
    v_SuEYCGS_ActiveFlg boolean;
    v_NEYC_Id int;
    v_NEYCG_Id int;
    v_EYCE_Id int;
    v_SEYCE_Id int;
    v_EYCES_MarksEntryMax decimal(18,2);
    v_EYCES_MaxMarks decimal(18,2);
    v_EYCES_MinMarks decimal(18,2);
    v_EYCES_SubExamFlg boolean;
    v_EYCES_SubSubjectFlg boolean;
    v_EYCES_MarksGradeEntryFlg boolean;
    v_EYCES_MarksDisplayFlg boolean;
    v_EYCES_GradeDisplayFlg boolean;
    v_EYCES_AplResultFlg boolean;
    v_EYCES_SubjectOrder int;
    v_EYCES_ActiveFlg boolean;
    v_NEYCE_Id int;
    v_EYCES_Id int;
    v_EMSE_SubExamName text;
    v_EYCESSE_MaxMarks decimal(18,2);
    v_EYCESSE_MinMarks decimal(18,2);
    v_EYCESSE_ExemptedFlg boolean;
    v_EYCESSE_ExemptedPer decimal(18,2);
    v_EYCESSE_SubExamOrder int;
    v_EYCESSE_ActiveFlg boolean;
    v_NEYCES_Id int;
    v_NEMSE_Id int;
    v_NEMSS_Id int;
    v_EMSS_SubSubjectName text;
    v_EYCESSS_MaxMarks decimal(18,2);
    v_EYCESSS_MinMarks decimal(18,2);
    v_EYCESSS_ExemptedFlg boolean;
    v_EYCESSS_ExemptedPer decimal(18,2);
    v_EYCESSS_SubSubjectOrder int;
    v_EYCESSS_ActiveFlg boolean;
    v_EXTT_Id int;
    v_TMI_Id bigint;
    v_TASMAY_Id bigint;
    v_TASMCL_ClassName text;
    v_TASMC_SectionName text;
    v_TEME_ExamName text;
    v_TEXTT_ActiveFlag boolean;
    v_TEXTT_FromDate timestamp;
    v_TEXTT_EndDate timestamp;
    v_TEMG_GroupName text;
    v_TSEXTT_Id int;
    v_EXTTS_Date timestamp;
    v_EXTTS_ExamDuration varchar(40);
    v_EXTTS_FromTime varchar(40);
    v_EXTTS_EndTime varchar(40);
    v_EXTTS_ActiveFlag boolean;
    v_ETTS_SessionName text;
    v_NEXTT_Id int;
    v_NETTS_Id int;
    v_NASMCL_Id bigint;
    v_NASMS_Id bigint;
    v_HRCRCount int;
    v_HDRCount int;
    v_HRDesRCount int;
    v_HRGTRCount int;
    v_HRGRCount int;
    v_HRETRCount int;
    v_HRMLYRCount int;
    v_HRPRcount int;
    v_HRMLRCount int;
    v_HRMEDRCount int;
    v_MLRRcount int;
    v_FSRcount int;
    v_FMRcount int;
    v_FMTRcount int;
    v_IRcount int;
    v_ITRcount int;
    v_MHRcount int;
    v_FMCCRcount int;
    v_GRcount int;
    v_GDRcount int;
    v_MGRcount int;
    v_GSRcount int;
    v_SGERcount int;
    v_SGERcount1 int;
    v_SGERcount2 int;
    v_EYCRcount int;
    v_ceRcount int;
    v_CESRcount int;
    v_EESERcount int;
    v_EESSRcount int;
    v_cgrcount int;
    v_cgsrcount int;
    v_ETTRcount int;
    v_TTSRcount int;
    v_MIVRMMMI_Id_rec RECORD;
    v_PIVRMMMI_Id_rec RECORD;
    v_Admcatnames_rec RECORD;
    v_AdmCatSections_rec RECORD;
    v_ClassCategory_rec RECORD;
    v_InstGrade_rec RECORD;
    v_GradeDetails_rec RECORD;
    v_MasterGroup_rec RECORD;
    v_groupsubjects_rec RECORD;
    v_SubGroup_rec RECORD;
    v_SubGrExms_rec RECORD;
    v_SubGrSubs_rec RECORD;
    v_EYCat_rec RECORD;
    v_catexams_rec RECORD;
    v_catexsub_rec RECORD;
    v_SubexamsList_rec RECORD;
    v_SubexamsSubSubjectList_rec RECORD;
    v_eygroup_rec RECORD;
    v_catgrsub_rec RECORD;
    v_ETTrecords_rec RECORD;
    v_ttsubjectwisedates_rec RECORD;
BEGIN

    v_AYRcount := 0;
    v_ARCount := 0;
    v_IMCCount := 0;
    v_IMRCount := 0;
    v_IMSCount := 0;
    v_IMCount := 0;
    v_IPCount := 0;
    v_ISMPCount := 0;
    v_IMGCount := 0;
    v_IMAPCount := 0;
    v_IMRCount := 0;
    v_IRPCount := 0;
    v_IRTCount := 0;
    v_IIMCount := 0;
    v_IMNCount := 0;
    v_IMPMCount := 0;
    v_IRMPCount := 0;
    v_IIRPCount := 0;
    v_IMALDCount := 0;
    v_IULPCount := 0;
    v_IMMICount := 0;

    v_ULRCount := 0;

    SELECT COUNT(*) INTO v_ULRCount FROM "IVRM_User_Login" WHERE "MI_Id" = p_MI_Id;
    
    IF v_ULRCount = 0 THEN
        INSERT INTO "IVRM_User_Login"("IVRMRT_Id","IVRMUL_UserName","IVRMUL_Password","IVRMUL_SecurityQns","IVRMUL_Answer","IVRMUL_ActiveFlag","MI_Id","IVRMUL_SuperAdminFlag","CreatedDate","UpdatedDate")
        SELECT "IVRMRT_Id","IVRMUL_UserName","IVRMUL_Password","IVRMUL_SecurityQns","IVRMUL_Answer","IVRMUL_ActiveFlag",p_MI_Id,"IVRMUL_SuperAdminFlag","CreatedDate","UpdatedDate" 
        FROM "IVRM_User_Login" WHERE "MI_Id" = p_SMI_Id;
    END IF;

    v_ULIRcount := 0;

    SELECT COUNT(*) INTO v_ULIRcount FROM "IVRM_User_Login_Institutionwise" WHERE "MI_Id" = p_MI_Id AND "Id" = p_AppId;

    IF v_ULIRcount = 0 THEN
        INSERT INTO "IVRM_User_Login_Institutionwise"("MI_Id","Id","CreatedDate","UpdatedDate","Activeflag","IVRMULI_PaymentAlertFlg","IVRMULI_SubExpAlertFlg")
        SELECT p_MI_Id,p_AppId,"CreatedDate","UpdatedDate","Activeflag","IVRMULI_PaymentAlertFlg","IVRMULI_SubExpAlertFlg" 
        FROM "IVRM_User_Login_Institutionwise" WHERE "MI_Id" = p_SMI_Id LIMIT 1;
    END IF;

    v_ISVRcount := 0;

    SELECT COUNT(*) INTO v_ISVRcount FROM "Master_Institution_SubscriptionValidity" WHERE "MI_Id" = p_MI_Id;

    IF v_ISVRcount = 0 THEN
        INSERT INTO "Master_Institution_SubscriptionValidity"("MI_Id","MISV_FromDate","MISV_ToDate","MISV_SubscriptionNo","MISV_SubscriptionType","MISV_ActiveFlag","CreatedDate","UpdatedDate","MISV_OrderNo")
        SELECT p_MI_Id,"MISV_FromDate","MISV_ToDate","MISV_SubscriptionNo","MISV_SubscriptionType","MISV_ActiveFlag","CreatedDate","UpdatedDate","MISV_OrderNo" 
        FROM "Master_Institution_SubscriptionValidity" WHERE "MI_Id" = p_SMI_Id;
    END IF;

    v_FMDRcount := 0;

    SELECT COUNT(*) INTO v_FMDRcount FROM "Fo"."FO_Master_Day" WHERE "MI_Id" = p_MI_Id;

    IF v_FMDRcount = 0 THEN
        INSERT INTO "Fo"."FO_Master_Day"("MI_Id","FOMD_DayName","FOMD_DayCode","FOMD_ActiveFlag","CreatedDate","UpdatedDate")
        SELECT p_MI_Id,"FOMD_DayName","FOMD_DayCode","FOMD_ActiveFlag","CreatedDate","UpdatedDate" 
        FROM "Fo"."FO_Master_Day" WHERE "MI_Id" = p_SMI_Id;
    END IF;

    v_HMCORCount := 0;

    SELECT COUNT(*) INTO v_HMCORCount FROM "HR_Master_Course" WHERE "MI_Id" = p_MI_Id;

    IF v_HMCORCount = 0 THEN
        INSERT INTO "HR_Master_Course"("MI_Id","HRMC_QulaificationName","HRMC_QualificationDesc","HRMC_DefaultQualFag","HRMC_SpecialisationFlag","HRMC_Order","HRMC_ActiveFlag","CreatedDate","UpdatedDate","HRMC_CreatedBy","HRMC_UpdatedBy")
        SELECT p_MI_Id,"HRMC_QulaificationName","HRMC_QualificationDesc","HRMC_DefaultQualFag","HRMC_SpecialisationFlag","HRMC_Order","HRMC_ActiveFlag","CreatedDate","UpdatedDate","HRMC_CreatedBy","HRMC_UpdatedBy" 
        FROM "HR_Master_Course" WHERE "MI_Id" = p_SMI_Id;
    END IF;

    v_HTMLRCount := 0;

    SELECT COUNT(*) INTO v_HTMLRCount FROM "IVRM_Master_HTMLTemplates" WHERE "MI_Id" = p_MI_Id;

    IF v_HTMLRCount = 0 THEN
        INSERT INTO "IVRM_Master_HTMLTemplates"("MI_Id","ISMHTML_HTMLName","ISMHTML_HTMLTemplate","ISMHTML_ActiveFlg","ISMHTML_CreatedBy","ISMHTML_UpdatedBy","ISMHTML_CreatedDate","ISMHTML_UpdatedDate")
        SELECT p_MI_Id,"ISMHTML_HTMLName","ISMHTML_HTMLTemplate","ISMHTML_ActiveFlg","ISMHTML_CreatedBy","ISMHTML_UpdatedBy","ISMHTML_CreatedDate","ISMHTML_UpdatedDate" 
        FROM "IVRM_Master_HTMLTemplates" WHERE "MI_Id" = p_SMI_Id;
    END IF;

    SELECT COUNT(*) INTO v_IRMPCount FROM "IVRM_Role_MobileApp_Privileges";
    
    IF v_IRMPCount = 0 THEN
        INSERT INTO "IVRM_Role_MobileApp_Privileges"("IVRMRT_Id","IVRMMAP_Id","IVRMRMAP_ActiveFlg","CreatedDate","UpdatedDate","MI_ID") 
        SELECT "IVRMRT_Id","IVRMMAP_Id","IVRMRMAP_ActiveFlg","CreatedDate","UpdatedDate",p_MI_ID 
        FROM "IVRM_Role_MobileApp_Privileges" WHERE "MI_Id" = p_SMI_Id;
    END IF;

    SELECT COUNT(*) INTO v_IMALDCount FROM "IVRM_MobileApp_LoginDetails" WHERE "MI_Id" = p_MI_Id AND "IVRMUL_Id" = p_AppId;

    IF v_IMALDCount = 0 THEN
        INSERT INTO "IVRM_MobileApp_LoginDetails"("MI_Id","IVRMUL_Id","IVRMMALD_DateTime","IVRMMALD_logintype","IVRMMALD_MobileModel","CreatedDate","UpdatedDate") 
        VALUES (p_MI_Id, p_AppId, CAST('2019-09-05 17:07:07.560' AS TIMESTAMP), 'Web', '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;

    v_MAACount := 0;

    SELECT COUNT(*) INTO v_MAACount FROM "MobileApplAuthentication" WHERE "MI_Id" = p_MI_Id;

    IF v_MAACount = 0 THEN
        INSERT INTO "MobileApplAuthentication"("MI_Id","MAAN_AuthenticationKey","CreatedDate","UpdatedDate","MAAN_CreatedBy","MAAN_UpdatedBy") 
        SELECT p_MI_Id,"MAAN_AuthenticationKey","CreatedDate","UpdatedDate","MAAN_CreatedBy","MAAN_UpdatedBy" 
        FROM "MobileApplAuthentication" WHERE "MI_Id" = p_SMI_Id;
    END IF;

    v_DPMRcount := 0;

    SELECT COUNT(*) INTO v_DPMRcount FROM "IVRM_Dashboard_Page_Mapping" WHERE "MI_Id" = p_MI_Id;
    
    IF v_DPMRcount = 0 THEN
        INSERT INTO "IVRM_Dashboard_Page_Mapping"("IVRMP_Dasboard_PageName","IVRMRT_Role","MI_ID","IVRM_CreatedDate","IVRM_UpdatedDate","IVRM_CreatedBy","IVRM_UpdatedBy")
        SELECT "IVRMP_Dasboard_PageName","IVRMRT_Role",p_MI_Id,"IVRM_CreatedDate","IVRM_UpdatedDate","IVRM_CreatedBy","IVRM_UpdatedBy" 
        FROM "IVRM_Dashboard_Page_Mapping" WHERE "MI_Id" = p_SMI_Id;
    END IF;

    v_SDPMRcount := 0;
    v_PDPMRcount := 0;

    SELECT COUNT(*) INTO v_PDPMRcount FROM "IVRM_Dashboard_Page_Mapping" WHERE "MI_Id" = p_MI_Id;
    
    IF v_PDPMRcount = 0 THEN
        INSERT INTO "IVRM_Dashboard_Page_Mapping"("IVRMP_Dasboard_PageName","IVRMRT_Role","MI_ID","IVRM_CreatedDate","IVRM_UpdatedDate","IVRM_CreatedBy","IVRM_UpdatedBy")
        SELECT "IVRMP_Dasboard_PageName","IVRMRT_Role",p_MI_ID,"IVRM_CreatedDate","IVRM_UpdatedDate","IVRM_CreatedBy","IVRM_UpdatedBy" 
        FROM "IVRM_Dashboard_Page_Mapping" WHERE "MI_Id" = p_SMI_Id;
    END IF;

    v_PDPMRcount := 0;
    
    SELECT COUNT(*) INTO v_PDPMRcount FROM "IVRM_General_Cofiguration" WHERE "MI_Id" = p_MI_Id;
    
    IF v_PDPMRcount = 0 THEN
        INSERT INTO "IVRM_General_Cofiguration"("MI_Id","IVRMGC_MobileValOTPFlag","IVRMGC_emailValOTPFlag","IVRMGC_StudentPhotoPath","IVRMGC_StaffPhotoPath","IVRMGC_ComTrasaNoFlag","IVRMGC_SMSDomain","IVRMGC_SMSURL","IVRMGC_SMSUserName","IVRMGC_SMSPassword","IVRMGC_SMSSenderId","IVRMGC_SMSWorkingKey","IVRMGC_SMSFooter","IVRMGC_SMSActiveFlag","IVRMGC_emailUserName","IVRMGC_emailPassword","IVRMGC_HostName","IVRMGC_PortNo","IVRMGC_MailGenralDesc","IVRMGC_Webiste","IVRMGC_emailid","IVRMGC_emailFooter","IVRMGC_CCMail","IVRMGC_BCCMail","IVRMGC_ToMail","IVRMGC_EmailActiveFlag","IVRMGC_Pagination","IVRMGC_ReminderDays","IVRMGC_ClassCapacity","IVRMGC_SectionCapacity","IVRMGC_SCLockingPeriod","IVRMGC_SCActive","IVRMGC_FPActive","IVRMGC_FaceReaderActive","IVRMGC_DefaultStudentSelection","CreatedDate","UpdatedDate","IVRMGC_PagePagination","IVRMGC_ReportPagination","IVRMGC_ManagerSign","IVRMGC_PrincipalSign","IVRMGC_OnlinePaymentCompany","IVRMGC_APIOrSMTPFlg","IVRMGC_IVRSVoiceFilePath","IVRMGC_EnableSTIntFlg","IVRMGC_EnableCTIntFlg","IVRMGC_EnableHODIntFlg","IVRMGC_EnablePrincipalIntFlg","IVRMGC_EnableASIntFlg","IVRMGC_TAApprovalReqFlg","IVRMGC_EnableECIntFlg","IVRMGC_SportsPointsDropdownFlg","IVRMGC_FMSManualReferenceFlg","IVRMGC_AlumniRegCompFlg","IVRMGC_AlumniRegFeeApplFlg","IVRMGC_SMSApproval","IVRMGC_MailApproval","IVRMGC_CallApproval","IVRMGC_StudentDataChangeAlertFlg","IVRMGC_StudentDataChangeAlertDays","IVRMGC_EnableSUBTSTUIntFlg","IVRMGC_VMReminderSchedule","IVRMGC_VMReminderFlag","IVRMGC_VMRepeatFlag","IVRMGC_CreatedBy","IVRMGC_UpdatedBy")
        SELECT p_MI_Id,"IVRMGC_MobileValOTPFlag","IVRMGC_emailValOTPFlag","IVRMGC_StudentPhotoPath","IVRMGC_StaffPhotoPath","IVRMGC_ComTrasaNoFlag","IVRMGC_SMSDomain","IVRMGC_SMSURL","IVRMGC_SMSUserName","IVRMGC_SMSPassword","IVRMGC_SMSSenderId","IVRMGC_SMSWorkingKey","IVRMGC_SMSFooter","IVRMGC_SMSActiveFlag","IVRMGC_emailUserName","IVRMGC_emailPassword","IVRMGC_HostName","IVRMGC_PortNo","IVRMGC_MailGenralDesc","IVRMGC_Webiste","IVRMGC_emailid","IVRMGC_emailFooter","IVRMGC_CCMail","IVRMGC_BCCMail","IVRMGC_ToMail","IVRMGC_EmailActiveFlag","IVRMGC_Pagination","IVRMGC_ReminderDays","IVRMGC_ClassCapacity","IVRMGC_SectionCapacity","IVRMGC_SCLockingPeriod","IVRMGC_SCActive","IVRMGC_FPActive","IVRMGC_FaceReaderActive","IVRMGC_DefaultStudentSelection","CreatedDate","UpdatedDate","IVRMGC_PagePagination","IVRMGC_ReportPagination","IVRMGC_ManagerSign","IVRMGC_PrincipalSign","IVRMGC_OnlinePaymentCompany","IVRMGC_APIOrSMTPFlg","IVRMGC_IVRSVoiceFilePath","IVRMGC_EnableSTIntFlg","IVRMGC_EnableCTIntFlg","IVRMGC_EnableHODIntFlg","IVRMGC_EnablePrincipalIntFlg","IVRMGC_EnableASIntFlg","IVRMGC_TAApprovalReqFlg","IVRMGC_EnableECIntFlg","IVRMG