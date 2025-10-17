CREATE OR REPLACE FUNCTION "Adm_Yearwiseadmissioncount"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT,
    p_ASMCL_ID TEXT
)
RETURNS TABLE (
    "ASMAY_Year" VARCHAR,
    dynamic_columns TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cols TEXT;
    v_sqldynamic TEXT;
    v_PivotColumnNames TEXT;
    v_monthyearsd TEXT := '';
    v_monthyearsd_array TEXT[] := ARRAY[]::TEXT[];
    v_record RECORD;
BEGIN

    v_PivotColumnNames := 'SELECT DISTINCT A."ASMCL_Classname" 
                          FROM "Adm_School_M_Class" A 
                          INNER JOIN "Adm_m_student" B ON A."ASMCL_Id" = B."ASMCL_Id" 
                              AND A."MI_Id" = B."MI_Id" 
                          WHERE A."MI_id" = ' || p_MI_ID || ' 
                              AND B."ASMAY_Id" IN (' || p_ASMAY_ID || ') 
                              AND A."ASMCL_Id" IN (' || p_ASMCL_ID || ')';

    FOR v_record IN EXECUTE v_PivotColumnNames
    LOOP
        IF v_monthyearsd <> '' THEN
            v_monthyearsd := v_monthyearsd || ', ';
        END IF;
        v_monthyearsd := v_monthyearsd || '"' || v_record."ASMCL_Classname" || '"';
    END LOOP;

    v_sqldynamic := 'SELECT "ASMAY_Year", ' || v_monthyearsd || ' 
                     FROM crosstab(
                         ''SELECT B."ASMAY_Year", C."ASMCL_ClassName", COALESCE(COUNT(DISTINCT A."AMST_Id"), 0)::INTEGER AS Studentcount
                           FROM "Adm_M_Student" A
                           INNER JOIN "Adm_School_M_Academic_Year" B ON B."ASMAY_Id" = A."ASMAY_Id" AND B."MI_Id" = A."MI_Id"
                           INNER JOIN "Adm_School_M_Class" C ON C."ASMCL_Id" = A."ASMCL_Id" AND C."MI_Id" = A."MI_Id"
                           WHERE A."ASMAY_ID" IN (' || p_ASMAY_ID || ') 
                               AND A."MI_Id" = ' || p_MI_ID || ' 
                               AND C."ASMCL_Id" IN (' || p_ASMCL_ID || ')
                           GROUP BY B."ASMAY_Year", C."ASMCL_ClassName"
                           ORDER BY 1, 2'',
                         ''SELECT DISTINCT A."ASMCL_Classname" 
                           FROM "Adm_School_M_Class" A 
                           INNER JOIN "Adm_m_student" B ON A."ASMCL_Id" = B."ASMCL_Id" AND A."MI_Id" = B."MI_Id"
                           WHERE A."MI_id" = ' || p_MI_ID || ' 
                               AND B."ASMAY_Id" IN (' || p_ASMAY_ID || ') 
                               AND A."ASMCL_Id" IN (' || p_ASMCL_ID || ')
                           ORDER BY 1''
                     ) AS pivot_table("ASMAY_Year" VARCHAR, ' || v_monthyearsd || ' INTEGER)';

    RETURN QUERY EXECUTE v_sqldynamic;

END;
$$;