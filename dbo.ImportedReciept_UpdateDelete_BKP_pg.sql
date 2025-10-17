CREATE OR REPLACE FUNCTION "dbo"."ImportedReciept_UpdateDelete_BKP"(
    p_MI_ID BIGINT,
    p_ASMAY_ID BIGINT,
    p_AMST_ID BIGINT,
    p_FYP_ID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_StatusCnt BIGINT;
BEGIN
    SELECT COUNT("Fss"."FSS_Id") INTO v_StatusCnt
    FROM "Fee_Student_Status" "FSS" 
    INNER JOIN "fee_t_payment" "FTP" ON "FTP"."FMA_id" = "FSS"."FMA_id" 
    INNER JOIN "fee_y_payment" "FYP" ON "FYP"."FYP_ID" = "FTP"."FYP_ID" AND "FYP"."MI_Id" = "FSS"."MI_Id"
    INNER JOIN "fee_y_payment_school_student" "PSS" ON "PSS"."AMST_Id" = "FSS"."AMST_Id" 
        AND "FYP"."FYP_ID" = "PSS"."FYP_ID" AND "FYP"."ASMAY_Id" = "PSS"."ASMAY_Id"
    WHERE "FSS"."MI_Id" = p_MI_ID 
        AND "FSS"."ASMAY_Id" = p_ASMAY_ID 
        AND "FSS"."AMST_Id" = p_AMST_ID 
        AND "FYP"."FYP_ID" = p_FYP_ID 
        AND ("FSS"."FSS_WaivedAmount" != 0
            OR "FSS"."FSS_RunningExcessAmount" != 0 
            OR "FSS"."FSS_AdjustedAmount" != 0);

    IF (v_StatusCnt = 0) THEN
        BEGIN
            UPDATE "Fee_Student_Status" "FSS" 
            SET "FSS_PaidAmount" = ("FSS_PaidAmount" - "FTP"."FTP_Paid_Amt"), 
                "FSS_ToBePaid" = CASE WHEN COALESCE("Fss"."FSS_FineAmount", 0) = 0 
                                     THEN ("FSS_ToBePaid" + "FTP"."FTP_Paid_Amt") 
                                     ELSE "FSS_ToBePaid" END, 
                "FSS_FineAmount" = CASE WHEN ("Fss"."FSS_FineAmount" - "FTP"."FTP_Paid_Amt") >= 0 
                                       THEN ("Fss"."FSS_FineAmount" - "FTP"."FTP_Paid_Amt") 
                                       ELSE 0 END,
                "FSS_ExcessPaidAmount" = CASE WHEN ("Fss"."FSS_ExcessPaidAmount" - "FTP"."FTP_Paid_Amt") >= 0 
                                             THEN ("Fss"."FSS_ExcessPaidAmount" - "FTP"."FTP_Paid_Amt") 
                                             ELSE 0 END,  
                "FSS_RunningExcessAmount" = CASE WHEN ("Fss"."FSS_RunningExcessAmount" - "FTP"."FTP_Paid_Amt") >= 0 
                                                THEN ("Fss"."FSS_RunningExcessAmount" - "FTP"."FTP_Paid_Amt") 
                                                ELSE 0 END    
            FROM "fee_t_payment" "FTP"
            INNER JOIN "fee_y_payment" "FYP" ON "FYP"."FYP_ID" = "FTP"."FYP_ID" AND "FYP"."MI_Id" = "FSS"."MI_Id"
            INNER JOIN "fee_y_payment_school_student" "PSS" ON "PSS"."AMST_Id" = "FSS"."AMST_Id" 
                AND "FYP"."FYP_ID" = "PSS"."FYP_ID" AND "FYP"."ASMAY_Id" = "PSS"."ASMAY_Id"
            WHERE "FTP"."FMA_id" = "FSS"."FMA_id"
                AND "FSS"."MI_Id" = p_MI_ID 
                AND "FSS"."ASMAY_Id" = p_ASMAY_ID 
                AND "FSS"."AMST_Id" = p_AMST_ID 
                AND "FYP"."FYP_ID" = p_FYP_ID 
                AND "FSS"."FSS_WaivedAmount" = 0
                AND "FSS"."FSS_AdjustedAmount" = 0 
                AND "FSS"."FSS_RunningExcessAmount" = 0
                AND (("FSS"."FSS_NetAmount" != 0 OR "FSS"."FSS_OBArrearAmount" != 0) OR "FSS"."FSS_FineAmount" != 0);

            DELETE FROM "Fee_T_Payment" WHERE "FYP_ID" = p_FYP_ID;

            DELETE FROM "Fee_Y_Payment_PaymentMode" WHERE "FYP_ID" = p_FYP_ID;

            DELETE FROM "Fee_Y_Payment_School_Student" WHERE "FYP_ID" = p_FYP_ID;

            DELETE FROM "Fee_Y_Payment" WHERE "FYP_ID" = p_FYP_ID;

        EXCEPTION
            WHEN OTHERS THEN
                RAISE;
        END;
    END IF;
    
    RETURN;
END;
$$;