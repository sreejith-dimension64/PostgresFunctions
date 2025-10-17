CREATE OR REPLACE FUNCTION "dbo"."FeeITReport"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@Amst_id" TEXT,
    "@FYP_Id" TEXT
)
RETURNS TABLE(
    "amsT_FirstName" VARCHAR,
    "amsT_MiddleName" VARCHAR,
    "amsT_LastName" VARCHAR,
    "fmH_Id" BIGINT,
    "ftI_Name" VARCHAR,
    "ftI_Id" BIGINT,
    "fyP_Receipt_no" VARCHAR,
    "fmH_FeeName" VARCHAR,
    "ftP_Paid_Amt" NUMERIC,
    "fyP_Date" TIMESTAMP,
    "ftP_Concession_Amt" NUMERIC,
    "ftP_Fine_Amt" NUMERIC,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "fmcC_ConcessionName" VARCHAR,
    "AMST_Id" BIGINT,
    "admno" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "fathername" VARCHAR,
    "mothername" VARCHAR,
    "rollno" BIGINT,
    "fmA_Amount" NUMERIC,
    "FMH_Order" INTEGER,
    "fyP_Bank_Or_Cash" VARCHAR,
    "fyP_DD_Cheque_No" VARCHAR,
    "fyP_DD_Cheque_Date" TIMESTAMP,
    "fyP_Bank_Name" VARCHAR,
    "FYP_Remarks" VARCHAR,
    "amsT_RegistrationNo" VARCHAR,
    "fsS_AdjustedAmount" NUMERIC,
    "amst_mobile" BIGINT,
    "fyP_ChallanNo" VARCHAR,
    "fmH_Order" INTEGER,
    "fyP_PaymentReference_Id" VARCHAR,
    "fsS_ToBePaid" NUMERIC,
    "ASMAY_Year" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "Adm_M_Student"."amsT_FirstName",
        "Adm_M_Student"."amsT_MiddleName",
        "Adm_M_Student"."amsT_LastName",
        "Fee_Master_Head"."FMH_Id" AS "fmH_Id",
        "Fee_T_Installment"."FTI_Name" AS "ftI_Name",
        "Fee_T_Installment"."FTI_Id" AS "ftI_Id",
        "Fee_Y_Payment"."FYP_Receipt_No" AS "fyP_Receipt_no",
        "Fee_Master_Head"."fmH_FeeName",
        SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "ftP_Paid_Amt",
        "Fee_Y_Payment"."FYP_Date" AS "fyP_Date",
        SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "ftP_Concession_Amt",
        SUM("Fee_T_Payment"."FTP_Fine_Amt") AS "ftP_Fine_Amt",
        "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
        "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname",
        "Fee_Master_Concession"."fmcC_ConcessionName",
        "Adm_M_Student"."AMST_Id",
        "Adm_M_Student"."AMST_AdmNo" AS "admno",
        "Adm_M_Student"."AMST_AdmNo",
        "Adm_M_Student"."AMST_FatherName" AS "fathername",
        "Adm_M_Student"."AMST_MotherName" AS "mothername",
        "Adm_School_Y_Student"."AMAY_RollNo" AS "rollno",
        SUM("Fee_Master_Amount"."FMA_Amount") AS "fmA_Amount",
        "Fee_Master_Head"."FMH_Order",
        "Fee_Y_Payment"."FYP_Bank_Or_Cash" AS "fyP_Bank_Or_Cash",
        "Fee_Y_Payment"."FYP_DD_Cheque_No" AS "fyP_DD_Cheque_No",
        "Fee_Y_Payment"."FYP_DD_Cheque_Date" AS "fyP_DD_Cheque_Date",
        "Fee_Y_Payment"."FYP_Bank_Name" AS "fyP_Bank_Name",
        "Fee_Y_Payment"."FYP_Remarks" AS "FYP_Remarks",
        "Adm_M_Student"."AMST_RegistrationNo" AS "amsT_RegistrationNo",
        "Fee_Student_Status"."FSS_AdjustedAmount" AS "fsS_AdjustedAmount",
        "Adm_M_Student"."AMST_MobileNo" AS "amst_mobile",
        "Fee_Y_Payment"."FYP_ChallanNo" AS "fyP_ChallanNo",
        "Fee_Master_Head"."FMH_Order" AS "fmH_Order",
        "Fee_Y_Payment"."FYP_PaymentReference_Id" AS "fyP_PaymentReference_Id",
        "Fee_Student_Status"."FSS_ToBePaid" AS "fsS_ToBePaid",
        "Adm_School_M_Academic_Year"."ASMAY_Year"
    FROM "dbo"."Adm_M_Student"
    INNER JOIN "dbo"."Fee_Master_Concession" ON "Adm_M_Student"."AMST_Concession_Type" = "Fee_Master_Concession"."FMCC_Id"
    INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
    INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
    INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
    INNER JOIN "dbo"."Fee_Master_Amount" ON "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Master_Amount"."FTI_Id"
    INNER JOIN "dbo"."Fee_Master_Installment" ON "Fee_T_Installment"."FMI_Id" = "Fee_Master_Installment"."FMI_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Master_Amount"."ASMAY_Id"
    INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Student_Status"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        AND "Fee_Student_Status"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
        AND "Fee_Student_Status"."ASMAY_Id" = "Fee_Master_Amount"."ASMAY_Id"
    WHERE "Adm_M_Student"."AMST_Id" = "@Amst_id"::BIGINT
        AND "Fee_Y_Payment"."MI_Id" = "@MI_Id"::BIGINT
        AND "Fee_Y_Payment"."ASMAY_ID" = "@ASMAY_Id"::BIGINT
        AND "Adm_School_Y_Student"."ASMAY_ID" = "@ASMAY_Id"::BIGINT
        AND "Fee_Student_Status"."FSS_OBArrearAmount" = 0
        AND "Fee_Y_Payment"."FYP_Id" = "@FYP_Id"::BIGINT
        AND "Adm_M_Student"."AMST_SOL" = 'S'
    GROUP BY 
        "Adm_M_Student"."AMST_FirstName",
        "Adm_M_Student"."AMST_MiddleName",
        "Adm_M_Student"."AMST_LastName",
        "Fee_Master_Head"."fmH_FeeName",
        "Adm_School_M_Class"."ASMCL_ClassName",
        "Adm_School_M_Section"."ASMC_SectionName",
        "Fee_Master_Concession"."FMCC_ConcessionName",
        "Adm_M_Student"."AMST_Id",
        "Fee_Master_Installment"."FMI_Name",
        "Adm_M_Student"."AMST_AdmNo",
        "Adm_M_Student"."AMST_RegistrationNo",
        "Fee_Master_Head"."FMH_Id",
        "Adm_M_Student"."AMST_FatherName",
        "Adm_M_Student"."AMST_MotherName",
        "Adm_School_Y_Student"."AMAY_RollNo",
        "Fee_Master_Amount"."FMA_Amount",
        "Fee_Master_Head"."FMH_Order",
        "Adm_School_M_Academic_Year"."ASMAY_Year",
        "Fee_T_Installment"."FTI_Name",
        "Fee_T_Installment"."FTI_Id",
        "Fee_Y_Payment"."FYP_Receipt_No",
        "Fee_Master_Head"."fmH_FeeName",
        "Fee_Y_Payment"."FYP_Bank_Or_Cash",
        "Fee_Y_Payment"."FYP_DD_Cheque_No",
        "Fee_Y_Payment"."FYP_DD_Cheque_Date",
        "Fee_Y_Payment"."FYP_Bank_Name",
        "Fee_Y_Payment"."FYP_Remarks",
        "Fee_Y_Payment"."FYP_Date",
        "Fee_Student_Status"."FSS_AdjustedAmount",
        "Fee_Y_Payment"."FYP_PaymentReference_Id",
        "Fee_Student_Status"."FSS_ToBePaid",
        "Adm_M_Student"."AMST_MobileNo",
        "Fee_Y_Payment"."FYP_ChallanNo",
        "Fee_Master_Head"."FMH_Order"
    HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
    ORDER BY "Fee_Master_Head"."FMH_Order";
END;
$$;