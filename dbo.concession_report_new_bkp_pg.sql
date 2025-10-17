CREATE OR REPLACE FUNCTION "concession_report_new_bkp" (
    "fmg_id" TEXT,
    "fmt_id" TEXT,
    "ASMAY_ID" VARCHAR(50),
    "type" VARCHAR(50),
    "option" VARCHAR(50),
    "date1" TEXT,
    "date2" TEXT,
    "mi_id" VARCHAR,
    "term_group" VARCHAR(1),
    "active" VARCHAR(50),
    "deactive" VARCHAR(50),
    "left" VARCHAR(50)
)
RETURNS SETOF RECORD
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

    IF "active" = '1' AND "deactive" = '0' AND "left" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1)and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "deactive" = '1' AND "active" = '0' AND "left" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1)and ("Adm_M_Student"."AMST_SOL"=''D'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=0)and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=0)';
    ELSIF "left" = '1' AND "active" = '1' AND "deactive" = '0' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1))and ("Adm_M_Student"."AMST_SOL" in (''L'',''S'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF "left" = '1' AND "active" = '0' AND "deactive" = '1' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1))and ("Adm_M_Student"."AMST_SOL" in (''L'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF "left" = '0' AND "active" = '1' AND "deactive" = '1' THEN
        "amst_sol" := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (1))and ("Adm_M_Student"."AMST_SOL" in (''S'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(1))';
    ELSIF "left" = '1' AND "active" = '1' AND "deactive" = '1' THEN
        "amst_sol" := 'and ("Adm_M_Student"."AMST_SOL" in (''S'',''D'',''L'')) ';
    END IF;

    IF "type" = 'year' THEN
        IF "option" = 'FSW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT  (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''')) "StudentName" , SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance",SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine","Adm_School_M_Class"."asmcl_classname","adm_school_m_section"."asmc_sectionname" FROM   "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="fee_student_status"."FMH_Id"  INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="fee_student_status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" on  "Fee_Master_Terms_FeeHeads"."FMH_Id"=  "fee_student_status"."FMH_Id" and  "Fee_Master_Terms_FeeHeads"."FTI_Id"=  "fee_student_status"."FTI_Id"  inner join     "adm_school_m_section" on "adm_school_m_section"."asms_id"=   "Adm_School_Y_Student"."asms_id"    WHERE     ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" =' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1)  and  ("Fee_Master_Group"."FMG_Id" in(' || "fmg_id" || ')) and ("Fee_Master_Terms_FeeHeads"."FMT_Id" in(' || "fmt_id" || '))  and "FSS_ConcessionAmount">0  ' || "amst_sol" || ' AND ("fee_student_status"."ASMAY_Id" =' || "ASMAY_ID" || ')   GROUP BY "Adm_M_Student"."AMST_FirstName","Adm_M_Student"."AMST_MiddleName","Adm_M_Student"."AMST_LastName","Adm_School_M_Class"."asmcl_classname","adm_school_m_section"."asmc_sectionname" order by  "Adm_School_M_Class"."asmcl_classname","adm_school_m_section"."asmc_sectionname"';
            ELSE
                "query" := 'SELECT  (COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''')) "StudentName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine","adm_school_m_class"."asmcl_classname","adm_school_m_section"."asmc_sectionname" FROM   "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="fee_student_status"."FMH_Id"  INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="fee_student_status"."FTI_Id" inner join     "adm_school_m_section" on "adm_school_m_section"."asms_id"=   "Adm_School_Y_Student"."asms_id"   WHERE  ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" =' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1) AND "FSS_ConcessionAmount">0 and ("Fee_Master_Group"."FMG_Id" in(' || "fmg_id" || ')) ' || "amst_sol" || ' AND ("fee_student_status"."ASMAY_Id" =' || "ASMAY_ID" || ')  GROUP BY "Adm_M_Student"."AMST_FirstName","Adm_M_Student"."AMST_MiddleName","Adm_M_Student"."AMST_LastName","adm_school_m_class"."asmcl_classname","adm_school_m_section"."asmc_sectionname" order by    "Adm_School_M_Class"."asmcl_classname","adm_school_m_section"."asmc_sectionname"';
            END IF;
        ELSIF "option" = 'FGW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT  "Fee_Master_Group"."FMG_GroupName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" FROM   "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="fee_student_status"."FMH_Id"  INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="fee_student_status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" on  "Fee_Master_Terms_FeeHeads"."FMH_Id"=  "fee_student_status"."FMH_Id" and  "Fee_Master_Terms_FeeHeads"."FTI_Id"=  "fee_student_status"."FTI_Id"  WHERE  ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ')  AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1)  and "FSS_ConcessionAmount">0 and ("Fee_Master_Group"."FMG_Id" in(' || "fmg_id" || ')) and ("Fee_Master_Terms_FeeHeads"."FMT_Id" in(' || "fmt_id" || ')) ' || "amst_sol" || ' AND ("fee_student_status"."ASMAY_Id" =' || "ASMAY_ID" || ')  GROUP BY "Fee_Master_Group"."FMG_GroupName"';
            ELSE
                "query" := 'SELECT SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_FineAmount") AS "fine", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", "Fee_Master_Group"."FMG_GroupName" FROM  "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="fee_student_status"."FMH_Id"  INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="fee_student_status"."FTI_Id"      WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "Mi_Id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1)   and "FSS_ConcessionAmount">0 and    ("Fee_Master_Group"."FMG_Id" in (' || "fmg_id" || '))' || "amst_sol" || ' AND ("fee_student_status"."ASMAY_Id" =' || "ASMAY_ID" || ')  GROUP BY  "Fee_Master_Group"."FMG_GroupName"';
            END IF;
        ELSIF "option" = 'FHW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'SELECT  "Fee_Master_Head"."FMH_FeeName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" FROM   "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="fee_student_status"."FMH_Id"  INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="fee_student_status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" on  "Fee_Master_Terms_FeeHeads"."FMH_Id"=  "fee_student_status"."FMH_Id" and  "Fee_Master_Terms_FeeHeads"."FTI_Id"=  "fee_student_status"."FTI_Id"  WHERE  ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1)  and "FSS_ConcessionAmount">0 and ("Fee_Master_Group"."FMG_Id" in(' || "fmg_id" || ')) and ("Fee_Master_Terms_FeeHeads"."FMT_Id" in(' || "fmt_id" || '))' || "amst_sol" || ' AND ("fee_student_status"."ASMAY_Id" =' || "ASMAY_ID" || ')  GROUP BY "Fee_Master_Head"."FMH_FeeName"';
            ELSE
                "query" := 'SELECT  "Fee_Master_Head"."FMH_FeeName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" FROM   "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="fee_student_status"."FMH_Id"  INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="fee_student_status"."FTI_Id" WHERE  ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1)  and "FSS_ConcessionAmount">0 and ("Fee_Master_Group"."FMG_Id" in(' || "fmg_id" || ')) ' || "amst_sol" || ' AND ("fee_student_status"."ASMAY_Id" =' || "ASMAY_ID" || ')  GROUP BY "Fee_Master_Head"."FMH_FeeName"';
            END IF;
        ELSIF "option" = 'FCW' THEN
            IF "term_group" = 'T' THEN
                "query" := 'Select "Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName" as "ASMCL_ClassName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" FROM  "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="fee_student_status"."FMH_Id"  INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="fee_student_status"."FTI_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" on       "Fee_Master_Terms_FeeHeads"."FMH_Id"=  "fee_student_status"."FMH_Id" and  "Fee_Master_Terms_FeeHeads"."FTI_Id"=  "fee_student_status"."FTI_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1)  and "FSS_ConcessionAmount">0  and ("Fee_Master_Group"."FMG_Id" in(' || "fmg_id" || ')) and ("Fee_Master_Terms_FeeHeads"."FMT_Id" in(' || "fmt_id" || ')) ' || "amst_sol" || ' AND ("fee_student_status"."ASMAY_Id" =' || "ASMAY_ID" || ')  GROUP BY "Adm_School_M_Class"."ASMCL_ClassName","adm_school_m_section"."asmc_sectionname"  order by       "Adm_School_M_Class"."asmcl_classname","adm_school_m_section"."asmc_sectionname"';
            ELSE
                "query" := 'SELECT "Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName" as "ASMCL_ClassName", SUM("fee_student_status"."FSS_PaidAmount") AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine" FROM  "fee_student_status" INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="fee_student_status"."FMH_Id"  INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="fee_student_status"."FTI_Id" INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ') AND ("fee_student_status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Group"."FMG_ActiceFlag" = 1)  and "FSS_ConcessionAmount">0  and ("Fee_Master_Group"."FMG_Id" in(' || "fmg_id" || ')) ' || "amst_sol" || ' AND ("fee_student_status"."ASMAY_Id" =' || "ASMAY_ID" || ')  GROUP BY "Adm_School_M_Class"."ASMCL_ClassName","adm_school_m_section"."asmc_sectionname" order by       "Adm_School_M_Class"."asmcl_classname","adm_school_m_section"."asmc_sectionname"';
            END IF;
        ELSIF "option" = 'TRMW' THEN
            "query" := 'select distinct k."FMT_Id",k."FMT_Name","FMH_FeeName",Sum("FSS_ToBePaid") "Balance",Sum("FSS_PaidAmount") "Paid",Sum("FSS_ConcessionAmount") "Concession",Sum("FSS_WaivedAmount") "Waivedoff",  Sum("FSS_FineAmount") "Fine",sum("FSS_NetAmount") "Netamount"   from "Fee_Student_Status" a, "Adm_M_Student" b,"Adm_School_Y_Student" c,  "Adm_School_M_Class"  e,"Adm_School_M_Section"  f,"Fee_T_Installment" g  ,"Fee_Master_Amount" h  ,"Fee_Master_Terms_FeeHeads" i,"Fee_Master_Head" j,"Fee_Master_Terms" k where a."AMST_Id"=b."AMST_Id" and b."AMST_Id"=c."AMST_Id" and  h."FMA_Id"=a."FMA_Id"  and a."MI_Id"=' || "mi_id" || ' and b."MI_Id"=' || "mi_id" || ' and  a."ASMAY_Id"=' || "ASMAY_ID" || ' and c."ASMAY_Id"=' || "ASMAY_ID" || '  and e."MI_Id"=' || "mi_id" || ' and  e."ASMCL_Id"=c."ASMCL_Id"  and f."MI_Id"=' || "mi_id" || ' and f."AS