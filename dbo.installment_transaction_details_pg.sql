CREATE OR REPLACE FUNCTION "dbo"."installment_transaction_details"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_Amst_id" TEXT,
    "p_fyp_id" TEXT
)
RETURNS TABLE(
    "FMA_Id" BIGINT,
    "amsT_FirstName" VARCHAR,
    "amsT_MiddleName" VARCHAR,
    "amsT_LastName" VARCHAR,
    "fmH_FeeName" VARCHAR,
    "fyP_Receipt_No" VARCHAR,
    "ftP_Paid_Amt" NUMERIC,
    "ftP_Concession_Amt" NUMERIC,
    "ftP_Fine_Amt" NUMERIC,
    "fyP_Date" TIMESTAMP,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "fyP_Bank_Or_Cash" VARCHAR,
    "fmcC_ConcessionName" VARCHAR,
    "AMST_Id" BIGINT,
    "admno" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "fmH_Id" BIGINT,
    "fathername" VARCHAR,
    "mothername" VARCHAR,
    "fyP_DD_Cheque_No" VARCHAR,
    "fyP_DD_Cheque_Date" TIMESTAMP,
    "fyP_Remarks" VARCHAR,
    "rollno" VARCHAR,
    "fyP_Bank_Name" VARCHAR,
    "fmA_Amount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_curryearorder" BIGINT;
    "v_selectedcurryearorder" BIGINT;
BEGIN
    SELECT "ASMAY_Order" INTO "v_curryearorder"
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = "p_MI_Id"
    AND CURRENT_DATE BETWEEN "ASMAY_From_Date"::DATE AND "ASMAY_To_Date"::DATE;

    SELECT "ASMAY_Order" INTO "v_selectedcurryearorder"
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = "p_MI_Id"
    AND "ASMAY_Id" = "p_ASMAY_Id";

    IF "v_curryearorder" = "v_selectedcurryearorder" THEN
        RETURN QUERY
        SELECT "fee_t_payment"."FMA_Id", "Adm_M_Student"."amsT_FirstName", "Adm_M_Student"."amsT_MiddleName", "Adm_M_Student"."amsT_LastName",
               "Fee_Master_Head"."fmH_FeeName", "Fee_Y_Payment"."fyP_Receipt_No", SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "ftP_Paid_Amt",
               SUM("Fee_T_Payment"."FTP_Concession_Amt") AS "ftP_Concession_Amt", SUM("Fee_T_Payment"."FTP_Fine_Amt") AS "ftP_Fine_Amt",
               "Fee_Y_Payment"."fyP_Date", "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
               "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname", "Fee_Y_Payment"."fyP_Bank_Or_Cash", "Fee_Master_Concession"."fmcC_ConcessionName",
               "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo" AS "admno", "Adm_M_Student"."AMST_RegistrationNo", "Fee_Master_Head"."fmH_Id",
               "Adm_M_Student"."AMST_FatherName" AS "fathername", "Adm_M_Student"."AMST_MotherName" AS "mothername",
               "Fee_Y_Payment"."fyP_DD_Cheque_No", "Fee_Y_Payment"."fyP_DD_Cheque_Date", "Fee_Y_Payment"."fyP_Remarks",
               "Adm_School_Y_Student"."AMAY_RollNo" AS "rollno", "Fee_Y_Payment"."fyP_Bank_Name", "Fee_Master_Amount"."FMA_Amount" AS "fmA_Amount"
        FROM "Adm_M_Student"
        INNER JOIN "Fee_Master_Concession" ON "Adm_M_Student"."AMST_Concession_Type" = "Fee_Master_Concession"."FMCC_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Fee_T_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" ON "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Master_Amount"."FTI_Id"
        INNER JOIN "Fee_Master_Installment" ON "Fee_T_Installment"."FMI_Id" = "Fee_Master_Installment"."FMI_Id"
        WHERE "Adm_M_Student"."AMST_Id" = "p_Amst_id"
        AND "Fee_Y_Payment"."FYP_Id" = "p_fyp_id"
        AND "Fee_Y_Payment"."MI_Id" = "p_MI_Id"
        AND "Fee_Y_Payment"."ASMAY_ID" = "p_ASMAY_Id"
        AND "Adm_School_Y_Student"."ASMAY_ID" = "p_ASMAY_Id"
        AND "Adm_M_Student"."AMST_SOL" = 'S'
        GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", "Fee_Master_Head"."FMH_FeeName",
                 "Fee_Y_Payment"."FYP_Receipt_No", "Fee_Y_Payment"."FYP_Date", "Adm_School_M_Class"."ASMCL_ClassName",
                 "Adm_School_M_Section"."ASMC_SectionName", "Fee_Y_Payment"."FYP_Bank_Or_Cash", "Fee_Master_Concession"."FMCC_ConcessionName",
                 "Adm_M_Student"."AMST_Id", "Fee_Master_Installment"."FMI_Name", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo",
                 "Fee_Master_Head"."FMH_Id", "Adm_M_Student"."AMST_FatherName", "Adm_M_Student"."AMST_MotherName",
                 "Fee_Y_Payment"."FYP_DD_Cheque_No", "Fee_Y_Payment"."FYP_DD_Cheque_Date", "Fee_Y_Payment"."FYP_Remarks",
                 "Adm_School_Y_Student"."AMAY_RollNo", "Fee_Y_Payment"."FYP_Bank_Name", "Fee_Master_Amount"."FMA_Amount", "fee_t_payment"."FMA_Id"
        HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0;
    ELSE
        RETURN QUERY
        SELECT "fee_t_payment"."FMA_Id", "Adm_M_Student"."amsT_FirstName", "Adm_M_Student"."amsT_MiddleName", "Adm_M_Student"."amsT_LastName",
               "Fee_Master_Head"."fmH_FeeName", "Fee_Y_Payment"."fyP_Receipt_No", SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "ftP_Paid_Amt",
               SUM("Fee_T_Payment"."FTP_Concession_Amt") AS "ftP_Concession_Amt", SUM("Fee_T_Payment"."FTP_Fine_Amt") AS "ftP_Fine_Amt",
               "Fee_Y_Payment"."fyP_Date", "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
               "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname", "Fee_Y_Payment"."fyP_Bank_Or_Cash", "Fee_Master_Concession"."fmcC_ConcessionName",
               "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo" AS "admno", "Adm_M_Student"."AMST_RegistrationNo", "Fee_Master_Head"."fmH_Id",
               "Adm_M_Student"."AMST_FatherName" AS "fathername", "Adm_M_Student"."AMST_MotherName" AS "mothername",
               "Fee_Y_Payment"."fyP_DD_Cheque_No", "Fee_Y_Payment"."fyP_DD_Cheque_Date", "Fee_Y_Payment"."fyP_Remarks",
               "Adm_School_Y_Student"."AMAY_RollNo" AS "rollno", "Fee_Y_Payment"."fyP_Bank_Name", "Fee_Master_Amount"."FMA_Amount" AS "fmA_Amount"
        FROM "Adm_M_Student"
        INNER JOIN "Fee_Master_Concession" ON "Adm_M_Student"."AMST_Concession_Type" = "Fee_Master_Concession"."FMCC_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Fee_T_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" ON "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Master_Amount"."FTI_Id"
        INNER JOIN "Fee_Master_Installment" ON "Fee_T_Installment"."FMI_Id" = "Fee_Master_Installment"."FMI_Id"
        WHERE "Adm_M_Student"."AMST_Id" = "p_Amst_id"
        AND "Fee_Y_Payment"."FYP_Id" = "p_fyp_id"
        AND "Fee_Y_Payment"."MI_Id" = "p_MI_Id"
        AND "Fee_Y_Payment"."ASMAY_ID" = "p_ASMAY_Id"
        AND "Adm_M_Student"."AMST_SOL" = 'S'
        AND "Adm_School_Y_Student"."ASMAY_ID" = "p_ASMAY_Id"
        GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", "Fee_Master_Head"."FMH_FeeName",
                 "Fee_Y_Payment"."FYP_Receipt_No", "Fee_Y_Payment"."FYP_Date", "Adm_School_M_Class"."ASMCL_ClassName",
                 "Adm_School_M_Section"."ASMC_SectionName", "Fee_Y_Payment"."FYP_Bank_Or_Cash", "Fee_Master_Concession"."FMCC_ConcessionName",
                 "Adm_M_Student"."AMST_Id", "Fee_Master_Installment"."FMI_Name", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo",
                 "Fee_Master_Head"."FMH_Id", "Adm_M_Student"."AMST_FatherName", "Adm_M_Student"."AMST_MotherName",
                 "Fee_Y_Payment"."FYP_DD_Cheque_No", "Fee_Y_Payment"."FYP_DD_Cheque_Date", "Fee_Y_Payment"."FYP_Remarks",
                 "Adm_School_Y_Student"."AMAY_RollNo", "Fee_Y_Payment"."FYP_Bank_Name", "Fee_Master_Amount"."FMA_Amount", "fee_t_payment"."FMA_Id"
        HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
        LIMIT 10;
    END IF;

    RETURN;
END;
$$;