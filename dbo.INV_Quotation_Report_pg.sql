CREATE OR REPLACE FUNCTION "dbo"."INV_Quotation_Report" (
    "MI_Id" BIGINT, 
    "startdate" VARCHAR(10), 
    "enddate" VARCHAR(10),
    "INVMSQ_Ids" VARCHAR(100), 
    "PI_Ids" VARCHAR(100),  
    "INVMI_Ids" VARCHAR(100), 
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMSQ_Id" BIGINT,
    "INVMPI_Id" BIGINT,
    "INVMSQ_QuotationNo" VARCHAR,
    "INVMSQ_Quotation" VARCHAR,
    "INVMSQ_SupplierName" VARCHAR,
    "INVMSQ_SupplierContactNo" VARCHAR,
    "INVMSQ_SupplierEmailId" VARCHAR,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMUOM_Id" BIGINT,
    "INVMUOM_UOMName" VARCHAR,
    "INVTSQ_QuotedRate" NUMERIC,
    "INVTSQ_NegotiatedRate" NUMERIC,
    "INVTSQ_FinaliseFlg" BOOLEAN,
    "INVTSQ_ActiveFlg" BOOLEAN,
    "INVMSQ_TotalQuotedRate" NUMERIC,
    "INVMSQ_NegotiatedRate" NUMERIC,
    "INVMSQ_ActiveFlg" BOOLEAN,
    "INVMSQ_FinaliseFlg" BOOLEAN,
    "INVMSQ_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "dates" VARCHAR(200);
BEGIN
    IF "startdate" != '' AND "enddate" != '' THEN
        "dates" := 'AND "CreatedDate"::date BETWEEN TO_DATE(''' || "startdate" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "dates" := '';
    END IF;
  
    IF ("optionflag" = 'All') THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSQ"."INVMSQ_Id", "MSQ"."INVMPI_Id", "MSQ"."INVMSQ_QuotationNo", "MSQ"."INVMSQ_Quotation", 
        "MSQ"."INVMSQ_SupplierName", "MSQ"."INVMSQ_SupplierContactNo", "MSQ"."INVMSQ_SupplierEmailId",
        "TSQ"."INVMI_Id", "MI"."INVMI_ItemName", "TSQ"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", 
        "TSQ"."INVTSQ_QuotedRate", "TSQ"."INVTSQ_NegotiatedRate", "TSQ"."INVTSQ_FinaliseFlg", "TSQ"."INVTSQ_ActiveFlg",
        "MSQ"."INVMSQ_TotalQuotedRate", "MSQ"."INVMSQ_NegotiatedRate", "MSQ"."INVMSQ_ActiveFlg", 
        "MSQ"."INVMSQ_FinaliseFlg", "MSQ"."INVMSQ_Remarks"
        FROM "INV"."INV_M_SupplierQuotation" "MSQ"
        INNER JOIN "INV"."INV_T_SupplierQuotation" "TSQ" ON "MSQ"."INVMSQ_Id" = "TSQ"."INVMSQ_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TSQ"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TSQ"."INVMUOM_Id"
        WHERE "MSQ"."INVMSQ_ActiveFlg" = TRUE AND "TSQ"."INVTSQ_ActiveFlg" = TRUE 
        AND "MSQ"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'QuoteNo' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSQ"."INVMSQ_Id", "MSQ"."INVMPI_Id", "MSQ"."INVMSQ_QuotationNo", "MSQ"."INVMSQ_Quotation", 
        "MSQ"."INVMSQ_SupplierName", "MSQ"."INVMSQ_SupplierContactNo", "MSQ"."INVMSQ_SupplierEmailId",
        "TSQ"."INVMI_Id", "MI"."INVMI_ItemName", "TSQ"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", 
        "TSQ"."INVTSQ_QuotedRate", "TSQ"."INVTSQ_NegotiatedRate", "TSQ"."INVTSQ_FinaliseFlg", "TSQ"."INVTSQ_ActiveFlg",
        "MSQ"."INVMSQ_TotalQuotedRate", "MSQ"."INVMSQ_NegotiatedRate", "MSQ"."INVMSQ_ActiveFlg", 
        "MSQ"."INVMSQ_FinaliseFlg", "MSQ"."INVMSQ_Remarks"
        FROM "INV"."INV_M_SupplierQuotation" "MSQ"
        INNER JOIN "INV"."INV_T_SupplierQuotation" "TSQ" ON "MSQ"."INVMSQ_Id" = "TSQ"."INVMSQ_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TSQ"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TSQ"."INVMUOM_Id"
        WHERE "MSQ"."INVMSQ_ActiveFlg" = TRUE AND "TSQ"."INVTSQ_ActiveFlg" = TRUE 
        AND "MSQ"."INVMSQ_Id" IN (' || "INVMSQ_Ids" || ') 
        AND "MSQ"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'PINo' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSQ"."INVMSQ_Id", "MSQ"."INVMPI_Id", "MSQ"."INVMSQ_QuotationNo", "MSQ"."INVMSQ_Quotation", 
        "MSQ"."INVMSQ_SupplierName", "MSQ"."INVMSQ_SupplierContactNo", "MSQ"."INVMSQ_SupplierEmailId",
        "TSQ"."INVMI_Id", "MI"."INVMI_ItemName", "TSQ"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", 
        "TSQ"."INVTSQ_QuotedRate", "TSQ"."INVTSQ_NegotiatedRate", "TSQ"."INVTSQ_FinaliseFlg", "TSQ"."INVTSQ_ActiveFlg",
        "MSQ"."INVMSQ_TotalQuotedRate", "MSQ"."INVMSQ_NegotiatedRate", "MSQ"."INVMSQ_ActiveFlg", 
        "MSQ"."INVMSQ_FinaliseFlg", "MSQ"."INVMSQ_Remarks"
        FROM "INV"."INV_M_SupplierQuotation" "MSQ"
        INNER JOIN "INV"."INV_T_SupplierQuotation" "TSQ" ON "MSQ"."INVMSQ_Id" = "TSQ"."INVMSQ_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TSQ"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TSQ"."INVMUOM_Id"
        WHERE "MSQ"."INVMSQ_ActiveFlg" = TRUE AND "TSQ"."INVTSQ_ActiveFlg" = TRUE 
        AND "MSQ"."INVMPI_Id" IN (' || "PI_Ids" || ') 
        AND "MSQ"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Item' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSQ"."INVMSQ_Id", "MSQ"."INVMPI_Id", "MSQ"."INVMSQ_QuotationNo", "MSQ"."INVMSQ_Quotation", 
        "MSQ"."INVMSQ_SupplierName", "MSQ"."INVMSQ_SupplierContactNo", "MSQ"."INVMSQ_SupplierEmailId",
        "TSQ"."INVMI_Id", "MI"."INVMI_ItemName", "TSQ"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", 
        "TSQ"."INVTSQ_QuotedRate", "TSQ"."INVTSQ_NegotiatedRate", "TSQ"."INVTSQ_FinaliseFlg", "TSQ"."INVTSQ_ActiveFlg",
        "MSQ"."INVMSQ_TotalQuotedRate", "MSQ"."INVMSQ_NegotiatedRate", "MSQ"."INVMSQ_ActiveFlg", 
        "MSQ"."INVMSQ_FinaliseFlg", "MSQ"."INVMSQ_Remarks"
        FROM "INV"."INV_M_SupplierQuotation" "MSQ"
        INNER JOIN "INV"."INV_T_SupplierQuotation" "TSQ" ON "MSQ"."INVMSQ_Id" = "TSQ"."INVMSQ_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TSQ"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TSQ"."INVMUOM_Id"
        WHERE "MSQ"."INVMSQ_ActiveFlg" = TRUE AND "TSQ"."INVTSQ_ActiveFlg" = TRUE 
        AND "TSQ"."INVMI_Id" IN (' || "INVMI_Ids" || ') 
        AND "MSQ"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
        
    ELSIF "optionflag" = 'Supplier' THEN
        "Slqdymaic" := '
        SELECT DISTINCT "MSQ"."INVMSQ_Id", "MSQ"."INVMPI_Id", "MSQ"."INVMSQ_QuotationNo", "MSQ"."INVMSQ_Quotation", 
        "MSQ"."INVMSQ_SupplierName", "MSQ"."INVMSQ_SupplierContactNo", "MSQ"."INVMSQ_SupplierEmailId",
        "TSQ"."INVMI_Id", "MI"."INVMI_ItemName", "TSQ"."INVMUOM_Id", "UOM"."INVMUOM_UOMName", 
        "TSQ"."INVTSQ_QuotedRate", "TSQ"."INVTSQ_NegotiatedRate", "TSQ"."INVTSQ_FinaliseFlg", "TSQ"."INVTSQ_ActiveFlg",
        "MSQ"."INVMSQ_TotalQuotedRate", "MSQ"."INVMSQ_NegotiatedRate", "MSQ"."INVMSQ_ActiveFlg", 
        "MSQ"."INVMSQ_FinaliseFlg", "MSQ"."INVMSQ_Remarks"
        FROM "INV"."INV_M_SupplierQuotation" "MSQ"
        INNER JOIN "INV"."INV_T_SupplierQuotation" "TSQ" ON "MSQ"."INVMSQ_Id" = "TSQ"."INVMSQ_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TSQ"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TSQ"."INVMUOM_Id"
        WHERE "MSQ"."INVMSQ_ActiveFlg" = TRUE AND "TSQ"."INVTSQ_ActiveFlg" = TRUE 
        AND "MSQ"."INVMSQ_Id" IN (' || "INVMSQ_Ids" || ') 
        AND "MSQ"."MI_Id" = ' || "MI_Id"::TEXT || ' ' || "dates";
        
        RETURN QUERY EXECUTE "Slqdymaic";
    END IF;

    RETURN;
END;
$$;