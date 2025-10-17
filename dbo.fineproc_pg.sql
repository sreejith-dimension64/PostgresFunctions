CREATE OR REPLACE FUNCTION fineproc()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_amst_id bigint;
    v_fyp_id bigint;
    v_fma_id bigint;
    v_tpayment bigint;
    v_ypayment bigint;
    v_fineamount bigint;
    cursor_record RECORD;
BEGIN
    FOR cursor_record IN
        SELECT "Fee_Y_Payment"."FYP_Id", "AMST_Id", "FYP_Tot_Amount"
        FROM "Fee_Y_Payment"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
        WHERE "Fee_Y_Payment_School_Student"."FYP_Id" IN (36127,36138,36139,36168,36471,37016,37017,37115,37187,37207,37282,37283,37366,37368,37369,37371,37376,37399,37400,37640,37641,37879,38098,38099,38102,38239,38242,38243,38326,38327,38418,38437,38523,38526,38527,38570,38638,38735,38736,38737,38740,38741,38742,38751,38838,38843,38846,38848,38849,38850,38851,38852,38853,38862,38863,38864,38923,38973,39063,39064,39123,39125)
    LOOP
        v_fyp_id := cursor_record."FYP_Id";
        v_amst_id := cursor_record."AMST_Id";
        v_ypayment := cursor_record."FYP_Tot_Amount";
        
        SELECT "FMA_Id" INTO v_fma_id
        FROM "Fee_Student_Status"
        WHERE "AMST_Id" = v_amst_id AND "ASMAY_Id" = 62 AND "FMH_Id" = 72
        LIMIT 1;
        
        SELECT COALESCE(SUM("FTP_Paid_Amt"), 0) INTO v_tpayment
        FROM "Fee_T_Payment"
        WHERE "FYP_Id" = v_fyp_id;
        
        v_fineamount := v_ypayment - v_tpayment;
        
        INSERT INTO "Fee_T_Payment" ("FYP_Id", "FMA_Id", "FTP_Paid_Amt", "FTP_Fine_Amt", "FTP_Concession_Amt", "FTP_Waived_Amt", "ftp_remarks", "FTP_RebateAmount")
        VALUES (v_fyp_id, v_fma_id, v_fineamount, 0, 0, 0, 'Fee Online Payment', 0);
        
        UPDATE "Fee_Student_Status"
        SET "FSS_PaidAmount" = "FSS_PaidAmount" + v_fineamount,
            "FSS_FineAmount" = "FSS_FineAmount" + v_fineamount
        WHERE "AMST_Id" = v_amst_id AND "ASMAY_Id" = 62 AND "FMH_Id" = 72;
    END LOOP;
    
    RETURN;
END;
$$;