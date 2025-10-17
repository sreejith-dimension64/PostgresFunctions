CREATE OR REPLACE FUNCTION "dbo"."installment_transaction_details_BU"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@Amst_id" TEXT,
    "@fyp_id" TEXT
)
RETURNS TABLE(
    "amsT_FirstName" VARCHAR,
    "amsT_MiddleName" VARCHAR,
    "amsT_LastName" VARCHAR,
    "fmH_FeeName" VARCHAR,
    "fyP_Receipt_No" VARCHAR,
    "ftP_Paid_Amt" NUMERIC,
    "fmA_Amount" NUMERIC,
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
    "rollno" BIGINT,
    "fyP_Bank_Name" VARCHAR,
    "FMH_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "Adm_M_Student"."amsT_FirstName",
        "Adm_M_Student"."amsT_MiddleName",
        "Adm_M_Student"."amsT_LastName",
        "Fee_Master_Head"."fmH_FeeName",
        "Fee_Y_Payment"."fyP_Receipt_No",
        SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "ftP_Paid_Amt",
        SUM("Fee_Master_Amount"."FMA_Amount") AS "fmA_Amount",
        SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "ftP_Concession_Amt",
        SUM("Fee_T_Payment"."FTP_Fine_Amt") AS "ftP_Fine_Amt",
        "Fee_Y_Payment"."fyP_Date",
        "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
        "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname",
        "Fee_Y_Payment"."fyP_Bank_Or_Cash",
        "Fee_Master_Concession"."fmcC_ConcessionName",
        "Adm_M_Student"."AMST_Id",
        "Adm_M_Student"."AMST_AdmNo" AS "admno",
        "Adm_M_Student"."AMST_RegistrationNo",
        "Fee_Master_Head"."fmH_Id",
        "Adm_M_Student"."AMST_FatherName" AS "fathername",
        "Adm_M_Student"."AMST_MotherName" AS "mothername",
        "Fee_Y_Payment"."fyP_DD_Cheque_No",
        "Fee_Y_Payment"."fyP_DD_Cheque_Date",
        "Fee_Y_Payment"."fyP_Remarks",
        "Adm_School_Y_Student"."AMAY_RollNo" AS "rollno",
        "Fee_Y_Payment"."fyP_Bank_Name",
        "Fee_Master_Head"."FMH_Order"
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
    INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Student_Status"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
        AND "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        AND "Fee_Student_Status"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
    WHERE ("Adm_M_Student"."AMST_Id"::TEXT = "@Amst_id")
        AND ("Fee_Y_Payment"."FYP_Id"::TEXT = "@fyp_id")
        AND ("Fee_Y_Payment"."MI_Id"::TEXT = "@MI_Id")
        AND ("Adm_School_Y_Student"."ASMAY_ID"::TEXT = "@ASMAY_Id")
        AND ("Adm_M_Student"."AMST_SOL" = 'S' OR "Adm_M_Student"."AMST_SOL" = 'L' OR "Adm_M_Student"."AMST_SOL" = 'D')
    GROUP BY 
        "Adm_M_Student"."AMST_FirstName",
        "Adm_M_Student"."AMST_MiddleName",
        "Adm_M_Student"."AMST_LastName",
        "Fee_Master_Head"."fmH_FeeName",
        "Fee_Y_Payment"."fyP_Receipt_No",
        "Fee_Y_Payment"."fyP_Date",
        "Adm_School_M_Class"."ASMCL_ClassName",
        "Adm_School_M_Section"."ASMC_SectionName",
        "Fee_Y_Payment"."fyP_Bank_Or_Cash",
        "Fee_Master_Concession"."fmcC_ConcessionName",
        "Adm_M_Student"."AMST_Id",
        "Fee_Master_Installment"."FMI_Name",
        "Adm_M_Student"."AMST_AdmNo",
        "Adm_M_Student"."AMST_RegistrationNo",
        "Fee_Master_Head"."fmH_Id",
        "Adm_M_Student"."AMST_FatherName",
        "Adm_M_Student"."AMST_MotherName",
        "Fee_Y_Payment"."fyP_DD_Cheque_No",
        "Fee_Y_Payment"."fyP_DD_Cheque_Date",
        "Fee_Y_Payment"."fyP_Remarks",
        "Adm_School_Y_Student"."AMAY_RollNo",
        "Fee_Y_Payment"."fyP_Bank_Name",
        "Fee_Master_Amount"."FMA_Amount",
        "Fee_Master_Head"."FMH_Order"
    ORDER BY "Fee_Master_Head"."FMH_Order";
END;
$$;