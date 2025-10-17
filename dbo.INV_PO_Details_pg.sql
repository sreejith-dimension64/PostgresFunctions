CREATE OR REPLACE FUNCTION "dbo"."INV_PO_Details"(
    "@MI_Id" BIGINT,
    "@optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMPO_Id" BIGINT,
    "INVMPO_PONo" VARCHAR,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMI_ItemCode" VARCHAR,
    "INVMS_Id" BIGINT,
    "INVMS_SupplierName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@optionflag" = 'PONo' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "INV_M_PurchaseOrder"."INVMPO_Id",
            "INV_M_PurchaseOrder"."INVMPO_PONo",
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::BIGINT,
            NULL::VARCHAR
        FROM "INV"."INV_M_PurchaseOrder"
        WHERE "INV_M_PurchaseOrder"."MI_Id" = "@MI_Id" 
            AND "INV_M_PurchaseOrder"."INVMPO_ActiveFlg" = 1
        ORDER BY "INV_M_PurchaseOrder"."INVMPO_Id";
        
    ELSIF "@optionflag" = 'Item' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT,
            NULL::VARCHAR,
            a."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode",
            NULL::BIGINT,
            NULL::VARCHAR
        FROM "INV"."INV_Master_Item" a,
            "INV"."INV_M_PurchaseOrder" b,
            "INV"."INV_T_PurchaseOrder" c
        WHERE a."INVMI_Id" = c."INVMI_Id" 
            AND b."INVMPO_Id" = c."INVMPO_Id" 
            AND a."MI_Id" = "@MI_Id"
        ORDER BY a."INVMI_ItemName";
        
    ELSIF "@optionflag" = 'Supplier' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            a."INVMS_Id",
            b."INVMS_SupplierName"
        FROM "INV"."INV_M_PurchaseOrder" a
        INNER JOIN "INV"."INV_Master_Supplier" b 
            ON a."INVMS_Id" = b."INVMS_Id" 
            AND a."MI_Id" = b."MI_Id"
        WHERE a."MI_Id" = "@MI_Id" 
            AND a."INVMPO_ActiveFlg" = 1
        ORDER BY b."INVMS_SupplierName";
        
    END IF;

    RETURN;

END;
$$;