CREATE OR REPLACE FUNCTION "dbo"."Employee_Detailse_Fetching" (
    p_MI_Id bigint, 
    p_HRME_Id bigint
)
RETURNS TABLE (
    "NAME" text,
    "EMP_CODE" character varying,
    "DEPARTMENT" character varying,
    "DESIGNATION" character varying
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (COALESCE("a"."HRME_EmployeeFirstName", '') || COALESCE("a"."HRME_EmployeeMiddleName", '') || COALESCE("a"."HRME_EmployeeLastName", '')) as "NAME",
        "a"."HRME_EmployeeCode" as "EMP_CODE",
        "b"."HRMD_DepartmentName" as "DEPARTMENT",
        "c"."HRMDES_DesignationName" as "DESIGNATION"
    FROM "HR_Master_Employee" "a"
    INNER JOIN "HR_Master_Department" "b" ON "b"."HRMD_Id" = "a"."HRMD_Id"
    INNER JOIN "HR_Master_Designation" "c" ON "c"."HRMDES_Id" = "a"."HRMDES_Id"
    WHERE "a"."MI_Id" = p_MI_Id AND "a"."HRME_Id" = p_HRME_Id;
END;
$$;