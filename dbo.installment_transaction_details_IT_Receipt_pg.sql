CREATE OR REPLACE FUNCTION "dbo"."installment_transaction_details_IT_Receipt"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_Amst_id" TEXT
)
RETURNS TABLE(
    "amsT_FirstName" TEXT,
    "fmH_FeeName" VARCHAR,
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
    AND "ASMAY_Id" = "p_ASMAY_Id"::BIGINT;

    IF "v_curryearorder" = "v_selectedcurryearorder" THEN

        RETURN QUERY
        SELECT "Adm_M_Student"."amsT_FirstName" || '' || "Adm_M_Student"."amsT_MiddleName" || ' ' || "Adm_M_Student"."amsT_LastName" AS "amsT_FirstName",
               "Fee_Master_Head"."fmH_FeeName",
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
               AND "Fee_Student_Status"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
               AND "Fee_Student_Status"."ASMAY_Id" = "Fee_Master_Amount"."ASMAY_Id"
        WHERE "Adm_M_Student"."AMST_Id" = "p_Amst_id"::BIGINT
          AND "Fee_Y_Payment"."MI_Id" = "p_MI_Id"::BIGINT
          AND "Fee_Y_Payment"."ASMAY_ID" = "p_ASMAY_Id"::BIGINT
          AND "Adm_School_Y_Student"."ASMAY_ID" = "p_ASMAY_Id"::BIGINT
          AND "Adm_M_Student"."AMST_SOL" = 'S'
        GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName",
                 "Fee_Master_Head"."fmH_FeeName", "Adm_School_M_Class"."ASMCL_ClassName",
                 "Adm_School_M_Section"."ASMC_SectionName", "Fee_Master_Concession"."fmcC_ConcessionName",
                 "Adm_M_Student"."AMST_Id", "Fee_Master_Installment"."FMI_Name", "Adm_M_Student"."AMST_AdmNo",
                 "Adm_M_Student"."AMST_RegistrationNo", "Fee_Master_Head"."fmH_Id", "Adm_M_Student"."AMST_FatherName",
                 "Adm_M_Student"."AMST_MotherName", "Adm_School_Y_Student"."AMAY_RollNo", "Fee_Master_Amount"."FMA_Amount",
                 "Fee_Master_Head"."FMH_Order", "Adm_School_M_Academic_Year"."ASMAY_Year"
        HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
        ORDER BY "Fee_Master_Head"."FMH_Order";

    ELSE

        RETURN QUERY
        SELECT "Adm_M_Student"."amsT_FirstName" || '' || "Adm_M_Student"."amsT_MiddleName" || ' ' || "Adm_M_Student"."amsT_LastName" AS "amsT_FirstName",
               "Fee_Master_Head"."fmH_FeeName",
               SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "ftP_Paid_Amt",
               SUM("Fee_T_Payment"."FTP_Concession_Amt") AS "ftP_Concession_Amt",
               SUM("Fee_T_Payment"."FTP_Fine_Amt") AS "ftP_Fine_Amt",
               "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
               "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname",
               "Fee_Master_Concession"."fmcC_ConcessionName",
               "Adm_M_Student"."AMST_Id",
               "Adm_M_Student"."AMST_AdmNo" AS "admno",
               "Adm_M_Student"."AMST_RegistrationNo" AS "AMST_AdmNo",
               "Fee_Master_Head"."fmH_Id",
               "Adm_M_Student"."AMST_FatherName" AS "fathername",
               "Adm_M_Student"."AMST_MotherName" AS "mothername",
               "Adm_School_Y_Student"."AMAY_RollNo" AS "rollno",
               "Fee_Master_Amount"."FMA_Amount" AS "fmA_Amount",
               "Fee_Master_Head"."FMH_Order",
               NULL::VARCHAR AS "ASMAY_Year"
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
        WHERE "Adm_M_Student"."AMST_Id" = "p_Amst_id"::BIGINT
          AND "Fee_Y_Payment"."MI_Id" = "p_MI_Id"::BIGINT
          AND "Fee_Y_Payment"."ASMAY_ID" = "p_ASMAY_Id"::BIGINT
          AND "Adm_M_Student"."AMST_SOL" = 'S'
        GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName",
                 "Fee_Master_Head"."fmH_FeeName", "Adm_School_M_Class"."ASMCL_ClassName",
                 "Adm_School_M_Section"."ASMC_SectionName", "Fee_Master_Concession"."fmcC_ConcessionName",
                 "Adm_M_Student"."AMST_Id", "Fee_Master_Installment"."FMI_Name", "Adm_M_Student"."AMST_AdmNo",
                 "Adm_M_Student"."AMST_RegistrationNo", "Fee_Master_Head"."fmH_Id", "Adm_M_Student"."AMST_FatherName",
                 "Adm_M_Student"."AMST_MotherName", "Adm_School_Y_Student"."AMAY_RollNo", "Fee_Master_Amount"."FMA_Amount",
                 "Fee_Master_Head"."FMH_Order"
        HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
        ORDER BY "Fee_Master_Head"."FMH_Order"
        LIMIT 1;

    END IF;

    RETURN;

END;
$$;