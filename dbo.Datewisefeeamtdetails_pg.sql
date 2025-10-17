CREATE OR REPLACE FUNCTION "dbo"."Datewisefeeamtdetails"(
    p_ASMAY_Id VARCHAR(100),
    p_MI_Id VARCHAR(100),
    p_fromdate DATE,
    p_todate DATE
)
RETURNS TABLE(
    "FYP_Date" DATE,
    "Online" NUMERIC,
    "Bank" NUMERIC,
    "Cash" NUMERIC,
    "total" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CAST("FYP"."FYP_Date" AS DATE) AS "FYP_Date",
        SUM(COALESCE((CASE WHEN "FYP"."FYP_Bank_Or_Cash" = 'O' THEN "FYP"."FYP_Tot_Amount" END), 0)) AS "Online",
        SUM(COALESCE((CASE WHEN "FYP"."FYP_Bank_Or_Cash" = 'B' THEN "FYP"."FYP_Tot_Amount" END), 0)) AS "Bank",
        SUM(COALESCE((CASE WHEN "FYP"."FYP_Bank_Or_Cash" = 'C' THEN "FYP"."FYP_Tot_Amount" END), 0)) AS "Cash",
        SUM("FYP"."FYP_Tot_Amount") AS "total"
    FROM "dbo"."Fee_Y_Payment" "FYP"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "FYP"."ASMAY_ID" 
        AND "ASMAY"."MI_Id" = "FYP"."MI_Id"
    WHERE "ASMAY"."ASMAY_Id" = p_ASMAY_Id 
        AND "ASMAY"."MI_Id" = p_MI_Id 
        AND "FYP"."FYP_Date" BETWEEN p_fromdate AND p_todate
    GROUP BY CAST("FYP"."FYP_Date" AS DATE);
END;
$$;