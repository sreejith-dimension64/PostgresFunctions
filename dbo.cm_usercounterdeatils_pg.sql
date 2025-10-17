CREATE OR REPLACE FUNCTION cm_usercounterdeatils(p_Id bigint)
RETURNS TABLE(
    "CMMCO_Id" bigint,
    "CMMCO_CounterName" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT b."CMMCO_Id", b."CMMCO_CounterName" 
    FROM "CM_Counter_UserMapping" a 
    INNER JOIN "CM_Master_Counter" b ON b."CMMCO_Id" = a."CMMCO_Id"
    WHERE a."Id" = p_Id;
END;
$$;