CREATE OR REPLACE FUNCTION "dbo"."INV_Pur_Report" (
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
    "INVMPO_PONo" VARCHAR,
    "INVMPO_PODate" TIMESTAMP,
    "INVMPO_ReferenceNo" VARCHAR,
    "INVMS_SupplierName" VARCHAR,
    "INVMS_SupplierCode" VARCHAR,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMUOM_Id" BIGINT,
    "INVMUOM_UOMName" VARCHAR,
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
        "dates" := 'AND DATE("INVMPO_PODate") BETWEEN TO_DATE(''' || "startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;

    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "MPO"."INVMPI_Id", "MPO"."INVMPO_PONo", "MPO"."INVMPO_PODate", "MPO"."INVMPO_ReferenceNo",
        "MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
        "TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "TPO"."INVTPO_POQty", "TPO"."INVTPO_RatePerUnit", "TPO"."INVTPO_TaxAmount", "TPO"."INVTPO_Amount",
        "MPO"."INVMPO_TotRate", "MPO"."INVMPO_TotTax", "MPO"."INVMPO_TotAmount", "TPO"."INVTPO_Remarks", "TPO"."INVTPO_ActiveFlg", "MPO"."INVMPO_ActiveFlg", "MPO"."INVMPO_Remarks"
        FROM "INV"."INV_M_PurchaseOrder" "MPO"
        INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
        WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "MPO"."INVMPI_Id", "MPO"."INVMPO_PONo", "MPO"."INVMPO_PODate", "MPO"."INVMPO_ReferenceNo",
        "MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
        "TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "TPO"."INVTPO_POQty", "TPO"."INVTPO_RatePerUnit", "TPO"."INVTPO_TaxAmount", "TPO"."INVTPO_Amount",
        "MPO"."INVMPO_TotRate", "MPO"."INVMPO_TotTax", "MPO"."INVMPO_TotAmount", "TPO"."INVTPO_Remarks", "TPO"."INVTPO_ActiveFlg", "MPO"."INVMPO_ActiveFlg", "MPO"."INVMPO_Remarks"
        FROM "INV"."INV_M_PurchaseOrder" "MPO"
        INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
        WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "TPO"."INVMI_Id" IN (' || "INVMI_Ids" || ') AND "MPO"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Supplier' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "MPO"."INVMPI_Id", "MPO"."INVMPO_PONo", "MPO"."INVMPO_PODate", "MPO"."INVMPO_ReferenceNo",
        "MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
        "TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "TPO"."INVTPO_POQty", "TPO"."INVTPO_RatePerUnit", "TPO"."INVTPO_TaxAmount", "TPO"."INVTPO_Amount",
        "MPO"."INVMPO_TotRate", "MPO"."INVMPO_TotTax", "MPO"."INVMPO_TotAmount", "TPO"."INVTPO_Remarks", "TPO"."INVTPO_ActiveFlg", "MPO"."INVMPO_ActiveFlg", "MPO"."INVMPO_Remarks"
        FROM "INV"."INV_M_PurchaseOrder" "MPO"
        INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
        WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."INVMS_Id" IN (' || "INVMS_Ids" || ') AND "MPO"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Itm' THEN
        RETURN QUERY EXECUTE '
        SELECT DISTINCT "TPO"."INVMI_Id", NULL::BIGINT, NULL::BIGINT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR,
        "MI"."INVMI_ItemName"::BIGINT AS "INVMI_Id", "MI"."INVMI_ItemName", NULL::BIGINT, NULL::VARCHAR,
        SUM("TPO"."INVTPO_POQty") AS "INVTPO_POQty", NULL::NUMERIC, NULL::NUMERIC, SUM("TPO"."INVTPO_Amount") AS "INVTPO_Amount",
        NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::BOOLEAN, NULL::TEXT
        FROM "INV"."INV_M_PurchaseOrder" "MPO"
        INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
        WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."MI_Id" = ' || "MI_Id"::TEXT || '
        GROUP BY "TPO"."INVMI_Id", "MI"."INVMI_ItemName"';

    ELSIF "optionflag" = 'Sup' THEN
        IF COALESCE("INVMS_Ids", '') != '' THEN
            "Slqdymaic" := '
            SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "MPO"."INVMPI_Id", "MPO"."INVMPO_PONo", "MPO"."INVMPO_PODate", "MPO"."INVMPO_ReferenceNo",
            "MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
            "TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "TPO"."INVTPO_POQty", "TPO"."INVTPO_RatePerUnit", "TPO"."INVTPO_TaxAmount", "TPO"."INVTPO_Amount",
            "MPO"."INVMPO_TotRate", "MPO"."INVMPO_TotTax", "MPO"."INVMPO_TotAmount", "TPO"."INVTPO_Remarks", "TPO"."INVTPO_ActiveFlg", "MPO"."INVMPO_ActiveFlg", "MPO"."INVMPO_Remarks"
            FROM "INV"."INV_M_PurchaseOrder" "MPO"
            INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
            INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
            INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
            WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."INVMS_Id" IN (' || "INVMS_Ids" || ') AND "MPO"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates";

            RETURN QUERY EXECUTE "Slqdymaic";
        ELSE
            RETURN QUERY EXECUTE '
            SELECT DISTINCT NULL::BIGINT, "MPO"."INVMS_Id", NULL::BIGINT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR,
            "MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode", NULL::BIGINT, NULL::VARCHAR, NULL::BIGINT, NULL::VARCHAR,
            SUM("TPO"."INVTPO_POQty") AS "INVTPO_POQty", NULL::NUMERIC, NULL::NUMERIC, SUM("TPO"."INVTPO_Amount") AS "INVTPO_Amount",
            NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::BOOLEAN, NULL::TEXT
            FROM "INV"."INV_M_PurchaseOrder" "MPO"
            INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
            INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
            INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
            WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."MI_Id" = ' || "MI_Id"::TEXT || '
            GROUP BY "MPO"."INVMS_Id", "MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode"';
        END IF;
    END IF;

    RETURN;
END;
$$;