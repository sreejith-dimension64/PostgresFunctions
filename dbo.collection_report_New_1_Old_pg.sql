CREATE OR REPLACE FUNCTION "dbo"."collection_report_New_1_Old" (
    p_fmg_id TEXT,
    p_fmt_id TEXT,
    p_ASMAY_ID VARCHAR(50),
    p_type VARCHAR(50),
    p_option VARCHAR(50),
    p_active VARCHAR(50),
    p_deactive VARCHAR(50),
    p_left VARCHAR(50),
    p_date1 TEXT,
    p_date2 TEXT,
    p_mi_id VARCHAR(50),
    p_term_group VARCHAR(1),
    p_cheque TEXT,
    p_asmcl_id TEXT,
    p_amsc_id TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_amst_sol TEXT := '';
    v_mi BIGINT := 0;
    v_dt BIGINT := 0;
    v_mt BIGINT := 0;
    v_ftdd_day BIGINT := 0;
    v_ftdd_month BIGINT := 0;
    v_endyr BIGINT := 0;
    v_startyr BIGINT := 0;
    v_duedate TIMESTAMP;
    v_duedate1 TIMESTAMP;
    v_fromdate TIMESTAMP;
    v_todate TIMESTAMP;
    v_oResult VARCHAR(50);
    v_days VARCHAR(50) := '0';
    v_months VARCHAR(50) := '0';
    v_query TEXT;
    v_date TEXT;
    v_str1 TEXT;
BEGIN

    IF p_amsc_id != '0' THEN
        IF (p_option = 'STRMW') OR (p_option = 'TRMW') THEN
            v_str1 := 'and (e."ASMCL_Id" = ' || p_asmcl_id || ') and (f."asms_id"= ' || p_amsc_id || ')';
        ELSE
            v_str1 := 'and "Adm_School_M_Class"."ASMCL_Id"=' || p_asmcl_id || ' and ("Adm_School_M_Section"."ASMS_Id"= ' || p_amsc_id || ')';
        END IF;
    ELSIF p_asmcl_id != '0' THEN
        IF (p_option = 'STRMW') OR (p_option = 'TRMW') THEN
            v_str1 := 'and (e."ASMCL_Id" = ' || p_asmcl_id || ')';
        ELSE
            v_str1 := 'and "Adm_School_M_Class"."ASMCL_Id"=' || p_asmcl_id || '';
        END IF;
    ELSE
        v_str1 := ' ';
    END IF;

    IF p_cheque = '1' THEN
        v_date := 'CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') AND TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY'') and "FYP_Bank_Or_Cash"=''C''';
    ELSIF p_cheque = '2' THEN
        v_date := 'CAST("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) BETWEEN TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') AND TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY'') and "FYP_Bank_Or_Cash"=''B''';
    ELSIF p_cheque = '3' THEN
        v_date := '((CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') AND TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY''))) ';
    ELSIF p_cheque = '4' THEN
        v_date := '((CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') AND TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY'') and "FYP_Bank_Or_Cash"=''C'') or ((CAST("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) BETWEEN TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') AND TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY''))and "FYP_Bank_Or_Cash"=''B''))';
    END IF;

    SELECT "MI_Id" INTO v_mi FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = p_ASMAY_ID::BIGINT;

    IF p_active = '1' AND p_deactive = '0' AND p_left = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1)and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF p_deactive = '1' AND p_active = '0' AND p_left = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1)and ("Adm_M_Student"."AMST_SOL"=''D'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=0)and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=0)';
    ELSIF p_left = '1' AND p_active = '1' AND p_deactive = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1))and ("Adm_M_Student"."AMST_SOL" in (''L'',''S'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '1' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1))and ("Adm_M_Student"."AMST_SOL" in (''L'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF p_left = '0' AND p_active = '1' AND p_deactive = '1' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (1))and ("Adm_M_Student"."AMST_SOL" in (''S'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(1))';
    END IF;

    IF p_type = 'year' THEN
        IF p_option = 'FSW' THEN
            IF p_term_group = 'T' THEN
                v_query := 'SELECT (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'' '')) AS "StudentName", "dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName" as "ASMCL_ClassName","Adm_M_Student"."AMST_AdmNo",(SUM("dbo"."fee_student_status"."FSS_PaidAmount")- SUM("dbo"."fee_student_status"."FSS_FineAmount"))AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid") AS "balance", SUM("dbo"."fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("dbo"."fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("dbo"."fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("dbo"."fee_student_status"."FSS_FineAmount") AS "fine",SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges") AS "totalpayable"
FROM "dbo"."fee_student_status" 
INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."fee_student_status"."Amst_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id"
INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."fee_student_status"."fmg_id" = "dbo"."Fee_Master_Group"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id"="dbo"."fee_student_status"."FMH_Id" 
INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="dbo"."fee_student_status"."FTI_Id"   
INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "fee_student_status"."FMH_Id" and "Fee_Master_Terms_FeeHeads"."FTI_Id"="fee_student_status"."FTI_Id"  
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" 
WHERE ("dbo"."fee_student_status"."MI_Id" =' || p_mi_id || ') AND ("dbo"."Adm_M_Student"."MI_Id" =' || p_mi_id || ') AND ("dbo"."Adm_School_M_Class"."MI_Id" =' || p_mi_id || ') AND ("dbo"."Fee_Master_Group"."MI_Id" =' || p_mi_id || ') AND ("dbo"."Fee_Master_Head"."MI_Id" =' || p_mi_id || ') AND ("dbo"."Fee_T_Installment"."MI_Id" =' || p_mi_id || ') AND ("dbo"."Fee_Master_Terms_FeeHeads"."MI_Id" =' || p_mi_id || ') AND ("dbo"."Adm_School_M_Section"."MI_Id" =' || p_mi_id || ') and
("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND ("dbo"."fee_student_status"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("dbo"."Fee_Master_Group"."FMG_Id" in(' || p_fmg_id || ')) and ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" in (' || p_fmt_id || ')) ' || v_amst_sol || ' ' || v_str1 || ' 
GROUP BY "dbo"."Adm_M_Student"."AMST_FirstName","dbo"."Adm_M_Student"."AMST_MiddleName","dbo"."Adm_M_Student"."AMST_LastName","Adm_M_Student"."AMST_AdmNo","dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName" 
having SUM("dbo"."fee_student_status"."FSS_PaidAmount")>0 ';
            ELSE
                v_query := 'SELECT (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'' '')) AS "StudentName","Adm_M_Student"."AMST_AdmNo", "dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName" as "ASMCL_ClassName",
(SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount")-SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")) AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid") AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") AS "concession", 
SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") AS "rebate", 
SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") AS "fine",SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges") AS "totalpayable"
FROM "dbo"."Fee_Student_Status" 
INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id" 
INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" AND "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" 
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" 
WHERE ("dbo"."Fee_Student_Status"."MI_Id" = ' || p_mi_id || ') AND ("dbo"."Adm_M_Student"."MI_Id" = ' || p_mi_id || ') AND ("dbo"."Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || p_mi_id || ') AND ("dbo"."Fee_Master_Group"."MI_Id" = ' || p_mi_id || ') AND ("dbo"."Fee_Master_Head"."MI_Id" = ' || p_mi_id || ') AND ("dbo"."Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || p_mi_id || ') AND ("dbo"."Adm_School_M_Section"."MI_Id" = ' || p_mi_id || ') 
and ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND ("dbo"."fee_student_status"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || p_fmg_id || ')) ' || v_amst_sol || ' ' || v_str1 || ' 
GROUP BY "dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_MiddleName", "dbo"."Adm_M_Student"."AMST_LastName","Adm_M_Student"."AMST_AdmNo","dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName" 
having SUM("dbo"."fee_student_status"."FSS_PaidAmount")>0 ';
            END IF;
        ELSIF p_option = 'FGW' THEN
            IF p_term_group = 'T' THEN
                v_query := 'SELECT distinct "dbo"."Fee_Master_Group"."FMG_GroupName", (SUM("dbo"."fee_student_status"."FSS_PaidAmount")- SUM("dbo"."fee_student_status"."FSS_FineAmount"))AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid") AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") 
AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") AS "rebate", 
SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") AS "fine",SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges") AS "totalpayable"
FROM "dbo"."Fee_Student_Status" 
INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id"
INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id"  
INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id"  
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id"  
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" 
INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id" 
WHERE ("dbo"."Fee_Student_Status"."MI_Id" = ' || p_Mi_Id || ') AND ("dbo"."Adm_M_Student"."MI_Id" =' || p_Mi_Id || ') AND ("dbo"."Adm_School_M_Class"."MI_Id" =' || p_Mi_Id || ') AND ("dbo"."Fee_Master_Group"."MI_Id" =' || p_Mi_Id || ') AND ("dbo"."Fee_Master_Head"."MI_Id" =' || p_Mi_Id || ') AND ("dbo"."Adm_School_M_Section"."MI_Id"=' || p_Mi_Id || ') AND ("dbo"."Fee_Master_Terms_FeeHeads"."MI_Id"=' || p_Mi_Id || ')
AND ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || p_fmg_id || ')) and ("dbo"."fee_student_status"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_fmt_id || ')) ' || v_amst_sol || '
GROUP BY "dbo"."Fee_Master_Group"."FMG_GroupName"';
            ELSE
                v_query := 'SELECT "dbo"."Fee_Master_Group"."FMG_GroupName", (SUM("dbo"."Fee_Student_Status"."FSS_PaidAmount")-SUM("dbo"."Fee_Student_Status"."FSS_FineAmount")) AS "FSS_PaidAmount", SUM("dbo"."fee_student_status"."FSS_ToBePaid") AS "balance", SUM("dbo"."Fee_Student_Status"."FSS_ConcessionAmount") 
AS "concession", SUM("dbo"."Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("dbo"."Fee_Student_Status"."FSS_RebateAmount") AS "rebate", 
SUM("dbo"."Fee_Student_Status"."FSS_FineAmount") AS "fine",SUM("dbo"."fee_student_status"."FSS_CurrentYrCharges") AS "totalpayable"
FROM "dbo"."Fee_Student_Status" 
INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id"
INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"  
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" AND "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" 
INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id"   
WHERE ("dbo"."Fee_Student_Status"."MI_Id" = ' || p_Mi_Id || ') AND ("dbo"."Adm_M_Student"."MI_Id" = ' || p_Mi_Id || ') AND ("dbo"."Adm_School_M_Class"."MI_Id" = ' || p_Mi_Id || ') AND ("dbo"."Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || p_Mi_Id || ') AND ("dbo"."Fee_Master_Group"."MI_Id" = ' || p_Mi_Id || ') AND ("dbo"."Fee_Master_Head"."MI_Id" = ' || p_Mi_Id || ')
AND ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') and ("dbo"."fee_student_status"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND ("dbo"."Fee_Master_Group"."FMG_Id" IN (' || p_fmg_id || ')) ' || v_amst_sol || '
GROUP BY "dbo"."Fee_Master_Group"."FMG_GroupName"';
            END IF;
        ELSIF p_option = 'TRMW' THEN
            IF p_active = '1' AND p_deactive = '0' AND p_left = '0' THEN
                v_amst_sol := 'and (c."AMAY_ActiveFlag"=1)and (b."AMST_SOL"=''S'') and (b."AMST_ActiveFlag"=1)';
            ELSIF p_deactive = '1' AND p_active = '0' AND p_left = '0' THEN
                v_amst_sol := 'and (c."AMAY_ActiveFlag"=1)and (b."AMST_SOL"=''D'') and (b."AMST_ActiveFlag"=1)';
            ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '0' THEN
                v_amst_sol := 'and (c."AMAY_ActiveFlag"=0)and (b."AMST_SOL"=''L'') and (b."AMST_ActiveFlag"=0)';
            ELSIF p_left = '1' AND p_active = '1' AND p_deactive = '0' THEN
                v_amst_sol := 'and (c."AMAY_ActiveFlag" in (0,1))and (b."AMST_SOL" in (''L'',''S'')) and (b."AMST_ActiveFlag" in(0,1))';
            ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '1' THEN
                v_amst_sol := 'and (c."AMAY_ActiveFlag" in (0,1))and (b."AMST_SOL" in (''L'',''D'')) and (b."AMST_ActiveFlag" in(0,1))';
            ELSIF p_left = '0' AND p_active = '1' AND p_deactive = '1' THEN
                v_amst_sol := 'and (c."AMAY_ActiveFlag" in (1))and (b."AMST_SOL" in (''S'',''D'')) and (b."AMST_ActiveFlag" in(1))';
            END IF;

            v_query := 'select distinct j."FMH_Id",k."FMT_Id",k."FMT_Name","FMH_FeeName", sum(a."FSS_OBArrearAmount") AS "Arrear",sum(a."FSS_OBExcessAmount") AS "Excess",sum(a."FSS_ToBePaid") AS "Balance",sum(a."FSS_PaidAmount") AS "Paid",(sum(a."FSS_TotalToBePaid")-sum(a."FSS_ConcessionAmount")) as "Payable",sum(a."FSS_ConcessionAmount") as "Concession",sum(a."FSS_CurrentYrCharges") AS "Charges"   
from "Fee_Student_Status" a, "Adm_M_Student" b,"Adm_School_Y_Student" c, "Adm_School_M_Class" e,"Adm_School_M_Section" f,"Fee_T_Installment" g,"Fee_Master_Amount" h,
"Fee_Master_Terms_FeeHeads" i,"Fee_Master_Head" j,"Fee_Master_Terms" k
where a."AMST_Id"=b."AMST_Id" and b."AMST_Id"=c."AMST_Id" and h."FMA_Id"=a."FMA_Id" and a."asmay_id"=c."asmay_id" and a."MI_Id"=' || p_mi_id || ' and b."MI_Id"=' || p_mi_id || ' and a."ASMAY_Id"=' || p_ASMAY_ID || ' and c."ASMAY_Id"=' || p_ASMAY_ID || 'and e."MI_Id"=' || p_mi_id || ' and e."ASMCL_Id"