CREATE OR REPLACE FUNCTION "dbo"."IVRM_ModulesPagesMapping"(
    p_SMI_Id bigint,
    p_MI_Id bigint,
    p_UserName text
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
    v_AppId bigint;
    v_roleid bigint;
    v_RoleTypeId bigint;
    v_URCount int;
    v_ULRCount int;
    v_ULIRcount int;
    v_ISVRcount int;
    v_IVSRcount bigint;
    v_School_Id bigint;
    v_Subdomain varchar(100);
    v_GenderRCount int;
    v_GovRcount int;
    v_IMMSRcount int;
    v_IMNRcount int;
    v_IMPRcount2 int;
    v_IOPRcount int;
    v_ISESRcount int;
    v_CIVRMIM_Id bigint;
    v_CIVRMIMP_Id bigint;
    v_SESRcount bigint;
    v_EMI_Id bigint;
    v_EIVRMIM_Id bigint;
    v_ISES_Id_MN bigint;
    v_ISMP_Id bigint;
    v_ISES_Id bigint;
    v_PRcount bigint;
    v_ISES_Template_Name text;
    v_ISES_SMSMessage text;
    v_ISES_SMSActiveFlag boolean;
    v_ISES_MailSubject text;
    v_ISES_MailBody text;
    v_ISES_MailFooter text;
    v_ISES_Mail_Message text;
    v_ISES_MailHTMLTemplate text;
    v_ISES_MailActiveFlag boolean;
    v_IVRMSTAUL_Id bigint;
    v_EIVRMIMP_Id bigint;
    v_ISES_IVRSTextMsg text;
    v_ISES_IVRSVoiceFile text;
    v_ISES_PNActiveFlg boolean;
    v_ISES_PNMessage text;
    v_ISES_EnableSMSCCFlg boolean;
    v_ISES_SMSCCMobileNo text;
    v_ISES_EnableMailCCFlg boolean;
    v_ISES_EnableMailBCCFlg boolean;
    v_ISES_MailCCId text;
    v_ISES_MailBCCId text;
    v_ISES_AlertBeforeDays bigint;
    v_ISES_TemplateId text;
    v_FMDRcount int;
    v_HMCORCount bigint;
    v_HTMLRCount bigint;
    v_MAACount bigint;
    v_DPMRcount bigint;
    v_IVRMIMP_Id_P bigint;
    v_HeaderName text;
    v_HDRRcount bigint;
    v_IMRcount1 int;
    v_IMPRcount int;
    v_IVRMIMP_Id bigint;
    v_IVRMIMP_Id_Prev bigint;
    v_IVRMRT_Id_Prev bigint;
    v_SDPMRcount int;
    v_PDPMRcount int;
    v_MSRcount int;
    v_IMBRcount int;
    v_IMCCRcount int;
    v_IMCRcount int;
    v_MIRcount int;
    v_PMIRcount int;
    v_IVRMMMI_Id_MN bigint;
    v_IVRMMMI_IdW bigint;
    v_IVRMM_IdW bigint;
    v_IVRMM_Id_M bigint;
    v_Menu1 text;
    v_IVRMMMC_Id bigint;
    v_ASCRCount int;
    v_ASMCRCount int;
    v_ASMSRCount int;
    v_AMCRcount int;
    v_PCRcount int;
    v_CMERCount int;
    v_ECRcount bigint;
    v_EMERCount bigint;
    v_MSUBE int;
    v_MSubSubj int;
    v_CEMCA_Id int;
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
    v_MGRcount int;
    v_GSRcount int;
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
    v_SGERcount int;
    v_SGERcount1 int;
    v_SGERcount2 int;
    v_EYC_Id int;
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
    v_ASMAY_Id bigint;
    v_EMCA_Id int;
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
    v_SessionRcount int;
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
    v_ETTRcount int;
    v_TTSRcount int;
    v_HRCRCount int;
    v_HDRCount int;
    v_HRDesRCount int;
    v_HRGTRCount int;
    v_HRGRCount int;
    v_HRETRCount int;
    v_HRMLYRCount int;
    v_HRPRcount int;
    v_HRMLRCount int;
    v_MLRRcount int;
    v_FSRcount int;
    v_FMRcount int;
    v_FMTRcount int;
    v_IRcount int;
    v_ITRcount int;
    v_MHRcount int;
    v_FMCCRcount int;
    v_PMStatus bigint;
    v_CAMCP_Id bigint;
    v_ceRcount int;
    v_CESRcount int;
    v_EYCRcount int;
    v_cgrcount int;
    v_cgsrcount int;
    v_EESERcount int;
    v_EESSRcount int;
    v_ISDRcount int;
    v_HRMEDRCount int;
    v_EMGR_GradeName text;
    v_CEMGR_Id int;
    v_GMI_Id bigint;
    v_EMGR_MarksPerFlag text;
    v_GDEMGR_Id int;
    v_EMGD_Name text;
    v_EMGD_From decimal(18,2);
    v_EMGD_To decimal(18,2);
    v_EMGD_Remarks text;
    v_EMGD_GradePoints decimal(18,2);
    v_EMGD_ActiveFlag boolean;
    v_NEMGR_Id int;
    v_GRcount int;
    v_GDRcount int;
    v_row_count int;
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

    INSERT INTO "Applicationuser"(
        "AccessFailedCount","ConcurrencyStamp","Email","EmailConfirmed","LockoutEnabled","LockoutEnd",
        "NormalizedEmail","NormalizedUserName","PasswordHash","PhoneNumber","PhoneNumberConfirmed",
        "SecurityStamp","TwoFactorEnabled","UserName","Entry_Date","Machine_Ip_Address","UserImagePath",
        "RoleTypeFlag","CreatedDate","UpdatedDate","Name","CreatedBy","UpdatedBy"
    )
    SELECT 
        "AU"."AccessFailedCount","AU"."ConcurrencyStamp","AU"."Email","AU"."EmailConfirmed","AU"."LockoutEnabled",
        "AU"."LockoutEnd","AU"."NormalizedEmail",p_UserName,
        'AQAAAAEAACcQAAAAEGARxyK/NchjUhbaTLWFLaRoajzOq97Z9auxTu298V4cvp/lulgUFuJ0MftIeeSdyA==',
        "AU"."PhoneNumber","AU"."PhoneNumberConfirmed","AU"."SecurityStamp","AU"."TwoFactorEnabled",
        p_UserName,"AU"."Entry_Date","AU"."Machine_Ip_Address","AU"."UserImagePath","AU"."RoleTypeFlag",
        CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,"AU"."Name","AU"."CreatedBy","AU"."UpdatedBy"
    FROM "Applicationuser" "AU"
    LIMIT 1;

    SELECT "id" INTO v_AppId 
    FROM "Applicationuser" 
    WHERE "NormalizedUserName" = p_UserName 
    ORDER BY "id" DESC 
    LIMIT 1;

    SELECT "IVRMRT_Id" INTO v_RoleTypeId 
    FROM "IVRM_Role_Type" 
    WHERE "IVRMRT_Role" = 'ADMIN' 
    ORDER BY "IVRMRT_Id" DESC 
    LIMIT 1;

    SELECT "roleid" INTO v_roleid 
    FROM "ApplicationUserRole" 
    WHERE "RoleTypeId" = v_RoleTypeId 
    ORDER BY "roleid" DESC 
    LIMIT 1;

    v_URCount := 0;
    SELECT COUNT(*) INTO v_URCount 
    FROM "ApplicationUserRole" 
    WHERE "USERID" = v_AppId;

    IF v_URCount = 0 THEN
        INSERT INTO "ApplicationUserRole"("UserId","RoleId","RoleTypeId","CreatedDate","UpdatedDate")
        VALUES (v_AppId, v_roleid, v_RoleTypeId, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;

    v_ULRCount := 0;
    SELECT COUNT(*) INTO v_ULRCount 
    FROM "IVRM_User_Login" 
    WHERE "MI_Id" = p_MI_Id;

    IF v_ULRCount = 0 THEN
        INSERT INTO "IVRM_User_Login"(
            "IVRMRT_Id","IVRMUL_UserName","IVRMUL_Password","IVRMUL_SecurityQns","IVRMUL_Answer",
            "IVRMUL_ActiveFlag","MI_Id","IVRMUL_SuperAdminFlag","CreatedDate","UpdatedDate"
        )
        SELECT 
            "IVRMRT_Id","IVRMUL_UserName","IVRMUL_Password","IVRMUL_SecurityQns","IVRMUL_Answer",
            "IVRMUL_ActiveFlag",p_MI_Id,"IVRMUL_SuperAdminFlag","CreatedDate","UpdatedDate"
        FROM "IVRM_User_Login" 
        WHERE "MI_Id" = p_SMI_Id;
    END IF;

    v_ULIRcount := 0;
    SELECT COUNT(*) INTO v_ULIRcount 
    FROM "IVRM_User_Login_Institutionwise"  
    WHERE "MI_Id" = p_MI_Id AND "Id" = v_AppId;

    IF v_ULIRcount = 0 THEN
        INSERT INTO "IVRM_User_Login_Institutionwise"(
            "MI_Id","Id","CreatedDate","UpdatedDate","Activeflag","IVRMULI_PaymentAlertFlg","IVRMULI_SubExpAlertFlg"
        )
        SELECT 
            p_MI_Id, v_AppId, "CreatedDate", "UpdatedDate", "Activeflag", 
            "IVRMULI_PaymentAlertFlg", "IVRMULI_SubExpAlertFlg"
        FROM "IVRM_User_Login_Institutionwise" 
        WHERE "MI_Id" = p_SMI_Id 
        LIMIT 1;
    END IF;

    v_ISVRcount := 0;
    SELECT COUNT(*) INTO v_ISVRcount 
    FROM "Master_Institution_SubscriptionValidity" 
    WHERE "MI_Id" = p_MI_Id;

    IF v_ISVRcount = 0 THEN
        INSERT INTO "Master_Institution_SubscriptionValidity"(
            "MI_Id","MISV_FromDate","MISV_ToDate","MISV_SubscriptionNo","MISV_SubscriptionType",
            "MISV_ActiveFlag","CreatedDate","UpdatedDate","MISV_OrderNo"
        )
        SELECT 
            p_MI_Id,"MISV_FromDate","MISV_ToDate","MISV_SubscriptionNo","MISV_SubscriptionType",
            "MISV_ActiveFlag","CreatedDate","UpdatedDate","MISV_OrderNo"
        FROM "Master_Institution_SubscriptionValidity" 
        WHERE "MI_Id" = p_SMI_Id;
    END IF;

    SELECT COUNT(*) INTO v_ISMPCount 
    FROM "IVRM_SMS_MAIL_PARAMETER";

    IF v_ISMPCount = 0 THEN
        INSERT INTO "IVRM_SMS_MAIL_PARAMETER"("ISMP_ID","ISMP_NAME","CreatedDate","UpdatedDate") 
        VALUES 
        (1, '[USR]', '2017-05-24 12:31:56.890'::timestamp, '2017-05-24 12:31:56.890'::timestamp),
        (2, '[PWD]', '2017-05-24 12:31:56.890'::timestamp, '2017-05-24 12:31:56.890'::timestamp),
        (3, '[AMOUNT]', '2017-11-05 00:00:00.000'::timestamp, '2017-11-05 00:00:00.000'::timestamp),
        (4, '[TERM]', '2017-11-05 00:00:00.000'::timestamp, '2017-11-05 00:00:00.000'::timestamp),
        (5, '[DATE]', '2017-11-14 00:00:00.000'::timestamp, '2017-11-14 00:00:00.000'::timestamp),
        (6, '[NAME]', '2017-11-14 00:00:00.000'::timestamp, '2017-11-14 00:00:00.000'::timestamp),
        (7, '[RECEIPT_NO]', '2017-11-14 00:00:00.000'::timestamp, '2017-11-14 00:00:00.000'::timestamp),
        (8, '[TIME]', '2017-11-14 00:00:00.000'::timestamp, '2017-11-14 00:00:00.000'::timestamp),
        (9, '[STATUS]', '2017-11-14 00:00:00.000'::timestamp, '2017-11-14 00:00:00.000'::timestamp),
        (10, '[OTP]', '2017-11-14 00:00:00.000'::timestamp, '2017-11-14 00:00:00.000'::timestamp),
        (11, '[REG_NO]', '2017-11-14 00:00:00.000'::timestamp, '2017-11-14 00:00:00.000'::timestamp),
        (12, '[TERM]', '2017-11-14 00:00:00.000'::timestamp, '2017-11-14 00:00:00.000'::timestamp),
        (13, '[AMOUNT]', '2017-11-22 06:18:31.500'::timestamp, '2017-11-22 06:18:31.500'::timestamp),
        (14, '[DUEDATE]', '2017-11-22 06:18:31.500'::timestamp, '2017-11-22 06:18:31.500'::timestamp),
        (15, '[INSTUITENAME]', '2017-11-20 00:00:00.000'::timestamp, '2017-11-20 00:00:00.000'::timestamp),
        (16, '[EMAIL]', '2017-11-20 00:00:00.000'::timestamp, '2017-11-20 00:00:00.000'::timestamp),
        (17, '[STUDENT_NAME]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (18, '[PARENT]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (19, '[PICKUPROUTENO]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (20, '[PICKUPROUTENAME]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (21, '[DROPROUTENO]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (22, '[DROPROUTENAME]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (23, '[MESSAGE]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (24, '[STAFFNAME1]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (25, '[CLASS]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (26, '[SECTION]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (27, '[STAFFNAME2]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (28, '[DATEDEPUT]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (29, '[PERIODNAME]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (30, '[HIRER]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (31, '[PLACE]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (32, '[VEHICLEDETAILS]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (33, '[HIRERNO]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (34, '[TITLE]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (35, '[ISSUEDATE]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (36, '[RETURNDATE]', '2017-12-16 00:00:00.000'::timestamp, '2017-12-16 00:00:00.000'::timestamp),
        (37, '[Staffname]', '2018-04-25 00:00:00.000'::timestamp, '2018-04-25 00:00:00.000'::timestamp),
        (38, '[PARENTNAME]', '2019-03-23 00:00:00.000'::timestamp, '2019-03-23 00:00:00.000'::timestamp),
        (40, '[SUBJECTS]', '2019-03-23 00:00:00.000'::timestamp, '2019-03-23 00:00:00.000'::timestamp);
    END IF;

    v_FMDRcount := 0;
    SELECT COUNT(*) INTO v_FMDRcount 
    FROM "Fo"."FO_Master_Day" 
    WHERE "MI_Id" = p_MI_Id;

    IF v_FMDRcount = 0 THEN
        INSERT INTO "Fo"."FO_Master_Day"(
            "MI_Id","FOMD_DayName","FOMD_DayCode","FOMD_ActiveFlag","CreatedDate","UpdatedDate"
        )
        SELECT 
            p_MI_Id,"FOMD_DayName","FOMD_DayCode","FOMD_ActiveFlag","CreatedDate","UpdatedDate"
        FROM "Fo"."FO_Master_Day" 
        WHERE "MI_Id" = p_SMI_Id;
    END IF;

    v_HMCORCount := 0;
    SELECT COUNT(*) INTO v_HMCORCount 
    FROM "HR_Master_Course" 
    WHERE "MI_Id" = p_MI_Id;

    IF v_HMCORCount = 0 THEN
        INSERT INTO "HR_Master_Course"(
            "MI_Id","HRMC_QulaificationName","HRMC_QualificationDesc","HRMC_DefaultQualFag",
            "HRMC_SpecialisationFlag","HRMC_Order","HRMC_ActiveFlag","CreatedDate","UpdatedDate",
            "HRMC_CreatedBy","HRMC_UpdatedBy"
        )
        SELECT 
            p_MI_Id,"HRMC_Qu