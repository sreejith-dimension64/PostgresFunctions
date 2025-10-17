CREATE OR REPLACE FUNCTION "INV_DateWise_Vendor_Payment_Details"(
    p_MI_Id BIGINT,
    p_FROMDATE TIMESTAMP,
    p_TODATE TIMESTAMP
)
RETURNS TABLE(
    "PaymentDate" DATE,
    "Particular" TEXT,
    "TotalDebit" NUMERIC,
    "TotalCredit" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS temp_INVDEBIT;
    DROP TABLE IF EXISTS temp_INVCREDIT;

    CREATE TEMP TABLE temp_INVDEBIT AS
    SELECT 
        CAST(a."INVSPT_PaymentDate" AS DATE) AS "PaymentDate",
        a."INVSPT_Remarks" AS "Particular",
        a."INVSPT_Amount" AS "TotalDebit"
    FROM "INV"."INV_Supplier_Payment" a   
    WHERE a."MI_Id" = 30 
        AND CAST(a."INVSPT_PaymentDate" AS DATE) BETWEEN '2024-05-01' AND '2024-05-22' 
        AND a."INVSPT_ModeOfPayment" <> 'Cash';

    CREATE TEMP TABLE temp_INVCREDIT AS
    SELECT 
        CAST(a."FYP_Date" AS DATE) AS "PaymentDate",
        a."FYP_Tot_Amount" AS "TotalCredit"
    FROM "Fee_Y_Payment" a
    WHERE a."MI_Id" = 30 
        AND CAST(a."FYP_Date" AS DATE) BETWEEN '2024-05-01' AND '2024-05-22' 
        AND a."FYP_Bank_Or_Cash" <> 'C';

    RETURN QUERY
    SELECT 
        A."PaymentDate",
        A."Particular",
        A."TotalDebit",
        B."TotalCredit"
    FROM temp_INVDEBIT A 
    INNER JOIN temp_INVCREDIT B ON A."PaymentDate" = B."PaymentDate";

    DROP TABLE IF EXISTS temp_INVDEBIT;
    DROP TABLE IF EXISTS temp_INVCREDIT;

END;
$$;