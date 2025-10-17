CREATE OR REPLACE FUNCTION "dbo"."fee_report_details"(
    p_asmay_id VARCHAR(10),
    p_asmcl_id VARCHAR(10),
    p_asms_id VARCHAR(10),
    p_fmh_id VARCHAR(10),
    p_fmt_ids TEXT,
    p_type VARCHAR(10),
    p_trmr_id VARCHAR(10),
    p_mi_id VARCHAR(10),
    p_userid VARCHAR(10),
    p_active VARCHAR(50),
    p_deactive VARCHAR(50),
    p_left VARCHAR(50),
    p_report VARCHAR(50),
    p_details VARCHAR(50)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
    v_amst_sol TEXT;
    v_sql1 TEXT;
    v_sql2 TEXT;
BEGIN
    IF p_fmh_id = '0' THEN
        v_sql1 := ' ';
    ELSE
        v_sql1 := 'and "dbo"."Fee_Master_Head"."fmh_id"=' || p_fmh_id || '';
    END IF;

    IF p_asmcl_id = '0' THEN
        v_sql2 := ' ';
    ELSE
        IF p_asms_id = '0' THEN
            v_sql2 := 'AND ("dbo"."Adm_School_Y_Student"."ASMCL_Id" = ' || p_asmcl_id || ')';
        ELSE
            v_sql2 := 'AND ("dbo"."Adm_School_Y_Student"."ASMCL_Id" = ' || p_asmcl_id || ')AND ("dbo"."Adm_School_Y_Student"."ASMS_Id" = ' || p_asms_id || ') ';
        END IF;
    END IF;

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
    ELSE
        v_amst_sol := ' ';
    END IF;

    IF p_report = 'all' THEN
        IF p_trmr_id = '0' THEN
            IF p_type = 'FSW' THEN
                v_query := 'SELECT distinct (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'''')) StudentName, "dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName" as ASMCL_ClassName, sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount") as FSS_OBArrearAmount, sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") as FSS_OBExcessAmount, sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") as FSS_WaivedAmount, sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount") as FSS_AdjustedAmount, sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") as FSS_RefundAmount
FROM "dbo"."Fee_Master_Head" INNER JOIN
"dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" INNER JOIN
"dbo"."Fee_Student_Status" INNER JOIN
"dbo"."Adm_M_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" ON 
"dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND 
"dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || p_asmay_id || ') and ("dbo"."Fee_Student_Status"."MI_Id"=' || p_mi_id || ') ' || v_sql2 || ' AND 
("dbo"."Fee_Student_Status"."User_Id" = ' || p_userid || ') ' || v_sql1 || ' AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_fmt_ids || ')) ' || v_amst_sol || ' and "FMH_Flag" not in (''E'',''F'')
group by "ASMCL_ClassName","ASMC_SectionName","AMST_FirstName","AMST_MiddleName","AMST_LastName"
having sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") >0';
            ELSIF p_type = 'FRW' THEN
                v_query := 'SELECT distinct "TRMR_RouteName", sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount") as FSS_OBArrearAmount, sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") as FSS_OBExcessAmount, sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") as FSS_WaivedAmount, sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount") as FSS_AdjustedAmount, sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") as FSS_RefundAmount
FROM "dbo"."Fee_Master_Head" INNER JOIN
"dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" INNER JOIN
"dbo"."Fee_Student_Status" INNER JOIN
"dbo"."Adm_M_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" ON 
"dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND 
"dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
inner join "trn"."TR_Student_Route" on "trn"."TR_Student_Route"."AMST_Id"="dbo"."Fee_Student_Status"."AMST_Id"
inner join "trn"."TR_Master_Route" on "trn"."TR_Master_Route"."TRMR_Id"="trn"."TR_Student_Route"."TRMR_Id"
WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || p_asmay_id || ') and ("dbo"."Fee_Student_Status"."MI_Id"=' || p_mi_id || ') ' || v_sql2 || ' AND 
("dbo"."Fee_Student_Status"."User_Id" = ' || p_userid || ') ' || v_sql1 || ' AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_fmt_ids || ')) ' || v_amst_sol || ' and "FMH_Flag" not in (''E'',''F'')
group by "TRMR_RouteName"
having sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") >0';
            ELSIF p_type = 'FHW' THEN
                v_query := 'SELECT distinct "dbo"."Fee_Master_Head"."FMH_FeeName", sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount") as FSS_OBArrearAmount, sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") as FSS_OBExcessAmount, sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") as FSS_WaivedAmount, sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount") as FSS_AdjustedAmount, sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") as FSS_RefundAmount
FROM "dbo"."Fee_Master_Head" INNER JOIN
"dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" INNER JOIN
"dbo"."Fee_Student_Status" INNER JOIN
"dbo"."Adm_M_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" ON 
"dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND 
"dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || p_asmay_id || ') and ("dbo"."Fee_Student_Status"."MI_Id"=' || p_mi_id || ') ' || v_sql2 || ' AND 
("dbo"."Fee_Student_Status"."User_Id" = ' || p_userid || ') ' || v_sql1 || ' AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_fmt_ids || ')) ' || v_amst_sol || ' and "FMH_Flag" not in (''E'',''F'')
group by "dbo"."Fee_Master_Head"."FMH_FeeName"
having sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") >0';
            ELSE
                v_query := 'SELECT distinct "dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName" as ASMCL_ClassName, sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount") as FSS_OBArrearAmount, sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") as FSS_OBExcessAmount, sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") as FSS_WaivedAmount, sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount") as FSS_AdjustedAmount, sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") as FSS_RefundAmount
FROM "dbo"."Fee_Master_Head" INNER JOIN
"dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" INNER JOIN
"dbo"."Fee_Student_Status" INNER JOIN
"dbo"."Adm_M_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" ON 
"dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND 
"dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || p_asmay_id || ') and ("dbo"."Fee_Student_Status"."MI_Id"=' || p_mi_id || ') ' || v_sql2 || ' AND 
("dbo"."Fee_Student_Status"."User_Id" = ' || p_userid || ') ' || v_sql1 || ' AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_fmt_ids || ')) ' || v_amst_sol || ' and "FMH_Flag" not in (''E'',''F'')
group by "ASMCL_ClassName","ASMC_SectionName"
having sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") >0';
            END IF;
        ELSE
            v_query := 'SELECT distinct (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'''')) StudentName, "dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName" as ASMCL_ClassName, sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount") as FSS_OBArrearAmount, sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") as FSS_OBExcessAmount, sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") as FSS_WaivedAmount, sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount") as FSS_AdjustedAmount, sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") as FSS_RefundAmount
FROM "dbo"."Fee_Master_Head" INNER JOIN
"dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" INNER JOIN
"dbo"."Fee_Student_Status" INNER JOIN
"dbo"."Adm_M_Student" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" ON 
"dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND 
"dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
inner join "trn"."TR_Student_Route" on "trn"."TR_Student_Route"."AMST_Id"="dbo"."Fee_Student_Status"."AMST_Id"
WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || p_asmay_id || ') and ("dbo"."Fee_Student_Status"."MI_Id"=' || p_mi_id || ')
' || v_sql1 || ' AND ("dbo"."Fee_Student_Status"."User_Id" = ' || p_userid || ') AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_fmt_ids || '))
and ("trn"."TR_Student_Route"."TRMR_Id"=' || p_trmr_id || ') ' || v_amst_sol || ' ' || v_sql2 || ' and "FMH_Flag" not in (''E'',''F'')
group by "ASMCL_ClassName","ASMC_SectionName","AMST_FirstName","AMST_MiddleName","AMST_LastName"
having sum("dbo"."Fee_Student_Status"."FSS_OBArrearAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RunningExcessAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_WaivedAmount") >0 or sum("dbo"."Fee_Student_Status"."FSS_AdjustedAmount")>0 or sum("dbo"."Fee_Student_Status"."FSS_RefundAmount") >0';
        END IF;
    ELSE
        IF p_details = 'WO' THEN
            v_query := 'select sum("FSS_NetAmount") as FSS_TotalToBePaid,sum("FSS_ToBePaid") as FSS_ToBePaid,sum("FSS_PaidAmount") as FSS_PaidAmount,sum("FSS_WaivedAmount") as FSS_WaivedAmount,"FMH_FeeName",(COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'''')) StudentName,"dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName" as ASMCL_ClassName
FROM "dbo"."Fee_Student_Status" INNER JOIN
"dbo"."Adm_M_Student" on "Fee_Student_Status"."amst_id"="adm_M_student"."AMST_Id" INNER JOIN
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "Fee_Student_Status"."ASMAY_Id"="Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "dbo"."Fee_Master_Head" on "Fee_Master_Head"."FMH_Id"="Fee_Student_Status"."FMH_Id" INNER JOIN
"dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
inner join "Fee_Master_Terms_FeeHeads" on "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" and "Fee_Master_Terms_FeeHeads"."fti_id"="Fee_Student_Status"."FTI_Id"
WHERE ("Fee_Student_Status"."MI_Id" = ' || p_mi_id || ') AND ("Fee_Student_Status"."ASMAY_Id" = ' || p_asmay_id || ') and ("Adm_School_Y_Student"."ASMAY_Id"=' || p_asmay_id || ') ' || v_sql2 || ' ' || v_sql1 || ' and "Fee_Student_Status"."User_Id"=' || p_userid || ' and "FMH_Flag" not in (''E'',''F'') ' || v_amst_sol || '
group by "AMST_FirstName","AMST_MiddleName","AMST_LastName","ASMCL_ClassName","ASMC_SectionName","FMH_FeeName"
having sum("FSS_WaivedAmount")>0
order by "ASMCL_ClassName","ASMC_SectionName"';
        ELSIF p_details = 'OB' THEN
            v_query := 'select (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'' '') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'' '')) StudentName, "dbo"."Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "dbo"."Adm_School_M_Section"."ASMC_SectionName" as ASMCL_ClassName, "Fee_Master_Head"."FMH_FeeName",sum("FSS_OBArrearAmount") FMOB_Student_Due,sum("FSS_OBExcessAmount") FMOB_Institution_Due,sum("FSS_PaidAmount") FSS_PaidAmount,sum("FSS_ToBePaid") FSS_ToBePaid, 
Abs(sum("FSS_TotalToBePaid")) FSS_TotalToBePaid
,TO_CHAR("FMOB_EntryDate",''DD/MM/YYYY'') FSWO_Date
from "dbo"."Fee_Student_Status" INNER JOIN
"dbo"."Adm_M_Student" INNER JOIN
"dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN
"dbo"."Fee_Master_Head" INNER JOIN
"dbo"."Fee_Master_Opening_Balance" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Master_Opening_Balance"."FMH_Id" ON 
"dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_Master_Opening_Balance"."AMST_Id" ON 
"dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Fee_Master_Opening_Balance"."AMST_Id" AND 
"dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Opening_Balance"."FMH_Id" INNER JOIN
"dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"dbo"."Adm_School_M_Section" ON "dbo"."