CREATE OR REPLACE FUNCTION "dbo"."Automapping_Promotion"(
    p_amst_id BIGINT,
    p_mi_id BIGINT,
    p_asmay_id BIGINT,
    p_userid BIGINT,
    p_previous_asmay_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMG_Id BIGINT;
    v_FMSG_Id BIGINT;
    v_amcl_id BIGINT;
    v_fmcc_id BIGINT;
    v_FMH_Id BIGINT;
    v_FTI_Id BIGINT;
    v_FMA_Id BIGINT;
    v_FMA_Amount BIGINT;
    v_rowcount INTEGER;
    yearly_fee_rec RECORD;
    feeinstallment_rec RECORD;
BEGIN
    BEGIN
        FOR yearly_fee_rec IN
            SELECT DISTINCT "FMG"."FMG_Id" 
            FROM "Fee_Yearly_Group_Head_Mapping" "FYGHM"
            INNER JOIN "Fee_Master_Group" "FMG" ON "FYGHM"."FMG_Id" = "FMG"."FMG_Id"
            INNER JOIN "fee_yearly_group" ON "fee_yearly_group"."fmg_id" = "FMG"."fmg_id"
            INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FYGHM"."FMH_Id"
            WHERE "FYGHM"."MI_Id" = p_MI_Id 
            AND "FMG"."FMG_CompulsoryFlag" = '1' 
            AND "FYGHM"."asmay_id" = p_ASMAY_Id
        LOOP
            v_FMG_Id := yearly_fee_rec."FMG_Id";
            
            SELECT COUNT(*) INTO v_rowcount
            FROM "Fee_Master_Student_Group" 
            WHERE "FMG_Id" = v_FMG_Id 
            AND "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_ID;
            
            IF v_rowcount > 0 THEN
                INSERT INTO "Fee_Master_Student_Group" (
                    "MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag"
                ) 
                VALUES (
                    p_MI_Id, p_AMST_Id, p_ASMAY_ID, v_FMG_Id, 'Y'
                );
                
                SELECT MAX("FMSG_Id") INTO v_FMSG_Id 
                FROM "Fee_Master_Student_Group";
                
                SELECT "ASMCL_Id" INTO v_amcl_id 
                FROM "Adm_M_Student" 
                WHERE "amst_id" = p_amst_id 
                AND "ASMAY_Id" = p_asmay_id;
                
                SELECT "FMCC_Id" INTO v_fmcc_id 
                FROM "Fee_Yearly_Class_Category" 
                WHERE "ASMAY_Id" = p_ASMAY_ID 
                AND "MI_Id" = p_MI_Id 
                AND "FYCC_Id" IN (
                    SELECT "FYCC_Id" 
                    FROM "Fee_Yearly_Class_Category_Classes" 
                    WHERE "ASMCL_Id" = v_AMCL_Id
                );
                
                FOR feeinstallment_rec IN
                    SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
                    FROM "Fee_Master_Amount" 
                    WHERE "FMG_Id" = v_FMG_Id 
                    AND "ASMAY_Id" = p_ASMAY_ID 
                    AND "MI_Id" = p_MI_Id 
                    AND "FMCC_Id" = v_FMCC_Id
                LOOP
                    v_FMH_Id := feeinstallment_rec."FMH_Id";
                    v_FTI_Id := feeinstallment_rec."FTI_Id";
                    v_FMA_Id := feeinstallment_rec."FMA_Id";
                    v_FMA_Amount := feeinstallment_rec."FMA_Amount";
                    
                    INSERT INTO "Fee_Master_Student_Group_Installment" (
                        "FMSG_Id", "FMH_ID", "FTI_ID"
                    ) 
                    VALUES (
                        v_FMSG_Id, v_FMH_Id, v_FTI_Id
                    );
                    
                    INSERT INTO "Fee_Student_Status" (
                        "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
                        "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", 
                        "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount",
                        "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount",
                        "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount",
                        "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", 
                        "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", 
                        "FSS_ActiveFlag", "User_Id", "fss_refundableamount"
                    ) 
                    VALUES (
                        p_MI_Id, p_ASMAY_ID, p_AMST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id,
                        0, 0, v_FMA_Amount, v_FMA_Amount, v_FMA_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, v_FMA_Amount, 0, 0, 0, 1, p_UserId, 0
                    );
                END LOOP;
            END IF;
        END LOOP;
        
        PERFORM "dbo"."Automapping_Promotion_Opening_Balance"(
            p_amst_id, p_mi_id, p_asmay_id, p_userid, p_previous_asmay_id
        );
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
    
    RETURN;
END;
$$;