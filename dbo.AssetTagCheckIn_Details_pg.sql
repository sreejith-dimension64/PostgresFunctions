CREATE OR REPLACE FUNCTION "INV"."AssetTagCheckIn_Details"(
    "MI_Id" BIGINT,
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVMI_ItemCode" TEXT,
    "INVMST_Id" BIGINT,
    "INVMS_StoreName" TEXT,
    "INVMLO_Id" BIGINT,
    "INVMLO_LocationRoomName" TEXT
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
            NULL::BIGINT AS "INVMST_Id",
            NULL::TEXT AS "INVMS_StoreName",
            NULL::BIGINT AS "INVMLO_Id",
            NULL::TEXT AS "INVMLO_LocationRoomName"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_AssetTag_CheckIn" b ON a."INVMI_Id" = b."INVMI_Id"
        WHERE b."INVATCI_ActiveFlg" = 1 
            AND a."INVMI_Id" = b."INVMI_Id" 
            AND a."MI_Id" = b."MI_Id" 
            AND a."MI_Id" = "MI_Id"
        ORDER BY a."INVMI_ItemName";

    ELSIF ("optionflag" = 'Store') THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            a."INVMST_Id",
            b."INVMS_StoreName",
            NULL::BIGINT AS "INVMLO_Id",
            NULL::TEXT AS "INVMLO_LocationRoomName"
        FROM "INV"."INV_AssetTag_CheckIn" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."INVATCI_ActiveFlg" = 1 
            AND a."MI_Id" = "MI_Id"
        ORDER BY b."INVMS_StoreName";

    ELSIF ("optionflag" = 'Location') THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            NULL::BIGINT AS "INVMST_Id",
            NULL::TEXT AS "INVMS_StoreName",
            a."INVMLO_Id",
            b."INVMLO_LocationRoomName"
        FROM "INV"."INV_AssetTag_CheckIn" a
        INNER JOIN "INV"."INV_Master_Location" b ON a."INVMLO_Id" = b."INVMLO_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."INVATCI_ActiveFlg" = 1 
            AND a."MI_Id" = "MI_Id"
        ORDER BY b."INVMLO_LocationRoomName";

    END IF;

    RETURN;

END;
$$;