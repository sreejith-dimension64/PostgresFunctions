CREATE OR REPLACE FUNCTION "dbo"."Fee_school_CardAmount"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_FMG_Id text,
    p_FMT_Id text
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "StudentName" text,
    "ASMCL_ClassName" text,
    "AMST_AdmNo" varchar,
    "FSS_PaidAmount" numeric,
    "balance" numeric,
    "concession" numeric,
    "waived" numeric,
    "rebate" numeric,
    "fine" numeric,
    "totalpayable" numeric,
    "CardAmount" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlquery text;
BEGIN
    DROP TABLE IF EXISTS "FeeWithoutcardAmount";
    DROP TABLE IF EXISTS "FeeWithcardAmount";

    v_sqlquery := '
    CREATE TEMP TABLE "FeeWithoutcardAmount" AS
    SELECT  "Adm_M_Student"."AMST_Id",
    (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || ''  '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || ''  '' || COALESCE("Adm_M_Student"."AMST_LastName",'''')) AS "StudentName",
    "Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName" AS "ASMCL_ClassName",
    "Adm_M_Student"."AMST_AdmNo",
    (SUM("fee_student_status"."FSS_PaidAmount") - SUM("fee_student_status"."FSS_FineAmount")) AS "FSS_PaidAmount",
    SUM("fee_student_status"."FSS_ToBePaid") AS balance, 
    SUM("fee_student_status"."FSS_ConcessionAmount") AS concession,
    SUM("fee_student_status"."FSS_WaivedAmount") AS waived,
    SUM("fee_student_status"."FSS_RebateAmount") AS rebate,
    SUM("fee_student_status"."FSS_FineAmount") AS fine,
    SUM("fee_student_status"."FSS_CurrentYrCharges") AS totalpayable
    FROM "fee_student_status" 
    INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
    INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
    INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"  
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id"  
    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id"  
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"  
    WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
    AND "fee_student_status"."MI_Id" = ' || p_MI_Id || ' 
    AND "fee_student_status"."ASMAY_Id" = ' || p_ASMAY_Id || '
    AND "Fee_Master_Group"."FMG_Id" IN (' || p_FMG_Id || ')
    AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_FMT_Id || ')
    GROUP BY "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", 
        "Adm_M_Student"."AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_M_Class"."ASMCL_ClassName", 
        "Adm_School_M_Section"."ASMC_SectionName" 
    HAVING ((SUM("fee_student_status"."FSS_PaidAmount") - SUM("fee_student_status"."FSS_FineAmount")) > 0) 
        OR (SUM("fee_student_status"."FSS_ToBePaid") > 0) 
        OR (SUM("fee_student_status"."FSS_ConcessionAmount") > 0) 
        OR (SUM("fee_student_status"."FSS_WaivedAmount") > 0) 
        OR (SUM("fee_student_status"."FSS_RebateAmount") > 0) 
        OR (SUM("fee_student_status"."FSS_FineAmount") > 0) 
        OR (SUM("fee_student_status"."FSS_CurrentYrCharges") > 0)';

    EXECUTE v_sqlquery;

    v_sqlquery := '
    CREATE TEMP TABLE "FeeWithcardAmount" AS
    SELECT  "Adm_M_Student"."AMST_Id",
    (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || ''  '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || ''  '' || COALESCE("Adm_M_Student"."AMST_LastName",'''')) AS "StudentName",
    "Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName" AS "ASMCL_ClassName",
    "Adm_M_Student"."AMST_AdmNo",
    (SUM("fee_student_status"."FSS_PaidAmount") - SUM("fee_student_status"."FSS_FineAmount")) AS "FSS_PaidAmount",
    SUM("fee_student_status"."FSS_ToBePaid") AS balance, 
    SUM("fee_student_status"."FSS_ConcessionAmount") AS concession,
    SUM("fee_student_status"."FSS_WaivedAmount") AS waived,
    SUM("fee_student_status"."FSS_RebateAmount") AS rebate,
    SUM("fee_student_status"."FSS_FineAmount") AS fine,
    SUM("fee_student_status"."FSS_CurrentYrCharges") AS totalpayable
    FROM "fee_student_status" 
    INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
    INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
    INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"  
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id"  
    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id"  
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" 
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"  
    WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_Id || '
    AND "fee_student_status"."MI_Id" = ' || p_MI_Id || ' 
    AND "fee_student_status"."ASMAY_Id" = ' || p_ASMAY_Id || '
    AND "Fee_Master_Group"."FMG_Id" IN (' || p_FMG_Id || ')
    AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_FMT_Id || ') 
    AND "Fee_Master_Head"."FMH_Id" = 152  
    GROUP BY "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", 
        "Adm_M_Student"."AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_M_Class"."ASMCL_ClassName", 
        "Adm_School_M_Section"."ASMC_SectionName" 
    HAVING ((SUM("fee_student_status"."FSS_PaidAmount") - SUM("fee_student_status"."FSS_FineAmount")) > 0) 
        OR (SUM("fee_student_status"."FSS_ToBePaid") > 0) 
        OR (SUM("fee_student_status"."FSS_ConcessionAmount") > 0) 
        OR (SUM("fee_student_status"."FSS_WaivedAmount") > 0) 
        OR (SUM("fee_student_status"."FSS_RebateAmount") > 0) 
        OR (SUM("fee_student_status"."FSS_FineAmount") > 0) 
        OR (SUM("fee_student_status"."FSS_CurrentYrCharges") > 0)';

    EXECUTE v_sqlquery;

    RETURN QUERY
    SELECT A."AMST_Id", A."StudentName", A."ASMCL_ClassName", A."AMST_AdmNo", 
           A."FSS_PaidAmount", A.balance, A.concession, A.waived, A.rebate, A.fine, A.totalpayable,
           COALESCE(B."FSS_PaidAmount", 0) AS "CardAmount"
    FROM "FeeWithoutcardAmount" A 
    LEFT JOIN "FeeWithcardAmount" B ON A."AMST_Id" = B."AMST_Id";

    RETURN;
END;
$$;