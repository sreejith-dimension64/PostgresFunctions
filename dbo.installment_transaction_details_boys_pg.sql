CREATE OR REPLACE FUNCTION "dbo"."installment_transaction_details_boys"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "Amst_id" TEXT,
    "fyp_id" TEXT
)
RETURNS TABLE(
    "amsT_FirstName" VARCHAR,
    "amsT_MiddleName" VARCHAR,
    "amsT_LastName" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "fyP_Receipt_No" VARCHAR,
    "fyP_Date" TIMESTAMP,
    "fmH_FeeName" VARCHAR,
    "ftP_Paid_Amt" NUMERIC,
    "totalcharges" NUMERIC,
    "ftP_Concession_Amt" NUMERIC,
    "AMST_Id" BIGINT,
    "admno" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "fmH_Id" BIGINT,
    "fathername" VARCHAR,
    "mothername" VARCHAR,
    "fyP_DD_Cheque_No" VARCHAR,
    "fyP_DD_Cheque_Date" TIMESTAMP,
    "fyP_Remarks" TEXT,
    "rollno" VARCHAR,
    "fyP_Bank_Name" VARCHAR,
    "fmcC_ConcessionName" VARCHAR,
    "fyP_Bank_Or_Cash" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "ASMCL_Id" BIGINT;
    "ASMS_Id" BIGINT;
BEGIN

    SELECT "Adm_School_Y_Student"."ASMCL_Id", "Adm_School_Y_Student"."ASMS_Id"
    INTO "ASMCL_Id", "ASMS_Id"
    FROM "dbo"."Adm_M_Student" 
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    WHERE "Adm_School_Y_Student"."AMST_Id" = "Amst_id"::BIGINT 
    AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::BIGINT;

    RETURN QUERY
    SELECT "Adm_M_Student"."amsT_FirstName",
        "Adm_M_Student"."amsT_MiddleName",
        "Adm_M_Student"."amsT_LastName",
        "adm_m_student"."AMST_AdmNo",
        "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
        "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname",
        "Fee_Y_Payment"."FYP_Receipt_No" AS "fyP_Receipt_No",
        "Fee_Y_Payment"."FYP_Date" AS "fyP_Date",
        "Fee_Master_Head"."FMH_FeeName" AS "fmH_FeeName",
        SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "ftP_Paid_Amt",
        SUM("Fee_Student_Status"."FSS_NetAmount") AS "totalcharges",
        SUM("Fee_T_Payment"."FTP_Concession_Amt") AS "ftP_Concession_Amt",
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
        "Fee_Master_Concession"."fmcC_ConcessionName",
        "Fee_Y_Payment"."fyP_Bank_Or_Cash"
    FROM "dbo"."Adm_M_Student"
    INNER JOIN "dbo"."Fee_Master_Concession" ON "Adm_M_Student"."AMST_Concession_Type" = "Fee_Master_Concession"."FMCC_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
    INNER JOIN "dbo"."Fee_Student_Status" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
    INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Student_Status"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
    INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Student_Status"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_Student_Status"."FTI_Id" = "Fee_T_Installment"."FTI_Id"
    INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" AND "Fee_Student_Status"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
    WHERE ("Adm_M_Student"."AMST_Id" = "Amst_id"::BIGINT)
    AND ("Adm_School_M_Class"."ASMCL_Id" = "ASMCL_Id")
    AND ("Adm_School_M_Section"."ASMS_Id" = "ASMS_Id")
    AND ("Fee_Y_Payment"."ASMAY_Id" = "ASMAY_Id"::BIGINT)
    AND ("Fee_Y_Payment"."FYP_Id" = "fyp_id"::BIGINT)
    AND ("Adm_M_Student"."MI_Id" = "MI_Id"::BIGINT)
    AND "Fee_T_Payment"."FTP_Paid_Amt" > 0
    GROUP BY "Adm_M_Student"."amsT_FirstName",
        "Adm_M_Student"."amsT_MiddleName",
        "Adm_M_Student"."amsT_LastName",
        "adm_m_student"."AMST_AdmNo",
        "Adm_School_M_Class"."ASMCL_ClassName",
        "Adm_School_M_Section"."ASMC_SectionName",
        "Fee_Y_Payment"."FYP_Receipt_No",
        "Fee_Y_Payment"."FYP_Date",
        "Fee_Master_Head"."FMH_FeeName",
        "Adm_M_Student"."AMST_Id",
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
        "Fee_Master_Concession"."fmcC_ConcessionName",
        "Fee_Y_Payment"."fyP_Bank_Or_Cash"
    ORDER BY "Fee_Master_Head"."fmH_Id";

    RETURN;
END;
$$;