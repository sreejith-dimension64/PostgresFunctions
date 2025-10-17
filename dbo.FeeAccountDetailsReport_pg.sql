CREATE OR REPLACE FUNCTION "dbo"."FeeAccountDetailsReport"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@from_date" TEXT,
    "@to_date" TEXT,
    "@userid" TEXT
)
RETURNS TABLE(
    "FPGD_AccNo" VARCHAR,
    "FTP_Paid_Amt" NUMERIC,
    "FMH_FeeName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "Fee_PaymentGateway_Details"."FPGD_AccNo",
        SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "FTP_Paid_Amt",
        "Fee_Master_Head"."FMH_FeeName"
    FROM "Fee_PaymentGateway_Details"
    INNER JOIN "Fee_OnlinePayment_Mapping" ON "Fee_OnlinePayment_Mapping"."fpgd_id" = "Fee_PaymentGateway_Details"."FPGD_Id"
    INNER JOIN "Fee_Master_Amount" ON "Fee_Master_Amount"."FMG_Id" = "Fee_OnlinePayment_Mapping"."fmg_id" 
        AND "Fee_OnlinePayment_Mapping"."fti_id" = "Fee_Master_Amount"."FTI_Id"
        AND "Fee_Master_Amount"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id"
    INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
    INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Amount"."FMH_Id"
    WHERE "Fee_OnlinePayment_Mapping"."MI_Id" = "@MI_Id" 
        AND "Fee_Y_Payment"."MI_Id" = "@MI_Id" 
        AND "Fee_Y_Payment"."ASMAY_ID" = "@ASMAY_Id" 
        AND "Fee_PaymentGateway_Details"."MI_Id" = "@MI_Id"
    GROUP BY "Fee_PaymentGateway_Details"."FPGD_AccNo", "Fee_Master_Head"."FMH_FeeName";

END;
$$;