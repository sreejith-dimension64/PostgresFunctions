CREATE OR REPLACE FUNCTION "dbo"."Fee_Arrear_Report1"(
    "amay_id" VARCHAR(50),
    "asmcl_id" VARCHAR(50),
    "amcl_id" VARCHAR(50),
    "amst_id" BIGINT,
    "fmt_id" VARCHAR(50),
    "mi_id" VARCHAR(50),
    "fmg_id" VARCHAR(50)
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
    "FMT_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "fti_id" TEXT;
    "fmh_id" TEXT;
    "sqlinstall" TEXT;
    "sqlhead" TEXT;
    "monthyearsd" TEXT;
    "headid" TEXT;
    "query" TEXT;
    "temp" BIGINT;
    "temphead" BIGINT;
    "Row_count" BIGINT;
BEGIN
    "temp" := 0;
    "temphead" := 0;
    "headid" := 'D%';
    "sqlhead" := 'NULL';

    "query" := ';with cte as(SELECT DISTINCT "Adm_M_Student"."AMST_Id", COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as "Name", "Adm_M_Student"."AMST_AdmNo", case when "Fee_Y_Payment"."fyp_receipt_no" like ''' || "headid" || ''' or "Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' Then '' '' else "Fee_Y_Payment"."fyp_receipt_no" end as fyp_receipt_no, case when "Fee_Y_Payment"."fyp_receipt_no" like ''' || "headid" || ''' or "Fee_Y_Payment"."fyp_receipt_no" !~ ''[^0-9]'' then '' '' else to_char("Fee_Y_Payment"."FYP_Date"::DATE, ''DD/MM/YYYY'') end as date, sum("Fee_Student_Status"."FSS_ToBePaid") AS "Balance", sum("Fee_Student_Status"."FSS_PaidAmount") AS paid, sum("Fee_Student_Status"."fss_totaltobepaid") as total, "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Fee_Master_Terms"."FMT_Name", "Fee_Master_Terms"."fmt_id" 
FROM "Fee_Student_Status" INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id" INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id" INNER JOIN "Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN 
"Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms_FeeHeads"."FMT_Id" = "Fee_Master_Terms"."FMT_Id" inner join "Adm_School_M_Academic_Year" on "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" and "Adm_School_M_Academic_Year"."ASMAY_Id" = "fee_student_status"."ASMAY_Id" 
WHERE ("Adm_School_Y_Student"."asmay_id" = ''' || "amay_id" || ''') and ("Adm_M_Student"."AMST_SOL" = ''S'') and ("Fee_Y_Payment"."MI_Id" = ''' || "mi_id" || ''') AND ("Fee_Student_Status"."FMH_Id" NOT IN (100)) AND ("Fee_Master_Terms_FeeHeads"."FMT_Id" in (' || "fmt_id" || ')) and ("Adm_School_M_Class"."asmcl_id" = ' || "asmcl_id" || ') and ("Adm_School_M_Section"."asms_id" = ' || "amcl_id" || ') and ("Fee_Student_Status"."FSS_PaidAmount" > 0 or "Fee_Student_Status"."FSS_ToBePaid" > 0) and ("Fee_Student_Status"."FMG_Id" IN(select distinct "FMG_Id" from "Fee_Master_Group_Grouping" inner join "Fee_Master_Group_Grouping_Groups" on 
"Fee_Master_Group_Grouping"."FMGG_Id" = "Fee_Master_Group_Grouping_Groups"."FMGG_Id" where "FMGG_GroupCode" = ''1'' and "FMGG_ActiveFlag" = 1 and "MI_Id" = ''' || "mi_id" || ''' and "Fee_Master_Group_Grouping"."FMGG_Id" in (' || "fmg_id" || '))) group by "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "AMST_AdmNo", fyp_receipt_no, "FYP_Date", "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Fee_Master_Terms"."FMT_Name", "Fee_Master_Terms"."fmt_id") select "AMST_Id", "Name", "AMST_AdmNo", fyp_receipt_no, replace(date::TEXT, ''01/01/1900'', '' '') as date, sum("Balance") as "Balance", sum(paid) as paid, sum(total) as "Total", "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name", "FMT_Id" from cte group by "AMST_Id", "AMST_AdmNo", "Name", fyp_receipt_no, date, "ASMCL_ClassName", "ASMC_SectionName", "FMT_Name", fmt_id';

    RETURN QUERY EXECUTE "query";

END;
$$;