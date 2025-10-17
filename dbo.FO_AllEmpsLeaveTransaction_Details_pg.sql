CREATE OR REPLACE FUNCTION "dbo"."FO_AllEmpsLeaveTransaction_Details"(
    p_MI_Id TEXT,
    p_HRME_Ids TEXT
)
RETURNS TABLE(
    "MI_Id" INTEGER,
    "MI_Name" VARCHAR,
    "EmpName" TEXT,
    "EmployeeCode" VARCHAR,
    "LeaveType" VARCHAR,
    "LeaveCode" VARCHAR,
    "CreditedLeaves" NUMERIC,
    "ApprovedLeaves" NUMERIC,
    "BalanceLeaves" NUMERIC,
    "TotalDaysApplied" NUMERIC,
    "TotalDaysRejected" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Sqldynamic TEXT;
BEGIN

    v_Sqldynamic := '
SELECT DISTINCT "MI"."MI_Id", "MI"."MI_Name",
(COALESCE("HRME_EmployeeFirstName",'''') || '' '' || COALESCE("HRME_EmployeeMiddleName",'''') || '' '' || COALESCE("HRME_EmployeeLastName",'''')) AS "EmpName",
"HRME_EmployeeCode" AS "EmployeeCode",
"ML"."HRML_LeaveName" AS "LeaveType",
"HRML_LeaveCode" AS "LeaveCode",
"HRELS_TotalLeaves" AS "CreditedLeaves",
COALESCE(CASE
    WHEN "ML"."HRML_LeaveCode" IN (''COMPOFF'',''PL'') THEN 

(SELECT SUM("LT"."HRELT_TotDays") FROM "HR_Emp_Leave_Trans" "LT"
INNER JOIN "HR_Emp_Leave_Trans_Details" "LTD" ON "LT"."HRELT_Id" = "LTD"."HRELT_Id"
WHERE "LT"."HRME_Id" = "HME"."HRME_Id" AND "HRELTD_LWPFlag" = 0 AND "HRELT_Status" = ''Approved''
AND "LTD"."HRML_Id" = "ML"."HRML_Id")
ELSE
(SELECT SUM("LT"."HRELT_TotDays") FROM "HR_Emp_Leave_Trans" "LT"
INNER JOIN "HR_Emp_Leave_Trans_Details" "LTD" ON "LT"."HRELT_Id" = "LTD"."HRELT_Id"
WHERE "LT"."HRME_Id" = "HME"."HRME_Id" AND "LT"."HRMLY_Id" = "HMLY"."HRMLY_Id" AND "HRELTD_LWPFlag" = 0 AND "HRELT_Status" = ''Approved''
AND "LTD"."HRML_Id" = "ML"."HRML_Id")
END, 0) AS "ApprovedLeaves",
"HRELS_CBLeaves" AS "BalanceLeaves",

COALESCE(CASE
    WHEN "ML"."HRML_LeaveCode" IN (''COMPOFF'',''PL'') THEN 

(SELECT SUM("HRELAPD_TotalDays") FROM "HR_Emp_Leave_Application" "ELA"
LEFT JOIN "HR_Emp_Leave_Appl_Details" "ELAD" ON "ELAD"."HRELAP_Id" = "ELA"."HRELAP_Id"
WHERE "ELA"."HRME_Id" = "HME"."HRME_Id" AND "ELAD"."HRML_Id" = "ML"."HRML_Id" AND "HRELAPD_OutTime" IS NULL
AND "ELA"."HRELAP_ActiveFlag" = 1 AND "ELAD"."HRELAPD_ActiveFlag" = 1 AND "HRELAP_ApplicationStatus" = ''Approved'')
ELSE 
(SELECT SUM("HRELAPD_TotalDays") FROM "HR_Emp_Leave_Application" "ELA"
LEFT JOIN "HR_Emp_Leave_Appl_Details" "ELAD" ON "ELAD"."HRELAP_Id" = "ELA"."HRELAP_Id"
WHERE "ELA"."HRME_Id" = "HME"."HRME_Id" AND "ELAD"."HRML_Id" = "ML"."HRML_Id" AND "HRELAPD_OutTime" IS NULL
AND "ELA"."HRELAP_ActiveFlag" = 1 AND "ELAD"."HRELAPD_ActiveFlag" = 1 AND "HRELAP_ApplicationStatus" = ''Approved'' AND EXTRACT(YEAR FROM "ELA"."HRELAP_FromDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP))
END, 0) AS "TotalDaysApplied",

COALESCE((SELECT SUM("HRELAPD_TotalDays") FROM "HR_Emp_Leave_Application" "ELA"
LEFT JOIN "HR_Emp_Leave_Appl_Details" "ELAD" ON "ELAD"."HRELAP_Id" = "ELA"."HRELAP_Id"
WHERE "ELA"."HRME_Id" = "HME"."HRME_Id" AND "ELAD"."HRML_Id" = "ML"."HRML_Id" AND "HRELAPD_OutTime" IS NULL
AND "ELA"."HRELAP_ActiveFlag" = 1 AND "ELAD"."HRELAPD_ActiveFlag" = 1 AND EXTRACT(YEAR FROM "ELA"."HRELAP_FromDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP) - 1 AND "HRELAPD_LeaveStatus" = ''Rejected'' AND "HRELAPD_LeaveStatus" != ''Applied''), 0) AS "TotalDaysRejected"

FROM "HR_Master_Employee" "HME"
LEFT JOIN "HR_Emp_Leave_Status" "ELS" ON "ELS"."HRME_Id" = "HME"."HRME_Id"
LEFT JOIN "HR_Master_LeaveYear" "HMLY" ON "HMLY"."HRMLY_Id" = "ELS"."HRMLY_Id"
LEFT JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "HMLY"."MI_Id"
LEFT JOIN "HR_Master_Leave" "ML" ON "ML"."HRML_Id" = "ELS"."HRML_Id" AND "ML"."MI_Id" = "ELS"."MI_Id"
WHERE "HME"."MI_Id" IN (' || p_MI_Id || ') AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0 AND "HMLY"."HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP) - 1 AND "HME"."HRME_Id" IN (' || p_HRME_Ids || ')';

    RAISE NOTICE '%', v_Sqldynamic;

    RETURN QUERY EXECUTE v_Sqldynamic;

END;
$$;