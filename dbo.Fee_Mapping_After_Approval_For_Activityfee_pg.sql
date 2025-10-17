CREATE OR REPLACE FUNCTION "dbo"."Fee_Mapping_After_Approval_For_Activityfee"(
    p_mi_id BIGINT,
    p_asmay_id BIGINT,
    p_amst_id BIGINT,
    p_fmg_id BIGINT,
    p_fmh_id BIGINT,
    p_userid BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMSG_Id BIGINT;
    v_FTI_Id BIGINT;
    v_fma_id BIGINT;
    v_fma_amount BIGINT;
    v_row_count INTEGER;
    yearly_fee_rec RECORD;
BEGIN

    SELECT * INTO TEMP TABLE temp_result1
    FROM "Fee_Master_Student_Group" 
    INNER JOIN "Fee_Master_Student_Group_Installment" 
        ON "Fee_Master_Student_Group"."FMSG_Id" = "Fee_Master_Student_Group_Installment"."FMSG_Id"
    INNER JOIN "Fee_Student_Status" 
        ON "Fee_Student_Status"."amst_id" = "Fee_Master_Student_Group"."amst_id"
        AND "Fee_Student_Status"."FMG_Id" = "Fee_Master_Student_Group"."FMG_Id" 
        AND "Fee_Student_Status"."FMH_Id" = "Fee_Master_Student_Group_Installment"."FMH_Id"
    WHERE "Fee_Student_Status"."MI_Id" = p_mi_id 
        AND "Fee_Student_Status"."ASMAY_Id" = p_asmay_id 
        AND "Fee_Student_Status"."AMST_Id" = p_amst_id 
        AND "Fee_Student_Status"."FMG_Id" = p_fmg_id
        AND "Fee_Student_Status"."FMH_Id" = p_fmh_id 
        AND "FSS_NetAmount" > 0;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;

    IF v_row_count = 0 THEN

        SELECT * INTO TEMP TABLE temp_result2
        FROM "Fee_Master_Student_Group" 
        WHERE "AMST_Id" = p_amst_id 
            AND "MI_Id" = p_mi_id 
            AND "ASMAY_Id" = p_asmay_id 
            AND "FMG_Id" = p_fmg_id;

        GET DIAGNOSTICS v_row_count = ROW_COUNT;

        IF v_row_count = 0 THEN
            INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
            VALUES (p_mi_id, p_amst_id, p_asmay_id, p_fmg_id, 'Y');
            
            SELECT MAX("FMSG_Id") INTO v_FMSG_Id FROM "Fee_Master_Student_Group";
        END IF;

        FOR yearly_fee_rec IN 
            SELECT "FTI_Id", "FMA_Amount", "FMA_Id" 
            FROM "Fee_Master_Amount" 
            WHERE "MI_Id" = p_mi_id 
                AND "ASMAY_Id" = p_asmay_id 
                AND "FMG_Id" = p_fmg_id 
                AND "FMH_Id" = p_fmh_id 
                AND "FMCC_Id" IN (
                    SELECT "FMCC_Id" 
                    FROM "Fee_Yearly_Class_Category_Classes" 
                    WHERE "ASMCL_Id" IN (
                        SELECT "ASMCL_Id" 
                        FROM "Adm_School_Y_Student" 
                        WHERE "ASMAY_Id" = p_asmay_id 
                            AND "AMST_Id" = p_amst_id
                    )
                )
        LOOP
            v_FTI_Id := yearly_fee_rec."FTI_Id";
            v_fma_amount := yearly_fee_rec."FMA_Amount";
            v_fma_id := yearly_fee_rec."FMA_Id";

            INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
            VALUES (v_FMSG_Id, p_fmh_id, v_FTI_Id);

            INSERT INTO "Fee_Student_Status"(
                "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", 
                "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", 
                "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", 
                "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", 
                "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", 
                "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", 
                "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", 
                "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount"
            ) 
            VALUES(
                p_mi_id, p_asmay_id, p_amst_id, p_fmg_id, p_fmh_id, v_FTI_Id, v_fma_id, 
                0, 0, v_fma_amount, v_fma_amount, v_fma_amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                v_fma_amount, 0, 0, 0, 1, p_userid, 0
            );

        END LOOP;

        DROP TABLE IF EXISTS temp_result2;

    END IF;

    DROP TABLE IF EXISTS temp_result1;

END;
$$;