CREATE OR REPLACE FUNCTION "dbo"."Adm_Categorywiseadmissioncount"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT,
    p_ASMCL_ID TEXT,
    p_IMCC_ID TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    category_data JSONB
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cols TEXT;
    v_sqldynamic TEXT;
    v_PivotColumnNames TEXT := '';
    v_PivotColumnNames_agg TEXT := '';
BEGIN

    -- Build pivot column names
    SELECT STRING_AGG('"' || "IMCC_CategoryName" || '"', ',' ORDER BY "IMCC_CategoryName")
    INTO v_PivotColumnNames
    FROM (
        SELECT DISTINCT "IMCC"."IMCC_CategoryName" 
        FROM "IVRM_Master_Caste_Category" "IMCC" 
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."IMCC_Id" = "IMCC"."IMCC_Id"
        WHERE "AMS"."MI_ID" = p_MI_ID::BIGINT
    ) AS Pvcolumns;

    -- Build aggregation expressions for crosstab
    SELECT STRING_AGG(
        'SUM(CASE WHEN "IMCC_CategoryName" = ' || QUOTE_LITERAL("IMCC_CategoryName") || 
        ' THEN "Studentcount" ELSE 0 END) AS "' || "IMCC_CategoryName" || '"', 
        ', ' ORDER BY "IMCC_CategoryName"
    )
    INTO v_PivotColumnNames_agg
    FROM (
        SELECT DISTINCT "IMCC"."IMCC_CategoryName"
        FROM "IVRM_Master_Caste_Category" "IMCC"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."IMCC_Id" = "IMCC"."IMCC_Id"
        WHERE "AMS"."MI_ID" = p_MI_ID::BIGINT
    ) AS Pvcolumns;

    -- Build dynamic SQL
    v_sqldynamic := 'SELECT "ASMAY_Year", "ASMCL_ClassName", ' || v_PivotColumnNames_agg || 
    ' FROM (
        SELECT "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", 
               COUNT(DISTINCT "ASYS"."AMST_Id") AS "Studentcount", 
               "IMCC"."IMCC_CategoryName"
        FROM "dbo"."Adm_M_Student" "AMS"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id" 
            AND "ASMAY"."MI_Id" = "AMS"."MI_Id"
        INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
            AND "ASMC"."MI_Id" = "ASMAY"."MI_Id"
        INNER JOIN "IVRM_Master_Caste_Category" "IMCC" ON "IMCC"."IMCC_ID" = "AMS"."IMCC_Id"
        WHERE "ASYS"."ASMAY_ID"::TEXT IN (' || p_ASMAY_ID || ') 
            AND "AMS"."MI_Id" = ' || p_MI_ID || '
            AND "ASYS"."ASMCL_Id"::TEXT IN (' || p_ASMCL_ID || ')
            AND "IMCC"."IMCC_Id"::TEXT IN (' || p_IMCC_ID || ')
        GROUP BY "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", "IMCC"."IMCC_CategoryName"
    ) AS AdmCat
    GROUP BY "ASMAY_Year", "ASMCL_ClassName"
    ORDER BY "ASMAY_Year", "ASMCL_ClassName"';

    -- Execute dynamic SQL and return results
    RETURN QUERY EXECUTE v_sqldynamic;

END;
$$;