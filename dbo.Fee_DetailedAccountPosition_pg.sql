CREATE OR REPLACE FUNCTION "dbo"."Fee_DetailedAccountPosition"(
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
    "fmt_id" TEXT,
    "status" TEXT
)
RETURNS TABLE(
    col1 TEXT,
    col2 BIGINT,
    col3 BIGINT,
    col4 BIGINT,
    col5 BIGINT,
    col6 BIGINT,
    col7 BIGINT,
    col8 BIGINT,
    col9 BIGINT
)
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
        "where_condition" := ' and FYP_Date between TO_DATE(''' || "fromdate" || ''',''DD-MM-YYYY'') and TO_DATE(''' || "todate" || ''',''DD-MM-YYYY'') ';
    ELSIF "date" != '' THEN
        SELECT TO_CHAR("ASMAY_From_Date",'DD-MM-YYYY') INTO "ASMAY_From_Date" 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = "mi_id" AND "ASMAY_Id" = "asmay_Id";
        
        "where_condition" := ' and FYP_Date between TO_DATE(''' || "ASMAY_From_Date" || ''',''DD-MM-YYYY'') and TO_DATE(''' || "date" || ''',''DD-MM-YYYY'')';
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
        "sqlquery" := 'SELECT "FeeName"::TEXT, SUM("Charges")::BIGINT, SUM("Concession")::BIGINT, SUM("Rebate")::BIGINT, SUM("Waive")::BIGINT, SUM("Fine")::BIGINT, SUM("Collection")::BIGINT, SUM("Debit")::BIGINT, SUM("LastYear")::BIGINT FROM (
        SELECT DISTINCT "ASMCL_ClassName" AS "ClassName","FMH_FeeName" AS "FeeName","FTI_Name",SUM("FSS_NetAmount") AS "NetAmt",SUM("FSS_ConcessionAmount") AS "ConcessAmt",SUM("FSS_RebateAmount") AS "RebateAmt",SUM("FSS_WaivedAmount") AS "WaivedAmt",SUM("FSS_FineAmount") AS "FineAmt",SUM("FSS_PaidAmount") AS "CollectionAmt",SUM("FSS_OBArrearAmount") AS "OBArrearAmt",SUM("FSS_ToBePaid") AS tobepaid
        FROM "Fee_Master_Group" 
        INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id"=' || "asmay_Id" || '
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id"=' || "mi_id" || '
        INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID"=' || "mi_id" || '
        INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"
        WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || ') AND ("Fee_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')) 
        AND ("Fee_Student_Status"."MI_Id" = ' || "mi_id" || ') AND "Fee_Student_Status"."FMG_Id" 
        IN (SELECT DISTINCT "FMG_Id" FROM "Fee_Master_Group_Grouping_Groups" WHERE "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN(SELECT DISTINCT "fmgg_id" FROM "Fee_Master_Group_Grouping" WHERE "mi_id"=' || "mi_id" || ' AND "fmgg_id" IN(' || "fmgg_id" || ')))
        AND ("Fee_Student_Status"."ASMAY_Id" = ' || "asmay_Id" || ')
        GROUP BY "Adm_School_M_Class"."ASMCL_ClassName","Fee_Master_Head"."FMH_FeeName","fee_t_installment"."FTI_Name"
        ) cte 
        GROUP BY "FeeName"';

        RETURN QUERY EXECUTE "sqlquery";

    ELSIF "Type" = 'route' THEN
        
        OPEN "routecursor" FOR 
        SELECT DISTINCT "MR"."TRMR_Id","MR"."TRMR_RouteName" 
        FROM "TRN"."TR_Master_Route" "MR" 
        INNER JOIN "TRN"."TR_Student_Route" "SR" ON "MR"."MI_Id"="SR"."MI_Id" AND "SR"."ASMAY_Id"="asmay_Id" 
        WHERE "MR"."MI_Id"="mi_id" AND "TRMR_ActiveFlg"=true;

        LOOP
            FETCH "routecursor" INTO "trmr_id", "RouteName";
            EXIT WHEN NOT FOUND;

            "sqlquery" := 'SELECT SUM(sq."Charges")::BIGINT, SUM(sq."Concession")::BIGINT, SUM(sq."Rebate")::BIGINT, SUM(sq."Waive")::BIGINT, SUM(sq."Fine")::BIGINT, SUM(sq."Collection")::BIGINT, SUM(sq."DebitBalance")::BIGINT, SUM(sq."LastYear")::BIGINT FROM (
            SELECT SUM("FSS_NetAmount") AS "Charges",SUM("FSS_ConcessionAmount") AS "Concession",SUM("FSS_RebateAmount") AS "Rebate",SUM("FSS_WaivedAmount") AS "Waive",SUM("FSS_FineAmount") AS "Fine",SUM("FSS_PaidAmount") AS "Collection",SUM("FSS_ToBePaid") AS "DebitBalance",SUM("FSS_OBArrearAmount") AS "LastYear","Fee_Master_Group"."FMG_GroupName"
            FROM "Fee_Master_Group" 
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "Fee_Master_Group_Grouping_Groups" ON "Fee_Student_Status"."FMG_Id"="Fee_Master_Group_Grouping_Groups"."FMG_Id" 
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id" 
            WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || ') AND ("Fee_Student_Status"."MI_Id" = ' || "mi_id" || ') AND ("Fee_Master_Terms"."FMT_Id" IN (' || "fmt_id" || ')) 
            AND ("Adm_School_Y_Student"."AMAY_ActiveFlag"=true) AND ("Adm_M_Student"."AMST_SOL"=''S'') AND ("Adm_M_Student"."AMST_ActiveFlag"=true) AND ("Fee_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')) AND "FMGG_id" IN(' || "fmgg_id" || ')
            AND ("Fee_Student_Status"."AMST_Id" IN (
                SELECT DISTINCT "AMST_Id" FROM "TRN"."TR_Student_Route" WHERE "mi_id"=' || "mi_id" || ' 
                AND "TRMR_Id" IN (SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" WHERE "mi_id"=' || "mi_id" || ' AND "TRMR_Id" = ' || "trmr_id" || ') AND "ASMAY_Id"=' || "asmay_Id" || ' AND "TRSR_ActiveFlg"=true 
                UNION  
                SELECT DISTINCT "AMST_Id" FROM "TRN"."TR_Student_Route" WHERE "mi_id"=' || "mi_id" || '
                AND "TRMR_Drop_Route" IN (SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" WHERE "mi_id"=' || "mi_id" || ' AND "TRMR_Id" = ' || "trmr_id" || ')
                AND "ASMAY_Id"=' || "asmay_Id" || ' AND "TRSR_ActiveFlg"=true AND "AMST_Id" NOT IN(SELECT DISTINCT "AMST_Id" FROM "TRN"."TR_Student_Route" WHERE "mi_id"=' || "mi_id" || '
                AND "TRMR_Id" IN (SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" WHERE "mi_id"=' || "mi_id" || ' AND "TRMR_Id"<>0) AND "ASMAY_Id"=' || "asmay_Id" || ' AND "TRSR_ActiveFlg"=true)
            )) GROUP BY "Fee_Master_Group"."FMG_GroupName") sq';

            OPEN "IndRoute" FOR EXECUTE "sqlquery";
            FETCH "IndRoute" INTO "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear";
            
            IF FOUND THEN
                INSERT INTO "IndRoute" VALUES("RouteName", "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear");
            END IF;
            
            CLOSE "IndRoute";

        END LOOP;

        CLOSE "routecursor";

        RETURN QUERY 
        SELECT "RouteName"::TEXT, SUM("Charges")::BIGINT, SUM("Concession")::BIGINT, SUM("Rebate")::BIGINT, 
               SUM("Waive")::BIGINT, SUM("Fine")::BIGINT, (SUM("Collection")-SUM("Fine"))::BIGINT, SUM("Debit")::BIGINT, SUM("LastYear")::BIGINT 
        FROM "IndRoute" 
        GROUP BY "RouteName" 
        HAVING SUM("Charges") > 0;

    ELSIF "Type" = 'All' THEN
        "sqlquery" := 'SELECT "ClassName"::TEXT, SUM("Charges")::BIGINT, SUM("Concession")::BIGINT, SUM("Rebate")::BIGINT, SUM("Waive")::BIGINT, SUM("Fine")::BIGINT, SUM("Collection")::BIGINT, SUM("Debit")::BIGINT, SUM("LastYear")::BIGINT FROM (
        SELECT DISTINCT "Adm_School_M_Class"."ASMCL_ClassName" AS "ClassName",SUM("Fee_Student_Status"."FSS_NetAmount") AS "NetAmt",SUM("FSS_ConcessionAmount") AS "ConcessAmt",SUM("FSS_RebateAmount") AS "RebateAmt",SUM("FSS_WaivedAmount") AS "WaivedAmt",SUM("FSS_FineAmount") AS "FineAmt",SUM("FSS_PaidAmount") AS "CollectionAmt",SUM("FSS_OBArrearAmount") AS "OBArrearAmt",SUM("FSS_ToBePaid") AS tobepaid
        FROM "Fee_Master_Group" 
        INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id"=' || "asmay_Id" || '
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id"=' || "mi_id" || '
        INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID"=' || "mi_id" || '
        INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"
        WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || ') AND ("Fee_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')) 
        AND ("Fee_Student_Status"."MI_Id" = ' || "mi_id" || ') AND "Fee_Student_Status"."FMG_Id" IN (SELECT DISTINCT "FMG_Id" FROM "Fee_Master_Group_Grouping_Groups" WHERE "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN(SELECT DISTINCT "fmgg_id" FROM "Fee_Master_Group_Grouping" WHERE "mi_id"=' || "mi_id" || ' AND "fmgg_id" IN(' || "fmgg_id" || ')))
        AND ("Fee_Student_Status"."ASMAY_Id" = ' || "asmay_Id" || ') GROUP BY "Adm_School_M_Class"."ASMCL_ClassName"
        ) cte 
        GROUP BY "ClassName"';

        RETURN QUERY EXECUTE "sqlquery";

    ELSIF "Type" = 'individual' AND "status" = 'false' THEN
        "sqlquery" := 'SELECT "admno"::TEXT, "StudentName"::TEXT, SUM("Charges")::BIGINT, SUM("Concession")::BIGINT, SUM("Rebate")::BIGINT, SUM("Waive")::BIGINT, SUM("Fine")::BIGINT, SUM("Collection")::BIGINT, SUM("Debit")::BIGINT FROM (
        SELECT DISTINCT "Adm_M_Student"."AMST_Admno" AS admno,(COALESCE("AMST_FirstName",'''')||'' ''||COALESCE("AMST_MiddleName",'''')||'' ''||COALESCE("AMST_LastName",'''')) AS "StudentName","FMH_FeeName" "FeeName","FTI_Name" "TName","FSS_NetAmount" AS "NetAmt","FSS_ConcessionAmount" AS "ConcessAmt","FSS_RebateAmount" AS "RebateAmt","FSS_WaivedAmount" AS "WaivedAmt","FSS_FineAmount" AS "FineAmt","FSS_PaidAmount" AS "CollectionAmt","FSS_OBArrearAmount" AS "OBArrearAmt","FSS_ToBePaid" AS tobepaid, "FSS_CurrentYrCharges" AS "Currentamt"
        FROM "Fee_Master_Group" 
        INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id"=' || "mi_id" || ' AND "AMST_ActiveFlag"=true AND "amst_sol"=''S''
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id"=' || "asmay_Id" || '
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id"=' || "mi_id" || '
        INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID"=' || "mi_id" || '
        INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id"="Fee_Student_Status"."FMA_Id"
        WHERE ("Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || ') AND ("Fee_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')) 
        AND ("Fee_Student_Status"."MI_Id" = ' || "mi_id" || ') AND ("Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id" || ') AND ("Adm_School_M_Section"."asms_id" =' || "amsc_id" || ') 
        AND "Fee_Student_Status"."FMG_Id" IN (SELECT DISTINCT "FMG_Id" FROM "Fee_Master_Group_Grouping_Groups" WHERE "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN(SELECT DISTINCT "fmgg_id" FROM "Fee_Master_Group_Grouping" WHERE "mi_id"=' || "mi_id" || ' AND "fmgg_id" IN(' || "fmgg_id" || ')))
        AND ("Fee_Student_Status"."ASMAY_Id" = ' || "asmay_Id" || ')
        ) cte 
        GROUP BY admno,"StudentName"';

        RETURN QUERY EXECUTE "sqlquery";

    ELSIF "Type" = 'individual' AND "status" = 'true' THEN
        "sqlquery" := 'SELECT "admno"::TEXT, "StudentName"::TEXT, SUM("Charges")::BIGINT, SUM("Concession")::BIGINT, SUM("Rebate")::BIGINT, SUM("Waive")::BIGINT, SUM("Fine")::BIGINT, SUM("Collection")::BIGINT, SUM("Debit")::BIGINT FROM (
        SELECT DISTINCT "Adm_M_Student"."AMST_Admno" AS admno,(COALESCE("AMST_FirstName",'''')||'' ''||COALESCE("AMST_MiddleName",'''')||'' ''||COALESCE("AMST_LastName",'''')) AS "StudentName","FMH_FeeName" "FeeName","FTI_Name" "TName","FSS_NetAmount" AS "NetAmt","FSS_ConcessionAmount" AS "ConcessAmt","FSS_RebateAmount" AS "RebateAmt","FSS_WaivedAmount" AS "WaivedAmt","FSS_FineAmount" AS "FineAmt","FSS_PaidAmount" AS "CollectionAmt","FSS_OBArrearAmount" AS "OBArrearAmt","FSS_ToBePaid" AS tobepaid, "FSS_CurrentYrCharges" AS "Currentamt"
        FROM "Fee_Master_Group" 
        INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id"="Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id"=' || "mi_id" || ' AND "AMST_ActiveFlag"=false AND ("amst_sol"=''L'' OR "amst_sol"=''D'')
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id"="Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id"=' || "asmay_Id" || '
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id"="Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id"=' || "mi_id" || '
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id"="Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id"=' || "mi_id" || '
        INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id"="Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID"=' || "mi_id" || '
        INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id"="Fee