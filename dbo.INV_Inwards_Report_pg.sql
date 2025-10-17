CREATE OR REPLACE FUNCTION "dbo"."INV_Inwards_Report" (
    "MI_Id" VARCHAR(20), 
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
    "INVMPO_Remarks" TEXT,
    "MI_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN
    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := 'AND "INVMPO_PODate"::DATE BETWEEN TO_DATE(''' || "startdate" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;

    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '   
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", "INVMPI_Id", "INVMPO_PONo", "INVMPO_PODate", "INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", "INVMS_SupplierCode",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", "INVTPO_POQty", "INVTPO_RatePerUnit", "INVTPO_TaxAmount", "INVTPO_Amount",
        "INVMPO_TotRate", "INVMPO_TotTax", "INVMPO_TotAmount", "INVTPO_Remarks", "INVTPO_ActiveFlg", "INVMPO_ActiveFlg", "INVMPO_Remarks", mtr."MI_Name"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        LEFT JOIN "Master_Institution" mtr ON mtr."MI_Id" = MPO."MI_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."MI_Id"::VARCHAR IN (' || "MI_Id" || ') ' || "dates";

        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Itm' THEN
        "Slqdymaic" := '
        SELECT DISTINCT TPO."INVMI_Id", MI."INVMI_ItemName", SUM("INVTPO_POQty") AS "INVTPO_POQty", SUM("INVTPO_Amount") AS "INVTPO_Amount",
        NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR,
        NULL::BIGINT, NULL::VARCHAR, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT,
        NULL::BOOLEAN, NULL::BOOLEAN, NULL::TEXT, NULL::VARCHAR
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."MI_Id"::VARCHAR = ''' || "MI_Id" || ''' ' || "dates" || ' 
        GROUP BY TPO."INVMI_Id", MI."INVMI_ItemName"';
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", "INVMPI_Id", "INVMPO_PONo", "INVMPO_PODate", "INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", "INVMS_SupplierCode",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", "INVTPO_POQty", "INVTPO_RatePerUnit", "INVTPO_TaxAmount", "INVTPO_Amount",
        "INVMPO_TotRate", "INVMPO_TotTax", "INVMPO_TotAmount", "INVTPO_Remarks", "INVTPO_ActiveFlg", "INVMPO_ActiveFlg", "INVMPO_Remarks", mtr."MI_Name"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        LEFT JOIN "Master_Institution" mtr ON mtr."MI_Id" = MPO."MI_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND TPO."INVMI_Id"::VARCHAR IN (' || "INVMI_Ids" || ') AND MPO."MI_Id"::VARCHAR IN (' || "MI_Id" || ') ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Sup' THEN
        "Slqdymaic" := '
        SELECT DISTINCT NULL::BIGINT, MPO."INVMS_Id", NULL::BIGINT, NULL::VARCHAR, NULL::TIMESTAMP, NULL::VARCHAR,
        MSP."INVMS_SupplierName", "INVMS_SupplierCode", NULL::BIGINT, NULL::VARCHAR, NULL::BIGINT, NULL::VARCHAR,
        SUM("INVTPO_POQty") AS "INVTPO_POQty", NULL::NUMERIC, NULL::NUMERIC, SUM("INVTPO_Amount") AS "INVTPO_Amount",
        NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, NULL::TEXT, NULL::BOOLEAN, NULL::BOOLEAN, NULL::TEXT, NULL::VARCHAR
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."MI_Id"::VARCHAR = ''' || "MI_Id" || ''' ' || "dates" || ' 
        GROUP BY MPO."INVMS_Id", MSP."INVMS_SupplierName", "INVMS_SupplierCode"';
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Supplier' THEN
        "Slqdymaic" := '
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", "INVMPI_Id", "INVMPO_PONo", "INVMPO_PODate", "INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", "INVMS_SupplierCode",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", "INVTPO_POQty", "INVTPO_RatePerUnit", "INVTPO_TaxAmount", "INVTPO_Amount",
        NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC, "INVTPO_Remarks", "INVTPO_ActiveFlg", NULL::BOOLEAN, NULL::TEXT, mtr."MI_Name"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        LEFT JOIN "Master_Institution" mtr ON mtr."MI_Id" = MPO."MI_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."INVMS_Id"::VARCHAR IN (' || "INVMS_Ids" || ') AND MPO."MI_Id"::VARCHAR IN (' || "MI_Id" || ') ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
    END IF;

    RETURN;
END;
$$;