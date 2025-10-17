CREATE OR REPLACE FUNCTION "dbo"."Adm_Sourcewiseadmissioncount"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    pivot_data JSONB
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
    v_PivotColumnNames TEXT := '';
    v_PivotColumnList TEXT := '';
    v_CaseStatements TEXT := '';
    v_rec RECORD;
BEGIN
    
    -- Build pivot column names
    SELECT STRING_AGG(DISTINCT '"' || "PAMR_ReferenceName" || '"', ',')
    INTO v_PivotColumnNames
    FROM (
        SELECT DISTINCT "PMR"."PAMR_ReferenceName"
        FROM "Preadmission_Master_Reference" "PMR"
        INNER JOIN "Adm_M_Student_Reference" "AMSR" ON "AMSR"."PAMR_Id" = "PMR"."PAMR_Id"
        WHERE "AMSR"."MI_Id" = p_MI_ID::BIGINT
    ) AS Pvcolumns;
    
    -- Build CASE statements for pivot
    FOR v_rec IN (
        SELECT DISTINCT "PMR"."PAMR_ReferenceName"
        FROM "Preadmission_Master_Reference" "PMR"
        INNER JOIN "Adm_M_Student_Reference" "AMSR" ON "AMSR"."PAMR_Id" = "PMR"."PAMR_Id"
        WHERE "AMSR"."MI_Id" = p_MI_ID::BIGINT
    )
    LOOP
        v_CaseStatements := v_CaseStatements || 
            'SUM(CASE WHEN "PAMR_ReferenceName" = ' || QUOTE_LITERAL(v_rec."PAMR_ReferenceName") || 
            ' THEN "Studentcount" ELSE 0 END) AS "' || v_rec."PAMR_ReferenceName" || '",';
    END LOOP;
    
    -- Remove trailing comma
    v_CaseStatements := RTRIM(v_CaseStatements, ',');
    
    -- Build dynamic SQL with proper pivot using CASE statements
    v_sqldynamic := '
    SELECT "ASMAY_Year"::VARCHAR, "ASMCL_ClassName"::VARCHAR, ' || v_CaseStatements || '
    FROM (
        SELECT DISTINCT "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", 
               COALESCE(COUNT(DISTINCT "ASYS"."AMST_Id"), 0) AS "Studentcount", 
               "PMR"."PAMR_ReferenceName"
        FROM "dbo"."Adm_M_Student" "AMS"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id" 
            AND "ASMAY"."MI_Id" = "AMS"."MI_Id"
        INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
            AND "ASMC"."MI_Id" = "AMS"."MI_Id"
        INNER JOIN "Adm_M_Student_Reference" "AMSR" ON "AMSR"."AMST_Id" = "ASYS"."AMST_Id" 
            AND "AMSR"."MI_Id" = "ASMAY"."MI_Id"
        INNER JOIN "Preadmission_Master_Reference" "PMR" ON "PMR"."PAMR_Id" = "AMSR"."PAMR_Id"
        WHERE "ASYS"."ASMAY_ID" IN (' || p_ASMAY_ID || ') 
            AND "AMS"."MI_Id" = ' || p_MI_ID || '
        GROUP BY "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", "PMR"."PAMR_ReferenceName"
    ) AS AdmSource
    GROUP BY "ASMAY_Year", "ASMCL_ClassName"
    ORDER BY "ASMAY_Year", "ASMCL_ClassName"';
    
    RETURN QUERY EXECUTE v_sqldynamic;
    
END;
$$;