CREATE OR REPLACE FUNCTION "dbo"."Datewisefeeamtdetailstemp"(
    p_ASMAY_Id VARCHAR(100),
    p_MI_Id VARCHAR(100),
    p_fromdate DATE,
    p_todate DATE
)
RETURNS TABLE (
    "FYP_Date" DATE,
    "online" NUMERIC,
    "bank" NUMERIC,
    "cash" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CAST("FYP"."FYP_Date" AS DATE) AS "FYP_Date",
        (SELECT SUM("FYP_Tot_Amount") 
         FROM "dbo"."Fee_Y_Payment" 
         WHERE "MI_Id" = p_MI_Id 
           AND "ASMAY_Id" = p_ASMAY_Id 
           AND "FYP_Bank_Or_Cash" = 'O' 
           AND "FYP_Date" BETWEEN p_fromdate AND p_todate) AS "online",
        (SELECT SUM("FYP_Tot_Amount") 
         FROM "dbo"."Fee_Y_Payment" 
         WHERE "MI_Id" = p_MI_Id 
           AND "ASMAY_Id" = p_ASMAY_Id 
           AND "FYP_Bank_Or_Cash" = 'B' 
           AND "FYP_Date" BETWEEN p_fromdate AND p_todate) AS "bank",
        (SELECT SUM("FYP_Tot_Amount") 
         FROM "dbo"."Fee_Y_Payment" 
         WHERE "MI_Id" = p_MI_Id 
           AND "ASMAY_Id" = p_ASMAY_Id 
           AND "FYP_Bank_Or_Cash" = 'C' 
           AND "FYP_Date" BETWEEN p_fromdate AND p_todate) AS "cash"
    FROM "dbo"."Fee_Y_Payment" "FYP"
    LEFT JOIN "Adm_School_M_Academic_Year" "ASMAY" 
        ON "ASMAY"."ASMAY_Id" = "FYP"."ASMAY_ID" 
        AND "ASMAY"."MI_Id" = "FYP"."MI_Id"
    WHERE "ASMAY"."ASMAY_Id" = p_ASMAY_Id 
      AND "ASMAY"."MI_Id" = p_MI_Id 
      AND "FYP"."MI_Id" = p_MI_Id 
      AND "FYP"."ASMAY_Id" = p_ASMAY_Id 
      AND "FYP"."FYP_Date" BETWEEN p_fromdate AND p_todate
    GROUP BY "FYP"."FYP_Date";
END;
$$;