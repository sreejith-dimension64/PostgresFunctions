CREATE OR REPLACE FUNCTION "INV_Vendor_Monthwise_Payment_Details"(
    "@MI_Id" BIGINT,
    "@FROMDATE" TIMESTAMP,
    "@TODATE" TIMESTAMP
)
RETURNS TABLE(
    "Month" TEXT,
    "TotalDebit" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TO_CHAR("a"."INVSPT_PaymentDate", 'Month') || ' ' || CAST(EXTRACT(YEAR FROM "a"."INVSPT_PaymentDate") AS TEXT) AS "Month",
        SUM("a"."INVSPT_Amount") AS "TotalDebit"
    FROM "INV"."INV_Supplier_Payment" "a"
    WHERE "a"."MI_Id" = "@MI_Id" 
        AND CAST("a"."INVSPT_PaymentDate" AS DATE) BETWEEN CAST("@FROMDATE" AS DATE) AND CAST("@TODATE" AS DATE)
        AND "a"."INVSPT_ModeOfPayment" <> 'Cash'
    GROUP BY TO_CHAR("a"."INVSPT_PaymentDate", 'Month'), EXTRACT(YEAR FROM "a"."INVSPT_PaymentDate")
    ORDER BY EXTRACT(YEAR FROM "a"."INVSPT_PaymentDate"), EXTRACT(MONTH FROM "a"."INVSPT_PaymentDate");
END;
$$;