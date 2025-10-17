CREATE OR REPLACE FUNCTION "dbo"."Exm_StudentSbjectWiseProgress_bkp"(
    "p_MI_Id" varchar(100),
    "p_ASMAY_Id" varchar(100),
    "p_AMST_Id" varchar(100)
)
RETURNS TABLE (
    "EME_ExamName" varchar,
    "pivot_data" text
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sqldynamic" text;
    "v_sqldynamic1" text;
    "v_PivotColumnNames" text;
    "v_PivotSelectColumnNames" text;
BEGIN
    -- Exec Exm_StudentSbjectWiseProgress_bkp 4,10137,150169120
    
    -- Drop temp table if exists
    DROP TABLE IF EXISTS "SubjectNames_Temp";
    
    -- Build and execute dynamic SQL to create temp table
    "v_sqldynamic1" := '
    CREATE TEMP TABLE "SubjectNames_Temp" AS
    SELECT DISTINCT "IMS"."ISMS_SubjectName"
    FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
    LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
        ON "ESS"."ASMAY_Id"="ESMPS"."ASMAY_Id" 
        AND "ESS"."ASMCL_Id"="ESMPS"."ASMCL_Id"
        AND "ESS"."ASMS_Id"="ESMPS"."ASMS_Id" 
        AND "ESS"."AMST_Id"="ESMPS"."AMST_Id" 
        AND "ESS"."ISMS_Id"="ESMPS"."ISMS_Id"
    INNER JOIN "IVRM_Master_Subjects" "IMS" 
        ON "IMS"."ISMS_Id"="ESMPS"."ISMS_Id" 
        AND "IMS"."MI_Id"="ESMPS"."MI_Id"
    INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
        ON "EME"."EME_Id"="ESMPS"."EME_Id" 
        AND "IMS"."MI_Id"="EME"."MI_Id"
    WHERE "ESS"."MI_Id"=' || "p_MI_Id" || ' 
        AND "ESMPS"."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') 
        AND "ESMPS"."AMST_Id"=' || "p_AMST_Id";
    
    EXECUTE "v_sqldynamic1";
    
    -- Get distinct values of the PIVOT Column
    SELECT string_agg('"' || "ISMS_SubjectName" || '"', ',')
    INTO "v_PivotColumnNames"
    FROM (SELECT DISTINCT "ISMS_SubjectName" FROM "SubjectNames_Temp") AS "PVColumns";
    
    -- Get distinct values of the PIVOT Column with COALESCE
    SELECT string_agg('COALESCE("' || "ISMS_SubjectName" || '", 0) AS "' || "ISMS_SubjectName" || '"', ',')
    INTO "v_PivotSelectColumnNames"
    FROM (SELECT DISTINCT "ISMS_SubjectName" FROM "SubjectNames_Temp") AS "PVSelctedColumns";
    
    -- Build and execute dynamic PIVOT query
    "v_sqldynamic" := '
    SELECT "EME_ExamName", ' || "v_PivotColumnNames" || '
    FROM crosstab(
        ''SELECT "EME_ExamName", "ISMS_SubjectName", SUM("ESTMPS_ObtainedMarks")
        FROM (
            SELECT "IMS"."ISMS_SubjectName", "EME"."EME_ExamName", "ESMPS"."ESTMPS_ObtainedMarks", "ESMPS"."EME_Id", "ISMS_OrderFlag"
            FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
            LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
                ON "ESS"."ASMAY_Id"="ESMPS"."ASMAY_Id" 
                AND "ESS"."ASMCL_Id"="ESMPS"."ASMCL_Id"
                AND "ESS"."ASMS_Id"="ESMPS"."ASMS_Id" 
                AND "ESS"."AMST_Id"="ESMPS"."AMST_Id" 
                AND "ESS"."ISMS_Id"="ESMPS"."ISMS_Id"
            INNER JOIN "IVRM_Master_Subjects" "IMS" 
                ON "IMS"."ISMS_Id"="ESMPS"."ISMS_Id" 
                AND "IMS"."MI_Id"="ESMPS"."MI_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
                ON "EME"."EME_Id"="ESMPS"."EME_Id" 
                AND "IMS"."MI_Id"="EME"."MI_Id"
            WHERE "ESS"."MI_Id"=' || "p_MI_Id" || ' 
                AND "ESMPS"."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') 
                AND "ESMPS"."AMST_Id"=' || "p_AMST_Id" || '
            ORDER BY "ESMPS"."EME_Id", "ISMS_OrderFlag"
            LIMIT 100
        ) AS "New"
        GROUP BY "EME_ExamName", "ISMS_SubjectName"
        ORDER BY 1, 2'',
        ''SELECT DISTINCT "ISMS_SubjectName" FROM "SubjectNames_Temp" ORDER BY 1''
    ) AS "ct"("EME_ExamName" varchar, ' || "v_PivotColumnNames" || ' numeric)';
    
    RETURN QUERY EXECUTE "v_sqldynamic";
    
    -- Clean up temp table
    DROP TABLE IF EXISTS "SubjectNames_Temp";
    
END;
$$;