CREATE OR REPLACE FUNCTION "dbo"."AssetTagTransferItemData"(
    p_MI_Id bigint,
    p_INVMLO_Id bigint,
    p_INVMI_Id bigint
)
RETURNS TABLE(
    "INVATCO_Id" bigint,
    "INVAAT_Id" bigint,
    "INVMI_Id" bigint,
    "INVMLO_Id" bigint,
    "INVMLO_LocationRoomName" varchar,
    "INVMI_ItemName" varchar,
    "INVAAT_AssetId" varchar,
    "INVAAT_AssetDescription" varchar,
    "INVAAT_ModelNo" varchar,
    "INVAAT_SerialNo" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."INVATCO_Id", 
        a."INVAAT_Id", 
        a."INVMI_Id", 
        a."INVMLO_Id", 
        e."INVMLO_LocationRoomName", 
        d."INVMI_ItemName", 
        b."INVAAT_AssetId",
        b."INVAAT_AssetDescription", 
        b."INVAAT_ModelNo", 
        b."INVAAT_SerialNo"
    FROM "INV"."INV_AssetTag_CheckOut" AS a
    CROSS JOIN "INV"."INV_Asset_AssetTag" AS b
    CROSS JOIN "INV"."INV_Master_Item" AS d
    CROSS JOIN "INV"."INV_Master_Location" AS e
    WHERE a."INVAAT_Id" = b."INVAAT_Id" 
        AND a."INVMI_Id" = d."INVMI_Id" 
        AND a."INVMLO_Id" = e."INVMLO_Id"
        AND a."INVATCO_CheckInFlg" = 0 
        AND a."MI_Id" = b."MI_Id" 
        AND a."INVATCO_ActiveFlg" = 1
        AND a."MI_Id" = p_MI_Id 
        AND a."INVMLO_Id" = p_INVMLO_Id 
        AND a."INVMI_Id" = p_INVMI_Id
        AND a."INVAAT_Id" NOT IN (
            SELECT "INVAAT_Id" 
            FROM "INV"."INV_AssetTag_Transfer"
        );
END;
$$;