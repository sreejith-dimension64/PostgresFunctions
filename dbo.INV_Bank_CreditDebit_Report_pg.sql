CREATE OR REPLACE FUNCTION "dbo"."INV_Bank_CreditDebit_Report"(
    "@MI_Id" bigint,
    "@MONTH" VARCHAR(20),
    "@YEAR" VARCHAR(20)
)
RETURNS TABLE(
    "Month" TEXT,
    "TotalDebit" NUMERIC,
    "TotalCredit" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "temp_debit";
    DROP TABLE IF EXISTS "temp_credit";

    CREATE TEMP TABLE "temp_debit" AS
    SELECT TO_CHAR("INVSPT_PaymentDate", 'Month') || ',' || CAST(EXTRACT(YEAR FROM "INVSPT_PaymentDate") AS VARCHAR) AS "Month",
           SUM(a."INVSPT_Amount") AS "TotalDebit"
    FROM "INV"."INV_Supplier_Payment" a   
    WHERE a."MI_Id" = "@MI_Id" 
      AND EXTRACT(MONTH FROM "INVSPT_PaymentDate") = "@MONTH"::INTEGER 
      AND EXTRACT(YEAR FROM "INVSPT_PaymentDate") = "@YEAR"::INTEGER 
      AND "INVSPT_ModeOfPayment" <> 'Cash'
    GROUP BY TO_CHAR("INVSPT_PaymentDate", 'Month'), EXTRACT(YEAR FROM "INVSPT_PaymentDate");

    CREATE TEMP TABLE "temp_credit" AS
    SELECT TO_CHAR("FYP_Date", 'Month') || ',' || CAST(EXTRACT(YEAR FROM "FYP_Date") AS VARCHAR) AS "Month",
           SUM(a."FYP_Tot_Amount") AS "TotalCredit"
    FROM "Fee_Y_Payment" a
    WHERE a."MI_Id" = "@MI_Id"
      AND EXTRACT(MONTH FROM "FYP_Date") = "@MONTH"::INTEGER 
      AND EXTRACT(YEAR FROM "FYP_Date") = "@YEAR"::INTEGER  
      AND "FYP_Bank_Or_Cash" <> 'C'
    GROUP BY TO_CHAR("FYP_Date", 'Month'), EXTRACT(YEAR FROM "FYP_Date");

    RETURN QUERY
    SELECT a."Month", a."TotalDebit", b."TotalCredit"
    FROM "temp_debit" a 
    LEFT JOIN "temp_credit" b ON a."Month" = b."Month";

    DROP TABLE IF EXISTS "temp_debit";
    DROP TABLE IF EXISTS "temp_credit";

END;
$$;