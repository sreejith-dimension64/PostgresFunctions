CREATE OR REPLACE FUNCTION "dbo"."FeeImportTermDetails" (
    "@ASMAY_Id" VARCHAR(100),
    "@MI_Id" VARCHAR(100),
    "@AMST_Id" VARCHAR(100)
)
RETURNS TABLE (
    "FMT_Id" INTEGER,
    "AMST_Id" VARCHAR(100),
    "FSS_ToBePaid" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "C"."FMT_Id",
        "A"."AMST_Id",
        SUM("A"."FSS_ToBePaid") AS "FSS_ToBePaid"
    FROM "Fee_Student_Status" "A"
    INNER JOIN "Fee_Master_Terms_FeeHeads" "B" ON "A"."FMH_Id" = "B"."FMH_Id" AND "A"."FTI_Id" = "B"."FTI_Id"
    INNER JOIN "Fee_Master_Terms" "C" ON "C"."FMT_Id" = "B"."FMT_Id"
    WHERE "A"."ASMAY_Id" = "@ASMAY_Id" 
        AND "A"."MI_Id" = "@MI_Id" 
        AND "A"."AMST_Id" = "@AMST_Id"
    GROUP BY "C"."FMT_Id", "A"."AMST_Id"
    HAVING SUM("A"."FSS_ToBePaid") > 0
    LIMIT 1;
END;
$$;