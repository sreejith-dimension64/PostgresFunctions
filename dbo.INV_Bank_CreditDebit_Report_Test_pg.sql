CREATE OR REPLACE FUNCTION "dbo"."INV_Bank_CreditDebit_Report_Test"(
    "@MI_Id" bigint,
    "@FROMDATE" TIMESTAMP,
    "@TODATE" TIMESTAMP
)
RETURNS TABLE(
    "Month" TEXT,
    "TotalDebit" NUMERIC,
    "TotalCredit" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "#debit";
    DROP TABLE IF EXISTS "#credit";

    CREATE TEMP TABLE "#debit" AS
    SELECT 
        TO_CHAR("INVSPT_PaymentDate", 'Month') || ' ' || CAST(EXTRACT(YEAR FROM "INVSPT_PaymentDate") AS VARCHAR) AS "Month",
        SUM(a."INVSPT_Amount") AS "TotalDebit"
    FROM "INV"."INV_Supplier_Payment" a   
    WHERE a."MI_Id" = "@MI_Id" 
        AND "INVSPT_PaymentDate"::date BETWEEN "@FROMDATE" AND "@TODATE" 
        AND "INVSPT_ModeOfPayment" <> 'Cash'
    GROUP BY TO_CHAR("INVSPT_PaymentDate", 'Month'), EXTRACT(YEAR FROM "INVSPT_PaymentDate"),
             TO_CHAR("INVSPT_PaymentDate", 'YYYY-MM');

    CREATE TEMP TABLE "#credit" AS
    SELECT 
        TO_CHAR("FYP_Date", 'Month') || ' ' || CAST(EXTRACT(YEAR FROM "FYP_Date") AS VARCHAR) AS "Month",
        SUM(a."FYP_Tot_Amount") AS "TotalCredit"
    FROM "Fee_Y_Payment" a
    WHERE a."MI_Id" = "@MI_Id" 
        AND "FYP_Date"::date BETWEEN "@FROMDATE" AND "@TODATE" 
        AND "FYP_Bank_Or_Cash" <> 'C'
    GROUP BY TO_CHAR("FYP_Date", 'Month'), EXTRACT(YEAR FROM "FYP_Date"),
             TO_CHAR("FYP_Date", 'YYYY-MM');

    RETURN QUERY
    SELECT 
        a."Month",
        a."TotalDebit",
        b."TotalCredit"
    FROM "#debit" a 
    LEFT JOIN "#credit" b ON a."Month" = b."Month";

    DROP TABLE IF EXISTS "#debit";
    DROP TABLE IF EXISTS "#credit";

END;
$$;