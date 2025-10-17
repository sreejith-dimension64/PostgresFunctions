CREATE OR REPLACE FUNCTION "INV"."INV_VendorPayment_Report"(
    p_MI_Id BIGINT,
    p_INVMS_Id BIGINT,
    p_INVMGRN_Id BIGINT,
    p_optionflag VARCHAR(50),
    p_Fromdate TIMESTAMP,
    p_Todate TIMESTAMP
)
RETURNS TABLE(
    "INVSPT_Id" BIGINT,
    "INVMS_Id" BIGINT,
    "INVMS_SupplierName" VARCHAR,
    "INVSPT_PaymentDate" TIMESTAMP,
    "INVSPT_ModeOfPayment" VARCHAR,
    "INVSPT_PaymentReference" VARCHAR,
    "INVSPT_ChequeDDNo" VARCHAR,
    "INVSPT_BankName" VARCHAR,
    "INVSPT_ChequeDDDate" TIMESTAMP,
    "INVSPT_Amount" NUMERIC,
    "INVSPT_Remarks" VARCHAR,
    "INVSPTGRN_Id" BIGINT,
    "INVMGRN_Id" BIGINT,
    "INVMGRN_GRNNo" VARCHAR,
    "INVSPTGRN_Amount" NUMERIC,
    "INVMGRN_TotalPaid" NUMERIC,
    "INVMGRN_TotalBalance" NUMERIC,
    "INVSPTGRN_ActiveFlg" BOOLEAN,
    "INVSPTGRN_Remarks" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_optionflag = 'Supplier') THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "INVSPT_Id",
            a."INVMS_Id",
            d."INVMS_SupplierName",
            a."INVSPT_PaymentDate",
            a."INVSPT_ModeOfPayment",
            a."INVSPT_PaymentReference",
            a."INVSPT_ChequeDDNo",
            a."INVSPT_BankName",
            a."INVSPT_ChequeDDDate",
            NULL::NUMERIC AS "INVSPT_Amount",
            a."INVSPT_Remarks",
            NULL::BIGINT AS "INVSPTGRN_Id",
            b."INVMGRN_Id",
            c."INVMGRN_GRNNo",
            b."INVSPTGRN_Amount",
            c."INVMGRN_TotalPaid",
            c."INVMGRN_TotalBalance",
            b."INVSPTGRN_ActiveFlg",
            NULL::VARCHAR AS "INVSPTGRN_Remarks"
        FROM "INV"."INV_Supplier_Payment" a
        INNER JOIN "INV"."INV_Supplier_Payment_GRN" b ON a."INVSPT_Id" = b."INVSPT_Id" AND b."INVSPTGRN_ActiveFlg" = TRUE
        INNER JOIN "INV"."INV_M_GRN" c ON b."INVMGRN_Id" = c."INVMGRN_Id" AND a."INVMS_Id" = c."INVMS_Id"
        INNER JOIN "INV"."INV_Master_Supplier" d ON a."INVMS_Id" = d."INVMS_Id" AND a."MI_Id" = d."MI_Id"
        WHERE a."INVSPT_ActiveFlg" = TRUE 
            AND a."MI_Id" = p_MI_Id 
            AND a."INVMS_Id" = p_INVMS_Id
            AND CAST(a."INVSPT_PaymentDate" AS DATE) BETWEEN CAST(p_Fromdate AS DATE) AND CAST(p_Todate AS DATE)
        ORDER BY c."INVMGRN_GRNNo";
    END IF;

    IF (p_optionflag = 'GRN') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVSPT_Id",
            a."INVMS_Id",
            d."INVMS_SupplierName",
            a."INVSPT_PaymentDate",
            a."INVSPT_ModeOfPayment",
            a."INVSPT_PaymentReference",
            a."INVSPT_ChequeDDNo",
            a."INVSPT_BankName",
            a."INVSPT_ChequeDDDate",
            a."INVSPT_Amount",
            a."INVSPT_Remarks",
            b."INVSPTGRN_Id",
            b."INVMGRN_Id",
            c."INVMGRN_GRNNo",
            b."INVSPTGRN_Amount",
            NULL::NUMERIC AS "INVMGRN_TotalPaid",
            NULL::NUMERIC AS "INVMGRN_TotalBalance",
            b."INVSPTGRN_ActiveFlg",
            b."INVSPTGRN_Remarks"
        FROM "INV"."INV_Supplier_Payment" a
        INNER JOIN "INV"."INV_Supplier_Payment_GRN" b ON a."INVSPT_Id" = b."INVSPT_Id" AND b."INVSPTGRN_ActiveFlg" = TRUE
        INNER JOIN "INV"."INV_M_GRN" c ON b."INVMGRN_Id" = c."INVMGRN_Id" AND a."INVMS_Id" = c."INVMS_Id"
        INNER JOIN "INV"."INV_Master_Supplier" d ON a."INVMS_Id" = d."INVMS_Id" AND a."MI_Id" = d."MI_Id"
        WHERE a."INVSPT_ActiveFlg" = TRUE 
            AND a."MI_Id" = p_MI_Id 
            AND b."INVMGRN_Id" = p_INVMGRN_Id
            AND CAST(a."INVSPT_PaymentDate" AS DATE) BETWEEN CAST(p_Fromdate AS DATE) AND CAST(p_Todate AS DATE)
        ORDER BY c."INVMGRN_GRNNo";
    END IF;

    RETURN;

END;
$$;