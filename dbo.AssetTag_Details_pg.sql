CREATE OR REPLACE FUNCTION "dbo"."AssetTag_Details"(
    "MI_Id" BIGINT,
    "optionflag" VARCHAR(50)
)
RETURNS TABLE(
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVMI_ItemCode" TEXT,
    "INVMST_Id" BIGINT,
    "INVMS_StoreName" TEXT
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
            NULL::TEXT AS "INVMS_StoreName"
        FROM "INV"."INV_Master_Item" a,
             "INV"."INV_Asset_AssetTag" b
        WHERE a."INVMI_Id" = b."INVMI_Id" 
            AND b."INVAAT_Id" = b."INVAAT_Id" 
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
            b."INVMS_StoreName"
        FROM "INV"."INV_Asset_AssetTag" a
        INNER JOIN "INV"."INV_Master_Store" b 
            ON a."INVMST_Id" = b."INVMST_Id" 
            AND a."MI_Id" = b."MI_Id"
        WHERE a."INVAAT_ActiveFlg" = 1 
            AND a."MI_Id" = "MI_Id"
        ORDER BY b."INVMS_StoreName";
        
    END IF;

END;
$$;