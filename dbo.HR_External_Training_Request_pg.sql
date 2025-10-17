CREATE OR REPLACE FUNCTION "dbo"."HR_External_Training_Request"(
    p_MI_Id bigint
)
RETURNS TABLE (
    "Employee_Name" text,
    "HRME_Id" bigint
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        (COALESCE("d"."HRME_EmployeeFirstName", '') || ' ' || 
         COALESCE("d"."HRME_EmployeeMiddleName", '') || ' ' || 
         COALESCE("d"."HRME_EmployeeLastName", '')) AS "Employee_Name",
        "a"."HRME_Id"
    FROM "dbo"."HR_External_Training" "a"
    INNER JOIN "dbo"."HR_Master_Employee" "d" ON "d"."HRME_Id" = "a"."HRME_Id"
    WHERE "a"."MI_Id" = p_MI_Id;
END;
$$;