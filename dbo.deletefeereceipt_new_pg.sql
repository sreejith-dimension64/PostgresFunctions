CREATE OR REPLACE FUNCTION "dbo"."deletefeereceipt_new"(
    p_mi_id BIGINT,
    p_amst_id BIGINT,
    p_asmay_id BIGINT,
    p_fyp_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_fma_id BIGINT;
    v_paidamount BIGINT;
    v_statuspaidamount BIGINT;
    v_statuspendingamount BIGINT;
    v_statusconcessionamount BIGINT;
    v_netpayableamount BIGINT;
    v_groupid BIGINT;
    v_headid BIGINT;
    v_instid BIGINT;
    v_tpaymentconcessionamount BIGINT;
    v_rowcount INTEGER;
    yearly_fee_rec RECORD;
BEGIN
    SELECT COUNT(*) INTO v_rowcount
    FROM "Fee_Y_Payment"
    WHERE "MI_Id" = p_mi_id
        AND "ASMAY_ID" = p_asmay_id
        AND "FYP_Id" = p_fyp_id;

    IF v_rowcount > 0 THEN
        FOR yearly_fee_rec IN
            SELECT "FMA_Id", "FTP_Paid_Amt", "FTP_Concession_Amt"
            FROM "Fee_T_Payment"
            WHERE "FYP_Id" = p_fyp_id
        LOOP
            v_fma_id := yearly_fee_rec."FMA_Id";
            v_paidamount := yearly_fee_rec."FTP_Paid_Amt";
            v_tpaymentconcessionamount := yearly_fee_rec."FTP_Concession_Amt";

            SELECT "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ConcessionAmount", "FSS_TotalToBePaid"
            INTO v_statuspendingamount, v_statuspaidamount, v_statusconcessionamount, v_netpayableamount
            FROM "Fee_Student_Status"
            WHERE "AMST_Id" = p_amst_id
                AND "MI_Id" = p_mi_id
                AND "ASMAY_Id" = p_asmay_id
                AND "FMA_Id" = v_fma_id;

            GET DIAGNOSTICS v_rowcount = ROW_COUNT;

            IF v_rowcount > 0 THEN
                IF v_netpayableamount >= v_statuspendingamount + v_statuspaidamount THEN
                    UPDATE "Fee_Student_Status"
                    SET "FSS_ToBePaid" = v_statuspendingamount + v_paidamount,
                        "FSS_PaidAmount" = v_statuspaidamount - v_paidamount
                    WHERE "MI_Id" = p_mi_id
                        AND "ASMAY_Id" = p_asmay_id
                        AND "AMST_Id" = p_amst_id
                        AND "FMA_Id" = v_fma_id;

                    DELETE FROM "Fee_T_Payment"
                    WHERE "FYP_Id" = p_fyp_id
                        AND "FMA_Id" = v_fma_id;
                END IF;
            END IF;
        END LOOP;

        DELETE FROM "Fee_Y_Payment_School_Student"
        WHERE "FYP_Id" = p_fyp_id
            AND "AMST_Id" = p_amst_id;

        DELETE FROM "Fee_Y_Payment"
        WHERE "MI_Id" = p_mi_id
            AND "ASMAY_ID" = p_asmay_id
            AND "FYP_Id" = p_fyp_id
            AND "mi_id" = p_mi_id;
    END IF;

    RETURN;
END;
$$;