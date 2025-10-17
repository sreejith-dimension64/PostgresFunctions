CREATE OR REPLACE FUNCTION "dbo"."Insert_fee_tables_Online_Full_payment"(
    "mi_id" VARCHAR(50),
    "termid" VARCHAR(50),
    "studentid" VARCHAR(50),
    "groupid" VARCHAR(50),
    "amount" VARCHAR(50),
    "transid" VARCHAR(50),
    "checkid" VARCHAR(50)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "CURR_IDENTYTY" BIGINT;
    "fypwaived" BIGINT;
    "fypconcessionamt" BIGINT;
    "fypfine" BIGINT;
    "tobepaidamt" BIGINT;
    "fma_id" BIGINT;
    "remarks" VARCHAR(50);
    "totconcession" VARCHAR(50);
    "asmay_id" VARCHAR(50);
    "ftptobepaidamtstatus" DECIMAL;
    "paidamtstatus" DECIMAL;
    "concessionamtstatus" DECIMAL;
    "waivedamtstatus" DECIMAL;
    "fineamtstatus" DECIMAL;
    "netamountstatus" DECIMAL;
    "yearly_fee_rec" RECORD;
    "feeinsert_rec" RECORD;
    "sql_query" TEXT;
BEGIN
    "CURR_IDENTYTY" := 0;
    "fypwaived" := 0;
    "fypconcessionamt" := 0;
    "fypfine" := 0;
    "remarks" := 'Online Payment';
    
    SELECT "ASMAY_Id" INTO "asmay_id"
    FROM "Adm_School_M_Academic_Year"
    WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
        AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
        AND "MI_Id" = "mi_id";
    
    "sql_query" := 'SELECT SUM("FSS_ConcessionAmount") as fma_id 
                    FROM "Fee_Student_Status" 
                    INNER JOIN "Fee_Master_Terms_FeeHeads" 
                        ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
                        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id" 
                    WHERE "Fee_Student_Status"."MI_Id" = ' || "mi_id" || ' 
                        AND "ASMAY_Id" = ' || "asmay_id" || ' 
                        AND "AMST_Id" = ' || "studentid" || ' 
                        AND "FMT_Id" IN (' || "termid" || ') 
                        AND "fmg_id" IN (' || "groupid" || ')';
    
    FOR "yearly_fee_rec" IN EXECUTE "sql_query"
    LOOP
        "totconcession" := "yearly_fee_rec"."fma_id";
    END LOOP;
    
    UPDATE "Fee_Y_Payment" 
    SET "FYP_OnlineChallanStatusFlag" = 'Successfull',
        "FYP_PaymentReference_Id" = "checkid"
    WHERE "fyp_transaction_id" = "transid" 
        AND "MI_Id" = "mi_id" 
        AND "ASMAY_ID" = "asmay_id";
    
    SELECT MAX("FYP_Id") INTO "CURR_IDENTYTY"
    FROM "Fee_Y_Payment"
    WHERE "MI_Id" = "mi_id";
    
    INSERT INTO "Fee_Y_Payment_School_Student"(
        "FYP_Id",
        "AMST_Id",
        "ASMAY_Id",
        "FTP_TotalPaidAmount",
        "FTP_TotalWaivedAmount",
        "FTP_TotalConcessionAmount",
        "FTP_TotalFineAmount"
    ) 
    VALUES (
        "CURR_IDENTYTY",
        "studentid",
        "asmay_id",
        "amount",
        "fypwaived",
        "fypconcessionamt",
        "fypfine"
    );
    
    "sql_query" := 'SELECT "FMA_Id", "FSS_ToBePaid", "FSS_FineAmount", "FSS_ConcessionAmount", "FSS_WaivedAmount" 
                    FROM "Fee_Student_Status" 
                    INNER JOIN "Fee_Master_Terms_FeeHeads" 
                        ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" 
                        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id" 
                    WHERE "Fee_Student_Status"."MI_Id" = ' || "mi_id" || ' 
                        AND "ASMAY_Id" = ' || "asmay_id" || ' 
                        AND "AMST_Id" = ' || "studentid" || ' 
                        AND "FMT_Id" IN (' || "termid" || ') 
                        AND "fmg_id" IN (' || "groupid" || ')';
    
    FOR "feeinsert_rec" IN EXECUTE "sql_query"
    LOOP
        "fma_id" := "feeinsert_rec"."FMA_Id";
        "tobepaidamt" := "feeinsert_rec"."FSS_ToBePaid";
        "fypfine" := "feeinsert_rec"."FSS_FineAmount";
        "fypconcessionamt" := "feeinsert_rec"."FSS_ConcessionAmount";
        "fypwaived" := "feeinsert_rec"."FSS_WaivedAmount";
        
        INSERT INTO "Fee_T_Payment" (
            "FYP_Id",
            "FMA_Id",
            "FTP_Paid_Amt",
            "FTP_Fine_Amt",
            "FTP_Concession_Amt",
            "FTP_Waived_Amt",
            "ftp_remarks"
        ) 
        VALUES (
            "CURR_IDENTYTY",
            "fma_id",
            "tobepaidamt",
            "fypfine",
            "fypconcessionamt",
            "fypwaived",
            "remarks"
        );
        
        SELECT "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ConcessionAmount", "FSS_WaivedAmount", "FSS_FineAmount", "FSS_NetAmount"
        INTO "ftptobepaidamtstatus", "paidamtstatus", "concessionamtstatus", "waivedamtstatus", "fineamtstatus", "netamountstatus"
        FROM "Fee_Student_Status"
        WHERE "Amst_Id" = "studentid" 
            AND "asmay_id" = "asmay_id" 
            AND "fma_id" = "FMA_Id" 
            AND "MI_Id" = "MI_ID";
        
        UPDATE "Fee_Student_Status" 
        SET "FSS_ToBePaid" = "ftptobepaidamtstatus" - "tobepaidamt",
            "FSS_PaidAmount" = "paidamtstatus" + "tobepaidamt",
            "FSS_WaivedAmount" = "waivedamtstatus" + "fypwaived",
            "FSS_FineAmount" = "fineamtstatus" + "fypfine"
        WHERE "Amst_Id" = "studentid" 
            AND "asmay_id" = "asmay_id" 
            AND "fma_id" = "FMA_Id" 
            AND "MI_Id" = "MI_ID";
    END LOOP;
    
    RETURN;
END;
$$;