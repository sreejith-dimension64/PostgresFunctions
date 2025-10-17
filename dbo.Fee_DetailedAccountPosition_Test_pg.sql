CREATE OR REPLACE FUNCTION "dbo"."Fee_DetailedAccountPosition_Test"(
    "mi_id" BIGINT,
    "asmay_Id" BIGINT,
    "asmcl_id" BIGINT,
    "amsc_id" BIGINT,
    "fmgg_id" TEXT,
    "fmg_id" TEXT,
    "date" VARCHAR(10),
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10),
    "Type" VARCHAR(60)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "aa" TEXT;
    "where_condition" TEXT;
    "sqlquery" TEXT;
    "OnAnyDate" TEXT;
    "ASMAY_From_Date" VARCHAR(10);
BEGIN

    IF "fromdate" != '' AND "todate" != '' AND "date" = '' THEN
        "where_condition" := ' and "FYP_Date" between TO_TIMESTAMP(''' || "fromdate" || ''', ''DD-MM-YYYY'') and TO_TIMESTAMP(''' || "todate" || ''', ''DD-MM-YYYY'') ';
    ELSIF "date" != '' THEN
        SELECT TO_CHAR("ASMAY_From_Date", 'DD-MM-YYYY') INTO "ASMAY_From_Date"
        FROM "Adm_School_M_Academic_Year"
        WHERE "mi_id" = "mi_id" AND "asmay_id" = "asmay_id";
        
        "where_condition" := ' and "FYP_Date" between TO_TIMESTAMP(''' || "ASMAY_From_Date" || ''', ''DD-MM-YYYY'') and TO_TIMESTAMP(''' || "date" || ''', ''DD-MM-YYYY'')';
    ELSE
        "where_condition" := '';
    END IF;

    IF "Type" = 'headwise' THEN
        "sqlquery" := ';with cte
as
(
SELECT 
DISTINCT 
"Adm_School_M_Class"."ASMCL_ClassName" "ClassName", 
"FMH_FeeName" "FeeName",
"FTI_Name" "TName",
"FSS_NetAmount" AS "NetAmt",
"FSS_ConcessionAmount" AS "ConcessAmt",
"FSS_RebateAmount" AS "RebateAmt",
"FSS_WaivedAmount" AS "WaivedAmt",
"FSS_FineAmount" AS "FineAmt",
"FSS_PaidAmount" AS "CollectionAmt",
"FSS_OBArrearAmount" AS "OBArrearAmt"
FROM "dbo"."Fee_Master_Amount" 
INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" and "dbo"."Fee_Master_Amount"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."Fee_Master_Amount"."ASMAY_Id"=' || "asmay_Id"::TEXT || ' and "dbo"."Fee_Student_Status"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."Fee_Student_Status"."ASMAY_Id"=' || "asmay_Id"::TEXT || ' 
INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id"="dbo"."Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "mi_id"::TEXT || ' 
INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id"="dbo"."Fee_Master_Group"."FMG_Id"
INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping"."FMGG_Id"="dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id"
INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" and "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" and "dbo"."Fee_Yearly_Group"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."FEE_Yearly_Group"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id"="dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id"="dbo"."Fee_Student_Status"."MI_Id" and "dbo"."Fee_Master_Head"."MI_Id"=' || "mi_id"::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_Id"="dbo"."Fee_Student_Status"."ASMAY_Id" and "dbo"."Fee_Student_Status"."MI_Id"="dbo"."Fee_Y_Payment"."MI_Id" and "dbo"."Fee_Y_Payment"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."Fee_Y_Payment"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="dbo"."Fee_Student_Status"."FTI_Id" and "dbo"."Fee_T_Installment"."MI_Id"=' || "mi_id"::TEXT || '
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id" and "dbo"."Adm_School_M_Academic_Year"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" and "dbo"."Adm_M_Student"."MI_Id"=' || "mi_id"::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id"="dbo"."Adm_M_Student"."AMST_Id" and "dbo"."Fee_Y_Payment_School_Student"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL"=''S'' and "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "AMST_ActiveFlag"=1 and "AMAY_ActiveFlag"=1 and "dbo"."Adm_School_Y_Student"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" and "dbo"."Adm_School_M_Class"."MI_Id"=' || "mi_id"::TEXT || '
WHERE ("dbo"."Fee_Student_Status"."FMG_Id" IS NOT NULL) and ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'') 
and "dbo"."Fee_Student_Status"."ASMAY_Id"=' || "asmay_Id"::TEXT || ' AND "dbo"."Fee_Y_Payment"."mi_id"=' || "mi_id"::TEXT || ' and "dbo"."Fee_Y_Payment"."ASMAY_ID"=' || "asmay_Id"::TEXT || ' 
and "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" in (' || "fmgg_id" || ') and "dbo"."Fee_Master_Group"."FMG_Id" in (' || "fmg_id" || ') ' || "where_condition" || '
and "Fee_Y_Payment"."FYP_Id" IN ( select "FYP_Id" from "dbo"."Fee_T_Payment") and "Fee_Master_Amount"."FMA_Id" IN (select "FMA_Id" from "dbo"."Fee_T_Payment")
)select "ClassName","FeeName",sum("NetAmt") "Charges",sum("ConcessAmt") "Concession",sum("RebateAmt") "Rebate/Schlorship",sum("WaivedAmt") "Waive Off",sum("FineAmt") "Fine",
sum("CollectionAmt") "Collection",(case when sum("CollectionAmt") <>0 then (sum("NetAmt")-(sum("CollectionAmt")+sum("ConcessAmt")+sum("WaivedAmt"))) else ''0'' end) "Debit Balance",sum("OBArrearAmt") "Last Year Due" from cte group by "ClassName","FeeName"';

        RAISE NOTICE '%', "sqlquery";

    ELSIF "Type" = 'route' THEN
        "sqlquery" := ';with cte
as
(
SELECT 
DISTINCT 
"TRMR_RouteName" AS "RouteName",
"FTI_Name" "TName",
"FSS_NetAmount" AS "NetAmt",
"FSS_ConcessionAmount" AS "ConcessAmt",
"FSS_RebateAmount" AS "RebateAmt",
"FSS_WaivedAmount" AS "WaivedAmt",
"FSS_FineAmount" AS "FineAmt",
"FSS_PaidAmount" AS "CollectionAmt",
"FSS_OBArrearAmount" AS "OBArrearAmt"
FROM "dbo"."Fee_Master_Amount" 
INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" 
INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id"="dbo"."Fee_Student_Status"."FMG_Id"
INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id"="dbo"."Fee_Master_Group"."FMG_Id"
INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping"."FMGG_Id"="dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id"
INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."FEE_Yearly_Group"."FMG_Id" and "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id"="dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id"="dbo"."Fee_Student_Status"."MI_Id"
INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_Id"="dbo"."Fee_Student_Status"."ASMAY_Id" and "dbo"."Fee_Student_Status"."MI_Id"="dbo"."Fee_Y_Payment"."MI_Id"
INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="dbo"."Fee_Student_Status"."FTI_Id"
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id"
INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" 
INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id"="dbo"."Adm_M_Student"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL"=''S'' and "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "AMST_ActiveFlag"=1 and "AMAY_ActiveFlag"=1
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "dbo"."Adm_Student_Transport_Application" "TA" ON "TA"."AMST_Id"="dbo"."Adm_School_Y_Student"."AMST_Id" 
INNER JOIN "TRN"."TR_Master_Route" "TR" ON "TR"."TRMR_Id"="TA"."ASTA_Drop_TRMR_Id" OR "TR"."TRMR_Id"="TA"."ASTA_PickUp_TRMR_Id"
WHERE ("dbo"."Fee_Student_Status"."FMG_Id" IS NOT NULL) and ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'') 
and "dbo"."Fee_Student_Status"."ASMAY_Id" IN 
( SELECT distinct "dbo"."Adm_School_M_Class_Category"."ASMAY_Id" FROM 
  "dbo"."Adm_School_M_Class_Category" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_M_Class_Category"."ASMCL_Id" 
  INNER JOIN "dbo"."Adm_School_Master_Class_Cat_Sec" ON "dbo"."Adm_School_M_Class_Category"."ASMCC_Id"="Adm_School_Master_Class_Cat_Sec"."ASMCC_Id"
  WHERE ("dbo"."Adm_School_M_Class_Category"."ASMAY_Id"=' || "asmay_Id"::TEXT || ')   
) AND "dbo"."Fee_Y_Payment"."mi_id"=' || "mi_id"::TEXT || ' and "dbo"."Fee_Y_Payment"."ASMAY_ID"=' || "asmay_Id"::TEXT || ' 
and "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" in (' || "fmgg_id" || ') and "dbo"."Fee_Master_Group"."FMG_Id" in (' || "fmg_id" || ') ' || "where_condition" || '
and "Fee_Y_Payment"."FYP_Id" IN ( select "FYP_Id" from "dbo"."Fee_T_Payment") and "Fee_Master_Amount"."FMA_Id" IN (select "FMA_Id" from "dbo"."Fee_T_Payment")
)select "RouteName",sum("NetAmt") "Charges",sum("ConcessAmt") "Concession",sum("RebateAmt") "Rebate/Schlorship",sum("WaivedAmt") "Waive Off",sum("FineAmt") "Fine",
sum("CollectionAmt") "Collection",ABS((case when sum("CollectionAmt") <>0 then (sum("NetAmt")-(sum("CollectionAmt")+sum("ConcessAmt")+sum("WaivedAmt"))) else ''0'' end)) "Debit Balance",sum("OBArrearAmt") "Last Year Due" from cte group by "RouteName"';

        EXECUTE "sqlquery";

    ELSIF "Type" = 'All' THEN
        "sqlquery" := ';with cte
as
(
SELECT 
DISTINCT 
"Adm_School_M_Class"."ASMCL_ClassName" "ClassName",
"FSS_NetAmount" AS "NetAmt",
"FSS_ConcessionAmount" AS "ConcessAmt",
"FSS_RebateAmount" AS "RebateAmt",
"FSS_WaivedAmount" AS "WaivedAmt",
"FSS_FineAmount" AS "FineAmt",
"FSS_PaidAmount" AS "CollectionAmt",
"FSS_OBArrearAmount" AS "OBArrearAmt"
FROM "dbo"."Fee_Master_Amount" 
INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" and "dbo"."Fee_Master_Amount"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."Fee_Master_Amount"."ASMAY_Id"=' || "asmay_Id"::TEXT || ' and "dbo"."Fee_Student_Status"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."Fee_Student_Status"."ASMAY_Id"=' || "asmay_Id"::TEXT || ' 
INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id"="dbo"."Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || "mi_id"::TEXT || ' 
INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id"="dbo"."Fee_Master_Group"."FMG_Id"
INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping"."FMGG_Id"="dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id"
INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" and "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" and "dbo"."Fee_Yearly_Group"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."FEE_Yearly_Group"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id"="dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id"="dbo"."Fee_Student_Status"."MI_Id" and "dbo"."Fee_Master_Head"."MI_Id"=' || "mi_id"::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_Id"="dbo"."Fee_Student_Status"."ASMAY_Id" and "dbo"."Fee_Student_Status"."MI_Id"="dbo"."Fee_Y_Payment"."MI_Id" and "dbo"."Fee_Y_Payment"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."Fee_Y_Payment"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="dbo"."Fee_Student_Status"."FTI_Id" and "dbo"."Fee_T_Installment"."MI_Id"=' || "mi_id"::TEXT || '
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id" and "dbo"."Adm_School_M_Academic_Year"."MI_Id"=' || "mi_id"::TEXT || ' and "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" and "dbo"."Adm_M_Student"."MI_Id"=' || "mi_id"::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id"="dbo"."Adm_M_Student"."AMST_Id" and "dbo"."Fee_Y_Payment_School_Student"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL"=''S'' and "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "AMST_ActiveFlag"=1 and "AMAY_ActiveFlag"=1 and "dbo"."Adm_School_Y_Student"."ASMAY_Id"=' || "asmay_Id"::TEXT || '
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" and "dbo"."Adm_School_M_Class"."MI_Id"=' || "mi_id"::TEXT || '
WHERE ("dbo"."Fee_Student_Status"."FMG_Id" IS NOT NULL) and ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'') and "dbo"."Fee_Student_Status"."ASMAY_Id"=' || "asmay_Id"::TEXT || ' 
AND "dbo"."Fee_Y_Payment"."mi_id"=' || "mi_id"::TEXT || ' and "dbo"."Fee_Y_Payment"."ASMAY_ID"=' || "asmay_Id"::TEXT || ' 
AND "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" in (' || "fmgg_id" || ') and "dbo"."Fee_Master_Group"."FMG_Id" in (' || "fmg_id" || ') ' || "where_condition" || '
and "Fee_Y_Payment"."FYP_Id" IN ( select "FYP_Id" from "dbo"."Fee_T_Payment" )
)select "ClassName",sum("NetAmt") "Charges",sum("ConcessAmt") "Concession",sum("RebateAmt") "Rebate/Schlorship",sum("WaivedAmt") "Waive Off",sum("FineAmt") "Fine",
sum("CollectionAmt") "Collection",ABS((case when sum("CollectionAmt") <>0 then (sum("NetAmt")-(sum("CollectionAmt")+sum("ConcessAmt")+sum("WaivedAmt"))) else ''0'' end)) "Debit Balance",sum("OBArrearAmt") "Last Year Due" from cte group by "ClassName"';

        RAISE NOTICE '%', "sqlquery";

    ELSIF "Type" = 'individual' THEN
        "sqlquery" := ';with cte
as
(
SELECT 
DISTINCT "dbo"."Adm_M_Student"."AMST_Admno" AS "admno",
(COALESCE("AMST_FirstName",'''')||'''' ||COALESCE("AMST_MiddleName",'''')||'''' ||COALESCE("AMST_LastName",'''')) AS "StudentName",
"FMH_FeeName" "FeeName",
"FTI_Name" "TName",
"FSS_NetAmount" AS "NetAmt",
"FSS_ConcessionAmount" AS "ConcessAmt",
"FSS_RebateAmount" AS "RebateAmt",
"FSS_WaivedAmount" AS "WaivedAmt",
"FSS_FineAmount" AS "FineAmt",
"FSS_PaidAmount" AS "CollectionAmt",
"FSS_OBArrearAmount" AS "OBArrearAmt","FSS_ToBePaid" as "Balance", "FSS_CurrentYrCharges" as "Currentamt"
FROM "dbo"."Fee_Master_Amount" 
INNER JOIN "dbo"."Fee_Student_Status" 
INNER JOIN "dbo"."Fee_Master_Group"
INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups"
INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id"
INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."FEE_Yearly_Group"."FMG_Id" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" 
INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id"="dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id"="dbo"."Fee_Student_Status"."MI_Id"
INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_ID"="dbo"."Fee_Student_Status"."ASMAY_Id" and "dbo"."Fee_Student_Status"."MI_Id"="dbo"."Fee_Y_Payment"."MI_Id"
INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_T_Payment"."FMA_Id"="dbo"."Fee_Master_Amount"."FMA_Id" and "dbo"."Fee_T_Payment"."FYP_Id"="dbo"."Fee_Y_Payment"."FYP_Id"
INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="dbo"."Fee_Student_Status"."FTI_Id"
INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
INNER JOIN "dbo"."Adm_M_Student"
INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id"="dbo"."Adm_M_Student"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_Y_Student"
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL"=''S'' ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_