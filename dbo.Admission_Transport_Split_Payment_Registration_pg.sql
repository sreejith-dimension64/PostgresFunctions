CREATE OR REPLACE FUNCTION "dbo"."Admission_Transport_Split_Payment_Registration" (
    "MI_Id" VARCHAR(50),
    "Asmay_Id" VARCHAR(50),
    "Amst_Id" VARCHAR(50),
    "paygateway" TEXT
)
RETURNS TABLE (
    "balance" NUMERIC,
    "FPGD_Id" INTEGER,
    "FPGD_MerchantId" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "termwisetot" TEXT;
    "flag" VARCHAR(10);
    "fmt_id" VARCHAR(50);
BEGIN

    SELECT DISTINCT "Fee_OnlinePayment_Mapping"."fmt_id" INTO "fmt_id"
    FROM "Fee_OnlinePayment_Mapping" 
    INNER JOIN "Fee_Master_Head" ON "Fee_OnlinePayment_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    INNER JOIN "Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_OnlinePayment_Mapping"."fmg_id"
    WHERE "Fee_OnlinePayment_Mapping"."MI_Id" = "MI_Id" 
    AND "Fee_Master_Head"."FMH_Flag" = 'NT';

    "flag" := 'NT';

    "termwisetot" := 'SELECT SUM("FMA_Amount") as balance, "Fee_PaymentGateway_Details"."FPGD_Id", "Fee_PaymentGateway_Details"."FPGD_SubMerchantId" as "FPGD_MerchantId" 
    FROM "Fee_OnlinePayment_Mapping" 
    INNER JOIN "Fee_Master_Amount" ON "Fee_Master_Amount"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id"
        AND "Fee_Master_Amount"."FTI_Id" = "Fee_OnlinePayment_Mapping"."FTI_Id" 
        AND "Fee_Master_Amount"."FMG_Id" = "Fee_OnlinePayment_Mapping"."FMG_Id" 
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id"
    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_OnlinePayment_Mapping"."fti_id"
    INNER JOIN "Fee_PaymentGateway_Details" ON "Fee_PaymentGateway_Details"."FPGD_Id" = "Fee_OnlinePayment_Mapping"."fpgd_id"
    INNER JOIN "Fee_Master_Group" ON "Fee_Master_Amount"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
    INNER JOIN "IVRM_Master_PG" ON "IVRM_Master_PG"."IMPG_Id" = "Fee_PaymentGateway_Details"."IMPG_Id"
    WHERE "Fee_Master_Amount"."MI_Id" = ' || "MI_Id" || ' 
        AND "Fee_Master_Amount"."ASMAY_Id" = ' || "Asmay_Id" || ' 
        AND "Fee_Master_Head"."FMH_Flag" = ''' || "flag" || ''' 
        AND "IVRM_Master_PG"."IMPG_PGFlag" = ''' || "paygateway" || ''' 
        AND "Fee_OnlinePayment_Mapping"."fmt_id" IN (' || "fmt_id" || ')
        AND "Fee_Master_Amount"."FMCC_Id" IN (
            SELECT "FMCC_Id" 
            FROM "Fee_Yearly_Class_Category" 
            WHERE "fycc_id" IN (
                SELECT "FYCC_Id" 
                FROM "Fee_Yearly_Class_Category_Classes" 
                WHERE "ASMCL_Id" IN (
                    SELECT "ASMCL_Id" 
                    FROM "Adm_M_Student" 
                    WHERE "AMST_Id" = ' || "Amst_Id" || '
                )
            )
        )
    GROUP BY "Fee_PaymentGateway_Details"."fpgd_id", "Fee_PaymentGateway_Details"."FPGD_SubMerchantId"';

    RETURN QUERY EXECUTE "termwisetot";

END;
$$;