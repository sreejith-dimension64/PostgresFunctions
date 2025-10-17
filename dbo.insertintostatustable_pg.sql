CREATE OR REPLACE FUNCTION "dbo"."insertintostatustable"(
    p_fmg_id BIGINT,
    p_MI_ID BIGINT,
    p_ASML_ID BIGINT
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
    v_asmay_id BIGINT;
    v_fmg_id_new BIGINT;
    v_fmsgid BIGINT;
    v_ftp_concession_amt BIGINT;
    v_fmh_id BIGINT;
    v_fti_id BIGINT;
    v_FMH_ID_new BIGINT;
    v_amst_id BIGINT;
    v_fti_id_new BIGINT;
    v_row_count INT;
    rec_yearly_fee RECORD;
    rec_fee_det RECORD;
BEGIN
    v_amcl_id := 0;
    v_fmcc_id := 0;
    v_fma_id := 0;
    v_fti_name := '';
    v_fma_amount := 0;
    v_fmh_name := '';
    v_asmay_id := 0;
    v_ftp_concession_amt := 0;

    SELECT "ASMAY_Id" INTO v_asmay_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
    AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
    AND "MI_Id" = p_MI_ID;

    FOR rec_yearly_fee IN
        SELECT DISTINCT "Adm_School_Y_Student"."amst_id",
            "Fee_Master_Student_Group"."fmsg_id",
            "Fee_Master_Student_Group"."fmg_id",
            "Fee_Master_Student_Group_Installment"."fmh_id",
            "Fee_Master_Student_Group_Installment"."fti_id"
        FROM "Fee_Master_Student_Group"
        INNER JOIN "Fee_Master_Student_Group_Installment" 
            ON "Fee_Master_Student_Group_Installment"."fmsg_id" = "Fee_Master_Student_Group"."fmsg_id"
        INNER JOIN "Adm_School_Y_Student" 
            ON "Adm_School_Y_Student"."amst_id" = "Fee_Master_Student_Group"."amst_id"
        WHERE "Fee_Master_Student_Group"."mi_id" = p_MI_ID 
        AND "asmcl_id" = p_ASML_ID
    LOOP
        v_amst_id := rec_yearly_fee."amst_id";
        v_fyghm_id := rec_yearly_fee."fmsg_id";
        v_fmg_id_new := rec_yearly_fee."fmg_id";
        v_FMH_ID_new := rec_yearly_fee."fmh_id";
        v_fti_id_new := rec_yearly_fee."fti_id";

        SELECT "ASMCL_Id" INTO v_amcl_id 
        FROM "Adm_School_Y_Student" 
        WHERE "amst_id" = v_amst_id 
        AND "ASMAY_Id" = v_asmay_id;

        IF COALESCE(v_amcl_id, 0) > 0 THEN
            SELECT "FMCC_Id" INTO v_fmcc_id 
            FROM "Fee_Yearly_Class_Category" 
            WHERE "ASMAY_Id" = v_asmay_id 
            AND "MI_Id" = p_mi_id 
            AND "FYCC_Id" IN (
                SELECT "FYCC_Id" 
                FROM "Fee_Yearly_Class_Category_Classes" 
                WHERE "ASMCL_Id" = p_ASML_ID
            );

            IF COALESCE(v_fmcc_id, 0) > 0 THEN
                FOR rec_fee_det IN
                    SELECT "Fee_Master_Amount"."fma_id",
                        "Fee_Master_Amount"."fti_id",
                        "fee_t_installment"."fti_name",
                        "Fee_Master_Amount"."fma_amount"
                    FROM "Fee_Master_Amount"
                    INNER JOIN "fee_t_installment" 
                        ON "Fee_Master_Amount"."fti_id" = "fee_t_installment"."fti_id"
                    WHERE "FMCC_Id" = v_fmcc_id 
                    AND "FMG_Id" = v_fmg_id_new 
                    AND "FMH_Id" = v_FMH_ID_new 
                    AND "Fee_Master_Amount"."FTI_Id" = v_fti_id_new
                LOOP
                    v_fma_id := rec_fee_det."fma_id";
                    v_fti_id := rec_fee_det."fti_id";
                    v_fti_name := rec_fee_det."fti_name";
                    v_fma_amount := rec_fee_det."fma_amount";

                    SELECT "FMH_FeeName" INTO v_fmh_name 
                    FROM "Fee_Master_Head" 
                    WHERE "fmh_id" = v_FMH_ID_new;

                    PERFORM * 
                    FROM "Fee_Student_Status" 
                    WHERE "Amst_Id" = v_amst_id 
                    AND "fmg_id" = v_fmg_id_new 
                    AND "fmh_id" = v_FMH_ID_new 
                    AND "fma_id" = v_fma_id;

                    v_ftp_concession_amt := 0;
                    SELECT "FSCI_ConcessionAmount" INTO v_ftp_concession_amt 
                    FROM "Fee_Student_Concession"
                    INNER JOIN "Fee_Student_Concession_Installments" 
                        ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id"
                    WHERE "AMST_Id" = v_amst_id 
                    AND "FMH_Id" = v_FMH_ID_new 
                    AND "FTI_Id" = v_fti_id_new 
                    AND "FMG_Id" = p_fmg_id 
                    AND "MI_Id" = p_MI_ID;

                    GET DIAGNOSTICS v_row_count = ROW_COUNT;

                    IF v_row_count = 0 THEN
                        PERFORM * 
                        FROM "Fee_Student_Status" 
                        WHERE "Amst_Id" = v_amst_id 
                        AND "fmg_id" = v_fmg_id_new 
                        AND "fmh_id" = v_FMH_ID_new 
                        AND "fma_id" = v_fma_id;

                        GET DIAGNOSTICS v_row_count = ROW_COUNT;

                        IF v_row_count = 0 THEN
                            INSERT INTO "Fee_Student_Status"(
                                "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
                                "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges",
                                "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount",
                                "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount",
                                "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount",
                                "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount",
                                "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag",
                                "FSS_ActiveFlag", "User_Id"
                            ) VALUES (
                                p_MI_ID, v_asmay_id, v_amst_id, p_fmg_id, v_FMH_ID_new, v_fti_id_new, v_fma_id,
                                0, 0, v_fma_amount, v_fma_amount, v_fma_amount, 0, 0, 0, 0,
                                COALESCE(v_ftp_concession_amt, 0), 0, 0, 0, 0, 0, 0, v_fma_amount,
                                0, 0, 0, 1, 725
                            );

                            PERFORM "dbo"."UpdateStudPaidAmt"(v_amst_id, v_fma_id, p_MI_ID);
                        END IF;
                    ELSE
                        PERFORM "dbo"."UpdateStudPaidAmt"(v_amst_id, v_fma_id, p_MI_ID);
                    END IF;
                END LOOP;
            END IF;
        END IF;
    END LOOP;
END;
$$;