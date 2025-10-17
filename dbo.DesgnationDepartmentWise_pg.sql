CREATE OR REPLACE FUNCTION "DesgnationDepartmentWise"(p_mi_id bigint)
RETURNS TABLE (
    "HRMDES_Id" bigint,
    "HRMDES_DesignationName" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "HRMDES_Id", "HRMDES_DesignationName" 
    FROM "HR_Master_Designation" 
    WHERE "MI_Id" = p_mi_id;
END;
$$;