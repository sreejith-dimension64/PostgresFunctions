CREATE OR REPLACE FUNCTION "dbo"."INV_GRNReport" (
    "p_MI_Id" BIGINT, 
    "p_startdate" VARCHAR(10), 
    "p_enddate" VARCHAR(10), 
    "p_GRN_Ids" VARCHAR(100), 
    "p_INVMI_Ids" VARCHAR(100),
    "p_INVMS_Ids" VARCHAR(100), 
    "p_optionflag" VARCHAR(50), 
    "p_typeflag" VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" VARCHAR(200);
BEGIN

    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := 'AND CAST("INVMGRN_PurchaseDate" AS DATE) BETWEEN TO_DATE(''' || "p_startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;

    IF ("p_typeflag" = 'All') THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "MGRN"."INVMGRN_Id", "MGRN"."INVMS_Id", "TGRN"."INVMI_Id", "INVMGRN_GRNNo", "INVMGRN_PurchaseDate", 
        "ISP"."INVMS_SupplierName", "INVMS_SupplierCode", "INVMS_SupplierConatctPerson", "INVMS_SupplierConatctNo", 
        "INVMS_EmailId", "INVMS_SupplierAddress", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode", "UOM"."INVMUOM_UOMName", 
        "TGRN"."INVTGRN_BatchNo", "INVTGRN_PurchaseRate", "INVTGRN_MRP", "INVTGRN_SalesPrice", "INVTGRN_DiscountAmt", 
        "INVTGRN_TaxAmt", "INVTGRN_Amount", "INVTGRN_Qty", "INVTGRN_Naration", "INVTGRN_MfgDate", "INVTGRN_ExpDate", "INVTGRN_ActiveFlg"
        FROM "INV"."INV_M_GRN" "MGRN"
        LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
        LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
        LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id" = "MGRN"."INVMS_Id"
        WHERE "MGRN"."INVMGRN_ActiveFlg" = 1 AND "TGRN"."INVTGRN_ActiveFlg" = 1 AND "MGRN"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' ' || "v_dates";
        
        EXECUTE "v_Slqdymaic";
    END IF;

    IF ("p_typeflag" = 'Overall') THEN
        IF "p_optionflag" = 'Item_1' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "TGRN"."INVMI_Id", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode",
            SUM("INVTGRN_PurchaseRate") AS "grnRate", SUM("INVTGRN_MRP") AS "grnMRP", SUM("INVTGRN_SalesPrice") AS "grnSalePrice", 
            SUM("INVTGRN_DiscountAmt") AS "grnDiscount", SUM("INVTGRN_TaxAmt") AS "grnTax", SUM("INVTGRN_Amount") AS "grnAmount", 
            SUM("INVTGRN_Qty") AS "grnQuantity"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg" = 1 AND "TGRN"."INVTGRN_ActiveFlg" = 1 AND "TGRN"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') 
            AND "MGRN"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' ' || "v_dates" || '
            GROUP BY "TGRN"."INVMI_Id", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode"';
            
            EXECUTE "v_Slqdymaic";
        ELSIF "p_optionflag" = 'Supplier' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "MGRN"."INVMS_Id", "ISP"."INVMS_SupplierName", "INVMS_SupplierCode", "INVMS_SupplierConatctPerson", 
            "INVMS_SupplierConatctNo", "INVMS_EmailId", "INVMS_SupplierAddress",
            SUM("INVTGRN_PurchaseRate") AS "grnRate", SUM("INVTGRN_MRP") AS "grnMRP", SUM("INVTGRN_SalesPrice") AS "grnSalePrice", 
            SUM("INVTGRN_DiscountAmt") AS "grnDiscount", SUM("INVTGRN_TaxAmt") AS "grnTax", SUM("INVTGRN_Amount") AS "grnAmount", 
            SUM("INVTGRN_Qty") AS "grnQuantity"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
            LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id" = "MGRN"."INVMS_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg" = 1 AND "TGRN"."INVTGRN_ActiveFlg" = 1 AND "MGRN"."INVMS_Id" IN (' || "p_INVMS_Ids" || ') 
            AND "MGRN"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' ' || "v_dates" || '
            GROUP BY "MGRN"."INVMS_Id", "ISP"."INVMS_SupplierName", "INVMS_SupplierCode", "INVMS_SupplierConatctPerson", 
            "INVMS_SupplierConatctNo", "INVMS_EmailId", "INVMS_SupplierAddress"';
            
            EXECUTE "v_Slqdymaic";
        END IF;
    END IF;

    IF ("p_typeflag" = 'Detailed') THEN
        IF "p_optionflag" = 'Individual_1' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "MGRN"."INVMGRN_Id", "MGRN"."INVMS_Id", "TGRN"."INVMI_Id", "INVMGRN_GRNNo", "INVMGRN_PurchaseDate", 
            "ISP"."INVMS_SupplierName", "INVMS_SupplierCode", "INVMS_SupplierConatctPerson", "INVMS_SupplierConatctNo", 
            "INVMS_EmailId", "INVMS_SupplierAddress", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode", "UOM"."INVMUOM_UOMName", 
            "TGRN"."INVTGRN_BatchNo", "INVTGRN_Qty", "INVTGRN_PurchaseRate", "INVTGRN_MRP", "INVTGRN_SalesPrice", "INVTGRN_DiscountAmt",
            "INVTGRN_TaxAmt", "INVTGRN_Amount", "INVTGRN_Naration", "INVTGRN_MfgDate", "INVTGRN_ExpDate", "INVTGRN_ActiveFlg"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
            LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id" = "MGRN"."INVMS_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg" = 1 AND "TGRN"."INVTGRN_ActiveFlg" = 1 AND "MGRN"."INVMGRN_Id" IN (' || "p_GRN_Ids" || ') 
            AND "MGRN"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' ' || "v_dates";
            
            EXECUTE "v_Slqdymaic";
        ELSIF "p_optionflag" = 'Item_1' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "MGRN"."INVMGRN_Id", "MGRN"."INVMS_Id", "TGRN"."INVMI_Id", "INVMGRN_GRNNo", "INVMGRN_PurchaseDate", 
            "ISP"."INVMS_SupplierName", "INVMS_SupplierCode", "INVMS_SupplierConatctPerson", "INVMS_SupplierConatctNo", 
            "INVMS_EmailId", "INVMS_SupplierAddress", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode", "UOM"."INVMUOM_UOMName", 
            "TGRN"."INVTGRN_BatchNo", "INVTGRN_PurchaseRate", "INVTGRN_MRP", "INVTGRN_SalesPrice", "INVTGRN_DiscountAmt",
            "INVTGRN_TaxAmt", "INVTGRN_Amount", "INVTGRN_Qty", "INVTGRN_Naration", "INVTGRN_MfgDate", "INVTGRN_ExpDate", "INVTGRN_ActiveFlg"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
            LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id" = "MGRN"."INVMS_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg" = 1 AND "TGRN"."INVTGRN_ActiveFlg" = 1 AND "TGRN"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') 
            AND "MGRN"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' ' || "v_dates";
            
            EXECUTE "v_Slqdymaic";
        ELSIF "p_optionflag" = 'Supplier' THEN
            "v_Slqdymaic" := '
            SELECT DISTINCT "MGRN"."INVMGRN_Id", "MGRN"."INVMS_Id", "TGRN"."INVMI_Id", "INVMGRN_GRNNo", "INVMGRN_PurchaseDate", 
            "ISP"."INVMS_SupplierName", "INVMS_SupplierCode", "INVMS_SupplierConatctPerson", "INVMS_SupplierConatctNo", 
            "INVMS_EmailId", "INVMS_SupplierAddress", "MI"."INVMI_ItemName", "MI"."INVMI_ItemCode", "UOM"."INVMUOM_UOMName", 
            "TGRN"."INVTGRN_BatchNo", "INVTGRN_PurchaseRate", "INVTGRN_MRP", "INVTGRN_SalesPrice", "INVTGRN_DiscountAmt",
            "INVTGRN_TaxAmt", "INVTGRN_Amount", "INVTGRN_Qty", "INVTGRN_Naration", "INVTGRN_MfgDate", "INVTGRN_ExpDate", "INVTGRN_ActiveFlg"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id" = "MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TGRN"."INVMUOM_Id"
            LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id" = "MGRN"."INVMS_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg" = 1 AND "TGRN"."INVTGRN_ActiveFlg" = 1 AND "MGRN"."INVMS_Id" IN (' || "p_INVMS_Ids" || ') 
            AND "MGRN"."MI_Id" = ' || "p_MI_Id"::VARCHAR || ' ' || "v_dates";
            
            EXECUTE "v_Slqdymaic";
        END IF;
    END IF;

    RETURN;
END;
$$;