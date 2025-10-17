CREATE OR REPLACE FUNCTION "dbo"."Fee_ClassWise_Report_1_Old"(
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
    "ReceiptNo" VARCHAR(300),
    "Date" VARCHAR(30),
    "ChequeNo" TEXT,
    "InstName" TEXT,
    "Paid" DECIMAL,
    "FTI_Id" BIGINT,
    "FYP_DD_Cheque_Date" VARCHAR(30),
    "FYP_Bank_Name" TEXT,
    "AMAY_RollNo" TEXT,
    "AMST_AdmNo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlquery TEXT;
BEGIN
    IF p_flag = 'allr' THEN
        v_sqlquery := 'WITH cte AS (
            SELECT DISTINCT
                "Fee_Y_Payment_School_Student"."AMST_Id",
                (COALESCE("AMST_FirstName", '''') || ''  '' || COALESCE("AMST_MiddleName", '''') || ''  '' || COALESCE("AMST_LastName", '''')) AS "StudentName",
                "ASMCL_ClassName" AS "ClassName",
                "ASMC_SectionName" AS "SectionName",
                "FYP_Receipt_No" AS "ReceiptNo",
                TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "Date",
                COALESCE("FYP_DD_Cheque_No", '''') AS "ChequeNo",
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
                AND ("Adm_M_Student"."AMST_SOL" = ''S'') AND "AMST_ActiveFlag" = TRUE AND "AMAY_ActiveFlag" = TRUE
            INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            WHERE ("Fee_Student_Status"."FMG_Id" IS NOT NULL)
                AND "Fee_Y_Payment"."mi_id" = ' || p_MI_Id || '
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
                AND "FYP_OnlineChallanStatusFlag" = ''Sucessfull''
                AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || p_ASMCL_Id || ')
                AND "Adm_School_Y_Student"."ASMS_Id" IN (' || p_ASMS_Id || ')
                AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
                AND "Fee_Y_Payment"."ASMAY_Id" = ' || p_ASMAY_Id || '
            GROUP BY "Fee_Y_Payment_School_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName",
                "ASMCL_ClassName", "ASMC_SectionName", "FYP_Receipt_No", "FYP_Date", "FYP_DD_Cheque_No",
                "Fee_T_Installment"."FTI_Name", "Fee_T_Installment"."FTI_Id", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "AMAY_RollNo"
        )
        SELECT * FROM cte ORDER BY "ClassName", "SectionName", "StudentName"';
    ELSE
        v_sqlquery := 'WITH cte AS (
            SELECT DISTINCT
                "Fee_Y_Payment_School_Student"."AMST_Id",
                "AMST_AdmNo",
                (COALESCE("AMST_FirstName", '''') || ''  '' || COALESCE("AMST_MiddleName", '''') || ''  '' || COALESCE("AMST_LastName", '''')) AS "StudentName",
                "ASMCL_ClassName" AS "ClassName",
                "ASMC_SectionName" AS "SectionName",
                "FYP_Receipt_No" AS "ReceiptNo",
                TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "Date",
                COALESCE("FYP_DD_Cheque_No", '''') AS "ChequeNo",
                NULL::TEXT AS "InstName",
                SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "Paid",
                NULL::BIGINT AS "FTI_Id",
                TO_CHAR("FYP_DD_Cheque_Date", ''DD/MM/YYYY'') AS "FYP_DD_Cheque_Date",
                "FYP_Bank_Name",
                "AMAY_RollNo"
            FROM "Adm_M_Student"
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
            INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
            INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            INNER JOIN "Fee_Master_Amount" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
            WHERE ("Adm_M_Student"."AMST_SOL" = ''S'')
                AND "AMST_ActiveFlag" = TRUE
                AND "AMAY_ActiveFlag" = TRUE
                AND "Fee_Y_Payment"."mi_id" = ' || p_MI_Id || '
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
                AND "FYP_OnlineChallanStatusFlag" = ''Sucessfull''
                AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || p_ASMCL_Id || ')
                AND "Adm_School_Y_Student"."ASMS_Id" IN (' || p_ASMS_Id || ')
                AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
                AND "Fee_Y_Payment"."ASMAY_Id" = ' || p_ASMAY_Id || '
            GROUP BY "Fee_Y_Payment_School_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName",
                "ASMCL_ClassName", "ASMC_SectionName", "AMAY_RollNo", "AMST_AdmNo", "FYP_Receipt_No", "FYP_Date",
                "FYP_DD_Cheque_No", "FYP_DD_Cheque_Date", "FYP_Bank_Name", "AMAY_RollNo"
            HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
        )
        SELECT * FROM cte ORDER BY "ClassName", "SectionName", "StudentName"';
    END IF;

    RETURN QUERY EXECUTE v_sqlquery;
END;
$$;