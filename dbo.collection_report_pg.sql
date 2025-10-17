CREATE OR REPLACE FUNCTION "dbo"."collection_report"(
    "fmg_id" TEXT,
    "fmt_id" TEXT,
    "ASMAY_ID" VARCHAR(50),
    "type" VARCHAR(50),
    "option" VARCHAR(50),
    "active" VARCHAR(50),
    "deactive" VARCHAR(50),
    "left" VARCHAR(50),
    "date1" TEXT,
    "date2" TEXT,
    "mi_id" VARCHAR(50),
    "term_group" VARCHAR(1),
    "cheque" TEXT
)
RETURNS TABLE(
    "StudentName" TEXT,
    "ASMCL_ClassName" TEXT,
    "AMST_AdmNo" TEXT,
    "FSS_PaidAmount" NUMERIC,
    "balance" NUMERIC,
    "concession" NUMERIC,
    "waived" NUMERIC,
    "rebate" NUMERIC,
    "fine" NUMERIC,
    "totalpayable" NUMERIC,
    "FMG_GroupName" TEXT,
    "FMH_FeeName" TEXT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "FMCC_ClassCategoryName" TEXT,
    "fmh_feename" TEXT,
    "ByBank" NUMERIC,
    "ByCash" NUMERIC,
    "ByOnline" NUMERIC,
    "ByCard" NUMERIC,
    "ByECS" NUMERIC,
    "ByRTGS" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "amst_sol" TEXT;
    "mi" BIGINT;
    "dt" BIGINT;
    "mt" BIGINT;
    "ftdd_day" BIGINT;
    "ftdd_month" BIGINT;
    "endyr" BIGINT;
    "startyr" BIGINT;
    "duedate" TIMESTAMP;
    "duedate1" TIMESTAMP;
    "fromdate" TIMESTAMP;
    "todate" TIMESTAMP;
    "oResult" VARCHAR(50);
    "days" VARCHAR(50);
    "months" VARCHAR(50);
    "query" TEXT;
    "date" TEXT;
    "asmay_new" BIGINT;
BEGIN
    "amst_sol" := '';
    "mi" := 0;
    "ftdd_day" := 0;
    "ftdd_month" := 0;
    "endyr" := 0;
    "startyr" := 0;
    "days" := '0';
    "months" := '0';
    "dt" := 0;
    "mt" := 0;

    IF "cheque" = '1' THEN
        "date" := 'CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''',''DD/MM/YYYY'') AND "FYP_Bank_Or_Cash"=''C''';
    ELSIF "cheque" = '2' THEN
        "date" := 'CAST("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''',''DD/MM/YYYY'') AND "FYP_Bank_Or_Cash"=''B''';
    ELSIF "cheque" = '3' THEN
        "date" := '((CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''',''DD/MM/YYYY'')))';
    ELSIF "cheque" = '4' THEN
        "date" := '((CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''',''DD/MM/YYYY'') AND "FYP_Bank_Or_Cash"=''C'') OR ((CAST("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''',''DD/MM/YYYY''))AND "FYP_Bank_Or_Cash"=''B''))';
    END IF;

    SELECT "MI_Id" INTO "mi" FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = "ASMAY_ID"::BIGINT;

    IF "active" = '1' AND "deactive" = '0' AND "left" = '0' THEN
        "amst_sol" := 'AND ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1) AND ("Adm_M_Student"."AMST_SOL"=''S'') AND ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "deactive" = '1' AND "active" = '0' AND "left" = '0' THEN
        "amst_sol" := 'AND ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1) AND ("Adm_M_Student"."AMST_SOL"=''D'') AND ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '0' THEN
        "amst_sol" := 'AND ("Adm_School_Y_Student"."AMAY_ActiveFlag"=0) AND ("Adm_M_Student"."AMST_SOL"=''L'') AND ("Adm_M_Student"."AMST_ActiveFlag"=0)';
    ELSIF "left" = '1' AND "active" = '1' AND "deactive" = '0' THEN
        "amst_sol" := 'AND ("Adm_School_Y_Student"."AMAY_ActiveFlag" IN (0,1)) AND ("Adm_M_Student"."AMST_SOL" IN (''L'',''S'')) AND ("Adm_M_Student"."AMST_ActiveFlag" IN (0,1))';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '1' THEN
        "amst_sol" := 'AND ("Adm_School_Y_Student"."AMAY_ActiveFlag" IN (0,1)) AND ("Adm_M_Student"."AMST_SOL" IN (''L'',''D'')) AND ("Adm_M_Student"."AMST_ActiveFlag" IN (0,1))';
    ELSIF "left" = '0' AND "active" = '1' AND "deactive" = '1' THEN
        "amst_sol" := 'AND ("Adm_School_Y_Student"."AMAY_ActiveFlag" IN (1)) AND ("Adm_M_Student"."AMST_SOL" IN (''S'',''D'')) AND ("Adm_M_Student"."AMST_ActiveFlag" IN (1))';
    END IF;

    IF "type" = 'year' THEN
        IF "option" = 'FSW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'' ''))::TEXT AS "StudentName", ("dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName")::TEXT AS "ASMCL_ClassName", "Adm_M_Student"."AMST_AdmNo"::TEXT, (SUM("dbo"."fee_student_status"."FSS_PaidAmount") - SUM("dbo"."fee_student_status"."FSS_FineAmount"))::NUMERIC AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid")::NUMERIC AS "balance", SUM("dbo"."fee_student_status"."FSS_ConcessionAmount")::NUMERIC AS "concession", SUM("dbo"."fee_student_status"."FSS_WaivedAmount")::NUMERIC AS "waived", SUM("dbo"."fee_student_status"."FSS_RebateAmount")::NUMERIC AS "rebate", SUM("dbo"."fee_student_status"."FSS_FineAmount")::NUMERIC AS "fine", SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges")::NUMERIC AS "totalpayable", NULL::TEXT AS "FMG_GroupName", NULL::TEXT AS "FMH_FeeName", NULL::BIGINT AS "ASMCL_Id", NULL::BIGINT AS "ASMS_Id", NULL::TEXT AS "FMCC_ClassCategoryName", NULL::TEXT AS "fmh_feename", NULL::NUMERIC AS "ByBank", NULL::NUMERIC AS "ByCash", NULL::NUMERIC AS "ByOnline", NULL::NUMERIC AS "ByCard", NULL::NUMERIC AS "ByECS", NULL::NUMERIC AS "ByRTGS" FROM "dbo"."fee_student_status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."fee_student_status"."Amst_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."fee_student_status"."fmg_id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."fee_student_status"."FMH_Id" INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."fee_student_status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."fee_student_status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) ' || "amst_sol" || ' GROUP BY "dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_MiddleName", "dbo"."Adm_M_Student"."AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName"';
            ELSE
                "query" := 'SELECT (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'' ''))::TEXT AS "StudentName", "Adm_M_Student"."AMST_AdmNo"::TEXT, ("dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName")::TEXT AS "ASMCL_ClassName", SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount")::NUMERIC AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid")::NUMERIC AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount")::NUMERIC AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount")::NUMERIC AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount")::NUMERIC AS "rebate", SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")::NUMERIC AS "fine", SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges")::NUMERIC AS "totalpayable", NULL::TEXT AS "FMG_GroupName", NULL::TEXT AS "FMH_FeeName", NULL::BIGINT AS "ASMCL_Id", NULL::BIGINT AS "ASMS_Id", NULL::TEXT AS "FMCC_ClassCategoryName", NULL::TEXT AS "fmh_feename", NULL::NUMERIC AS "ByBank", NULL::NUMERIC AS "ByCash", NULL::NUMERIC AS "ByOnline", NULL::NUMERIC AS "ByCard", NULL::NUMERIC AS "ByECS", NULL::NUMERIC AS "ByRTGS" FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" AND "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Student_Status"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."fee_student_status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) ' || "amst_sol" || ' GROUP BY "dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_MiddleName", "dbo"."Adm_M_Student"."AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName"';
            END IF;
        ELSIF "option" = 'FGW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT NULL::TEXT AS "StudentName", NULL::TEXT AS "ASMCL_ClassName", NULL::TEXT AS "AMST_AdmNo", (SUM("dbo"."fee_student_status"."FSS_PaidAmount") - SUM("dbo"."fee_student_status"."FSS_FineAmount"))::NUMERIC AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid")::NUMERIC AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount")::NUMERIC AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount")::NUMERIC AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount")::NUMERIC AS "rebate", SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")::NUMERIC AS "fine", SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges")::NUMERIC AS "totalpayable", "dbo"."Fee_Master_Group"."FMG_GroupName"::TEXT, NULL::TEXT AS "FMH_FeeName", NULL::BIGINT AS "ASMCL_Id", NULL::BIGINT AS "ASMS_Id", NULL::TEXT AS "FMCC_ClassCategoryName", NULL::TEXT AS "fmh_feename", NULL::NUMERIC AS "ByBank", NULL::NUMERIC AS "ByCash", NULL::NUMERIC AS "ByOnline", NULL::NUMERIC AS "ByCard", NULL::NUMERIC AS "ByECS", NULL::NUMERIC AS "ByRTGS" FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id" WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Student_Status"."MI_Id" = ' || "Mi_Id" || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("dbo"."fee_student_status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) ' || "amst_sol" || ' GROUP BY "dbo"."Fee_Master_Group"."FMG_GroupName"';
            ELSE
                "query" := 'SELECT NULL::TEXT AS "StudentName", NULL::TEXT AS "ASMCL_ClassName", NULL::TEXT AS "AMST_AdmNo", SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount")::NUMERIC AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid")::NUMERIC AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount")::NUMERIC AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount")::NUMERIC AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount")::NUMERIC AS "rebate", SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")::NUMERIC AS "fine", SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges")::NUMERIC AS "totalpayable", "dbo"."Fee_Master_Group"."FMG_GroupName"::TEXT, NULL::TEXT AS "FMH_FeeName", NULL::BIGINT AS "ASMCL_Id", NULL::BIGINT AS "ASMS_Id", NULL::TEXT AS "FMCC_ClassCategoryName", NULL::TEXT AS "fmh_feename", NULL::NUMERIC AS "ByBank", NULL::NUMERIC AS "ByCash", NULL::NUMERIC AS "ByOnline", NULL::NUMERIC AS "ByCard", NULL::NUMERIC AS "ByECS", NULL::NUMERIC AS "ByRTGS" FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" AND "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."fee_student_status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Student_Status"."MI_Id" = ' || "Mi_Id" || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) ' || "amst_sol" || ' GROUP BY "dbo"."Fee_Master_Group"."FMG_GroupName"';
            END IF;
        ELSIF "option" = 'FHW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT NULL::TEXT AS "StudentName", NULL::TEXT AS "ASMCL_ClassName", NULL::TEXT AS "AMST_AdmNo", (SUM("dbo"."fee_student_status"."FSS_PaidAmount") - SUM("dbo"."fee_student_status"."FSS_FineAmount"))::NUMERIC AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid")::NUMERIC AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount")::NUMERIC AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount")::NUMERIC AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount")::NUMERIC AS "rebate", SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")::NUMERIC AS "fine", SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges")::NUMERIC AS "totalpayable", NULL::TEXT AS "FMG_GroupName", "dbo"."Fee_Master_Head"."FMH_FeeName"::TEXT, NULL::BIGINT AS "ASMCL_Id", NULL::BIGINT AS "ASMS_Id", NULL::TEXT AS "FMCC_ClassCategoryName", NULL::TEXT AS "fmh_feename", NULL::NUMERIC AS "ByBank", NULL::NUMERIC AS "ByCash", NULL::NUMERIC AS "ByOnline", NULL::NUMERIC AS "ByCard", NULL::NUMERIC AS "ByECS", NULL::NUMERIC AS "ByRTGS" FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id" WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."fee_student_status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Student_Status"."MI_Id" = ' || "Mi_Id" || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) ' || "amst_sol" || ' GROUP BY "dbo"."Fee_Master_Head"."FMH_FeeName"';
            ELSE
                "query" := 'SELECT NULL::TEXT AS "StudentName", NULL::TEXT AS "ASMCL_ClassName", NULL::TEXT AS "AMST_AdmNo", (SUM("dbo"."fee_student_status"."FSS_PaidAmount") - SUM("dbo"."fee_student_status"."FSS_FineAmount"))::NUMERIC AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid")::NUMERIC AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount")::NUMERIC AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount")::NUMERIC AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount")::NUMERIC AS "rebate", SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")::NUMERIC AS "fine", SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges")::NUMERIC AS "totalpayable", NULL::TEXT AS "FMG_GroupName", "dbo