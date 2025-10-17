CREATE OR REPLACE FUNCTION "dbo"."GroupwiePaymentdetails"(
    "Mi_Id" bigint,
    "ASMAY_Id" bigint
)
RETURNS TABLE(
    "FMG_GroupName" VARCHAR,
    "FSS_CurrentYrCharges" NUMERIC,
    "FSS_ToBePaid" NUMERIC,
    "FSS_PaidAmount" NUMERIC,
    "FSS_ConcessionAmount" NUMERIC,
    "FSS_WaivedAmount" NUMERIC,
    "FSS_RunningExcessAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "b"."FMG_GroupName",
        SUM("a"."FSS_CurrentYrCharges") AS "FSS_CurrentYrCharges",
        SUM("a"."FSS_ToBePaid") AS "FSS_ToBePaid",
        SUM("a"."FSS_PaidAmount") AS "FSS_PaidAmount",
        SUM("a"."FSS_ConcessionAmount") AS "FSS_ConcessionAmount",
        SUM("a"."FSS_WaivedAmount") AS "FSS_WaivedAmount",
        SUM("a"."FSS_RunningExcessAmount") AS "FSS_RunningExcessAmount"
    FROM "fee_student_status" AS "a"
    INNER JOIN "fee_master_group" AS "b" ON "a"."fmg_id" = "b"."FMG_Id"
    WHERE "a"."MI_Id" = "Mi_Id" AND "a"."ASMAY_Id" = "ASMAY_Id"
    GROUP BY "a"."FMG_Id", "b"."FMG_GroupName";
END;
$$;