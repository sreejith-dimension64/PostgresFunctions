CREATE OR REPLACE FUNCTION "dbo"."Fee_DetailedAccountPosition_ROld" (
    "mi_id" BIGINT,
    "asmay_Id" BIGINT,
    "asmcl_id" BIGINT,
    "amsc_id" BIGINT,
    "fmgg_id" TEXT,
    "fmg_id" TEXT,
    "date" VARCHAR(10),
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10),
    "Type" VARCHAR(60),
    "fmt_id" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
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
    "routecursor" REFCURSOR;
    "IndRoute" REFCURSOR;
BEGIN

    IF "fromdate" != '' AND "todate" != '' AND "date" = '' THEN
        "where_condition" := ' and "FYP_Date" between TO_TIMESTAMP(''' || "fromdate" || ''', ''DD-MM-YYYY'') and TO_TIMESTAMP(''' || "todate" || ''', ''DD-MM-YYYY'') ';
    ELSIF "date" != '' THEN
        SELECT TO_CHAR("ASMAY_From_Date", 'DD-MM-YYYY') INTO "ASMAY_From_Date" 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = "mi_id" AND "ASMAY_Id" = "asmay_id";
        
        "where_condition" := ' and "FYP_Date" between TO_TIMESTAMP(''' || "ASMAY_From_Date" || ''', ''DD-MM-YYYY'') and TO_TIMESTAMP(''' || "date" || ''', ''DD-MM-YYYY'')';
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
        "sqlquery" := 'with cte as (
            SELECT DISTINCT
            "Adm_School_M_Class"."ASMCL_ClassName" "ClassName", 
            "FMH_FeeName" "FeeName",
            "FTI_Name" "TName",
            "FSS_NetAmount" AS "NetAmt",
            "FSS_ConcessionAmount" AS "ConcessAmt",
            "FSS_RebateAmount" AS "RebateAmt",
            "FSS_WaivedAmount" AS "WaivedAmt",
            "FSS_FineAmount" AS "FineAmt",
            "FSS_PaidAmount" AS "CollectionAmt",
            "FSS_OBArrearAmount" AS "OBArrearAmt",
            "FSS_ToBePaid" AS "tobepaid"
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" 
            INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."FEE_Yearly_Group"."FMG_Id" and "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id" = "dbo"."Fee_Student_Status"."MI_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_Id" = "dbo"."Fee_Student_Status"."ASMAY_Id" and "dbo"."Fee_Student_Status"."MI_Id" = "dbo"."Fee_Y_Payment"."MI_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" 
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL" = ''S'' and "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "AMST_ActiveFlag" = 1 and "AMAY_ActiveFlag" = 1
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            WHERE ("dbo"."Fee_Student_Status"."FMG_Id" IS NOT NULL) and ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'')  
            and "dbo"."Fee_Student_Status"."ASMAY_Id" 
            in 
            ( SELECT distinct "dbo"."Adm_School_M_Class_Category"."ASMAY_Id" FROM  
              "dbo"."Adm_School_M_Class_Category" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_M_Class_Category"."ASMCL_Id" 
              INNER JOIN "dbo"."Adm_School_Master_Class_Cat_Sec" ON "dbo"."Adm_School_M_Class_Category"."ASMCC_Id" = "Adm_School_Master_Class_Cat_Sec"."ASMCC_Id"
              WHERE ("dbo"."Adm_School_M_Class_Category"."ASMAY_Id" = ' || "asmay_Id" || ')   
            ) AND "dbo"."Fee_Y_Payment"."mi_id" = ' || "mi_id" || ' and "dbo"."Fee_Y_Payment"."ASMAY_ID" = ' || "asmay_Id" || '   
            and "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" in (' || "fmgg_id" || ') and "dbo"."Fee_Master_Group"."FMG_Id" in (' || "fmg_id" || ') 
            and "Fee_Y_Payment"."FYP_Id" IN ( select "FYP_Id" from "dbo"."Fee_T_Payment") and "Fee_Master_Amount"."FMA_Id" IN ( select "FMA_Id" from "dbo"."Fee_T_Payment")
        )
        select "FeeName", sum("NetAmt") "Charges", sum("ConcessAmt") "Concession", sum("RebateAmt") "Rebate/Schlorship", sum("WaivedAmt") "Waive Off", sum("FineAmt") "Fine",
        sum("CollectionAmt") "Collection", sum("tobepaid") "Debit Balance", sum("OBArrearAmt") "Last Year Due" from cte group by "FeeName"';
        
        EXECUTE "sqlquery";

    ELSIF "Type" = 'route' THEN
        OPEN "routecursor" FOR
        SELECT DISTINCT "MR"."TRMR_Id" 
        FROM "TRN"."TR_Master_Route" "MR" 
        INNER JOIN "TRN"."TR_Student_Route" "SR" ON "MR"."MI_Id" = "SR"."MI_Id" and "SR"."ASMAY_Id" = "asmay_Id"
        WHERE "MR"."MI_Id" = "MI_Id" and "TRMR_ActiveFlg" = 1;

        LOOP
            FETCH "routecursor" INTO "trmr_id";
            EXIT WHEN NOT FOUND;

            "sqlquery" := '
            select distinct
            "TRMR_RouteName" "RouteName", sum("FSS_NetAmount") "Charges",
            sum("FSS_ConcessionAmount") AS "Concession",
            sum("FSS_RebateAmount") AS "Rebate",
            sum("FSS_WaivedAmount") AS "Waive",
            sum("FSS_FineAmount") AS "Fine",
            sum("FSS_PaidAmount") AS "Collection",
            sum("FSS_ToBePaid") AS "Debit",
            sum("FSS_OBArrearAmount") AS "LastYear"
            from "fee_student_status" 
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "fee_student_status"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" 
            INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" 
            INNER JOIN "dbo"."Fee_Master_Terms" ON "dbo"."Fee_Master_Terms"."FMT_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" AND "dbo"."Fee_Student_Status"."FTI_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" 
            INNER JOIN "TRN"."TR_Student_Route" "SR" ON "SR"."AMST_Id" = "fee_student_status"."AMST_Id" and "SR"."mi_id" = ' || "mi_id" || ' and "SR"."ASMAY_Id" = ' || "asmay_Id" || '
            INNER JOIN "TRN"."TR_Master_Route" "MR" ON ("MR"."TRMR_Id" = "SR"."TRMR_Id" OR "TRMR_Drop_Route" = "MR"."TRMR_Id") and "MR"."TRMR_Id" = ' || "trmr_id" || '
            where "fee_student_status"."mi_id" = ' || "mi_id" || ' and "fee_student_status"."ASMAY_Id" = ' || "asmay_Id" || ' 
            and "dbo"."Fee_Master_Terms"."FMT_Id" IN (' || "fmt_id" || ')
            and "dbo"."Fee_Student_Status"."AMST_Id" IN(select distinct "amst_id" from "Fee_Y_Payment_School_Student" 
            where "Fee_Y_Payment_School_Student"."FYP_Id" IN (select distinct "fyp_id" from "fee_y_payment" where "mi_id" = ' || "mi_id" || ' and "ASMAY_ID" = ' || "asmay_Id" || ')
            and "Fee_Y_Payment_School_Student"."amst_id" IN (
            select distinct "AMST_Id" from "TRN"."TR_Student_Route" where "mi_id" = ' || "mi_id" || '
            and "TRMR_Id" = (select "TRMR_Id" from "TRN"."TR_Master_Route" where "mi_id" = ' || "mi_id" || ' and "TRMR_Id" = ' || "trmr_id" || ') and "ASMAY_Id" = ' || "asmay_Id" || ' and "TRSR_ActiveFlg" = 1
            union
            select distinct "AMST_Id" from "TRN"."TR_Student_Route" where "mi_id" = ' || "mi_id" || '
            and "TRMR_Drop_Route" = (select "TRMR_Id" from "TRN"."TR_Master_Route" where "mi_id" = ' || "mi_id" || ' and "TRMR_Id" = ' || "trmr_id" || ') 
            and "ASMAY_Id" = ' || "asmay_Id" || ' and "TRSR_ActiveFlg" = 1 
            and "AMST_Id" not in(select distinct "AMST_Id" from "TRN"."TR_Student_Route" where "mi_id" = ' || "mi_id" || '
            and "TRMR_Id" IN (select "TRMR_Id" from "TRN"."TR_Master_Route" where "mi_id" = ' || "mi_id" || ' and "TRMR_Id" <> 0) and "ASMAY_Id" = ' || "asmay_Id" || ' and "TRSR_ActiveFlg" = 1)
             ))
             
            and "fee_student_status"."FMG_Id" IN(' || "fmg_id" || ') and "FMGG_Id" IN(' || "fmgg_id" || ') 
            and "fee_student_status"."AMST_Id" IN (select "Adm_M_Student"."amst_id" from "dbo"."Adm_M_Student" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL" = ''S'' and "AMST_ActiveFlag" = 1 and "AMAY_ActiveFlag" = 1
            where "mi_id" = ' || "mi_id" || ' and "Adm_School_Y_Student"."asmay_id" = ' || "asmay_Id" || ')  
            group by "TRMR_RouteName"';

            OPEN "IndRoute" FOR EXECUTE "sqlquery";

            LOOP
                FETCH "IndRoute" INTO "RouteName", "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear";
                EXIT WHEN NOT FOUND;

                INSERT INTO "IndRoute" VALUES("RouteName", "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear");
            END LOOP;

            CLOSE "IndRoute";
        END LOOP;

        CLOSE "routecursor";

        EXECUTE 'select "RouteName" AS "RouteName", sum("Charges") AS "Charges", sum("Concession") AS "Concession", sum("Rebate") AS "Rebate/Schlorship",
        sum("Waive") AS "Waive Off", sum("Fine") AS "Fine", sum("Collection") AS "Collection", sum("Debit") AS "Debit Balance", sum("LastYear") AS "Last Year Due" from "IndRoute" group by "RouteName"';

    ELSIF "Type" = 'All' THEN
        "sqlquery" := 'with cte as (
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
            "FSS_OBArrearAmount" AS "OBArrearAmt",
            "FSS_ToBePaid" AS "tobepaid"
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" 
            INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."FEE_Yearly_Group"."FMG_Id" and "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id" = "dbo"."Fee_Student_Status"."MI_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_Id" = "dbo"."Fee_Student_Status"."ASMAY_Id" and "dbo"."Fee_Student_Status"."MI_Id" = "dbo"."Fee_Y_Payment"."MI_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" 
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL" = ''S'' and "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" and "AMST_ActiveFlag" = 1 and "AMAY_ActiveFlag" = 1
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            WHERE ("dbo"."Fee_Student_Status"."FMG_Id" IS NOT NULL) and ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'')  
            and "dbo"."Fee_Student_Status"."ASMAY_Id" 
            IN 
            ( SELECT distinct "dbo"."Adm_School_M_Class_Category"."ASMAY_Id" FROM  
              "dbo"."Adm_School_M_Class_Category" INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_M_Class_Category"."ASMCL_Id" 
              INNER JOIN "dbo"."Adm_School_Master_Class_Cat_Sec" ON "dbo"."Adm_School_M_Class_Category"."ASMCC_Id" = "Adm_School_Master_Class_Cat_Sec"."ASMCC_Id"
              WHERE ("dbo"."Adm_School_M_Class_Category"."ASMAY_Id" = ' || "asmay_Id" || ')    
            ) AND "dbo"."Fee_Y_Payment"."mi_id" = ' || "mi_id" || ' and "dbo"."Fee_Y_Payment"."ASMAY_ID" = ' || "asmay_Id" || '   
            AND "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" in (' || "fmgg_id" || ') and "dbo"."Fee_Master_Group"."FMG_Id" in (' || "fmg_id" || ') 
            AND "Fee_Y_Payment"."FYP_Id" IN( select "FYP_Id" from "dbo"."Fee_T_Payment") and "Fee_Master_Amount"."FMA_Id" IN ( select "FMA_Id" from "dbo"."Fee_T_Payment")
        )
        select "ClassName", sum("NetAmt") "Charges", sum("ConcessAmt") "Concession", sum("RebateAmt") "Rebate/Schlorship", sum("WaivedAmt") "Waive Off", sum("FineAmt") "Fine",
        sum("CollectionAmt") "Collection", sum("tobepaid") "Debit Balance", sum("OBArrearAmt") "Last Year Due" from cte group by "ClassName"';
        
        EXECUTE "sqlquery";

    ELSIF "Type" = 'individual' THEN
        "sqlquery" := 'with cte as (
            SELECT 
            DISTINCT "dbo"."Adm_M_Student"."AMST_Admno" AS "admno",
            (COALESCE("AMST_FirstName", '''') || '' '' || COALESCE("AMST_MiddleName", '''') || '' '' || COALESCE("AMST_LastName", '''')) AS "StudentName",
            "FMH_FeeName" "FeeName",
            "FTI_Name" "TName",
            "FSS_NetAmount" AS "NetAmt",
            "FSS_ConcessionAmount" AS "ConcessAmt",
            "FSS_RebateAmount" AS "RebateAmt",
            "FSS_WaivedAmount" AS "WaivedAmt",
            "FSS_FineAmount" AS "FineAmt",
            "FSS_PaidAmount" AS "CollectionAmt",
            "FSS_OBArrearAmount" AS "OBArrearAmt", "FSS_ToBePaid" as "Balance", "FSS_CurrentYrCharges" as "Currentamt"
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_Student_Status" 
            INNER JOIN "dbo"."Fee_Master_Group"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."FEE_Yearly_Group"."FMG_Id" ON "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" 
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id" = "dbo"."Fee_Student_Status"."MI_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_ID" = "dbo"."Fee_Student_Status"."ASMAY_Id" and "dbo"."Fee_Student_Status"."MI_Id" = "dbo"."Fee_Y_Payment"."MI_Id"
            INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_T_Payment"."FMA_Id" = "dbo"."Fee_Master_Amount"."FMA_Id" and "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
            INNER JOIN "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
            INNER JOIN "dbo"."Adm_School_Y_Student"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL" = ''S'' ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" ON "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
            WHERE ("dbo"."Fee_Student_Status"."FMG_Id" IS NOT NULL) and ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'') and ("dbo"."Fee_Student_Status"."ASMAY_Id" = ' || "asmay_Id" || ')
            AND ("dbo"."Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id" || ')  
            AND ("dbo"."Adm_School_M_Section"."ASMS_Id" = ' || "amsc_id" || '  
            ) AND "dbo"."Fee_Y_Payment"."mi_id" = ' || "mi_