CREATE OR REPLACE FUNCTION "dbo"."ISM_DepartmentChange"(
    p_departments VARCHAR
)
RETURNS TABLE(
    "HRMDES_Id" INTEGER,
    "MI_Id" INTEGER,
    "HRMDES_DesignationName" VARCHAR,
    "MI_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SqlDynamic TEXT;
BEGIN
    v_SqlDynamic := '
    SELECT "HRMDES_Id", "HR_Master_Designation"."MI_Id", "HRMDES_DesignationName", "MI_Subdomain" AS "MI_Name" 
    FROM "HR_Master_Designation" 
    INNER JOIN "Master_Institution" ON "Master_Institution"."MI_Id" = "HR_Master_Designation"."MI_Id" 
    WHERE "HRMDES_ActiveFlag" = 1 
    AND "HR_Master_Designation"."MI_Id" IN (
        SELECT "MI_Id" 
        FROM "Master_Institution" 
        WHERE "MI_ActiveFlag" = 1
    )
    AND "HRMDC_ID" IN (' || p_departments || ')';

    RETURN QUERY EXECUTE v_SqlDynamic;
END;
$$;