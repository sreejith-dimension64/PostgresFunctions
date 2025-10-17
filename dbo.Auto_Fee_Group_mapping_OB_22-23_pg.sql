CREATE OR REPLACE FUNCTION "dbo"."Auto_Fee_Group_mapping_OB_22-23"(
    p_mi_id BIGINT,
    p_ASMAY_ID BIGINT,
    p_userid BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_fyghm_id BIGINT;
    v_fmcc_id BIGINT;
    v_amcl_id BIGINT;
    v_fma_id BIGINT;
    v_fti_name VARCHAR(100);
    v_fma_amount NUMERIC;
    v_fmh_name VARCHAR(100);
    v_fmg_id BIGINT;
    v_fmsgid BIGINT;
    v_ftp_concession_amt BIGINT;
    v_fmh_id BIGINT;
    v_fti_id BIGINT;
    v_FMSG_Id BIGINT;
    v_AmST_ID BIGINT;
    v_AmST_IDold BIGINT;
    v_FMG_Idnew BIGINT;
    v_rowcount INTEGER;
    rec_feeinstallment RECORD;
BEGIN
    v_amcl_id := 0;
    v_fmcc_id := 0;
    v_fma_id := 0;
    v_fti_name := '';
    v_fma_amount := 0;
    v_fmh_name := '';
    v_ftp_concession_amt := 0;

    v_fmg_id := 26;
    v_AmST_IDold := 77;
    v_FMG_Idnew := 207;

    FOR v_AmST_ID IN 
        SELECT DISTINCT "amst_id" 
        FROM "fee_student_status" 
        WHERE "mi_id" = p_mi_id 
            AND "asmay_id" = v_AmST_IDold 
            AND "fss_tobepaid" > 0 
            AND "FMG_Id" = v_fmg_id 
            AND "AMST_Id" = 3321
    LOOP
        SELECT COUNT(*) INTO v_rowcount
        FROM "Fee_Master_Student_Group" 
        WHERE "MI_Id" = p_mi_id 
            AND "amst_id" = v_AmST_ID 
            AND "ASMAY_Id" = p_ASMAY_ID 
            AND "FMG_Id" = v_FMG_Idnew;

        IF v_rowcount = 0 THEN
            INSERT INTO "Fee_Master_Student_Group" (
                "MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag"
            ) 
            VALUES (
                p_mi_id, v_AmST_ID, p_ASMAY_ID, v_FMG_Idnew, 'Y'
            );

            SELECT MAX("FMSG_Id") INTO v_FMSG_Id 
            FROM "Fee_Master_Student_Group";

            SELECT "ASMCL_Id" INTO v_amcl_id
            FROM "adm_school_Y_student" 
            WHERE "amst_id" = v_AmST_ID 
                AND "ASMAY_Id" = p_ASMAY_ID;

            SELECT "FMCC_Id" INTO v_fmcc_id
            FROM "Fee_Yearly_Class_Category" 
            WHERE "ASMAY_Id" = p_ASMAY_ID 
                AND "MI_Id" = p_mi_id 
                AND "FYCC_Id" IN (
                    SELECT "FYCC_Id" 
                    FROM "Fee_Yearly_Class_Category_Classes" 
                    WHERE "ASMCL_Id" = v_amcl_id
                );

            FOR rec_feeinstallment IN 
                SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
                FROM "Fee_Master_Amount" 
                WHERE "FMG_Id" = v_FMG_Idnew 
                    AND "ASMAY_Id" = p_ASMAY_ID 
                    AND "MI_Id" = p_mi_id 
                    AND "FMCC_Id" = v_fmcc_id
            LOOP
                v_fmh_id := rec_feeinstallment."FMH_Id";
                v_fti_id := rec_feeinstallment."FTI_Id";
                v_fma_id := rec_feeinstallment."FMA_Id";
                v_fma_amount := rec_feeinstallment."FMA_Amount";

                INSERT INTO "Fee_Master_Student_Group_Installment" (
                    "FMSG_Id", "FMH_ID", "FTI_ID"
                ) 
                VALUES (
                    v_FMSG_Id, v_fmh_id, v_fti_id
                );

                INSERT INTO "Fee_Student_Status" (
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
                    p_mi_id, p_ASMAY_ID, v_AmST_ID, v_FMG_Idnew, v_fmh_id, v_fti_id, v_fma_id,
                    0, 0, v_fma_amount, v_fma_amount, v_fma_amount, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, v_fma_amount, 0, 0, 0, 1, p_userid, 0
                );
            END LOOP;
        END IF;
    END LOOP;

    RETURN;
END;
$$;