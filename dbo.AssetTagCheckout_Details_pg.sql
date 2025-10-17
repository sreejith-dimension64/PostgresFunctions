CREATE OR REPLACE FUNCTION "dbo"."AssetTagCheckout_Details"(
    "MI_Id" BIGINT,
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "ID" BIGINT,
    "Name" TEXT,
    "Code" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF ("optionflag" = 'Item') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMI_Id",
            a."INVMI_ItemName"::TEXT,
            a."INVMI_ItemCode"::TEXT
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_AssetTag_CheckOut" b ON a."INVMI_Id" = b."INVMI_Id"
        WHERE b."INVATCO_ActiveFlg" = 1 
            AND a."INVMI_Id" = b."INVMI_Id" 
            AND a."MI_Id" = b."MI_Id" 
            AND a."MI_Id" = "MI_Id"
        ORDER BY a."INVMI_ItemName";

    ELSIF ("optionflag" = 'Store') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMST_Id",
            b."INVMS_StoreName"::TEXT,
            NULL::TEXT
        FROM "INV"."INV_AssetTag_CheckOut" a
        INNER JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."INVATCO_ActiveFlg" = 1 
            AND a."MI_Id" = "MI_Id"
        ORDER BY b."INVMS_StoreName";

    ELSIF ("optionflag" = 'Location') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMLO_Id",
            b."INVMLO_LocationRoomName"::TEXT,
            NULL::TEXT
        FROM "INV"."INV_Asset_CheckOut" a
        INNER JOIN "INV"."INV_Master_Location" b ON a."INVMLO_Id" = b."INVMLO_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."INVACO_ActiveFlg" = 1 
            AND a."MI_Id" = "MI_Id"
        ORDER BY b."INVMLO_LocationRoomName";

    END IF;

    RETURN;

END;
$$;