CREATE OR REPLACE FUNCTION "dbo"."AT_LocationDetail"(
    "MI_Id" BIGINT,
    "INVMLO_Id" VARCHAR(100)
)
RETURNS TABLE(
    "INVMLO_Id" BIGINT,
    "INVMLO_LocationRoomName" VARCHAR,
    "INVMLO_InchargeName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "dynamic" TEXT;
BEGIN
    "dynamic" := 'SELECT DISTINCT a."INVMLO_Id", b."INVMLO_LocationRoomName", b."INVMLO_InchargeName" ' ||
                 'FROM "INV"."INV_Asset_CheckOut" a ' ||
                 'INNER JOIN "INV"."INV_Master_Location" b ON a."INVMLO_Id" = b."INVMLO_Id" AND a."MI_Id" = b."MI_Id" ' ||
                 'WHERE a."MI_Id" = ' || "MI_Id"::VARCHAR || ' AND a."INVACO_ActiveFlg" = 1 AND a."INVMLO_Id" IN (' || "INVMLO_Id" || ') ' ||
                 'GROUP BY a."INVACO_Id", a."INVMLO_Id", b."INVMLO_LocationRoomName", b."INVMLO_InchargeName"';
    
    RETURN QUERY EXECUTE "dynamic";
END;
$$;