CREATE OR REPLACE FUNCTION "dbo"."Feemonthend_report" (
    p_fromdate TEXT,
    p_todate TEXT,
    p_type BIGINT,
    p_mi_id BIGINT,
    p_amay_id TEXT
)
RETURNS TABLE (
    cashcount BIGINT,
    bankcount BIGINT,
    onlinecount BIGINT,
    rtgs BIGINT,
    cardcount BIGINT,
    ecs BIGINT,
    defaulters BIGINT,
    refund BIGINT,
    refundbank BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_VOUCHER_NO TEXT;
    v_VOUCHER_NO_NEW TEXT;
    v_cardcount BIGINT;
    v_missingemail BIGINT;
    v_missingphone BIGINT;
    v_missingphoto BIGINT;
    v_newadmision BIGINT;
    v_Bankcount BIGINT;
    v_cashcount BIGINT;
    v_onlinecount BIGINT;
    v_Ecscount BIGINT;
    v_RTGS BIGINT;
    v_refountbankcount BIGINT;
    v_refountcashcount BIGINT;
    v_defaulters BIGINT;
    v_smscount BIGINT;
    v_emailcount BIGINT;
    v_kisokcount BIGINT;
    v_portelNdashcount BIGINT;
    v_newadm BIGINT;
    v_todaydate DATE;
    v_totalnew BIGINT;
    v_total_tc BIGINT;
    v_total_absent BIGINT;
    v_missingphoto_new BIGINT;
    v_missingemail_new BIGINT;
    v_missingphone_new BIGINT;
    v_DOB_Certificate_count BIGINT;
BEGIN
    v_Bankcount := 0;
    v_cashcount := 0;
    v_cardcount := 0;
    v_onlinecount := 0;
    v_Ecscount := 0;
    v_refountcashcount := 0;
    v_RTGS := 0;
    v_refountbankcount := 0;
    v_defaulters := 0;
    v_smscount := 0;
    v_emailcount := 0;
    v_kisokcount := 0;
    v_portelNdashcount := 0;
    v_newadm := 0;
    v_todaydate := NULL;
    v_totalnew := 0;
    v_total_tc := 0;
    v_total_absent := 0;
    v_missingphoto_new := 0;
    v_missingemail_new := 0;
    v_missingphone_new := 0;
    v_DOB_Certificate_count := 0;

    IF p_type = 0 THEN
        SELECT COUNT(DISTINCT "fyp_receipt_no") INTO v_cashcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'C' 
            AND "ASMAY_ID" = p_amay_id
            AND "fyp_date"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT(DISTINCT "fyp_receipt_no") INTO v_Bankcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'B' 
            AND "ASMAY_ID" = p_amay_id
            AND "fyp_date"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_onlinecount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'O'
            AND "fyp_date"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_cardcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'S' 
            AND "ASMAY_ID" = p_amay_id
            AND "fyp_date"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_RTGS
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'R' 
            AND "ASMAY_ID" = p_amay_id
            AND "fyp_date"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_refountcashcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'E' 
            AND "ASMAY_ID" = p_amay_id
            AND "fyp_date"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_refountbankcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'E' 
            AND "ASMAY_ID" = p_amay_id
            AND "fyp_date"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT "fee_due_calculation"(p_amay_id, p_mi_id, p_todate) INTO v_VOUCHER_NO_NEW;

        v_defaulters := v_VOUCHER_NO_NEW;

    ELSE

        SELECT COUNT(DISTINCT "fyp_receipt_no") INTO v_cashcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'C' 
            AND "ASMAY_ID" = p_amay_id
            AND "DOE"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT(DISTINCT "fyp_receipt_no") INTO v_Bankcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'B' 
            AND "ASMAY_ID" = p_amay_id
            AND "DOE"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_onlinecount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'O' 
            AND "ASMAY_ID" = p_amay_id
            AND "DOE"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_cardcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'S' 
            AND "ASMAY_ID" = p_amay_id
            AND "DOE"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_RTGS
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'R' 
            AND "ASMAY_ID" = p_amay_id
            AND "DOE"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_refountcashcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'E' 
            AND "ASMAY_ID" = p_amay_id
            AND "fyp_date"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_refountbankcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id 
            AND "fyp_bank_or_cash" = 'E' 
            AND "ASMAY_ID" = p_amay_id
            AND "fyp_date"::DATE BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
        GROUP BY "fyp_bank_or_cash";

        SELECT "fee_due_calculation"(p_amay_id, p_mi_id, p_todate) INTO v_VOUCHER_NO_NEW;

        v_defaulters := v_VOUCHER_NO_NEW;

    END IF;

    RETURN QUERY
    SELECT 
        COALESCE(v_cashcount, 0)::BIGINT,
        COALESCE(v_Bankcount, 0)::BIGINT,
        COALESCE(v_onlinecount, 0)::BIGINT,
        COALESCE(v_RTGS, 0)::BIGINT,
        COALESCE(v_cardcount, 0)::BIGINT,
        COALESCE(v_Ecscount, 0)::BIGINT,
        COALESCE(v_defaulters, 0)::BIGINT,
        COALESCE(v_refountcashcount, 0)::BIGINT,
        COALESCE(v_refountbankcount, 0)::BIGINT;

END;
$$;