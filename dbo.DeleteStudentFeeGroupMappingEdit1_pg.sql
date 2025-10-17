CREATE OR REPLACE FUNCTION "dbo"."DeleteStudentFeeGroupMappingEdit1"(
    p_mi_id BIGINT,
    p_amst_id BIGINT,
    p_asmay_id BIGINT,
    p_fmg_id BIGINT,
    p_fmh_id BIGINT,
    p_fti_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMG_GroupName VARCHAR(100);
    v_FMH_FeeName VARCHAR(100);
    v_FTI_Name VARCHAR(100);
    v_FMSG_Id BIGINT;
    v_rowcount INTEGER;
BEGIN
    RAISE NOTICE 'a';
    
    IF (p_fti_id = 0 AND p_fmh_id = 0) THEN
        RAISE NOTICE 'group';
        
        PERFORM * FROM "Fee_Student_Status" a
        INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
        INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
        WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND "FSS_PaidAmount" = 0;
        
        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
        
        IF v_rowcount > 0 THEN
            RAISE NOTICE 'gb';
            
            INSERT INTO "Fee_Master_Student_Group_Installment_Log"("FMSGI_Id", "FMSG_Id", "FMH_ID", "FTI_ID", "ActionName")
            SELECT "FMSGI_Id", b."FMSG_Id", a."FMH_ID", a."FTI_ID", 'Delete' FROM "Fee_Student_Status" a
            INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND "FSS_PaidAmount" = 0;
            
            INSERT INTO "Fee_Student_Status_Log"("FSS_Id", "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "ActionName")
            SELECT "FSS_Id", a."MI_Id", a."ASMAY_Id", a."AMST_Id", a."FMG_Id", a."FMH_Id", a."FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", 'Delete' FROM "Fee_Student_Status" a
            INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND "FSS_PaidAmount" = 0;
            
            DELETE FROM "Fee_Master_Student_Group_Installment" c
            USING "Fee_Student_Status" a
            INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            WHERE b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            AND b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND "FSS_PaidAmount" = 0;
            
            DELETE FROM "Fee_Student_Status" a
            USING "Fee_Master_Student_Group" b, "Fee_Master_Student_Group_Installment" c
            WHERE a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            AND b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            AND b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND a."FSS_PaidAmount" = 0;
            
            PERFORM * FROM "Fee_Master_Student_Group_Installment" WHERE "FMSG_Id" IN (SELECT "FMSG_Id" FROM "Fee_Master_Student_Group" WHERE "FMG_Id" = p_fmg_id AND "ASMAY_Id" = p_asmay_id AND "MI_Id" = p_mi_id AND "AMST_Id" = p_amst_id);
            
            DELETE FROM "Fee_Master_Student_Group" WHERE "FMG_Id" = p_fmg_id AND "ASMAY_Id" = p_asmay_id AND "MI_Id" = p_mi_id AND "AMST_Id" = p_amst_id;
        END IF;
        
    ELSIF (p_fti_id = 0 AND p_fmh_id > 0) THEN
        RAISE NOTICE 'head';
        
        PERFORM * FROM "Fee_Student_Status" a
        INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
        INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
        WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND "FSS_PaidAmount" = 0;
        
        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
        
        IF v_rowcount > 0 THEN
            RAISE NOTICE 'hb';
            
            INSERT INTO "Fee_Master_Student_Group_Installment_Log"("FMSGI_Id", "FMSG_Id", "FMH_ID", "FTI_ID", "ActionName")
            SELECT "FMSGI_Id", b."FMSG_Id", a."FMH_ID", a."FTI_ID", 'Delete' FROM "Fee_Student_Status" a
            INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND "FSS_PaidAmount" = 0;
            
            INSERT INTO "Fee_Student_Status_Log"("FSS_Id", "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "ActionName")
            SELECT "FSS_Id", a."MI_Id", a."ASMAY_Id", a."AMST_Id", a."FMG_Id", a."FMH_Id", a."FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", 'Delete' FROM "Fee_Student_Status" a
            INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND "FSS_PaidAmount" = 0;
            
            DELETE FROM "Fee_Master_Student_Group_Installment" c
            USING "Fee_Student_Status" a
            INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            WHERE b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            AND b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND "FSS_PaidAmount" = 0;
            
            DELETE FROM "Fee_Student_Status" a
            USING "Fee_Master_Student_Group" b, "Fee_Master_Student_Group_Installment" c
            WHERE a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            AND b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            AND b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND a."FSS_PaidAmount" = 0;
            
            PERFORM * FROM "Fee_Master_Student_Group_Installment" WHERE "FMSG_Id" IN (SELECT "FMSG_Id" FROM "Fee_Master_Student_Group" WHERE "FMG_Id" = p_fmg_id AND "ASMAY_Id" = p_asmay_id AND "MI_Id" = p_mi_id AND "AMST_Id" = p_amst_id);
            
            DELETE FROM "Fee_Master_Student_Group" WHERE "FMG_Id" = p_fmg_id AND "ASMAY_Id" = p_asmay_id AND "MI_Id" = p_mi_id AND "AMST_Id" = p_amst_id;
        END IF;
        
    ELSIF (p_fti_id > 0 AND p_fmh_id > 0) THEN
        RAISE NOTICE 'installment';
        
        PERFORM * FROM "Fee_Student_Status" a
        INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
        INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
        WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND c."FTI_ID" = p_fti_id AND "FSS_PaidAmount" = 0;
        
        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
        
        IF v_rowcount > 0 THEN
            RAISE NOTICE 'ib';
            
            INSERT INTO "Fee_Master_Student_Group_Installment_Log"("FMSGI_Id", "FMSG_Id", "FMH_ID", "FTI_ID", "ActionName")
            SELECT "FMSGI_Id", b."FMSG_Id", a."FMH_ID", a."FTI_ID", 'Delete' FROM "Fee_Student_Status" a
            INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND c."FTI_ID" = p_fti_id AND "FSS_PaidAmount" = 0;
            
            INSERT INTO "Fee_Student_Status_Log"("FSS_Id", "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "ActionName")
            SELECT "FSS_Id", a."MI_Id", a."ASMAY_Id", a."AMST_Id", a."FMG_Id", a."FMH_Id", a."FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", 'Delete' FROM "Fee_Student_Status" a
            INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            INNER JOIN "Fee_Master_Student_Group_Installment" c ON b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            WHERE b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND c."FTI_ID" = p_fti_id AND "FSS_PaidAmount" = 0;
            
            DELETE FROM "Fee_Master_Student_Group_Installment" c
            USING "Fee_Student_Status" a
            INNER JOIN "Fee_Master_Student_Group" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            WHERE b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            AND b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND c."FTI_ID" = p_fti_id AND "FSS_PaidAmount" = 0;
            
            DELETE FROM "Fee_Student_Status" a
            USING "Fee_Master_Student_Group" b, "Fee_Master_Student_Group_Installment" c
            WHERE a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id" AND a."MI_Id" = b."MI_Id" AND a."FMG_Id" = b."FMG_Id"
            AND b."FMSG_Id" = c."FMSG_Id" AND a."FMH_Id" = c."FMH_ID" AND a."FTI_Id" = c."FTI_ID"
            AND b."MI_Id" = p_mi_id AND b."ASMAY_Id" = p_asmay_id AND b."AMST_Id" = p_amst_id AND b."FMG_Id" = p_fmg_id AND c."FMH_ID" = p_fmh_id AND c."FTI_ID" = p_fti_id AND a."FSS_PaidAmount" = 0;
            
            PERFORM * FROM "Fee_Master_Student_Group_Installment" WHERE "FMSG_Id" IN (SELECT "FMSG_Id" FROM "Fee_Master_Student_Group" WHERE "FMG_Id" = p_fmg_id AND "ASMAY_Id" = p_asmay_id AND "MI_Id" = p_mi_id AND "AMST_Id" = p_amst_id);
            
            DELETE FROM "Fee_Master_Student_Group" WHERE "FMG_Id" = p_fmg_id AND "ASMAY_Id" = p_asmay_id AND "MI_Id" = p_mi_id AND "AMST_Id" = p_amst_id;
        END IF;
    END IF;
    
    RETURN;
END;
$$;