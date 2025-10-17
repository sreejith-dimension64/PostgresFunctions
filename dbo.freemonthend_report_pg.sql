CREATE OR REPLACE FUNCTION "dbo"."freemonthend_report" (
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10)
)
RETURNS TABLE (
    "bankcount" BIGINT,
    "cashcount" BIGINT,
    "onlinecount" BIGINT,
    "ecscount" BIGINT,
    "refoundbankcount" BIGINT,
    "refoundcashcount" BIGINT,
    "defaulterscount" BIGINT,
    "smscount" BIGINT,
    "emailcount" BIGINT,
    "kisokcount" BIGINT,
    "portelanddashboardcount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Bankcount" BIGINT;
    "v_cashcount" BIGINT;
    "v_onlinecount" BIGINT;
    "v_Ecscount" BIGINT;
    "v_refountcashcount" BIGINT;
    "v_refountbankcount" BIGINT;
    "v_defaulters" BIGINT;
    "v_smscount" BIGINT;
    "v_emailcount" BIGINT;
    "v_kisokcount" BIGINT;
    "v_portelNdashcount" BIGINT;
BEGIN
    "v_Bankcount" := 0;
    "v_cashcount" := 0;
    "v_onlinecount" := 0;
    "v_Ecscount" := 0;
    "v_refountcashcount" := 0;
    "v_refountbankcount" := 0;
    "v_defaulters" := 0;
    "v_smscount" := 0;
    "v_emailcount" := 0;
    "v_kisokcount" := 0;
    "v_portelNdashcount" := 0;

    SELECT COUNT(*) INTO "v_Bankcount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'B' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_cashcount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'C' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_onlinecount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'O' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_Ecscount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'E' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_refountbankcount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'B' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_refountcashcount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'C' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_defaulters" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'C' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_smscount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'C' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_emailcount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'C' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_kisokcount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'C' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    SELECT COUNT(*) INTO "v_portelNdashcount" 
    FROM "fee_Y_payment" 
    WHERE "FYP_Bank_Or_Cash" = 'C' 
    AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY');

    RETURN QUERY
    SELECT 
        "v_Bankcount",
        "v_cashcount",
        "v_onlinecount",
        "v_Ecscount",
        "v_refountbankcount",
        "v_refountcashcount",
        "v_defaulters",
        "v_smscount",
        "v_emailcount",
        "v_kisokcount",
        "v_portelNdashcount";

END;
$$;