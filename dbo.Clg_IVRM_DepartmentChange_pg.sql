CREATE OR REPLACE FUNCTION "Clg_IVRM_DepartmentChange"(
    p_departments VARCHAR,
    p_MI_Id bigint
)
RETURNS TABLE (
    "HRMDES_Id" bigint,
    "MI_Id" bigint,
    "HRMDES_DesignationName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
BEGIN
    v_Slqdymaic := '
    SELECT DISTINCT a."HRMDES_Id", a."MI_Id", a."HRMDES_DesignationName" 
    FROM "HR_Master_Designation" a 
    LEFT JOIN "HR_Master_Employee" b ON a."HRMDES_Id" = b."HRMDES_Id"
    WHERE a."HRMDES_ActiveFlag" = 1
    AND b."HRMD_Id" IN (' || p_departments || ') 
    AND a."MI_Id" = ' || p_MI_Id::VARCHAR;

    RETURN QUERY EXECUTE v_Slqdymaic;
END;
$$;