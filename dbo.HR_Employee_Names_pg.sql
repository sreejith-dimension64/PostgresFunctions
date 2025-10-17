CREATE OR REPLACE FUNCTION "HR_Employee_Names" ("MI_Id" TEXT)
RETURNS TABLE (
    "EmployeeName" TEXT,
    "HRME_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE("HRME_EmployeeFirstName", '') || ' ' ||
        COALESCE("HRME_EmployeeMiddName", '') || ' ' ||
        COALESCE("HRME_EmployeeLastName", '') AS "EmployeeName",
        "HRME_Id"
    FROM "HR_Master_Employee"
    WHERE "mi_id" = "MI_Id" 
        AND "HRME_ActiveFlag" = TRUE 
        AND "HRME_LeftFlag" = FALSE;
END;
$$;