CREATE OR REPLACE FUNCTION "HR_EmployeeDetialsMultiple"(
    p_HRME_ID TEXT
)
RETURNS SETOF "hr_master_employee"
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    v_query := 'SELECT * FROM "hr_master_employee" WHERE "HRME_Id" IN (' || p_HRME_ID || ')';
    
    RETURN QUERY EXECUTE v_query;
END;
$$;