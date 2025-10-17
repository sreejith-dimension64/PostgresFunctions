CREATE OR REPLACE FUNCTION "dbo"."HeadwiseInsertStudents"()
RETURNS TABLE(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "AMST_Id" bigint,
    "FMG_Id" bigint,
    "FMH_Id" bigint,
    "FTI_Id" bigint,
    "FMA_Id" bigint,
    "FSS_OBArrearAmount" numeric,
    "FSS_OBExcessAmount" numeric,
    "FSS_CurrentYrCharges" numeric,
    "FSS_TotalToBePaid" numeric,
    "FSS_ToBePaid" numeric,
    "FSS_PaidAmount" numeric,
    "FSS_ExcessPaidAmount" numeric,
    "FSS_ExcessAdjustedAmount" numeric,
    "FSS_RunningExcessAmount" numeric,
    "FSS_ConcessionAmount" numeric,
    "FSS_AdjustedAmount" numeric,
    "FSS_WaivedAmount" numeric,
    "FSS_RebateAmount" numeric,
    "FSS_FineAmount" numeric,
    "FSS_RefundAmount" numeric,
    "FSS_RefundAmountAdjusted" numeric,
    "FSS_NetAmount" numeric,
    "FSS_ChequeBounceFlag" boolean,
    "FSS_ArrearFlag" boolean,
    "FSS_RefundOverFlag" boolean,
    "FSS_ActiveFlag" boolean,
    "User_Id" bigint,
    "FSS_RefundableAmount" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_MI_Id bigint;
    v_ASMAY_Id bigint;
    v_AMST_Id bigint;
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    v_FMA_Id bigint;
    v_FMG_Id bigint;
    v_AMST_Id_New bigint;
    student_record RECORD;
BEGIN
    DROP TABLE IF EXISTS feesstudentstatus_temp;
    
    CREATE TEMP TABLE feesstudentstatus_temp AS
    SELECT * FROM "fee_student_status" WHERE 1!=1;
    
    TRUNCATE TABLE feesstudentstatus_temp;
    
    FOR student_record IN
        SELECT DISTINCT "FMSG"."AMST_Id"
        FROM "Fee_Master_Student_Group" "FMSG"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMG_Id" = "FMSG"."FMG_Id" 
            AND "FMA"."MI_Id" = 10 AND "FMA"."ASMAY_Id" = 38 AND "FMA"."FMH_Id" = 212
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FMA"."FMH_Id" 
            AND "FMH"."MI_Id" = 10 AND "FMH"."FMH_Id" = 212
        WHERE "FMSG"."MI_Id" = 10 AND "FMSG"."ASMAY_Id" = 38
    LOOP
        v_AMST_Id := student_record."AMST_Id";
        
        SELECT "FMSG"."FMG_Id", "FMSG"."AMST_Id", "FMSG"."MI_Id", "FMSG"."ASMAY_Id", 
               "FMA"."FMH_Id", "FMA"."FTI_Id", "FMA"."FMA_Id"
        INTO v_FMG_Id, v_AMST_Id_New, v_MI_Id, v_ASMAY_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id
        FROM "Fee_Master_Student_Group" "FMSG"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMG_Id" = "FMSG"."FMG_Id" 
            AND "FMA"."MI_Id" = 10 AND "FMA"."ASMAY_Id" = 38 AND "FMA"."FMH_Id" = 212
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FMA"."FMH_Id" 
            AND "FMH"."MI_Id" = 10 AND "FMH"."FMH_Id" = 212
        WHERE "FMSG"."MI_Id" = 10 AND "FMSG"."ASMAY_Id" = 38 AND "FMSG"."AMST_Id" = v_AMST_Id
        LIMIT 1;
        
        INSERT INTO feesstudentstatus_temp (
            "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
            "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", 
            "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount",
            "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount",
            "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount",
            "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", 
            "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", 
            "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount"
        )
        VALUES (
            v_MI_Id, v_ASMAY_Id, v_AMST_Id_New, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            false, false, false, true, 7457, 0
        );
    END LOOP;
    
    RETURN QUERY
    SELECT * FROM feesstudentstatus_temp 
    WHERE "MI_Id" = 10 AND "FMH_Id" = 212;
    
    DROP TABLE IF EXISTS feesstudentstatus_temp;
    
    RETURN;
END;
$$;