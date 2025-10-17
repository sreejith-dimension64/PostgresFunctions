CREATE OR REPLACE FUNCTION "dbo"."concession_report"(
    "fmg_id" TEXT,
    "fmt_id" TEXT,
    "ASMAY_ID" VARCHAR,
    "type" VARCHAR(50),
    "option" VARCHAR(50),
    "status" VARCHAR(50),
    "date1" TEXT,
    "date2" TEXT,
    "mi_id" VARCHAR,
    "term_group" VARCHAR(1)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "amst_sol" CHAR(1);
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

    SELECT "MI_Id" INTO "mi" FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = "ASMAY_ID"::BIGINT;

    IF "status" = 'act' THEN
        "amst_sol" := 'S';
    ELSE
        "amst_sol" := 'L';
    END IF;

    IF "type" = 'year' THEN
        IF "option" = 'FSW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''')) AS StudentName, SUM("fee_student_status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("fee_student_status"."FSS_ConcessionAmount") AS concession, SUM("fee_student_status"."FSS_WaivedAmount") AS waived, SUM("fee_student_status"."FSS_RebateAmount") AS rebate, SUM("fee_student_status"."FSS_FineAmount") AS fine, "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"
                FROM "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"
                INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" INNER JOIN "adm_school_m_section" ON "adm_school_m_section"."asms_id" = "Adm_School_Y_Student"."asms_id"
                WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND ("Adm_M_Student"."AMST_SOL" = ''' || "amst_sol" || ''') AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) AND "FSS_ConcessionAmount" > 0 GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname" ORDER BY "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"';
            ELSE
                "query" := 'SELECT (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''')) AS StudentName, SUM("fee_student_status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("fee_student_status"."FSS_ConcessionAmount") AS concession, SUM("fee_student_status"."FSS_WaivedAmount") AS waived, SUM("fee_student_status"."FSS_RebateAmount") AS rebate, SUM("fee_student_status"."FSS_FineAmount") AS fine, "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"
                FROM "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"
                INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" INNER JOIN "adm_school_m_section" ON "adm_school_m_section"."asms_id" = "Adm_School_Y_Student"."asms_id"
                WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND ("Adm_M_Student"."AMST_SOL" = ''' || "amst_sol" || ''') AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname" ORDER BY "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"';
            END IF;
        ELSIF "option" = 'FGW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT SUM("fee_student_status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("fee_student_status"."FSS_ConcessionAmount") AS concession, SUM("fee_student_status"."FSS_FineAmount") AS fine, SUM("fee_student_status"."FSS_WaivedAmount") AS waived, SUM("fee_student_status"."FSS_RebateAmount") AS rebate, "Fee_Master_Group"."FMG_GroupName" FROM "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"
                INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id"
                WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND ("Adm_M_Student"."AMST_SOL" = ''' || "amst_sol" || ''') AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) GROUP BY "Fee_Master_Group"."FMG_GroupName"';
            ELSE
                "query" := 'SELECT SUM("fee_student_status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("fee_student_status"."FSS_ConcessionAmount") AS concession, SUM("fee_student_status"."FSS_FineAmount") AS fine, SUM("fee_student_status"."FSS_WaivedAmount") AS waived, SUM("fee_student_status"."FSS_RebateAmount") AS rebate, "Fee_Master_Group"."FMG_GroupName" FROM "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id"
                INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id"
                WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND ("Adm_M_Student"."AMST_SOL" = ''' || "amst_sol" || ''') AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) GROUP BY "Fee_Master_Group"."FMG_GroupName"';
            END IF;
        ELSIF "option" = 'FHW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT "Fee_Master_Head"."FMH_FeeName", SUM("fee_student_status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("fee_student_status"."FSS_ConcessionAmount") AS concession, SUM("fee_student_status"."FSS_WaivedAmount") AS waived, SUM("fee_student_status"."FSS_RebateAmount") AS rebate, SUM("fee_student_status"."FSS_FineAmount") AS fine FROM "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN
                "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) GROUP BY "Fee_Master_Head"."FMH_FeeName"';
            ELSE
                "query" := 'SELECT "Fee_Master_Head"."FMH_FeeName", SUM("fee_student_status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("fee_student_status"."FSS_ConcessionAmount") AS concession, SUM("fee_student_status"."FSS_WaivedAmount") AS waived, SUM("fee_student_status"."FSS_RebateAmount") AS rebate, SUM("fee_student_status"."FSS_FineAmount") AS fine FROM "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN
                "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) GROUP BY "Fee_Master_Head"."FMH_FeeName"';
            END IF;
        ELSIF "option" = 'FCW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT "Adm_School_M_Class"."ASMCL_ClassName", SUM("fee_student_status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("fee_student_status"."FSS_ConcessionAmount") AS concession, SUM("fee_student_status"."FSS_WaivedAmount") AS waived, SUM("fee_student_status"."FSS_RebateAmount") AS rebate, SUM("fee_student_status"."FSS_FineAmount") AS fine FROM "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN
                "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "fee_student_status"."FTI_Id" WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Adm_M_Student"."AMST_SOL" = ''' || "amst_sol" || ''') AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) GROUP BY "Adm_School_M_Class"."ASMCL_ClassName" ORDER BY "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"';
            ELSE
                "query" := 'SELECT "Adm_School_M_Class"."ASMCL_ClassName", SUM("fee_student_status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("fee_student_status"."FSS_ConcessionAmount") AS concession, SUM("fee_student_status"."FSS_WaivedAmount") AS waived, SUM("fee_student_status"."FSS_RebateAmount") AS rebate, SUM("fee_student_status"."FSS_FineAmount") AS fine FROM "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN
                "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "fee_student_status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "fee_student_status"."FTI_Id" WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount" > 0 AND ("Adm_M_Student"."AMST_SOL" = ''' || "amst_sol" || ''') AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) GROUP BY "Adm_School_M_Class"."ASMCL_ClassName" ORDER BY "Adm_School_M_Class"."asmcl_classname", "adm_school_m_section"."asmc_sectionname"';
            END IF;
        END IF;
    ELSIF "type" = 'date' THEN
        SELECT "ASMAY_Id" INTO "asmay_new" FROM "Adm_School_M_Academic_Year" WHERE TO_DATE("date1", 'DD/MM/YYYY') BETWEEN TO_DATE("ASMAY_From_Date", 'DD/MM/YYYY') AND TO_DATE("ASMAY_To_Date", 'DD/MM/YYYY');

        IF "option" = 'FGW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT DISTINCT "Fee_Master_Group"."FMG_GroupName", SUM("Fee_Student_Status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("Fee_Student_Status"."FSS_ToBePaid") AS balance, SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS concession, SUM("Fee_Student_Status"."FSS_FineAmount") AS fine, SUM("Fee_Student_Status"."FSS_WaivedAmount") AS waived, SUM("Fee_Student_Status"."FSS_RebateAmount") AS rebate
                FROM "Fee_Y_Payment" INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id" INNER JOIN "Fee_T_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" INNER JOIN "Adm_M_Student" INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN
                "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" INNER JOIN "Fee_Student_Status" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" INNER JOIN "Fee_Master_Group" ON
                "Fee_Student_Status"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Fee_T_Payment"."FMA_Id" = "Fee_Student_Status"."FMA_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id" WHERE ("Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) AND ("Fee_Y_Payment"."FYP_Date" BETWEEN TO_DATE(''' || "date1" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''', ''DD/MM/YYYY''))
                GROUP BY "Fee_Master_Group"."FMG_GroupName"';
            ELSE
                "query" := 'SELECT DISTINCT "Fee_Master_Group"."FMG_GroupName", SUM("Fee_Student_Status"."FSS_PaidAmount") AS FSS_PaidAmount, SUM("Fee_Student_Status"."FSS_ToBePaid") AS balance, SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS concession, SUM("Fee_Student_Status"."FSS_FineAmount") AS fine, SUM("Fee_Student_Status"."FSS_WaivedAmount") AS waived, SUM("Fee_Student_Status"."FSS_RebateAmount") AS rebate
                FROM "Fee_Y_Payment" INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id" INNER JOIN "Fee_T_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" INNER JOIN "Adm_M_Student" INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN
                "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" INNER JOIN "Fee_Student_Status" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" INNER JOIN "Fee_Master_Group" ON
                "Fee_Student_Status"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Status"."FTI_Id" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Fee_T_Payment"."FMA_Id" = "Fee_Student