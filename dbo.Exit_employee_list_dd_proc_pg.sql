CREATE OR REPLACE FUNCTION "dbo"."Exit_employee_list_dd_proc"(
    p_MI_Id bigint
)
RETURNS TABLE(
    employeename TEXT,
    "hrmE_Id" bigint
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        (COALESCE("HRME_EmployeeFirstName",'') || ' ' || COALESCE("HRME_EmployeeMiddleName",'') || ' ' || COALESCE("HRME_EmployeeLastName",'')) AS employeename, 
        "HRME_Id" AS "hrmE_Id" 
    FROM "HR_Master_Employee" 
    WHERE "HRME_Id" NOT IN (
        SELECT "HRME_Id" 
        FROM "ISM_Resignation" 
        WHERE "MI_Id" = p_MI_Id
    ) 
    AND "MI_Id" = p_MI_Id;
END;
$$;