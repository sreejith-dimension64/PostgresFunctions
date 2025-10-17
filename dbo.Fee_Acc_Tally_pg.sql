CREATE OR REPLACE FUNCTION "dbo"."Fee_Acc_Tally"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_fromdate date,
    p_todate date
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_amst_id bigint;
    v_amt numeric;
    v_row_count integer;
    acc_record RECORD;
BEGIN
    FOR acc_record IN
        SELECT 
            (sum("fee_t_payment"."ftp_paid_Amt") - sum("fee_t_payment"."ftp_fine_Amt")) as amt,
            "Fee_Y_Payment_School_Student"."AMST_ID"
        FROM "fee_t_payment"
        INNER JOIN "fee_y_payment" ON "fee_t_payment"."fyp_id" = "fee_y_payment"."fyp_id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."fyp_id" = "fee_y_payment"."fyp_id"
        WHERE CAST("fee_y_payment"."fyp_date" AS date) BETWEEN p_fromdate AND p_todate 
            AND "fee_y_payment"."FYP_Receipt_No" LIKE 'S%' 
            AND "fee_y_payment"."MI_Id" = p_MI_Id 
            AND "fee_y_payment"."ASMAY_Id" = p_ASMAY_Id 
            AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = p_ASMAY_Id 
        GROUP BY "Fee_Y_Payment_School_Student"."AMST_ID"
    LOOP
        v_amt := acc_record.amt;
        v_amst_id := acc_record."AMST_ID";
        
        PERFORM 
            (sum("fee_t_payment"."ftp_paid_Amt") - sum("fee_t_payment"."ftp_fine_Amt")) as amt,
            "Fee_Y_Payment_School_Student"."AMST_ID"
        FROM "fee_t_payment"
        INNER JOIN "fee_y_payment" ON "fee_t_payment"."fyp_id" = "fee_y_payment"."fyp_id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."fyp_id" = "fee_y_payment"."fyp_id"
        INNER JOIN "adm_m_student" ON "Fee_Y_Payment_School_Student"."amst_id" = "adm_m_student"."amst_id"
        WHERE CAST("fee_y_payment"."fyp_date" AS date) BETWEEN p_fromdate AND p_todate 
            AND "fee_y_payment"."FYP_Receipt_No" LIKE 'S%' 
            AND "fee_y_payment"."MI_Id" = p_MI_Id 
            AND "fee_y_payment"."ASMAY_Id" = p_ASMAY_Id 
            AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = p_ASMAY_Id 
            AND "Fee_Y_Payment_School_Student"."amst_id" = v_amst_id 
        GROUP BY "Fee_Y_Payment_School_Student"."AMST_ID";
        
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        
        IF v_row_count = 0 THEN
            RAISE NOTICE '%', v_amst_id;
        END IF;
    END LOOP;
    
    RETURN;
END;
$$;