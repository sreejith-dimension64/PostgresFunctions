CREATE OR REPLACE FUNCTION "dbo"."AssetTagDispose_Details"(
    p_MI_Id BIGINT,
    p_optionflag VARCHAR(50)
)
RETURNS TABLE(
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVMI_ItemCode" TEXT,
    "INVMST_Id" BIGINT,
    "INVMS_StoreName" TEXT,
    "INVMLO_Id" BIGINT,
    "INVMLO_LocationRoomName" TEXT,
    "INVAAT_Id" BIGINT,
    "INVAAT_AssetId" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_optionflag = 'Item') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode",
            NULL::BIGINT AS "INVMST_Id",
            NULL::TEXT AS "INVMS_StoreName",
            NULL::BIGINT AS "INVMLO_Id",
            NULL::TEXT AS "INVMLO_LocationRoomName",
            NULL::BIGINT AS "INVAAT_Id",
            NULL::TEXT AS "INVAAT_AssetId"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_AssetTag_Dispose" b ON a."INVMI_Id" = b."INVMI_Id"
        WHERE b."INVATDI_ActiveFlg" = 1 
            AND a."INVMI_Id" = b."INVMI_Id" 
            AND a."MI_Id" = b."MI_Id" 
            AND a."MI_Id" = p_MI_Id
        ORDER BY a."INVMI_ItemName";

    ELSIF (p_optionflag = 'Store') THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            a."INVMST_Id",
            b."INVMS_StoreName",
            NULL::BIGINT AS "INVMLO_Id",
            NULL::TEXT AS "INVMLO_LocationRoomName",
            NULL::BIGINT AS "INVAAT_Id",
            NULL::TEXT AS "INVAAT_AssetId"
        FROM "INV"."INV_AssetTag_Dispose" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."INVATDI_ActiveFlg" = 1 
            AND a."MI_Id" = p_MI_Id
        ORDER BY b."INVMS_StoreName";

    ELSIF (p_optionflag = 'Location') THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            NULL::BIGINT AS "INVMST_Id",
            NULL::TEXT AS "INVMS_StoreName",
            a."INVMLO_Id",
            b."INVMLO_LocationRoomName",
            NULL::BIGINT AS "INVAAT_Id",
            NULL::TEXT AS "INVAAT_AssetId"
        FROM "INV"."INV_AssetTag_Dispose" a
        INNER JOIN "INV"."INV_Master_Location" b ON a."INVMLO_Id" = b."INVMLO_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."INVATDI_ActiveFlg" = 1 
            AND a."MI_Id" = p_MI_Id
        ORDER BY b."INVMLO_LocationRoomName";

    ELSIF (p_optionflag = 'Tag') THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            NULL::BIGINT AS "INVMST_Id",
            NULL::TEXT AS "INVMS_StoreName",
            NULL::BIGINT AS "INVMLO_Id",
            NULL::TEXT AS "INVMLO_LocationRoomName",
            a."INVAAT_Id",
            b."INVAAT_AssetId"
        FROM "INV"."INV_AssetTag_Dispose" a
        INNER JOIN "INV"."INV_Asset_AssetTag" b ON a."INVAAT_Id" = b."INVAAT_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."INVATDI_ActiveFlg" = 1 
            AND a."MI_Id" = p_MI_Id
        ORDER BY a."INVAAT_Id";

    END IF;

    RETURN;

END;
$$;