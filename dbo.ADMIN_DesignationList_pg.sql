CREATE OR REPLACE FUNCTION "dbo"."ADMIN_DesignationList"(p_MI_Id bigint)
RETURNS TABLE(
    "HRMDES_Id" bigint,
    "MI_Id" bigint,
    "HRMDES_DesignationName" varchar,
    "MI_Name" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic text;
BEGIN
    RETURN QUERY
    SELECT 
        "HR_Master_Designation"."HRMDES_Id",
        "HR_Master_Designation"."MI_Id",
        "HR_Master_Designation"."HRMDES_DesignationName",
        "Master_Institution"."MI_Subdomain" as "MI_Name"
    FROM "HR_Master_Designation"
    INNER JOIN "Master_Institution" ON "Master_Institution"."MI_Id" = "HR_Master_Designation"."MI_Id"
    WHERE "HR_Master_Designation"."HRMDES_ActiveFlag" = 1 
    AND "HR_Master_Designation"."MI_Id" IN (
        SELECT "MI_Id" 
        FROM "Master_Institution" 
        WHERE "MI_ActiveFlag" = 1
    );
END;
$$;