CREATE OR REPLACE FUNCTION "dbo"."getsettlementsummation"(
    "@MI_Id" bigint,
    "@Asmay_Id" bigint,
    "@FYPPSD_Idmax" bigint,
    "@User_Id" bigint
)
RETURNS TABLE(
    "FYPPSD_Payment_Mode" TEXT,
    "SettmentAmount" NUMERIC,
    "TransactionDate" DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@FYPPST_Settlement_Id" TEXT;
    "@FYPPST_Settlement_Date" TEXT;
    "@FYPPST_Settlement_Amount" TEXT;
    "@FYPPST_Id" bigint;
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "FYPPSD_Payment_Mode",
        SUM("FYPPSD_Transaction_amount") AS "SettmentAmount",
        CAST("FYPPSD_Transaction_Date" AS DATE) AS "TransactionDate"
    FROM "Fee_Payment_Settlement_Details"
    WHERE "mi_id" = "@MI_Id" 
        AND "FYPPSD_Id" > "@FYPPSD_Idmax"
    GROUP BY "FYPPSD_Payment_Mode", CAST("FYPPSD_Transaction_Date" AS DATE);

    RETURN;
END;
$$;