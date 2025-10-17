
CREATE OR REPLACE FUNCTION "dbo"."Fee_DetailedAccountPosition_AsonDate_FY_temp123"(
    "mi_id" BIGINT,
    "asmay_Id" BIGINT,
    "asmcl_id" BIGINT,
    "amsc_id" BIGINT,
    "fmgg_id" TEXT,
    "fmg_id" TEXT,
    "date" VARCHAR(50),
    "fromdate" VARCHAR(50),
    "todate" VARCHAR(50),
    "Type" VARCHAR(60),
    "fmt_id" TEXT,
    "status" TEXT,
    "asonduedate" VARCHAR(50)
)
RETURNS VOID AS $$
DECLARE
    "aa" TEXT;
    "where_condition" TEXT;
    "sqlquery" TEXT;
    "OnAnyDate" TEXT;
    "ASMAY_From_Date" VARCHAR(10);
    "SqlqueryC" TEXT;
    "trmr_id" BIGINT;
    "RouteName" VARCHAR(100);
    "Charges" BIGINT;
    "Concession" BIGINT;
    "Rebate" BIGINT;
    "Waive" BIGINT;
    "Fine" BIGINT;
    "Collection" BIGINT;
    "Debit" BIGINT;
    "LastYear" BIGINT;
    "IndRoute" REFCURSOR;
    "routecursor" REFCURSOR;
    "DynamicD1" TEXT;
    "DynamicD2" TEXT;
    "DynamicD3" TEXT;
    "DynamicD4" TEXT;
BEGIN

    IF "fromdate" != '' AND "todate" != '' THEN
        SELECT "ASMAY_FYStartDate", "ASMAY_FYEndDate" 
        INTO "ASMAY_From_Date", "asonduedate"
        FROM "Adm_School_M_Academic_Year" 
        WHERE "ASMAY_Id" = "asmay_Id";
    ELSIF "asonduedate" != '' THEN
        SELECT "ASMAY_FYStartDate" 
        INTO "ASMAY_From_Date"
        FROM "Adm_School_M_Academic_Year" 
        WHERE "ASMAY_Id" = "asmay_Id";
        
        "where_condition" := 'and ((CAST("FYP_Date" AS DATE)) between ''' || "ASMAY_From_Date" || ''' and ''' || "date" || ''')  ';
    ELSE
        "where_condition" := '';
    END IF;

    DROP TABLE IF EXISTS "IndRoute";
    
    CREATE TEMP TABLE "IndRoute"(
        "RouteName" VARCHAR(100),
        "Charges" BIGINT,
        "Concession" BIGINT,
        "Rebate" BIGINT,
        "Waive" BIGINT,
        "Fine" BIGINT,
        "Collection" BIGINT,
        "Debit" BIGINT,
        "LastYear" BIGINT
    );

    IF "Type" = 'headwise' THEN
        "sqlquery" := ';with cte
as
(
Select distinct "dbo"."Adm_School_M_Class"."ASMCL_ClassName" AS "ClassName","Fee_Master_Head"."FMH_FeeName" AS "FeeName","fee_t_installment"."FTI_Name",SUM("dbo"."fee_student_status"."FSS_NetAmount") AS "NetAmt",sum("FSS_ConcessionAmount") AS "ConcessAmt",sum("FSS_RebateAmount") AS "RebateAmt",sum("FSS_WaivedAmount") AS "WaivedAmt",sum("FSS_FineAmount") AS "FineAmt",sum("FSS_PaidAmount") AS "CollectionAmt",sum("FSS_OBArrearAmount") AS "OBArrearAmt",sum("FSS_ToBePaid") AS "tobepaid"
from "Fee_Master_Group" 
INNER JOIN "Fee_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "mi_id"::VARCHAR || ' 
INNER JOIN "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Adm_M_Student" on "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Adm_M_Student"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Adm_School_Y_Student" on "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || "asmay_Id"::VARCHAR || '
INNER JOIN "Adm_School_M_Class" on "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id"  and "Adm_School_M_Class"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id"  and "Adm_School_M_Section"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Fee_Master_Terms_FeeHeads" on "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id"  and "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Fee_Master_Terms" on "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" and "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "Fee_Master_Terms"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "fee_t_installment" on  "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "fee_t_installment"."MI_ID"=' || "mi_id"::VARCHAR || '
INNER JOIN "Fee_T_Due_Date" on "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"
where ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id"::VARCHAR || ') and ("Fee_Student_Status"."FMG_Id" in (' || "fmg_id" || ')) 
AND ("dbo"."fee_student_status"."MI_Id" = ' || "mi_id"::VARCHAR || ') and "Fee_Student_Status"."FMG_Id" 
IN (select distinct "FMG_Id" from "dbo"."Fee_Master_Group_Grouping_Groups" where "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN(select distinct "fmgg_id" from "Fee_Master_Group_Grouping" where "mi_id"=' || "mi_id"::VARCHAR || ' and "fmgg_id" in(' || "fmgg_id" || ')))
and ("dbo"."fee_student_status"."ASMAY_Id" = ' || "asmay_Id"::VARCHAR || ')
GROUP BY "dbo"."Adm_School_M_Class"."ASMCL_ClassName","Fee_Master_Head"."FMH_FeeName","fee_t_installment"."FTI_Name"
)select "FeeName",sum("NetAmt") AS "Charges",sum("ConcessAmt") AS "Concession",sum("RebateAmt") AS "Rebate/Schlorship",sum("WaivedAmt") AS "Waive Off",sum("FineAmt") AS "Fine",
(sum("CollectionAmt")-sum("FineAmt")) AS "Collection",sum("tobepaid") AS "Debit Balance",sum("OBArrearAmt") AS "Last Year Due" from cte group by "FeeName"';
        
        EXECUTE "sqlquery";
        
    ELSIF "Type" = 'route' THEN
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        
        OPEN "routecursor" FOR 
        SELECT DISTINCT "MR"."TRMR_Id", "MR"."TRMR_RouteName" 
        FROM "TRN"."TR_Master_Route" "MR" 
        INNER JOIN "TRN"."TR_Student_Route" "SR" ON "MR"."MI_Id"="SR"."MI_Id" AND "SR"."ASMAY_Id"="asmay_Id" 
        WHERE "MR"."MI_Id"="mi_id" AND "TRMR_ActiveFlg"=TRUE;
        
        LOOP
            FETCH "routecursor" INTO "trmr_id", "RouteName";
            EXIT WHEN NOT FOUND;
            
            "sqlquery" := '
select SUM("Charges") AS "Charges",SUM("Concession") AS "Concession",SUM("Rebate/Schlorship") AS "Rebate/Schlorship",SUM("Waive Off") AS "Waive Off",SUM("Fine") AS "Fine",SUM("Collection") AS "Collection",SUM("Debit Balance") AS "Debit Balance",SUM("Last Year Due") AS "Last Year Due"
FROM(
SELECT SUM("FSS_NetAmount") AS "Charges",SUM("FSS_ConcessionAmount") AS "Concession",SUM("FSS_RebateAmount") AS "Rebate/Schlorship",SUM("FSS_WaivedAmount") AS "Waive Off",SUM("FSS_FineAmount") AS "Fine",SUM("FSS_PaidAmount") AS "Collection",SUM("FSS_ToBePaid") AS "Debit Balance",
SUM("FSS_OBAsPerFY") AS "Last Year Due","Fee_Master_Group"."FMG_GroupName"
FROM "dbo"."Fee_Master_Group" 
INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id"
INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "fee_student_status"."FMG_Id"="Fee_Master_Group_Grouping_Groups"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" 
INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_M_Section"."ASMS_Id" = "dbo"."Adm_School_Y_Student"."ASMS_Id" 
INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" 
INNER JOIN "dbo"."Fee_Master_Terms" ON "dbo"."Fee_Master_Terms"."FMT_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" AND "dbo"."Fee_Student_Status"."FTI_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" 
INNER JOIN  "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id" AND  "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Fee_Student_Status"."ASMAY_Id" 
WHERE ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id"::VARCHAR || ') AND ("dbo"."Fee_Student_Status"."MI_Id" = ' || "mi_id"::VARCHAR || ')  AND   ("dbo"."Fee_Master_Terms"."FMT_Id" IN (' || "fmt_id" || ')) 
and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=TRUE) and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=TRUE)  and ("Fee_Student_Status"."FMG_Id" in (' || "fmg_id" || ')) and "FMGG_id" in(' || "fmgg_id" || ')  
AND ("dbo"."Fee_Student_Status"."AMST_Id" IN
(select distinct "AMST_Id" from "TRN"."TR_Student_Route" where "mi_id"=' || "mi_id"::VARCHAR || ' 
and "TRMR_Id" IN (select "TRMR_Id" from "TRN"."TR_Master_Route"  where "mi_id"=' || "mi_id"::VARCHAR || ' and "TRMR_Id" = ' || "trmr_id"::VARCHAR || ' ) and "ASMAY_Id"=' || "asmay_Id"::VARCHAR || '  and  "TRSR_ActiveFlg"=TRUE 
union  
select distinct "AMST_Id" from "TRN"."TR_Student_Route" where "mi_id"=' || "mi_id"::VARCHAR || '   
and "TRMR_Drop_Route" IN (select "TRMR_Id" from "TRN"."TR_Master_Route"  where "mi_id"=' || "mi_id"::VARCHAR || ' and "TRMR_Id" = ' || "trmr_id"::VARCHAR || ' )   
and "ASMAY_Id"=' || "asmay_Id"::VARCHAR || ' and  "TRSR_ActiveFlg"=TRUE   and "AMST_Id" not in(select distinct "AMST_Id" from "TRN"."TR_Student_Route" where "mi_id"=' || "mi_id"::VARCHAR || '  
and "TRMR_Id" IN (select "TRMR_Id" from "TRN"."TR_Master_Route"  where "mi_id"=' || "mi_id"::VARCHAR || ' and "TRMR_Id"<>0 ) and "ASMAY_Id"=' || "asmay_Id"::VARCHAR || ' and  "TRSR_ActiveFlg"=TRUE)
 )) GROUP BY  "Fee_Master_Group"."FMG_GroupName"  )New ';
            
            "SqlqueryC" := 'SELECT ' || "sqlquery";
            
            FOR "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear" IN EXECUTE "SqlqueryC"
            LOOP
                INSERT INTO "IndRoute" VALUES("RouteName", "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear");
            END LOOP;
            
        END LOOP;
        
        CLOSE "routecursor";
        
        EXECUTE 'select "RouteName" AS "RouteName",sum("Charges") AS "Charges",sum("Concession") AS "Concession",sum("Rebate") AS "Rebate/Schlorship",
sum("Waive") AS "Waive Off",sum("Fine") AS "Fine",(sum("Collection")-sum("Fine")) AS "Collection",sum("Debit") AS "Debit Balance",sum("LastYear") AS "Last Year Due" 
from "IndRoute" group by "RouteName"  having sum("Charges")>0';
        
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        
    ELSIF "Type" = 'All' THEN
        "sqlquery" := ';with cte
as
(
Select distinct "dbo"."Adm_School_M_Class"."ASMCL_ClassName" AS "ClassName",SUM("dbo"."fee_student_status"."FSS_NetAmount") AS "NetAmt",SUM("FSS_ConcessionAmount") AS "ConcessAmt",SUM("FSS_RebateAmount") AS "RebateAmt",SUM("FSS_WaivedAmount") AS "WaivedAmt",SUM("FSS_FineAmount") AS "FineAmt",SUM("FSS_PaidAmount") AS "CollectionAmt",SUM("FSS_OBAsPerFY") AS "OBArrearAmt",SUM("FSS_ToBePaid") AS "tobepaid"
from "Fee_Master_Group" 
INNER JOIN "Fee_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "mi_id"::VARCHAR || ' 
INNER JOIN "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Adm_M_Student" on "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Adm_M_Student"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Adm_School_Y_Student" on "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || "asmay_Id"::VARCHAR || '
INNER JOIN "Adm_School_M_Class" on "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id"  and "Adm_School_M_Class"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id"  and "Adm_School_M_Section"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Fee_Master_Terms_FeeHeads" on "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id"  and "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Fee_Master_Terms" on "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" and "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "Fee_Master_Terms"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "fee_t_installment" on  "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "fee_t_installment"."MI_ID"=' || "mi_id"::VARCHAR || '
INNER JOIN "Fee_T_Due_Date" on "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"  
INNER JOIN  "dbo"."Fee_Y_Payment_School_Student"   on "Fee_Student_Status"."AMST_Id"="dbo"."Fee_Y_Payment_School_Student"."AMST_Id"       
INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"   
where ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id"::VARCHAR || ') and ("Fee_Student_Status"."FMG_Id" in (' || "fmg_id" || '))   and "dbo"."Fee_Y_Payment"."fyp_date" between ''' || "ASMAY_From_Date" || ''' and ''' || "asonduedate" || '''                   
AND ("dbo"."fee_student_status"."MI_Id" = ' || "mi_id"::VARCHAR || ') and "Fee_Student_Status"."FMG_Id" IN (select distinct "FMG_Id" from "dbo"."Fee_Master_Group_Grouping_Groups" where "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN(select distinct "fmgg_id" from "Fee_Master_Group_Grouping" where "mi_id"=' || "mi_id"::VARCHAR || ' and "fmgg_id" in(' || "fmgg_id" || ')))
and ("dbo"."fee_student_status"."ASMAY_Id" = ' || "asmay_Id"::VARCHAR || ')  GROUP BY "dbo"."Adm_School_M_Class"."ASMCL_ClassName" 
)select "ClassName",sum("NetAmt") AS "Charges",sum("ConcessAmt") AS "Concession",sum("RebateAmt") AS "Rebate/Schlorship",sum("WaivedAmt") AS "Waive Off",sum("FineAmt") AS "Fine",
(sum("CollectionAmt")-sum("FineAmt")) AS "Collection",sum("tobepaid") AS "Debit Balance",sum("OBArrearAmt") AS "Last Year Due" from cte group by "ClassName"';
        
        EXECUTE "sqlquery";
        
    ELSIF "Type" = 'individual' AND "status" = 'true' THEN
        "sqlquery" := ';with cte
as
(
select DISTINCT "dbo"."Adm_M_Student"."AMST_Admno" AS "admno",(COALESCE("AMST_FirstName",'''')|| '' '' ||COALESCE("AMST_MiddleName",'''')|| '' '' ||COALESCE("AMST_LastName",'''')) AS "StudentName","FMH_FeeName" AS "FeeName","FTI_Name" AS "TName","FSS_NetAmount" AS "NetAmt","FSS_ConcessionAmount" AS "ConcessAmt","FSS_RebateAmount" AS "RebateAmt","FSS_WaivedAmount" AS "WaivedAmt","FSS_FineAmount" AS "FineAmt","FSS_PaidAmount" AS "CollectionAmt","FSS_OBAsPerFY" AS "OBArrearAmt","FSS_ToBePaid" AS "tobepaid", "FSS_CurrentYrCharges" AS "Currentamt"
from "Fee_Master_Group" 
INNER JOIN "Fee_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "mi_id"::VARCHAR || ' 
INNER JOIN "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Adm_M_Student" on "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Adm_M_Student"."MI_Id"=' || "mi_id"::VARCHAR || ' and  "AMST_ActiveFlag"=FALSE and ("amst_sol"=''L'' OR "amst_sol"=''D'')
INNER JOIN "Adm_School_Y_Student" on "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || "asmay_Id"::VARCHAR || '
INNER JOIN "Adm_School_M_Class" on "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id"  and "Adm_School_M_Class"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id"  and "Adm_School_M_Section"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Fee_Master_Terms_FeeHeads" on "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id"  and "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Fee_Master_Terms" on "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" and "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "Fee_Master_Terms"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "fee_t_installment" on  "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "fee_t_installment"."MI_ID"=' || "mi_id"::VARCHAR || '
INNER JOIN "Fee_T_Due_Date" on "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"
where ("dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id"::VARCHAR || ') and ("Fee_Student_Status"."FMG_Id" in (' || "fmg_id" || ')) 
AND ("dbo"."fee_student_status"."MI_Id" = ' || "mi_id"::VARCHAR || ') AND ("dbo"."Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id"::VARCHAR || ') AND ("dbo"."adm_school_m_section"."asms_id" =' || "amsc_id"::VARCHAR || ') 
AND "Fee_Student_Status"."FMG_Id" in (select distinct "FMG_Id" from "dbo"."Fee_Master_Group_Grouping_Groups" where "Fee_Master_Group_Grouping_Groups"."fmgg_id" in(select distinct "fmgg_id" from "Fee_Master_Group_Grouping" where "mi_id"=' || "mi_id"::VARCHAR || ' and "fmgg_id" in(' || "fmgg_id" || ')))
AND ("dbo"."fee_student_status"."ASMAY_Id" = ' || "asmay_Id"::VARCHAR || ')  
)select "admno","StudentName",sum("NetAmt") AS "Charges",sum("ConcessAmt") AS "Concession",sum("RebateAmt") AS "Rebate/Schlorship",sum("WaivedAmt") AS "Waive Off",
sum("FineAmt") AS "Fine",(sum("CollectionAmt")-sum("FineAmt")) AS "Collection",sum("tobepaid") AS "Debit Balance",sum("OBArrearAmt") AS "Last Year Due" from cte group by "admno","StudentName"';
        
        EXECUTE "sqlquery";
        
    ELSIF "Type" = 'individual' AND "status" = 'false' THEN
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        
        DROP TABLE IF EXISTS "test1";
        DROP TABLE IF EXISTS "test2";
        DROP TABLE IF EXISTS "test3";
        DROP TABLE IF EXISTS "test4";
        
        "DynamicD1" := ';with cte
AS
(
select DISTINCT "dbo"."Adm_M_Student"."AMST_Id","dbo"."Adm_M_Student"."AMST_Admno" AS "admno",(COALESCE("AMST_FirstName",'''')|| '' '' ||COALESCE("AMST_MiddleName",'''')|| '' '' ||COALESCE("AMST_LastName",'''')) AS "StudentName","FMH_FeeName" AS "FeeName","FTI_Name" AS "TName","FSS_NetAmount" AS "NetAmt","FSS_ConcessionAmount" AS "ConcessAmt","FSS_RebateAmount" AS "RebateAmt","FSS_WaivedAmount" AS "WaivedAmt","FSS_FineAmount" AS "FineAmt","FSS_PaidAmount" AS "CollectionAmt","FSS_OBAsPerFY" AS "FSS_OBAsPerFY","FSS_ToBePaid" AS "tobepaid", "FSS_CurrentYrCharges" AS "Currentamt"
from "Fee_Master_Group" 
INNER JOIN "Fee_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "mi_id"::VARCHAR || ' 
INNER JOIN "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || "mi_id"::VARCHAR || '
INNER JOIN "Adm_M_Student" on "A