CREATE OR REPLACE FUNCTION "dbo"."concession_report_new"(
    "p_fmg_id" TEXT,
    "p_fmt_id" TEXT,
    "p_ASMAY_ID" VARCHAR(50),
    "p_type" VARCHAR(50),
    "p_option" VARCHAR(50),
    "p_date1" TEXT,
    "p_date2" TEXT,
    "p_mi_id" VARCHAR(50),
    "p_term_group" VARCHAR(1),
    "p_active" VARCHAR(50),
    "p_deactive" VARCHAR(50),
    "p_left" VARCHAR(50)
)
RETURNS VOID AS $$
DECLARE
    "v_amst_sol" TEXT;
    "v_mi" BIGINT;
    "v_dt" BIGINT;
    "v_mt" BIGINT;
    "v_ftdd_day" BIGINT;
    "v_ftdd_month" BIGINT;
    "v_endyr" BIGINT;
    "v_startyr" BIGINT;
    "v_duedate" TIMESTAMP;
    "v_duedate1" TIMESTAMP;
    "v_fromdate" TIMESTAMP;
    "v_todate" TIMESTAMP;
    "v_oResult" VARCHAR(50);
    "v_days" VARCHAR(50);
    "v_months" VARCHAR(50);
    "v_query" TEXT;
    "v_asmay_new" BIGINT;
BEGIN
    "v_amst_sol" := '';
    "v_mi" := 0;
    "v_ftdd_day" := 0;
    "v_ftdd_month" := 0;
    "v_endyr" := 0;
    "v_startyr" := 0;
    "v_days" := '0';
    "v_months" := '0';
    "v_dt" := 0;
    "v_mt" := 0;

    SELECT "MI_Id" INTO "v_mi" FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = "p_ASMAY_ID"::BIGINT;

    IF "p_active" = '1' AND "p_deactive" = '0' AND "p_left" = '0' THEN
        "v_amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1) and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "p_deactive" = '1' AND "p_active" = '0' AND "p_left" = '0' THEN
        "v_amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1) and ("Adm_M_Student"."AMST_SOL"=''D'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "p_left" = '1' AND "p_active" = '0' AND "p_deactive" = '0' THEN
        "v_amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=0) and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=0)';
    ELSIF "p_left" = '1' AND "p_active" = '1' AND "p_deactive" = '0' THEN
        "v_amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1)) and ("Adm_M_Student"."AMST_SOL" in (''L'',''S'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF "p_left" = '1' AND "p_active" = '0' AND "p_deactive" = '1' THEN
        "v_amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1)) and ("Adm_M_Student"."AMST_SOL" in (''L'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF "p_left" = '0' AND "p_active" = '1' AND "p_deactive" = '1' THEN
        "v_amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (1)) and ("Adm_M_Student"."AMST_SOL" in (''S'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(1))';
    END IF;

    IF "p_type" = 'year' THEN
        IF "p_option" = 'FSW' THEN
            IF "p_term_group" = 'T' THEN
                "v_query" := 'SELECT (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''')) AS "StudentName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine", "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname" 
FROM "fee_student_status" 
INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
AND "fee_student_status"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" 
INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" 
INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
INNER JOIN "adm_school_m_section" ON "adm_school_m_section"."asms_id" = "Adm_School_Y_Student"."asms_id" 
WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "p_mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND ("Fee_Master_Group"."FMG_Id" IN(' || "p_fmg_id" || ')) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN(' || "p_fmt_id" || ')) AND "FSS_ConcessionAmount" > 0 ' || "v_amst_sol" || ' 
GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname" 
ORDER BY "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"';
            ELSE
                "v_query" := 'SELECT (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''')) AS "StudentName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine", "adm_school_m_class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"
FROM "fee_student_status" 
INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"
INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" 
INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" 
INNER JOIN "adm_school_m_section" ON "adm_school_m_section"."asms_id" = "Adm_School_Y_Student"."asms_id" 
WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "p_mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN(' || "p_fmg_id" || ')) ' || "v_amst_sol" || ' 
GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", "adm_school_m_class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname" 
ORDER BY "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"';
            END IF;
        ELSIF "p_option" = 'FGW' THEN
            IF "p_term_group" = 'T' THEN
                "v_query" := 'SELECT "Fee_Master_Group"."FMG_GroupName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" 
FROM "fee_student_status" 
INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" 
INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" 
INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "p_mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN(' || "p_fmg_id" || ')) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN(' || "p_fmt_id" || ')) ' || "v_amst_sol" || ' 
GROUP BY "Fee_Master_Group"."FMG_GroupName"';
            ELSE
                "v_query" := 'SELECT SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_FineAmount") AS "fine", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", "Fee_Master_Group"."FMG_GroupName" 
FROM "fee_student_status" 
INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"
INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" 
INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" 
WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "p_Mi_Id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN (' || "p_fmg_id" || '))' || "v_amst_sol" || ' 
GROUP BY "Fee_Master_Group"."FMG_GroupName"';
            END IF;
        ELSIF "p_option" = 'FHW' THEN
            IF "p_term_group" = 'T' THEN
                "v_query" := 'SELECT "Fee_Master_Head"."FMH_FeeName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" 
FROM "fee_student_status" 
INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" 
INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" 
INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "p_mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN(' || "p_fmg_id" || ')) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN(' || "p_fmt_id" || '))' || "v_amst_sol" || ' 
GROUP BY "Fee_Master_Head"."FMH_FeeName"';
            ELSE
                "v_query" := 'SELECT "Fee_Master_Head"."FMH_FeeName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" 
FROM "fee_student_status" 
INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" 
INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" 
WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "p_mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN(' || "p_fmg_id" || ')) ' || "v_amst_sol" || ' 
GROUP BY "Fee_Master_Head"."FMH_FeeName"';
            END IF;
        ELSIF "p_option" = 'FCW' THEN
            IF "p_term_group" = 'T' THEN
                "v_query" := 'SELECT "Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName" AS "ASMCL_ClassName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" 
FROM "fee_student_status" 
INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" 
INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" 
INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" 
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "p_mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN(' || "p_fmg_id" || ')) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN(' || "p_fmt_id" || ')) ' || "v_amst_sol" || ' 
GROUP BY "Adm_School_M_Class"."ASMCL_ClassName", "adm_school_m_section"."asmc_sectionname" 
ORDER BY "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"';
            ELSE
                "v_query" := 'SELECT "Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName" AS "ASMCL_ClassName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" 
FROM "fee_student_status" 
INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" 
INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" 
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "p_mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN(' || "p_fmg_id" || ')) ' || "v_amst_sol" || ' 
GROUP BY "Adm_School_M_Class"."ASMCL_ClassName", "adm_school_m_section"."asmc_sectionname" 
ORDER BY "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"';
            END IF;
        END IF;
    ELSIF "p_type" = 'date' THEN
        SELECT "ASMAY_Id" INTO "v_asmay_new" 
        FROM "Adm_School_M_Academic_Year" 
        WHERE TO_DATE("p_date1", 'DD/MM/YYYY') BETWEEN TO_DATE("ASMAY_From_Date", 'DD/MM/YYYY') 
        AND TO_DATE("ASMAY_To_Date", 'DD/MM/YYYY');

        IF "p_option" = 'FGW' THEN
            IF "p_term_group" = 'T' THEN
                "v_query" := 'SELECT DISTINCT "Fee_Master_Group"."FMG_GroupName", SUM("Fee_Student_Status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("Fee_Student_Status"."FSS_ToBePaid") AS "balance", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "concession", SUM("Fee_Student_Status"."FSS_FineAmount") AS "fine", SUM("Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate"
FROM "Fee_Y_Payment" 