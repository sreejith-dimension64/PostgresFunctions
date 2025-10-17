CREATE OR REPLACE FUNCTION "dbo"."Classcategorywiseamtdetails"(
    "Mi_Id" VARCHAR(100),
    "ASMAY_Id" VARCHAR(100),
    "FMCC_Id" TEXT
)
RETURNS TABLE(
    "FMCC_ClassCategoryName" VARCHAR,
    "studentcount" BIGINT,
    "Estimatedfeetobecollcted" NUMERIC,
    "Feecollectiontillnow" NUMERIC,
    "Pending" NUMERIC,
    "excess" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    query TEXT;
BEGIN
    query := 'SELECT "FMCC"."FMCC_ClassCategoryName",
                     COUNT(DISTINCT "FSS"."AMST_Id") AS studentcount,
                     SUM("FSS"."FSS_Currentyrcharges") AS Estimatedfeetobecollcted,
                     SUM("FSS"."FSS_PaidAmount") AS Feecollectiontillnow,
                     SUM("FSS"."FSS_Tobepaid") AS Pending,
                     SUM("FSS"."FSS_ExcessPaidAmount") AS excess
              FROM "Fee_Master_Amount" "FMA"
              INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."ASMAY_Id" = "FMA"."ASMAY_Id" 
                  AND "FSS"."MI_Id" = "FMA"."MI_Id" 
                  AND "FMA"."FMA_Id" = "FSS"."FMA_Id"
              INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "FSS"."ASMAY_ID" 
                  AND "ASMAY"."MI_Id" = "FSS"."MI_Id"
              INNER JOIN "Fee_Yearly_Class_Category" "FYCC" ON "ASMAY"."ASMAY_Id" = "FYCC"."ASMAY_ID" 
                  AND "ASMAY"."MI_Id" = "FYCC"."MI_Id"
              INNER JOIN "Fee_Master_Class_Category" "FMCC" ON "FMCC"."FMCC_Id" = "FYCC"."FMCC_Id" 
                  AND "FMCC"."MI_Id" = "FYCC"."MI_Id" 
                  AND "FMCC"."FMCC_Id" = "FMA"."FMCC_Id"
              WHERE "FSS"."MI_Id" = ' || "Mi_Id" || ' 
                  AND "FSS"."ASMAY_ID" = ' || "ASMAY_Id" || ' 
                  AND "FMCC"."FMCC_Id" IN (' || "FMCC_Id" || ')
              GROUP BY "FMCC"."FMCC_ClassCategoryName"';
    
    RETURN QUERY EXECUTE query;
END;
$$;