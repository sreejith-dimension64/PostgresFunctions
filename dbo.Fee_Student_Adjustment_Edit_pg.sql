CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Adjustment_Edit"(
    p_FSA_ID bigint,
    p_adjustmentnew bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_miid bigint;
    v_asmayid bigint;
    v_amstid bigint;
    v_From_FMG_id bigint;
    v_From_FMH_id bigint;
    v_From_FTI_id bigint;
    v_From_FMA_id bigint;
    v_To_FMG_id bigint;
    v_To_FMH_id bigint;
    v_To_FTI_id bigint;
    v_To_FMA_id bigint;
    v_adjusteamount bigint;
BEGIN
    SELECT "MI_Id", "ASMAY_Id", "AMST_Id", "FSA_From_FMG_Id", "FSA_From_FMH_Id", 
           "FSA_From_FTI_Id", "FSA_From_FMA_Id", "FSA_AdjustedAmount", "FSA_To_FMG_Id", 
           "FSA_To_FMH_Id", "FSA_To_FTI_Id", "FSA_To_FMA_Id"
    INTO v_miid, v_asmayid, v_amstid, v_From_FMG_id, v_From_FMH_id, 
         v_From_FTI_id, v_From_FMA_id, v_adjusteamount, v_To_FMG_id, 
         v_To_FMH_id, v_To_FTI_id, v_To_FMA_id
    FROM "dbo"."Fee_Student_Adjustment" 
    WHERE "FSA_Id" = p_FSA_ID;

    UPDATE "dbo"."Fee_Student_Status" 
    SET "FSS_RunningExcessAmount" = (("FSS_RunningExcessAmount" + v_adjusteamount) - p_adjustmentnew),
        "FSS_ExcessAdjustedAmount" = (("FSS_ExcessAdjustedAmount" - v_adjusteamount) + p_adjustmentnew)
    WHERE "MI_Id" = v_miid 
      AND "ASMAY_Id" = v_asmayid 
      AND "AMST_Id" = v_amstid 
      AND "FMG_Id" = v_From_FMG_id 
      AND "FMH_Id" = v_From_FMH_id 
      AND "FTI_Id" = v_From_FTI_id 
      AND "FMA_Id" = v_From_FMA_id;

    UPDATE "dbo"."Fee_Student_Status" 
    SET "FSS_ToBePaid" = (("FSS_ToBePaid" + v_adjusteamount) - p_adjustmentnew),
        "FSS_AdjustedAmount" = (("FSS_AdjustedAmount" - v_adjusteamount) + p_adjustmentnew)
    WHERE "MI_Id" = v_miid 
      AND "ASMAY_Id" = v_asmayid 
      AND "AMST_Id" = v_amstid 
      AND "FMG_Id" = v_To_FMG_id 
      AND "FMH_Id" = v_To_FMH_id 
      AND "FTI_Id" = v_To_FTI_id 
      AND "FMA_Id" = v_To_FMA_id;

    UPDATE "dbo"."Fee_Student_Adjustment"
    SET "FSA_AdjustedAmount" = p_adjustmentnew,
        "UpdatedDate" = CURRENT_TIMESTAMP
    WHERE "FSA_Id" = p_FSA_ID;

    RETURN;
END;
$$;