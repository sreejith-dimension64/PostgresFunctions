CREATE OR REPLACE FUNCTION "dbo"."INV_TotalWarrantyExpired"(
    "MI_Id" BIGINT
)
RETURNS TABLE (
    "INVAAT_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMS_StoreName" TEXT,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVAAT_AssetId" TEXT,
    "INVAAT_AssetDescription" TEXT,
    "INVAAT_ManufacturedDate" TIMESTAMP,
    "INVAAT_SKU" TEXT,
    "INVAAT_ModelNo" TEXT,
    "INVAAT_SerialNo" TEXT,
    "INVAAT_PurchaseDate" TIMESTAMP,
    "INVAAT_WarantyPeriod" TEXT,
    "INVAAT_WarantyExpiryDate" TIMESTAMP,
    "INVAAT_UnderAMCFlg" BOOLEAN,
    "INVAAT_AMCExpiryDate" TIMESTAMP,
    "INVAAT_CheckOutFlg" BOOLEAN,
    "INVAAT_DisposedFlg" BOOLEAN,
    "INVAAT_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT a."INVAAT_Id", a."INVMST_Id", c."INVMS_StoreName", a."INVMI_Id", d."INVMI_ItemName", a."INVAAT_AssetId", a."INVAAT_AssetDescription", a."INVAAT_ManufacturedDate",
    a."INVAAT_SKU", a."INVAAT_ModelNo", a."INVAAT_SerialNo", a."INVAAT_PurchaseDate", a."INVAAT_WarantyPeriod", a."INVAAT_WarantyExpiryDate", a."INVAAT_UnderAMCFlg", a."INVAAT_AMCExpiryDate",
    a."INVAAT_CheckOutFlg", a."INVAAT_DisposedFlg", a."INVAAT_ActiveFlg"
    FROM "INV"."INV_Asset_AssetTag" a
    INNER JOIN "INV"."INV_Stock" b ON a."INVMI_Id" = b."INVMI_Id" AND a."MI_Id" = b."MI_Id" AND a."INVAAT_ActiveFlg" = TRUE
    INNER JOIN "INV"."INV_Master_Store" c ON a."INVMST_Id" = c."INVMST_Id" AND c."INVMST_Id" = b."INVMST_Id" AND c."INVMS_ActiveFlg" = TRUE
    INNER JOIN "INV"."INV_Master_Item" d ON a."INVMI_Id" = b."INVMI_Id" AND b."INVMI_Id" = d."INVMI_Id" AND d."INVMI_ActiveFlg" = TRUE
    WHERE a."MI_Id" = "MI_Id" AND (a."INVAAT_WarantyExpiryDate") <= (CURRENT_TIMESTAMP);
END;
$$;