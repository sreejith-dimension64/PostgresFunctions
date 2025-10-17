CREATE OR REPLACE FUNCTION "dbo"."INTERVIEW_DETAILS"(
    "@ID" bigint
)
RETURNS TABLE (
    "HRCIS_InterviewFeedBack" TEXT,
    "HRCIS_Datetime" TIMESTAMP,
    "HRCIS_Status" VARCHAR,
    "HRME_EmployeeFirstName" TEXT,
    "HRCIS_CandidateStatus" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "B"."HRCIS_InterviewFeedBack",
        "B"."HRCIS_Datetime",
        "B"."HRCIS_Status",
        (COALESCE("D"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("D"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("D"."HRME_EmployeeLastName", '')) AS "HRME_EmployeeFirstName",
        "B"."HRCIS_CandidateStatus"
    FROM "HR_Candidate_InterviewSchedule" "A"
    JOIN "HR_Candidate_InterviewStatus" "B" ON "A"."HRCISC_Id" = "@ID" AND "A"."HRCD_Id" = "B"."HRCD_Id"
    JOIN "IVRM_Staff_User_Login" "C" ON "B"."IVRMUL_Id" = "C"."Id"
    JOIN "HR_MASTER_EMPLOYEE" "D" ON "D"."HRME_Id" = "C"."Emp_Code";
END;
$$;