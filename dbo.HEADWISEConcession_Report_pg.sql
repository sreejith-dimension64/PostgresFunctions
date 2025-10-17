CREATE OR REPLACE FUNCTION "dbo"."HEADWISEConcession_Report"(
    p_MI_Id VARCHAR(100),
    p_ASMAY_Id VARCHAR,
    p_FMCC_Id VARCHAR
)
RETURNS TABLE (
    "HEADS/CATEGORIES" VARCHAR,
    result_data JSON
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_PivotColumnNames TEXT := '';
    v_PivotSelectColumnNames TEXT := '';
    v_sqlquery TEXT;
    v_FeeName RECORD;
BEGIN
    -- Build pivot column names
    FOR v_FeeName IN 
        SELECT DISTINCT "FMH_FeeName" AS FeeName 
        FROM "Fee_Master_Head" 
        WHERE "MI_Id" = p_MI_Id::INTEGER
    LOOP
        IF v_PivotColumnNames != '' THEN
            v_PivotColumnNames := v_PivotColumnNames || ',';
            v_PivotSelectColumnNames := v_PivotSelectColumnNames || ',';
        END IF;
        v_PivotColumnNames := v_PivotColumnNames || '"' || v_FeeName.FeeName || '"';
        v_PivotSelectColumnNames := v_PivotSelectColumnNames || 
            'COALESCE("' || v_FeeName.FeeName || '", 0) AS "' || v_FeeName.FeeName || '"';
    END LOOP;

    -- Build and execute dynamic query
    v_sqlquery := '
    SELECT "HEADS/CATEGORIES",' || v_PivotSelectColumnNames || ' FROM (
        SELECT DISTINCT "FMC"."FMCC_ConcessionName" AS "HEADS/CATEGORIES",
               "FMH"."FMH_FeeName" AS "FeeName",
               SUM("FSS"."FSS_ConcessionAmount") AS "FSSConcessionAmt"
        FROM "Fee_Master_Concession" "FMC"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Concession_Type" = "FMC"."FMCC_Id" 
            AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id" 
            AND "ASYS"."ASMAY_Id" IN (' || p_ASMAY_Id || ') AND "ASYS"."AMAY_ActiveFlag" = 1
        INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."AMST_Id" = "ASYS"."AMST_Id" 
            AND "FSS"."ASMAY_Id" = "ASYS"."ASMAY_Id"
        INNER JOIN "Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FSS"."FMG_Id" 
            AND "FMG"."MI_Id" IN (' || p_MI_Id || ')
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id" 
            AND "FMH"."MI_Id" IN (' || p_MI_Id || ')
        WHERE "FMC"."MI_Id" IN (' || p_MI_Id || ') 
            AND "FMC"."FMCC_ActiveFlag" = 1 
            AND "FMH_ActiveFlag" = 1 
            AND "FSS"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
            AND "FSS"."MI_Id" IN (' || p_MI_Id || ') 
            AND "FMC"."FMCC_Id" IN (' || p_FMCC_Id || ')
        GROUP BY "FMC"."FMCC_ConcessionName", "FMH"."FMH_FeeName"
    ) AS "source_data"
    PIVOT (
        SUM("FSSConcessionAmt")
        FOR "FeeName" IN (' || v_PivotColumnNames || ')
    )';

    -- Since PostgreSQL doesn't have PIVOT, use crosstab or dynamic query with CASE statements
    v_sqlquery := '
    SELECT * FROM crosstab(
        ''SELECT DISTINCT "FMC"."FMCC_ConcessionName" AS category,
                 "FMH"."FMH_FeeName" AS feename,
                 SUM("FSS"."FSS_ConcessionAmount") AS amount
          FROM "Fee_Master_Concession" "FMC"
          INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Concession_Type" = "FMC"."FMCC_Id" 
              AND "AMST_SOL" = ''''S'''' AND "AMST_ActiveFlag" = 1
          INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id" 
              AND "ASYS"."ASMAY_Id" IN (' || p_ASMAY_Id || ') AND "ASYS"."AMAY_ActiveFlag" = 1
          INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."AMST_Id" = "ASYS"."AMST_Id" 
              AND "FSS"."ASMAY_Id" = "ASYS"."ASMAY_Id"
          INNER JOIN "Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FSS"."FMG_Id" 
              AND "FMG"."MI_Id" IN (' || p_MI_Id || ')
          INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id" 
              AND "FMH"."MI_Id" IN (' || p_MI_Id || ')
          WHERE "FMC"."MI_Id" IN (' || p_MI_Id || ') 
              AND "FMC"."FMCC_ActiveFlag" = 1 
              AND "FMH_ActiveFlag" = 1 
              AND "FSS"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
              AND "FSS"."MI_Id" IN (' || p_MI_Id || ') 
              AND "FMC"."FMCC_Id" IN (' || p_FMCC_Id || ')
          GROUP BY "FMC"."FMCC_ConcessionName", "FMH"."FMH_FeeName"
          ORDER BY 1, 2''
    ) AS ct("HEADS/CATEGORIES" VARCHAR, ' || v_PivotColumnNames || ' NUMERIC)';

    RETURN QUERY EXECUTE v_sqlquery;
    
END;
$$;