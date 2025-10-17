CREATE OR REPLACE FUNCTION "dbo"."AssetTagTransfer_Details"(
    "MI_Id" BIGINT,
    "optionflag" VARCHAR(50)
)
RETURNS TABLE(
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVMI_ItemCode" TEXT,
    "INVMLO_Id" BIGINT,
    "INVMLO_LocationRoomName" TEXT,
    "INVAAT_Id" BIGINT,
    "INVAAT_AssetId" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF ("optionflag" = 'Item') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode",
            NULL::BIGINT AS "INVMLO_Id",
            NULL::TEXT AS "INVMLO_LocationRoomName",
            NULL::BIGINT AS "INVAAT_Id",
            NULL::TEXT AS "INVAAT_AssetId"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_AssetTag_Transfer" b ON a."INVMI_Id" = b."INVMI_Id"
        WHERE b."INVATTR_ActiveFlg" = true 
            AND a."INVMI_Id" = b."INVMI_Id" 
            AND a."MI_Id" = b."MI_Id" 
            AND a."MI_Id" = "MI_Id"
        ORDER BY a."INVMI_ItemName";

    ELSIF ("optionflag" = 'Location') THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            b."INVMLO_Id",
            b."INVMLO_LocationRoomName",
            NULL::BIGINT AS "INVAAT_Id",
            NULL::TEXT AS "INVAAT_AssetId"
        FROM "INV"."INV_AssetTag_Transfer" a
        INNER JOIN "INV"."INV_Master_Location" b ON (a."INVMLOFrom_Id" = b."INVMLO_Id" OR a."INVMLOTo_Id" = b."INVMLO_Id") 
            AND a."MI_Id" = b."MI_Id"
        WHERE a."INVATTR_ActiveFlg" = true 
            AND a."MI_Id" = "MI_Id"
        ORDER BY b."INVMLO_LocationRoomName";

    ELSIF ("optionflag" = 'Tag') THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            NULL::BIGINT AS "INVMLO_Id",
            NULL::TEXT AS "INVMLO_LocationRoomName",
            a."INVAAT_Id",
            b."INVAAT_AssetId"
        FROM "INV"."INV_AssetTag_Transfer" a
        INNER JOIN "INV"."INV_Asset_AssetTag" b ON a."INVAAT_Id" = b."INVAAT_Id" 
            AND a."MI_Id" = b."MI_Id"
        WHERE a."INVATTR_ActiveFlg" = true 
            AND a."MI_Id" = "MI_Id"
        ORDER BY a."INVAAT_Id";

    END IF;

    RETURN;

END;
$$;