CREATE OR REPLACE FUNCTION "dbo"."FeeArrear_Register_Report"(
    "ayar" BIGINT,
    "miid" BIGINT,
    "conditionflag" VARCHAR(100),
    "amstid" BIGINT,
    "groupids" VARCHAR,
    "headsids" VARCHAR,
    "datevalue" VARCHAR(10)
)
RETURNS TABLE(
    "AMST_FirstName" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "AMST_MobileNo" VARCHAR,
    "AMST_SOL" VARCHAR,
    "ASMCL_Id" BIGINT,
    "fmh_id" BIGINT,
    "fti_id" BIGINT,
    "fmg_id" BIGINT,
    "fma_id" BIGINT,
    "asmay_id" BIGINT,
    "ftp_tobepaid_amt" NUMERIC,
    "paidamount" NUMERIC,
    "ftp_concession_amt" NUMERIC,
    "ftp_waived_Amt" NUMERIC,
    "ftp_rebate_amt" NUMERIC,
    "ftp_fine_amt" NUMERIC,
    "Net_amount" NUMERIC,
    "RefundAmt" NUMERIC,
    "ftp_stud_ob" NUMERIC,
    "Expr1" BIGINT,
    "FYP_Remarks" TEXT,
    "fypDate" TIMESTAMP,
    "PayMode" VARCHAR,
    "FYP_DD_Cheque_Date" TIMESTAMP,
    "FMH_FeeName" VARCHAR,
    "FTI_Name" VARCHAR,
    "FMG_GroupName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMCL_ClassName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "conditionflag" = 'Individual' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "Adm_M_Student"."AMST_FirstName",
            "Adm_M_Student"."AMST_RegistrationNo",
            "Adm_M_Student"."AMST_AdmNo",
            "Adm_M_Student"."AMST_MobileNo",
            "Adm_M_Student"."AMST_SOL",
            "Fee_T_Stud_FeeStatus"."ASMCL_Id",
            "Fee_T_Stud_FeeStatus"."fmh_id",
            "Fee_T_Stud_FeeStatus"."fti_id",
            "Fee_T_Stud_FeeStatus"."fmg_id",
            "Fee_T_Stud_FeeStatus"."fma_id",
            "Fee_T_Stud_FeeStatus"."asmay_id",
            "Fee_T_Stud_FeeStatus"."ftp_tobepaid_amt",
            "Fee_T_Stud_FeeStatus"."paidamount",
            "Fee_T_Stud_FeeStatus"."ftp_concession_amt",
            "Fee_T_Stud_FeeStatus"."ftp_waived_Amt",
            "Fee_T_Stud_FeeStatus"."ftp_rebate_amt",
            "Fee_T_Stud_FeeStatus"."ftp_fine_amt",
            "Fee_T_Stud_FeeStatus"."Net_amount",
            "Fee_T_Stud_FeeStatus"."RefundAmt",
            "Fee_T_Stud_FeeStatus"."ftp_stud_ob",
            "Fee_Yearly_Group"."FMG_Id" AS "Expr1",
            "Fee_Y_Payment"."FYP_Remarks",
            "Fee_Y_Payment"."FYP_Date" AS "fypDate",
            "Fee_Y_Payment"."FYP_Bank_Or_Cash" AS "PayMode",
            "Fee_Y_Payment"."FYP_DD_Cheque_Date",
            "Fee_T_Stud_FeeStatus"."FMH_FeeName",
            "Fee_T_Stud_FeeStatus"."FTI_Name",
            "Fee_Master_Group"."FMG_GroupName",
            "Adm_School_M_Section"."ASMC_SectionName",
            "Adm_School_M_Class"."ASMCL_ClassName"
        FROM "dbo"."Fee_T_Stud_FeeStatus"
        INNER JOIN "dbo"."Fee_Yearly_Group"
            INNER JOIN "dbo"."Fee_Master_Group" 
                ON "Fee_Yearly_Group"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
            ON "Fee_T_Stud_FeeStatus"."fmg_id" = "Fee_Yearly_Group"."FMG_Id"
        INNER JOIN "dbo"."Adm_M_Student" 
            ON "Fee_T_Stud_FeeStatus"."Amst_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment" 
            ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        WHERE "Adm_M_Student"."AMST_SOL" = 'S' 
            AND "Fee_T_Stud_FeeStatus"."fmg_id" IS NOT NULL 
            AND "Fee_Y_Payment_School_Student"."AMST_Id" = "amstid"
            AND TO_TIMESTAMP("Fee_Y_Payment"."FYP_Date"::TEXT, 'DD/MM/YYYY') <= TO_TIMESTAMP("datevalue", 'DD/MM/YYYY')
            AND "Fee_T_Stud_FeeStatus"."fmh_id"::TEXT = ANY(STRING_TO_ARRAY("headsids", ','))
            AND "Fee_T_Stud_FeeStatus"."fmg_id"::TEXT = ANY(STRING_TO_ARRAY("groupids", ','))
            AND "Adm_M_Student"."ASMAY_Id" = "ayar"
            AND "Adm_M_Student"."MI_Id" = "miid"
        ORDER BY "Fee_T_Stud_FeeStatus"."fmg_id", "Fee_T_Stud_FeeStatus"."fma_id", "Fee_T_Stud_FeeStatus"."fti_id"
        LIMIT 100;
    END IF;
    
    RETURN;
END;
$$;