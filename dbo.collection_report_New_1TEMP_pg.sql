CREATE OR REPLACE FUNCTION "dbo"."collection_report_New_1TEMP"(
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
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_amst_sol TEXT;
    v_mi BIGINT;
    v_dt BIGINT;
    v_mt BIGINT;
    v_ftdd_day BIGINT;
    v_ftdd_month BIGINT;
    v_endyr BIGINT;
    v_startyr BIGINT;
    v_duedate TIMESTAMP;
    v_duedate1 TIMESTAMP;
    v_fromdate TIMESTAMP;
    v_todate TIMESTAMP;
    v_oResult VARCHAR(50);
    v_days VARCHAR(50);
    v_months VARCHAR(50);
    v_query TEXT;
    v_date TEXT;
    v_str1 TEXT;
    v_queryC1 TEXT;
    v_queryC2 TEXT;
    v_asmay_new BIGINT;
    v_query1 TEXT;
    v_query2 TEXT;
    v_query11 TEXT;
    v_query123 TEXT;
BEGIN

    v_amst_sol := '';
    v_mi := 0;
    v_ftdd_day := 0;
    v_ftdd_month := 0;
    v_endyr := 0;
    v_startyr := 0;
    v_days := '0';
    v_months := '0';
    v_dt := 0;
    v_mt := 0;

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
        v_date := 'CAST("Fee_Y_Payment"."fyp_date" AS DATE) between TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') and TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY'')  and "FYP_Bank_Or_Cash"=''C''';
    ELSIF p_cheque = '2' THEN
        v_date := 'CAST("Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE) between TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') and TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY'')  and "FYP_Bank_Or_Cash"=''B''';
    ELSIF p_cheque = '3' THEN
        v_date := '((CAST("Fee_Y_Payment"."fyp_date" AS DATE) between TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') and TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY''))) ';
    ELSIF p_cheque = '4' THEN
        v_date := '((CAST("Fee_Y_Payment"."fyp_date" AS DATE) between TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') and TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY'') and "FYP_Bank_Or_Cash"=''C'')  or ((CAST("Fee_Y_Payment"."FYP_DD_Cheque_Date" AS DATE)  between TO_DATE(''' || p_date1 || ''',''DD/MM/YYYY'') and TO_DATE(''' || p_date2 || ''',''DD/MM/YYYY''))and "FYP_Bank_Or_Cash"=''B''))';
    END IF;

    SELECT "MI_Id" INTO v_mi FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = p_ASMAY_ID::BIGINT;

    IF p_active = '1' AND p_deactive = '0' AND p_left = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1) and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF p_deactive = '1' AND p_active = '0' AND p_left = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=1)and ("Adm_M_Student"."AMST_SOL"=''D'') and ("Adm_M_Student"."AMST_ActiveFlag"=1)';
    ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=0)and ("Adm_M_Student"."AMST_SOL"=''L'') and ("Adm_M_Student"."AMST_ActiveFlag"=0)';
    ELSIF p_left = '1' AND p_active = '1' AND p_deactive = '0' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1))and ("Adm_M_Student"."AMST_SOL" in (''L'',''S'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF p_left = '1' AND p_active = '0' AND p_deactive = '1' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (0,1))and ("Adm_M_Student"."AMST_SOL" in (''L'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(0,1))';
    ELSIF p_left = '0' AND p_active = '1' AND p_deactive = '1' THEN
        v_amst_sol := 'and ("Adm_School_Y_Student"."AMAY_ActiveFlag" in (1)) and ("Adm_M_Student"."AMST_SOL" in (''S'',''D'')) and ("Adm_M_Student"."AMST_ActiveFlag" in(1))';
    ELSIF p_active = '1' AND p_deactive = '1' AND p_left = '1' THEN
        v_amst_sol := 'and ("Adm_M_Student"."AMST_SOL" IN (''S'',''D'',''L'')) ';
    END IF;

    IF p_type = 'year' THEN
        IF p_option = 'FSW' THEN
            IF p_term_group = 'T' THEN
                v_query := 'SELECT  (COALESCE("Adm_M_Student"."AMST_FirstName",'' '') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'' '') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'' '')) "StudentName", "Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName" as "ASMCL_ClassName","Adm_M_Student"."AMST_AdmNo",(SUM("fee_student_status"."FSS_PaidAmount")- SUM("fee_student_status"."FSS_FineAmount")) AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession", SUM("fee_student_status"."FSS_WaivedAmount") AS "waived", SUM("fee_student_status"."FSS_RebateAmount") AS "rebate", SUM("fee_student_status"."FSS_FineAmount") AS "fine",SUM("fee_student_status"."FSS_CurrentYrCharges") AS "totalpayable"
FROM   "fee_student_status" 
INNER JOIN "Adm_School_Y_Student" ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id"
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Master_Group" ON "fee_student_status"."fmg_id" = "Fee_Master_Group"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="fee_student_status"."FMH_Id" 
INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="fee_student_status"."FTI_Id"   
INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" =  "fee_student_status"."FMH_Id" and  "Fee_Master_Terms_FeeHeads"."FTI_Id"="fee_student_status"."FTI_Id"  
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" 
WHERE ("fee_student_status"."MI_Id" =' || p_mi_id || ')  AND ("Adm_M_Student"."MI_Id" =' || p_mi_id || ')  AND ("Adm_School_M_Class"."MI_Id" =' || p_mi_id || ') AND ("Fee_Master_Group"."MI_Id" =' || p_mi_id || ') AND ("Fee_Master_Head"."MI_Id" =' || p_mi_id || ') AND ("Fee_T_Installment"."MI_Id" =' || p_mi_id || ') AND ("Fee_Master_Terms_FeeHeads"."MI_Id" =' || p_mi_id || ') AND ("Adm_School_M_Section"."MI_Id" =' || p_mi_id || ') and
("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND  ("fee_student_status"."ASMAY_Id" = ' || p_ASMAY_ID || ')  and ("Fee_Master_Group"."FMG_Id" in(' || p_fmg_id || ')) and ("Fee_Master_Terms_FeeHeads"."FMT_Id" in (' || p_fmt_id || ')) ' || v_amst_sol || ' ' || v_str1 || ' 
GROUP BY "Adm_M_Student"."AMST_FirstName","Adm_M_Student"."AMST_MiddleName","Adm_M_Student"."AMST_LastName","Adm_M_Student"."AMST_AdmNo","Adm_School_M_Class"."ASMCL_ClassName" , "Adm_School_M_Section"."ASMC_SectionName" 
having SUM("fee_student_status"."FSS_PaidAmount")>0 or SUM("fee_student_status"."FSS_ToBePaid")>0 or SUM("fee_student_status"."FSS_ConcessionAmount")>0 or SUM("fee_student_status"."FSS_WaivedAmount")>0 or SUM("fee_student_status"."FSS_RebateAmount")>0 or SUM("fee_student_status"."FSS_FineAmount")>0  or SUM("fee_student_status"."FSS_CurrentYrCharges")>0   ';
            ELSE
                v_query := 'SELECT  (COALESCE("Adm_M_Student"."AMST_FirstName",'' '') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'' '') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'' '')) "StudentName","Adm_M_Student"."AMST_AdmNo", "Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName" as "ASMCL_ClassName" ,
(SUM("Fee_Student_Status"."FSS_PaidAmount")-SUM("Fee_Student_Status"."FSS_FineAmount")) AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "concession", 
SUM("Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("Fee_Student_Status"."FSS_RebateAmount") AS "rebate", 
SUM("Fee_Student_Status"."FSS_FineAmount") AS "fine",SUM("fee_student_status"."FSS_CurrentYrCharges") AS "totalpayable"
FROM "Fee_Student_Status" 
INNER JOIN "Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id" 
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Fee_Yearly_Group_Head_Mapping" ON "Fee_Student_Status"."FMG_Id" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" and "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id"=' || p_ASMAY_ID || '
and "Fee_Yearly_Group_Head_Mapping"."asmay_id"="Fee_Student_Status"."asmay_id"
INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" and "Fee_Student_Status"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id" 
INNER JOIN "Adm_School_M_Class" on "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" 
WHERE ("Fee_Student_Status"."MI_Id" = ' || p_mi_id || ') AND ("Adm_M_Student"."MI_Id" = ' || p_mi_id || ')  AND ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || p_mi_id || ')  AND ("Fee_Master_Group"."MI_Id" = ' || p_mi_id || ') AND ("Fee_Master_Head"."MI_Id" = ' || p_mi_id || ') AND ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || p_mi_id || ') AND ("Adm_School_M_Section"."MI_Id" = ' || p_mi_id || ') 
and ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND  ("fee_student_status"."ASMAY_Id" = ' || p_ASMAY_ID || ')  AND ("Fee_Master_Group"."FMG_Id" IN (' || p_fmg_id || ')) ' || v_amst_sol || ' ' || v_str1 || ' 
GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName","Adm_M_Student"."AMST_AdmNo","Adm_School_M_Class"."ASMCL_ClassName" , "Adm_School_M_Section"."ASMC_SectionName" 
having SUM("fee_student_status"."FSS_PaidAmount")>0 or SUM("fee_student_status"."FSS_ToBePaid")>0 or SUM("fee_student_status"."FSS_ConcessionAmount")>0 or SUM("fee_student_status"."FSS_WaivedAmount")>0 or SUM("fee_student_status"."FSS_RebateAmount")>0 or SUM("fee_student_status"."FSS_FineAmount")>0  or SUM("fee_student_status"."FSS_CurrentYrCharges")>0  ';
            END IF;
        ELSIF p_option = 'FGW' THEN
            IF p_term_group = 'T' THEN
                v_query := 'SELECT distinct "Fee_Master_Group"."FMG_GroupName", (SUM("fee_student_status"."FSS_PaidAmount")- SUM("fee_student_status"."FSS_FineAmount"))AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("Fee_Student_Status"."FSS_ConcessionAmount") 
AS "concession", SUM("Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("Fee_Student_Status"."FSS_RebateAmount") AS "rebate", 
SUM("Fee_Student_Status"."FSS_FineAmount") AS "fine",SUM("fee_student_status"."FSS_CurrentYrCharges") AS "totalpayable"
FROM "Fee_Student_Status" 
INNER JOIN "Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id"
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"  
INNER JOIN "Fee_Master_Group" ON "Fee_Student_Status"."FMG_Id" = "Fee_Master_Group"."FMG_Id"  
INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"  
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" 
INNER JOIN  "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id" 
WHERE ("Fee_Student_Status"."MI_Id" =  ' || p_Mi_Id || ') AND ("Adm_M_Student"."MI_Id" =' || p_Mi_Id || ') AND ("Adm_School_M_Class"."MI_Id" =' || p_Mi_Id || ') AND ("Fee_Master_Group"."MI_Id" =' || p_Mi_Id || ') AND ("Fee_Master_Head"."MI_Id" =' || p_Mi_Id || ') AND ("Adm_School_M_Section"."MI_Id"=' || p_Mi_Id || ') AND ("Fee_Master_Terms_FeeHeads"."MI_Id"=' || p_Mi_Id || ')
AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || p_ASMAY_ID || ')  AND ("Fee_Master_Group"."FMG_Id" IN (' || p_fmg_id || '))  and ("fee_student_status"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_fmt_id || '))  ' || v_amst_sol || '
GROUP BY  "Fee_Master_Group"."FMG_GroupName"';
            ELSE
                v_query := 'SELECT  "Fee_Master_Group"."FMG_GroupName", (SUM("Fee_Student_Status"."FSS_PaidAmount")-SUM("Fee_Student_Status"."FSS_FineAmount")) AS "FSS_PaidAmount", SUM("fee_student_status"."FSS_ToBePaid") AS "balance", SUM("Fee_Student_Status"."FSS_ConcessionAmount") 
AS "concession", SUM("Fee_Student_Status"."FSS_WaivedAmount") AS "waived", SUM("Fee_Student_Status"."FSS_RebateAmount") AS "rebate", 
SUM("Fee_Student_Status"."FSS_FineAmount") AS "fine",SUM("fee_student_status"."FSS_CurrentYrCharges") AS "totalpayable"
FROM "Fee_Student_Status" 
INNER JOIN "Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id"
INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"  
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Fee_Yearly_Group_Head_Mapping" ON "Fee_Student_Status"."FMG_Id" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" AND "Fee_Student_Status"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id" and "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id"=' || p_ASMAY_ID || '
INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id"   
WHERE ("Fee_Student_Status"."MI_Id" = ' || p_Mi_Id || ') AND ("Adm_M_Student"."MI_Id" = ' || p_Mi_Id || ') AND ("Adm_School_M_Class"."MI_Id" = ' || p_Mi_Id || ') AND ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || p_Mi_Id || ') AND ("Fee_Master_Group"."MI_Id" = ' || p_Mi_Id || ') AND ("Fee_Master_Head"."MI_Id" = ' || p_Mi_Id || ')
AND ("Adm_School_Y_Student"."ASMAY_Id" =  ' || p_ASMAY_ID || ')  and ("fee_student_status"."ASMAY_Id" = ' || p_ASMAY_ID || ') AND  ("Fee_Master_Group"."FMG_Id" IN (' || p_fmg_id || ')) ' || v_amst_sol || '
GROUP BY "Fee_Master_Group"."FMG_GroupName"';
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
            ELSIF p_active = '1' AND p_deactive = '1' AND p_left = '1' THEN
                v_amst_sol := 'and (b."AMST_SOL" IN (''S'',''D'',''L'')) ';
            END IF;

            v_query := 'select distinct j."FMH_Id",k."FMT_Id",k."FMT_Name","FMH_FeeName", sum(a."FSS_OBArrearAmount") "Arrear",sum(a."FSS_OBExcessAmount") "Excess",sum(a."FSS_ToBePaid") "Balance",sum(a."FSS_PaidAmount")"Paid",(sum(a."FSS_TotalToBePaid")-sum(a."FSS_ConcessionAmount")) as "Payable",sum(a."FSS_ConcessionAmount")as "Concession",sum(a."FSS_CurrentYrCharges") "Charges"   
from "Fee_Student_Status" a, "Adm_M_Student" b,"Adm_School_Y_Student" c,  "Adm_School_M_Class"  e,"Adm_School_M_Section"  f,"Fee_T_Installment" g  ,"Fee_Master_Amount" h  ,
"Fee_Master_Terms_FeeHeads" i,"Fee_Master_Head" j,"Fee_Master_Terms" k
where a."AMST_Id"=b."AMST_Id" and b."AMST_Id"=c."AMST_Id" and  h."FMA_Id"=a."FMA_Id" and a."asmay_id"=c."asmay_id"  and a."MI_Id"=' || p_mi_id || ' and b."MI_Id"=' || p_mi_id || ' and  a."ASMAY_Id"=' || p_ASMAY_ID || ' and c."ASMAY_Id"=' || p_ASMAY_ID || 'and e."MI_Id"=' || p_mi_id || ' and  e."ASMCL_Id"=c."ASMCL_Id" and  f."MI