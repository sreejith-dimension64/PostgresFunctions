CREATE OR REPLACE FUNCTION "INV_Vendor_Monthwise_CreditPayment_Details"(
    p_MI_Id BIGINT,
    p_FROMDATE TIMESTAMP,
    p_TODATE TIMESTAMP
)
RETURNS TABLE(
    "Month" TEXT,
    "TotalCredit" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TO_CHAR("FYP_Date", 'Month') || ' ' || CAST(EXTRACT(YEAR FROM "FYP_Date") AS VARCHAR) AS "Month",
        SUM(a."FYP_Tot_Amount") AS "TotalCredit"
    FROM "Fee_Y_Payment" a
    WHERE a."MI_Id" = p_MI_Id 
        AND "FYP_Date"::date BETWEEN p_FROMDATE::date AND p_TODATE::date 
        AND "FYP_Bank_Or_Cash" <> 'C'
    GROUP BY TO_CHAR("FYP_Date", 'Month'), EXTRACT(YEAR FROM "FYP_Date"), DATE_TRUNC('month', "FYP_Date")
    ORDER BY DATE_TRUNC('month', "FYP_Date");
END;
$$;