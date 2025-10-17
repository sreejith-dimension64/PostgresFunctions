CREATE OR REPLACE FUNCTION "dbo"."AssetTagSMSNotification_proc"()
RETURNS TABLE(
    "INVMI_ItemName" VARCHAR(100),
    "INVMS_ContactNo" VARCHAR(20),
    "INVAAT_WarantyExpiryDate" DATE,
    "count_date" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS temp_asset_tag;
    
    CREATE TEMP TABLE temp_asset_tag(
        "INVMI_ItemName" VARCHAR(100),
        "INVMS_ContactNo" VARCHAR(20),
        "INVAAT_WarantyExpiryDate" DATE,
        "count_date" BIGINT
    );

    INSERT INTO temp_asset_tag ("INVMI_ItemName", "INVMS_ContactNo", "INVAAT_WarantyExpiryDate", "count_date")
    SELECT 
        c."INVMI_ItemName" AS "INVMI_ItemName",
        b."INVMS_ContactNo" AS "INVMS_ContactNo",
        a."INVAAT_WarantyExpiryDate" AS "INVAAT_WarantyExpiryDate",
        (a."INVAAT_WarantyExpiryDate" - CURRENT_DATE) AS "count_date"
    FROM 
        "inv"."INV_Asset_AssetTag" a,
        "inv"."INV_Master_Store" b,
        "inv"."INV_Master_Item" c
    WHERE 
        a."INVMST_Id" = b."INVMST_Id" 
        AND a."INVMI_Id" = c."INVMI_Id" 
        AND a."MI_Id" = b."MI_Id";

    RETURN QUERY
    SELECT 
        t."INVMI_ItemName",
        t."INVMS_ContactNo",
        t."INVAAT_WarantyExpiryDate",
        t."count_date"
    FROM temp_asset_tag t
    WHERE t."count_date" IN (1, 2, 3, 4, 5, 8);
END;
$$;