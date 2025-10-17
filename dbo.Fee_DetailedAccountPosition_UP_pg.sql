CREATE OR REPLACE FUNCTION "dbo"."Fee_DetailedAccountPosition_UP"(
    p_mi_id BIGINT,
    p_asmay_Id BIGINT,
    p_asmcl_id BIGINT,
    p_amsc_id BIGINT,
    p_fmgg_id TEXT,
    p_fmg_id TEXT,
    p_date VARCHAR(10),
    p_fromdate VARCHAR(10),
    p_todate VARCHAR(10),
    p_Type VARCHAR(60),
    p_fmt_id TEXT
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_aa TEXT;
    v_where_condition TEXT;
    v_sqlquery TEXT;
    v_OnAnyDate TEXT;
    v_ASMAY_From_Date VARCHAR(10);
    v_SqlqueryC TEXT;
    v_trmr_id BIGINT;
    v_RouteName VARCHAR(100);
    v_Charges BIGINT;
    v_Concession BIGINT;
    v_Rebate BIGINT;
    v_Waive BIGINT;
    v_Fine BIGINT;
    v_Collection BIGINT;
    v_Debit BIGINT;
    v_LastYear BIGINT;
    routecursor REFCURSOR;
    IndRoute REFCURSOR;
BEGIN

    IF p_fromdate != '' AND p_todate != '' AND p_date = '' THEN
        v_where_condition := ' and "FYP_Date" between TO_DATE(''' || p_fromdate || ''', ''DD-MM-YYYY'') and TO_DATE(''' || p_todate || ''', ''DD-MM-YYYY'') ';
    ELSIF p_date != '' THEN
        SELECT TO_CHAR("ASMAY_From_Date", 'DD-MM-YYYY') INTO v_ASMAY_From_Date 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_mi_id AND "ASMAY_Id" = p_asmay_id;
        
        v_where_condition := ' and "FYP_Date" between TO_DATE(''' || v_ASMAY_From_Date || ''', ''DD-MM-YYYY'') and TO_DATE(''' || p_date || ''', ''DD-MM-YYYY'')';
    ELSE
        v_where_condition := '';
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

    IF p_Type = 'headwise' THEN
        v_sqlquery := 'with cte as (
            SELECT DISTINCT 
            "Adm_School_M_Class"."ASMCL_ClassName" AS "ClassName", 
            "FMH_FeeName" AS "FeeName",
            "FTI_Name" AS "TName",
            "FSS_NetAmount" AS "NetAmt",
            "FSS_ConcessionAmount" AS "ConcessAmt",
            "FSS_RebateAmount" AS "RebateAmt",
            "FSS_WaivedAmount" AS "WaivedAmt",
            "FSS_FineAmount" AS "FineAmt",
            "FSS_PaidAmount" AS "CollectionAmt",
            "FSS_OBArrearAmount" AS "OBArrearAmt",
            "FSS_ToBePaid" AS tobepaid
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" 
            INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."FEE_Yearly_Group"."FMG_Id" AND "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Head"."MI_Id" = "dbo"."Fee_Student_Status"."MI_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_Id" = "dbo"."Fee_Student_Status"."ASMAY_Id" AND "dbo"."Fee_Student_Status"."MI_Id" = "dbo"."Fee_Y_Payment"."MI_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" 
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL" = ''S'' AND "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            WHERE ("dbo"."Fee_Student_Status"."FMG_Id" IS NOT NULL) AND ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'')  
            AND "dbo"."Fee_Student_Status"."ASMAY_Id" IN ( 
                SELECT DISTINCT "dbo"."Adm_School_M_Class_Category"."ASMAY_Id" FROM  
                "dbo"."Adm_School_M_Class_Category" 
                INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_M_Class_Category"."ASMCL_Id" 
                INNER JOIN "dbo"."Adm_School_Master_Class_Cat_Sec" ON "dbo"."Adm_School_M_Class_Category"."ASMCC_Id" = "Adm_School_Master_Class_Cat_Sec"."ASMCC_Id"
                WHERE ("dbo"."Adm_School_M_Class_Category"."ASMAY_Id" = ' || p_asmay_Id || ')   
            ) AND "dbo"."Fee_Y_Payment"."mi_id" = ' || p_mi_id || ' AND "dbo"."Fee_Y_Payment"."ASMAY_ID" = ' || p_asmay_Id || '   
            AND "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" IN (' || p_fmgg_id || ') AND "dbo"."Fee_Master_Group"."FMG_Id" IN (' || p_fmg_id || ') ' || v_where_condition || '
            AND "Fee_Y_Payment"."FYP_Id" IN (SELECT "FYP_Id" FROM "dbo"."Fee_T_Payment") AND "Fee_Master_Amount"."FMA_Id" IN (SELECT "FMA_Id" FROM "dbo"."Fee_T_Payment")
        ) 
        SELECT "FeeName", SUM("NetAmt") AS "Charges", SUM("ConcessAmt") AS "Concession", SUM("RebateAmt") AS "Rebate/Schlorship", 
        SUM("WaivedAmt") AS "Waive Off", SUM("FineAmt") AS "Fine", SUM("CollectionAmt") AS "Collection", 
        SUM(tobepaid) AS "Debit Balance", SUM("OBArrearAmt") AS "Last Year Due" 
        FROM cte GROUP BY "FeeName"';
        
        EXECUTE v_sqlquery;

    ELSIF p_Type = 'route' THEN
        OPEN routecursor FOR
        SELECT DISTINCT "MR"."TRMR_Id" 
        FROM "TRN"."TR_Master_Route" "MR" 
        INNER JOIN "TRN"."TR_Student_Route" "SR" ON "MR"."MI_Id" = "SR"."MI_Id" AND "SR"."ASMAY_Id" = p_asmay_Id
        WHERE "MR"."MI_Id" = p_MI_Id AND "TRMR_ActiveFlg" = 1;
        
        LOOP
            FETCH routecursor INTO v_trmr_id;
            EXIT WHEN NOT FOUND;
            
            v_sqlquery := 'SELECT DISTINCT 
                "TRMR_RouteName" AS "RouteName",
                SUM("FSS_NetAmount") AS "Charges",
                SUM("FSS_ConcessionAmount") AS "Concession",
                SUM("FSS_RebateAmount") AS "Rebate",
                SUM("FSS_WaivedAmount") AS "Waive",
                SUM("FSS_FineAmount") AS "Fine",
                SUM("FSS_PaidAmount") AS "Collection",
                SUM("FSS_ToBePaid") AS "Debit",
                SUM("FSS_OBArrearAmount") AS "LastYear"
                FROM "fee_student_status" 
                INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "fee_student_status"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id"
                INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Student_Status"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" 
                INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" 
                INNER JOIN "dbo"."Fee_Master_Terms" ON "dbo"."Fee_Master_Terms"."FMT_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FMT_Id" AND "dbo"."Fee_Student_Status"."FTI_Id" = "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" 
                INNER JOIN "TRN"."TR_Student_Route" "SR" ON "SR"."AMST_Id" = "fee_student_status"."AMST_Id" AND "SR"."mi_id" = ' || p_mi_id || ' AND "SR"."ASMAY_Id" = ' || p_asmay_Id || '
                INNER JOIN "TRN"."TR_Master_Route" "MR" ON ("MR"."TRMR_Id" = "SR"."TRMR_Id" OR "TRMR_Drop_Route" = "MR"."TRMR_Id") AND "MR"."TRMR_Id" = ' || v_trmr_id || '
                WHERE "fee_student_status"."mi_id" = ' || p_mi_id || ' AND "fee_student_status"."ASMAY_Id" = ' || p_asmay_Id || ' 
                AND "dbo"."Fee_Master_Terms"."FMT_Id" IN (' || p_fmt_id || ')
                AND "dbo"."Fee_Student_Status"."AMST_Id" IN (
                    SELECT DISTINCT "amst_id" FROM "Fee_Y_Payment_School_Student" 
                    WHERE "Fee_Y_Payment_School_Student"."FYP_Id" IN (
                        SELECT DISTINCT "fyp_id" FROM "fee_y_payment" 
                        WHERE "mi_id" = ' || p_mi_id || ' AND "ASMAY_ID" = ' || p_asmay_Id || '
                    )
                    AND "Fee_Y_Payment_School_Student"."amst_id" IN (
                        SELECT DISTINCT "AMST_Id" FROM "TRN"."TR_Student_Route" 
                        WHERE "mi_id" = ' || p_mi_id || '
                        AND "TRMR_Id" = (SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" WHERE "mi_id" = ' || p_mi_id || ' AND "TRMR_Id" = ' || v_trmr_id || ') 
                        AND "ASMAY_Id" = ' || p_asmay_Id || ' AND "TRSR_ActiveFlg" = 1
                        UNION
                        SELECT DISTINCT "AMST_Id" FROM "TRN"."TR_Student_Route" 
                        WHERE "mi_id" = ' || p_mi_id || '
                        AND "TRMR_Drop_Route" = (SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" WHERE "mi_id" = ' || p_mi_id || ' AND "TRMR_Id" = ' || v_trmr_id || ') 
                        AND "ASMAY_Id" = ' || p_asmay_Id || ' AND "TRSR_ActiveFlg" = 1 
                        AND "AMST_Id" NOT IN (
                            SELECT DISTINCT "AMST_Id" FROM "TRN"."TR_Student_Route" 
                            WHERE "mi_id" = ' || p_mi_id || '
                            AND "TRMR_Id" IN (SELECT "TRMR_Id" FROM "TRN"."TR_Master_Route" WHERE "mi_id" = ' || p_mi_id || ' AND "TRMR_Id" <> 0) 
                            AND "ASMAY_Id" = ' || p_asmay_Id || ' AND "TRSR_ActiveFlg" = 1
                        )
                    )
                )
                AND "fee_student_status"."FMG_Id" IN (' || p_fmg_id || ') AND "FMGG_Id" IN (' || p_fmgg_id || ') 
                AND "fee_student_status"."AMST_Id" IN (
                    SELECT "Adm_M_Student"."amst_id" FROM "dbo"."Adm_M_Student" 
                    INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
                    AND "Adm_M_Student"."AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
                    WHERE "mi_id" = ' || p_mi_id || ' AND "Adm_School_Y_Student"."asmay_id" = ' || p_asmay_Id || '
                )  
                GROUP BY "TRMR_RouteName"';
            
            OPEN IndRoute FOR EXECUTE v_sqlquery;
            
            LOOP
                FETCH IndRoute INTO v_RouteName, v_Charges, v_Concession, v_Rebate, v_Waive, v_Fine, v_Collection, v_Debit, v_LastYear;
                EXIT WHEN NOT FOUND;
                
                INSERT INTO "IndRoute" VALUES(v_RouteName, v_Charges, v_Concession, v_Rebate, v_Waive, v_Fine, v_Collection, v_Debit, v_LastYear);
            END LOOP;
            
            CLOSE IndRoute;
        END LOOP;
        
        CLOSE routecursor;
        
        PERFORM * FROM (
            SELECT "RouteName", SUM("Charges") AS "Charges", SUM("Concession") AS "Concession", SUM("Rebate") AS "Rebate/Schlorship",
            SUM("Waive") AS "Waive Off", SUM("Fine") AS "Fine", SUM("Collection") AS "Collection", 
            SUM("Debit") AS "Debit Balance", SUM("LastYear") AS "Last Year Due" 
            FROM "IndRoute" 
            GROUP BY "RouteName"
        ) AS result;

    ELSIF p_Type = 'All' THEN
        v_sqlquery := 'with cte as (
            SELECT DISTINCT 
            "Adm_School_M_Class"."ASMCL_ClassName" AS "ClassName",
            "FMH_FeeName" AS "FeeName",
            "FTI_Name" AS "TName",
            "FSS_NetAmount" AS "NetAmt",
            "FSS_ConcessionAmount" AS "ConcessAmt",
            "FSS_RebateAmount" AS "RebateAmt",
            "FSS_WaivedAmount" AS "WaivedAmt",
            "FSS_FineAmount" AS "FineAmt",
            "FSS_PaidAmount" AS "CollectionAmt",
            "FSS_OBArrearAmount" AS "OBArrearAmt",
            "FSS_ToBePaid" AS tobepaid
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" 
            INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."FEE_Yearly_Group"."FMG_Id" AND "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Head"."MI_Id" = "dbo"."Fee_Student_Status"."MI_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_Id" = "dbo"."Fee_Student_Status"."ASMAY_Id" AND "dbo"."Fee_Student_Status"."MI_Id" = "dbo"."Fee_Y_Payment"."MI_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" 
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL" = ''S'' AND "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            WHERE ("dbo"."Fee_Student_Status"."FMG_Id" IS NOT NULL) AND ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'')  
            AND "dbo"."Fee_Student_Status"."ASMAY_Id" IN ( 
                SELECT DISTINCT "dbo"."Adm_School_M_Class_Category"."ASMAY_Id" FROM  
                "dbo"."Adm_School_M_Class_Category" 
                INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_M_Class_Category"."ASMCL_Id" 
                INNER JOIN "dbo"."Adm_School_Master_Class_Cat_Sec" ON "dbo"."Adm_School_M_Class_Category"."ASMCC_Id" = "Adm_School_Master_Class_Cat_Sec"."ASMCC_Id"
                WHERE ("dbo"."Adm_School_M_Class_Category"."ASMAY_Id" = ' || p_asmay_Id || ')    
            ) AND "dbo"."Fee_Y_Payment"."mi_id" = ' || p_mi_id || ' AND "dbo"."Fee_Y_Payment"."ASMAY_ID" = ' || p_asmay_Id || '   
            AND "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" IN (' || p_fmgg_id || ') AND "dbo"."Fee_Master_Group"."FMG_Id" IN (' || p_fmg_id || ') ' || v_where_condition || '
            AND "Fee_Y_Payment"."FYP_Id" IN (SELECT "FYP_Id" FROM "dbo"."Fee_T_Payment") AND "Fee_Master_Amount"."FMA_Id" IN (SELECT "FMA_Id" FROM "dbo"."Fee_T_Payment")
        ) 
        SELECT "ClassName", SUM("NetAmt") AS "Charges", SUM("ConcessAmt") AS "Concession", SUM("RebateAmt") AS "Rebate/Schlorship", 
        SUM("WaivedAmt") AS "Waive Off", SUM("FineAmt") AS "Fine", SUM("CollectionAmt") AS "Collection", 
        SUM(tobepaid) AS "Debit Balance", SUM("OBArrearAmt") AS "Last Year Due" 
        FROM cte GROUP BY "ClassName"';
        
        EXECUTE v_sqlquery;

    ELSIF p_Type = 'individual' THEN
        v_sqlquery := 'with cte as (
            SELECT DISTINCT 
            "dbo"."Adm_M_Student"."AMST_Admno" AS admno,
            (COALESCE("AMST_FirstName", '''') || '''' || COALESCE("AMST_MiddleName", '''') || '''' || COALESCE("AMST_LastName", '''')) AS "StudentName",
            "FMH_FeeName" AS "FeeName",
            "FTI_Name" AS "TName",
            "FSS_NetAmount" AS "NetAmt",
            "FSS_ConcessionAmount" AS "ConcessAmt",
            "FSS_RebateAmount" AS "RebateAmt",
            "FSS_WaivedAmount" AS "WaivedAmt",
            "FSS_FineAmount" AS "FineAmt",
            "FSS_PaidAmount" AS "CollectionAmt",
            "FSS_OBArrearAmount" AS "OBArrearAmt",
            "FSS_ToBePaid" AS "Balance",
            "FSS_CurrentYrCharges" AS "Currentamt"
            FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" 
            INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Student_Status"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" = "dbo"."Fee_Master_Group"."FMG_Id"
            INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."FEE_Yearly_Group"."FMG_Id" AND "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" AND "dbo"."Fee_Master_Head"."MI_Id" = "dbo"."Fee_Student_Status"."MI_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment"."ASMAY_Id" = "dbo"."Fee_Student_Status"."ASMAY_Id" AND "dbo"."Fee_Student_Status"."MI_Id" = "dbo"."Fee_Y_Payment"."MI_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Adm_M_Student"."ASMAY_Id" 
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "Adm_M_Student"."AMST_SOL" = ''S'' AND "dbo"."Fee_Student_Status"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            WHERE ("dbo"."Fee_Student_Status"."FMG_Id" IS NOT NULL) AND ("dbo"."Fee_Y_Payment"."FYP_Chq