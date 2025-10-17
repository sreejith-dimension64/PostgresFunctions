CREATE OR REPLACE FUNCTION "dbo"."Fee_DetailedAccountPosition_AsonDate_FY_temp" (
    "@mi_id" BIGINT,
    "@asmay_Id" BIGINT,
    "@asmcl_id" BIGINT,
    "@amsc_id" BIGINT,
    "@fmgg_id" TEXT,
    "@fmg_id" TEXT,
    "@date" VARCHAR(10),
    "@fromdate" VARCHAR(10),
    "@todate" VARCHAR(10),
    "@Type" VARCHAR(60),
    "@fmt_id" TEXT,
    "@status" TEXT,
    "@asonduedate" VARCHAR(10)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@aa" TEXT;
    "@where_condition" TEXT;
    "@sqlquery" TEXT;
    "@OnAnyDate" TEXT;
    "@ASMAY_From_Date" VARCHAR(10);
    "@SqlqueryC" TEXT;
    "@trmr_id" BIGINT;
    "@RouteName" VARCHAR(100);
    "@Charges" BIGINT;
    "@Concession" BIGINT;
    "@Rebate" BIGINT;
    "@Waive" BIGINT;
    "@Fine" BIGINT;
    "@Collection" BIGINT;
    "@Debit" BIGINT;
    "@LastYear" BIGINT;
    "route_rec" RECORD;
    "result_rec" RECORD;
    "@DynamicD1" TEXT;
    "@DynamicD2" TEXT;
BEGIN

    IF "@fromdate" != '' AND "@todate" != '' AND "@date" = '' THEN
        "@where_condition" := 'and ((CAST("FYP_Date" AS DATE) between ''' || "@FromDate" || ''' and ''' || "@Todate" || '''))  ';
    ELSIF "@date" != '' OR "@asonduedate" != '' THEN
        SELECT "IMFY_FromDate" INTO "@ASMAY_From_Date" 
        FROM "IVRM_Master_FinancialYear" 
        WHERE "@date" BETWEEN "IMFY_FromDate" AND "IMFY_ToDate";
        
        "@where_condition" := 'and ((CAST("FYP_Date" AS DATE) between ''' || "@ASMAY_From_Date" || ''' and ''' || "@date" || '''))  ';
    ELSE
        "@where_condition" := '';
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

    IF "@Type" = 'headwise' THEN
        "@sqlquery" := ';with cte as (
Select distinct "Adm_School_M_Class"."ASMCL_ClassName" AS "ClassName","Fee_Master_Head"."FMH_FeeName" AS "FeeName","fee_t_installment"."FTI_Name",SUM("fee_student_status"."FSS_NetAmount") AS "NetAmt",sum("FSS_ConcessionAmount") AS "ConcessAmt",sum("FSS_RebateAmount") AS "RebateAmt",sum("FSS_WaivedAmount") AS "WaivedAmt",sum("FSS_FineAmount") AS "FineAmt",sum("FSS_PaidAmount") AS "CollectionAmt",sum("FSS_OBArrearAmount") AS "OBArrearAmt",sum("FSS_ToBePaid") AS tobepaid
from "Fee_Master_Group" 
INNER JOIN "Fee_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "@mi_id"::TEXT || ' 
INNER JOIN "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_M_Student" on "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Adm_M_Student"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_School_Y_Student" on "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || "@asmay_Id"::TEXT || '
INNER JOIN "Adm_School_M_Class" on "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" and "Adm_School_M_Class"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" and "Adm_School_M_Section"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_Master_Terms_FeeHeads" on "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" and "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_Master_Terms" on "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" and "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "Fee_Master_Terms"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "fee_t_installment" on "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "fee_t_installment"."MI_ID"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_T_Due_Date" on "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"
where ("Adm_School_Y_Student"."ASMAY_Id" = ' || "@asmay_Id"::TEXT || ') and ("Fee_Student_Status"."FMG_Id" in (' || "@fmg_id" || ')) 
AND ("fee_student_status"."MI_Id" = ' || "@mi_id"::TEXT || ') and "Fee_Student_Status"."FMG_Id" 
IN (select distinct "FMG_Id" from "Fee_Master_Group_Grouping_Groups" where "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN(select distinct fmgg_id from "Fee_Master_Group_Grouping" where mi_id=' || "@mi_id"::TEXT || ' and fmgg_id in(' || "@fmgg_id" || ')))
and ("fee_student_status"."ASMAY_Id" = ' || "@asmay_Id"::TEXT || ')
GROUP BY "Adm_School_M_Class"."ASMCL_ClassName","Fee_Master_Head"."FMH_FeeName","fee_t_installment"."FTI_Name"
)select "FeeName",sum("NetAmt") "Charges",sum("ConcessAmt") "Concession",sum("RebateAmt") "Rebate/Schlorship",sum("WaivedAmt") "Waive Off",sum("FineAmt") "Fine",
(sum("CollectionAmt")-sum("FineAmt")) "Collection",sum(tobepaid) "Debit Balance",sum("OBArrearAmt") "Last Year Due" from cte group by "FeeName"';
        
        EXECUTE "@sqlquery";

    ELSIF "@Type" = 'route' THEN
        FOR "route_rec" IN 
            SELECT DISTINCT "MR"."TRMR_Id", "MR"."TRMR_RouteName" 
            FROM "TRN"."TR_Master_Route" "MR" 
            INNER JOIN "TRN"."TR_Student_Route" "SR" ON "MR"."MI_Id"="SR"."MI_Id" AND "SR"."ASMAY_Id"="@asmay_Id" 
            WHERE "MR"."MI_Id"="@MI_Id" AND "TRMR_ActiveFlg"=TRUE
        LOOP
            "@trmr_id" := "route_rec"."TRMR_Id";
            "@RouteName" := "route_rec"."TRMR_RouteName";
            
            "@sqlquery" := '
select SUM("Charges") "Charges",SUM("Concession") "Concession",SUM("Rebate/Schlorship") "Rebate/Schlorship",SUM("Waive Off") "Waive Off",SUM("Fine") "Fine",SUM("Collection") "Collection",SUM("Debit Balance") "Debit Balance",SUM("Last Year Due") "Last Year Due" 
FROM(
SELECT SUM("FSS_NetAmount") "Charges",SUM("FSS_ConcessionAmount") AS "Concession",SUM("FSS_RebateAmount") AS "Rebate/Schlorship",SUM("FSS_WaivedAmount") AS "Waive Off",SUM("FSS_FineAmount") AS "Fine",SUM("FSS_PaidAmount") AS "Collection",SUM("FSS_ToBePaid") AS "Debit Balance",SUM("FSS_OBArrearAmount") AS "Last Year Due","Fee_Master_Group"."FMG_GroupName"
FROM "Fee_Master_Group" 
INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
INNER JOIN "Fee_Master_Group_Grouping_Groups" ON "fee_student_status"."FMG_Id"="Fee_Master_Group_Grouping_Groups"."FMG_Id" 
INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" 
INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id" 
WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "@asmay_Id"::TEXT || ') AND ("Fee_Student_Status"."MI_Id" = ' || "@mi_id"::TEXT || ') AND ("Fee_Master_Terms"."FMT_Id" IN (' || "@fmt_id" || ')) 
and ("Adm_School_Y_Student"."AMAY_ActiveFlag"=TRUE) and ("Adm_M_Student"."AMST_SOL"=''S'') and ("Adm_M_Student"."AMST_ActiveFlag"=TRUE) and ("Fee_Student_Status"."FMG_Id" in (' || "@fmg_id" || ')) and "FMGG_id" in(' || "@fmgg_id" || ')
AND ("Fee_Student_Status"."AMST_Id" IN 
(select distinct "AMST_Id" from "TRN"."TR_Student_Route" where mi_id=' || "@mi_id"::TEXT || ' 
and "TRMR_Id" IN (select "TRMR_Id" from "TRN"."TR_Master_Route" where mi_id=' || "@mi_id"::TEXT || ' and "TRMR_Id" = ' || "@trmr_id"::TEXT || ' ) and "ASMAY_Id"=' || "@asmay_Id"::TEXT || ' and "TRSR_ActiveFlg"=TRUE 
union 
select distinct "AMST_Id" from "TRN"."TR_Student_Route" where mi_id=' || "@mi_id"::TEXT || ' 
and "TRMR_Drop_Route" IN (select "TRMR_Id" from "TRN"."TR_Master_Route" where mi_id=' || "@mi_id"::TEXT || ' and "TRMR_Id" = ' || "@trmr_id"::TEXT || ' ) 
and "ASMAY_Id"=' || "@asmay_Id"::TEXT || ' and "TRSR_ActiveFlg"=TRUE and "AMST_Id" not in(select distinct "AMST_Id" from "TRN"."TR_Student_Route" where mi_id=' || "@mi_id"::TEXT || ' 
and "TRMR_Id" IN (select "TRMR_Id" from "TRN"."TR_Master_Route" where mi_id=' || "@mi_id"::TEXT || ' and "TRMR_Id"<>0 ) and "ASMAY_Id"=' || "@asmay_Id"::TEXT || ' and "TRSR_ActiveFlg"=TRUE)
)) GROUP BY "Fee_Master_Group"."FMG_GroupName" )"New" ';
            
            FOR "result_rec" IN EXECUTE "@sqlquery" LOOP
                "@Charges" := "result_rec"."Charges";
                "@Concession" := "result_rec"."Concession";
                "@Rebate" := "result_rec"."Rebate/Schlorship";
                "@Waive" := "result_rec"."Waive Off";
                "@Fine" := "result_rec"."Fine";
                "@Collection" := "result_rec"."Collection";
                "@Debit" := "result_rec"."Debit Balance";
                "@LastYear" := "result_rec"."Last Year Due";
                
                INSERT INTO "IndRoute" VALUES("@RouteName","@Charges","@Concession","@Rebate","@Waive","@Fine","@Collection","@Debit","@LastYear");
            END LOOP;
        END LOOP;
        
        PERFORM * FROM (
            SELECT "RouteName" AS "RouteName",SUM("Charges") AS "Charges",SUM("Concession") AS "Concession",SUM("Rebate") AS "Rebate/Schlorship",
            SUM("Waive") AS "Waive Off",SUM("Fine") AS "Fine",(SUM("Collection")-SUM("Fine")) AS "Collection",SUM("Debit") AS "Debit Balance",SUM("LastYear") AS "Last Year Due" 
            FROM "IndRoute" GROUP BY "RouteName" HAVING SUM("Charges")>0
        ) subq;

    ELSIF "@Type" = 'All' THEN
        "@sqlquery" := ';with cte as (
Select distinct "Adm_School_M_Class"."ASMCL_ClassName" AS "ClassName",SUM("fee_student_status"."FSS_NetAmount") AS "NetAmt",SUM("FSS_ConcessionAmount") AS "ConcessAmt",SUM("FSS_RebateAmount") AS "RebateAmt",SUM("FSS_WaivedAmount") AS "WaivedAmt",SUM("FSS_FineAmount") AS "FineAmt",SUM("FSS_PaidAmount") AS "CollectionAmt",SUM("FSS_OBArrearAmount") AS "OBArrearAmt",SUM("FSS_ToBePaid") AS tobepaid
from "Fee_Master_Group" 
INNER JOIN "Fee_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "@mi_id"::TEXT || ' 
INNER JOIN "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_M_Student" on "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Adm_M_Student"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_School_Y_Student" on "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || "@asmay_Id"::TEXT || '
INNER JOIN "Adm_School_M_Class" on "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" and "Adm_School_M_Class"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" and "Adm_School_M_Section"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_Master_Terms_FeeHeads" on "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" and "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_Master_Terms" on "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" and "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "Fee_Master_Terms"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "fee_t_installment" on "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "fee_t_installment"."MI_ID"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_T_Due_Date" on "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"
where ("Adm_School_Y_Student"."ASMAY_Id" = ' || "@asmay_Id"::TEXT || ') and ("Fee_Student_Status"."FMG_Id" in (' || "@fmg_id" || ')) 
AND ("fee_student_status"."MI_Id" = ' || "@mi_id"::TEXT || ') and "Fee_Student_Status"."FMG_Id" IN (select distinct "FMG_Id" from "Fee_Master_Group_Grouping_Groups" where "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN(select distinct fmgg_id from "Fee_Master_Group_Grouping" where mi_id=' || "@mi_id"::TEXT || ' and fmgg_id in(' || "@fmgg_id" || ')))
and ("fee_student_status"."ASMAY_Id" = ' || "@asmay_Id"::TEXT || ') GROUP BY "Adm_School_M_Class"."ASMCL_ClassName"
)select "ClassName",sum("NetAmt") "Charges",sum("ConcessAmt") "Concession",sum("RebateAmt") "Rebate/Schlorship",sum("WaivedAmt") "Waive Off",sum("FineAmt") "Fine",
(sum("CollectionAmt")-sum("FineAmt")) "Collection",sum(tobepaid) "Debit Balance",sum("OBArrearAmt") "Last Year Due" from cte group by "ClassName"';
        
        EXECUTE "@sqlquery";

    ELSIF "@Type" = 'individual' AND "@status" = 'true' THEN
        "@sqlquery" := ';with cte as (
select DISTINCT "Adm_M_Student"."AMST_Admno" AS admno,(COALESCE("AMST_FirstName",'''')||'' ''||COALESCE("AMST_MiddleName",'''')||'' ''||COALESCE("AMST_LastName",'''')) AS "StudentName","FMH_FeeName" "FeeName","FTI_Name" "TName","FSS_NetAmount" AS "NetAmt","FSS_ConcessionAmount" AS "ConcessAmt","FSS_RebateAmount" AS "RebateAmt","FSS_WaivedAmount" AS "WaivedAmt","FSS_FineAmount" AS "FineAmt","FSS_PaidAmount" AS "CollectionAmt","FSS_OBArrearAmount" AS "OBArrearAmt","FSS_ToBePaid" as tobepaid, "FSS_CurrentYrCharges" as "Currentamt"
from "Fee_Master_Group" 
INNER JOIN "Fee_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "@mi_id"::TEXT || ' 
INNER JOIN "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_M_Student" on "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Adm_M_Student"."MI_Id"=' || "@mi_id"::TEXT || ' and "AMST_ActiveFlag"=FALSE and ("amst_sol"=''L'' OR "amst_sol"=''D'')
INNER JOIN "Adm_School_Y_Student" on "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || "@asmay_Id"::TEXT || '
INNER JOIN "Adm_School_M_Class" on "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" and "Adm_School_M_Class"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" and "Adm_School_M_Section"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_Master_Terms_FeeHeads" on "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" and "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_Master_Terms" on "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" and "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "Fee_Master_Terms"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "fee_t_installment" on "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "fee_t_installment"."MI_ID"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_T_Due_Date" on "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"
where ("Adm_School_Y_Student"."ASMAY_Id" = ' || "@asmay_Id"::TEXT || ') and ("Fee_Student_Status"."FMG_Id" in (' || "@fmg_id" || ')) 
AND ("fee_student_status"."MI_Id" = ' || "@mi_id"::TEXT || ') AND ("Adm_School_M_Class"."ASMCL_Id" = ' || "@asmcl_id"::TEXT || ') AND ("adm_school_m_section".asms_id =' || "@amsc_id"::TEXT || ') 
AND "Fee_Student_Status"."FMG_Id" in (select distinct "FMG_Id" from "Fee_Master_Group_Grouping_Groups" where "Fee_Master_Group_Grouping_Groups"."fmgg_id" in(select distinct fmgg_id from "Fee_Master_Group_Grouping" where mi_id=' || "@mi_id"::TEXT || ' and fmgg_id in(' || "@fmgg_id" || ')))
AND ("fee_student_status"."ASMAY_Id" = ' || "@asmay_Id"::TEXT || ')
)select admno,"StudentName",sum("NetAmt") "Charges",sum("ConcessAmt") "Concession",sum("RebateAmt") "Rebate/Schlorship",sum("WaivedAmt") "Waive Off",
sum("FineAmt") "Fine",(sum("CollectionAmt")-sum("FineAmt")) "Collection",sum(tobepaid) "Debit Balance",sum("OBArrearAmt") "Last Year Due" from cte group by admno,"StudentName"';
        
        EXECUTE "@sqlquery";

    ELSIF "@Type" = 'individual' AND "@status" = 'false' THEN
        DROP TABLE IF EXISTS "Students_StatusCYChargesAcc_Temp2";
        DROP TABLE IF EXISTS "Students_CYPaidAcc_Temp2";
        
        "@DynamicD1" := ';with cte AS (
select DISTINCT "Adm_M_Student"."AMST_Id","Adm_M_Student"."AMST_Admno" AS admno,(COALESCE("AMST_FirstName",'''')||'' ''||COALESCE("AMST_MiddleName",'''')||'' ''||COALESCE("AMST_LastName",'''')) AS "StudentName","FMH_FeeName" "FeeName","FTI_Name" "TName","FSS_NetAmount" AS "NetAmt","FSS_ConcessionAmount" AS "ConcessAmt","FSS_RebateAmount" AS "RebateAmt","FSS_WaivedAmount" AS "WaivedAmt","FSS_FineAmount" AS "FineAmt","FSS_PaidAmount" AS "CollectionAmt","FSS_OBArrearAmount" AS "OBArrearAmt","FSS_ToBePaid" as tobepaid, "FSS_CurrentYrCharges" as "Currentamt"
from "Fee_Master_Group" 
INNER JOIN "Fee_Student_Status" on "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "@mi_id"::TEXT || ' 
INNER JOIN "Fee_Master_Head" on "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_M_Student" on "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Adm_M_Student"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_School_Y_Student" on "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || "@asmay_Id"::TEXT || '
INNER JOIN "Adm_School_M_Class" on "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" and "Adm_School_M_Class"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" and "Adm_School_M_Section"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_Master_Terms_FeeHeads" on "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" and "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" and "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "@mi_id"::TEXT || '
INNER JOIN "Fee_Master_Terms" on "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" and "Fee_Master_Terms"."MI_Id"=' || "@mi_id"::TEXT || '