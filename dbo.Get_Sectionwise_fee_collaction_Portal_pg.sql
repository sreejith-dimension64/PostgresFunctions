CREATE OR REPLACE FUNCTION "dbo"."Get_Sectionwise_fee_collaction_Portal"(
    p_MI_Id INT,
    p_ASMAY_Id INT,
    p_ASMCL_Id INT
)
RETURNS TABLE(
    callected NUMERIC,
    ballance NUMERIC,
    concession NUMERIC,
    waived NUMERIC,
    rebate NUMERIC,
    fine NUMERIC,
    class VARCHAR,
    classid INT,
    sectionid INT,
    sectionname VARCHAR,
    receivable NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        (SUM("dbo"."fee_student_status"."FSS_PaidAmount") - SUM("dbo"."fee_student_status"."FSS_FineAmount"))::NUMERIC AS callected,
        SUM("dbo"."fee_student_status"."FSS_ToBePaid")::NUMERIC AS ballance,
        SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount")::NUMERIC AS concession,
        SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount")::NUMERIC AS waived,
        SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount")::NUMERIC AS rebate,
        SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")::NUMERIC AS fine,
        "dbo"."Adm_School_M_Class"."ASMCL_ClassName" AS class,
        "dbo"."Adm_School_M_Class"."ASMCL_Id" AS classid,
        "dbo"."Adm_School_M_Section"."ASMS_Id" AS sectionid,
        "dbo"."Adm_School_M_Section"."ASMC_SectionName" AS sectionname,
        SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges")::NUMERIC AS receivable
    FROM "dbo"."fee_student_status"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."fee_student_status"."Amst_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."fee_student_status"."fmg_id" = "dbo"."Fee_Master_Group"."FMG_Id"
    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."fee_student_status"."FMH_Id"
    INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."fee_student_status"."FTI_Id"
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."fee_student_status"."FMH_Id" 
        AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."fee_student_status"."FTI_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_M_Section"."ASMS_Id" = "dbo"."Adm_School_Y_Student"."ASMS_Id"
    WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id)
        AND ("dbo"."fee_student_status"."MI_Id" = p_MI_Id)
        AND ("dbo"."fee_student_status"."ASMAY_Id" = p_ASMAY_Id)
        AND ("dbo"."Adm_School_Y_Student"."ASMCL_Id" = p_ASMCL_Id)
    GROUP BY "dbo"."Adm_School_M_Section"."ASMS_Id",
        "dbo"."Adm_School_M_Class"."ASMCL_Id",
        "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
        "dbo"."Adm_School_M_Section"."ASMC_SectionName"
    ORDER BY "dbo"."Adm_School_M_Section"."ASMS_Id";
END;
$$;