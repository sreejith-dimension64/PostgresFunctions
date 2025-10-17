CREATE OR REPLACE FUNCTION "dbo"."Castewise_Strength_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT
)
RETURNS TABLE(
    "ASMCL_ClassName" VARCHAR,
    caste_data JSON
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_DYNAMIC TEXT;
    v_DYNAMIC1 TEXT;
    v_PivotColumnNames TEXT := '';
    v_PivotSelectColumnNames TEXT := '';
    v_rec RECORD;
BEGIN
    -- Drop temp table if exists
    DROP TABLE IF EXISTS "Castewise_temp";
    
    -- Create dynamic query to populate temp table
    v_DYNAMIC := '
    CREATE TEMP TABLE "Castewise_temp" AS
    SELECT DISTINCT E."IMC_CasteName"
    FROM "Adm_M_Student" A
    INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
    INNER JOIN "Adm_School_M_Class" C ON C."ASMCL_Id" = B."ASMCL_Id"
    INNER JOIN "IVRM_Master_Caste_Category" D ON D."IMCC_Id" = A."IMCC_Id"
    INNER JOIN "IVRM_Master_Caste" E ON E."IMC_Id" = A."IC_Id"
    WHERE A."MI_Id" = ' || p_MI_Id || ' 
    AND B."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
    AND B."ASMAY_Id" = ' || p_ASMAY_Id || ' 
    AND A."AMST_SOL" = ''S'' 
    AND A."AMST_ActiveFlag" = 1 
    AND B."AMAY_ActiveFlag" = 1';
    
    EXECUTE v_DYNAMIC;
    
    -- Build pivot column names with quotes
    SELECT STRING_AGG('''' || "IMC_CasteName" || '''', ',')
    INTO v_PivotColumnNames
    FROM "Castewise_temp";
    
    -- Build select column names for aggregation
    SELECT STRING_AGG('SUM(CASE WHEN "IMC_CasteName" = ''' || "IMC_CasteName" || ''' THEN 1 ELSE 0 END) AS "' || "IMC_CasteName" || '"', ', ')
    INTO v_PivotSelectColumnNames
    FROM "Castewise_temp";
    
    -- Build and execute dynamic pivot query
    v_DYNAMIC1 := '
    SELECT "ASMCL_ClassName", ' || v_PivotSelectColumnNames || '
    FROM (
        SELECT DISTINCT E."IMC_Id", E."IMC_CasteName", C."ASMCL_ClassName", A."AMST_Id" 
        FROM "Adm_M_Student" A
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Class" C ON C."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "IVRM_Master_Caste_Category" D ON D."IMCC_Id" = A."IMCC_Id"
        INNER JOIN "IVRM_Master_Caste" E ON E."IMC_Id" = A."IC_Id"
        WHERE A."MI_Id" = ' || p_MI_Id || ' 
        AND B."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
        AND B."ASMAY_Id" = ' || p_ASMAY_Id || ' 
        AND A."AMST_SOL" = ''S'' 
        AND A."AMST_ActiveFlag" = 1 
        AND B."AMAY_ActiveFlag" = 1
    ) AS "New"
    GROUP BY "ASMCL_ClassName"';
    
    RETURN QUERY EXECUTE v_DYNAMIC1;
    
    -- Clean up temp table
    DROP TABLE IF EXISTS "Castewise_temp";
    
END;
$$;