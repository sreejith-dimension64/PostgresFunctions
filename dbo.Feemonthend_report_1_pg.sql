CREATE OR REPLACE FUNCTION "dbo"."Feemonthend_report_1"(
    p_fromdate TEXT,
    p_todate TEXT,
    p_type BIGINT,
    p_mi_id BIGINT,
    p_amay_id TEXT,
    p_user_id TEXT,
    p_acayid TEXT
)
RETURNS TABLE(
    cashcount BIGINT,
    bankcount BIGINT,
    onlinecount BIGINT,
    rtgs BIGINT,
    cardcount BIGINT,
    ecs BIGINT,
    defaulters BIGINT,
    refund BIGINT,
    refundbank BIGINT,
    smscount BIGINT,
    emailcount BIGINT,
    challancount BIGINT,
    refountonline BIGINT,
    feeadjustment BIGINT,
    feewaveoff BIGINT,
    firstterm BIGINT,
    secondterm BIGINT,
    thridterm BIGINT,
    fourthterm BIGINT,
    feeupdate BIGINT,
    feedelete BIGINT
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
    v_datenew TEXT;
    v_challancount BIGINT;
    v_refountonline BIGINT;
    v_feeadjustment BIGINT;
    v_feewaveoff BIGINT;
    v_firstterm BIGINT;
    v_secondterm BIGINT;
    v_thridterm BIGINT;
    v_fourthterm BIGINT;
    v_feeupdate BIGINT;
    v_feedelete BIGINT;
BEGIN
    v_feedelete := 0;
    v_feeupdate := 0;
    v_secondterm := 0;
    v_thridterm := 0;
    v_fourthterm := 0;
    v_feeadjustment := 0;
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
    v_challancount := 0;
    v_refountonline := 0;
    v_feewaveoff := 0;
    v_firstterm := 0;

    IF p_acayid = '1' THEN
        SELECT COUNT("IVRM_SSB_ID") INTO v_smscount
        FROM "IVRM_sms_sentBox"
        WHERE "MI_Id" = p_mi_id
            AND EXTRACT(YEAR FROM "Datetime") = p_todate::BIGINT
            AND EXTRACT(MONTH FROM "Datetime") = p_fromdate::BIGINT
            AND "Module_Name" = 'FEES';

        SELECT COUNT("IVRMESB_ID") INTO v_emailcount
        FROM "IVRM_Email_sentBox"
        WHERE "MI_Id" = p_mi_id
            AND EXTRACT(YEAR FROM "Datetime") = p_todate::BIGINT
            AND EXTRACT(MONTH FROM "Datetime") = p_fromdate::BIGINT
            AND "Module_Name" = 'FEES';

        SELECT COUNT(DISTINCT "fyp_receipt_no") INTO v_cashcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id
            AND "fyp_bank_or_cash" = 'C'
            AND "ASMAY_ID" = p_amay_id::BIGINT
            AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
            AND "user_id" = p_user_id
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT(DISTINCT "fyp_receipt_no") INTO v_Bankcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id
            AND "fyp_bank_or_cash" = 'B'
            AND "ASMAY_ID" = p_amay_id::BIGINT
            AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
            AND "user_id" = p_user_id
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_onlinecount
        FROM "Fee_Y_Payment"
        INNER JOIN "Fee_Payment_Settlement_Details" ON "Fee_Payment_Settlement_Details"."FYPPSD_PAYU_Id" = "Fee_Y_Payment"."FYP_PaymentReference_Id"
        INNER JOIN "Fee_Payment_Overall_Settlement_Details" ON "Fee_Payment_Overall_Settlement_Details"."FYPPST_Id" = "Fee_Payment_Settlement_Details"."FYPPST_Id"
        WHERE "Fee_Y_Payment"."mi_id" = p_mi_id
            AND "fyp_bank_or_cash" = 'O'
            AND EXTRACT(MONTH FROM "FYPPST_Settlement_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FYPPST_Settlement_Date") = p_todate::BIGINT
            AND "Fee_Payment_Overall_Settlement_Details"."user_id" = p_user_id
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("FYP_ChallanNo") INTO v_challancount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id
            AND "ASMAY_ID" = p_amay_id::BIGINT
            AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
            AND "user_id" = p_user_id
            AND "FYP_ChallanNo" IS NOT NULL;

        SELECT COUNT("fyp_receipt_no") INTO v_cardcount
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id
            AND "fyp_bank_or_cash" = 'S'
            AND "ASMAY_ID" = p_amay_id::BIGINT
            AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
            AND "user_id" = p_user_id
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("fyp_receipt_no") INTO v_RTGS
        FROM "fee_y_payment"
        WHERE "mi_id" = p_mi_id
            AND "fyp_bank_or_cash" = 'R'
            AND "ASMAY_ID" = p_amay_id::BIGINT
            AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
            AND "user_id" = p_user_id
        GROUP BY "fyp_bank_or_cash";

        SELECT COUNT("FR_ID") INTO v_refountcashcount
        FROM "Fee_Refund"
        WHERE "mi_id" = p_mi_id
            AND "FR_BANK_CASH" = 'C'
            AND "ASMAY_ID" = p_amay_id::BIGINT
            AND EXTRACT(MONTH FROM "FR_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FR_Date") = p_todate::BIGINT
            AND "user_id" = p_user_id;

        SELECT COUNT("FR_ID") INTO v_refountbankcount
        FROM "Fee_Refund"
        WHERE "mi_id" = p_mi_id
            AND "FR_BANK_CASH" = 'B'
            AND "ASMAY_ID" = p_amay_id::BIGINT
            AND EXTRACT(MONTH FROM "FR_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FR_Date") = p_todate::BIGINT
            AND "user_id" = p_user_id;

        SELECT COUNT("FSA_ID") INTO v_feeadjustment
        FROM "Fee_Student_Adjustment"
        WHERE "MI_Id" = p_mi_id
            AND "ASMAY_Id" = p_amay_id::BIGINT
            AND EXTRACT(MONTH FROM "FSA_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FSA_Date") = p_todate::BIGINT
            AND "user_id" = p_user_id;

        SELECT COUNT("FSWO_Id") INTO v_feewaveoff
        FROM "Fee_Student_Waived_Off"
        WHERE "MI_Id" = p_mi_id
            AND "ASMAY_Id" = p_amay_id::BIGINT
            AND EXTRACT(MONTH FROM "FSWO_Date") = p_fromdate::BIGINT
            AND EXTRACT(YEAR FROM "FSWO_Date") = p_todate::BIGINT
            AND "User_id" = p_user_id;

        SELECT COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") INTO v_defaulters
        FROM "Fee_Master_Group"
        INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
            AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_amay_id::BIGINT
            AND "Fee_Student_Status"."User_Id" = p_user_id
            AND "Fee_Student_Status"."MI_Id" = p_mi_id
            AND "Fee_Master_Terms"."FMT_Id" IN (1, 2, 9, 10, 5, 6, 17, 18)
            AND "Fee_Student_Status"."FSS_ToBePaid" > 0;

        SELECT COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") INTO v_firstterm
        FROM "Fee_Master_Group"
        INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
            AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_amay_id::BIGINT
            AND "Fee_Student_Status"."User_Id" = p_user_id
            AND "Fee_Student_Status"."MI_Id" = p_mi_id
            AND "Fee_Master_Terms"."FMT_Id" IN (1, 5, 9, 17, 35)
            AND "Fee_Student_Status"."FSS_ToBePaid" > 0;

    ELSE
        IF p_type = 0 THEN
            SELECT COUNT("IVRM_SSB_ID") INTO v_smscount
            FROM "IVRM_sms_sentBox"
            WHERE "MI_Id" = p_mi_id
                AND EXTRACT(YEAR FROM "Datetime") = p_todate::BIGINT
                AND EXTRACT(MONTH FROM "Datetime") = p_fromdate::BIGINT
                AND "Module_Name" = 'FEES';

            SELECT COUNT("IVRMESB_ID") INTO v_emailcount
            FROM "IVRM_Email_sentBox"
            WHERE "MI_Id" = p_mi_id
                AND EXTRACT(YEAR FROM "Datetime") = p_todate::BIGINT
                AND EXTRACT(MONTH FROM "Datetime") = p_fromdate::BIGINT
                AND "Module_Name" = 'FEES';

            SELECT COUNT(DISTINCT "fyp_receipt_no") INTO v_cashcount
            FROM "fee_y_payment"
            WHERE "mi_id" = p_mi_id
                AND "fyp_bank_or_cash" = 'C'
                AND "ASMAY_ID" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id
            GROUP BY "fyp_bank_or_cash";

            SELECT COUNT(DISTINCT "fyp_receipt_no") INTO v_Bankcount
            FROM "fee_y_payment"
            WHERE "mi_id" = p_mi_id
                AND "fyp_bank_or_cash" = 'B'
                AND "ASMAY_ID" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id
            GROUP BY "fyp_bank_or_cash";

            SELECT COUNT("fyp_receipt_no") INTO v_onlinecount
            FROM "fee_y_payment"
            WHERE "mi_id" = p_mi_id
                AND "fyp_bank_or_cash" = 'O'
                AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id
            GROUP BY "fyp_bank_or_cash";

            SELECT COUNT("fyp_receipt_no") INTO v_cardcount
            FROM "fee_y_payment"
            WHERE "mi_id" = p_mi_id
                AND "fyp_bank_or_cash" = 'S'
                AND "ASMAY_ID" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id
            GROUP BY "fyp_bank_or_cash";

            SELECT COUNT("FYP_ChallanNo") INTO v_challancount
            FROM "fee_y_payment"
            WHERE "mi_id" = p_mi_id
                AND "ASMAY_ID" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id
                AND "FYP_ChallanNo" IS NOT NULL;

            SELECT COUNT("fyp_receipt_no") INTO v_RTGS
            FROM "fee_y_payment"
            WHERE "mi_id" = p_mi_id
                AND "fyp_bank_or_cash" = 'R'
                AND "ASMAY_ID" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FYP_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FYP_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id
            GROUP BY "fyp_bank_or_cash";

            SELECT COUNT("FR_ID") INTO v_refountcashcount
            FROM "Fee_Refund"
            WHERE "mi_id" = p_mi_id
                AND "FR_BANK_CASH" = 'C'
                AND "ASMAY_ID" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FR_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FR_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id;

            SELECT COUNT("FR_ID") INTO v_refountbankcount
            FROM "Fee_Refund"
            WHERE "mi_id" = p_mi_id
                AND "FR_BANK_CASH" = 'B'
                AND "ASMAY_ID" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FR_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FR_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id;

            SELECT COUNT("FR_ID") INTO v_refountonline
            FROM "Fee_Refund"
            WHERE "mi_id" = p_mi_id
                AND "FR_BANK_CASH" = 'O'
                AND "ASMAY_ID" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FR_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FR_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id;

            SELECT COUNT("FSA_ID") INTO v_feeadjustment
            FROM "Fee_Student_Adjustment"
            WHERE "MI_Id" = p_mi_id
                AND "ASMAY_Id" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FSA_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FSA_Date") = p_todate::BIGINT
                AND "user_id" = p_user_id;

            SELECT COUNT("FSWO_Id") INTO v_feewaveoff
            FROM "Fee_Student_Waived_Off"
            WHERE "MI_Id" = p_mi_id
                AND "ASMAY_Id" = p_amay_id::BIGINT
                AND EXTRACT(MONTH FROM "FSWO_Date") = p_fromdate::BIGINT
                AND EXTRACT(YEAR FROM "FSWO_Date") = p_todate::BIGINT
                AND "User_id" = p_user_id;

            SELECT COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") INTO v_defaulters
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
                AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
                AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_amay_id::BIGINT
                AND "Fee_Student_Status"."User_Id" = p_user_id
                AND "Fee_Student_Status"."MI_Id" = p_mi_id
                AND "Fee_Master_Terms"."FMT_Id" IN (1, 5, 9, 17, 35, 2, 6, 10, 18, 28, 36, 3, 7, 11, 29, 38, 4, 8, 12, 30)
                AND "Fee_Student_Status"."FSS_ToBePaid" > 0;

            SELECT COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") INTO v_firstterm
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
                AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
                AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_amay_id::BIGINT
                AND "Fee_Student_Status"."User_Id" = p_user_id
                AND "Fee_Student_Status"."MI_Id" = p_mi_id
                AND "Fee_Master_Terms"."FMT_Id" IN (1, 5, 9, 17, 35)
                AND "Fee_Student_Status"."FSS_ToBePaid" > 0;

            SELECT COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") INTO v_secondterm
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
                AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
                AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_