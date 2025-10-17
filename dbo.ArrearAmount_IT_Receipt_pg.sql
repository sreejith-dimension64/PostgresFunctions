CREATE OR REPLACE FUNCTION "dbo"."ArrearAmount_IT_Receipt"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "amsT_FirstName" TEXT,
    "fmH_FeeName" VARCHAR,
    "FSS_OBArrearAmount" NUMERIC,
    "ftP_Paid_Amt" NUMERIC,
    "ftP_Concession_Amt" NUMERIC,
    "ftP_Fine_Amt" NUMERIC,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "fmcC_ConcessionName" VARCHAR,
    "AMST_Id" BIGINT,
    "admno" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "fmH_Id" BIGINT,
    "fathername" VARCHAR,
    "mothername" VARCHAR,
    "rollno" BIGINT,
    "fmA_Amount" NUMERIC,
    "FMH_Order" INT,
    "ASMAY_Year" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_NextAccYear VARCHAR(100);
    v_Stucount INT;
BEGIN
    v_NextAccYear := '0';
    v_Stucount := 0;
    
    SELECT "ASMAY_Id" INTO v_NextAccYear
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = p_MI_Id::BIGINT
    AND "ASMAY_Order" = (
        SELECT "ASMAY_Order"
        FROM "Adm_School_M_Academic_Year"
        WHERE "MI_Id" = p_MI_Id::BIGINT
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT
    ) + 1;
    
    v_Stucount := 0;
    
    SELECT COUNT(*) INTO v_Stucount
    FROM "Fee_Student_Status"
    WHERE "AMST_Id" = p_AMST_Id::BIGINT
    AND "ASMAY_Id" = v_NextAccYear::BIGINT
    AND "MI_Id" = p_MI_Id::BIGINT;
    
    IF (v_Stucount <> 0) THEN
        RETURN QUERY
        SELECT 
            COALESCE("Adm_M_Student"."amsT_FirstName", '') || ' ' || COALESCE("Adm_M_Student"."amsT_MiddleName", '') || ' ' || COALESCE("Adm_M_Student"."amsT_LastName", '') AS "amsT_FirstName",
            "Fee_Master_Head"."fmH_FeeName",
            SUM("Fee_Student_Status"."FSS_OBArrearAmount") AS "FSS_OBArrearAmount",
            SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "ftP_Paid_Amt",
            SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "ftP_Concession_Amt",
            SUM("Fee_T_Payment"."FTP_Fine_Amt") AS "ftP_Fine_Amt",
            "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
            "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname",
            "Fee_Master_Concession"."fmcC_ConcessionName",
            "Adm_M_Student"."AMST_Id",
            "Adm_M_Student"."AMST_AdmNo" AS "admno",
            "Adm_M_Student"."AMST_AdmNo",
            "Fee_Master_Head"."fmH_Id",
            "Adm_M_Student"."AMST_FatherName" AS "fathername",
            "Adm_M_Student"."AMST_MotherName" AS "mothername",
            "Adm_School_Y_Student"."AMAY_RollNo" AS "rollno",
            SUM("Fee_Master_Amount"."FMA_Amount") AS "fmA_Amount",
            "Fee_Master_Head"."FMH_Order",
            "Adm_School_M_Academic_Year"."ASMAY_Year"
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
        INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Master_Amount"."ASMAY_Id"
        INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id" 
            AND "Fee_Student_Status"."ASMAY_Id" = "Fee_Y_Payment_School_Student"."ASMAY_Id" 
            AND "Fee_T_Payment"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
        WHERE "Adm_M_Student"."AMST_Id" = p_AMST_Id::BIGINT
        AND "Fee_Y_Payment"."MI_Id" = p_MI_Id::BIGINT
        AND "Fee_Y_Payment"."ASMAY_ID" = v_NextAccYear::BIGINT
        AND "Fee_Student_Status"."FSS_OBArrearAmount" > 0
        AND "Fee_Student_Status"."FSS_PaidAmount" > 0
        AND "Adm_School_Y_Student"."ASMAY_ID" = v_NextAccYear::BIGINT
        AND "Adm_M_Student"."AMST_SOL" = 'S'
        GROUP BY 
            "Adm_M_Student"."AMST_FirstName",
            "Adm_M_Student"."AMST_MiddleName",
            "Adm_M_Student"."AMST_LastName",
            "Fee_Master_Head"."fmH_FeeName",
            "Adm_School_M_Class"."ASMCL_ClassName",
            "Adm_School_M_Section"."ASMC_SectionName",
            "Fee_Master_Concession"."fmcC_ConcessionName",
            "Adm_M_Student"."AMST_Id",
            "Fee_Master_Installment"."FMI_Name",
            "Adm_M_Student"."AMST_AdmNo",
            "Adm_M_Student"."AMST_RegistrationNo",
            "Fee_Master_Head"."fmH_Id",
            "Adm_M_Student"."AMST_FatherName",
            "Adm_M_Student"."AMST_MotherName",
            "Adm_School_Y_Student"."AMAY_RollNo",
            "Fee_Master_Amount"."FMA_Amount",
            "Fee_Master_Head"."FMH_Order",
            "Adm_School_M_Academic_Year"."ASMAY_Year"
        HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
        ORDER BY "Fee_Master_Head"."FMH_Order";
    END IF;
    
    RETURN;
END;
$$;