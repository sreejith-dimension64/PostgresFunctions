CREATE OR REPLACE FUNCTION "HR_Candiddate_Details"(p_HRCD_Id BIGINT)
RETURNS TABLE(
    "HRCD_Id" BIGINT,
    "HRMPT_Id" BIGINT,
    "HRMPT_Name" VARCHAR,
    "HRMC_Id" BIGINT,
    "HRMC_QulaificationName" VARCHAR,
    "HRCD_MRFNO" VARCHAR,
    "HRCD_FirstName" VARCHAR,
    "HRCD_MiddleName" VARCHAR,
    "HRCD_LastName" VARCHAR,
    "HRMJ_Id" BIGINT,
    "HRCD_Skills" TEXT,
    "HRCD_DOB" DATE,
    "IVRMMG_Id" BIGINT,
    "IVRMMG_GenderName" VARCHAR,
    "HRCD_MobileNo" VARCHAR,
    "HRCD_EmailId" VARCHAR,
    "HRCD_ExpFrom" DATE,
    "HRCD_ExpTo" DATE,
    "HRCD_CurrentCompany" VARCHAR,
    "HRCD_ResumeSource" VARCHAR,
    "HRCD_JobPortalName" VARCHAR,
    "HRCD_RefCode" VARCHAR,
    "HRCD_LastCTC" NUMERIC,
    "HRCD_ExpectedCTC" NUMERIC,
    "HRCD_AppDate" DATE,
    "HRCD_InterviewDate" TIMESTAMP,
    "HRCD_NoticePeriod" VARCHAR,
    "HRCD_Remarks" TEXT,
    "HRCD_Resume" BYTEA,
    "HRCD_RecruitmentStatus" VARCHAR,
    "HRCD_CreatedBy" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT a."HRCD_Id",
           b."HRMPT_Id",
           b."HRMPT_Name",
           c."HRMC_Id",
           c."HRMC_QulaificationName",
           a."HRCD_MRFNO",
           a."HRCD_FirstName",
           a."HRCD_MiddleName",
           a."HRCD_LastName",
           a."HRMJ_Id",
           a."HRCD_Skills",
           a."HRCD_DOB",
           d."IVRMMG_Id",
           d."IVRMMG_GenderName",
           a."HRCD_MobileNo",
           a."HRCD_EmailId",
           a."HRCD_ExpFrom",
           a."HRCD_ExpTo",
           a."HRCD_CurrentCompany",
           a."HRCD_ResumeSource",
           a."HRCD_JobPortalName",
           a."HRCD_RefCode",
           a."HRCD_LastCTC",
           a."HRCD_ExpectedCTC",
           a."HRCD_AppDate",
           a."HRCD_InterviewDate",
           a."HRCD_NoticePeriod",
           a."HRCD_Remarks",
           a."HRCD_Resume",
           a."HRCD_RecruitmentStatus",
           a."HRCD_CreatedBy"
    FROM "HR_Candidate_Details" a
    INNER JOIN "HR_Master_PostionType" b ON a."HRMPT_Id" = b."HRMPT_Id"
    INNER JOIN "HR_Master_Course" c ON a."HRMC_Id" = c."HRMC_Id"
    INNER JOIN "IVRM_Master_Gender" d ON a."IVRMMG_Id" = d."IVRMMG_Id"
    WHERE a."HRCD_Id" = p_HRCD_Id;
END;
$$;