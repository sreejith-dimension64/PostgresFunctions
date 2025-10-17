```sql
CREATE OR REPLACE FUNCTION "dbo"."FeeReceipt_ASOnDateBalanceTEMP"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint,
    p_FYP_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "FYP_Id" bigint,
    "amsT_FirstName" text,
    "amsT_MiddleName" text,
    "amsT_LastName" text,
    "FMH_Id" bigint,
    "fmH_FeeName" text,
    "ftI_Name" text,
    "FTI_Id" bigint,
    "fyP_Receipt_No" text,
    "ftP_Concession_Amt" text,
    "FTP_Fine_Amt" bigint,
    "fyP_Date" timestamp,
    "classname" text,
    "sectionname" text,
    "rollno" text,
    "admno" text,
    "fathername" text,
    "mothername" text,
    "fyP_Bank_Or_Cash" text,
    "fyP_DD_Cheque_No" text,
    "fyP_DD_Cheque_Date" timestamp,
    "fyP_Bank_Name" text,
    "fyP_Remarks" text,
    "AMST_RegistrationNo" text,
    "fmcC_ConcessionName" text,
    "FSS_AdjustedAmount" bigint,
    "amst_mobile" bigint,
    "FYP_ChallanNo" text,
    "FMH_Order" bigint,
    "fmA_Amount" bigint,
    "fsS_OBArrearAmount" bigint,
    "FSS_RefundAmount" bigint,
    "FSS_CurrentYrCharges" bigint,
    "ftP_Paid_Amt" bigint,
    "fyp_transaction_Id" text,
    "fsS_ToBePaid" bigint,
    "fyP_PaymentReference_Id" text,
    "totalcharges" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    v_AMST_Id_N bigint;
    v_FYP_Id_N bigint;
    v_AMST_FirstName text;
    v_AMST_MiddleName text;
    v_AMST_LastName text;
    v_FMH_Id_N bigint;
    v_FMH_FeeName text;
    v_FTI_Name text;
    v_FTI_Id_N bigint;
    v_FYP_Receipt_No text;
    v_FTP_Concession_Amt bigint;
    v_FTP_Fine_Amt bigint;
    v_FYP_Date timestamp;
    v_ASMCL_ClassName text;
    v_ASMC_SectionName text;
    v_AMAY_RollNo text;
    v_AMST_AdmNo text;
    v_AMST_FatherName text;
    v_AMST_MotherName text;
    v_FYP_Bank_Or_Cash text;
    v_FYP_DD_Cheque_No text;
    v_FYP_DD_Cheque_Date timestamp;
    v_FYP_Bank_Name text;
    v_FYP_Remarks text;
    v_AMST_RegistrationNo text;
    v_FMCC_ConcessionName text;
    v_FSS_AdjustedAmount bigint;
    v_AMST_MobileNo bigint;
    v_FYP_ChallanNo text;
    v_FMH_Order bigint;
    v_FMA_Amount bigint;
    v_FSS_OBArrearAmount bigint;
    v_FSS_RefundAmount bigint;
    v_FSS_CurrentYrCharges bigint;
    v_fyp_transaction_Id text;
    v_FSS_TobePaid bigint;
    v_FTP_Paid_Amt bigint;
    v_FYP_PaymentReference_Id text;
    v_totalcharges bigint;
    
    rec_instid RECORD;
    rec_details RECORD;
BEGIN
    DROP TABLE IF EXISTS "StudentWiseFeeReceiptDetails_Temp";
    
    CREATE TEMP TABLE "StudentWiseFeeReceiptDetails_Temp" (
        "AMST_Id" bigint,
        "FYP_Id" bigint,
        "amsT_FirstName" text,
        "amsT_MiddleName" text,
        "amsT_LastName" text,
        "FMH_Id" bigint,
        "fmH_FeeName" text,
        "ftI_Name" text,
        "FTI_Id" bigint,
        "fyP_Receipt_No" text,
        "ftP_Concession_Amt" text,
        "FTP_Fine_Amt" bigint,
        "fyP_Date" timestamp,
        "classname" text,
        "sectionname" text,
        "rollno" text,
        "admno" text,
        "fathername" text,
        "mothername" text,
        "fyP_Bank_Or_Cash" text,
        "fyP_DD_Cheque_No" text,
        "fyP_DD_Cheque_Date" timestamp,
        "fyP_Bank_Name" text,
        "fyP_Remarks" text,
        "AMST_RegistrationNo" text,
        "fmcC_ConcessionName" text,
        "FSS_AdjustedAmount" bigint,
        "amst_mobile" bigint,
        "FYP_ChallanNo" text,
        "FMH_Order" bigint,
        "fmA_Amount" bigint,
        "fsS_OBArrearAmount" bigint,
        "FSS_RefundAmount" bigint,
        "FSS_CurrentYrCharges" bigint,
        "ftP_Paid_Amt" bigint,
        "fyp_transaction_Id" text,
        "fsS_ToBePaid" bigint,
        "fyP_PaymentReference_Id" text,
        "totalcharges" bigint
    );
    
    FOR rec_instid IN
        SELECT DISTINCT "FSS"."FTI_Id", "FSS"."FMH_Id"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FSYS" ON "FSYS"."FYP_Id" = "FYP"."FYP_Id" AND "FSYS"."ASMAY_Id" = "FYP"."ASMAY_ID"
        INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FSYS"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMA_Id" = "FTP"."FMA_Id" AND "FMA"."ASMAY_Id" = "FSYS"."ASMAY_Id"
        INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."ASMAY_Id" = "FMA"."ASMAY_Id" AND "FSS"."AMST_Id" = "FSYS"."AMST_Id" AND "FSS"."FMG_Id" = "FMA"."FMG_Id" AND "FSS"."FMH_Id" = "FMA"."FMH_Id" AND "FSS"."FTI_Id" = "FMA"."FTI_Id" AND "FSS"."FMA_Id" = "FMA"."FMA_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "FSYS"."AMST_Id" AND "ASYS"."ASMAY_Id" = "FSS"."ASMAY_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."AMST_SOL" = 'S' AND "AMS"."AMST_ActiveFlag" = 1 AND "ASYS"."amay_activeflag" = 1
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id" AND "FMH"."MI_Id" = p_MI_Id
        LEFT JOIN "Fee_Master_Concession" "FMCC" ON "FMCC"."FMCC_Id" = "AMS"."AMST_Concession_Type" AND "FMCC"."MI_Id" = p_MI_Id
        INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = p_MI_Id
        INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id" AND "ASMS"."MI_Id" = p_MI_Id
        INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FSS"."FTI_Id" AND "FTI"."MI_ID" = p_MI_Id
        WHERE "FYP"."MI_Id" = p_MI_Id AND "FYP"."ASMAY_Id" = p_ASMAY_Id AND "FSYS"."AMST_Id" = p_AMST_Id
    LOOP
        v_FTI_Id := rec_instid."FTI_Id";
        v_FMH_Id := rec_instid."FMH_Id";
        
        FOR rec_details IN
            SELECT "FSYS"."AMST_Id", "FYP"."FYP_Id", "AMS"."AMST_FirstName", "AMS"."AMST_MiddleName", "AMS"."AMST_LastName", 
                   "FSS"."FMH_Id", "FMH"."FMH_FeeName", "FTI"."FTI_Name", "FSS"."FTI_Id", "FYP"."FYP_Receipt_No",
                   "FSS"."FSS_ConcessionAmount", "FTP"."FTP_Fine_Amt", "FYP"."FYP_Date", "ASMC"."ASMCL_ClassName", 
                   "ASMS"."ASMC_SectionName", "ASYS"."AMAY_RollNo", "AMS"."AMST_AdmNo", "AMS"."AMST_FatherName", 
                   "AMS"."AMST_MotherName", "FYP"."FYP_Bank_Or_Cash", "FYP"."FYP_DD_Cheque_No", "FYP"."FYP_DD_Cheque_Date", 
                   "FYP"."FYP_Bank_Name", "FYP"."FYP_Remarks", "AMS"."AMST_RegistrationNo", 
                   COALESCE("FMCC"."FMCC_ConcessionName", '') AS "FMCC_ConcessionName", "FSS"."FSS_AdjustedAmount", 
                   "AMS"."AMST_MobileNo", COALESCE("FYP"."FYP_ChallanNo", '') AS "FYP_ChallanNo", "FMH"."FMH_Order", 
                   "FMA"."FMA_Amount", "FSS"."FSS_OBArrearAmount", "FSS"."FSS_RefundAmount", "FSS"."FSS_CurrentYrCharges", 
                   "FTP"."FTP_Paid_Amt", COALESCE("FYP"."fyp_transaction_Id", '') AS "fyp_transaction_Id",
                   ("FSS"."FSS_CurrentYrCharges" - "FSS"."FSS_ConcessionAmount") - 
                   SUM("FTP"."FTP_Paid_Amt") OVER(ORDER BY "FSS"."FTI_Id", "FSS"."FMH_Id", "FSS"."FSS_CurrentYrCharges" ROWS UNBOUNDED PRECEDING) AS "FSS_TobePaid",
                   "FYP"."FYP_PaymentReference_Id", "FMA"."FMA_Amount" AS "totalcharges"
            FROM "Fee_Y_Payment" "FYP"
            INNER JOIN "Fee_Y_Payment_School_Student" "FSYS" ON "FSYS"."FYP_Id" = "FYP"."FYP_Id" AND "FSYS"."ASMAY_Id" = "FYP"."ASMAY_ID"
            INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FSYS"."FYP_Id"
            INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMA_Id" = "FTP"."FMA_Id" AND "FMA"."ASMAY_Id" = "FSYS"."ASMAY_Id"
            INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."ASMAY_Id" = "FMA"."ASMAY_Id" AND "FSS"."AMST_Id" = "FSYS"."AMST_Id" AND "FSS"."FMG_Id" = "FMA"."FMG_Id" AND "FSS"."FMH_Id" = "FMA"."FMH_Id" AND "FSS"."FTI_Id" = "FMA"."FTI_Id" AND "FSS"."FMA_Id" = "FMA"."FMA_Id"
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "FSYS"."AMST_Id" AND "ASYS"."ASMAY_Id" = "FSS"."ASMAY_Id"
            INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."AMST_SOL" = 'S' AND "AMS"."AMST_ActiveFlag" = 1 AND "ASYS"."amay_activeflag" = 1
            INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id" AND "FMH"."MI_Id" = p_MI_Id
            LEFT JOIN "Fee_Master_Concession" "FMCC" ON "FMCC"."FMCC_Id" = "AMS"."AMST_Concession_Type" AND "FMCC"."MI_Id" = p_MI_Id
            INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = p_MI_Id
            INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id" AND "ASMS"."MI_Id" = p_MI_Id
            INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FSS"."FTI_Id" AND "FTI"."MI_ID" = p_MI_Id
            WHERE "FYP"."MI_Id" = p_MI_Id AND "FYP"."ASMAY_Id" = p_ASMAY_Id AND "FSYS"."AMST_Id" = p_AMST_Id 
                  AND "FSS"."FTI_Id" = v_FTI_Id AND "FSS"."FMH_Id" = v_FMH_Id AND "FTP"."FTP_Paid_Amt" > 0
        LOOP
            INSERT INTO "StudentWiseFeeReceiptDetails_Temp" VALUES(
                rec_details."AMST_Id", rec_details."FYP_Id", rec_details."AMST_FirstName", rec_details."AMST_MiddleName",
                rec_details."AMST_LastName", rec_details."FMH_Id", rec_details."FMH_FeeName", rec_details."FTI_Name",
                rec_details."FTI_Id", rec_details."FYP_Receipt_No", rec_details."FSS_ConcessionAmount"::text,
                rec_details."FTP_Fine_Amt", rec_details."FYP_Date", rec_details."ASMCL_ClassName",
                rec_details."ASMC_SectionName", rec_details."AMAY_RollNo", rec_details."AMST_AdmNo",
                rec_details."AMST_FatherName", rec_details."AMST_MotherName", rec_details."FYP_Bank_Or_Cash",
                rec_details."FYP_DD_Cheque_No", rec_details."FYP_DD_Cheque_Date", rec_details."FYP_Bank_Name",
                rec_details."FYP_Remarks", rec_details."AMST_RegistrationNo", rec_details."FMCC_ConcessionName",
                rec_details."FSS_AdjustedAmount", rec_details."AMST_MobileNo", rec_details."FYP_ChallanNo",
                rec_details."FMH_Order", rec_details."FMA_Amount", rec_details."FSS_OBArrearAmount",
                rec_details."FSS_RefundAmount", rec_details."FSS_CurrentYrCharges", rec_details."FTP_Paid_Amt",
                rec_details."fyp_transaction_Id", rec_details."FSS_TobePaid", rec_details."FYP_PaymentReference_Id",
                rec_details."totalcharges"
            );
        END LOOP;
    END LOOP;
    
    RETURN QUERY
    SELECT * FROM "StudentWiseFeeReceiptDetails_Temp" 
    WHERE "FYP_Id" = p_FYP_Id AND "AMST_Id" = p_AMST_Id 
    ORDER BY "FMH_Order";
    
END;
$$;
```