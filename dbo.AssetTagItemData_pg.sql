CREATE OR REPLACE FUNCTION "dbo"."AssetTagItemData"(
    p_MI_Id bigint,
    p_INVMST_Id bigint,
    p_INVMI_Id bigint
)
RETURNS TABLE(
    "INVAAT_Id" bigint,
    "INVMST_Id" bigint,
    "INVMI_Id" bigint,
    "INVMS_StoreName" varchar,
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
        a."INVAAT_Id", 
        a."INVMST_Id",
        a."INVMI_Id",
        b."INVMS_StoreName",
        c."INVMI_ItemName", 
        a."INVAAT_AssetId",
        a."INVAAT_AssetDescription",
        a."INVAAT_ModelNo",
        a."INVAAT_SerialNo"
    FROM "INV"."INV_Asset_AssetTag" a
    LEFT JOIN "INV"."INV_Master_Store" b ON a."INVMST_Id" = b."INVMST_Id" 
    LEFT JOIN "INV"."INV_Master_Item" c ON a."INVMI_Id" = c."INVMI_Id"
    WHERE a."INVAAT_ActiveFlg" = 1 
        AND a."INVAAT_CheckOutFlg" = 0 
        AND a."INVAAT_DisposedFlg" = 0 
        AND a."MI_Id" = p_MI_Id 
        AND b."INVMST_Id" = p_INVMST_Id 
        AND a."INVMI_Id" = p_INVMI_Id
        AND a."INVAAT_Id" NOT IN (
            SELECT "INVAAT_Id" 
            FROM "INV"."INV_AssetTag_CheckOut"
        );
END;
$$;