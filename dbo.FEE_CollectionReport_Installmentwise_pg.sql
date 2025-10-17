CREATE OR REPLACE FUNCTION "FEE_CollectionReport_Installmentwise"(
    p_mi_id TEXT,
    p_ASMAY_ID TEXT,
    p_asmcl_id TEXT,
    p_asms_id TEXT,
    p_fmg_id TEXT,
    p_fti_id TEXT
)
RETURNS TABLE(
    "StudentName" TEXT,
    "ASMCL_ClassName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "FSS_PaidAmount" NUMERIC,
    "balance" NUMERIC,
    "concession" NUMERIC,
    "waived" NUMERIC,
    "rebate" NUMERIC,
    "fine" NUMERIC,
    "totalpayable" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
    v_str1 TEXT;
BEGIN
    
    IF (p_asmcl_id != '0' AND p_asms_id != '0') THEN
        v_str1 := 'and "Adm_School_M_Class"."ASMCL_Id"=' || p_asmcl_id || ' and ("Adm_School_M_Section"."ASMS_Id"= ' || p_asms_id || ')';
    ELSE
        v_str1 := ' ';
    END IF;
    
    v_query := 'SELECT (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''')) AS "StudentName",
    "Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName" as "ASMCL_ClassName",
    "Adm_M_Student"."AMST_AdmNo",
    (SUM("fee_student_status"."FSS_PaidAmount") - SUM("fee_student_status"."FSS_FineAmount")) AS "FSS_PaidAmount",
    SUM("fee_student_status"."FSS_ToBePaid") AS "balance",
    SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession",
    SUM("fee_student_status"."FSS_WaivedAmount") AS "waived",
    SUM("fee_student_status"."FSS_RebateAmount") AS "rebate",
    SUM("fee_student_status"."FSS_FineAmount") AS "fine",
    SUM("fee_student_status"."FSS_CurrentYrCharges") AS "totalpayable"
    FROM "fee_student_status"
    INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
    INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id"
    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" and "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
    INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE ("fee_student_status"."MI_Id" = ' || p_mi_id || ') AND ("Adm_M_Student"."MI_Id" = ' || p_mi_id || ') AND ("Adm_School_M_Class"."MI_Id" = ' || p_mi_id || ') AND ("Fee_Master_Group"."MI_Id" = ' || p_mi_id || ') AND ("Fee_Master_Head"."MI_Id" = ' || p_mi_id || ') AND ("Fee_T_Installment"."MI_Id" = ' || p_mi_id || ') AND ("Fee_Master_Terms_FeeHeads"."MI_Id" = ' || p_mi_id || ') AND ("Adm_School_M_Section"."MI_Id" = ' || p_mi_id || ') and
    ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND ("fee_student_status"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("Fee_Master_Group"."FMG_Id" in (' || p_fmg_id || '))
    and ("Fee_T_Installment"."FTI_ID" IN (' || p_fti_id || ')) AND ("Adm_M_Student"."AMST_SOL" = ''S'') ' || v_str1 || '
    GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName"
    HAVING SUM("fee_student_status"."FSS_PaidAmount") > 0 or SUM("fee_student_status"."FSS_ToBePaid") > 0 or SUM("fee_student_status"."FSS_ConcessionAmount") > 0 or SUM("fee_student_status"."FSS_WaivedAmount") > 0 or SUM("fee_student_status"."FSS_RebateAmount") > 0 or
    SUM("fee_student_status"."FSS_FineAmount") > 0 or SUM("fee_student_status"."FSS_CurrentYrCharges") > 0';
    
    RETURN QUERY EXECUTE v_query;
    
END;
$$;