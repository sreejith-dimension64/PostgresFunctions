CREATE OR REPLACE FUNCTION "dbo"."GET_TRN_FEETERM_PART1"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint
)
RETURNS TABLE(
    "TRMR_Id" bigint,
    "TRMR_RouteName" VARCHAR,
    "FSS_ToBePaid" NUMERIC,
    "FSS_PaidAmount" NUMERIC,
    "FSS_TotalToBePaid" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "C"."TRMR_Id",
        "C"."TRMR_RouteName",
        SUM("A"."FSS_ToBePaid") AS "FSS_ToBePaid",
        SUM("A"."FSS_PaidAmount") + SUM("A"."FSS_ConcessionAmount") AS "FSS_PaidAmount",
        SUM("A"."FSS_TotalToBePaid") AS "FSS_TotalToBePaid"
    FROM "Fee_Student_Status" AS "A"
    INNER JOIN "TRN"."TR_Student_Route" AS "B" 
        ON "A"."AMST_Id" = "B"."AMST_Id" 
        AND "A"."FMG_Id" = "B"."FMG_Id"
    INNER JOIN "TRN"."TR_Master_Route" AS "C" 
        ON "B"."TRMR_Id" = "C"."TRMR_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads" AS "D" 
        ON "A"."FMH_Id" = "D"."FMH_Id"
    WHERE "A"."MI_Id" = "@MI_Id" 
        AND "A"."ASMAY_Id" = "@ASMAY_Id"
    GROUP BY "C"."TRMR_Id", "C"."TRMR_RouteName";
END;
$$;