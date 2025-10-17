CREATE OR REPLACE FUNCTION "HR_leave_Overall_Report"(
    "@Status" VARCHAR(100),
    "@mi_id" BIGINT,
    "@fromdate" TIMESTAMP,
    "@todate" TIMESTAMP
)
RETURNS TABLE(
    "HRME_EmployeeFirstName" TEXT,
    "HRME_EmployeeCode" VARCHAR,
    "HRELT_FromDate" TIMESTAMP,
    "HRELT_ToDate" TIMESTAMP,
    "HRELT_Status" VARCHAR,
    "HRML_LeaveName" VARCHAR,
    "HRMD_DepartmentName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        CONCAT(COALESCE("a"."HRME_EmployeeFirstName", ''), ' ', COALESCE("a"."HRME_EmployeeMiddleName", ''), ' ', COALESCE("a"."HRME_EmployeeLastName", '')) AS "HRME_EmployeeFirstName",
        "a"."HRME_EmployeeCode",
        "b"."HRELT_FromDate",
        "b"."HRELT_ToDate",
        "b"."HRELT_Status",
        "c"."HRML_LeaveName",
        "d"."HRMD_DepartmentName"
    FROM "HR_Master_Employee" "a"
    INNER JOIN "HR_Emp_Leave_Trans" "b"
        ON "a"."MI_Id" = "b"."MI_Id" 
        AND "a"."HRME_Id" = "b"."HRME_Id" 
        AND "b"."HRELT_ActiveFlag" = 1
    INNER JOIN "HR_Master_Leave" "c" 
        ON "c"."MI_Id" = "b"."MI_Id" 
        AND "b"."HRELT_LeaveId" = "c"."HRML_Id"
    INNER JOIN "HR_Master_Department" "d" 
        ON "d"."HRMD_Id" = "a"."HRMD_Id"
    WHERE "b"."HRELT_Status" = "@Status" 
        AND "b"."MI_Id" = "@mi_id" 
        AND CAST("b"."HRELT_FromDate" AS DATE) >= CAST("@fromdate" AS DATE)
        AND CAST("b"."HRELT_ToDate" AS DATE) <= CAST("@todate" AS DATE);
END;
$$;