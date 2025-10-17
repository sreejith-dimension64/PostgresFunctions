CREATE OR REPLACE FUNCTION "dbo"."Fee_DetailedAccountPosition_AsonDate_FY"(
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
    "status" TEXT,
    "asonduedate" VARCHAR(10)
)
RETURNS TABLE(
    "Result1" TEXT,
    "Result2" BIGINT,
    "Result3" BIGINT,
    "Result4" BIGINT,
    "Result5" BIGINT,
    "Result6" BIGINT,
    "Result7" BIGINT,
    "Result8" BIGINT,
    "Result9" BIGINT
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
    "DynamicD1" TEXT;
    "DynamicD2" TEXT;
    rec RECORD;
BEGIN

    IF "fromdate" != '' AND "todate" != '' AND "date" = '' THEN
        "where_condition" := ' and "FYP_Date" between TO_DATE(''' || "fromdate" || ''', ''DD-MM-YYYY'') and TO_DATE(''' || "todate" || ''', ''DD-MM-YYYY'') ';
    ELSIF "date" != '' OR "asonduedate" != '' THEN
        SELECT CAST("IMFY_FromDate" AS DATE) INTO "ASMAY_From_Date" 
        FROM "IVRM_Master_FinancialYear" 
        WHERE TO_DATE("date", 'DD-MM-YYYY') BETWEEN "IMFY_FromDate" AND "IMFY_ToDate";
        
        "where_condition" := ' and "FYP_Date" between ''' || "ASMAY_From_Date" || ''' and TO_DATE(''' || "date" || ''', ''DD-MM-YYYY'')';
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
        "sqlquery" := 'WITH cte AS (
            SELECT DISTINCT "Adm_School_M_Class"."ASMCL_ClassName" AS "ClassName",
                "Fee_Master_Head"."FMH_FeeName" AS "FeeName",
                "fee_t_installment"."FTI_Name",
                SUM("fee_student_status"."FSS_NetAmount") AS "NetAmt",
                SUM("FSS_ConcessionAmount") AS "ConcessAmt",
                SUM("FSS_RebateAmount") AS "RebateAmt",
                SUM("FSS_WaivedAmount") AS "WaivedAmt",
                SUM("FSS_FineAmount") AS "FineAmt",
                SUM("FSS_PaidAmount") AS "CollectionAmt",
                SUM("FSS_OBArrearAmount") AS "OBArrearAmt",
                SUM("FSS_ToBePaid") AS tobepaid
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || '
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID" = ' || "mi_id" || '
            INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || ' 
                AND "Fee_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')
                AND "fee_student_status"."MI_Id" = ' || "mi_id" || '
                AND "Fee_Student_Status"."FMG_Id" IN (
                    SELECT DISTINCT "FMG_Id" FROM "Fee_Master_Group_Grouping_Groups" 
                    WHERE "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN (
                        SELECT DISTINCT "fmgg_id" FROM "Fee_Master_Group_Grouping" 
                        WHERE "mi_id" = ' || "mi_id" || ' AND "fmgg_id" IN (' || "fmgg_id" || ')
                    )
                )
                AND "fee_student_status"."ASMAY_Id" = ' || "asmay_Id" || '
            GROUP BY "Adm_School_M_Class"."ASMCL_ClassName", "Fee_Master_Head"."FMH_FeeName", "fee_t_installment"."FTI_Name"
        )
        SELECT "FeeName", 
            SUM("NetAmt") AS "Charges",
            SUM("ConcessAmt") AS "Concession",
            SUM("RebateAmt") AS "Rebate/Schlorship",
            SUM("WaivedAmt") AS "Waive Off",
            SUM("FineAmt") AS "Fine",
            (SUM("CollectionAmt") - SUM("FineAmt")) AS "Collection",
            SUM(tobepaid) AS "Debit Balance",
            SUM("OBArrearAmt") AS "Last Year Due"
        FROM cte 
        GROUP BY "FeeName"';
        
        RETURN QUERY EXECUTE "sqlquery";

    ELSIF "Type" = 'route' THEN
        FOR rec IN 
            SELECT DISTINCT MR."TRMR_Id", MR."TRMR_RouteName" 
            FROM "TRN"."TR_Master_Route" MR
            INNER JOIN "TRN"."TR_Student_Route" SR ON MR."MI_Id" = SR."MI_Id" AND SR."ASMAY_Id" = "asmay_Id"
            WHERE MR."MI_Id" = "mi_id" AND "TRMR_ActiveFlg" = TRUE
        LOOP
            "trmr_id" := rec."TRMR_Id";
            "RouteName" := rec."TRMR_RouteName";
            
            "sqlquery" := 'SELECT SUM("Charges") "Charges", SUM("Concession") "Concession", SUM("Rebate/Schlorship") "Rebate/Schlorship", 
                SUM("Waive Off") "Waive Off", SUM("Fine") "Fine", SUM("Collection") "Collection", 
                SUM("Debit Balance") "Debit Balance", SUM("Last Year Due") "Last Year Due"
            FROM (
                SELECT SUM("FSS_NetAmount") "Charges", SUM("FSS_ConcessionAmount") AS "Concession",
                    SUM("FSS_RebateAmount") AS "Rebate/Schlorship", SUM("FSS_WaivedAmount") AS "Waive Off",
                    SUM("FSS_FineAmount") AS "Fine", SUM("FSS_PaidAmount") AS "Collection",
                    SUM("FSS_ToBePaid") AS "Debit Balance", SUM("FSS_OBArrearAmount") AS "Last Year Due",
                    "Fee_Master_Group"."FMG_GroupName"
                FROM "Fee_Master_Group"
                INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
                INNER JOIN "Fee_Master_Group_Grouping_Groups" ON "fee_student_status"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id"
                INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
                INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
                INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
                INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
                    AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" 
                    AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
                WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || '
                    AND "Fee_Student_Status"."MI_Id" = ' || "mi_id" || '
                    AND "Fee_Master_Terms"."FMT_Id" IN (' || "fmt_id" || ')
                    AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = TRUE
                    AND "Adm_M_Student"."AMST_SOL" = ''S''
                    AND "Adm_M_Student"."AMST_ActiveFlag" = TRUE
                    AND "Fee_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')
                    AND "FMGG_id" IN (' || "fmgg_id" || ')
                    AND "Fee_Student_Status"."AMST_Id" IN (
                        SELECT DISTINCT "AMST_Id" FROM "TRN"."TR_Student_Route" 
                        WHERE "mi_id" = ' || "mi_id" || ' 
                            AND "TRMR_Id" IN (SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" 
                                WHERE "mi_id" = ' || "mi_id" || ' AND "TRMR_Id" = ' || "trmr_id" || ')
                            AND "ASMAY_Id" = ' || "asmay_Id" || ' AND "TRSR_ActiveFlg" = TRUE
                        UNION
                        SELECT DISTINCT "AMST_Id" FROM "TRN"."TR_Student_Route" 
                        WHERE "mi_id" = ' || "mi_id" || '
                            AND "TRMR_Drop_Route" IN (SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" 
                                WHERE "mi_id" = ' || "mi_id" || ' AND "TRMR_Id" = ' || "trmr_id" || ')
                            AND "ASMAY_Id" = ' || "asmay_Id" || ' AND "TRSR_ActiveFlg" = TRUE
                            AND "AMST_Id" NOT IN (SELECT DISTINCT "AMST_Id" FROM "TRN"."TR_Student_Route" 
                                WHERE "mi_id" = ' || "mi_id" || '
                                    AND "TRMR_Id" IN (SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" 
                                        WHERE "mi_id" = ' || "mi_id" || ' AND "TRMR_Id" <> 0)
                                    AND "ASMAY_Id" = ' || "asmay_Id" || ' AND "TRSR_ActiveFlg" = TRUE)
                    )
                GROUP BY "Fee_Master_Group"."FMG_GroupName"
            ) "New"';
            
            EXECUTE "sqlquery" INTO "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear";
            
            IF FOUND THEN
                INSERT INTO "IndRoute" VALUES ("RouteName", "Charges", "Concession", "Rebate", "Waive", "Fine", "Collection", "Debit", "LastYear");
            END IF;
        END LOOP;
        
        RETURN QUERY 
        SELECT "RouteName" AS "RouteName", 
            SUM("Charges") AS "Charges", 
            SUM("Concession") AS "Concession", 
            SUM("Rebate") AS "Rebate/Schlorship",
            SUM("Waive") AS "Waive Off", 
            SUM("Fine") AS "Fine", 
            (SUM("Collection") - SUM("Fine")) AS "Collection", 
            SUM("Debit") AS "Debit Balance", 
            SUM("LastYear") AS "Last Year Due"
        FROM "IndRoute" 
        GROUP BY "RouteName" 
        HAVING SUM("Charges") > 0;

    ELSIF "Type" = 'All' THEN
        "sqlquery" := 'WITH cte AS (
            SELECT DISTINCT "Adm_School_M_Class"."ASMCL_ClassName" AS "ClassName",
                SUM("fee_student_status"."FSS_NetAmount") AS "NetAmt",
                SUM("FSS_ConcessionAmount") AS "ConcessAmt",
                SUM("FSS_RebateAmount") AS "RebateAmt",
                SUM("FSS_WaivedAmount") AS "WaivedAmt",
                SUM("FSS_FineAmount") AS "FineAmt",
                SUM("FSS_PaidAmount") AS "CollectionAmt",
                SUM("FSS_OBArrearAmount") AS "OBArrearAmt",
                SUM("FSS_ToBePaid") AS tobepaid
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || '
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID" = ' || "mi_id" || '
            INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || '
                AND "Fee_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')
                AND "fee_student_status"."MI_Id" = ' || "mi_id" || '
                AND "Fee_Student_Status"."FMG_Id" IN (
                    SELECT DISTINCT "FMG_Id" FROM "Fee_Master_Group_Grouping_Groups"
                    WHERE "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN (
                        SELECT DISTINCT "fmgg_id" FROM "Fee_Master_Group_Grouping"
                        WHERE "mi_id" = ' || "mi_id" || ' AND "fmgg_id" IN (' || "fmgg_id" || ')
                    )
                )
                AND "fee_student_status"."ASMAY_Id" = ' || "asmay_Id" || '
            GROUP BY "Adm_School_M_Class"."ASMCL_ClassName"
        )
        SELECT "ClassName",
            SUM("NetAmt") AS "Charges",
            SUM("ConcessAmt") AS "Concession",
            SUM("RebateAmt") AS "Rebate/Schlorship",
            SUM("WaivedAmt") AS "Waive Off",
            SUM("FineAmt") AS "Fine",
            (SUM("CollectionAmt") - SUM("FineAmt")) AS "Collection",
            SUM(tobepaid) AS "Debit Balance",
            SUM("OBArrearAmt") AS "Last Year Due"
        FROM cte 
        GROUP BY "ClassName"';
        
        RETURN QUERY EXECUTE "sqlquery";

    ELSIF "Type" = 'individual' AND "status" = 'true' THEN
        "sqlquery" := 'WITH cte AS (
            SELECT DISTINCT "Adm_M_Student"."AMST_Admno" AS admno,
                (COALESCE("AMST_FirstName", '''') || '' '' || COALESCE("AMST_MiddleName", '''') || '' '' || COALESCE("AMST_LastName", '''')) AS "StudentName",
                "FMH_FeeName" "FeeName",
                "FTI_Name" "TName",
                "FSS_NetAmount" AS "NetAmt",
                "FSS_ConcessionAmount" AS "ConcessAmt",
                "FSS_RebateAmount" AS "RebateAmt",
                "FSS_WaivedAmount" AS "WaivedAmt",
                "FSS_FineAmount" AS "FineAmt",
                "FSS_PaidAmount" AS "CollectionAmt",
                "FSS_OBArrearAmount" AS "OBArrearAmt",
                "FSS_ToBePaid" AS tobepaid,
                "FSS_CurrentYrCharges" AS "Currentamt"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
                AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || ' 
                AND "AMST_ActiveFlag" = FALSE 
                AND ("amst_sol" = ''L'' OR "amst_sol" = ''D'')
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || '
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" AND "Adm_School_M_Class"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" AND "Adm_School_M_Section"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Master_Terms_FeeHeads"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND "Fee_Master_Terms"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "fee_t_installment" ON "fee_t_installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND "fee_t_installment"."MI_ID" = ' || "mi_id" || '
            INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "asmay_Id" || '
                AND "Fee_Student_Status"."FMG_Id" IN (' || "fmg_id" || ')
                AND "fee_student_status"."MI_Id" = ' || "mi_id" || '
                AND "Adm_School_M_Class"."ASMCL_Id" = ' || "asmcl_id" || '
                AND "adm_school_m_section"."asms_id" = ' || "amsc_id" || '
                AND "Fee_Student_Status"."FMG_Id" IN (
                    SELECT DISTINCT "FMG_Id" FROM "Fee_Master_Group_Grouping_Groups"
                    WHERE "Fee_Master_Group_Grouping_Groups"."fmgg_id" IN (
                        SELECT DISTINCT "fmgg_id" FROM "Fee_Master_Group_Grouping"
                        WHERE "mi_id" = ' || "mi_id" || ' AND "fmgg_id" IN (' || "fmgg_id" || ')
                    )
                )
                AND "fee_student_status"."ASMAY_Id" = ' || "asmay_Id" || '
        )
        SELECT admno,
            "StudentName",
            SUM("NetAmt") AS "Charges",
            SUM("ConcessAmt") AS "Concession",
            SUM("RebateAmt") AS "Rebate/Schlorship",
            SUM("WaivedAmt") AS "Waive Off",
            SUM("FineAmt") AS "Fine",
            (SUM("CollectionAmt") - SUM("FineAmt")) AS "Collection",
            SUM(tobepaid) AS "Debit Balance",
            SUM("OBArrearAmt") AS "Last Year Due"
        FROM cte 
        GROUP BY admno, "StudentName"';
        
        RETURN QUERY EXECUTE "sqlquery";

    ELSIF "Type" = 'individual' AND "status" = 'false' THEN
        DROP TABLE IF EXISTS "Students_StatusCYChargesAcc_Temp";
        DROP TABLE IF EXISTS "Students_CYPaidAcc_Temp";

        "DynamicD1" := 'CREATE TEMP TABLE "Students_StatusCYChargesAcc_Temp" AS
        WITH cte AS (
            SELECT DISTINCT "Adm_M_Student"."AMST_Id",
                "Adm_M_Student"."AMST_Admno" AS admno,
                (COALESCE("AMST_FirstName", '''') || '' '' || COALESCE("AMST_MiddleName", '''') || '' '' || COALESCE("AMST_LastName", '''')) AS "StudentName",
                "FMH_FeeName" "FeeName",
                "FTI_Name" "TName",
                "FSS_NetAmount" AS "NetAmt",
                "FSS_ConcessionAmount" AS "ConcessAmt",
                "FSS_RebateAmount" AS "RebateAmt",
                "FSS_WaivedAmount" AS "WaivedAmt",
                "FSS_FineAmount" AS "FineAmt",
                "FSS_PaidAmount" AS "CollectionAmt",
                "FSS_OBArrearAmount" AS "OBArrearAmt",
                "FSS_ToBePaid" AS tobepaid,
                "FSS_CurrentYrCharges" AS "Currentamt"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = ' || "mi_id" || '
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_