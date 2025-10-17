CREATE OR REPLACE FUNCTION "dbo"."Fee_ClassWise_Report_1"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id VARCHAR(100),
    p_ASMS_Id VARCHAR(100),
    p_flag VARCHAR(100)
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "ClassName" TEXT,
    "SectionName" TEXT,
    "ReceiptNo" TEXT,
    "Date" TEXT,
    "ChequeNo" TEXT,
    "InstName" TEXT,
    "Paid" NUMERIC,
    "FTI_Id" BIGINT,
    "FYP_DD_Cheque_Date" TEXT,
    "FYP_Bank_Name" TEXT,
    "AMAY_RollNo" BIGINT,
    "AMST_AdmNo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_aa TEXT;
    v_where_condition TEXT;
    v_sqlquery TEXT;
    v_sqlquery1 TEXT;
    v_sqlquery2 TEXT;
    v_FeeName TEXT;
    v_FT_Name TEXT;
    v_FName TEXT;
    v_TName TEXT;
    v_columnname VARCHAR(50);
    v_sqlquerycolumn VARCHAR(400);
    v_count INT;
    v_Feenametemp VARCHAR(500);
    v_Studentnametemp VARCHAR(500);
    v_amst_id_temp VARCHAR(500);
    v_paidamount_temp VARCHAR(500);
    v_InstName_temp VARCHAR(500);
    v_admission_no VARCHAR(500);
    v_columnname1 VARCHAR(50);
    v_sqlquerycolumn1 VARCHAR(400);
    v_count1 INT;
    v_Feenametemp1 VARCHAR(500);
    v_Studentnametemp1 VARCHAR(500);
    v_amst_id_temp1 VARCHAR(500);
    v_paidamount_temp1 VARCHAR(500);
    v_InstName_temp1 VARCHAR(500);
    v_admission_no1 VARCHAR(500);
    v_InstName_Test1 VARCHAR(100);
    v_InstName_Test2 VARCHAR(100);
    v_condition VARCHAR(100);
    v_Classnametemp1 VARCHAR(100);
    v_Sectionnametemp1 VARCHAR(100);
    v_ReceiptNotemp1 VARCHAR(100);
    v_fypdatetemp1 VARCHAR(30);
    v_chequenotemp1 VARCHAR(100);
    v_Classname_temp1 VARCHAR(100);
    v_Sectionname_temp1 VARCHAR(100);
    v_ReceiptNo_temp1 VARCHAR(100);
    v_fypdate_temp1 VARCHAR(30);
    v_chequeno_temp1 VARCHAR(100);
BEGIN

    DROP TABLE IF EXISTS "AmountPaidStudents_Temp";
    DROP TABLE IF EXISTS "AmountNotPaidStudents_Temp";

    IF p_flag = 'allr' THEN

        IF p_ASMCL_Id > '0' AND p_ASMS_Id > '0' THEN
        
            v_sqlquery1 := 'CREATE TEMP TABLE "AmountPaidStudents_Temp" AS
            SELECT DISTINCT "Fee_Y_Payment_School_Student"."AMST_Id" as "AMST_Id",
                (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName",
                "ASMCL_ClassName" AS "ClassName",
                "ASMC_SectionName" AS "SectionName",
                "FYP_Receipt_No" AS "ReceiptNo",
                TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "Date",
                COALESCE("FYP_DD_Cheque_No",'''') AS "ChequeNo",
                "Fee_T_Installment"."FTI_Name" AS "InstName",
                SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "Paid",
                "Fee_T_Installment"."FTI_Id",
                TO_CHAR("FYP_DD_Cheque_Date", ''DD/MM/YYYY'') AS "FYP_DD_Cheque_Date",
                "FYP_Bank_Name",
                "AMAY_RollNo",
                NULL::TEXT AS "AMST_AdmNo"
            FROM "dbo"."Fee_Master_Amount"
            INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
            INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment"."fyp_id" = "Fee_Y_Payment_School_Student"."fyp_id"
            INNER JOIN "dbo"."Adm_m_student" ON "Adm_m_student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
            INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" AND "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" AND "Adm_School_Y_Student"."AMST_Id" = "Adm_m_student"."AMST_Id"
                AND ("Adm_M_Student"."AMST_SOL" = ''S'') AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            WHERE ("Fee_Student_Status"."FMG_Id" IS NOT NULL) AND "Fee_Y_Payment"."mi_id" = ' || p_MI_Id || '
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "FYP_OnlineChallanStatusFlag" = ''Sucessfull''
                AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || p_ASMCL_Id || ') AND "Adm_School_Y_Student"."ASMS_Id" IN (' || p_ASMS_Id || ')
                AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "Fee_Y_Payment"."ASMAY_Id" = ' || p_ASMAY_Id || '
            GROUP BY "Fee_Y_Payment_School_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "ASMCL_ClassName", "ASMC_SectionName",
                "FYP_Receipt_No", "FYP_Date", "FYP_DD_Cheque_No", "Fee_T_Installment"."FTI_Name", "Fee_T_Installment"."FTI_Id", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "AMAY_RollNo"
            ORDER BY "ClassName", "SectionName", "StudentName" LIMIT 100';

            v_sqlquery2 := 'CREATE TEMP TABLE "AmountNotPaidStudents_Temp" AS
            SELECT DISTINCT "Adm_School_Y_Student"."AMST_Id" as "AMST_Id",
                (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName",
                "ASMCL_ClassName" AS "ClassName",
                "ASMC_SectionName" AS "SectionName",
                '''' as "ReceiptNo",
                '''' AS "Date",
                '''' AS "ChequeNo",
                "Fee_T_Installment"."FTI_Name" AS "InstName",
                0 AS "Paid",
                "Fee_T_Installment"."FTI_Id",
                '''' AS "FYP_DD_Cheque_Date",
                '''' AS "FYP_Bank_Name",
                "AMAY_RollNo",
                NULL::TEXT AS "AMST_AdmNo"
            FROM "dbo"."Adm_m_student"
            LEFT JOIN "dbo"."Adm_School_Y_Student" ON "Adm_m_student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            INNER JOIN "dbo"."Fee_Master_Amount" ON "Fee_Master_Amount"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Fee_Master_Amount"."MI_Id" = 10001
            LEFT JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id" AND "Fee_Student_Status"."ASMAY_Id" = 10019 AND "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
            WHERE "Adm_m_student"."MI_Id" = ' || p_MI_Id || ' AND ("Adm_M_Student"."AMST_SOL" = ''S'') AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || p_ASMCL_Id || ') AND "Adm_School_Y_Student"."ASMS_Id" IN (' || p_ASMS_Id || ')
                AND "Fee_Student_Status"."FSS_PaidAmount" = 0
                AND "Fee_Student_Status"."AMST_Id" NOT IN (SELECT DISTINCT "AMST_Id" FROM "fee_student_Status" WHERE "MI_Id" = ' || p_MI_Id || ' AND "ASMAY_Id" = ' || p_ASMAY_Id || ' AND "FSS_PaidAMount" <> 0)
            ORDER BY "ClassName", "SectionName", "StudentName" LIMIT 100';

            EXECUTE v_sqlquery1;
            EXECUTE v_sqlquery2;

            RETURN QUERY EXECUTE 'SELECT "AMST_Id", "StudentName", "ClassName", "SectionName", "ReceiptNo", "Date", "ChequeNo", "InstName", "Paid", "FTI_Id", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "AMAY_RollNo", "AMST_AdmNo" FROM "AmountPaidStudents_Temp"
            UNION
            SELECT "AMST_Id", "StudentName", "ClassName", "SectionName", "ReceiptNo", "Date", "ChequeNo", "InstName", "Paid", "FTI_Id", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "AMAY_RollNo", "AMST_AdmNo" FROM "AmountNotPaidStudents_Temp"';

        ELSIF p_ASMCL_Id > '0' AND p_ASMS_Id = '0' THEN

            v_sqlquery1 := 'CREATE TEMP TABLE "AmountPaidStudents_Temp" AS
            SELECT DISTINCT "Fee_Y_Payment_School_Student"."AMST_Id" as "AMST_Id",
                (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName",
                "ASMCL_ClassName" AS "ClassName",
                "ASMC_SectionName" AS "SectionName",
                "FYP_Receipt_No" AS "ReceiptNo",
                TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "Date",
                COALESCE("FYP_DD_Cheque_No",'''') AS "ChequeNo",
                "Fee_T_Installment"."FTI_Name" AS "InstName",
                SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "Paid",
                "Fee_T_Installment"."FTI_Id",
                TO_CHAR("FYP_DD_Cheque_Date", ''DD/MM/YYYY'') AS "FYP_DD_Cheque_Date",
                "FYP_Bank_Name",
                "AMAY_RollNo",
                NULL::TEXT AS "AMST_AdmNo"
            FROM "dbo"."Fee_Master_Amount"
            INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
            INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment"."fyp_id" = "Fee_Y_Payment_School_Student"."fyp_id"
            INNER JOIN "dbo"."Adm_m_student" ON "Adm_m_student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
            INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" AND "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" AND "Adm_School_Y_Student"."AMST_Id" = "Adm_m_student"."AMST_Id"
                AND ("Adm_M_Student"."AMST_SOL" = ''S'') AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            WHERE ("Fee_Student_Status"."FMG_Id" IS NOT NULL) AND "Fee_Y_Payment"."mi_id" = ' || p_MI_Id || '
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "FYP_OnlineChallanStatusFlag" = ''Sucessfull''
                AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || p_ASMCL_Id || ')
                AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "Fee_Y_Payment"."ASMAY_Id" = ' || p_ASMAY_Id || '
            GROUP BY "Fee_Y_Payment_School_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "ASMCL_ClassName", "ASMC_SectionName",
                "FYP_Receipt_No", "FYP_Date", "FYP_DD_Cheque_No", "Fee_T_Installment"."FTI_Name", "Fee_T_Installment"."FTI_Id", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "AMAY_RollNo"
            ORDER BY "ClassName", "SectionName", "StudentName" LIMIT 100';

            v_sqlquery2 := 'CREATE TEMP TABLE "AmountNotPaidStudents_Temp" AS
            SELECT DISTINCT "Adm_School_Y_Student"."AMST_Id" as "AMST_Id",
                (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName",
                "ASMCL_ClassName" AS "ClassName",
                "ASMC_SectionName" AS "SectionName",
                '''' as "ReceiptNo",
                '''' AS "Date",
                '''' AS "ChequeNo",
                "Fee_T_Installment"."FTI_Name" AS "InstName",
                0 AS "Paid",
                "Fee_T_Installment"."FTI_Id",
                '''' AS "FYP_DD_Cheque_Date",
                '''' AS "FYP_Bank_Name",
                "AMAY_RollNo",
                NULL::TEXT AS "AMST_AdmNo"
            FROM "dbo"."Adm_m_student"
            LEFT JOIN "dbo"."Adm_School_Y_Student" ON "Adm_m_student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            INNER JOIN "dbo"."Fee_Master_Amount" ON "Fee_Master_Amount"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Fee_Master_Amount"."MI_Id" = 10001
            LEFT JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id" AND "Fee_Student_Status"."ASMAY_Id" = 10019 AND "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
            WHERE "Adm_m_student"."MI_Id" = ' || p_MI_Id || ' AND ("Adm_M_Student"."AMST_SOL" = ''S'') AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || p_ASMCL_Id || ')
                AND "Fee_Student_Status"."FSS_PaidAmount" = 0
                AND "Fee_Student_Status"."AMST_Id" NOT IN (SELECT DISTINCT "AMST_Id" FROM "fee_student_Status" WHERE "MI_Id" = ' || p_MI_Id || ' AND "ASMAY_Id" = ' || p_ASMAY_Id || ' AND "FSS_PaidAMount" <> 0)
            ORDER BY "ClassName", "SectionName", "StudentName" LIMIT 100';

            EXECUTE v_sqlquery1;
            EXECUTE v_sqlquery2;

            RETURN QUERY EXECUTE 'SELECT "AMST_Id", "StudentName", "ClassName", "SectionName", "ReceiptNo", "Date", "ChequeNo", "InstName", "Paid", "FTI_Id", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "AMAY_RollNo", "AMST_AdmNo" FROM "AmountPaidStudents_Temp"
            UNION
            SELECT "AMST_Id", "StudentName", "ClassName", "SectionName", "ReceiptNo", "Date", "ChequeNo", "InstName", "Paid", "FTI_Id", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "AMAY_RollNo", "AMST_AdmNo" FROM "AmountNotPaidStudents_Temp"';

        ELSIF p_ASMCL_Id = '0' AND p_ASMS_Id = '0' THEN

            v_sqlquery1 := 'CREATE TEMP TABLE "AmountPaidStudents_Temp" AS
            SELECT DISTINCT "Fee_Y_Payment_School_Student"."AMST_Id" as "AMST_Id",
                (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName",
                "ASMCL_ClassName" AS "ClassName",
                "ASMC_SectionName" AS "SectionName",
                "FYP_Receipt_No" AS "ReceiptNo",
                TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "Date",
                COALESCE("FYP_DD_Cheque_No",'''') AS "ChequeNo",
                "Fee_T_Installment"."FTI_Name" AS "InstName",
                SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "Paid",
                "Fee_T_Installment"."FTI_Id",
                TO_CHAR("FYP_DD_Cheque_Date", ''DD/MM/YYYY'') AS "FYP_DD_Cheque_Date",
                "FYP_Bank_Name",
                "AMAY_RollNo",
                NULL::TEXT AS "AMST_AdmNo"
            FROM "dbo"."Fee_Master_Amount"
            INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
            INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment"."fyp_id" = "Fee_Y_Payment_School_Student"."fyp_id"
            INNER JOIN "dbo"."Adm_m_student" ON "Adm_m_student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
            INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" AND "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" AND "Adm_School_Y_Student"."AMST_Id" = "Adm_m_student"."AMST_Id"
                AND ("Adm_M_Student"."AMST_SOL" = ''S'') AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            WHERE ("Fee_Student_Status"."FMG_Id" IS NOT NULL) AND "Fee_Y_Payment"."mi_id" = ' || p_MI_Id || '
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "FYP_OnlineChallanStatusFlag" = ''Sucessfull''
                AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "Fee_Y_Payment"."ASMAY_Id" = ' || p_ASMAY_Id || '
            GROUP BY "Fee_Y_Payment_School_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "ASMCL_ClassName", "ASMC_SectionName",
                "FYP_Receipt_No", "FYP_Date", "FYP_DD_Cheque_No", "Fee_T_Installment"."FTI_Name", "Fee_T_Installment"."FTI_Id", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "AMAY