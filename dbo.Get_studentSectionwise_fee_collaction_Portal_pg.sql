CREATE OR REPLACE FUNCTION "dbo"."Get_studentSectionwise_fee_collaction_Portal"(
    p_MI_Id INT,
    p_ASMAY_Id INT,
    p_ASMCL_Id INT,
    p_ASMS_Id INT
)
RETURNS TABLE(
    "StudentName" TEXT,
    "callected" NUMERIC,
    "ballance" NUMERIC,
    "concession" NUMERIC,
    "waived" NUMERIC,
    "rebate" NUMERIC,
    "fine" NUMERIC,
    "class" VARCHAR,
    "classid" INT,
    "sectionid" INT,
    "sectionname" VARCHAR,
    "receivable" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        (COALESCE("AMST_FirstName", '') || ' ' || COALESCE("AMST_MiddleName", '') || ' ' || COALESCE("AMST_LastName", '') || '-' || "AMST_AdmNo")::TEXT AS "StudentName",
        (SUM("fee_student_status"."FSS_PaidAmount") - SUM("fee_student_status"."FSS_FineAmount"))::NUMERIC AS "callected",
        SUM("fee_student_status"."FSS_ToBePaid")::NUMERIC AS "ballance",
        SUM("fee_student_status"."FSS_ConcessionAmount")::NUMERIC AS "concession",
        SUM("fee_student_status"."FSS_WaivedAmount")::NUMERIC AS "waived",
        SUM("fee_student_status"."FSS_RebateAmount")::NUMERIC AS "rebate",
        SUM("fee_student_status"."FSS_FineAmount")::NUMERIC AS "fine",
        "Adm_School_M_Class"."ASMCL_ClassName" AS "class",
        "Adm_School_M_Class"."ASMCL_Id" AS "classid",
        "Adm_School_M_Section"."ASMS_Id" AS "sectionid",
        "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname",
        (SUM("fee_student_status"."FSS_CurrentYrCharges") + SUM("fee_student_status"."FSS_OBArrearAmount"))::NUMERIC AS "receivable"
    FROM "dbo"."fee_student_status"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "dbo"."Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id"
    INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id"
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE ("Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id)
        AND ("fee_student_status"."MI_Id" = p_MI_Id)
        AND ("fee_student_status"."ASMAY_Id" = p_ASMAY_Id)
        AND ("Adm_School_Y_Student"."ASMCL_Id" = p_ASMCL_Id)
        AND ("Adm_M_Student"."AMST_SOL" = 'S')
        AND ("Adm_School_Y_Student"."AMAY_ActiveFlag" = 1)
        AND ("Adm_School_Y_Student"."ASMS_Id" = p_ASMS_Id)
    GROUP BY 
        "Adm_School_M_Section"."ASMS_Id",
        "Adm_School_M_Class"."ASMCL_Id",
        "Adm_School_M_Class"."ASMCL_ClassName",
        "Adm_School_M_Section"."ASMC_SectionName",
        "AMST_FirstName",
        "AMST_MiddleName",
        "AMST_LastName",
        "AMST_AdmNo"
    ORDER BY "Adm_School_M_Section"."ASMS_Id";

END;
$$;