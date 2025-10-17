CREATE OR REPLACE FUNCTION "dbo"."INV_Inward_Details"(
    "MI_Id" VARCHAR(50),
    "optionflag" VARCHAR(50)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlexec" TEXT;
BEGIN
    IF ("optionflag" = 'Item') THEN
        "sqlexec" := '
        SELECT DISTINCT a."INVMI_Id", a."INVMI_ItemName", a."INVMI_ItemCode"
        FROM "INV"."INV_Master_Item" a,
        "INV"."INV_M_PurchaseOrder" b,
        "INV"."INV_T_PurchaseOrder" c
        WHERE a."INVMI_Id" = c."INVMI_Id" AND b."INVMPO_Id" = c."INVMPO_Id" AND a."MI_Id" IN(' || "MI_Id" || ')
        ORDER BY a."INVMI_ItemName"';
        
        RETURN QUERY EXECUTE "sqlexec";
        
    ELSIF ("optionflag" = 'Supplier') THEN
        "sqlexec" := '
        SELECT DISTINCT a."INVMS_Id", b."INVMS_SupplierName"
        FROM "INV"."INV_M_PurchaseOrder" a
        INNER JOIN "INV"."INV_Master_Supplier" b ON a."INVMS_Id" = b."INVMS_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."MI_Id" IN(' || "MI_Id" || ') AND "INVMPO_ActiveFlg" = 1
        ORDER BY b."INVMS_SupplierName"';
        
        RETURN QUERY EXECUTE "sqlexec";
        
    END IF;
    
    RETURN;
END;
$$;