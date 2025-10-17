CREATE OR REPLACE FUNCTION "ImportedReciept_UpdateDelete"(
    p_MI_ID BIGINT,
    p_ASMAY_ID BIGINT,
    p_AMST_ID BIGINT,
    p_FYP_ID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMA_ID BIGINT;
    v_FSSST_PaidAmount DECIMAL(18,2);
    v_FSS_ExcessPaidAmount DECIMAL(18,2);
    v_FSS_RunningExcessAmount DECIMAL(18,2);
    v_DELCANDEL BIGINT;
    v_FMH_ID BIGINT;
    v_FINEHEADS BIGINT;
    v_FSS_NetAmount DECIMAL(18,2);
    v_FSS_OBArrearAmount DECIMAL(18,2);
BEGIN
    SELECT COUNT("FMH_ID") INTO v_DELCANDEL
    FROM "FEE_STUDENT_STATUS" "FSS" 
    INNER JOIN "FEE_T_PAYMENT" "FTP" ON "FTP"."FMA_ID" = "FSS"."FMA_ID"
    INNER JOIN "FEE_Y_PAYMENT_SCHOOL_STUDENT" "FYST" ON "FYST"."FYP_ID" = "FTP"."FYP_ID"
    WHERE "FSS"."MI_ID" = p_MI_ID AND "FSS"."ASMAY_ID" = p_ASMAY_ID AND "FSS"."AMST_ID" = p_AMST_ID AND "FTP"."FYP_ID" = p_FYP_ID
    AND ("FSS_WaivedAmount" > 0 OR "FSS_AdjustedAmount" > 0 OR "FSS_RunningExcessAmount" > 0);

    IF v_DELCANDEL = 0 THEN
        SELECT "FMH_ID", "FSS"."FMA_ID", "FTP_Paid_Amt", "FSS_ExcessPaidAmount", "FSS_RunningExcessAmount"
        INTO v_FMH_ID, v_FMA_ID, v_FSSST_PaidAmount, v_FSS_ExcessPaidAmount, v_FSS_RunningExcessAmount
        FROM "FEE_STUDENT_STATUS" "FSS" 
        INNER JOIN "FEE_T_PAYMENT" "FTP" ON "FTP"."FMA_ID" = "FSS"."FMA_ID"
        INNER JOIN "FEE_Y_PAYMENT_SCHOOL_STUDENT" "FYST" ON "FYST"."FYP_ID" = "FTP"."FYP_ID"
        WHERE "MI_ID" = p_MI_ID AND "FSS"."ASMAY_ID" = p_ASMAY_ID AND "FSS"."AMST_ID" = p_AMST_ID AND "FTP"."FYP_ID" = p_FYP_ID;

        CREATE TEMP TABLE fmaids ON COMMIT DROP AS
        SELECT "FSS"."FMA_ID" 
        FROM "FEE_STUDENT_STATUS" "FSS" 
        INNER JOIN "FEE_T_PAYMENT" "FTP" ON "FTP"."FMA_ID" = "FSS"."FMA_ID"
        INNER JOIN "FEE_Y_PAYMENT_SCHOOL_STUDENT" "FYST" ON "FYST"."FYP_ID" = "FTP"."FYP_ID"
        WHERE "MI_ID" = p_MI_ID AND "FSS"."ASMAY_ID" = p_ASMAY_ID AND "FSS"."AMST_ID" = p_AMST_ID AND "FTP"."FYP_ID" = p_FYP_ID;

        UPDATE "Fee_Student_Status"  
        SET "FSS_PaidAmount" = "FSS_PaidAmount" - v_FSSST_PaidAmount
        WHERE "FMA_Id" IN (SELECT "FMA_ID" FROM fmaids) AND "MI_Id" = p_MI_ID AND "ASMAY_ID" = p_ASMAY_ID AND "AMST_Id" = p_AMST_ID;

        IF v_FSS_ExcessPaidAmount > 0 THEN
            UPDATE "fee_Student_Status"
            SET "FSS_ExcessPaidAmount" = "FSS_ExcessPaidAmount" - v_FSSST_PaidAmount
            WHERE "FMA_Id" IN (SELECT "FMA_ID" FROM fmaids) AND "MI_Id" = p_MI_ID AND "ASMAY_ID" = p_ASMAY_ID AND "AMST_Id" = p_AMST_ID;
        END IF;

        IF v_FSS_RunningExcessAmount > 0 THEN
            UPDATE "fee_Student_Status"
            SET "FSS_RunningExcessAmount" = "FSS_RunningExcessAmount" - v_FSSST_PaidAmount
            WHERE "FMA_Id" IN (SELECT "FMA_ID" FROM fmaids) AND "MI_Id" = p_MI_ID AND "ASMAY_ID" = p_ASMAY_ID AND "AMST_Id" = p_AMST_ID;
        END IF;

        SELECT COUNT("FMH"."FMH_Id"), "FSS_NetAmount", "FSS_OBArrearAmount"
        INTO v_FINEHEADS, v_FSS_NetAmount, v_FSS_OBArrearAmount
        FROM "Fee_Student_Status" "FSS"
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id"
        WHERE "FMH_Flag" = 'F'
        AND "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_ID AND "FMA_Id" = v_FMA_ID AND "FSS"."MI_Id" = p_MI_ID
        GROUP BY "FSS_NetAmount", "FSS_OBArrearAmount";

        IF v_FINEHEADS > 0 THEN
            UPDATE "Fee_Student_Status"
            SET "FSS_FineAmount" = "FSS_FineAmount" - v_FSSST_PaidAmount
            WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_ID AND "FMA_Id" IN (SELECT "FMA_ID" FROM fmaids) AND "MI_Id" = p_MI_ID;
        END IF;

        IF v_FSS_NetAmount != 0 AND v_FSS_OBArrearAmount = 0 THEN
            UPDATE "Fee_Student_Status"
            SET "FSS_ToBePaid" = "FSS_ToBePaid" + v_FSSST_PaidAmount
            WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_ID AND "FMA_Id" IN (SELECT "FMA_ID" FROM fmaids) AND "MI_Id" = p_MI_ID;
        ELSIF v_FSS_NetAmount != 0 AND v_FSS_OBArrearAmount != 0 THEN
            UPDATE "Fee_Student_Status"
            SET "FSS_ToBePaid" = "FSS_ToBePaid" + v_FSSST_PaidAmount
            WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_ID AND "FMA_Id" IN (SELECT "FMA_ID" FROM fmaids) AND "MI_Id" = p_MI_ID;
        ELSIF v_FSS_NetAmount = 0 AND v_FSS_OBArrearAmount != 0 THEN
            UPDATE "Fee_Student_Status"
            SET "FSS_ToBePaid" = "FSS_ToBePaid" + v_FSSST_PaidAmount
            WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_ID AND "FMA_Id" IN (SELECT "FMA_ID" FROM fmaids) AND "MI_Id" = p_MI_ID;
        ELSE
            UPDATE "Fee_Student_Status"
            SET "FSS_ToBePaid" = 0
            WHERE "AMST_Id" = p_AMST_ID AND "ASMAY_Id" = p_ASMAY_ID AND "FMA_Id" IN (SELECT "FMA_ID" FROM fmaids) AND "MI_Id" = p_MI_ID;
        END IF;
    END IF;

    DELETE FROM "fee_t_payment"  
    WHERE "FYP_Id" = p_FYP_ID;

    DELETE FROM "Fee_Y_Payment_PaymentMode"  
    WHERE "FYP_Id" = p_FYP_ID;

    DELETE FROM "Fee_Y_Payment_School_Student"  
    WHERE "FYP_Id" = p_FYP_ID;

    DELETE FROM "Fee_Y_Payment"  
    WHERE "FYP_Id" = p_FYP_ID;

    RETURN;
END;
$$;