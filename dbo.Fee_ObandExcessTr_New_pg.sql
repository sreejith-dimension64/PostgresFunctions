CREATE OR REPLACE FUNCTION "dbo"."Fee_ObandExcessTr_New"(
    p_mi_id bigint,
    p_Lasmay_id bigint,
    p_Nasmay_id bigint,
    p_amst_id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FSS_ToBePaid bigint;
    v_FSS_ToBePaidNew bigint;
    v_FSS_PaidAmount bigint;
    v_FSS_Id bigint;
    v_FSS_IdNew bigint;
    v_FMG_Id bigint;
    v_FMG_IdN bigint;
    v_FMH_Id bigint;
    v_FMH_IdN bigint;
    v_FTI_IdN bigint;
    v_FTI_Id bigint;
    v_FMA_IdN bigint;
    v_FMA_Id bigint;
BEGIN

    ----Opening balance transfer
    --FOR rec IN 
    --    SELECT "FSS_Id", "FMA_Id", "FMH_Id", "FTI_Id", "FSS_ToBePaid" 
    --    FROM "fee_student_status" 
    --    WHERE "MI_Id" = p_mi_id 
    --        AND "AMST_Id" = p_amst_id 
    --        AND "ASMAY_Id" = p_Lasmay_id 
    --        AND "FSS_ToBePaid" > 0
    --LOOP
    --    v_FSS_Id := rec."FSS_Id";
    --    v_FMA_Id := rec."FMA_Id";
    --    v_FMH_Id := rec."FMH_Id";
    --    v_FTI_Id := rec."FTI_Id";
    --    v_FSS_ToBePaid := rec."FSS_ToBePaid";
    
    --    UPDATE "Fee_Student_Status" 
    --    SET "FSS_OBTransferred" = v_FSS_ToBePaid, 
    --        "FSS_ToBePaid" = 0 
    --    WHERE "MI_Id" = p_MI_Id 
    --        AND "ASMAY_Id" = p_Lasmay_id 
    --        AND "AMST_Id" = p_AMST_Id 
    --        AND "FSS_Id" = v_FSS_Id;
    
    --    SELECT "FSS_Id", "FTI_Id", "FMH_Id"
    --    INTO v_FSS_IdNew, v_FTI_IdN, v_FMH_IdN
    --    FROM "fee_student_status" 
    --    WHERE "MI_Id" = p_MI_Id 
    --        AND "AMST_Id" = p_AMST_Id 
    --        AND "FMH_Id" = v_FMH_Id 
    --        AND "ASMAY_Id" = p_Nasmay_id 
    --    ORDER BY "FTI_Id"
    --    LIMIT 1;
    
    --    IF FOUND THEN
    --        UPDATE "Fee_Student_Status" 
    --        SET "FSS_OBArrearAmount" = "FSS_OBArrearAmount" + v_FSS_ToBePaid,
    --            "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + v_FSS_ToBePaid,
    --            "FSS_ToBePaid" = "FSS_ToBePaid" + v_FSS_ToBePaid 
    --        WHERE "FSS_Id" = v_FSS_IdNew 
    --            AND "MI_Id" = p_MI_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "AMST_Id" = p_AMST_Id 
    --            AND "FMH_Id" = v_FMH_IdN 
    --            AND "FTI_Id" = v_FTI_IdN;
    --    ELSE
    --        SELECT "FMG_Id", "FMH_Id", "FMA_Id", "FTI_Id"
    --        INTO v_FMG_IdN, v_FMH_IdN, v_FMA_IdN, v_FTI_IdN
    --        FROM "fee_student_status" 
    --        WHERE "MI_Id" = p_MI_Id 
    --            AND "AMST_Id" = p_AMST_Id 
    --            AND "FMH_Id" = v_FMH_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "FTI_Id" = v_FTI_Id;
    
    --        INSERT INTO "Fee_Student_Status"("MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBArrearAmount","FSS_TotalToBePaid","FSS_ToBePaid","FSS_OBExcessAmount","FSS_CurrentYrCharges","FSS_PaidAmount","FSS_ExcessPaidAmount","FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id","FSS_RefundableAmount","FSS_OBTransferred","FSS_ExcessTransferred") 
    --        VALUES(p_MI_Id,p_Nasmay_id,p_AMST_Id,v_FMG_IdN,v_FMH_IdN,v_FTI_Id,v_FMA_IdN,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    
    --        UPDATE "Fee_Student_Status" 
    --        SET "FSS_OBArrearAmount" = v_FSS_ToBePaid,
    --            "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + v_FSS_ToBePaid,
    --            "FSS_ToBePaid" = "FSS_ToBePaid" + v_FSS_ToBePaid 
    --        WHERE "FSS_Id" = v_FSS_IdNew 
    --            AND "MI_Id" = p_MI_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "AMST_Id" = p_AMST_Id 
    --            AND "FMH_Id" = v_FMH_IdN 
    --            AND "FTI_Id" = v_FTI_IdN;
    --    END IF;
    --END LOOP;
    ----Opening balance transfer

    ---- excess head amount transfer
    --FOR rec IN 
    --    SELECT "FSS_Id", "FMA_Id", "FMH_Id", "FTI_Id", "FSS_PaidAmount" 
    --    FROM "fee_student_status" 
    --    WHERE "MI_Id" = p_mi_id 
    --        AND "AMST_Id" = p_amst_id 
    --        AND "ASMAY_Id" = p_Lasmay_id 
    --        AND "FMH_Id" IN (SELECT "FMH_Id" FROM "fee_Master_Head" WHERE "MI_Id" = p_MI_Id AND "FMH_FeeName" LIKE '%Excess%') 
    --        AND "FSS_RunningExcessAmount" = 0 
    --        AND "FSS_PaidAmount" > 0
    --LOOP
    --    v_FSS_Id := rec."FSS_Id";
    --    v_FMA_Id := rec."FMA_Id";
    --    v_FMH_Id := rec."FMH_Id";
    --    v_FTI_Id := rec."FTI_Id";
    --    v_FSS_PaidAmount := rec."FSS_PaidAmount";
      
    --    UPDATE "fee_student_status" 
    --    SET "FSS_ExcessTransferred" = v_FSS_PaidAmount 
    --    WHERE "FSS_Id" = v_FSS_Id 
    --        AND "MI_Id" = p_MI_Id 
    --        AND "ASMAY_Id" = p_Lasmay_id 
    --        AND "FMH_Id" = v_FMH_Id 
    --        AND "FSS_Id" = v_FSS_Id 
    --        AND "AMST_Id" = p_amst_id 
    --        AND "FTI_Id" = v_FTI_Id;
    
    --    SELECT "FSS_Id", "FTI_Id", "FMH_Id"
    --    INTO v_FSS_IdNew, v_FTI_IdN, v_FMH_IdN
    --    FROM "fee_student_status" 
    --    WHERE "MI_Id" = p_MI_Id 
    --        AND "AMST_Id" = p_AMST_Id 
    --        AND "FMH_Id" = v_FMH_Id 
    --        AND "ASMAY_Id" = p_Nasmay_id 
    --        AND "FTI_Id" = v_FTI_Id;
    
    --    IF FOUND THEN
    --        UPDATE "Fee_Student_Status" 
    --        SET "FSS_OBExcessAmount" = v_FSS_PaidAmount,
    --            "FSS_ExcessPaidAmount" = v_FSS_PaidAmount,
    --            "FSS_RunningExcessAmount" = v_FSS_PaidAmount 
    --        WHERE "FSS_Id" = v_FSS_IdNew 
    --            AND "MI_Id" = p_MI_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "AMST_Id" = p_amst_id 
    --            AND "FMH_Id" = v_FMH_IdN;
    --    ELSE
    --        SELECT "FMG_Id", "FMH_Id", "FMA_Id"
    --        INTO v_FMG_IdN, v_FMH_IdN, v_FMA_IdN
    --        FROM "fee_student_status" 
    --        WHERE "MI_Id" = p_MI_Id 
    --            AND "AMST_Id" = p_AMST_Id 
    --            AND "FMH_Id" = v_FMH_IdN 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "FTI_Id" = v_FTI_Id;
    
    --        INSERT INTO "Fee_Student_Status"("MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBExcessAmount","FSS_ExcessPaidAmount","FSS_RunningExcessAmount","FSS_OBArrearAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessAdjustedAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id","FSS_RefundableAmount","FSS_OBTransferred","FSS_ExcessTransferred")
    --        VALUES(p_MI_Id,p_Nasmay_id,p_AMST_Id,v_FMG_IdN,v_FMH_IdN,v_FTI_Id,v_FMA_IdN,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    
    --        UPDATE "Fee_Student_Status" 
    --        SET "FSS_OBExcessAmount" = v_FSS_PaidAmount,
    --            "FSS_ExcessPaidAmount" = v_FSS_PaidAmount,
    --            "FSS_RunningExcessAmount" = v_FSS_PaidAmount 
    --        WHERE "FSS_Id" = v_FSS_IdNew 
    --            AND "MI_Id" = p_MI_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "AMST_Id" = p_amst_id 
    --            AND "FMH_Id" = v_FMH_IdN;
    --    END IF;
    --END LOOP;
    ----excess head amount transfer

    ----excess head amount transfer with Waived off
    --FOR rec IN 
    --    SELECT "FSS_Id", "FMA_Id", "FMH_Id", "FTI_Id", "FSS_PaidAmount" 
    --    FROM "fee_student_status" 
    --    WHERE "MI_Id" = p_mi_id 
    --        AND "AMST_Id" = p_amst_id 
    --        AND "ASMAY_Id" = p_Lasmay_id 
    --        AND "FMH_Id" IN (SELECT "FMH_Id" FROM "fee_Master_Head" WHERE "MI_Id" = p_MI_Id AND "FMH_FeeName" LIKE '%Excess%') 
    --        AND "FSS_RunningExcessAmount" > 0
    --LOOP
    --    v_FSS_Id := rec."FSS_Id";
    --    v_FMA_Id := rec."FMA_Id";
    --    v_FMH_Id := rec."FMH_Id";
    --    v_FTI_Id := rec."FTI_Id";
    --    v_FSS_PaidAmount := rec."FSS_PaidAmount";
      
    --    UPDATE "fee_student_status" 
    --    SET "FSS_ExcessTransferred" = v_FSS_PaidAmount 
    --    WHERE "FSS_Id" = v_FSS_Id 
    --        AND "MI_Id" = p_MI_Id 
    --        AND "ASMAY_Id" = p_Lasmay_id 
    --        AND "FMH_Id" = v_FMH_Id 
    --        AND "FSS_Id" = v_FSS_Id 
    --        AND "AMST_Id" = p_amst_id 
    --        AND "FTI_Id" = v_FTI_Id;
    
    --    SELECT "FSS_Id", "FTI_Id", "FMH_Id"
    --    INTO v_FSS_IdNew, v_FTI_IdN, v_FMH_IdN
    --    FROM "fee_student_status" 
    --    WHERE "MI_Id" = p_MI_Id 
    --        AND "AMST_Id" = p_AMST_Id 
    --        AND "FMH_Id" = v_FMH_Id 
    --        AND "ASMAY_Id" = p_Nasmay_id 
    --        AND "FTI_Id" = v_FTI_Id;
    
    --    IF FOUND THEN
    --        UPDATE "Fee_Student_Status" 
    --        SET "FSS_OBExcessAmount" = v_FSS_PaidAmount,
    --            "FSS_ExcessPaidAmount" = v_FSS_PaidAmount,
    --            "FSS_RunningExcessAmount" = v_FSS_PaidAmount 
    --        WHERE "FSS_Id" = v_FSS_IdNew 
    --            AND "MI_Id" = p_MI_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "AMST_Id" = p_amst_id 
    --            AND "FMH_Id" = v_FMH_IdN;
    --    ELSE
    --        SELECT "FMG_Id", "FMH_Id", "FMA_Id"
    --        INTO v_FMG_IdN, v_FMH_IdN, v_FMA_IdN
    --        FROM "fee_student_status" 
    --        WHERE "MI_Id" = p_MI_Id 
    --            AND "AMST_Id" = p_AMST_Id 
    --            AND "FMH_Id" = v_FMH_IdN 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "FTI_Id" = v_FTI_Id;
    
    --        INSERT INTO "Fee_Student_Status"("MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBExcessAmount","FSS_ExcessPaidAmount","FSS_RunningExcessAmount","FSS_OBArrearAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessAdjustedAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id","FSS_RefundableAmount","FSS_OBTransferred","FSS_ExcessTransferred")
    --        VALUES(p_MI_Id,p_Nasmay_id,p_AMST_Id,v_FMG_IdN,v_FMH_IdN,v_FTI_Id,v_FMA_IdN,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    
    --        UPDATE "Fee_Student_Status" 
    --        SET "FSS_OBExcessAmount" = v_FSS_PaidAmount,
    --            "FSS_ExcessPaidAmount" = v_FSS_PaidAmount,
    --            "FSS_RunningExcessAmount" = v_FSS_PaidAmount 
    --        WHERE "FSS_Id" = v_FSS_IdNew 
    --            AND "MI_Id" = p_MI_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "AMST_Id" = p_amst_id 
    --            AND "FMH_Id" = v_FMH_IdN;
    --    END IF;
    --END LOOP;
    ----excess head amount transfer with Waived off

    ----Running excess for other heads exluding excess head
    --FOR rec IN 
    --    SELECT "FSS_Id", "FMA_Id", "FMH_Id", "FTI_Id", "FSS_PaidAmount" 
    --    FROM "fee_student_status" 
    --    WHERE "MI_Id" = p_mi_id 
    --        AND "AMST_Id" = p_amst_id 
    --        AND "ASMAY_Id" = p_Lasmay_id 
    --        AND "FMH_Id" NOT IN (SELECT "FMH_Id" FROM "fee_Master_Head" WHERE "MI_Id" = p_MI_Id AND "FMH_FeeName" LIKE '%Excess%') 
    --        AND "FSS_RunningExcessAmount" > 0
    --LOOP
    --    v_FSS_Id := rec."FSS_Id";
    --    v_FMA_Id := rec."FMA_Id";
    --    v_FMH_Id := rec."FMH_Id";
    --    v_FTI_Id := rec."FTI_Id";
    --    v_FSS_PaidAmount := rec."FSS_PaidAmount";
      
    --    UPDATE "fee_student_status" 
    --    SET "FSS_ExcessTransferred" = v_FSS_PaidAmount 
    --    WHERE "FSS_Id" = v_FSS_Id 
    --        AND "MI_Id" = p_MI_Id 
    --        AND "ASMAY_Id" = p_Lasmay_id 
    --        AND "FMH_Id" = v_FMH_Id 
    --        AND "FSS_Id" = v_FSS_Id 
    --        AND "AMST_Id" = p_amst_id 
    --        AND "FTI_Id" = v_FTI_Id;
    
    --    SELECT "FSS_Id", "FTI_Id", "FMH_Id"
    --    INTO v_FSS_IdNew, v_FTI_IdN, v_FMH_IdN
    --    FROM "fee_student_status" 
    --    WHERE "MI_Id" = p_MI_Id 
    --        AND "AMST_Id" = p_AMST_Id 
    --        AND "FMH_Id" = v_FMH_Id 
    --        AND "ASMAY_Id" = p_Nasmay_id 
    --        AND "FTI_Id" = v_FTI_Id;
    
    --    IF FOUND THEN
    --        UPDATE "Fee_Student_Status" 
    --        SET "FSS_OBExcessAmount" = v_FSS_PaidAmount,
    --            "FSS_ExcessPaidAmount" = v_FSS_PaidAmount,
    --            "FSS_RunningExcessAmount" = v_FSS_PaidAmount 
    --        WHERE "FSS_Id" = v_FSS_IdNew 
    --            AND "MI_Id" = p_MI_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "AMST_Id" = p_amst_id 
    --            AND "FMH_Id" = v_FMH_IdN;
    --    ELSE
    --        SELECT "FMG_Id", "FMH_Id", "FMA_Id"
    --        INTO v_FMG_IdN, v_FMH_IdN, v_FMA_IdN
    --        FROM "fee_student_status" 
    --        WHERE "MI_Id" = p_MI_Id 
    --            AND "AMST_Id" = p_AMST_Id 
    --            AND "FMH_Id" = v_FMH_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "FTI_Id" = v_FTI_Id;
    
    --        INSERT INTO "Fee_Student_Status"("MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBExcessAmount","FSS_ExcessPaidAmount","FSS_RunningExcessAmount","FSS_OBArrearAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessAdjustedAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id","FSS_RefundableAmount","FSS_OBTransferred","FSS_ExcessTransferred")
    --        VALUES(p_MI_Id,p_Nasmay_id,p_AMST_Id,v_FMG_IdN,v_FMH_IdN,v_FTI_Id,v_FMA_IdN,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    
    --        UPDATE "Fee_Student_Status" 
    --        SET "FSS_OBExcessAmount" = v_FSS_PaidAmount,
    --            "FSS_ExcessPaidAmount" = v_FSS_PaidAmount,
    --            "FSS_RunningExcessAmount" = v_FSS_PaidAmount 
    --        WHERE "FSS_Id" = v_FSS_IdNew 
    --            AND "MI_Id" = p_MI_Id 
    --            AND "ASMAY_Id" = p_Nasmay_id 
    --            AND "AMST_Id" = p_amst_id 
    --            AND "FMH_Id" = v_FMH_IdN;
    --    END IF;
    --END LOOP;
    ----Running excess for other heads exluding excess head
    
    RAISE NOTICE 'aaaa';
    
    RETURN;
END;
$$;