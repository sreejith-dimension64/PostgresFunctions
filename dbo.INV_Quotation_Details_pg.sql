CREATE OR REPLACE FUNCTION "INV"."INV_Quotation_Details"(
    "p_MI_Id" BIGINT,
    "p_optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMSQ_Id" BIGINT,
    "INVMSQ_QuotationNo" TEXT,
    "INVMPI_Id" BIGINT,
    "INVMPI_PINo" TEXT,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" TEXT,
    "INVMI_ItemCode" TEXT,
    "INVMSQ_SupplierName" TEXT,
    "INVMSQ_SupplierContactNo" TEXT,
    "INVMSQ_SupplierEmailId" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "p_optionflag" = 'QuoteNo' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "INV_M_SupplierQuotation"."INVMSQ_Id",
            "INV_M_SupplierQuotation"."INVMSQ_QuotationNo",
            NULL::BIGINT AS "INVMPI_Id",
            NULL::TEXT AS "INVMPI_PINo",
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            NULL::TEXT AS "INVMSQ_SupplierName",
            NULL::TEXT AS "INVMSQ_SupplierContactNo",
            NULL::TEXT AS "INVMSQ_SupplierEmailId"
        FROM "INV"."INV_M_SupplierQuotation"
        WHERE "MI_Id" = "p_MI_Id" AND "INVMSQ_ActiveFlg" = true
        ORDER BY "INVMSQ_Id";

    ELSIF "p_optionflag" = 'PINo' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMSQ_Id",
            NULL::TEXT AS "INVMSQ_QuotationNo",
            a."INVMPI_Id",
            a."INVMPI_PINo",
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            NULL::TEXT AS "INVMSQ_SupplierName",
            NULL::TEXT AS "INVMSQ_SupplierContactNo",
            NULL::TEXT AS "INVMSQ_SupplierEmailId"
        FROM "INV"."INV_M_PurchaseIndent" a
        INNER JOIN "INV"."INV_M_SupplierQuotation" b ON a."INVMPI_Id" = b."INVMPI_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."MI_Id" = "p_MI_Id" AND a."INVMPI_ActiveFlg" = true AND b."INVMSQ_ActiveFlg" = true
        ORDER BY a."INVMPI_Id";

    ELSIF "p_optionflag" = 'Item' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVMSQ_Id",
            NULL::TEXT AS "INVMSQ_QuotationNo",
            NULL::BIGINT AS "INVMPI_Id",
            NULL::TEXT AS "INVMPI_PINo",
            a."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode",
            NULL::TEXT AS "INVMSQ_SupplierName",
            NULL::TEXT AS "INVMSQ_SupplierContactNo",
            NULL::TEXT AS "INVMSQ_SupplierEmailId"
        FROM "INV"."INV_Master_Item" a,
             "INV"."INV_M_SupplierQuotation" b,
             "INV"."INV_T_SupplierQuotation" c
        WHERE a."INVMI_Id" = c."INVMI_Id" AND b."INVMSQ_Id" = c."INVMSQ_Id" AND a."MI_Id" = "p_MI_Id"
        ORDER BY a."INVMI_ItemName";

    ELSIF "p_optionflag" = 'Supplier' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "INVMSQ_Id",
            NULL::TEXT AS "INVMSQ_QuotationNo",
            NULL::BIGINT AS "INVMPI_Id",
            NULL::TEXT AS "INVMPI_PINo",
            NULL::BIGINT AS "INVMI_Id",
            NULL::TEXT AS "INVMI_ItemName",
            NULL::TEXT AS "INVMI_ItemCode",
            "INVMSQ_SupplierName",
            "INVMSQ_SupplierContactNo",
            "INVMSQ_SupplierEmailId"
        FROM "INV"."INV_M_SupplierQuotation"
        WHERE "MI_Id" = "p_MI_Id" AND "INVMSQ_ActiveFlg" = true
        ORDER BY "INVMSQ_Id";

    END IF;

    RETURN;

END;
$$;