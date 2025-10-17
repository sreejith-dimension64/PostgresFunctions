CREATE OR REPLACE FUNCTION "dbo"."EmpWiseLeavesDetails"(
    p_HRME_Id TEXT
)
RETURNS TABLE(
    "EmpName" TEXT,
    "EmpLeaveType" VARCHAR,
    "EmpCreatedLeaves" NUMERIC,
    "EmpUsedLeaves1" NUMERIC,
    "EmpBalanceLeaves" NUMERIC,
    "EmpUsedLeaves" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlDynamic TEXT;
BEGIN
    v_sqlDynamic := '
    SELECT COALESCE("HME"."HRME_EmployeeFirstName",'''') || '' '' || COALESCE("HME"."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE("HME"."HRME_EmployeeLastName",'''') AS "EmpName",
    "HML"."HRML_LeaveName" AS "EmpLeaveType",
    "HRELS_CreditedLeaves" AS "EmpCreatedLeaves",
    "HRELS_TransLeaves" AS "EmpUsedLeaves1",
    "HRELS_CBLeaves" AS "EmpBalanceLeaves",
    ("HRELS_CreditedLeaves" - "HRELS_CBLeaves") AS "EmpUsedLeaves"
    FROM "HR_Emp_Leave_Status" "HELS"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "HELS"."HRME_Id"
    INNER JOIN "HR_Master_Leave" "HML" ON "HML"."MI_Id" = "HME"."MI_Id" AND "HML"."HRML_Id" = "HELS"."HRML_Id"
    INNER JOIN "HR_Master_LeaveYear" "HMLY" ON "HMLY"."HRMLY_Id" = "HELS"."HRMLY_Id"
    WHERE "HELS"."HRME_Id" IN (' || p_HRME_Id || ') AND "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)';
    
    RETURN QUERY EXECUTE v_sqlDynamic;
END;
$$;