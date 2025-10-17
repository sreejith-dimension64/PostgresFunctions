CREATE OR REPLACE FUNCTION "dbo"."COE_YearwiseCOEcount"(
    "p_MI_ID" TEXT,
    "p_ASMAY_ID" TEXT
)
RETURNS TABLE(
    "IVRM_Month_Name" VARCHAR,
    result_data JSON
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_cols" TEXT;
    "v_sqldynamic" TEXT;
    "v_PivotColumnNames" TEXT;
    "v_PivotColumnNames1" TEXT;
    "v_monthyearsd" TEXT;
    "v_monthyearsd_select" TEXT;
    "v_rec" RECORD;
    "v_table_exists" BOOLEAN;
BEGIN

    -- Check if temp table exists and drop it
    SELECT EXISTS (
        SELECT FROM pg_tables 
        WHERE schemaname = 'pg_temp' 
        AND tablename LIKE '%admissionaccyearcoe_temp%'
    ) INTO "v_table_exists";

    IF "v_table_exists" THEN
        DROP TABLE IF EXISTS "AdmissionAccYearCOE_Temp";
    END IF;

    -- Create temp table with academic year data
    "v_PivotColumnNames" := 'CREATE TEMP TABLE "AdmissionAccYearCOE_Temp" AS 
        SELECT "ASMAY_Year" 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "ASMAY_ID" IN (' || "p_ASMAY_ID" || ') 
        AND "MI_Id" = ' || "p_MI_ID";
    
    EXECUTE "v_PivotColumnNames";

    -- Build comma-separated list of quoted year names
    SELECT STRING_AGG(DISTINCT '"' || "ASMAY_Year" || '"', ',')
    INTO "v_monthyearsd"
    FROM "AdmissionAccYearCOE_Temp";

    -- Build dynamic SQL for pivot query
    "v_sqldynamic" := '
    SELECT * FROM CROSSTAB(
        ''SELECT 
            IM."IVRM_Month_Name"::TEXT,
            ASMAY."ASMAY_Year"::TEXT,
            COUNT(COALESCE(CE."COEE_Id", 0))::TEXT
        FROM "COE"."COE_Events" CE
        INNER JOIN "Adm_School_M_Academic_Year" ASMAY 
            ON ASMAY."ASMAY_Id" = CE."ASMAY_Id" 
            AND ASMAY."MI_Id" = CE."MI_Id"
        INNER JOIN "IVRM_Month" IM 
            ON IM."IVRM_Month_Id" = EXTRACT(MONTH FROM CE."COEE_EEndDate")
        WHERE CE."ASMAY_Id" IN (' || "p_ASMAY_ID" || ') 
            AND CE."MI_Id" = ' || "p_MI_ID" || '
        GROUP BY IM."IVRM_Month_Name", ASMAY."ASMAY_Year"
        ORDER BY 1, 2'',
        ''SELECT DISTINCT "ASMAY_Year"::TEXT 
          FROM "AdmissionAccYearCOE_Temp" 
          ORDER BY 1''
    ) AS ct("IVRM_Month_Name" VARCHAR';

    -- Add column definitions for each year
    FOR "v_rec" IN 
        SELECT DISTINCT "ASMAY_Year" 
        FROM "AdmissionAccYearCOE_Temp" 
        ORDER BY "ASMAY_Year"
    LOOP
        "v_sqldynamic" := "v_sqldynamic" || ', "' || "v_rec"."ASMAY_Year" || '" TEXT';
    END LOOP;

    "v_sqldynamic" := "v_sqldynamic" || ')';

    -- Return query results
    RETURN QUERY EXECUTE "v_sqldynamic";

END;
$$;