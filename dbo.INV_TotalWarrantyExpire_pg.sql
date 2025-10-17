CREATE OR REPLACE FUNCTION "dbo"."INV_TotalWarrantyExpire"(@MI_Id BIGINT)
RETURNS TABLE (
    "INVAAT_Id" BIGINT,
    "MI_Id" BIGINT,
    "INVAAT_AssetId" TEXT,
    "INVAAT_AssetDescription" TEXT,
    "INVAAT_ModelNo" TEXT,
    "INVAAT_SerialNo" TEXT,
    "INVAAT_WarantyExpiryDate" TIMESTAMP,
    "INVAAT_PurchaseDate" TIMESTAMP,
    "INVAAT_ActiveFlg" BOOLEAN,
    "INVAAT_CreatedBy" BIGINT,
    "INVAAT_UpdatedBy" BIGINT,
    "INVAAT_CreatedDate" TIMESTAMP,
    "INVAAT_UpdatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM "INV"."INV_Asset_AssetTag"
    WHERE "MI_Id" = @MI_Id 
        AND "INVAAT_ActiveFlg" = true 
        AND CAST("INVAAT_WarantyExpiryDate" AS DATE) <= CURRENT_DATE + INTERVAL '15 days';
END;
$$;