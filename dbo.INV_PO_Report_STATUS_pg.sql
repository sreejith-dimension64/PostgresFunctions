CREATE OR REPLACE FUNCTION "dbo"."INV_PO_Report_STATUS"(
    "MI_Id" TEXT,
    "startdate" VARCHAR(10),
    "enddate" VARCHAR(10),
    "PO_Ids" TEXT,
    "INVMI_Ids" TEXT,
    "INVMS_Ids" TEXT,
    "optionflag" VARCHAR(50),
    "accept" VARCHAR(10),
    "reject" VARCHAR(10),
    "pending" VARCHAR(10)
)
RETURNS TABLE(
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
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
    "flg" VARCHAR(200);
BEGIN

    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := 'AND DATE("INVMPO_PODate") BETWEEN TO_DATE(''' || "startdate" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''', ''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;

    IF "accept" = '1' AND "reject" = '0' AND "pending" = '0' THEN
        "flg" := 'AND MPO."INVMPO_RejectFlg" = FALSE AND MPO."INVMPO_FinalProcessFlag" = TRUE AND TPO."INVTPO_RejectFlg" = FALSE';
    ELSIF "accept" = '0' AND "reject" = '1' AND "pending" = '0' THEN
        "flg" := 'AND MPO."INVMPO_FinalProcessFlag" = TRUE AND TPO."INVTPO_RejectFlg" = TRUE AND (MPO."INVMPO_RejectFlg" = TRUE OR MPO."INVMPO_RejectFlg" = TRUE)';
    ELSIF "accept" = '0' AND "reject" = '0' AND "pending" = '1' THEN
        "flg" := 'AND MPO."INVMPO_RejectFlg" = FALSE AND MPO."INVMPO_FinalProcessFlag" = FALSE AND TPO."INVTPO_RejectFlg" = FALSE';
    ELSE
        "flg" := '';
    END IF;

    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", MPO."INVMPI_Id", MPO."INVMPO_PONo", MPO."INVMPO_PODate", MPO."INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", TPO."INVTPO_POQty", TPO."INVTPO_RatePerUnit", 
        TPO."INVTPO_TaxAmount", TPO."INVTPO_Amount",
        MPO."INVMPO_TotRate", MPO."INVMPO_TotTax", MPO."INVMPO_TotAmount", TPO."INVTPO_Remarks", TPO."INVTPO_ActiveFlg", 
        MPO."INVMPO_ActiveFlg", MPO."INVMPO_Remarks", ins."MI_Name", MPO."INVMPO_RejectFlg", MPO."INVMPO_FinalProcessFlag"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        LEFT JOIN "master_institution" ins ON ins."MI_Id" = TPO."MI_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."MI_Id" IN (' || "MI_Id" || ') ' || "dates" || ' ' || "flg";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'PONo' THEN
        "Slqdymaic" := '
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", MPO."INVMPI_Id", MPO."INVMPO_PONo", MPO."INVMPO_PODate", MPO."INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", TPO."INVTPO_POQty", TPO."INVTPO_RatePerUnit", 
        TPO."INVTPO_TaxAmount", TPO."INVTPO_Amount",
        MPO."INVMPO_TotRate", MPO."INVMPO_TotTax", MPO."INVMPO_TotAmount", TPO."INVTPO_Remarks", TPO."INVTPO_ActiveFlg", 
        MPO."INVMPO_ActiveFlg", MPO."INVMPO_Remarks", ins."MI_Name", MPO."INVMPO_RejectFlg", MPO."INVMPO_FinalProcessFlag"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        LEFT JOIN "master_institution" ins ON ins."MI_Id" = TPO."MI_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."INVMPO_Id" IN (' || "PO_Ids" || ') AND MPO."MI_Id" IN (' || "MI_Id" || ') ' || "dates" || ' ' || "flg";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", MPO."INVMPI_Id", MPO."INVMPO_PONo", MPO."INVMPO_PODate", MPO."INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", TPO."INVTPO_POQty", TPO."INVTPO_RatePerUnit", 
        TPO."INVTPO_TaxAmount", TPO."INVTPO_Amount",
        MPO."INVMPO_TotRate", MPO."INVMPO_TotTax", MPO."INVMPO_TotAmount", TPO."INVTPO_Remarks", TPO."INVTPO_ActiveFlg", 
        MPO."INVMPO_ActiveFlg", MPO."INVMPO_Remarks", ins."MI_Name", MPO."INVMPO_RejectFlg", MPO."INVMPO_FinalProcessFlag"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        LEFT JOIN "master_institution" ins ON ins."MI_Id" = TPO."MI_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND TPO."INVMI_Id" IN (' || "INVMI_Ids" || ') AND MPO."MI_Id" IN (' || "MI_Id" || ') ' || "dates" || ' ' || "flg";

        RETURN QUERY EXECUTE "Slqdymaic";

    ELSIF "optionflag" = 'Supplier' THEN
        "Slqdymaic" := '
        SELECT DISTINCT MPO."INVMPO_Id", MPO."INVMS_Id", MPO."INVMPI_Id", MPO."INVMPO_PONo", MPO."INVMPO_PODate", MPO."INVMPO_ReferenceNo",
        MSP."INVMS_SupplierName", MSP."INVMS_SupplierCode",
        TPO."INVMI_Id", MI."INVMI_ItemName", TPO."INVMUOM_Id", UOM."INVMUOM_UOMName", TPO."INVTPO_POQty", TPO."INVTPO_RatePerUnit", 
        TPO."INVTPO_TaxAmount", TPO."INVTPO_Amount",
        MPO."INVMPO_TotRate", MPO."INVMPO_TotTax", MPO."INVMPO_TotAmount", TPO."INVTPO_Remarks", TPO."INVTPO_ActiveFlg", 
        MPO."INVMPO_ActiveFlg", MPO."INVMPO_Remarks", ins."MI_Name", MPO."INVMPO_RejectFlg", MPO."INVMPO_FinalProcessFlag"
        FROM "INV"."INV_M_PurchaseOrder" MPO
        INNER JOIN "INV"."INV_T_PurchaseOrder" TPO ON MPO."INVMPO_Id" = TPO."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" MI ON MI."INVMI_Id" = TPO."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" UOM ON UOM."INVMUOM_Id" = TPO."INVMUOM_Id"
        INNER JOIN "INV"."INV_Master_Supplier" MSP ON MPO."INVMS_Id" = MSP."INVMS_Id"
        LEFT JOIN "master_institution" ins ON ins."MI_Id" = TPO."MI_Id"
        WHERE MPO."INVMPO_ActiveFlg" = TRUE AND TPO."INVTPO_ActiveFlg" = TRUE AND MPO."INVMS_Id" IN (' || "INVMS_Ids" || ') AND MPO."MI_Id" IN (' || "MI_Id" || ') ' || "dates" || ' ' || "flg";

        RETURN QUERY EXECUTE "Slqdymaic";

    END IF;

    RETURN;

END;
$$;