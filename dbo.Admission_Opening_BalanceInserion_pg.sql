CREATE OR REPLACE FUNCTION "dbo"."Admission_Opening_BalanceInserion"(
    p_AMST_ID BIGINT,
    p_MI_ID BIGINT,
    p_ASMAY_ID BIGINT,
    p_userid BIGINT,
    p_ASMCL_Id BIGINT,
    p_ASMST_Id BIGINT
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
    v_FMC_Areawise_FeeFlg BIGINT;
    v_Lasmay_id BIGINT;
    v_STUCONCESSONCAT BIGINT;
    v_STUCONCESSONCATFLAG TEXT;
    v_HRME_ID BIGINT;
    v_FMG_IdNew BIGINT;
    v_newyearorder BIGINT;
    v_revisedorder BIGINT;
    v_rowcount INTEGER;
    rec_feeinstallment RECORD;
    rec_yearly_fee RECORD;
BEGIN
    v_amcl_id := 0;
    v_fmcc_id := 0;
    v_fma_id := 0;
    v_fti_name := '';
    v_fma_amount := 0;
    v_fmh_name := '';
    v_ftp_concession_amt := 0;

    SELECT "FMC_Areawise_FeeFlg" INTO v_FMC_Areawise_FeeFlg 
    FROM "Fee_Master_Configuration" 
    WHERE "mi_id" = p_MI_ID 
    LIMIT 1;

    SELECT "FMG_Id" INTO v_FMG_IdNew 
    FROM "Fee_Master_Stream_Group_Mapping" 
    WHERE "PASL_ID" = p_ASMST_Id 
    LIMIT 1;

    IF v_FMC_Areawise_FeeFlg = 1 THEN
        
        FOR rec_yearly_fee IN (
            SELECT * FROM (
                SELECT "FMG_Id" 
                FROM "Fee_Master_Group" 
                WHERE "MI_Id" = p_MI_ID 
                    AND "FMG_CompulsoryFlag" = 1 
                    AND "FMG_Id" = v_FMG_IdNew
            ) a
        )
        LOOP
            v_fmg_id := rec_yearly_fee."FMG_Id";

            SELECT COUNT(*) INTO v_rowcount
            FROM "Fee_Master_Student_Group" 
            WHERE "FMG_Id" = v_fmg_id 
                AND "MI_Id" = p_MI_ID 
                AND "amst_id" = p_AmST_ID 
                AND "ASMAY_Id" = p_ASMAY_ID;

            IF v_rowcount = 0 THEN
                
                INSERT INTO "Fee_Master_Student_Group" 
                    ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
                VALUES 
                    (p_MI_ID, p_AmST_ID, p_ASMAY_ID, v_fmg_id, 'Y');

                SELECT MAX("FMSG_Id") INTO v_FMSG_Id 
                FROM "Fee_Master_Student_Group";

                SELECT "FMCC_Id" INTO v_fmcc_id 
                FROM "Fee_Yearly_Class_Category" 
                WHERE "ASMAY_Id" = p_ASMAY_ID 
                    AND "MI_Id" = p_MI_ID 
                    AND "FYCC_Id" IN (
                        SELECT "FYCC_Id" 
                        FROM "Fee_Yearly_Class_Category_Classes" 
                        WHERE "ASMCL_Id" = p_ASMCL_Id 
                            AND "ASMAY_Id" = p_ASMAY_ID
                    );

                FOR rec_feeinstallment IN (
                    SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
                    FROM "Fee_Master_Amount" 
                    WHERE "FMG_Id" = v_fmg_id 
                        AND "ASMAY_Id" = p_ASMAY_ID 
                        AND "MI_Id" = p_MI_ID 
                        AND "FMCC_Id" = v_fmcc_id
                )
                LOOP
                    v_fmh_id := rec_feeinstallment."FMH_Id";
                    v_fti_id := rec_feeinstallment."FTI_Id";
                    v_fma_id := rec_feeinstallment."FMA_Id";
                    v_fma_amount := rec_feeinstallment."FMA_Amount";

                    INSERT INTO "Fee_Master_Student_Group_Installment" 
                        ("FMSG_Id", "FMH_ID", "FTI_ID") 
                    VALUES 
                        (v_FMSG_Id, v_fmh_id, v_fti_id);

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
                        p_MI_ID, p_ASMAY_ID, p_AmST_ID, v_fmg_id, v_fmh_id, v_fti_id, v_fma_id, 
                        0, 0, v_fma_amount, v_fma_amount, v_fma_amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                        0, 0, v_fma_amount, 0, 0, 0, 1, p_userid, 0
                    );

                END LOOP;

            END IF;

        END LOOP;

    END IF;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;