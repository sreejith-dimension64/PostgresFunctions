CREATE OR REPLACE FUNCTION "FinalacialYearEndDatebkp"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_DynamicD1 TEXT;
    v_test TEXT;
    v_DynamicD3 TEXT;
    v_PASMAY_year VARCHAR(40);
    v_ASMAY_Order INT;
    v_PFYEndDate VARCHAR(10);
    v_CASMAY_Year VARCHAR(10);
    v_CFYStartDate VARCHAR(10);
    v_CFYEndDate VARCHAR(10);
    v_FAMST_Id BIGINT;
    v_asonduedate_S DATE;
    v_asonduedate_N VARCHAR(10);
    v_Rcount INT;
    v_FYRcount INT;
    v_handle INT;
BEGIN

    SELECT "ASMAY_year", "ASMAY_Order", TO_CHAR("ASMAY_FYEndDate", 'YYYY-MM-DD')
    INTO v_PASMAY_year, v_ASMAY_Order, v_PFYEndDate
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT;

    SELECT "ASMAY_FYStartDate", "ASMAY_FYEndDate"
    INTO v_CFYStartDate, v_CFYEndDate
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Order" = v_ASMAY_Order + 1;

    v_test := 'SELECT "Fee_Y_Payment_School_Student"."AMST_Id",
        "Adm_M_Student"."AMST_Admno" AS admno,
        SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "TotalPaid",
        COALESCE("Adm_M_Student"."AMST_FirstName", '' '') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '' '') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '' '') AS "StudentName",
        ("Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName") AS "ClassSection"
    FROM "Fee_Y_Payment_School_Student"
    INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
    INNER JOIN "Adm_M_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
        AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "Fee_T_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
    INNER JOIN "Fee_Master_Amount" ON "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Master_Amount"."FMH_Id" 
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Master_Amount"."FTI_Id"
    INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
    INNER JOIN "Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Master_Amount"."FMG_Id"
    WHERE "Fee_Y_Payment"."MI_Id" = ' || p_MI_Id || ' 
        AND "Adm_M_Student"."MI_Id" = ' || p_MI_Id || ' 
        AND "Adm_School_M_Class"."MI_Id" = ' || p_MI_Id || ' 
        AND "FYP_Chq_Bounce" <> ''CB'' 
        AND "FYP_Chq_Bounce" = ''CL''
        AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
        AND "Fee_Y_Payment"."ASMAY_Id" = ' || p_ASMAY_Id || '
        AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
        AND "Adm_School_M_Section"."MI_Id" = ' || p_MI_Id || '
        AND "Fee_Master_Terms_FeeHeads"."MI_Id" = ' || p_MI_Id || '
        AND "Fee_Master_Group"."MI_Id" = ' || p_MI_Id || '
    GROUP BY "Fee_Y_Payment_School_Student"."AMST_Id", "AMST_Admno", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "ASMCL_ClassName", "ASMC_SectionName"';

    EXECUTE v_test;

END;
$$;