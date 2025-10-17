CREATE OR REPLACE FUNCTION "dbo"."CLG_Fee_Student_Adjustment_Edit"(
    "@FSA_ID" bigint,
    "@adjustmentnew" bigint
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
    SELECT "MI_Id", "ASMAY_Id", "AMCST_Id", "FCSA_From_FMG_Id", "FCSA_From_FMH_Id", 
           "FCSA_FromFTI_Id", "FCSA_FromFMA_Id", "FCSA_AdjustedAmount", "FCSA_To_FMG_Id", 
           "FCSA_To_FMH_Id", "FCSA_ToFTI_Id", "FCSA_ToFMA_Id"
    INTO "@miid", "@asmayid", "@amstid", "@From_FMG_id", "@From_FMH_id", 
         "@From_FTI_id", "@From_FMA_id", "@adjusteamount", "@To_FMG_id", 
         "@To_FMH_id", "@To_FTI_id", "@To_FMA_id"
    FROM "CLG"."Fee_College_Student_Adjustment" 
    WHERE "FCSA_Id" = "@FSA_ID";

    UPDATE "CLG"."Fee_College_Student_Status" 
    SET "FCSS_RunningExcessAmount" = (("FCSS_RunningExcessAmount" + "@adjusteamount") - "@adjustmentnew"),
        "FCSS_ExcessAmountAdjusted" = (("FCSS_ExcessAmountAdjusted" - "@adjusteamount") + "@adjustmentnew")
    WHERE "MI_Id" = "@miid" 
      AND "ASMAY_Id" = "@asmayid" 
      AND "AMCST_Id" = "@amstid" 
      AND "FMG_Id" = "@From_FMG_id" 
      AND "FMH_Id" = "@From_FMH_id" 
      AND "FTI_Id" = "@From_FTI_id" 
      AND "FCMAS_Id" = "@From_FMA_id";

    UPDATE "CLG"."Fee_College_Student_Status" 
    SET "FCSS_ToBePaid" = (("FCSS_ToBePaid" + "@adjusteamount") - "@adjustmentnew"),
        "FCSS_AdjustedAmount" = (("FCSS_AdjustedAmount" - "@adjusteamount") + "@adjustmentnew")
    WHERE "MI_Id" = "@miid" 
      AND "ASMAY_Id" = "@asmayid" 
      AND "AMCST_Id" = "@amstid" 
      AND "FMG_Id" = "@To_FMG_id" 
      AND "FMH_Id" = "@To_FMH_id" 
      AND "FTI_Id" = "@To_FTI_id" 
      AND "FCMAS_Id" = "@To_FMA_id";

    UPDATE "CLG"."Fee_College_Student_Adjustment"
    SET "FCSA_AdjustedAmount" = "@adjustmentnew"
    WHERE "FCSA_Id" = "@FSA_ID";

    RETURN;
END;
$$;