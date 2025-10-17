CREATE OR REPLACE FUNCTION "dbo"."Arrear_Register_Report"(
    "@ayar" bigint,
    "@miid" bigint,
    "@conditionflag" varchar,
    "@amstid" bigint,
    "@groupids" varchar,
    "@headsids" varchar
)
RETURNS TABLE(
    "AMST_FirstName" varchar,
    "AMST_AdmNo" varchar,
    "AMST_RegistrationNo" varchar,
    "ASMCL_ClassName" varchar,
    "AMST_MobileNo" varchar,
    "AMST_SOL" varchar,
    "ASMCL_Id" bigint,
    "fmh_id" bigint,
    "fti_id" bigint,
    "fmg_id" bigint,
    "fma_id" bigint,
    "asmay_id" bigint,
    "ftp_tobepaid_amt" numeric,
    "ftp_concession_amt" numeric,
    "paidamount" numeric,
    "ftp_waived_Amt" numeric,
    "ftp_rebate_amt" numeric,
    "Net_amount" numeric,
    "ftp_fine_amt" numeric,
    "RefundAmt" numeric,
    "Ftp_Chq_BON_amt" numeric,
    "FMH_FeeName" varchar,
    "ftp_stud_ob" numeric,
    "FMG_GroupName" varchar,
    "FMG_ActiceFlag" boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        "Adm_M_Student"."AMST_FirstName",
        "Adm_M_Student"."AMST_AdmNo",
        "Adm_M_Student"."AMST_RegistrationNo",
        "Adm_School_M_Class"."ASMCL_ClassName",
        "Adm_M_Student"."AMST_MobileNo",
        "Adm_M_Student"."AMST_SOL",
        "Fee_T_Stud_FeeStatus"."ASMCL_Id",
        "Fee_T_Stud_FeeStatus"."fmh_id",
        "Fee_T_Stud_FeeStatus"."fti_id",
        "Fee_T_Stud_FeeStatus"."fmg_id",
        "Fee_T_Stud_FeeStatus"."fma_id",
        "Fee_T_Stud_FeeStatus"."asmay_id",
        "Fee_T_Stud_FeeStatus"."ftp_tobepaid_amt",
        "Fee_T_Stud_FeeStatus"."ftp_concession_amt",
        "Fee_T_Stud_FeeStatus"."paidamount",
        "Fee_T_Stud_FeeStatus"."ftp_waived_Amt",
        "Fee_T_Stud_FeeStatus"."ftp_rebate_amt",
        "Fee_T_Stud_FeeStatus"."Net_amount",
        "Fee_T_Stud_FeeStatus"."ftp_fine_amt",
        "Fee_T_Stud_FeeStatus"."RefundAmt",
        "Fee_T_Stud_FeeStatus"."Ftp_Chq_BON_amt",
        "Fee_T_Stud_FeeStatus"."FMH_FeeName",
        "Fee_T_Stud_FeeStatus"."ftp_stud_ob",
        "Fee_Master_Group"."FMG_GroupName",
        "Fee_Master_Group"."FMG_ActiceFlag"
    FROM "dbo"."Adm_M_Student"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_M_Student"."ASMCL_Id"
    INNER JOIN "dbo"."Fee_Master_Group"
    INNER JOIN "dbo"."Fee_T_Stud_FeeStatus" ON "Fee_Master_Group"."FMG_Id" = "Fee_T_Stud_FeeStatus"."fmg_id"
        ON "Adm_M_Student"."AMST_Id" = "Fee_T_Stud_FeeStatus"."Amst_Id"
    WHERE ("Adm_M_Student"."AMST_SOL" = 'S')
        AND ("Adm_M_Student"."AMST_Id" = "@amstid")
        AND ("Fee_T_Stud_FeeStatus"."FMH_Id" IN (SELECT unnest(string_to_array("@headsids", ','))))
        AND ("Fee_T_Stud_FeeStatus"."fmg_id" IN (SELECT unnest(string_to_array("@groupids", ','))))
        AND ("Adm_M_Student"."ASMAY_Id" = "@ayar")
        AND ("Adm_M_Student"."MI_Id" = "@miid")
    ORDER BY "Fee_T_Stud_FeeStatus"."fti_id", "Fee_T_Stud_FeeStatus"."fma_id"
    LIMIT 100;
END;
$$;