CREATE OR REPLACE FUNCTION "clg"."college_month_end_report"(
    "mi_id" BIGINT,
    "asmay_id" BIGINT,
    "fromdate" TEXT,
    "todate" TEXT,
    "user_id" TEXT
)
RETURNS TABLE(
    "cashcount" BIGINT,
    "bankcount" BIGINT,
    "onlinecount" BIGINT,
    "rtgs" BIGINT,
    "cardcount" BIGINT,
    "ecs" BIGINT,
    "refundcash" BIGINT,
    "refundbank" BIGINT,
    "smscount" BIGINT,
    "emailcount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_smscount" BIGINT;
    "v_emailcount" BIGINT;
    "v_cashcount" BIGINT;
    "v_Bankcount" BIGINT;
    "v_onlinecount" BIGINT;
    "v_cardcount" BIGINT;
    "v_RTGS" BIGINT;
    "v_Ecscount" BIGINT;
    "v_refountcashcount" BIGINT;
    "v_refountbankcount" BIGINT;
    "v_date" TEXT;
BEGIN
    "v_smscount" := 0;
    "v_emailcount" := 0;
    "v_cashcount" := 0;
    "v_Bankcount" := 0;
    "v_onlinecount" := 0;
    "v_cardcount" := 0;
    "v_RTGS" := 0;
    "v_refountcashcount" := 0;
    "v_refountbankcount" := 0;
    "v_Ecscount" := 0;

    SELECT COUNT(DISTINCT "FYP_ReceiptNo") INTO "v_cashcount"
    FROM "clg"."Fee_Y_Payment"
    WHERE "mi_id" = "college_month_end_report"."mi_id"
        AND "FYP_TransactionTypeFlag" = 'C'
        AND "ASMAY_ID" = "college_month_end_report"."asmay_id"
        AND EXTRACT(MONTH FROM "FYP_ReceiptDate") = "fromdate"::INTEGER
        AND EXTRACT(YEAR FROM "FYP_ReceiptDate") = "todate"::INTEGER
        AND "user_id" = "college_month_end_report"."user_id";

    SELECT COUNT(DISTINCT "FYP_ReceiptNo") INTO "v_Bankcount"
    FROM "clg"."Fee_Y_Payment"
    WHERE "mi_id" = "college_month_end_report"."mi_id"
        AND "FYP_TransactionTypeFlag" = 'B'
        AND "ASMAY_ID" = "college_month_end_report"."asmay_id"
        AND EXTRACT(MONTH FROM "FYP_ReceiptDate") = "fromdate"::INTEGER
        AND EXTRACT(YEAR FROM "FYP_ReceiptDate") = "todate"::INTEGER
        AND "user_id" = "college_month_end_report"."user_id";

    SELECT COUNT(DISTINCT "FYP_ReceiptNo") INTO "v_onlinecount"
    FROM "clg"."Fee_Y_Payment"
    WHERE "mi_id" = "college_month_end_report"."mi_id"
        AND "FYP_TransactionTypeFlag" = 'O'
        AND "ASMAY_ID" = "college_month_end_report"."asmay_id"
        AND EXTRACT(MONTH FROM "FYP_ReceiptDate") = "fromdate"::INTEGER
        AND EXTRACT(YEAR FROM "FYP_ReceiptDate") = "todate"::INTEGER
        AND "user_id" = "college_month_end_report"."user_id";

    SELECT COUNT(DISTINCT "FYP_ReceiptNo") INTO "v_RTGS"
    FROM "clg"."Fee_Y_Payment"
    WHERE "mi_id" = "college_month_end_report"."mi_id"
        AND "FYP_TransactionTypeFlag" = 'R'
        AND "ASMAY_ID" = "college_month_end_report"."asmay_id"
        AND EXTRACT(MONTH FROM "FYP_ReceiptDate") = "fromdate"::INTEGER
        AND EXTRACT(YEAR FROM "FYP_ReceiptDate") = "todate"::INTEGER
        AND "user_id" = "college_month_end_report"."user_id";

    SELECT COUNT(DISTINCT "FYP_ReceiptNo") INTO "v_cardcount"
    FROM "clg"."Fee_Y_Payment"
    WHERE "mi_id" = "college_month_end_report"."mi_id"
        AND "FYP_TransactionTypeFlag" = 'S'
        AND "ASMAY_ID" = "college_month_end_report"."asmay_id"
        AND EXTRACT(MONTH FROM "FYP_ReceiptDate") = "fromdate"::INTEGER
        AND EXTRACT(YEAR FROM "FYP_ReceiptDate") = "todate"::INTEGER
        AND "user_id" = "college_month_end_report"."user_id";

    SELECT COUNT(DISTINCT "FYP_ReceiptNo") INTO "v_Ecscount"
    FROM "clg"."Fee_Y_Payment"
    WHERE "mi_id" = "college_month_end_report"."mi_id"
        AND "FYP_TransactionTypeFlag" = 'E'
        AND "ASMAY_ID" = "college_month_end_report"."asmay_id"
        AND EXTRACT(MONTH FROM "FYP_ReceiptDate") = "fromdate"::INTEGER
        AND EXTRACT(YEAR FROM "FYP_ReceiptDate") = "todate"::INTEGER
        AND "user_id" = "college_month_end_report"."user_id";

    SELECT COUNT("FCR_RefundNo") INTO "v_refountcashcount"
    FROM "clg"."Fee_College_Refund"
    WHERE "mi_id" = "college_month_end_report"."mi_id"
        AND "FCR_ModeOfPayment" = 'C'
        AND "ASMAY_ID" = "college_month_end_report"."asmay_id"
        AND EXTRACT(MONTH FROM "FCR_Date") = "fromdate"::INTEGER
        AND EXTRACT(YEAR FROM "FCR_Date") = "todate"::INTEGER
        AND "user_id" = "college_month_end_report"."user_id"
    GROUP BY "FCR_ModeOfPayment";

    SELECT COUNT("FCR_RefundNo") INTO "v_refountbankcount"
    FROM "clg"."Fee_College_Refund"
    WHERE "mi_id" = "college_month_end_report"."mi_id"
        AND "FCR_ModeOfPayment" = 'B'
        AND "ASMAY_ID" = "college_month_end_report"."asmay_id"
        AND EXTRACT(MONTH FROM "FCR_Date") = "fromdate"::INTEGER
        AND EXTRACT(YEAR FROM "FCR_Date") = "todate"::INTEGER
        AND "user_id" = "college_month_end_report"."user_id"
    GROUP BY "FCR_ModeOfPayment";

    SELECT COUNT("IVRM_SSB_ID") INTO "v_smscount"
    FROM "IVRM_sms_sentBox"
    WHERE "MI_Id" = "college_month_end_report"."mi_id"
        AND EXTRACT(YEAR FROM "IVRM_sms_sentBox"."Datetime") = "todate"::INTEGER
        AND EXTRACT(MONTH FROM "IVRM_sms_sentBox"."Datetime") = "fromdate"::INTEGER
        AND "Module_Name" = 'FEES';

    SELECT COUNT("IVRMESB_ID") INTO "v_emailcount"
    FROM "IVRM_Email_sentBox"
    WHERE "MI_Id" = "college_month_end_report"."mi_id"
        AND EXTRACT(YEAR FROM "IVRM_Email_sentBox"."Datetime") = "todate"::INTEGER
        AND EXTRACT(MONTH FROM "IVRM_Email_sentBox"."Datetime") = "fromdate"::INTEGER
        AND "Module_Name" = 'FEES';

    RETURN QUERY
    SELECT "v_cashcount", "v_Bankcount", "v_onlinecount", "v_RTGS", "v_cardcount", 
           "v_Ecscount", "v_refountcashcount", "v_refountbankcount", "v_smscount", "v_emailcount";

END;
$$;