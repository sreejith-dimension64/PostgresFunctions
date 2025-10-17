CREATE OR REPLACE FUNCTION "dbo"."Fee_ClassWise_Report" (
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" VARCHAR(100),
    "ASMS_Id" VARCHAR(100)
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "ClassName" TEXT,
    "SectionName" TEXT,
    "ReceiptNo" TEXT,
    "Date" VARCHAR(30),
    "ChequeNo" TEXT,
    "FeeName" TEXT,
    "InstName" TEXT,
    "Paid" DECIMAL(10,2),
    "FTI_Id" BIGINT,
    "FYP_DD_Cheque_Date" VARCHAR(30),
    "FYP_Bank_Name" TEXT,
    "AMAY_RollNo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "aa" TEXT;
    "where_condition" TEXT;
    "sqlquery" TEXT;
    "FeeName" TEXT;
    "FT_Name" TEXT;
    "FName" TEXT;
    "TName" TEXT;
    "columnname" VARCHAR(50);
    "sqlquerycolumn" VARCHAR(400);
    "count" INT;
    "Feenametemp" VARCHAR(500);
    "Studentnametemp" VARCHAR(500);
    "amst_id_temp" VARCHAR(500);
    "paidamount_temp" VARCHAR(500);
    "InstName_temp" VARCHAR(500);
    "admission_no" VARCHAR(500);
    "columnname1" VARCHAR(50);
    "sqlquerycolumn1" VARCHAR(400);
    "count1" INT;
    "Feenametemp1" VARCHAR(500);
    "Studentnametemp1" VARCHAR(500);
    "amst_id_temp1" VARCHAR(500);
    "paidamount_temp1" VARCHAR(500);
    "InstName_temp1" VARCHAR(500);
    "admission_no1" VARCHAR(500);
    "InstName_Test1" VARCHAR(100);
    "InstName_Test2" VARCHAR(100);
    "condition" TEXT;
    "Classnametemp1" TEXT;
    "Sectionnametemp1" TEXT;
    "ReceiptNotemp1" TEXT;
    "fypdatetemp1" VARCHAR(30);
    "chequenotemp1" TEXT;
    "Classname_temp1" TEXT;
    "Sectionname_temp1" TEXT;
    "ReceiptNo_temp1" TEXT;
    "fypdate_temp1" VARCHAR(30);
    "chequeno_temp1" TEXT;
BEGIN
    "sqlquery" := ';WITH cte AS
    (
      SELECT DISTINCT "Fee_Y_Payment_School_Student"."AMST_Id",
             (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName",
             "ASMCL_ClassName" AS "ClassName",
             "ASMC_SectionName" AS "SectionName",
             "FYP_Receipt_No" AS "ReceiptNo",
             TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "Date",
             COALESCE("FYP_DD_Cheque_No",'''') AS "ChequeNo",
             "Fee_Master_Head"."FMH_FeeName" AS "FeeName",
             "Fee_T_Installment"."FTI_Name" AS "InstName",
             "Fee_T_Payment"."FTP_Paid_Amt" AS "Paid",
             "Fee_T_Installment"."FTI_Id",
             TO_CHAR("FYP_DD_Cheque_Date", ''DD/MM/YYYY') AS "FYP_DD_Cheque_Date",
             "FYP_Bank_Name",
             "AMAY_RollNo"
      FROM "dbo"."Fee_Master_Amount"
      INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
      INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
      INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "Fee_Master_Group"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id"
      INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "Fee_Master_Group_Grouping"."FMGG_Id"
      INNER JOIN "dbo"."Fee_Yearly_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" 
                 AND "Fee_Student_Status"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id"
      INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
      INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
      INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment"."fyp_id" = "Fee_Y_Payment_School_Student"."fyp_id"
      INNER JOIN "dbo"."Adm_m_student" ON "Adm_m_student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
      INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" 
                 AND "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
      INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
      INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
      INNER JOIN "dbo"."Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                 AND "Adm_School_Y_Student"."AMST_Id" = "Adm_m_student"."AMST_Id"
                 AND ("Adm_M_Student"."AMST_SOL" = ''S'') 
                 AND "AMST_ActiveFlag" = 1 
                 AND "AMAY_ActiveFlag" = 1
      INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
      INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
      WHERE ("Fee_Student_Status"."FMG_Id" IS NOT NULL) 
            AND "Fee_Y_Payment"."mi_id" = ' || "MI_Id"::TEXT || '
            AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_Id"::TEXT || '
            AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || "ASMCL_Id" || ')
            AND "Adm_School_Y_Student"."ASMS_Id" IN (' || "ASMS_Id" || ')
            AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || "ASMAY_Id"::TEXT || '
            AND "Fee_Y_Payment"."ASMAY_Id" = ' || "ASMAY_Id"::TEXT || '
      LIMIT 100
    ) SELECT * FROM cte';

    RETURN QUERY EXECUTE "sqlquery";

END;
$$;