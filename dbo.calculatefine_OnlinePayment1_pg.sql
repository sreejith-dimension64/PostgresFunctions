CREATE OR REPLACE FUNCTION "dbo"."calculatefine_OnlinePayment1"(
    "@MI_Id" VARCHAR(50),
    "@Asmay_Id" VARCHAR(50),
    "@Amst_Id" VARCHAR(50),
    "@fmt_id" VARCHAR(50),
    "@fmgid" VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@fyg_id" BIGINT;
    "@fma_id" BIGINT;
    "@fmg_id" BIGINT;
    "@fti_id" BIGINT;
    "@Fmh_id" BIGINT;
    "@amay_id" BIGINT;
    "@fmh_name" VARCHAR(100);
    "@fti_name" VARCHAR(100);
    "@ftp_tobepaid_amt" NUMERIC;
    "@paidamount" NUMERIC;
    "@ftp_concession_amt" NUMERIC;
    "@Net_amount" NUMERIC;
    "@ftp_fine_amt" NUMERIC;
    "@refundamt" NUMERIC;
    "@fmi_name" VARCHAR(100);
    "@On_Date" TIMESTAMP;
    "@FineAmount" NUMERIC;
    "@ecsflag" NUMERIC;
    "@FlagArrear" INT;
    "@fypwaived" BIGINT;
    "@headflag" VARCHAR(20);
    "@FSSCurrentYrCharges" BIGINT;
    "@FSSTotalToBePaid" BIGINT;
    "@sql1head" TEXT;
    "@sqlhead" TEXT;
    "@termwisetot" TEXT;
    "yearly_fee_rec" RECORD;
BEGIN
    "@On_Date" := CURRENT_TIMESTAMP;
    "@fmi_name" := '';
    "@FineAmount" := 0;
    
    DELETE FROM "v_studentpending";
    
    IF "@Asmay_Id"::BIGINT > 0 THEN
        FOR "yearly_fee_rec" IN 
            EXECUTE 
            'SELECT "FMA_Id", "FSS_ToBePaid", "FSS_FineAmount", "FSS_ConcessionAmount", "FSS_WaivedAmount", ' ||
            '"Fee_Student_Status"."FMG_Id", "Fee_Student_Status"."FTI_Id", "FSS_PaidAmount", "FSS_NetAmount", ' ||
            '"FSS_RefundAmount", "FMH_FeeName", "FTI_Name", "Fee_Student_Status"."FMH_Id", ' ||
            '"FSS_CurrentYrCharges", "FSS_TotalToBePaid" ' ||
            'FROM "Fee_OnlinePayment_Mapping" ' ||
            'INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id" ' ||
            'AND "Fee_Student_Status"."FTI_Id" = "Fee_OnlinePayment_Mapping"."FTI_Id" ' ||
            'AND "Fee_Student_Status"."FMG_Id" = "Fee_OnlinePayment_Mapping"."FMG_Id" ' ||
            'INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id" ' ||
            'INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_OnlinePayment_Mapping"."fti_id" ' ||
            'WHERE "Fee_Student_Status"."MI_Id" = ' || "@MI_Id" || ' ' ||
            'AND "ASMAY_Id" = ' || "@Asmay_Id" || ' ' ||
            'AND "AMST_Id" = ' || "@Amst_Id" || ' ' ||
            'AND "fmt_id" IN (' || "@fmt_id" || ') ' ||
            'AND "FSS_ToBePaid" > 0 ' ||
            'AND "Fee_OnlinePayment_Mapping"."fmg_id" IN (' || "@fmgid" || ') ' ||
            'ORDER BY "Fee_Master_Head"."FMH_Id"'
        LOOP
            "@fma_id" := "yearly_fee_rec"."FMA_Id";
            "@ftp_tobepaid_amt" := "yearly_fee_rec"."FSS_ToBePaid";
            "@ftp_fine_amt" := "yearly_fee_rec"."FSS_FineAmount";
            "@ftp_concession_amt" := "yearly_fee_rec"."FSS_ConcessionAmount";
            "@fypwaived" := "yearly_fee_rec"."FSS_WaivedAmount";
            "@fmg_id" := "yearly_fee_rec"."FMG_Id";
            "@fti_id" := "yearly_fee_rec"."FTI_Id";
            "@paidamount" := "yearly_fee_rec"."FSS_PaidAmount";
            "@Net_amount" := "yearly_fee_rec"."FSS_NetAmount";
            "@refundamt" := "yearly_fee_rec"."FSS_RefundAmount";
            "@fmh_name" := "yearly_fee_rec"."FMH_FeeName";
            "@fti_name" := "yearly_fee_rec"."FTI_Name";
            "@Fmh_id" := "yearly_fee_rec"."FMH_Id";
            "@FSSCurrentYrCharges" := "yearly_fee_rec"."FSS_CurrentYrCharges";
            "@FSSTotalToBePaid" := "yearly_fee_rec"."FSS_TotalToBePaid";
            
            SELECT * INTO "@FineAmount", "@FlagArrear" 
            FROM "dbo"."Sp_Calculate_Fine"("@On_Date", "@fma_id", "@amay_id");
            
            INSERT INTO "v_studentpending"(
                "fmg_id", "fma_id", "fti_id", "Fmh_id", "asmay_id", 
                "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ConcessionAmount", 
                "FSS_NetAmount", "FSS_FineAmount", "FSS_RefundAmount", 
                "fmh_feeName", "fti_name", "mi_id", "CreatedDate", 
                "UpdatedDate", "FSS_CurrentYrCharges", "FSS_TotalToBePaid"
            ) 
            VALUES(
                "@fmg_id", "@fma_id", "@fti_id", "@Fmh_id", "@amay_id", 
                "@ftp_tobepaid_amt", "@paidamount", "@ftp_concession_amt", 
                "@Net_amount", "@FineAmount", "@refundamt", 
                "@fmh_name", "@fti_name", "@MI_Id", CURRENT_TIMESTAMP, 
                CURRENT_TIMESTAMP, "@FSSCurrentYrCharges", "@FSSTotalToBePaid"
            );
        END LOOP;
        
        "@termwisetot" := 
            'SELECT SUM("FSS_ToBePaid") AS balance, "Fee_PaymentGateway_Details"."FPGD_Id", ' ||
            '"Fee_PaymentGateway_Details"."FPGD_SubMerchantId" AS "FPGD_MerchantId" ' ||
            'FROM "Fee_OnlinePayment_Mapping" ' ||
            'INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id" ' ||
            'AND "Fee_Student_Status"."FTI_Id" = "Fee_OnlinePayment_Mapping"."FTI_Id" ' ||
            'AND "Fee_Student_Status"."FMG_Id" = "Fee_OnlinePayment_Mapping"."FMG_Id" ' ||
            'INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id" ' ||
            'INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_OnlinePayment_Mapping"."fti_id" ' ||
            'INNER JOIN "Fee_PaymentGateway_Details" ON "Fee_PaymentGateway_Details"."FPGD_Id" = "Fee_OnlinePayment_Mapping"."fpgd_id" ' ||
            'WHERE "Fee_Student_Status"."MI_Id" = ' || "@MI_Id" || ' ' ||
            'AND "ASMAY_Id" = ' || "@Asmay_Id" || ' ' ||
            'AND "AMST_Id" = ' || "@Amst_Id" || ' ' ||
            'AND "fmt_id" IN (' || "@fmt_id" || ') ' ||
            'AND "Fee_OnlinePayment_Mapping"."fmg_id" IN (' || "@fmgid" || ') ' ||
            'GROUP BY "Fee_PaymentGateway_Details"."fpgd_id", "FPGD_SubMerchantId"';
        
        EXECUTE "@termwisetot";
    END IF;
    
    RETURN;
END;
$$;