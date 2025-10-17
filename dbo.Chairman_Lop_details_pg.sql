CREATE OR REPLACE FUNCTION "dbo"."Chairman_Lop_details"(
    p_MI_Id INT,
    p_HRMLY_Id INT,
    p_MONTH VARCHAR(50)
)
RETURNS TABLE (
    name TEXT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "HRELTD_TotDays" NUMERIC,
    "HRELTD_FromDate" TIMESTAMP,
    "HRELTD_ToDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (REPLACE(REPLACE(REPLACE(COALESCE("B"."HRME_EmployeeFirstName",''),'.',''),'$',''),'0','') || ' ' || 
         REPLACE(REPLACE(REPLACE(COALESCE("B"."HRME_EmployeeMiddleName",''),'.',''),'$',''),'0','') || ' ' || 
         REPLACE(REPLACE(REPLACE(COALESCE("B"."HRME_EmployeeLastName",''),'.',''),'$',''),'0',''))::TEXT AS name,
        "D"."HRMD_DepartmentName",
        "C"."HRMDES_DesignationName",
        "A"."HRELTD_TotDays",
        "A"."HRELTD_FromDate",
        "A"."HRELTD_ToDate"
    FROM "HR_Emp_Leave_Trans_Details" AS "A"
    INNER JOIN "hr_master_employee" AS "B" ON "A"."HRME_Id" = "B"."HRME_Id" AND "A"."MI_Id" = "B"."MI_Id"
    INNER JOIN "hr_master_designation" AS "C" ON "B"."HRMDES_Id" = "C"."HRMDES_Id"
    INNER JOIN "HR_Master_Department" AS "D" ON "B"."HRMD_Id" = "D"."HRMD_Id"
    INNER JOIN "HR_Emp_Leave_Trans" AS "E" ON "E"."HRELT_Id" = "A"."HRELT_Id" AND "A"."MI_Id" = "E"."MI_Id"
    INNER JOIN "HR_Master_Leave" AS "F" ON "A"."HRML_Id" = "F"."HRML_Id" AND "F"."MI_Id" = "A"."MI_Id"
    WHERE "A"."MI_Id" = 5 
        AND "A"."HRELTD_LWPFlag" = 1 
        AND "E"."HRMLY_Id" = 1 
        AND TO_CHAR("E"."HRELT_FromDate", 'Month') = p_MONTH
        AND "F"."HRML_LeaveCode" = 'LWP';
END;
$$;