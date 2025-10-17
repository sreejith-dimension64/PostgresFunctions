CREATE OR REPLACE FUNCTION "FeeReceipt_ASOnDateBalance"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint,
    p_FYP_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "FYP_Id" bigint,
    "amsT_FirstName" TEXT,
    "amsT_MiddleName" TEXT,
    "amsT_LastName" TEXT,
    "fmH_Id" bigint,
    "fmH_FeeName" TEXT,
    "ftI_Name" TEXT,
    "ftI_Id" bigint,
    "fyP_Receipt_No" TEXT,
    "ftP_Concession_Amt" TEXT,
    "FTP_Fine_Amt" bigint,
    "fyP_Date" TIMESTAMP,
    "classname" TEXT,
    "sectionname" TEXT,
    "rollno" TEXT,
    "admno" TEXT,
    "fathername" TEXT,
    "mothername" TEXT,
    "fyP_Bank_Or_Cash" TEXT,
    "fyP_DD_Cheque_No" TEXT,
    "fyP_DD_Cheque_Date" TIMESTAMP,
    "fyP_Bank_Name" TEXT,
    "fyP_Remarks" TEXT,
    "AMST_RegistrationNo" TEXT,
    "fmcC_ConcessionName" TEXT,
    "FSS_AdjustedAmount" bigint,
    "amst_mobile" bigint,
    "FYP_ChallanNo" TEXT,
    "FMH_Order" bigint,
    "fmA_Amount" bigint,
    "fsS_OBArrearAmount" bigint,
    "FSS_RefundAmount" bigint,
    "FSS_CurrentYrCharges" bigint,
    "ftP_Paid_Amt" bigint,
    "fyp_transaction_Id" TEXT,
    "fsS_ToBePaid" bigint,
    "fyP_PaymentReference_Id" TEXT,
    "totalcharges" bigint,
    "fmG_Id" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_currentyearorder bigint;
    v_previousyearorder bigint;
    v_preAsmay_id bigint;
    v_cnt bigint;
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    rec_InstidHeadId RECORD;
    rec_StudentwiseFeeRepDetails RECORD;
BEGIN

    DROP TABLE IF EXISTS "StudentWiseFeeReceiptDetails_Temp";
    
    CREATE TEMP TABLE "StudentWiseFeeReceiptDetails_Temp" (
        "AMST_Id" bigint,
        "FYP_Id" bigint,
        "amsT_FirstName" TEXT,
        "amsT_MiddleName" TEXT,
        "amsT_LastName" TEXT,
        "fmH_Id" bigint,
        "fmH_FeeName" TEXT,
        "ftI_Name" TEXT,
        "ftI_Id" bigint,
        "fyP_Receipt_No" TEXT,
        "ftP_Concession_Amt" TEXT,
        "FTP_Fine_Amt" bigint,
        "fyP_Date" TIMESTAMP,
        "classname" TEXT,
        "sectionname" TEXT,
        "rollno" TEXT,
        "admno" TEXT,
        "fathername" TEXT,
        "mothername" TEXT,
        "fyP_Bank_Or_Cash" TEXT,
        "fyP_DD_Cheque_No" TEXT,
        "fyP_DD_Cheque_Date" TIMESTAMP,
        "fyP_Bank_Name" TEXT,
        "fyP_Remarks" TEXT,
        "AMST_RegistrationNo" TEXT,
        "fmcC_ConcessionName" TEXT,
        "FSS_AdjustedAmount" bigint,
        "amst_mobile" bigint,
        "FYP_ChallanNo" TEXT,
        "FMH_Order" bigint,
        "fmA_Amount" bigint,
        "fsS_OBArrearAmount" bigint,
        "FSS_RefundAmount" bigint,
        "FSS_CurrentYrCharges" bigint,
        "ftP_Paid_Amt" bigint,
        "fyp_transaction_Id" TEXT,
        "fsS_ToBePaid" bigint,
        "fyP_PaymentReference_Id" TEXT,
        "totalcharges" bigint,
        "fmG_Id" bigint
    );

    SELECT COUNT(*) INTO v_cnt 
    FROM "adm_School_Y_student" 
    WHERE "AMST_Id" = p_AMST_Id AND "ASMAY_Id" = p_ASMAY_Id;

    IF v_cnt > 0 THEN
    
        FOR rec_InstidHeadId IN
            SELECT DISTINCT "FSS"."FTI_Id", "FSS"."FMH_Id" 
            FROM "Fee_Y_Payment" "FYP"
            INNER JOIN "Fee_Y_Payment_School_Student" "FSYS" ON "FSYS"."FYP_Id" = "FYP"."FYP_Id" AND "FSYS"."ASMAY_Id" = "FYP"."ASMAY_ID"
            INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FSYS"."FYP_Id"
            INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMA_Id" = "FTP"."FMA_Id" AND "FMA"."ASMAY_Id" = "FSYS"."ASMAY_Id"
            INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."ASMAY_Id" = "FMA"."ASMAY_Id" AND "FSS"."AMST_Id" = "FSYS"."AMST_Id" AND "FSS"."FMG_Id" = "FMA"."FMG_Id" AND "FSS"."FMH_Id" = "FMA"."FMH_Id" AND "FSS"."FTI_Id" = "FMA"."FTI_Id" AND "FSS"."FMA_Id" = "FMA"."FMA_Id"
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "FSYS"."AMST_Id" AND "ASYS"."ASMAY_Id" = "FSS"."ASMAY_Id"
            INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."AMST_SOL" IN ('S','L','D')
            INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id" AND "FMH"."MI_Id" = p_MI_Id
            LEFT JOIN "Fee_Master_Concession" "FMCC" ON "FMCC"."FMCC_Id" = "AMS"."AMST_Concession_Type" AND "FMCC"."MI_Id" = p_MI_Id
            INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = p_MI_Id
            INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id" AND "ASMS"."MI_Id" = p_MI_Id
            INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FSS"."FTI_Id" AND "FTI"."MI_ID" = p_MI_Id
            WHERE "FYP"."MI_Id" = p_MI_Id AND "FYP"."ASMAY_Id" = p_ASMAY_Id AND "FSYS"."AMST_Id" = p_AMST_Id
        LOOP
        
            v_FTI_Id := rec_InstidHeadId."FTI_Id";
            v_FMH_Id := rec_InstidHeadId."FMH_Id";
            
            FOR rec_StudentwiseFeeRepDetails IN
                SELECT "FSYS"."AMST_Id", "FYP"."FYP_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "FSS"."FMH_Id", "FMH_FeeName", "FTI_Name", "FSS"."FTI_Id", "FYP_Receipt_No",
                "FSS_ConcessionAmount", "FTP_Fine_Amt", "FYP_Date", "ASMCL_ClassName", "ASMC_SectionName", "AMAY_RollNo", "AMST_AdmNo", "AMST_FatherName", "AMST_MotherName", "FYP_Bank_Or_Cash", "FYP_DD_Cheque_No", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "FYP_Remarks", "AMST_RegistrationNo", COALESCE("FMCC_ConcessionName",'') AS "FMCC_ConcessionName", "FSS_AdjustedAmount", "AMST_MobileNo", COALESCE("FYP_ChallanNo",'') AS "FYP_ChallanNo", "FMH_Order", "FMA_Amount",
                "FSS_OBArrearAmount", "FSS_RefundAmount", "FSS_CurrentYrCharges", "FTP_Paid_Amt", COALESCE("fyp_transaction_Id",'') AS "fyp_transaction_Id", ("FSS_TotalToBePaid") - SUM("FTP_Paid_Amt") OVER(ORDER BY "FYP"."FYP_Id", "FSS"."FTI_Id", "FSS"."FMH_Id", "FSS_TotalToBePaid" ROWS UNBOUNDED PRECEDING) AS "FSS_TobePaid", "FYP_PaymentReference_Id", "FMA_Amount", "FSS"."FMG_Id"
                FROM "Fee_Y_Payment" "FYP"
                INNER JOIN "Fee_Y_Payment_School_Student" "FSYS" ON "FSYS"."FYP_Id" = "FYP"."FYP_Id" AND "FSYS"."ASMAY_Id" = "FYP"."ASMAY_ID"
                INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FSYS"."FYP_Id"
                INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMA_Id" = "FTP"."FMA_Id" AND "FMA"."ASMAY_Id" = "FSYS"."ASMAY_Id"
                INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."ASMAY_Id" = "FMA"."ASMAY_Id" AND "FSS"."AMST_Id" = "FSYS"."AMST_Id" AND "FSS"."FMG_Id" = "FMA"."FMG_Id" AND "FSS"."FMH_Id" = "FMA"."FMH_Id" AND "FSS"."FTI_Id" = "FMA"."FTI_Id" AND "FSS"."FMA_Id" = "FMA"."FMA_Id"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "FSYS"."AMST_Id" AND "ASYS"."ASMAY_Id" = "FSS"."ASMAY_Id"
                INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."AMST_SOL" IN ('S','L','D')
                INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id" AND "FMH"."MI_Id" = p_MI_Id
                LEFT JOIN "Fee_Master_Concession" "FMCC" ON "FMCC"."FMCC_Id" = "AMS"."AMST_Concession_Type" AND "FMCC"."MI_Id" = p_MI_Id
                INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = p_MI_Id
                INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id" AND "ASMS"."MI_Id" = p_MI_Id
                INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FSS"."FTI_Id" AND "FTI"."MI_ID" = p_MI_Id
                WHERE "FYP"."MI_Id" = p_MI_Id AND "FYP"."ASMAY_Id" = p_ASMAY_Id AND "FSYS"."AMST_Id" = p_AMST_Id AND "FSS"."FTI_Id" = v_FTI_Id AND "FSS"."FMH_Id" = v_FMH_Id AND "FTP_Paid_Amt" > 0
            LOOP
            
                INSERT INTO "StudentWiseFeeReceiptDetails_Temp" VALUES(
                    rec_StudentwiseFeeRepDetails."AMST_Id", rec_StudentwiseFeeRepDetails."FYP_Id", rec_StudentwiseFeeRepDetails."AMST_FirstName", rec_StudentwiseFeeRepDetails."AMST_MiddleName", rec_StudentwiseFeeRepDetails."AMST_LastName", rec_StudentwiseFeeRepDetails."FMH_Id", rec_StudentwiseFeeRepDetails."FMH_FeeName", rec_StudentwiseFeeRepDetails."FTI_Name", rec_StudentwiseFeeRepDetails."FTI_Id", rec_StudentwiseFeeRepDetails."FYP_Receipt_No",
                    rec_StudentwiseFeeRepDetails."FSS_ConcessionAmount", rec_StudentwiseFeeRepDetails."FTP_Fine_Amt", rec_StudentwiseFeeRepDetails."FYP_Date", rec_StudentwiseFeeRepDetails."ASMCL_ClassName", rec_StudentwiseFeeRepDetails."ASMC_SectionName", rec_StudentwiseFeeRepDetails."AMAY_RollNo",
                    rec_StudentwiseFeeRepDetails."AMST_AdmNo", rec_StudentwiseFeeRepDetails."AMST_FatherName", rec_StudentwiseFeeRepDetails."AMST_MotherName", rec_StudentwiseFeeRepDetails."FYP_Bank_Or_Cash", rec_StudentwiseFeeRepDetails."FYP_DD_Cheque_No", rec_StudentwiseFeeRepDetails."FYP_DD_Cheque_Date", rec_StudentwiseFeeRepDetails."FYP_Bank_Name", rec_StudentwiseFeeRepDetails."FYP_Remarks", rec_StudentwiseFeeRepDetails."AMST_RegistrationNo", rec_StudentwiseFeeRepDetails."FMCC_ConcessionName", rec_StudentwiseFeeRepDetails."FSS_AdjustedAmount", rec_StudentwiseFeeRepDetails."AMST_MobileNo", rec_StudentwiseFeeRepDetails."FYP_ChallanNo", rec_StudentwiseFeeRepDetails."FMH_Order", rec_StudentwiseFeeRepDetails."FMA_Amount", rec_StudentwiseFeeRepDetails."FSS_OBArrearAmount", rec_StudentwiseFeeRepDetails."FSS_RefundAmount", rec_StudentwiseFeeRepDetails."FSS_CurrentYrCharges", rec_StudentwiseFeeRepDetails."FTP_Paid_Amt", rec_StudentwiseFeeRepDetails."fyp_transaction_Id", rec_StudentwiseFeeRepDetails."FSS_TobePaid", rec_StudentwiseFeeRepDetails."FYP_PaymentReference_Id", rec_StudentwiseFeeRepDetails."FMA_Amount", rec_StudentwiseFeeRepDetails."FMG_Id"
                );
                
            END LOOP;
            
        END LOOP;
        
        RETURN QUERY SELECT * FROM "StudentWiseFeeReceiptDetails_Temp" WHERE "FYP_Id" = p_FYP_Id AND "AMST_Id" = p_AMST_Id ORDER BY "FMH_Order";
        
    ELSE
    
        SELECT "ASMAY_Order" INTO v_currentyearorder FROM "Adm_School_M_Academic_Year" WHERE "mi_id" = p_MI_Id AND "asmay_id" = p_ASMAY_Id;
        v_previousyearorder := v_currentyearorder - 1;
        SELECT "ASMAY_Id" INTO v_preAsmay_id FROM "Adm_School_M_Academic_Year" WHERE "mi_id" = p_MI_Id AND "ASMAY_Order" = v_previousyearorder;

        FOR rec_InstidHeadId IN
            SELECT DISTINCT "FSS"."FTI_Id", "FSS"."FMH_Id" 
            FROM "Fee_Y_Payment" "FYP"
            INNER JOIN "Fee_Y_Payment_School_Student" "FSYS" ON "FSYS"."FYP_Id" = "FYP"."FYP_Id" AND "FSYS"."ASMAY_Id" = "FYP"."ASMAY_ID"
            INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FSYS"."FYP_Id"
            INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMA_Id" = "FTP"."FMA_Id" AND "FMA"."ASMAY_Id" = "FSYS"."ASMAY_Id"
            INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."ASMAY_Id" = "FMA"."ASMAY_Id" AND "FSS"."AMST_Id" = "FSYS"."AMST_Id" AND "FSS"."FMG_Id" = "FMA"."FMG_Id" AND "FSS"."FMH_Id" = "FMA"."FMH_Id" AND "FSS"."FTI_Id" = "FMA"."FTI_Id" AND "FSS"."FMA_Id" = "FMA"."FMA_Id"
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "FSYS"."AMST_Id"
            INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."AMST_SOL" IN ('S','L','D')
            INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id" AND "FMH"."MI_Id" = p_MI_Id
            LEFT JOIN "Fee_Master_Concession" "FMCC" ON "FMCC"."FMCC_Id" = "AMS"."AMST_Concession_Type" AND "FMCC"."MI_Id" = p_MI_Id
            INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = p_MI_Id
            INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id" AND "ASMS"."MI_Id" = p_MI_Id
            INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FSS"."FTI_Id" AND "FTI"."MI_ID" = p_MI_Id
            WHERE "FYP"."MI_Id" = p_MI_Id AND "FYP"."ASMAY_Id" = p_ASMAY_Id AND "FSYS"."AMST_Id" = p_AMST_Id
        LOOP
        
            v_FTI_Id := rec_InstidHeadId."FTI_Id";
            v_FMH_Id := rec_InstidHeadId."FMH_Id";
            
            FOR rec_StudentwiseFeeRepDetails IN
                SELECT "FSYS"."AMST_Id", "FYP"."FYP_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "FSS"."FMH_Id", "FMH_FeeName", "FTI_Name", "FSS"."FTI_Id", "FYP_Receipt_No",
                "FSS_ConcessionAmount", "FTP_Fine_Amt", "FYP_Date", "ASMCL_ClassName", "ASMC_SectionName", "AMAY_RollNo", "AMST_AdmNo", "AMST_FatherName", "AMST_MotherName", "FYP_Bank_Or_Cash", "FYP_DD_Cheque_No", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "FYP_Remarks", "AMST_RegistrationNo", COALESCE("FMCC_ConcessionName",'') AS "FMCC_ConcessionName", "FSS_AdjustedAmount", "AMST_MobileNo", COALESCE("FYP_ChallanNo",'') AS "FYP_ChallanNo", "FMH_Order", "FMA_Amount",
                "FSS_OBArrearAmount", "FSS_RefundAmount", "FSS_CurrentYrCharges", "FTP_Paid_Amt", COALESCE("fyp_transaction_Id",'') AS "fyp_transaction_Id", ("FSS_CurrentYrCharges" - "FSS_ConcessionAmount") - SUM("FTP_Paid_Amt") OVER(ORDER BY "FSS"."FTI_Id", "FSS"."FMH_Id", "FSS_CurrentYrCharges" ROWS UNBOUNDED PRECEDING) AS "FSS_TobePaid", "FYP_PaymentReference_Id", "FMA_Amount", "FSS"."FMG_Id"
                FROM "Fee_Y_Payment" "FYP"
                INNER JOIN "Fee_Y_Payment_School_Student" "FSYS" ON "FSYS"."FYP_Id" = "FYP"."FYP_Id" AND "FSYS"."ASMAY_Id" = "FYP"."ASMAY_ID"
                INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FSYS"."FYP_Id"
                INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMA_Id" = "FTP"."FMA_Id" AND "FMA"."ASMAY_Id" = "FSYS"."ASMAY_Id"
                INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."ASMAY_Id" = "FMA"."ASMAY_Id" AND "FSS"."AMST_Id" = "FSYS"."AMST_Id" AND "FSS"."FMG_Id" = "FMA"."FMG_Id" AND "FSS"."FMH_Id" = "FMA"."FMH_Id" AND "FSS"."FTI_Id" = "FMA"."FTI_Id" AND "FSS"."FMA_Id" = "FMA"."FMA_Id"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "FSYS"."AMST_Id"
                INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."AMST_SOL" IN ('S','L','D')
                INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id" AND "FMH"."MI_Id" = p_MI_Id
                LEFT JOIN "Fee_Master_Concession" "FMCC" ON "FMCC"."FMCC_Id" = "AMS"."AMST_Concession_Type" AND "FMCC"."MI_Id" = p_MI_Id
                INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = p_MI_Id
                INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id" AND "ASMS"."MI_Id" = p_MI_Id
                INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FSS"."FTI_Id" AND "FTI"."MI_ID" = p_MI_Id
                WHERE "FYP"."MI_Id" = p_MI_Id AND "FYP"."ASMAY_Id" = p_ASMAY_Id AND "FSYS"."AMST_Id" = p_AMST_Id AND "FSS"."FTI_Id" = v_FTI_Id AND "FSS"."FMH_Id" = v_FMH_Id AND "FTP_Paid_Amt" > 0 AND "ASYS"."ASMAY_Id" = v_preAsmay_id
            LOOP
            
                INSERT INTO "StudentWiseFeeReceiptDetails_Temp" VALUES(
                    rec_StudentwiseFeeRepDetails."AMST_Id", rec_StudentwiseFeeRepDetails."FYP_Id", rec_StudentwiseFeeRepDetails."AMST_FirstName", rec_StudentwiseFeeRepDetails."AMST_MiddleName", rec_StudentwiseFeeRepDetails."AMST_LastName", rec_StudentwiseFeeRepDetails."FMH_Id", rec_StudentwiseFeeRepDetails."FMH_FeeName", rec_StudentwiseFeeRepDetails."FTI_Name", rec_StudentwiseFeeRepDetails."FTI_Id", rec_StudentwiseFeeRepDetails."FYP_Receipt_No",
                    rec_StudentwiseFeeRepDetails."FSS_ConcessionAmount", rec_StudentwiseFeeRepDetails."FTP_Fine_Amt", rec_StudentwiseFeeRepDetails."FYP_Date", rec_StudentwiseFeeRepDetails."ASMCL_ClassName", rec_StudentwiseFeeRepDetails."ASMC_SectionName", rec_StudentwiseFeeRepDetails."AMAY_RollNo",
                    rec_StudentwiseFeeRepDetails."AMST_AdmNo", rec_StudentwiseFeeRepDetails."AMST_FatherName", rec_StudentwiseFeeRepDetails."AMST_MotherName", rec_StudentwiseFeeRepDetails."FYP_Bank_Or_Cash", rec_StudentwiseFeeRepDetails."FYP_DD_Cheque_No", rec_StudentwiseFeeRepDetails."FYP_DD_Cheque_Date", rec_StudentwiseFeeRepDetails."FYP_Bank_Name", rec_StudentwiseFeeRepDetails."FYP_Remarks", rec_StudentwiseFeeRepDetails."AMST_RegistrationNo", rec_StudentwiseFeeRepDetails."FMCC_ConcessionName", rec_StudentwiseFeeRepDetails."FSS_AdjustedAmount", rec_StudentwiseFeeRepDetails."AMST_MobileNo", rec_StudentwiseFeeRepDetails."FYP_ChallanNo", rec_StudentwiseFeeRepDetails."FMH_Order", rec_StudentwiseFeeRepDetails."FMA_Amount", rec_StudentwiseFeeRepDetails."FSS_OBArrearAmount", rec_StudentwiseFeeRepDetails."FSS_RefundAmount", rec_StudentwiseFeeRepDetails."FSS_CurrentYrCharges", rec_StudentwiseFeeRepDetails."FTP_Paid_Amt", rec_StudentwiseFeeRepDetails."fyp_transaction_Id", rec_StudentwiseFeeRepDetails."FSS_TobePaid", rec_StudentwiseFeeRepDetails."FYP_PaymentReference_Id", rec_StudentwiseFeeRepDetails."FMA_Amount", rec_StudentwiseFeeRepDetails."FMG_Id"
                );
                
            END LOOP;
            
        END LOOP;
        
        RETURN QUERY SELECT * FROM "StudentWiseFeeReceiptDetails_Temp" WHERE "FYP_Id" = p_FYP_Id AND "AMST_Id" = p_AMST_Id ORDER BY "FMH_Order";
        
    END IF;

END;
$$;