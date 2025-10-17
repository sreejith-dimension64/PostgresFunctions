CREATE OR REPLACE FUNCTION "dbo"."INV_PO_REPORT_STATUS_NEW" (
    "p_MI_Id" TEXT, 
    "p_startdate" VARCHAR(10), 
    "p_enddate" VARCHAR(10), 
    "p_PO_Ids" TEXT,  
    "p_INVMI_Ids" TEXT, 
    "p_INVMS_Ids" TEXT, 
    "p_optionflag" VARCHAR(50),  
    "p_accept" VARCHAR(10), 
    "p_reject" VARCHAR(10), 
    "p_pending" VARCHAR(10)
)
RETURNS TABLE (
    "INVMPO_Id" INTEGER,
    "INVMS_Id" INTEGER,
    "INVMPI_Id" INTEGER,
    "INVMPO_PONo" VARCHAR,
    "INVMPO_PODate" TIMESTAMP,
    "INVMPO_ReferenceNo" VARCHAR,
    "INVMS_SupplierName" VARCHAR,
    "INVMS_SupplierCode" VARCHAR,
    "INVMI_Id" INTEGER,
    "INVMI_ItemName" VARCHAR,
    "INVMUOM_Id" INTEGER,
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
    "INVMPO_Remarks" TEXT,
    "MI_Name" VARCHAR,
    "INVMPO_RejectFlg" BOOLEAN,
    "INVMPO_FinalProcessFlag" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" VARCHAR(200);
    "v_flg" VARCHAR(200);
BEGIN

    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := 'AND "INVMPO_PODate"::date BETWEEN TO_DATE(''' || "p_startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;

    IF "p_accept" = '1' AND "p_reject" = '0' AND "p_pending" = '0' THEN
        "v_flg" := 'AND "MPO"."INVMPO_RejectFlg" = false AND "MPO"."INVMPO_FinalProcessFlag" = true AND "TPO"."INVTPO_RejectFlg" = false';
    ELSIF "p_accept" = '0' AND "p_reject" = '1' AND "p_pending" = '0' THEN
        "v_flg" := 'AND "MPO"."INVMPO_FinalProcessFlag" = true AND "TPO"."INVTPO_RejectFlg" = true AND ("MPO"."INVMPO_RejectFlg" = true OR "MPO"."INVMPO_RejectFlg" = true)';
    ELSIF "p_accept" = '0' AND "p_reject" = '0' AND "p_pending" = '1' THEN
        "v_flg" := 'AND "MPO"."INVMPO_RejectFlg" = false AND "MPO"."INVMPO_FinalProcessFlag" = false AND "TPO"."INVTPO_RejectFlg" = false';
    ELSE
        "v_flg" := '';
    END IF;

    IF "p_optionflag" = 'All' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PONo", "INVMPO_PODate", "INVMPO_ReferenceNo",
"MSP"."INVMS_SupplierName", "INVMS_SupplierCode",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "INVTPO_POQty", "INVTPO_RatePerUnit", "INVTPO_TaxAmount", "INVTPO_Amount",
"INVMPO_TotRate", "INVMPO_TotTax", "INVMPO_TotAmount", "INVTPO_Remarks", "INVTPO_ActiveFlg", "INVMPO_ActiveFlg", "INVMPO_Remarks", "ins"."MI_Name", "MPO"."INVMPO_RejectFlg", "MPO"."INVMPO_FinalProcessFlag"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
LEFT JOIN "master_institution" "ins" ON "ins"."MI_Id" = "TPO"."MI_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_dates" || ' ' || "v_flg";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'PONo' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PONo", "INVMPO_PODate", "INVMPO_ReferenceNo",
"MSP"."INVMS_SupplierName", "INVMS_SupplierCode",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "INVTPO_POQty", "INVTPO_RatePerUnit", "INVTPO_TaxAmount", "INVTPO_Amount",
"INVMPO_TotRate", "INVMPO_TotTax", "INVMPO_TotAmount", "INVTPO_Remarks", "INVTPO_ActiveFlg", "INVMPO_ActiveFlg", "INVMPO_Remarks", "ins"."MI_Name", "MPO"."INVMPO_RejectFlg", "MPO"."INVMPO_FinalProcessFlag"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
LEFT JOIN "master_institution" "ins" ON "ins"."MI_Id" = "TPO"."MI_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."INVMPO_Id" IN (' || "p_PO_Ids" || ') AND "MPO"."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_dates" || ' ' || "v_flg";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Item' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PONo", "INVMPO_PODate", "INVMPO_ReferenceNo",
"MSP"."INVMS_SupplierName", "INVMS_SupplierCode",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "INVTPO_POQty", "INVTPO_RatePerUnit", "INVTPO_TaxAmount", "INVTPO_Amount",
"INVMPO_TotRate", "INVMPO_TotTax", "INVMPO_TotAmount", "INVTPO_Remarks", "INVTPO_ActiveFlg", "INVMPO_ActiveFlg", "INVMPO_Remarks", "ins"."MI_Name", "MPO"."INVMPO_RejectFlg", "MPO"."INVMPO_FinalProcessFlag"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
LEFT JOIN "master_institution" "ins" ON "ins"."MI_Id" = "TPO"."MI_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "TPO"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') AND "MPO"."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_dates" || ' ' || "v_flg";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Supplier' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PONo", "INVMPO_PODate", "INVMPO_ReferenceNo",
"MSP"."INVMS_SupplierName", "INVMS_SupplierCode",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", "INVTPO_POQty", "INVTPO_RatePerUnit", "INVTPO_TaxAmount", "INVTPO_Amount",
"INVMPO_TotRate", "INVMPO_TotTax", "INVMPO_TotAmount", "INVTPO_Remarks", "INVTPO_ActiveFlg", "INVMPO_ActiveFlg", "INVMPO_Remarks", "ins"."MI_Name", "MPO"."INVMPO_RejectFlg", "MPO"."INVMPO_FinalProcessFlag"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
LEFT JOIN "master_institution" "ins" ON "ins"."MI_Id" = "TPO"."MI_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = true AND "TPO"."INVTPO_ActiveFlg" = true AND "MPO"."INVMS_Id" IN (' || "p_INVMS_Ids" || ') AND "MPO"."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_dates" || ' ' || "v_flg";

        RETURN QUERY EXECUTE "v_Slqdymaic";

    END IF;

    RETURN;

END;
$$;