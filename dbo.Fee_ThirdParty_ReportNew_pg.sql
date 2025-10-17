CREATE OR REPLACE FUNCTION "Fee_ThirdParty_ReportNew"(
    "frmdate" TIMESTAMP,
    "todate" TIMESTAMP,
    "mid" BIGINT,
    "ayar" BIGINT
)
RETURNS TABLE(
    "name" VARCHAR,
    "receiptno" VARCHAR,
    "fypdate" VARCHAR,
    "bankname" VARCHAR,
    "bankorcash" VARCHAR,
    "chequno" VARCHAR,
    "chequedate" VARCHAR,
    "paidamt" NUMERIC,
    "towords" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "B"."FYPTP_Name" AS "name",
        "A"."FYP_Receipt_No" AS "receiptno",
        TO_CHAR("A"."FYP_date", 'DD/MM/YYYY') AS "fypdate",
        "A"."FYP_Bank_Name" AS "bankname",
        "A"."FYP_Bank_Or_Cash" AS "bankorcash",
        "A"."FYP_DD_Cheque_No" AS "chequno",
        TO_CHAR("A"."FYP_DD_Cheque_Date", 'DD/MM/YYYY') AS "chequedate",
        "A"."FYP_Tot_Amount" AS "paidamt",
        "A"."FYP_Remarks" AS "towords"
    FROM "Fee_Y_Payment" "A"
    INNER JOIN "Fee_Y_Payment_ThirdParty" "B" ON "A"."FYP_Id" = "B"."FYP_Id"
    INNER JOIN "Fee_Master_Head" "C" ON "C"."MI_Id" = "A"."MI_Id" AND "B"."FMH_Id" = "C"."FMH_Id"
    WHERE "A"."ASMAY_ID" = "ayar" 
        AND "A"."MI_Id" = "mid" 
        AND "A"."FYP_Date"::DATE BETWEEN "frmdate"::DATE AND "todate"::DATE;
END;
$$;