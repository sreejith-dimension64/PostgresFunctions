CREATE OR REPLACE FUNCTION "dbo"."installmentwise_collection_report"(
    "fmg_id" TEXT,
    "fti_id" TEXT,
    "ASMAY_ID" VARCHAR(50),
    "type" VARCHAR(50),
    "option" VARCHAR(50),
    "active" VARCHAR(50),
    "deactive" VARCHAR(50),
    "left" VARCHAR(50),
    "mi_id" VARCHAR(50),
    "term_group" VARCHAR(1),
    "date1" TEXT,
    "date2" TEXT,
    "cheque" TEXT,
    "asmcl_id" TEXT,
    "amsc_id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "FTI_Id" BIGINT,
    "FTI_Name" TEXT,
    "Arrear" NUMERIC,
    "Excess" NUMERIC,
    "Balance" NUMERIC,
    "Paid" NUMERIC,
    "Payable" NUMERIC,
    "Concession" NUMERIC,
    "Charge" NUMERIC,
    "adjusted" NUMERIC,
    "StudentName" TEXT,
    "ASMCL_ClassName" TEXT,
    "AMST_AdmNo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "str1" TEXT;
    "amst_sol" TEXT;
    "date" TEXT;
    "query" TEXT;
BEGIN
    "str1" := ' ';
    
    IF "type" = 'year' THEN
        "date" := '';
    ELSE
        "date" := 'and "dbo"."Fee_Y_Payment"."fyp_date"::date between TO_DATE(''' || "date1" || ''',''DD-MM-YYYY'') and TO_DATE(''' || "date2" || ''',''DD-MM-YYYY'') and "FYP_Bank_Or_Cash"=''C''';
    END IF;
    
    IF "active" = '1' AND "deactive" = '0' AND "left" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1) and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "deactive" = '1' AND "active" = '0' AND "left" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1) and ("Adm_M_Student"."AMST_SOL"=''D'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=0) and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=0)';
    ELSIF "left" = '1' AND "active" = '1' AND "deactive" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1)) and ("Adm_M_Student"."AMST_SOL" in (''L'',''S'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '1' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1)) and ("Adm_M_Student"."AMST_SOL" in (''L'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF "left" = '0' AND "active" = '1' AND "deactive" = '1' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (1)) and ("Adm_M_Student"."AMST_SOL" in (''S'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(1))';
    ELSIF "active" = '1' AND "deactive" = '1' AND "left" = '1' THEN
        "amst_sol" := 'and ("Adm_M_Student"."AMST_SOL" IN (''S'',''D'',''L'')) ';
    END IF;
    
    "query" := 'select distinct "Adm_M_Student"."AMST_Id","Fee_T_Installment"."FTI_Id","Fee_T_Installment"."FTI_Name", sum("Fee_Student_Status"."FSS_OBArrearAmount") "Arrear",sum("Fee_Student_Status"."FSS_OBExcessAmount") "Excess",sum("Fee_Student_Status"."FSS_ToBePaid") "Balance",
    (SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount")-SUM("dbo"."Fee_Student_Status"."FSS_FineAmount"))"Paid",
    sum("Fee_Student_Status"."FSS_TotalToBePaid") as "Payable",sum("Fee_Student_Status"."FSS_ConcessionAmount")as "Concession",sum("Fee_Student_Status"."FSS_CurrentYrCharges") "Charge",
    SUM("Fee_Student_Status"."FSS_AdjustedAmount") AS "adjusted",
    (COALESCE("AMST_FirstName",'' '')|| '' ''||COALESCE("AMST_MiddleName",'' '')|| '' '' ||COALESCE("AMST_LastName",'' '')) "StudentName", "ASMCL_ClassName" ||'':''||"ASMC_SectionName" as "ASMCL_ClassName",
    "Adm_M_Student"."AMST_AdmNo" FROM "Fee_Student_Status"
    INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id"="Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id"
    INNER JOIN "Fee_T_Installment" ON "Fee_Student_Status"."FTI_Id"="Fee_T_Installment"."FTI_Id"
    INNER JOIN "fee_y_payment_school_student" ON "fee_y_payment_school_student"."amst_id"="Adm_School_Y_Student"."amst_id" AND "fee_y_payment_school_student"."ASMAY_Id"=' || "ASMAY_ID" || '
    INNER JOIN "fee_y_payment" ON "fee_y_payment"."fyp_id"="fee_y_payment_school_student"."fyp_id" AND "fee_y_payment"."MI_Id"=' || "mi_id" || ' AND "fee_y_payment"."ASMAY_Id"=' || "ASMAY_ID" || '
    where "Fee_Student_Status"."MI_Id"=' || "mi_id" || ' and "Adm_M_Student"."MI_Id"=' || "mi_id" || ' and "Fee_Student_Status"."ASMAY_Id"=' || "ASMAY_ID" || ' and "Adm_School_Y_Student"."ASMAY_Id"=' || "ASMAY_ID" || ' and "Adm_School_M_Section"."MI_Id"=' || "mi_id" || ' and "Adm_School_M_Section"."MI_Id"=' || "mi_id" || ' and "Fee_T_Installment"."FTI_Id" in (' || "fti_id" || ') and "Fee_T_Installment"."MI_ID"=' || "mi_id" || ' and "Fee_Student_Status"."FMG_Id" in (' || "fmg_id" || ') ' || "date" || ' ' || "amst_sol" || '
    group by "Adm_M_Student"."AMST_Id","Fee_T_Installment"."FTI_Id","Fee_T_Installment"."FTI_Name","Adm_M_Student"."AMST_FirstName","Adm_M_Student"."AMST_MiddleName","Adm_M_Student"."AMST_LastName","ASMCL_ClassName","ASMC_SectionName","Adm_M_Student"."AMST_AdmNo"
    order by "Fee_T_Installment"."FTI_Id","StudentName"';
    
    RETURN QUERY EXECUTE "query";
    
END;
$$;