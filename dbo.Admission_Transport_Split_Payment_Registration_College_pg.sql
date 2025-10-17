CREATE OR REPLACE FUNCTION "dbo"."Admission_Transport_Split_Payment_Registration_College" (
    "@MI_Id" VARCHAR(50),
    "@Asmay_Id" VARCHAR(50),
    "@Amcst_Id" VARCHAR(50),
    "@paygateway" TEXT
)
RETURNS TABLE (
    "balance" NUMERIC,
    "FPGD_Id" VARCHAR,
    "FPGD_MerchantId" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@termwisetot" TEXT;
    "@flag" VARCHAR(10);
    "@fmt_id" TEXT;
BEGIN

    SELECT STRING_AGG(DISTINCT "fmt_id"::TEXT, ',')
    INTO "@fmt_id"
    FROM "Fee_OnlinePayment_Mapping" 
    INNER JOIN "Fee_Master_Head" ON "Fee_OnlinePayment_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    INNER JOIN "CLG"."Fee_College_Master_Amount" "FCMA" ON "FCMA"."FMG_Id" = "Fee_OnlinePayment_Mapping"."fmg_id"
    WHERE "Fee_OnlinePayment_Mapping"."MI_Id" = "@MI_Id" AND "FMH_Flag" = 'NT';

    "@flag" := 'NT';

    RETURN QUERY EXECUTE 
        'SELECT DISTINCT SUM("FMA_Amount")::NUMERIC AS balance, "Fee_PaymentGateway_Details"."FPGD_Id", "Fee_PaymentGateway_Details"."FPGD_SubMerchantId" AS "FPGD_MerchantId" 
        FROM "Fee_OnlinePayment_Mapping" 
        INNER JOIN "CLG"."Fee_College_Master_Amount" "FCMA" ON "FCMA"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id" AND "FCMA"."FTI_Id" = "Fee_OnlinePayment_Mapping"."FTI_Id" AND "FCMA"."FMG_Id" = "Fee_OnlinePayment_Mapping"."FMG_Id" 
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_OnlinePayment_Mapping"."fti_id"
        INNER JOIN "Fee_PaymentGateway_Details" ON "Fee_PaymentGateway_Details"."FPGD_Id" = "Fee_OnlinePayment_Mapping"."fpgd_id"
        INNER JOIN "Fee_Master_Group" ON "Fee_Master_Amount"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
        INNER JOIN "IVRM_Master_PG" ON "IVRM_Master_PG"."IMPG_Id" = "Fee_PaymentGateway_Details"."IMPG_Id"
        WHERE "FCMA"."MI_Id" = $1 AND "ASMAY_Id" = $2 AND ("FMH_Flag" = $3) AND "IMPG_PGFlag" = $4 
        AND "fmt_id" IN (SELECT UNNEST(STRING_TO_ARRAY($5, '',''))::VARCHAR)
        AND "FCMA"."FCMA_Id" IN (
            SELECT "FCMA_Id" FROM "Fee_College_Master_Amount_Semesterwise" 
            WHERE "MI_Id" = $1 AND "AMSE_Id" IN (
                SELECT "AMSE_Id" FROM "CLG"."Adm_Master_College_Student" 
                WHERE "MI_Id" = $1 AND "AMCST_Id" = $6
            )
        )
        GROUP BY "Fee_PaymentGateway_Details"."fpgd_id", "FPGD_SubMerchantId"'
        USING "@MI_Id", "@Asmay_Id", "@flag", "@paygateway", "@fmt_id", "@Amcst_Id";

    RETURN;

END;
$$;