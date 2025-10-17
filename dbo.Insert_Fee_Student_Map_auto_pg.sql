CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Student_Map_auto"(
    p_mi_id BIGINT,
    p_ASMAY_ID BIGINT,
    p_AmST_ID BIGINT,
    p_fmg_id BIGINT
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
    v_fmg_id_new BIGINT;
    v_fmsgid BIGINT;
    v_ftp_concession_amt BIGINT;
    v_fmh_id BIGINT;
    v_fti_id BIGINT;
    v_FMSG_Id BIGINT;
    v_asmay_id BIGINT;
    v_row_count INTEGER;
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
    AND "ASMAY_To_Date" > CURRENT_TIMESTAMP;

    v_asmay_id := COALESCE(v_asmay_id, p_ASMAY_ID);

    SELECT "ASMCL_Id" INTO v_amcl_id 
    FROM "Adm_School_Y_Student" 
    WHERE "amst_id" = p_amst_id 
    AND "ASMAY_Id" = v_asmay_id;

    SELECT "FMCC_Id" INTO v_fmcc_id 
    FROM "Fee_Yearly_Class_Category" 
    WHERE "ASMAY_Id" = p_ASMAY_ID 
    AND "MI_Id" = p_mi_id 
    AND "FYCC_Id" IN (
        SELECT "FYCC_Id" 
        FROM "Fee_Yearly_Class_Category_Classes" 
        WHERE "ASMCL_Id" = v_amcl_id
    );

    SELECT MAX("FMSG_Id") INTO v_FMSG_Id 
    FROM "Fee_Master_Student_Group" 
    WHERE "AMST_Id" = p_AmST_ID;

    FOR v_fmh_id, v_fti_id IN 
        SELECT "FMH_Id", "FTI_Id" 
        FROM "Fee_Master_Amount" 
        WHERE "FMG_Id" = p_fmg_id 
        AND "ASMAY_Id" = p_ASMAY_ID 
        AND "MI_Id" = p_mi_id 
        AND "FMCC_Id" = v_fmcc_id
    LOOP
        INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
        VALUES (v_FMSG_Id, v_fmh_id, v_fti_id);

        FOR v_fyghm_id, v_fmg_id_new, v_fmh_id IN 
            SELECT "FYGHM_Id", "FMG_Id", "FMH_Id" 
            FROM "Fee_Yearly_Group_Head_Mapping" 
            WHERE "FMG_Id" = p_fmg_id 
            AND "FYGHM_ActiveFlag" = 1 
            AND "ASMAY_Id" = v_asmay_id 
            AND "FMH_Id" = v_fmh_id 
            AND "FMI_Id" IN (
                SELECT "FMI_Id" 
                FROM "Fee_T_Installment" 
                WHERE "FTI_Id" = v_fti_id
            )
        LOOP
            SELECT "ASMCL_Id" INTO v_amcl_id 
            FROM "Adm_School_Y_Student" 
            WHERE "amst_id" = p_amst_id 
            AND "ASMAY_Id" = v_asmay_id;

            IF v_amcl_id > 0 THEN
                SELECT "FMCC_Id" INTO v_fmcc_id 
                FROM "Fee_Yearly_Class_Category" 
                WHERE "ASMAY_Id" = p_ASMAY_ID 
                AND "MI_Id" = p_mi_id 
                AND "FYCC_Id" IN (
                    SELECT "FYCC_Id" 
                    FROM "Fee_Yearly_Class_Category_Classes" 
                    WHERE "ASMCL_Id" = v_amcl_id
                );

                IF v_fmcc_id > 0 THEN
                    FOR v_fma_id, v_fti_id, v_fti_name, v_fma_amount IN 
                        SELECT "Fee_Master_Amount"."fma_id", 
                               "Fee_Master_Amount"."fti_id",
                               "fee_t_installment"."fti_name", 
                               "Fee_Master_Amount"."fma_amount" 
                        FROM "Fee_Master_Amount" 
                        INNER JOIN "fee_t_installment" 
                            ON "Fee_Master_Amount"."fti_id" = "fee_t_installment"."fti_id" 
                        WHERE "FMCC_Id" = v_fmcc_id 
                        AND "FMG_Id" = v_fmg_id_new 
                        AND "FMH_Id" = v_fmh_id 
                        AND "Fee_Master_Amount"."FTI_Id" = v_fti_id
                    LOOP
                        SELECT "FMH_FeeName" INTO v_fmh_name 
                        FROM "Fee_Master_Head" 
                        WHERE "fmh_id" = v_fmh_id;

                        SELECT "FSCI_ConcessionAmount" INTO v_ftp_concession_amt 
                        FROM "Fee_Student_Concession" 
                        INNER JOIN "Fee_Student_Concession_Installments" 
                            ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" 
                        WHERE "AMST_Id" = p_amst_id 
                        AND "FMH_Id" = v_fmh_id 
                        AND "FTI_Id" = v_fti_id 
                        AND "FMG_Id" = p_fmg_id 
                        AND "MI_Id" = p_MI_ID;

                        v_ftp_concession_amt := COALESCE(v_ftp_concession_amt, 0);

                        SELECT COUNT(*) INTO v_row_count 
                        FROM "Fee_Student_Status" 
                        WHERE "Amst_Id" = p_amst_id 
                        AND "fmg_id" = v_fmg_id_new 
                        AND "fmh_id" = v_fmh_id 
                        AND "fma_id" = v_fma_id;

                        IF v_row_count = 0 THEN
                            INSERT INTO "Fee_Student_Status"(
                                "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", 
                                "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", 
                                "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", 
                                "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", 
                                "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", 
                                "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", 
                                "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag"
                            ) 
                            VALUES(
                                p_MI_ID, v_asmay_id, p_amst_id, p_fmg_id, v_fmh_id, v_fti_id, v_fma_id, 
                                0, 0, v_fma_amount, v_fma_amount, v_fma_amount, 0, 0, 0, 0, 
                                v_ftp_concession_amt, 0, 0, 0, 0, 0, 0, v_fma_amount, 0, 0, 0, 1
                            );

                            PERFORM "dbo"."UpdateStudPaidAmt"(p_amst_id, v_fma_id, p_MI_ID);
                        ELSE
                            UPDATE "Fee_Student_Status" 
                            SET "fmh_id" = v_fmh_id,
                                "fti_id" = v_fti_id, 
                                "asmay_id" = 10,
                                "FSS_NetAmount" = v_fma_amount,
                                "fmg_id" = p_fmg_id 
                            WHERE "Amst_Id" = p_amst_id 
                            AND "fmg_id" = v_fmg_id_new 
                            AND "fmh_id" = v_fmh_id 
                            AND "fma_id" = v_fma_id 
                            AND "asmay_id" = v_asmay_id;

                            PERFORM "dbo"."UpdateStudPaidAmt"(p_amst_id, v_fma_id, p_MI_ID);
                        END IF;
                    END LOOP;
                END IF;
            END IF;
        END LOOP;
    END LOOP;

    RETURN;
END;
$$;