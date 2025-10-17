CREATE OR REPLACE FUNCTION "dbo"."GET_TRN_FEETERM_PART2"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint
)
RETURNS TABLE(
    "FMT_Id" bigint,
    "TRMR_Id" bigint,
    "TRMR_RouteName" text,
    "FSS_ToBePaid" numeric,
    "FSS_PaidAmount" numeric,
    "FSS_TotalToBePaid" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "D"."FMT_Id",
        "C"."TRMR_Id",
        "C"."TRMR_RouteName",
        SUM("A"."FSS_ToBePaid") as "FSS_ToBePaid",
        SUM("A"."FSS_PaidAmount") + SUM("A"."FSS_ConcessionAmount") as "FSS_PaidAmount",
        SUM("A"."FSS_TotalToBePaid") as "FSS_TotalToBePaid"
    FROM "Fee_Student_Status" as "A"
    INNER JOIN "TRN"."TR_Student_Route" as "B" ON "A"."AMST_Id" = "B"."AMST_Id" AND "A"."FMG_Id" = "B"."FMG_Id"
    INNER JOIN "TRN"."TR_Master_Route" as "C" ON "B"."TRMR_Id" = "C"."TRMR_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads" as "D" ON "A"."FMH_Id" = "D"."FMH_Id"
    WHERE "A"."MI_Id" = "@MI_Id" AND "A"."ASMAY_Id" = "@ASMAY_Id"
    GROUP BY "D"."FMT_Id", "C"."TRMR_Id", "C"."TRMR_RouteName";
END;
$$;