CREATE OR REPLACE FUNCTION "dbo"."collection_report_New_1"(
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
    "cheque" TEXT,
    "asmcl_id" TEXT,
    "amsc_id" TEXT
)
RETURNS VOID
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
    "str1" TEXT;
    "queryC1" TEXT;
    "queryC2" TEXT;
    "asmay_new" BIGINT;
    "query1" TEXT;
    "query2" TEXT;
    "query11" TEXT;
    "query123" TEXT;
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

    IF "amsc_id" != '0' THEN
        IF ("option" = 'STRMW') OR ("option" = 'TRMW') THEN
            "str1" := 'and (e."ASMCL_Id" = ' || "asmcl_id" || ') and (f."ASMS_Id" = ' || "amsc_id" || ')';
        ELSE
            "str1" := 'and "Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id" || ' and ("Adm_School_M_Section"."ASMS_Id" = ' || "amsc_id" || ')';
        END IF;
    ELSIF "asmcl_id" != '0' THEN
        IF ("option" = 'STRMW') OR ("option" = 'TRMW') THEN
            "str1" := 'and (e."ASMCL_Id" = ' || "asmcl_id" || ')';
        ELSE
            "str1" := 'and "Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id" || '';
        END IF;
    ELSE
        "str1" := ' ';
    END IF;

    IF "cheque" = '1' THEN
        "date" := 'CAST("dbo"."Fee_Y_Payment"."FYP_Date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''', ''DD/MM/YYYY'') AND "FYP_Bank_Or_Cash" = ''C''';
    ELSIF "cheque" = '2' THEN
        "date" := 'CAST("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''', ''DD/MM/YYYY'') AND "FYP_Bank_Or_Cash" = ''B''';
    ELSIF "cheque" = '3' THEN
        "date" := '((CAST("dbo"."Fee_Y_Payment"."FYP_Date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''', ''DD/MM/YYYY'')))';
    ELSIF "cheque" = '4' THEN
        "date" := '((CAST("dbo"."Fee_Y_Payment"."FYP_Date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''', ''DD/MM/YYYY'') AND "FYP_Bank_Or_Cash" = ''C'') OR (CAST("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) BETWEEN TO_DATE(''' || "date1" || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || "date2" || ''', ''DD/MM/YYYY'') AND "FYP_Bank_Or_Cash" = ''B''))';
    END IF;

    SELECT "MI_Id" INTO "mi" FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = CAST("ASMAY_ID" AS BIGINT);

    IF "active" = '1' AND "deactive" = '0' AND "left" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = 1) and ("Adm_M_Student"."AMST_SOL" = ''S'') and ("Adm_M_Student"."AMST_ActiveFlag" = 1)';
    ELSIF "deactive" = '1' AND "active" = '0' AND "left" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = 1) and ("Adm_M_Student"."AMST_SOL" = ''D'') and ("Adm_M_Student"."AMST_ActiveFlag" = 1)';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = 0) and ("Adm_M_Student"."AMST_SOL" = ''L'') and ("Adm_M_Student"."AMST_ActiveFlag" = 0)';
    ELSIF "left" = '1' AND "active" = '1' AND "deactive" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" IN (0,1)) and ("Adm_M_Student"."AMST_SOL" IN (''L'',''S'')) and ("Adm_M_Student"."AMST_ActiveFlag" IN (0,1))';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '1' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" IN (0,1)) and ("Adm_M_Student"."AMST_SOL" IN (''L'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" IN (0,1))';
    ELSIF "left" = '0' AND "active" = '1' AND "deactive" = '1' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" IN (1)) and ("Adm_M_Student"."AMST_SOL" IN (''S'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" IN (1))';
    ELSIF "active" = '1' AND "deactive" = '1' AND "left" = '1' THEN
        "amst_sol" := 'and ("Adm_M_Student"."AMST_SOL" IN (''S'',''D'',''L''))';
    END IF;

    IF "type" = 'year' THEN
        IF "option" = 'FSW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'' '')) AS "StudentName", "dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName" AS "ASMCL_ClassName", "Adm_M_Student"."AMST_AdmNo", (SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount") - SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")) AS "FSS_PaidAmount", SUM("dbo"."Fee_Student_Status"."FSS_ToBePaid") AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") AS "rebate", SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") AS "fine", SUM("dbo"."Fee_Student_Status"."FSS_CurrentYrCharges") AS "totalpayable", SUM("dbo"."Fee_Student_Status"."FSS_AdjustedAmount") AS "adjusted", SUM("FSS_ExcessPaidAmount") AS "Excess", SUM("FSS_OBArrearAmount") AS "openingbalance" FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" WHERE ("dbo"."Fee_Student_Status"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_School_M_Class"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Group"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Head"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_T_Installment"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Terms_FeeHeads"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_School_M_Section"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) ' || "amst_sol" || ' ' || "str1" || ' GROUP BY "dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_MiddleName", "dbo"."Adm_M_Student"."AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName" HAVING SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_ToBePaid") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_CurrentYrCharges") > 0';
            ELSE
                "query" := 'SELECT (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'' '')) AS "StudentName", "Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName" AS "ASMCL_ClassName", (SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount") - SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")) AS "FSS_PaidAmount", SUM("dbo"."Fee_Student_Status"."FSS_ToBePaid") AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") AS "rebate", SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") AS "fine", SUM("dbo"."Fee_Student_Status"."FSS_CurrentYrCharges") AS "totalpayable", SUM("dbo"."Fee_Student_Status"."FSS_AdjustedAmount") AS "adjusted", SUM("FSS_ExcessPaidAmount") AS "Excess", SUM("FSS_OBArrearAmount") AS "openingbalance" FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" AND "dbo"."Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || "ASMAY_ID" || ' INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" AND "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" WHERE ("dbo"."Fee_Student_Status"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Group"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Head"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_School_M_Section"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) ' || "amst_sol" || ' ' || "str1" || ' GROUP BY "dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_MiddleName", "dbo"."Adm_M_Student"."AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName" HAVING SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_ToBePaid") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") > 0 OR SUM("dbo"."Fee_Student_Status"."FSS_CurrentYrCharges") > 0';
            END IF;
        ELSIF "option" = 'FGW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT DISTINCT "dbo"."Fee_Master_Group"."FMG_GroupName", (SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount") - SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")) AS "FSS_PaidAmount", SUM("dbo"."Fee_Student_Status"."FSS_ToBePaid") AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") AS "rebate", SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") AS "fine", SUM("dbo"."Fee_Student_Status"."FSS_CurrentYrCharges") AS "totalpayable", SUM("dbo"."Fee_Student_Status"."FSS_AdjustedAmount") AS "adjusted", SUM("FSS_ExcessPaidAmount") AS "Excess", SUM("FSS_RunningExcessAmount") AS "RunningExcess" FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id" WHERE ("dbo"."Fee_Student_Status"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_School_M_Class"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Group"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Head"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_School_M_Section"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Terms_FeeHeads"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "fmt_id" || ')) ' || "amst_sol" || ' GROUP BY "dbo"."Fee_Master_Group"."FMG_GroupName"';
            ELSE
                "query" := 'SELECT "dbo"."Fee_Master_Group"."FMG_GroupName", (SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount") - SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")) AS "FSS_PaidAmount", SUM("dbo"."Fee_Student_Status"."FSS_ToBePaid") AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") AS "rebate", SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") AS "fine", SUM("dbo"."Fee_Student_Status"."FSS_CurrentYrCharges") AS "totalpayable", SUM("dbo"."Fee_Student_Status"."FSS_AdjustedAmount") AS "adjusted", SUM("FSS_ExcessPaidAmount") AS "Excess" FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" AND "dbo"."Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || "ASMAY_ID" || ' INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" WHERE ("dbo"."Fee_Student_Status"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Group"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Fee_Master_Head"."MI_Id" = ' || "mi_id" || ') AND ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Student_Status"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || "fmg_id" || ')) ' || "amst_sol" || ' GROUP BY "dbo"."Fee_Master_Group"."FMG_GroupName"';
            END IF;
        END IF;
    END IF;

    EXECUTE "query";

END;
$$;