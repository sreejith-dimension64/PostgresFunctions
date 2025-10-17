CREATE OR REPLACE FUNCTION "dbo"."Assets_get_employee_proc"(
    "@MI_Id" bigint
)
RETURNS TABLE(
    mi_id bigint,
    employeename text,
    "hrmeE_EmployeeCode" text,
    "hrmE_id" bigint,
    "E_EmployeeOrder" integer
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        "HR_Master_Employee"."mi_id",
        (COALESCE("HRME_EmployeeFirstName", '') || COALESCE("HRME_EmployeeMiddleName", '') || COALESCE("HRME_EmployeeLastName", '')) AS employeename,
        "HRME_EmployeeCode" AS "hrmeE_EmployeeCode",
        "HRME_Id" AS "hrmE_id",
        "HRME_EmployeeOrder" AS "E_EmployeeOrder"
    FROM "HR_Master_Employee"
    WHERE "HRME_ActiveFlag" = 0 
        AND "HRME_LeftFlag" = 0 
        AND "MI_Id" IN (17, 16, 20, 21, 22, 23, 24)
    ORDER BY "HR_Master_Employee"."MI_Id";

END;
$$;