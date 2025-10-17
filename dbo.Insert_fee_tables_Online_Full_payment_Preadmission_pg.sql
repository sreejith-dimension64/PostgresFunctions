CREATE OR REPLACE FUNCTION "dbo"."Insert_fee_tables_Online_Full_payment_Preadmission"(
    @mi_id VARCHAR(50),
    @termid VARCHAR(50),
    @studentid VARCHAR(50),
    @asmcl_id VARCHAR(50),
    @amount VARCHAR(50),
    @transid VARCHAR(50),
    @checkid VARCHAR(50),
    @asmcl_id1 BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@CURR_IDENTYTY" BIGINT;
    "@fypwaived" BIGINT;
    "@fypconcessionamt" BIGINT;
    "@fypfine" BIGINT;
    "@tobepaidamt" BIGINT;
    "@fma_id" BIGINT;
    "@remarks" VARCHAR(50);
    "@totconcession" VARCHAR(50);
    "@sql1head" TEXT;
    "@sqlhead" TEXT;
    "@asmay_id" VARCHAR(50);
    "@ftptobepaidamtstatus" DECIMAL;
    "@paidamtstatus" DECIMAL;
    "@concessionamtstatus" DECIMAL;
    "@waivedamtstatus" DECIMAL;
    "@fineamtstatus" DECIMAL;
    "@netamountstatus" DECIMAL;
    "feeinsert_rec" RECORD;
BEGIN

    "@CURR_IDENTYTY" := 0;
    "@fypwaived" := 0;
    "@fypconcessionamt" := 0;
    "@fypfine" := 0;
    "@remarks" := 'Preadmission Online Payment';

    SELECT "ASMAY_Id" INTO "@asmay_id"
    FROM "Adm_School_M_Academic_Year"
    WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
        AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
        AND "MI_Id" = @mi_id;

    UPDATE "Fee_Y_Payment" 
    SET "FYP_OnlineChallanStatusFlag" = 'Successfull',
        "FYP_PaymentReference_Id" = @checkid
    WHERE "fyp_transaction_id" = @transid 
        AND "MI_Id" = @mi_id 
        AND "ASMAY_ID" = "@asmay_id";

    SELECT MAX("FYP_Id") INTO "@CURR_IDENTYTY"
    FROM "Fee_Y_Payment"
    WHERE "MI_Id" = @mi_id;

    INSERT INTO "Fee_Y_Payment_PA_Registration"("FYP_Id", "PASR_Id", "FYPPR_TotalPaidAmount", "FYPPR_ActiveFlag")
    VALUES ("@CURR_IDENTYTY", @studentid, @amount, 1);

    FOR "feeinsert_rec" IN
        SELECT "FMA_Id", "FMA_Amount", 0 AS "zero1", 0 AS "zero2", 0 AS "zero3"
        FROM "Fee_Master_Amount"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_Master_Amount"."FTI_Id" = "Fee_T_Installment"."FTI_Id"
        INNER JOIN "Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Master_Amount"."FMG_Id"
        INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_Id" = "Fee_Master_Amount"."FMG_Id"
            AND "Fee_Group_Login_Previledge"."FMH_Id" = "Fee_Master_Amount"."FMH_Id"
        INNER JOIN "Fee_Master_Class_Category" ON "Fee_Master_Class_Category"."FMCC_Id" = "Fee_Master_Amount"."FMCC_Id"
        INNER JOIN "Fee_Yearly_Class_Category" ON "Fee_Yearly_Class_Category"."FMCC_Id" = "Fee_Master_Class_Category"."FMCC_Id"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" ON "Fee_Yearly_Class_Category_Classes"."FYCC_Id" = "Fee_Yearly_Class_Category"."FYCC_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
            AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_T_Installment"."FTI_Id"
        WHERE "Fee_Master_Amount"."MI_Id" = @mi_id 
            AND ("FMG_CompulsoryFlag" = 1 OR "FMH_Flag" = 'N')
            AND "ASMCL_Id" = @asmcl_id 
            AND "Fee_Master_Amount"."ASMAY_Id" = "@asmay_id" 
            AND "FMT_Id" = @termid
    LOOP
        "@fma_id" := "feeinsert_rec"."FMA_Id";
        "@tobepaidamt" := "feeinsert_rec"."FMA_Amount";
        "@fypfine" := "feeinsert_rec"."zero1";
        "@fypconcessionamt" := "feeinsert_rec"."zero2";
        "@fypwaived" := "feeinsert_rec"."zero3";

        INSERT INTO "Fee_T_Payment" ("FYP_Id", "FMA_Id", "FTP_Paid_Amt", "FTP_Fine_Amt", "FTP_Concession_Amt", "FTP_Waived_Amt", "ftp_remarks")
        VALUES ("@CURR_IDENTYTY", "@fma_id", "@tobepaidamt", "@fypfine", "@fypconcessionamt", "@fypwaived", "@remarks");

    END LOOP;

    RETURN;

END;
$$;