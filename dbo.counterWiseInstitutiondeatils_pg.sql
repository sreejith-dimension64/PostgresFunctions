CREATE OR REPLACE FUNCTION "dbo"."counterWiseInstitutiondeatils"()
RETURNS TABLE (
    "CMCWM_Id" INTEGER,
    "CMMCO_CounterName" VARCHAR,
    "MI_Name" VARCHAR,
    "CMCWM_ActiveFlag" BOOLEAN,
    "CMMCO_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."CMCWM_Id",
        a."CMMCO_CounterName",
        c."MI_Name",
        b."CMCWM_ActiveFlag",
        a."CMMCO_Id"
    FROM "CM_Master_Counter" a
    INNER JOIN "CM_CounterWiseInstitution_Mapping" b ON b."CMMCO_Id" = a."CMMCO_Id"
    INNER JOIN "Master_Institution" c ON c."MI_Id" = b."MI_Id";
END;
$$;