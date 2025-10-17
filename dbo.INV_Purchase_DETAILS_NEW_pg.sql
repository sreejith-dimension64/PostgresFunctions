CREATE OR REPLACE FUNCTION "dbo"."INV_Purchase_DETAILS_NEW"(
    "MI_Id" VARCHAR(30),
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "Id" BIGINT,
    "Name" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlexec" TEXT;
BEGIN
    IF "optionflag" = 'Item' THEN
        "sqlexec" := '
        SELECT a."INVMI_Id", a."INVMI_ItemName" 
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_T_PurchaseOrder" b ON a."INVMI_Id" = b."INVMI_Id"
        WHERE a."MI_Id" = b."MI_Id" AND a."MI_Id" IN(' || "MI_Id" || ')';
        
        RETURN QUERY EXECUTE "sqlexec";
        
    ELSIF "optionflag" = 'Supplier' THEN
        "sqlexec" := '
        SELECT a."INVMS_Id", a."INVMS_SupplierName" 
        FROM "INV"."INV_Master_Supplier" a
        INNER JOIN "INV"."INV_M_PurchaseOrder" b ON a."INVMS_Id" = b."INVMS_Id"
        WHERE a."MI_Id" = b."MI_Id" AND a."MI_Id" IN(' || "MI_Id" || ')';
        
        RETURN QUERY EXECUTE "sqlexec";
    END IF;
    
    RETURN;
END;
$$;