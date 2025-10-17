CREATE OR REPLACE FUNCTION "dbo"."cm_usermappingdetails"()
RETURNS TABLE(
    "UserName" VARCHAR,
    "CMMCO_CounterName" VARCHAR,
    "CMCUMAP_ActiveFlg" BOOLEAN,
    "CMCUMAP_Id" INTEGER,
    "CMMCO_Id" INTEGER,
    "Id" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c."UserName",
        b."CMMCO_CounterName",
        a."CMCUMAP_ActiveFlg",
        a."CMCUMAP_Id",
        b."CMMCO_Id",
        c."Id"
    FROM "CM_Counter_UserMapping" a
    INNER JOIN "CM_Master_Counter" b ON b."CMMCO_Id" = a."CMMCO_Id"
    INNER JOIN "ApplicationUser" c ON c."Id" = a."Id";
END;
$$;