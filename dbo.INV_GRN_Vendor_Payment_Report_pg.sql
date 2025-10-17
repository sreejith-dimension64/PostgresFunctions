CREATE OR REPLACE FUNCTION "INV"."INV_GRN_Vendor_Payment_Report"(
    "MI_Id" BIGINT,
    "INVMS_Id" BIGINT,
    "Fromdate" TIMESTAMP,
    "Todate" TIMESTAMP
)
RETURNS TABLE(
    "GRNNO" VARCHAR,
    "INVMGRN_PurchaseDate" TIMESTAMP,
    "TotalAmount" NUMERIC,
    "TotalPaidAmount" NUMERIC,
    "BalanceAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        c."INVMGRN_GRNNo" AS "GRNNO",
        c."INVMGRN_PurchaseDate" AS "INVMGRN_PurchaseDate",
        SUM(c."INVMGRN_TotalAmount") AS "TotalAmount",
        SUM(c."INVMGRN_TotalPaid") AS "TotalPaidAmount",
        (SUM(c."INVMGRN_TotTaxAmt" + c."INVMGRN_TotalAmount") - c."INVMGRN_TotalPaid") AS "BalanceAmount"
    FROM "INV"."INV_Supplier_Payment" a
    INNER JOIN "INV"."INV_Supplier_Payment_GRN" b ON a."INVSPT_Id" = b."INVSPT_Id" AND b."INVSPTGRN_ActiveFlg" = 1
    INNER JOIN "INV"."INV_M_GRN" c ON b."INVMGRN_Id" = c."INVMGRN_Id" AND a."INVMS_Id" = c."INVMS_Id"
    INNER JOIN "INV"."INV_Master_Supplier" d ON a."INVMS_Id" = d."INVMS_Id" AND a."MI_Id" = d."MI_Id"
    WHERE a."INVMS_Id" = "INVMS_Id" 
        AND a."MI_Id" = "MI_Id" 
        AND a."INVSPT_ActiveFlg" = 1 
        AND CAST(a."INVSPT_PaymentDate" AS DATE) BETWEEN CAST("Fromdate" AS DATE) AND CAST("Todate" AS DATE) 
        AND c."INVMGRN_ActiveFlg" = 1
    GROUP BY c."INVMGRN_GRNNo", c."INVMGRN_PurchaseDate", c."INVMGRN_TotalAmount", c."INVMGRN_TotalPaid";

END;
$$;