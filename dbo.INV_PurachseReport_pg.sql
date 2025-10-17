CREATE OR REPLACE FUNCTION "INV"."INV_PurachseReport" (
    "p_MI_Id" VARCHAR(20), 
    "p_startdate" VARCHAR(10), 
    "p_enddate" VARCHAR(10),
    "p_INVMI_Ids" VARCHAR(100), 
    "p_INVMS_Ids" VARCHAR(100), 
    "p_optionflag" VARCHAR(50)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" VARCHAR(200);
BEGIN
    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := 'AND CAST("INVMPO_PODate" AS DATE) BETWEEN TO_DATE(''' || "p_startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;

    IF ("p_optionflag" = 'All') THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PODate",
"MSP"."INVMS_SupplierName",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", SUM("INVTPO_POQty") AS "INVTPO_POQty",
SUM("INVTPO_RatePerUnit") AS "INVTPO_RatePerUnit", SUM("INVTPO_TaxAmount") AS "INVTPO_TaxAmount", SUM("INVTPO_Amount") AS "INVTPO_Amount"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
LEFT JOIN "Master_Institution" "mtr" ON "mtr"."MI_Id" = "MPO"."MI_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = 1 AND "TPO"."INVTPO_ActiveFlg" = 1 AND "MPO"."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_dates" || '
GROUP BY "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PODate",
"MSP"."INVMS_SupplierName",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName"';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Itm' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "TPO"."INVMI_Id", "MI"."INVMI_ItemName", SUM("INVTPO_POQty") AS "INVTPO_POQty", SUM("INVTPO_Amount") AS "INVTPO_Amount"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = 1 AND "TPO"."INVTPO_ActiveFlg" = 1 AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates" || '
GROUP BY "TPO"."INVMI_Id", "MI"."INVMI_ItemName"';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Item' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PODate",
"MSP"."INVMS_SupplierName",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", SUM("INVTPO_POQty") AS "INVTPO_POQty",
SUM("INVTPO_RatePerUnit") AS "INVTPO_RatePerUnit", SUM("INVTPO_TaxAmount") AS "INVTPO_TaxAmount", SUM("INVTPO_Amount") AS "INVTPO_Amount"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
LEFT JOIN "Master_Institution" "mtr" ON "mtr"."MI_Id" = "MPO"."MI_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = 1 AND "TPO"."INVTPO_ActiveFlg" = 1 AND "TPO"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') AND "MPO"."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_dates" || '
GROUP BY "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PODate",
"MSP"."INVMS_SupplierName",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName"';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Sup' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMS_Id", "MSP"."INVMS_SupplierName", "INVMS_SupplierCode", SUM("INVTPO_POQty") AS "INVTPO_POQty", SUM("INVTPO_Amount") AS "INVTPO_Amount"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = 1 AND "TPO"."INVTPO_ActiveFlg" = 1 AND "MPO"."MI_Id" = ' || "p_MI_Id" || ' ' || "v_dates" || '
GROUP BY "MPO"."INVMS_Id", "MSP"."INVMS_SupplierName", "INVMS_SupplierCode"';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    ELSIF "p_optionflag" = 'Supplier' THEN
        "v_Slqdymaic" := '
SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PODate",
"MSP"."INVMS_SupplierName",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", SUM("INVTPO_POQty") AS "INVTPO_POQty",
SUM("INVTPO_RatePerUnit") AS "INVTPO_RatePerUnit", SUM("INVTPO_TaxAmount") AS "INVTPO_TaxAmount", SUM("INVTPO_Amount") AS "INVTPO_Amount"
FROM "INV"."INV_M_PurchaseOrder" "MPO"
INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id"
INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPO"."INVMI_Id"
INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPO"."INVMUOM_Id"
INNER JOIN "INV"."INV_Master_Supplier" "MSP" ON "MPO"."INVMS_Id" = "MSP"."INVMS_Id"
LEFT JOIN "Master_Institution" "mtr" ON "mtr"."MI_Id" = "MPO"."MI_Id"
WHERE "MPO"."INVMPO_ActiveFlg" = 1 AND "TPO"."INVTPO_ActiveFlg" = 1 AND "MPO"."INVMS_Id" IN (' || "p_INVMS_Ids" || ') AND "MPO"."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_dates" || '
GROUP BY "MPO"."INVMPO_Id", "MPO"."INVMS_Id", "INVMPI_Id", "INVMPO_PODate",
"MSP"."INVMS_SupplierName",
"TPO"."INVMI_Id", "MI"."INVMI_ItemName", "TPO"."INVMUOM_Id", "UOM"."INVMUOM_UOMName"';

        RETURN QUERY EXECUTE "v_Slqdymaic";

    END IF;

    RETURN;
END;
$$;