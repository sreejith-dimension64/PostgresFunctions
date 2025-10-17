CREATE OR REPLACE FUNCTION "INV"."INV_Inward_Report" (
    "MI_Id" BIGINT,
    "startdate" VARCHAR(10),
    "enddate" VARCHAR(10),
    "INVMI_Ids" VARCHAR(100),
    "INVMS_Ids" VARCHAR(100),
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMPO_Id" BIGINT,
    "INVMS_Id" BIGINT,
    "INVMPI_Id" BIGINT,
    "INVMPO_PONo" TEXT,
    "INVMPO_PODate" TIMESTAMP,
    "INVMPO_ReferenceNo" TEXT,
    "INVMS_SupplierName" TEXT,
    "INVMS_SupplierCode" TEXT,
    "INV_SupplierINVNo" TEXT,
    "INV_HSNNo" TEXT,
    "INV_ItemQty" TEXT,
    "INV_BP" TEXT,
    "INV_Tax" TEXT,
    "INV_otherChrgs" TEXT,
    "INV_totalvalue" TEXT,
    "INV_PORefere" TEXT,
    "INV_EwayBill" TEXT,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVMUOM_Id" BIGINT,
    "INVMUOM_UOMName" TEXT,
    "INVTPO_POQty" NUMERIC,
    "INVTPO_RatePerUnit" NUMERIC,
    "INVTPO_TaxAmount" NUMERIC,
    "INVTPO_Amount" NUMERIC,
    "INVMPO_TotRate" NUMERIC,
    "INVMPO_TotTax" NUMERIC,
    "INVMPO_TotAmount" NUMERIC,
    "INVTPO_Remarks" TEXT,
    "INVTPO_ActiveFlg" BOOLEAN,
    "INVMPO_ActiveFlg" BOOLEAN,
    "INVMPO_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN
    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := 'AND "INVMPO_PODate"::date BETWEEN TO_DATE(''' || "startdate" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;

    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", MPO."INVMPI_Id", MPO."INVMPO_PONo", MPO."INVMPO_PODate", MPO."INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode",
        ''''::TEXT AS "INV_SupplierINVNo", ''''::TEXT AS "INV_HSNNo",
        ''''::TEXT AS "INV_ItemQty", ''''::TEXT AS "INV_BP", ''''::TEXT AS "INV_Tax", ''''::TEXT AS "INV_otherChrgs", 
        ''''::TEXT AS "INV_totalvalue", ''''::TEXT AS "INV_PORefere", ''''::TEXT AS "INV_EwayBill",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", TPO."INVTPO_POQty", TPO."INVTPO_RatePerUnit", 
        TPO."INVTPO_TaxAmount", TPO."INVTPO_Amount",
        MPO."INVMPO_TotRate", MPO."INVMPO_TotTax", MPO."INVMPO_TotAmount", TPO."INVTPO_Remarks", TPO."INVTPO_ActiveFlg", 
        MPO."INVMPO_ActiveFlg", MPO."INVMPO_Remarks"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."MI_Id" = ' || "MI_Id" || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", MPO."INVMPI_Id", MPO."INVMPO_PONo", MPO."INVMPO_PODate", MPO."INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode",
        ''''::TEXT AS "INV_SupplierINVNo", ''''::TEXT AS "INV_HSNNo",
        ''''::TEXT AS "INV_ItemQty", ''''::TEXT AS "INV_BP", ''''::TEXT AS "INV_Tax", ''''::TEXT AS "INV_otherChrgs", 
        ''''::TEXT AS "INV_totalvalue", ''''::TEXT AS "INV_PORefere", ''''::TEXT AS "INV_EwayBill",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", TPO."INVTPO_POQty", TPO."INVTPO_RatePerUnit", 
        TPO."INVTPO_TaxAmount", TPO."INVTPO_Amount",
        MPO."INVMPO_TotRate", MPO."INVMPO_TotTax", MPO."INVMPO_TotAmount", TPO."INVTPO_Remarks", TPO."INVTPO_ActiveFlg", 
        MPO."INVMPO_ActiveFlg", MPO."INVMPO_Remarks"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND TPO."INVMI_Id" IN (' || "INVMI_Ids" || ') 
        AND MPO."MI_Id" = ' || "MI_Id" || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Supplier' THEN
        "Slqdymaic" := '
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", MPO."INVMPI_Id", MPO."INVMPO_PONo", MPO."INVMPO_PODate", MPO."INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode",
        ''''::TEXT AS "INV_SupplierINVNo", ''''::TEXT AS "INV_HSNNo",
        ''''::TEXT AS "INV_ItemQty", ''''::TEXT AS "INV_BP", ''''::TEXT AS "INV_Tax", ''''::TEXT AS "INV_otherChrgs", 
        ''''::TEXT AS "INV_totalvalue", ''''::TEXT AS "INV_PORefere", ''''::TEXT AS "INV_EwayBill",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", TPO."INVTPO_POQty", TPO."INVTPO_RatePerUnit", 
        TPO."INVTPO_TaxAmount", TPO."INVTPO_Amount",
        MPO."INVMPO_TotRate", MPO."INVMPO_TotTax", MPO."INVMPO_TotAmount", TPO."INVTPO_Remarks", TPO."INVTPO_ActiveFlg", 
        MPO."INVMPO_ActiveFlg", MPO."INVMPO_Remarks"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."INVMS_Id" IN (' || "INVMS_Ids" || ') 
        AND MPO."MI_Id" = ' || "MI_Id" || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Itm' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::TEXT, NULL::TIMESTAMP, NULL::TEXT,
            NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, 
            NULL::TEXT, NULL::TEXT, NULL::TEXT,
            TPO."INVMI_Id", MI."INVMI_ItemName", NULL::BIGINT, NULL::TEXT, 
            SUM(TPO."INVTPO_POQty") AS "INVTPO_POQty", NULL::NUMERIC, NULL::NUMERIC, 
            SUM(TPO."INVTPO_Amount") AS "INVTPO_Amount",
            NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::BOOLEAN, NULL::TEXT
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."MI_Id" = "MI_Id"
        GROUP BY TPO."INVMI_Id", MI."INVMI_ItemName";

    ELSIF "optionflag" = 'Sup' THEN
        IF "INVMS_Ids" IS NOT NULL AND "INVMS_Ids" != '' AND "INVMS_Ids" != '0' THEN
            "Slqdymaic" := '
            SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", MPO."INVMPI_Id", MPO."INVMPO_PONo", MPO."INVMPO_PODate", MPO."INVMPO_ReferenceNo",
            MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode",
            ''''::TEXT AS "INV_SupplierINVNo", ''''::TEXT AS "INV_HSNNo",
            ''''::TEXT AS "INV_ItemQty", ''''::TEXT AS "INV_BP", ''''::TEXT AS "INV_Tax", ''''::TEXT AS "INV_otherChrgs", 
            ''''::TEXT AS "INV_totalvalue", ''''::TEXT AS "INV_PORefere", ''''::TEXT AS "INV_EwayBill",
            TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", TPO."INVTPO_POQty", TPO."INVTPO_RatePerUnit", 
            TPO."INVTPO_TaxAmount", TPO."INVTPO_Amount",
            MPO."INVMPO_TotRate", MPO."INVMPO_TotTax", MPO."INVMPO_TotAmount", TPO."INVTPO_Remarks", TPO."INVTPO_ActiveFlg", 
            MPO."INVMPO_ActiveFlg", MPO."INVMPO_Remarks"
            FROM "INV"."INV_M_PurchaseOrder" MPO
            INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
            INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
            INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
            INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
            WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."INVMS_Id" IN (' || "INVMS_Ids" || ') 
            AND MPO."MI_Id" = ' || "MI_Id" || ' ' || "dates";

            RETURN QUERY EXECUTE "Slqdymaic";
        ELSE
            RETURN QUERY
            SELECT DISTINCT 
                NULL::BIGINT, MPO."INVMS_Id", NULL::BIGINT, NULL::TEXT, NULL::TIMESTAMP, NULL::TEXT,
                MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode", NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, 
                NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
                NULL::BIGINT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, 
                SUM(TPO."INVTPO_POQty") AS "INVTPO_POQty", NULL::NUMERIC, NULL::NUMERIC, 
                SUM(TPO."INVTPO_Amount") AS "INVTPO_Amount",
                NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::BOOLEAN, NULL::TEXT
            FROM "INV"."INV_M_PurchaseOrder" MPO
            INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
            INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
            INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
            WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."MI_Id" = "MI_Id"
            GROUP BY MPO."INVMS_Id", MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode";
        END IF;
    END IF;

    RETURN;
END;
$$;