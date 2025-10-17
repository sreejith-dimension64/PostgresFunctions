CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Adjustment_Delete"(
    "@FSA_ID" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "@miid" bigint;
    "@asmayid" bigint;
    "@amstid" bigint;
    "@From_FMG_id" bigint;
    "@From_FMH_id" bigint;
    "@From_FTI_id" bigint;
    "@From_FMA_id" bigint;
    "@To_FMG_id" bigint;
    "@To_FMH_id" bigint;
    "@To_FTI_id" bigint;
    "@To_FMA_id" bigint;
    "@adjusteamount" bigint;
BEGIN
    SELECT "MI_Id", "ASMAY_Id", "AMST_Id", "FSA_From_FMG_Id", "FSA_From_FMH_Id", "FSA_From_FTI_Id", "FSA_From_FMA_Id", "FSA_AdjustedAmount", "FSA_To_FMG_Id", "FSA_To_FMH_Id", "FSA_To_FTI_Id", "FSA_To_FMA_Id"
    INTO "@miid", "@asmayid", "@amstid", "@From_FMG_id", "@From_FMH_id", "@From_FTI_id", "@From_FMA_id", "@adjusteamount", "@To_FMG_id", "@To_FMH_id", "@To_FTI_id", "@To_FMA_id"
    FROM "dbo"."Fee_Student_Adjustment" 
    WHERE "FSA_Id" = "@FSA_ID";

    UPDATE "dbo"."Fee_Student_Status" 
    SET "FSS_RunningExcessAmount" = ("FSS_RunningExcessAmount" + "@adjusteamount"),
        "FSS_ExcessAdjustedAmount" = ("FSS_ExcessAdjustedAmount" - "@adjusteamount")
    WHERE "MI_Id" = "@miid" 
        AND "ASMAY_Id" = "@asmayid" 
        AND "AMST_Id" = "@amstid" 
        AND "FMG_Id" = "@From_FMG_id" 
        AND "FMH_Id" = "@From_FMH_id" 
        AND "FTI_Id" = "@From_FTI_id" 
        AND "FMA_Id" = "@From_FMA_id";

    UPDATE "dbo"."Fee_Student_Status" 
    SET "FSS_ToBePaid" = ("FSS_ToBePaid" + "@adjusteamount"),
        "FSS_AdjustedAmount" = ("FSS_AdjustedAmount" - "@adjusteamount")
    WHERE "MI_Id" = "@miid" 
        AND "ASMAY_Id" = "@asmayid" 
        AND "AMST_Id" = "@amstid" 
        AND "FMG_Id" = "@To_FMG_id" 
        AND "FMH_Id" = "@To_FMH_id" 
        AND "FTI_Id" = "@To_FTI_id" 
        AND "FMA_Id" = "@To_FMA_id";

    DELETE FROM "dbo"."Fee_Student_Adjustment" 
    WHERE "FSA_Id" = "@FSA_ID";

    RETURN;
END;
$$;