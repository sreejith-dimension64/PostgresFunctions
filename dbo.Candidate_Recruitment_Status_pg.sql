CREATE OR REPLACE FUNCTION "dbo"."Candidate_Recruitment_Status"(
    "HRCD_Id" TEXT
)
RETURNS TABLE(
    "CandidateName" TEXT,
    "HRCD_Designation" VARCHAR,
    "EmployeeName" TEXT,
    "HRCIS_Datetime" TIMESTAMP,
    "HRCIS_InterviewFeedBack" TEXT,
    "HRCIS_Status" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SqlDynamic" TEXT;
BEGIN
    "SqlDynamic" := '
    SELECT DISTINCT 
        COALESCE("HRCD_FirstName", '''') || '' '' || COALESCE("HRCD_MiddleName", '''') || '' '' || COALESCE("HRCD_LastName", '''') AS "CandidateName",
        "HRCD_Designation",
        COALESCE("HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HRME_EmployeeMiddlename", '''') || '' '' || COALESCE("HRME_EmployeeLastName", '''') AS "EmployeeName",
        "HRCIS_Datetime",
        "HRCIS_InterviewFeedBack",
        "HRCIS_Status"
    FROM "HR_Candidate_Details" "HCD"
    LEFT JOIN "HR_Candidate_InterviewStatus" "HCI" ON "HCI"."HRCD_Id" = "HCD"."HRCD_Id"
    LEFT JOIN "HR_Candidate_Master_Grade" "HCMG" ON "HCMG"."HRCMG_Id" = "HCI"."HRCMG_Id"
    LEFT JOIN "IVRM_Staff_User_Login" "ISUL" ON "ISUL"."Id" = "IVRMUL_Id"
    LEFT JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ISUL"."Emp_Code"
    WHERE "HCD"."HRCD_Id" IN (' || "HRCD_Id" || ')';

    RETURN QUERY EXECUTE "SqlDynamic";
END;
$$;