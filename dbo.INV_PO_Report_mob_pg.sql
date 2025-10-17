CREATE OR REPLACE FUNCTION "INV"."INV_PO_Report_mob" (
    "p_MI_Id" BIGINT, 
    "p_startdate" VARCHAR(10), 
    "p_enddate" VARCHAR(10), 
    "p_PO_Ids" VARCHAR(100),  
    "p_INVMI_Ids" VARCHAR(100), 
    "p_INVMS_Ids" VARCHAR(100), 
    "p_optionflag" VARCHAR(50)
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
    "v_Slqdymaic" TEXT;
    "v_dates" VARCHAR(200);
BEGIN
    
    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := 'AND "INVMPO_PODate"::date BETWEEN TO_DATE(''' || "p_startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;
    
    IF ("p_optionflag" = 'All') THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "MPO"."INVMPI_Id", "MPO"."INVMPO_PONo", "MPO"."INVMPO_PODate", "MPO"."INVMPO_ReferenceNo",
"MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "TPO"."INVTPO_POQty", "TPO"."INVTPO_RatePerUnit", "TPO"."INVTPO_TaxAmount", "TPO"."INVTPO_Amount",
"MPO"."INVMPO_TotRate", "MPO"."INVMPO_TotTax", "MPO"."INVMPO_TotAmount", "TPO"."INVTPO_Remarks", "TPO"."INVTPO_ActiveFlg", "MPO"."INVMPO_ActiveFlg", "MPO"."INVMPO_Remarks"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_optionflag" = 'PONo' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "MPO"."INVMPI_Id", "MPO"."INVMPO_PONo", "MPO"."INVMPO_PODate", "MPO"."INVMPO_ReferenceNo",
"MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "TPO"."INVTPO_POQty", "TPO"."INVTPO_RatePerUnit", "TPO"."INVTPO_TaxAmount", "TPO"."INVTPO_Amount",
"MPO"."INVMPO_TotRate", "MPO"."INVMPO_TotTax", "MPO"."INVMPO_TotAmount", "TPO"."INVTPO_Remarks", "TPO"."INVTPO_ActiveFlg", "MPO"."INVMPO_ActiveFlg", "MPO"."INVMPO_Remarks"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."INVMPO_Id" IN (' || "p_PO_Ids" || ') AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_optionflag" = 'Item' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "MPO"."INVMPI_Id", "MPO"."INVMPO_PONo", "MPO"."INVMPO_PODate", "MPO"."INVMPO_ReferenceNo",
"MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "TPO"."INVTPO_POQty", "TPO"."INVTPO_RatePerUnit", "TPO"."INVTPO_TaxAmount", "TPO"."INVTPO_Amount",
"MPO"."INVMPO_TotRate", "MPO"."INVMPO_TotTax", "MPO"."INVMPO_TotAmount", "TPO"."INVTPO_Remarks", "TPO"."INVTPO_ActiveFlg", "MPO"."INVMPO_ActiveFlg", "MPO"."INVMPO_Remarks"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "TPO"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_optionflag" = 'Supplier' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "MPO"."INVMPI_Id", "MPO"."INVMPO_PONo", "MPO"."INVMPO_PODate", "MPO"."INVMPO_ReferenceNo",
"MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "TPO"."INVTPO_POQty", "TPO"."INVTPO_RatePerUnit", "TPO"."INVTPO_TaxAmount", "TPO"."INVTPO_Amount",
"MPO"."INVMPO_TotRate", "MPO"."INVMPO_TotTax", "MPO"."INVMPO_TotAmount", "TPO"."INVTPO_Remarks", "TPO"."INVTPO_ActiveFlg", "MPO"."INVMPO_ActiveFlg", "MPO"."INVMPO_Remarks"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."INVMS_Id" IN (' || "p_INVMS_Ids" || ') AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_optionflag" = 'PO' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", NULL::BIGINT, NULL::BIGINT, "MPO"."INVMPO_PONo", NULL::TIMESTAMP, NULL::VARCHAR,
NULL::VARCHAR, NULL::VARCHAR,
NULL::BIGINT, NULL::VARCHAR, NULL::BIGINT, NULL::VARCHAR, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, SUM("TPO"."INVTPO_Amount") AS "INVTPO_Amount",
NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::BOOLEAN, NULL::TEXT
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' 
GROUP BY "MPO"."INVMPO_Id", "MPO"."INVMPO_PONo"';
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_optionflag" = 'Itm' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR,
NULL::VARCHAR, NULL::VARCHAR,
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", NULL::BIGINT, NULL::VARCHAR, SUM("TPO"."INVTPO_POQty") AS "INVTPO_POQty", NULL::NUMERIC, NULL::NUMERIC, SUM("TPO"."INVTPO_Amount") AS "INVTPO_Amount",
NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::BOOLEAN, NULL::TEXT
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' 
GROUP BY "TPO"."INVMI_Id", "MI"."INVMI_ItemName"';
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_optionflag" = 'Sup' THEN
        IF "p_INVMS_Ids" IS NOT NULL AND "p_INVMS_Ids" != '' AND "p_INVMS_Ids" != '0' THEN
            "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "MPO"."INVMPI_Id", "MPO"."INVMPO_PONo", "MPO"."INVMPO_PODate", "MPO"."INVMPO_ReferenceNo",
"MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "TPO"."INVTPO_POQty", "TPO"."INVTPO_RatePerUnit", "TPO"."INVTPO_TaxAmount", "TPO"."INVTPO_Amount",
"MPO"."INVMPO_TotRate", "MPO"."INVMPO_TotTax", "MPO"."INVMPO_TotAmount", "TPO"."INVTPO_Remarks", "TPO"."INVTPO_ActiveFlg", "MPO"."INVMPO_ActiveFlg", "MPO"."INVMPO_Remarks"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."INVMS_Id" IN (' || "p_INVMS_Ids" || ') AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates";
            
            RETURN QUERY EXECUTE "v_Slqdymaic";
        ELSE
            "v_Slqdymaic" := '
SELECT DISTINCT NULL::BIGINT, "MPO"."INVMS_Id", NULL::BIGINT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR,
"MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode",
NULL::BIGINT, NULL::VARCHAR, NULL::BIGINT, NULL::VARCHAR, SUM("TPO"."INVTPO_POQty") AS "INVTPO_POQty", NULL::NUMERIC, NULL::NUMERIC, SUM("TPO"."INVTPO_Amount") AS "INVTPO_Amount",
NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::BOOLEAN, NULL::TEXT
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' 
GROUP BY "MPO"."INVMS_Id", "MSP"."INVMS_SupplierName", "MSP"."INVMS_SupplierCode"';
            
            RETURN QUERY EXECUTE "v_Slqdymaic";
        END IF;
    END IF;
    
    RETURN;
END;
$$;