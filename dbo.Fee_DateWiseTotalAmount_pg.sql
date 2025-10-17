CREATE OR REPLACE FUNCTION "dbo"."Fee_DateWiseTotalAmount"(
    "p_MI_Id" VARCHAR(50),
    "p_ASMAY_Id" VARCHAR(50),
    "p_FromDate" VARCHAR(10),
    "p_Todate" VARCHAR(10)
)
RETURNS TABLE(
    "Date" DATE,
    "TotalPaidAmount" NUMERIC
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_PivotColumnNames" TEXT := '';
    "v_PivotSelectColumnNames" TEXT := '';
    "v_SqlDynamic" TEXT := '';
BEGIN

    SELECT STRING_AGG('"' || "FeeName" || '"', ',' ORDER BY "FeeName")
    INTO "v_PivotColumnNames"
    FROM (SELECT DISTINCT "FMH_FeeName" AS "FeeName" FROM "Fee_Master_Head" WHERE "MI_Id" = "p_MI_Id") AS "PVColumns";

    SELECT STRING_AGG('COALESCE(' || '"' || "FeeName" || '"' || ', 0) AS ' || '"' || "FeeName" || '"', ',' ORDER BY "FeeName")
    INTO "v_PivotSelectColumnNames"
    FROM (SELECT DISTINCT "FMH_FeeName" AS "FeeName" FROM "Fee_Master_Head" WHERE "MI_Id" = "p_MI_Id") AS "PVSelctedColumns";

    DROP TABLE IF EXISTS "Fee_StuwiseRecDatewiseTotalAmount_Temp";
    DROP TABLE IF EXISTS "Fee_StuwiseRecDatewiseHeadWsieTotalAmount_Temp";

    CREATE TEMP TABLE "Fee_StuwiseRecDatewiseTotalAmount_Temp" AS
    SELECT DISTINCT CAST("FYP_date" AS DATE) AS "Total_Date", SUM("FTP_Paid_Amt") AS "TotalPaidAmount"
    FROM "dbo"."Adm_M_Student"
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
    INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id"
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" 
        AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
    INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id"
    INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
    INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_T_Payment"."FYP_Id" 
        AND "Fee_T_Payment"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
    WHERE "dbo"."Fee_Y_Payment"."MI_Id" = "p_MI_Id" 
        AND "dbo"."Adm_M_Student"."MI_Id" = "p_MI_Id" 
        AND "dbo"."Adm_School_M_Class"."MI_Id" = "p_MI_Id" 
        AND "dbo"."Adm_School_M_Section"."MI_Id" = "p_MI_Id" 
        AND "dbo"."Fee_Student_Status"."MI_Id" = "p_MI_Id" 
        AND "dbo"."Fee_Master_Terms_FeeHeads"."MI_Id" = "p_MI_Id" 
        AND "dbo"."Fee_Master_Head"."MI_Id" = "p_MI_Id" 
        AND "dbo"."Fee_Student_Status"."ASMAY_Id" = "p_ASMAY_Id" 
        AND "dbo"."Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id" 
        AND "dbo"."Fee_Y_Payment_School_Student"."ASMAY_Id" = "p_ASMAY_Id"
        AND (CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN CAST("p_FromDate" AS DATE) AND CAST("p_Todate" AS DATE))
    GROUP BY CAST("FYP_date" AS DATE);

    "v_SqlDynamic" := '
    CREATE TEMP TABLE "Fee_StuwiseRecDatewiseHeadWsieTotalAmount_Temp" AS
    SELECT * FROM CROSSTAB(
        ''SELECT CAST("FYP_date" AS DATE)::TEXT AS "FYP_date", "FMH_FeeName" AS "FeeName", SUM("FTP_Paid_Amt") AS "HeadPaidAmount"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Fee_Student_Status" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id"
        INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" ON "dbo"."Fee_Master_Terms_FeeHeads"."FMH_Id" = "dbo"."Fee_Student_Status"."FMH_Id" 
            AND "dbo"."Fee_Master_Terms_FeeHeads"."FTI_Id" = "dbo"."Fee_Student_Status"."FTI_Id"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Fee_Student_Status"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
        INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_T_Payment"."FYP_Id" 
            AND "Fee_T_Payment"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        WHERE "dbo"."Fee_Y_Payment"."MI_Id" = ' || QUOTE_LITERAL("p_MI_Id") || ' 
            AND "dbo"."Adm_M_Student"."MI_Id" = ' || QUOTE_LITERAL("p_MI_Id") || ' 
            AND "dbo"."Adm_School_M_Class"."MI_Id" = ' || QUOTE_LITERAL("p_MI_Id") || ' 
            AND "dbo"."Adm_School_M_Section"."MI_Id" = ' || QUOTE_LITERAL("p_MI_Id") || ' 
            AND "dbo"."Fee_Student_Status"."MI_Id" = ' || QUOTE_LITERAL("p_MI_Id") || ' 
            AND "dbo"."Fee_Master_Terms_FeeHeads"."MI_Id" = ' || QUOTE_LITERAL("p_MI_Id") || ' 
            AND "dbo"."Fee_Master_Head"."MI_Id" = ' || QUOTE_LITERAL("p_MI_Id") || ' 
            AND "dbo"."Fee_Student_Status"."ASMAY_Id" = ' || QUOTE_LITERAL("p_ASMAY_Id") || ' 
            AND "dbo"."Adm_School_Y_Student"."ASMAY_Id" = ' || QUOTE_LITERAL("p_ASMAY_Id") || ' 
            AND "dbo"."Fee_Y_Payment_School_Student"."ASMAY_Id" = ' || QUOTE_LITERAL("p_ASMAY_Id") || '
            AND (CAST("dbo"."Fee_Y_Payment"."fyp_date" AS DATE) BETWEEN ' || QUOTE_LITERAL("p_FromDate") || '::DATE AND ' || QUOTE_LITERAL("p_Todate") || '::DATE)
        GROUP BY CAST("FYP_date" AS DATE), "FMH_FeeName"
        ORDER BY 1, 2'',
        ''SELECT DISTINCT "FMH_FeeName" FROM "Fee_Master_Head" WHERE "MI_Id" = ' || QUOTE_LITERAL("p_MI_Id") || ' ORDER BY 1''
    ) AS ct("Date" TEXT, ' || "v_PivotColumnNames" || ' NUMERIC)';

    EXECUTE "v_SqlDynamic";

    RETURN QUERY
    SELECT CAST("B"."Date" AS DATE), "A"."TotalPaidAmount"
    FROM "Fee_StuwiseRecDatewiseTotalAmount_Temp" "A"
    INNER JOIN "Fee_StuwiseRecDatewiseHeadWsieTotalAmount_Temp" "B" ON "A"."Total_Date" = CAST("B"."Date" AS DATE)
    ORDER BY CAST("B"."Date" AS DATE);

    DROP TABLE IF EXISTS "Fee_StuwiseRecDatewiseTotalAmount_Temp";
    DROP TABLE IF EXISTS "Fee_StuwiseRecDatewiseHeadWsieTotalAmount_Temp";

END;
$$;