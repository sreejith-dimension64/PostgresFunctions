CREATE OR REPLACE FUNCTION "dbo"."fee_it_report"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "Amst_id" TEXT,
    "fmh_id" TEXT
)
RETURNS TABLE(
    "amsT_FirstName" VARCHAR,
    "amsT_MiddleName" VARCHAR,
    "amsT_LastName" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
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
    "rollno" BIGINT,
    "fmcC_ConcessionName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "ASMCL_Id" TEXT;
    "ASMS_Id" TEXT;
    "sql1head" TEXT;
BEGIN

    SELECT 
        "Adm_School_Y_Student"."ASMCL_Id",
        "Adm_School_Y_Student"."ASMS_Id"
    INTO 
        "ASMCL_Id",
        "ASMS_Id"
    FROM 
        "dbo"."Adm_M_Student" 
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    WHERE 
        "Adm_School_Y_Student"."AMST_Id" = "Amst_id"::BIGINT 
        AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::BIGINT;

    "sql1head" := 'SELECT 
        "Adm_M_Student"."amsT_FirstName",
        "Adm_M_Student"."amsT_MiddleName",
        "Adm_M_Student"."amsT_LastName",
        "adm_m_student"."AMST_AdmNo",
        "Adm_School_M_Class"."ASMCL_ClassName" as classname,
        "Adm_School_M_Section"."ASMC_SectionName" as sectionname,
        "Fee_Master_Head"."FMH_FeeName" as fmH_FeeName,
        sum("Fee_T_Payment"."FTP_Paid_Amt") as ftP_Paid_Amt,
        sum("Fee_Student_Status"."FSS_NetAmount") as totalcharges,
        sum("Fee_T_Payment"."FTP_Concession_Amt") as ftP_Concession_Amt,
        "Adm_M_Student"."AMST_Id",
        "Adm_M_Student"."AMST_AdmNo" as admno,
        "Adm_M_Student"."AMST_RegistrationNo",
        "Fee_Master_Head"."fmH_Id",
        "Adm_M_Student"."AMST_FatherName" as fathername,
        "Adm_M_Student"."AMST_MotherName" as mothername,
        "Adm_School_Y_Student"."AMAY_RollNo" as rollno,
        "Fee_Master_Concession"."fmcC_ConcessionName"
    FROM 
        "dbo"."Adm_M_Student"
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
        INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" 
            AND "Fee_Student_Status"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
    WHERE 
        ("Adm_M_Student"."AMST_Id" = ' || "Amst_id" || ')
        AND ("Adm_School_M_Class"."ASMCL_Id" = ' || "ASMCL_Id" || ')
        AND ("Adm_School_M_Section"."ASMS_Id" = ' || "ASMS_Id" || ')
        AND ("Fee_Y_Payment"."ASMAY_Id" = ' || "ASMAY_Id" || ')
        AND ("Fee_Student_Status"."FMH_Id" IN (' || "fmh_id" || '))
        AND ("Adm_M_Student"."MI_Id" = ' || "MI_Id" || ')
        AND "Fee_T_Payment"."FTP_Paid_Amt" > 0
    GROUP BY 
        "Adm_M_Student"."amsT_FirstName",
        "Adm_M_Student"."amsT_MiddleName",
        "Adm_M_Student"."amsT_LastName",
        "adm_m_student"."AMST_AdmNo",
        "Adm_School_M_Class"."ASMCL_ClassName",
        "Adm_School_M_Section"."ASMC_SectionName",
        "Fee_Master_Head"."FMH_FeeName",
        "Adm_M_Student"."AMST_Id",
        "Adm_M_Student"."AMST_AdmNo",
        "Adm_M_Student"."AMST_RegistrationNo",
        "Fee_Master_Head"."fmH_Id",
        "Adm_M_Student"."AMST_FatherName",
        "Adm_M_Student"."AMST_MotherName",
        "Fee_Y_Payment"."fyP_Remarks",
        "Adm_School_Y_Student"."AMAY_RollNo",
        "Fee_Master_Concession"."fmcC_ConcessionName"
    ORDER BY "Fee_Master_Head"."FMH_Id"';

    RETURN QUERY EXECUTE "sql1head";

END;
$$;