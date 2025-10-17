CREATE OR REPLACE FUNCTION "INV"."INV_VendorPayment_Report_Datewise"(
    "p_MI_Id" BIGINT,
    "p_Fromdate" TIMESTAMP,
    "p_Todate" TIMESTAMP,
    "p_Flag" VARCHAR(100)
)
RETURNS TABLE (
    "INVMS_Id" BIGINT,
    "VendorName" VARCHAR,
    "INVSPT_PaymentDate" TIMESTAMP,
    "INVSPT_ModeOfPayment" VARCHAR,
    "INVSPT_PaymentReference" VARCHAR,
    "INVSPT_ChequeDDNo" VARCHAR,
    "INVSPT_BankName" VARCHAR,
    "INVSPT_ChequeDDDate" TIMESTAMP,
    "INVMGRN_Id" BIGINT,
    "INVMGRN_GRNNo" VARCHAR,
    "INVSPTGRN_Amount" NUMERIC,
    "INVMGRN_TotalPaid" NUMERIC,
    "INVMGRN_TotalBalance" NUMERIC,
    "INVSPTGRN_ActiveFlg" BOOLEAN,
    "INVSPT_Remarks" TEXT,
    "GSTNo" VARCHAR,
    "TotalAmount" NUMERIC,
    "TotalPaidAmount" NUMERIC,
    "BalanceAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF("p_Flag" = 'Overall') THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMS_Id",
            d."INVMS_SupplierName",
            a."INVSPT_PaymentDate",
            a."INVSPT_ModeOfPayment",
            a."INVSPT_PaymentReference",
            a."INVSPT_ChequeDDNo",
            a."INVSPT_BankName",
            a."INVSPT_ChequeDDDate",
            b."INVMGRN_Id",
            c."INVMGRN_GRNNo",
            b."INVSPTGRN_Amount",
            c."INVMGRN_TotalPaid",
            c."INVMGRN_TotalBalance",
            b."INVSPTGRN_ActiveFlg",
            a."INVSPT_Remarks",
            NULL::VARCHAR AS "GSTNo",
            NULL::NUMERIC AS "TotalAmount",
            NULL::NUMERIC AS "TotalPaidAmount",
            NULL::NUMERIC AS "BalanceAmount"
        FROM "INV"."INV_Supplier_Payment" a
        INNER JOIN "INV"."INV_Supplier_Payment_GRN" b ON a."INVSPT_Id" = b."INVSPT_Id" AND b."INVSPTGRN_ActiveFlg" = true
        INNER JOIN "INV"."INV_M_GRN" c ON b."INVMGRN_Id" = c."INVMGRN_Id" AND a."INVMS_Id" = c."INVMS_Id"
        INNER JOIN "INV"."INV_Master_Supplier" d ON a."INVMS_Id" = d."INVMS_Id" AND a."MI_Id" = d."MI_Id"
        WHERE a."INVSPT_ActiveFlg" = true 
            AND a."MI_Id" = "p_MI_Id" 
            AND c."INVMGRN_ActiveFlg" = true
            AND CAST(a."INVSPT_PaymentDate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE)
        ORDER BY c."INVMGRN_GRNNo";
        
    ELSIF("p_Flag" = 'Vendor') THEN
    
        RETURN QUERY
        SELECT 
            a."INVMS_Id",
            d."INVMS_SupplierName" AS "VendorName",
            NULL::TIMESTAMP AS "INVSPT_PaymentDate",
            NULL::VARCHAR AS "INVSPT_ModeOfPayment",
            NULL::VARCHAR AS "INVSPT_PaymentReference",
            NULL::VARCHAR AS "INVSPT_ChequeDDNo",
            NULL::VARCHAR AS "INVSPT_BankName",
            NULL::TIMESTAMP AS "INVSPT_ChequeDDDate",
            NULL::BIGINT AS "INVMGRN_Id",
            NULL::VARCHAR AS "INVMGRN_GRNNo",
            NULL::NUMERIC AS "INVSPTGRN_Amount",
            NULL::NUMERIC AS "INVMGRN_TotalPaid",
            NULL::NUMERIC AS "INVMGRN_TotalBalance",
            NULL::BOOLEAN AS "INVSPTGRN_ActiveFlg",
            NULL::TEXT AS "INVSPT_Remarks",
            COALESCE(d."INVMS_GSTNo", '') AS "GSTNo",
            SUM(c."INVMGRN_PurchaseValue") AS "TotalAmount",
            SUM(c."INVMGRN_TotalPaid") AS "TotalPaidAmount",
            SUM(c."INVMGRN_PurchaseValue" - c."INVMGRN_TotalPaid") AS "BalanceAmount"
        FROM "INV"."INV_Supplier_Payment" a
        INNER JOIN "INV"."INV_Supplier_Payment_GRN" b ON a."INVSPT_Id" = b."INVSPT_Id" AND b."INVSPTGRN_ActiveFlg" = true
        INNER JOIN "INV"."INV_M_GRN" c ON b."INVMGRN_Id" = c."INVMGRN_Id" AND a."INVMS_Id" = c."INVMS_Id"
        INNER JOIN "INV"."INV_Master_Supplier" d ON a."INVMS_Id" = d."INVMS_Id" AND a."MI_Id" = d."MI_Id"
        WHERE a."INVSPT_ActiveFlg" = true 
            AND a."MI_Id" = "p_MI_Id" 
            AND c."INVMGRN_ActiveFlg" = true
            AND CAST(c."INVMGRN_PurchaseDate" AS DATE) BETWEEN CAST("p_Fromdate" AS DATE) AND CAST("p_Todate" AS DATE)
        GROUP BY d."INVMS_SupplierName", d."INVMS_GSTNo", a."INVMS_Id";
        
    END IF;

END;
$$;