CREATE OR REPLACE FUNCTION "dbo"."Fee_Arrear_Report_user_new"(
    p_amay_id VARCHAR(50),
    p_asmcl_id VARCHAR(50),
    p_amcl_id VARCHAR(50),
    p_amst_id BIGINT,
    p_fmt_id VARCHAR(50),
    p_mi_id VARCHAR(50),
    p_fmg_id VARCHAR(50),
    p_userid VARCHAR(50),
    p_fmgg_id VARCHAR(50),
    p_trmr_id VARCHAR(50)
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "Name" TEXT,
    "AMST_AdmNo" TEXT,
    "fyp_receipt_no" TEXT,
    "date" TEXT,
    "Balance" NUMERIC,
    "paid" NUMERIC,
    "Total" NUMERIC,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "FMT_Name" TEXT,
    "FMT_Id" BIGINT,
    "TRMR_RouteName" TEXT,
    "FMCC_ConcessionName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_fti_id TEXT;
    v_fmh_id TEXT;
    v_sqlinstall TEXT;
    v_sqlhead TEXT;
    v_monthyearsd TEXT;
    v_headid TEXT;
    v_query TEXT;
    v_temp BIGINT;
    v_temphead BIGINT;
    v_Row_count BIGINT;
BEGIN

    IF p_amst_id = 1 THEN
    
        v_temp := 0;
        v_temphead := 0;
        
        v_headid := 'D%';
        v_sqlhead := 'NULL';
        
        IF p_mi_id = '4' THEN
        
            IF p_userid = '364' THEN
            
                IF p_trmr_id = '0' THEN
                
                    v_query := ';with cte as(SELECT DISTINCT "Adm_M_Student"."AMST_Id", COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'''') as Name, "dbo"."Adm_M_Student"."AMST_AdmNo", case when "dbo"."Fee_Y_Payment"."fyp_receipt_no" like ''' || v_headid || ''' or "dbo"."Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' Then '' '' else "dbo"."Fee_Y_Payment"."fyp_receipt_no" end as fyp_receipt_no, case when "dbo"."Fee_Y_Payment"."fyp_receipt_no" like ''' || v_headid || ''' or "dbo"."Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' then '' '' else "dbo"."Fee_Y_Payment"."FYP_Date"::date::text end as date, sum("dbo"."Fee_Student_Status"."FSS_ToBePaid") AS Balance, sum("dbo"."Fee_Student_Status"."FSS_PaidAmount") AS paid, sum("dbo"."Fee_Student_Status"."fss_totaltobepaid") as total, "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Fee_Master_Terms"."FMT_Name", "dbo"."Fee_Master_Terms"."fmt_id", "trn"."TR_Master_Route"."TRMR_RouteName", "FMCC_ConcessionName"      
FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id" INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN 
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" INNER JOIN "dbo"."Fee_Master_Terms" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" = "dbo"."Fee_Master_Terms"."FMT_Id" inner join "Adm_School_M_Academic_Year" on "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" and "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" 
inner join "trn"."TR_Student_Route" on "trn"."TR_Student_Route"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
inner join "trn"."TR_Master_Route" on "trn"."TR_Student_Route"."TRMR_Id" = "trn"."TR_Master_Route"."TRMR_Id" inner join "Fee_Master_Concession" on "Fee_Master_Concession"."FMCC_Id" = "Adm_M_Student"."AMST_Concession_Type"
WHERE ("dbo"."Adm_School_Y_Student"."asmay_id" = ''' || p_amay_id || ''') and ("Adm_M_Student"."AMST_ActiveFlag" = true) and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = true) and ("dbo"."Adm_M_Student"."AMST_SOL" = ''S'') and ("Fee_Y_Payment"."user_id" = ''' || p_userid || ''') and ("dbo"."Fee_Y_Payment"."MI_Id" = ''' || p_mi_id || ''') AND ("dbo"."Fee_Student_Status"."FMH_Id" NOT IN (100)) AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" in (' || p_fmt_id || ')) and ("dbo"."Adm_School_M_Class"."asmcl_id" = ' || p_asmcl_id || ') and ("dbo"."Adm_School_M_Section"."asms_id" = ' || p_amcl_id || ') and ("Fee_Student_Status"."FSS_PaidAmount" > 0 or "Fee_Student_Status"."FSS_ToBePaid" > 0) and ("dbo"."Fee_Student_Status"."FMG_Id" IN(select distinct "FMG_Id" from "Fee_Master_Group_Grouping" inner join "Fee_Master_Group_Grouping_Groups" on 
"Fee_Master_Group_Grouping"."FMGG_Id" = "Fee_Master_Group_Grouping_Groups"."FMGG_Id" where "FMGG_GroupCode" = ''1'' and "FMGG_ActiveFlag" = true and "MI_Id" = ''' || p_mi_id || ''' and "Fee_Master_Group_Grouping"."FMGG_Id" in (' || p_fmgg_id || '))) group by "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "AMST_AdmNo", "fyp_receipt_no", "FYP_Date", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Fee_Master_Terms"."FMT_Name", "dbo"."Fee_Master_Terms"."fmt_id", "trn"."TR_Master_Route"."TRMR_RouteName", "FMCC_ConcessionName" ) select "AMST_Id", "Name", "AMST_AdmNo", "fyp_receipt_no", replace(date::text, ''1900-01-01'', '' '') as date, sum("Balance") as Balance, sum("paid") as paid, sum("total") as Total, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name", "FMT_Id", "TRMR_RouteName", "FMCC_ConcessionName" from cte group by "AMST_Id", "AMST_AdmNo", "Name", "fyp_receipt_no", date, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name", "fmt_id", "TRMR_RouteName", "FMCC_ConcessionName"';
                
                ELSE
                
                    v_query := ';with cte as(SELECT DISTINCT "Adm_M_Student"."AMST_Id", COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'''') as Name, "dbo"."Adm_M_Student"."AMST_AdmNo", case when "dbo"."Fee_Y_Payment"."fyp_receipt_no" like ''' || v_headid || ''' or "dbo"."Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' Then '' '' else "dbo"."Fee_Y_Payment"."fyp_receipt_no" end as fyp_receipt_no, case when "dbo"."Fee_Y_Payment"."fyp_receipt_no" like ''' || v_headid || ''' or "dbo"."Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' then '' '' else "dbo"."Fee_Y_Payment"."FYP_Date"::date::text end as date, sum("dbo"."Fee_Student_Status"."FSS_ToBePaid") AS Balance, sum("dbo"."Fee_Student_Status"."FSS_PaidAmount") AS paid, sum("dbo"."Fee_Student_Status"."fss_totaltobepaid") as total, "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Fee_Master_Terms"."FMT_Name", "dbo"."Fee_Master_Terms"."fmt_id", "trn"."TR_Master_Route"."TRMR_RouteName", "FMCC_ConcessionName"      
FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id" INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN 
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" INNER JOIN "dbo"."Fee_Master_Terms" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" = "dbo"."Fee_Master_Terms"."FMT_Id" inner join "Adm_School_M_Academic_Year" on "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" and "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" 
inner join "trn"."TR_Student_Route" on "trn"."TR_Student_Route"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
inner join "trn"."TR_Master_Route" on "trn"."TR_Student_Route"."TRMR_Id" = "trn"."TR_Master_Route"."TRMR_Id" inner join "Fee_Master_Concession" on "Fee_Master_Concession"."FMCC_Id" = "Adm_M_Student"."AMST_Concession_Type"
WHERE ("dbo"."Adm_School_Y_Student"."asmay_id" = ''' || p_amay_id || ''') and ("Adm_M_Student"."AMST_ActiveFlag" = true) and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = true) and ("dbo"."Adm_M_Student"."AMST_SOL" = ''S'') and ("Fee_Y_Payment"."user_id" = ''' || p_userid || ''') and ("dbo"."Fee_Y_Payment"."MI_Id" = ''' || p_mi_id || ''') AND ("dbo"."Fee_Student_Status"."FMH_Id" NOT IN (100)) AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" in (' || p_fmt_id || ')) and ("Fee_Student_Status"."FSS_PaidAmount" > 0 or "Fee_Student_Status"."FSS_ToBePaid" > 0) and ("dbo"."Fee_Student_Status"."FMG_Id" IN(select distinct "FMG_Id" from "Fee_Master_Group_Grouping" inner join "Fee_Master_Group_Grouping_Groups" on 
"Fee_Master_Group_Grouping"."FMGG_Id" = "Fee_Master_Group_Grouping_Groups"."FMGG_Id" where "FMGG_GroupCode" = ''1'' and "FMGG_ActiveFlag" = true and "MI_Id" = ''' || p_mi_id || ''' and "Fee_Master_Group_Grouping"."FMGG_Id" in (' || p_fmgg_id || '))) and ("trn"."TR_Master_Route"."TRMR_Id" = ' || p_trmr_id || ') group by "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "AMST_AdmNo", "fyp_receipt_no", "FYP_Date", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Fee_Master_Terms"."FMT_Name", "dbo"."Fee_Master_Terms"."fmt_id", "trn"."TR_Master_Route"."TRMR_RouteName", "FMCC_ConcessionName" ) select "AMST_Id", "Name", "AMST_AdmNo", "fyp_receipt_no", replace(date::text, ''1900-01-01'', '' '') as date, sum("Balance") as Balance, sum("paid") as paid, sum("total") as Total, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name", "FMT_Id", "TRMR_RouteName", "FMCC_ConcessionName" from cte group by "AMST_Id", "AMST_AdmNo", "Name", "fyp_receipt_no", date, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name", "fmt_id", "TRMR_RouteName", "FMCC_ConcessionName"';
                
                END IF;
            
            ELSE
            
                v_query := ';with cte as(SELECT DISTINCT "Adm_M_Student"."AMST_Id", COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'''') as Name, "dbo"."Adm_M_Student"."AMST_AdmNo", case when "dbo"."Fee_Y_Payment"."fyp_receipt_no" like ''' || v_headid || ''' or "dbo"."Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' Then '' '' else "dbo"."Fee_Y_Payment"."fyp_receipt_no" end as fyp_receipt_no, case when "dbo"."Fee_Y_Payment"."fyp_receipt_no" like ''' || v_headid || ''' or "dbo"."Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' then '' '' else "dbo"."Fee_Y_Payment"."FYP_Date"::date::text end as date, sum("dbo"."Fee_Student_Status"."FSS_ToBePaid") AS Balance, sum("dbo"."Fee_Student_Status"."FSS_PaidAmount") AS paid, sum("dbo"."Fee_Student_Status"."fss_totaltobepaid") as total, "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Fee_Master_Terms"."FMT_Name", "dbo"."Fee_Master_Terms"."fmt_id"      
FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id" INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN 
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" INNER JOIN "dbo"."Fee_Master_Terms" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" = "dbo"."Fee_Master_Terms"."FMT_Id" inner join "Adm_School_M_Academic_Year" on "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" and "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" 
WHERE ("dbo"."Adm_School_Y_Student"."asmay_id" = ''' || p_amay_id || ''') and ("Adm_M_Student"."AMST_ActiveFlag" = true) and ("Adm_School_Y_Student"."AMAY_ActiveFlag" = true) and ("dbo"."Adm_M_Student"."AMST_SOL" = ''S'') and ("Fee_Y_Payment"."user_id" = ''' || p_userid || ''') and ("dbo"."Fee_Y_Payment"."MI_Id" = ''' || p_mi_id || ''') AND ("dbo"."Fee_Student_Status"."FMH_Id" NOT IN (100)) AND ("dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" in (' || p_fmt_id || ')) and ("dbo"."Adm_School_M_Class"."asmcl_id" = ' || p_asmcl_id || ') and ("dbo"."Adm_School_M_Section"."asms_id" = ' || p_amcl_id || ') and ("Fee_Student_Status"."FSS_PaidAmount" > 0 or "Fee_Student_Status"."FSS_ToBePaid" > 0) and ("dbo"."Fee_Student_Status"."FMG_Id" IN(select distinct "FMG_Id" from "Fee_Master_Group_Grouping" inner join "Fee_Master_Group_Grouping_Groups" on 
"Fee_Master_Group_Grouping"."FMGG_Id" = "Fee_Master_Group_Grouping_Groups"."FMGG_Id" where "FMGG_GroupCode" = ''1'' and "FMGG_ActiveFlag" = true and "MI_Id" = ''' || p_mi_id || ''' and "Fee_Master_Group_Grouping"."FMGG_Id" in (' || p_fmgg_id || '))) group by "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "AMST_AdmNo", "fyp_receipt_no", "FYP_Date", "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Fee_Master_Terms"."FMT_Name", "dbo"."Fee_Master_Terms"."fmt_id" ) select "AMST_Id", "Name", "AMST_AdmNo", "fyp_receipt_no", replace(date::text, ''1900-01-01'', '' '') as date, sum("Balance") as Balance, sum("paid") as paid, sum("total") as Total, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name", "FMT_Id", NULL::TEXT as TRMR_RouteName, NULL::TEXT as FMCC_ConcessionName from cte group by "AMST_Id", "AMST_AdmNo", "Name", "fyp_receipt_no", date, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name", "fmt_id"';
            
            END IF;
        
        ELSE
        
            v_query := ';with cte as(SELECT DISTINCT "Adm_M_Student"."AMST_Id", COALESCE("dbo"."Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName",'''') as Name, "dbo"."Adm_M_Student"."AMST_AdmNo", case when "dbo"."Fee_Y_Payment"."fyp_receipt_no" like ''' || v_headid || ''' or "dbo"."Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' Then '' '' else "dbo"."Fee_Y_Payment"."fyp_receipt_no" end as fyp_receipt_no, case when "dbo"."Fee_Y_Payment"."fyp_receipt_no" like ''' || v_headid || ''' or "dbo"."Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' then '' '' else "dbo"."Fee_Y_Payment"."FYP_Date"::date::text end as date, sum("dbo"."Fee_Student_Status"."FSS_ToBePaid") AS Balance, sum("dbo"."Fee_Student_Status"."FSS_PaidAmount") AS paid, sum("dbo"."Fee_Student_Status"."fss_totaltobepaid") as total, "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Fee_Master_Terms"."FMT_Name", "dbo"."Fee_Master_Terms"."fmt_id"      
FROM "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id" INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" INNER JOIN 
"dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" INNER JOIN "dbo"."Fee_Master_Terms" ON "dbo"."Fee_Master