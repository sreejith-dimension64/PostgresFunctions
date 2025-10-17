CREATE OR REPLACE FUNCTION "INV"."INV_GRNReport_mob"(
    "MI_Id" BIGINT,
    "GRN_Ids" VARCHAR(100),
    "INVMI_Ids" VARCHAR(100),
    "INVMS_Ids" VARCHAR(100),
    "optionflag" VARCHAR(50),
    "typeflag" VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN
    "dates" := 'and (CAST("INVMGRN_PurchaseDate" AS DATE)>=''2019-04-01'')';
    
    IF ("typeflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MGRN"."INVMGRN_Id","MGRN"."INVMS_Id","TGRN"."INVMI_Id","INVMGRN_GRNNo","INVMGRN_PurchaseDate","ISP"."INVMS_SupplierName","INVMS_SupplierCode","INVMS_SupplierConatctPerson","INVMS_SupplierConatctNo","INVMS_EmailId","INVMS_SupplierAddress","MI"."INVMI_ItemName","MI"."INVMI_ItemCode","UOM"."INVMUOM_UOMName","TGRN"."INVTGRN_BatchNo","INVTGRN_PurchaseRate",
        "INVTGRN_MRP","INVTGRN_SalesPrice","INVTGRN_DiscountAmt","INVTGRN_TaxAmt","INVTGRN_Amount","INVTGRN_Qty","INVTGRN_Naration","INVTGRN_MfgDate","INVTGRN_ExpDate","INVTGRN_ActiveFlg"
        FROM "INV"."INV_M_GRN" "MGRN"
        LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id"="MGRN"."INVMGRN_Id"
        LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="TGRN"."INVMI_Id"
        LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id"="TGRN"."INVMUOM_Id"
        LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id"="MGRN"."INVMS_Id"
        WHERE "MGRN"."INVMGRN_ActiveFlg"=1 AND "TGRN"."INVTGRN_ActiveFlg"=1 AND "MGRN"."MI_Id"=' || "MI_Id";
        
        EXECUTE "Slqdymaic";
    END IF;
    
    IF ("typeflag" = 'Overall') THEN
        IF "optionflag" = 'Item' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "TGRN"."INVMI_Id","MI"."INVMI_ItemName","MI"."INVMI_ItemCode",
            SUM("INVTGRN_PurchaseRate") AS "grnRate",SUM("INVTGRN_MRP") AS "grnMRP",SUM("INVTGRN_SalesPrice") AS "grnSalePrice",SUM("INVTGRN_DiscountAmt") AS "grnDiscount",
            SUM("INVTGRN_TaxAmt") AS "grnTax",SUM("INVTGRN_Amount") AS "grnAmount",SUM("INVTGRN_Qty") AS "grnQuantity"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id"="MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id"="TGRN"."INVMUOM_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg"=1 AND "TGRN"."INVTGRN_ActiveFlg"=1 AND "MGRN"."MI_Id"=' || "MI_Id" || '
            GROUP BY "TGRN"."INVMI_Id","MI"."INVMI_ItemName","MI"."INVMI_ItemCode"';
            
            EXECUTE "Slqdymaic";
        ELSIF "optionflag" = 'Supplier' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "MGRN"."INVMS_Id","ISP"."INVMS_SupplierName","INVMS_SupplierCode","INVMS_SupplierConatctPerson","INVMS_SupplierConatctNo","INVMS_EmailId",
            "INVMS_SupplierAddress",
            SUM("INVTGRN_PurchaseRate") AS "grnRate",SUM("INVTGRN_MRP") AS "grnMRP",SUM("INVTGRN_SalesPrice") AS "grnSalePrice",SUM("INVTGRN_DiscountAmt") AS "grnDiscount",
            SUM("INVTGRN_TaxAmt") AS "grnTax",SUM("INVTGRN_Amount") AS "grnAmount",SUM("INVTGRN_Qty") AS "grnQuantity"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id"="MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id"="TGRN"."INVMUOM_Id"
            LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id"="MGRN"."INVMS_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg"=1 AND "TGRN"."INVTGRN_ActiveFlg"=1 AND "MGRN"."INVMS_Id" IN (' || "INVMS_Ids" || ') AND "MGRN"."MI_Id"=' || "MI_Id" || '
            GROUP BY "MGRN"."INVMS_Id","ISP"."INVMS_SupplierName","INVMS_SupplierCode","INVMS_SupplierConatctPerson","INVMS_SupplierConatctNo","INVMS_EmailId",
            "INVMS_SupplierAddress"';
            
            EXECUTE "Slqdymaic";
        END IF;
        
        IF "optionflag" = 'Individual' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "MGRN"."INVMGRN_Id","MGRN"."INVMS_Id","TGRN"."INVMI_Id","INVMGRN_GRNNo","INVMGRN_PurchaseDate","ISP"."INVMS_SupplierName","INVMS_SupplierCode","INVMS_SupplierConatctPerson","INVMS_SupplierConatctNo","INVMS_EmailId",
            "INVMS_SupplierAddress","MI"."INVMI_ItemName","MI"."INVMI_ItemCode","UOM"."INVMUOM_UOMName","TGRN"."INVTGRN_BatchNo","INVTGRN_Qty","INVTGRN_PurchaseRate","INVTGRN_MRP","INVTGRN_SalesPrice","INVTGRN_DiscountAmt",
            "INVTGRN_TaxAmt","INVTGRN_Amount","INVTGRN_Naration","INVTGRN_MfgDate","INVTGRN_ExpDate","INVTGRN_ActiveFlg"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id"="MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id"="TGRN"."INVMUOM_Id"
            LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id"="MGRN"."INVMS_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg"=1 AND "TGRN"."INVTGRN_ActiveFlg"=1 AND "MGRN"."MI_Id"=' || "MI_Id";
            
            EXECUTE "Slqdymaic";
        END IF;
    END IF;
    
    IF ("typeflag" = 'Detailed') THEN
        IF "optionflag" = 'Individual' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "MGRN"."INVMGRN_Id","MGRN"."INVMS_Id","TGRN"."INVMI_Id","INVMGRN_GRNNo","INVMGRN_PurchaseDate","ISP"."INVMS_SupplierName","INVMS_SupplierCode","INVMS_SupplierConatctPerson","INVMS_SupplierConatctNo","INVMS_EmailId",
            "INVMS_SupplierAddress","MI"."INVMI_ItemName","MI"."INVMI_ItemCode","UOM"."INVMUOM_UOMName","TGRN"."INVTGRN_BatchNo","INVTGRN_Qty","INVTGRN_PurchaseRate","INVTGRN_MRP","INVTGRN_SalesPrice","INVTGRN_DiscountAmt",
            "INVTGRN_TaxAmt","INVTGRN_Amount","INVTGRN_Naration","INVTGRN_MfgDate","INVTGRN_ExpDate","INVTGRN_ActiveFlg"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id"="MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id"="TGRN"."INVMUOM_Id"
            LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id"="MGRN"."INVMS_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg"=1 AND "TGRN"."INVTGRN_ActiveFlg"=1 AND "MGRN"."INVMGRN_Id" IN (' || "GRN_Ids" || ') AND "MGRN"."MI_Id"=' || "MI_Id";
            
            EXECUTE "Slqdymaic";
        ELSIF "optionflag" = 'Item' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "MGRN"."INVMGRN_Id","MGRN"."INVMS_Id","TGRN"."INVMI_Id","INVMGRN_GRNNo","INVMGRN_PurchaseDate","ISP"."INVMS_SupplierName","INVMS_SupplierCode","INVMS_SupplierConatctPerson","INVMS_SupplierConatctNo","INVMS_EmailId",
            "INVMS_SupplierAddress","MI"."INVMI_ItemName","MI"."INVMI_ItemCode","UOM"."INVMUOM_UOMName","TGRN"."INVTGRN_BatchNo","INVTGRN_PurchaseRate","INVTGRN_MRP","INVTGRN_SalesPrice","INVTGRN_DiscountAmt",
            "INVTGRN_TaxAmt","INVTGRN_Amount","INVTGRN_Qty","INVTGRN_Naration","INVTGRN_MfgDate","INVTGRN_ExpDate","INVTGRN_ActiveFlg"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id"="MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id"="TGRN"."INVMUOM_Id"
            LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id"="MGRN"."INVMS_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg"=1 AND "TGRN"."INVTGRN_ActiveFlg"=1 AND "TGRN"."INVMI_Id" IN (' || "INVMI_Ids" || ') AND "MGRN"."MI_Id"=' || "MI_Id";
            
            EXECUTE "Slqdymaic";
        ELSIF "optionflag" = 'Supplier' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "MGRN"."INVMGRN_Id","MGRN"."INVMS_Id","TGRN"."INVMI_Id","INVMGRN_GRNNo","INVMGRN_PurchaseDate","ISP"."INVMS_SupplierName","INVMS_SupplierCode","INVMS_SupplierConatctPerson","INVMS_SupplierConatctNo","INVMS_EmailId",
            "INVMS_SupplierAddress","MI"."INVMI_ItemName","MI"."INVMI_ItemCode","UOM"."INVMUOM_UOMName","TGRN"."INVTGRN_BatchNo","INVTGRN_PurchaseRate","INVTGRN_MRP","INVTGRN_SalesPrice","INVTGRN_DiscountAmt",
            "INVTGRN_TaxAmt","INVTGRN_Amount","INVTGRN_Qty","INVTGRN_Naration","INVTGRN_MfgDate","INVTGRN_ExpDate","INVTGRN_ActiveFlg"
            FROM "INV"."INV_M_GRN" "MGRN"
            LEFT JOIN "INV"."INV_T_GRN" "TGRN" ON "TGRN"."INVMGRN_Id"="MGRN"."INVMGRN_Id"
            LEFT JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id"="TGRN"."INVMI_Id"
            LEFT JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id"="TGRN"."INVMUOM_Id"
            LEFT JOIN "INV"."INV_Master_Supplier" "ISP" ON "ISP"."INVMS_Id"="MGRN"."INVMS_Id"
            WHERE "MGRN"."INVMGRN_ActiveFlg"=1 AND "TGRN"."INVTGRN_ActiveFlg"=1 AND "MGRN"."INVMS_Id" IN (' || "INVMS_Ids" || ') AND "MGRN"."MI_Id"=' || "MI_Id";
            
            EXECUTE "Slqdymaic";
        END IF;
    END IF;
    
    RETURN;
END;
$$;