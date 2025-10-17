CREATE OR REPLACE FUNCTION "dbo"."AT_Location"(
    "MI_Id" BIGINT,
    "coyear" VARCHAR(50)
)
RETURNS TABLE(
    "INVMLO_Id" BIGINT,
    "INVMLO_LocationRoomName" TEXT,
    "INVMLO_InchargeName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "fromyear" VARCHAR(10);
    "Toyear" VARCHAR(10);
    "fromToYear" VARCHAR(20);
BEGIN
    SELECT split_part("coyear", '-', 2) INTO "Toyear";
    
    SELECT split_part("coyear", '-', 1) INTO "fromyear";
    
    SELECT "fromyear" || ',' || "Toyear" INTO "fromToYear";
    
    "Slqdymaic" := '
    SELECT DISTINCT a."INVMLO_Id", b."INVMLO_LocationRoomName", b."INVMLO_InchargeName"
    FROM "INV"."INV_Asset_CheckOut" a
    INNER JOIN "INV"."INV_Master_Location" b ON a."INVMLO_Id" = b."INVMLO_Id" AND a."MI_Id" = b."MI_Id"
    WHERE a."MI_Id" = ' || "MI_Id"::VARCHAR || ' AND a."INVACO_ActiveFlg" = true AND EXTRACT(YEAR FROM a."INVACO_CheckoutDate") IN (' || "fromToYear" || ')
    GROUP BY a."INVACO_Id", a."INVMLO_Id", b."INVMLO_LocationRoomName", b."INVMLO_InchargeName"
    ';
    
    RETURN QUERY EXECUTE "Slqdymaic";
END;
$$;