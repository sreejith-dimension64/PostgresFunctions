CREATE OR REPLACE FUNCTION "dbo"."CLG_Student_Meeting_Profile_Student_Report"(
    p_MI_Id VARCHAR(10),
    p_ASMAY_Id VARCHAR(10),
    p_Studentid TEXT,
    p_FromDate VARCHAR(10),
    p_ToDate VARCHAR(10),
    p_TYPE VARCHAR(10)
)
RETURNS TABLE (
    "LMSLMEET_Id" BIGINT,
    "LMSLMEET_MeetingId" VARCHAR,
    "LMSLMEET_PlannedDate" TIMESTAMP,
    "AMCO_Id" BIGINT,
    "AMB_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "ACMS_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "LMSLMEET_PlannedStartTime" TIME,
    "LMSLMEET_PlannedEndTime" TIME,
    "LMSLMEET_MeetingDate" TIMESTAMP,
    "LMSLMEET_StartedTime" TIME,
    "LMSLMEET_EndTime" TIME,
    "ScheduleStaffId" BIGINT,
    "LMSLMEET_MeetingTopic" TEXT,
    "HRME_Id" BIGINT,
    "EmpName" TEXT,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "ACMS_SectionName" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "LMSLMEETCOBR_Id" BIGINT,
    "AMST_Id" BIGINT,
    "LMSLMEETSTD_LoginTime" TIMESTAMP,
    "LMSLMEETSTD_LogoutTime" TIMESTAMP,
    "LMSLMEETSTDCOL_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SqlDynamic TEXT;
BEGIN
    IF p_TYPE = 'SCH' THEN
        v_SqlDynamic := '
        SELECT DISTINCT LM."LMSLMEET_Id", LM."LMSLMEET_MeetingId", LM."LMSLMEET_PlannedDate", MC."AMCO_Id", MC."AMB_Id", MC."AMSE_Id", MC."ACMS_Id", MC."ISMS_Id",
        LM."LMSLMEET_PlannedStartTime", LM."LMSLMEET_PlannedEndTime", LM."LMSLMEET_MeetingDate", LM."LMSLMEET_StartedTime",
        LM."LMSLMEET_EndTime", LM."HRME_Id" AS "ScheduleStaffId", LM."LMSLMEET_MeetingTopic", COALESCE(LM."HRME_Id", 0) AS "HRME_Id",
        COALESCE(ME."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(ME."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(ME."HRME_EmployeeLastName", '''') AS "EmpName",
        ASMC."AMCO_CourseName", AMB."AMB_BranchName", SME."AMSE_SEMName", ACMS."ACMS_SectionName", IMS."ISMS_SubjectName", MC."LMSLMEETCOBR_Id", AY."AMCST_Id" AS "AMST_Id",
        NULL::TIMESTAMP AS "LMSLMEETSTD_LoginTime", NULL::TIMESTAMP AS "LMSLMEETSTD_LogoutTime", NULL::BIGINT AS "LMSLMEETSTDCOL_Id"
        FROM "LMS_Live_Meeting" LM 
        INNER JOIN "LMS_Live_Meeting_CourseBranch" MC ON LM."LMSLMEET_Id" = MC."LMSLMEET_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AY ON AY."AMCO_Id" = MC."AMCO_Id" AND AY."AMB_Id" = MC."AMB_Id" AND AY."AMSE_Id" = MC."AMSE_Id" AND AY."ACMS_Id" = MC."ACMS_Id" AND AY."ASMAY_Id" = MC."ASMAY_Id"
        INNER JOIN "HR_Master_Employee" ME ON ME."HRME_Id" = LM."HRME_Id"
        INNER JOIN "CLG"."Adm_Master_Course" ASMC ON ASMC."AMCO_Id" = MC."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AMB ON AMB."AMB_Id" = MC."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" SME ON SME."AMSE_Id" = MC."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" ACMS ON ACMS."ACMS_Id" = MC."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" IMS ON IMS."ISMS_Id" = MC."ISMS_Id"
        WHERE AY."ASMAY_Id" = ' || p_ASMAY_Id || ' AND LM."MI_Id" = ' || p_MI_Id || ' AND AY."AMCST_Id" IN (' || p_Studentid || ') AND LM."LMSLMEET_ActiveFlg" = TRUE
        AND CAST(LM."LMSLMEET_PlannedDate" AS DATE) BETWEEN ''' || p_FromDate || ''' AND ''' || p_ToDate || '''';
    END IF;

    IF p_TYPE = 'AT' THEN
        v_SqlDynamic := '
        SELECT DISTINCT LM."LMSLMEET_Id", LM."LMSLMEET_MeetingId", LM."LMSLMEET_PlannedDate", MC."AMCO_Id", MC."AMB_Id", MC."AMSE_Id", MC."ACMS_Id", MC."ISMS_Id",
        LM."LMSLMEET_PlannedStartTime", LM."LMSLMEET_PlannedEndTime", LM."LMSLMEET_MeetingDate", LM."LMSLMEET_StartedTime",
        LM."LMSLMEET_EndTime", LM."HRME_Id" AS "ScheduleStaffId", LM."LMSLMEET_MeetingTopic",
        COALESCE(LM."HRME_Id", 0) AS "HRME_Id", COALESCE(ME."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(ME."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(ME."HRME_EmployeeLastName", '''') AS "EmpName",
        ASMC."AMCO_CourseName", AMB."AMB_BranchName", SME."AMSE_SEMName", ACMS."ACMS_SectionName", IMS."ISMS_SubjectName", MC."LMSLMEETCOBR_Id", AY."AMCST_Id" AS "AMST_Id",
        LMS."LMSLMEETSTDCOL_LoginTime" AS "LMSLMEETSTD_LoginTime", LMS."LMSLMEETSTDCOL_LogoutTime" AS "LMSLMEETSTD_LogoutTime", LMS."LMSLMEETSTDCOL_Id"
        FROM "LMS_Live_Meeting" LM 
        INNER JOIN "LMS_Live_Meeting_CourseBranch" MC ON LM."LMSLMEET_Id" = MC."LMSLMEET_Id"
        INNER JOIN "LMS_Live_Meeting_Student_College" LMS ON LMS."LMSLMEET_Id" = LM."LMSLMEET_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AY ON AY."AMCO_Id" = MC."AMCO_Id" AND AY."AMB_Id" = MC."AMB_Id" AND AY."AMSE_Id" = MC."AMSE_Id" AND AY."ACMS_Id" = MC."ACMS_Id" AND AY."ASMAY_Id" = MC."ASMAY_Id" AND AY."AMCST_Id" = LMS."AMCST_Id"
        INNER JOIN "HR_Master_Employee" ME ON ME."HRME_Id" = LM."HRME_Id"
        INNER JOIN "CLG"."Adm_Master_Course" ASMC ON ASMC."AMCO_Id" = MC."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AMB ON AMB."AMB_Id" = MC."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" SME ON SME."AMSE_Id" = MC."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" ACMS ON ACMS."ACMS_Id" = MC."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" IMS ON IMS."ISMS_Id" = MC."ISMS_Id"
        WHERE AY."ASMAY_Id" = ' || p_ASMAY_Id || ' AND LM."MI_Id" = ' || p_MI_Id || ' AND AY."AMCST_Id" IN (' || p_Studentid || ') AND LMS."AMCST_Id" IN (' || p_Studentid || ') AND LM."LMSLMEET_ActiveFlg" = TRUE
        AND CAST(LM."LMSLMEET_PlannedDate" AS DATE) BETWEEN ''' || p_FromDate || ''' AND ''' || p_ToDate || '''';
    END IF;

    RETURN QUERY EXECUTE v_SqlDynamic;
    
    RETURN;
END;
$$;