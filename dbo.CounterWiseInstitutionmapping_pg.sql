CREATE OR REPLACE FUNCTION "CounterWiseInstitutionmapping"(p_CMCWM_Id bigint)
RETURNS TABLE(
    "CMMCO_Id" bigint,
    "CMMCO_CounterName" character varying,
    "MI_Name" character varying,
    "MI_Id" bigint,
    "CMCWM_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."CMMCO_Id",
        b."CMMCO_CounterName",
        c."MI_Name",
        c."MI_Id",
        a."CMCWM_Id"
    FROM "CM_CounterWiseInstitution_Mapping" a
    INNER JOIN "CM_Master_Counter" b ON b."CMMCO_Id" = a."CMMCO_Id"
    INNER JOIN "Master_Institution" c ON c."MI_Id" = a."MI_Id"
    WHERE a."CMCWM_Id" = p_CMCWM_Id;
END;
$$;