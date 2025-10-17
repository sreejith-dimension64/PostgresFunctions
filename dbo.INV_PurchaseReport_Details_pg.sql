CREATE OR REPLACE FUNCTION "dbo"."INV_PurchaseReport_Details"(
    "MI_Id" VARCHAR(50),
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVMI_ItemCode" TEXT,
    "INVMS_Id" BIGINT,
    "INVMS_SupplierName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlexec" TEXT;
BEGIN
    IF ("optionflag" = 'Item') THEN
        "sqlexec" := '
            SELECT DISTINCT a."INVMI_Id", a."INVMI_ItemName", a."INVMI_ItemCode",
            NULL::BIGINT AS "INVMS_Id", NULL::TEXT AS "INVMS_SupplierName"
            FROM "INV"."INV_Master_Item" a,
            "INV"."INV_M_PurchaseOrder" b,
            "INV"."INV_T_PurchaseOrder" c
            WHERE a."INVMI_Id" = c."INVMI_Id" 
            AND b."INVMPO_Id" = c."INVMPO_Id" 
            AND a."MI_Id" IN (' || "MI_Id" || ')
            ORDER BY a."INVMI_ItemName"';
        
        RETURN QUERY EXECUTE "sqlexec";
        
    ELSIF ("optionflag" = 'Supplier') THEN
        "sqlexec" := '
            SELECT NULL::BIGINT AS "INVMI_Id", NULL::TEXT AS "INVMI_ItemName", NULL::TEXT AS "INVMI_ItemCode",
            DISTINCT a."INVMS_Id", b."INVMS_SupplierName"
            FROM "INV"."INV_M_PurchaseOrder" a
            INNER JOIN "INV"."INV_Master_Supplier" b ON a."INVMS_Id" = b."INVMS_Id" AND a."MI_Id" = b."MI_Id"
            WHERE a."MI_Id" IN (' || "MI_Id" || ') AND "INVMPO_ActiveFlg" = 1
            ORDER BY b."INVMS_SupplierName"';
        
        RETURN QUERY EXECUTE "sqlexec";
    END IF;
    
    RETURN;
END;
$$;