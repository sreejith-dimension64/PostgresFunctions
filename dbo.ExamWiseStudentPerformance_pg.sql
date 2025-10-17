CREATE OR REPLACE FUNCTION "dbo"."ExamWiseStudentPerformance"(
    "p_MI_Id" VARCHAR(100),
    "p_ASMAY_Id" VARCHAR(100),
    "p_AMST_Id" VARCHAR(100),
    "p_EME_Id" VARCHAR(100)
)
RETURNS TABLE(
    "EME_ExamName" VARCHAR,
    "Details" VARCHAR,
    "subjects" JSON
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sqldynamic" TEXT;
    "v_sqldynamic1" TEXT;
    "v_sqldynamic2" TEXT;
    "v_sqldynamic3" TEXT;
    "v_sqldynamic4" TEXT;
    "v_PivotColumnNames" TEXT;
    "v_PivotSelectColumnNames" TEXT;
BEGIN
    -- Drop temporary tables if they exist
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp1";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp2";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp3";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp4";
    
    -- Build pivot column names
    SELECT STRING_AGG('"' || "ISMS_SubjectName" || '"', ',') INTO "v_PivotColumnNames"
    FROM (
        SELECT DISTINCT "IMS"."ISMS_SubjectName"
        FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
        LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
            ON "ESS"."ASMAY_Id" = "ESMPS"."ASMAY_Id" 
            AND "ESS"."ASMCL_Id" = "ESMPS"."ASMCL_Id"
            AND "ESS"."ASMS_Id" = "ESMPS"."ASMS_Id" 
            AND "ESS"."AMST_Id" = "ESMPS"."AMST_Id" 
            AND "ESS"."ISMS_Id" = "ESMPS"."ISMS_Id"
        INNER JOIN "IVRM_Master_Subjects" "IMS" 
            ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id" 
            AND "IMS"."MI_Id" = "ESMPS"."MI_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
            ON "EME"."EME_Id" = "ESMPS"."EME_Id" 
            AND "IMS"."MI_Id" = "EME"."MI_Id"
        WHERE "ESS"."MI_Id" = "p_MI_Id" 
            AND "ESMPS"."ASMAY_Id" = "p_ASMAY_Id" 
            AND "ESMPS"."AMST_Id" = "p_AMST_Id" 
            AND "EME"."EME_Id" = "p_EME_Id"
    ) AS "PVColumns";
    
    -- Build pivot select column names
    SELECT STRING_AGG('SUM(COALESCE("' || "ISMS_SubjectName" || '", 0)) AS "' || "ISMS_SubjectName" || '"', ',') 
    INTO "v_PivotSelectColumnNames"
    FROM (
        SELECT DISTINCT "IMS"."ISMS_SubjectName"
        FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
        LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
            ON "ESS"."ASMAY_Id" = "ESMPS"."ASMAY_Id" 
            AND "ESS"."ASMCL_Id" = "ESMPS"."ASMCL_Id"
            AND "ESS"."ASMS_Id" = "ESMPS"."ASMS_Id" 
            AND "ESS"."AMST_Id" = "ESMPS"."AMST_Id" 
            AND "ESS"."ISMS_Id" = "ESMPS"."ISMS_Id"
        INNER JOIN "IVRM_Master_Subjects" "IMS" 
            ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id" 
            AND "IMS"."MI_Id" = "ESMPS"."MI_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
            ON "EME"."EME_Id" = "ESMPS"."EME_Id" 
            AND "IMS"."MI_Id" = "EME"."MI_Id"
        WHERE "ESS"."MI_Id" = "p_MI_Id" 
            AND "ESMPS"."ASMAY_Id" = "p_ASMAY_Id" 
            AND "ESMPS"."AMST_Id" = "p_AMST_Id" 
            AND "EME"."EME_Id" = "p_EME_Id"
    ) AS "PVSelctedColumns";
    
    -- Build dynamic SQL for Student marks
    "v_sqldynamic" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp" AS 
        SELECT "EME_ExamName", ''Student'' AS "Details", ' || "v_PivotSelectColumnNames" || ' 
        FROM (
            SELECT DISTINCT "EME"."EME_ExamName", "IMS"."ISMS_SubjectName", "ESMPS"."ESTMPS_ObtainedMarks"
            FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
            LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
                ON "ESS"."ASMAY_Id" = "ESMPS"."ASMAY_Id" 
                AND "ESS"."ASMCL_Id" = "ESMPS"."ASMCL_Id"
                AND "ESS"."ASMS_Id" = "ESMPS"."ASMS_Id" 
                AND "ESS"."AMST_Id" = "ESMPS"."AMST_Id" 
                AND "ESS"."ISMS_Id" = "ESMPS"."ISMS_Id"
            INNER JOIN "IVRM_Master_Subjects" "IMS" 
                ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id" 
                AND "IMS"."MI_Id" = "ESMPS"."MI_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
                ON "EME"."EME_Id" = "ESMPS"."EME_Id" 
                AND "IMS"."MI_Id" = "EME"."MI_Id"
            WHERE "ESS"."MI_Id" = ' || "p_MI_Id" || ' 
                AND "ESMPS"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
                AND "ESMPS"."AMST_Id" = ' || "p_AMST_Id" || ' 
                AND "EME"."EME_Id" = ' || "p_EME_Id" || '
        ) AS "New"
        PIVOT (SUM("ESTMPS_ObtainedMarks") FOR "ISMS_SubjectName" IN (' || "v_PivotColumnNames" || ')) AS "Pvt"
        GROUP BY "EME_ExamName"';
    
    -- Build dynamic SQL for ClassHighest
    "v_sqldynamic1" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp1" AS 
        SELECT "EME_ExamName", ''ClassHighest'' AS "Details", ' || "v_PivotSelectColumnNames" || ' 
        FROM (
            SELECT DISTINCT "EME"."EME_ExamName", "IMS"."ISMS_SubjectName", "ESMPS"."ESTMPS_ClassHighest"
            FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
            LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
                ON "ESS"."ASMAY_Id" = "ESMPS"."ASMAY_Id" 
                AND "ESS"."ASMCL_Id" = "ESMPS"."ASMCL_Id"
                AND "ESS"."ASMS_Id" = "ESMPS"."ASMS_Id" 
                AND "ESS"."AMST_Id" = "ESMPS"."AMST_Id" 
                AND "ESS"."ISMS_Id" = "ESMPS"."ISMS_Id"
            INNER JOIN "IVRM_Master_Subjects" "IMS" 
                ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id" 
                AND "IMS"."MI_Id" = "ESMPS"."MI_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
                ON "EME"."EME_Id" = "ESMPS"."EME_Id" 
                AND "IMS"."MI_Id" = "EME"."MI_Id"
            WHERE "ESS"."MI_Id" = ' || "p_MI_Id" || ' 
                AND "ESMPS"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
                AND "ESMPS"."AMST_Id" = ' || "p_AMST_Id" || ' 
                AND "EME"."EME_Id" = ' || "p_EME_Id" || '
        ) AS "New"
        PIVOT (SUM("ESTMPS_ClassHighest") FOR "ISMS_SubjectName" IN (' || "v_PivotColumnNames" || ')) AS "Pvt1"
        GROUP BY "EME_ExamName"';
    
    -- Build dynamic SQL for SectionHighest
    "v_sqldynamic2" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp2" AS 
        SELECT "EME_ExamName", ''SectionHighest'' AS "Details", ' || "v_PivotSelectColumnNames" || ' 
        FROM (
            SELECT DISTINCT "EME"."EME_ExamName", "IMS"."ISMS_SubjectName", "ESMPS"."ESTMPS_SectionHighest"
            FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
            LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
                ON "ESS"."ASMAY_Id" = "ESMPS"."ASMAY_Id" 
                AND "ESS"."ASMCL_Id" = "ESMPS"."ASMCL_Id"
                AND "ESS"."ASMS_Id" = "ESMPS"."ASMS_Id" 
                AND "ESS"."AMST_Id" = "ESMPS"."AMST_Id" 
                AND "ESS"."ISMS_Id" = "ESMPS"."ISMS_Id"
            INNER JOIN "IVRM_Master_Subjects" "IMS" 
                ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id" 
                AND "IMS"."MI_Id" = "ESMPS"."MI_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
                ON "EME"."EME_Id" = "ESMPS"."EME_Id" 
                AND "IMS"."MI_Id" = "EME"."MI_Id"
            WHERE "ESS"."MI_Id" = ' || "p_MI_Id" || ' 
                AND "ESMPS"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
                AND "ESMPS"."AMST_Id" = ' || "p_AMST_Id" || ' 
                AND "EME"."EME_Id" = ' || "p_EME_Id" || '
        ) AS "New"
        PIVOT (SUM("ESTMPS_SectionHighest") FOR "ISMS_SubjectName" IN (' || "v_PivotColumnNames" || ')) AS "Pvt2"
        GROUP BY "EME_ExamName"';
    
    -- Build dynamic SQL for ClassAverage
    "v_sqldynamic3" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp3" AS 
        SELECT "EME_ExamName", ''ClassAverage'' AS "Details", ' || "v_PivotSelectColumnNames" || ' 
        FROM (
            SELECT DISTINCT "EME"."EME_ExamName", "IMS"."ISMS_SubjectName", "ESMPS"."ESTMPS_ClassAverage"
            FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
            LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
                ON "ESS"."ASMAY_Id" = "ESMPS"."ASMAY_Id" 
                AND "ESS"."ASMCL_Id" = "ESMPS"."ASMCL_Id"
                AND "ESS"."ASMS_Id" = "ESMPS"."ASMS_Id" 
                AND "ESS"."AMST_Id" = "ESMPS"."AMST_Id" 
                AND "ESS"."ISMS_Id" = "ESMPS"."ISMS_Id"
            INNER JOIN "IVRM_Master_Subjects" "IMS" 
                ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id" 
                AND "IMS"."MI_Id" = "ESMPS"."MI_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
                ON "EME"."EME_Id" = "ESMPS"."EME_Id" 
                AND "IMS"."MI_Id" = "EME"."MI_Id"
            WHERE "ESS"."MI_Id" = ' || "p_MI_Id" || ' 
                AND "ESMPS"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
                AND "ESMPS"."AMST_Id" = ' || "p_AMST_Id" || ' 
                AND "EME"."EME_Id" = ' || "p_EME_Id" || '
        ) AS "New"
        PIVOT (SUM("ESTMPS_ClassAverage") FOR "ISMS_SubjectName" IN (' || "v_PivotColumnNames" || ')) AS "Pvt3"
        GROUP BY "EME_ExamName"';
    
    -- Build dynamic SQL for SectionAverage
    "v_sqldynamic4" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp4" AS 
        SELECT "EME_ExamName", ''SectionAverage'' AS "Details", ' || "v_PivotSelectColumnNames" || ' 
        FROM (
            SELECT DISTINCT "EME"."EME_ExamName", "IMS"."ISMS_SubjectName", "ESMPS"."ESTMPS_SectionAverage"
            FROM "Exm"."Exm_Studentwise_Subjects" "ESS"
            LEFT JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
                ON "ESS"."ASMAY_Id" = "ESMPS"."ASMAY_Id" 
                AND "ESS"."ASMCL_Id" = "ESMPS"."ASMCL_Id"
                AND "ESS"."ASMS_Id" = "ESMPS"."ASMS_Id" 
                AND "ESS"."AMST_Id" = "ESMPS"."AMST_Id" 
                AND "ESS"."ISMS_Id" = "ESMPS"."ISMS_Id"
            INNER JOIN "IVRM_Master_Subjects" "IMS" 
                ON "IMS"."ISMS_Id" = "ESMPS"."ISMS_Id" 
                AND "IMS"."MI_Id" = "ESMPS"."MI_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" "EME" 
                ON "EME"."EME_Id" = "ESMPS"."EME_Id" 
                AND "IMS"."MI_Id" = "EME"."MI_Id"
            WHERE "ESS"."MI_Id" = ' || "p_MI_Id" || ' 
                AND "ESMPS"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
                AND "ESMPS"."AMST_Id" = ' || "p_AMST_Id" || ' 
                AND "EME"."EME_Id" = ' || "p_EME_Id" || '
        ) AS "New"
        PIVOT (SUM("ESTMPS_SectionAverage") FOR "ISMS_SubjectName" IN (' || "v_PivotColumnNames" || ')) AS "Pvt4"
        GROUP BY "EME_ExamName"';
    
    -- Execute dynamic SQL statements
    EXECUTE "v_sqldynamic";
    EXECUTE "v_sqldynamic1";
    EXECUTE "v_sqldynamic2";
    EXECUTE "v_sqldynamic3";
    EXECUTE "v_sqldynamic4";
    
    -- Return combined results
    RETURN QUERY
    SELECT * FROM "ExamStudentMarks_Temp"
    UNION ALL
    SELECT * FROM "ExamStudentMarks_Temp1"
    UNION ALL
    SELECT * FROM "ExamStudentMarks_Temp2"
    UNION ALL
    SELECT * FROM "ExamStudentMarks_Temp3"
    UNION ALL
    SELECT * FROM "ExamStudentMarks_Temp4";
    
END;
$$;