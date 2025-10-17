CREATE OR REPLACE FUNCTION "dbo"."Adm_Yearwisebirthdaycount"(
    "MI_ID" TEXT,
    "ASMAY_ID" TEXT
)
RETURNS TABLE(
    "Month_Name" TEXT,
    year_columns JSONB
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cols TEXT;
    v_sqldynamic TEXT;
    v_PivotColumnNames TEXT;
    v_PivotColumnNames1 TEXT;
    v_monthyearsd TEXT;
    v_monthyearsd_select TEXT;
BEGIN

    DROP TABLE IF EXISTS "AdmissionAccYear_Temp";

    v_PivotColumnNames := 'CREATE TEMP TABLE "AdmissionAccYear_Temp" AS 
                           SELECT "ASMAY_Year" 
                           FROM "Adm_School_M_Academic_Year" 
                           WHERE "ASMAY_ID" IN (' || "ASMAY_ID" || ') 
                           AND "MI_Id" = ' || "MI_ID";

    EXECUTE v_PivotColumnNames;

    SELECT string_agg(DISTINCT '"' || "ASMAY_Year" || '"', ',')
    INTO v_monthyearsd
    FROM "AdmissionAccYear_Temp";

    v_sqldynamic := 'SELECT "Month_Name"';
    
    FOR v_cols IN 
        SELECT DISTINCT "ASMAY_Year" 
        FROM "AdmissionAccYear_Temp" 
        ORDER BY "ASMAY_Year"
    LOOP
        v_sqldynamic := v_sqldynamic || ', COALESCE("' || v_cols || '", 0) AS "' || v_cols || '"';
    END LOOP;

    v_sqldynamic := v_sqldynamic || ' FROM crosstab(
        ''SELECT DISTINCT 
            TO_CHAR(AMST_DOb, ''''Month'''') AS Month_Name,
            ASMAY.ASMAY_Year AS Year_Name,
            COUNT(DISTINCT ASYS.AMST_Id)::INTEGER AS StudentCount
        FROM "Adm_M_Student" AMS
        INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ASMAY ON ASMAY."ASMAY_Id" = ASYS."ASMAY_Id" 
            AND ASMAY."MI_Id" = AMS."MI_Id"
        WHERE AMS."MI_Id" = ' || "MI_ID" || ' 
            AND ASYS."ASMAY_Id" IN (' || "ASMAY_ID" || ')
        GROUP BY TO_CHAR(AMST_DOb, ''''Month''''), ASMAY."ASMAY_Year"
        ORDER BY 1, 2'',
        ''SELECT DISTINCT "ASMAY_Year" FROM "AdmissionAccYear_Temp" ORDER BY 1''
    ) AS ct("Month_Name" TEXT';

    FOR v_cols IN 
        SELECT DISTINCT "ASMAY_Year" 
        FROM "AdmissionAccYear_Temp" 
        ORDER BY "ASMAY_Year"
    LOOP
        v_sqldynamic := v_sqldynamic || ', "' || v_cols || '" INTEGER';
    END LOOP;

    v_sqldynamic := v_sqldynamic || ')
    ORDER BY 
        CASE "Month_Name"
            WHEN ''January'' THEN 1
            WHEN ''February'' THEN 2
            WHEN ''March'' THEN 3
            WHEN ''April'' THEN 4
            WHEN ''May'' THEN 5
            WHEN ''June'' THEN 6
            WHEN ''July'' THEN 7
            WHEN ''August'' THEN 8
            WHEN ''September'' THEN 9
            WHEN ''October'' THEN 10
            WHEN ''November'' THEN 11
            WHEN ''December'' THEN 12
        END
    LIMIT 100';

    RETURN QUERY EXECUTE v_sqldynamic;

    DROP TABLE IF EXISTS "AdmissionAccYear_Temp";

END;
$$;