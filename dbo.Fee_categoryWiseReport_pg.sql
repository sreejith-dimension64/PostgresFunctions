CREATE OR REPLACE FUNCTION "dbo"."Fee_categoryWiseReport" (
    "frmdate" TIMESTAMP,
    "todate" TIMESTAMP,
    "miid" BIGINT,
    "yearid" BIGINT
)
RETURNS TABLE (
    "FMCC_Id" BIGINT,
    "FMH_Id" BIGINT,
    "FMCC_ClassCategoryName" VARCHAR,
    "FMH_FeeName" VARCHAR,
    "B" NUMERIC(10,2),
    "C" NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tab."FMCC_Id",
        tab."FMH_Id",
        tab."FMCC_ClassCategoryName",
        tab."FMH_FeeName",
        COALESCE(SUM(CASE WHEN tab."FYP_Bank_Or_Cash" = 'B' THEN tab.amount END), 0)::NUMERIC(10,2) AS "B",
        COALESCE(SUM(CASE WHEN tab."FYP_Bank_Or_Cash" = 'C' THEN tab.amount END), 0)::NUMERIC(10,2) AS "C"
    FROM (
        SELECT 
            "Fee_Master_Class_Category"."FMCC_Id",
            "Fee_Master_Head"."FMH_Id",
            "Fee_Master_Class_Category"."FMCC_ClassCategoryName",
            "Fee_Master_Head"."FMH_FeeName",
            "Fee_Y_Payment"."FYP_Bank_Or_Cash",
            CAST(SUM("Fee_Y_Payment"."FYP_Tot_Amount") AS NUMERIC(10,2)) AS amount
        FROM
            "Fee_Master_Class_Category"
            INNER JOIN "Fee_Master_Amount" ON "Fee_Master_Amount"."FMCC_Id" = "Fee_Master_Class_Category"."FMCC_Id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Amount"."FMH_Id"
            INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
            INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
        WHERE 
            "Fee_Master_Amount"."MI_Id" = "miid" 
            AND "Fee_Master_Amount"."ASMAY_Id" = "yearid"
            AND "Fee_Y_Payment"."FYP_Date" BETWEEN "frmdate" AND "todate"
        GROUP BY 
            "Fee_Master_Class_Category"."FMCC_Id",
            "Fee_Master_Head"."FMH_Id",
            "Fee_Master_Class_Category"."FMCC_ClassCategoryName",
            "Fee_Master_Head"."FMH_FeeName",
            "Fee_Y_Payment"."FYP_Bank_Or_Cash"
    ) AS tab
    GROUP BY 
        tab."FMCC_Id",
        tab."FMH_Id",
        tab."FMCC_ClassCategoryName",
        tab."FMH_FeeName";
END;
$$;