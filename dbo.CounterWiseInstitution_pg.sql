CREATE OR REPLACE FUNCTION "dbo"."CounterWiseInstitution"(p_CMMCO_Id bigint)
RETURNS TABLE(
    "MI_Id" bigint,
    "MI_Name" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN 
    RETURN QUERY
    SELECT c."MI_Id", c."MI_Name" 
    FROM "dbo"."CM_Master_Counter" a 
    INNER JOIN "dbo"."CM_CounterWiseInstitution_Mapping" b ON b."CMMCO_Id" = a."CMMCO_Id"
    INNER JOIN "dbo"."Master_Institution" c ON c."MI_Id" = b."MI_Id"
    WHERE a."CMMCO_Id" = p_CMMCO_Id;
END;
$$;