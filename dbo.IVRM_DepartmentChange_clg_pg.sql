CREATE OR REPLACE FUNCTION "dbo"."IVRM_DepartmentChange_clg"(
    "departments" TEXT,
    "MI_Id" bigint
)
RETURNS TABLE(
    "HRMDES_Id" bigint,
    "HRMDES_DesignationName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    "Slqdymaic" := '
    SELECT DISTINCT a."HRMDES_Id", a."HRMDES_DesignationName" 
    FROM "HR_Master_Designation" a 
    LEFT JOIN "HR_Master_Employee" b ON a."HRMDES_Id" = b."HRMDES_Id" 
    WHERE a."HRMDES_ActiveFlag" = 1  
    AND b."HRMD_Id" IN (' || "departments" || ') 
    AND a."MI_Id" = ' || "MI_Id"::TEXT;

    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;