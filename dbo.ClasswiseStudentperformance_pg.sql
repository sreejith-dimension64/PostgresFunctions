CREATE OR REPLACE FUNCTION "dbo"."ClasswiseStudentperformance"(
    "p_MI_Id" VARCHAR(100),
    "p_ASMAY_Id" VARCHAR(100),
    "p_ASMCL_Id" VARCHAR(100),
    "p_ASMS_Id" VARCHAR(100),
    "p_ISMS_Id" TEXT
)
RETURNS TABLE(
    "Class" TEXT,
    "Details" TEXT
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

    DROP TABLE IF EXISTS "ExamStudentMarks_Temp";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp1";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp2";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp3";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp4";

    SELECT STRING_AGG('"' || "Strength" || '"', ',' ORDER BY "Strength") INTO "v_PivotColumnNames"
    FROM (
        SELECT DISTINCT "F"."ISMS_SubjectName" AS "Strength"
        FROM "Exm"."Exm_Student_Marks_Process" "A"
        INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_Id" = "A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_Id" = "A"."ASMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "D" ON "D"."EME_Id" = "A"."EME_Id" AND "A"."MI_Id" = "D"."MI_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "E" ON "A"."MI_Id" = "E"."MI_Id" 
            AND "E"."ASMAY_Id" = "A"."ASMAY_Id"
            AND "B"."ASMCL_Id" = "E"."ASMCL_Id" AND "C"."ASMS_Id" = "E"."ASMS_Id" AND "A"."MI_Id" = "E"."MI_Id"
        INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_Id" = "E"."ISMS_Id" AND "F"."MI_Id" = "E"."MI_Id"
        WHERE "E"."MI_Id" = "p_MI_Id"::INTEGER AND "E"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
            AND "E"."ASMCL_Id" = "p_ASMCL_Id"::INTEGER AND "E"."ASMS_Id" = "p_ASMS_Id"::INTEGER 
            AND "E"."ISMS_Id" = "p_ISMS_Id"::INTEGER
    ) AS "PVColumns";

    SELECT STRING_AGG('SUM(COALESCE("' || "Strength" || '", 0)) AS "' || "Strength" || '"', ',' ORDER BY "Strength") 
    INTO "v_PivotSelectColumnNames"
    FROM (
        SELECT DISTINCT "F"."ISMS_SubjectName" AS "Strength"
        FROM "Exm"."Exm_Student_Marks_Process" "A"
        INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_Id" = "A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_Id" = "A"."ASMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "D" ON "D"."EME_Id" = "A"."EME_Id" AND "A"."MI_Id" = "D"."MI_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "E" ON "A"."MI_Id" = "E"."MI_Id" 
            AND "E"."ASMAY_Id" = "A"."ASMAY_Id"
            AND "B"."ASMCL_Id" = "E"."ASMCL_Id" AND "C"."ASMS_Id" = "E"."ASMS_Id" AND "A"."MI_Id" = "E"."MI_Id"
        INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_Id" = "E"."ISMS_Id" AND "F"."MI_Id" = "E"."MI_Id"
        WHERE "E"."MI_Id" = "p_MI_Id"::INTEGER AND "E"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER 
            AND "E"."ASMCL_Id" = "p_ASMCL_Id"::INTEGER AND "E"."ASMS_Id" = "p_ASMS_Id"::INTEGER 
            AND "E"."ISMS_Id" = "p_ISMS_Id"::INTEGER
    ) AS "PVSelctedColumns";

    "v_sqldynamic" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp" AS 
    SELECT ("ASMCL_ClassName" || ''('' || "ASMC_SectionName" || '')'') AS "Class", 
           ''Totalnoofstudents'' AS "Details", ' || "v_PivotSelectColumnNames" || '
    FROM CROSSTAB(
        ''SELECT "B"."ASMCL_ClassName" || ''''('''''' || "C"."ASMC_SectionName" || '''')'''' AS "Class",
                 "F"."ISMS_SubjectName",
                 COUNT(DISTINCT "A"."AMST_Id")::INTEGER
          FROM "Exm"."Exm_Student_Marks_Process" "A"
          INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_Id" = "A"."ASMCL_Id"
          INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_Id" = "A"."ASMS_Id"
          INNER JOIN "Exm"."Exm_Master_Exam" "D" ON "D"."EME_Id" = "A"."EME_Id" AND "A"."MI_Id" = "D"."MI_Id"
          INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "E" ON "A"."MI_Id" = "E"."MI_Id" 
              AND "E"."ASMAY_Id" = "A"."ASMAY_Id" AND "B"."ASMCL_Id" = "E"."ASMCL_Id" 
              AND "C"."ASMS_Id" = "E"."ASMS_Id" AND "A"."MI_Id" = "E"."MI_Id"
          INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_Id" = "E"."ISMS_Id" AND "F"."MI_Id" = "E"."MI_Id"
          WHERE "E"."MI_Id" = ' || "p_MI_Id" || ' AND "E"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
              AND "E"."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND "E"."ASMS_Id" = ' || "p_ASMS_Id" || ' 
              AND "E"."ISMS_Id" = ' || "p_ISMS_Id" || '
          GROUP BY "B"."ASMCL_ClassName", "C"."ASMC_SectionName", "F"."ISMS_SubjectName"
          ORDER BY 1, 2''
    ) AS ct("Class" TEXT, ' || "v_PivotColumnNames" || ')
    GROUP BY "ASMCL_ClassName", "ASMC_SectionName"';

    "v_sqldynamic1" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp1" AS 
    SELECT ("ASMCL_ClassName" || ''('' || "ASMC_SectionName" || '')'') AS "Class", 
           ''Passed Students'' AS "Details", ' || "v_PivotSelectColumnNames" || '
    FROM CROSSTAB(
        ''SELECT "B"."ASMCL_ClassName" || ''''('''''' || "C"."ASMC_SectionName" || '''')'''' AS "Class",
                 "F"."ISMS_SubjectName",
                 COUNT(DISTINCT "A"."AMST_Id")::INTEGER
          FROM "Exm"."Exm_Student_Marks_Process" "A"
          INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_Id" = "A"."ASMCL_Id"
          INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_Id" = "A"."ASMS_Id"
          INNER JOIN "Exm"."Exm_Master_Exam" "D" ON "D"."EME_Id" = "A"."EME_Id" AND "A"."MI_Id" = "D"."MI_Id"
          INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "E" ON "A"."MI_Id" = "E"."MI_Id" 
              AND "E"."ASMAY_Id" = "A"."ASMAY_Id" AND "B"."ASMCL_Id" = "E"."ASMCL_Id" 
              AND "C"."ASMS_Id" = "E"."ASMS_Id" AND "A"."MI_Id" = "E"."MI_Id"
          INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_Id" = "E"."ISMS_Id" AND "F"."MI_Id" = "E"."MI_Id"
          WHERE "E"."MI_Id" = ' || "p_MI_Id" || ' AND "E"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
              AND "E"."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND "E"."ASMS_Id" = ' || "p_ASMS_Id" || ' 
              AND "E"."ISMS_Id" = ' || "p_ISMS_Id" || ' AND "E"."ESTMPS_PassFailFlg" = ''''Pass''''
          GROUP BY "B"."ASMCL_ClassName", "C"."ASMC_SectionName", "F"."ISMS_SubjectName"
          ORDER BY 1, 2''
    ) AS ct("Class" TEXT, ' || "v_PivotColumnNames" || ')
    GROUP BY "ASMCL_ClassName", "ASMC_SectionName"';

    "v_sqldynamic2" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp2" AS 
    SELECT ("ASMCL_ClassName" || ''('' || "ASMC_SectionName" || '')'') AS "Class", 
           ''Failed Students'' AS "Details", ' || "v_PivotSelectColumnNames" || '
    FROM CROSSTAB(
        ''SELECT "B"."ASMCL_ClassName" || ''''('''''' || "C"."ASMC_SectionName" || '''')'''' AS "Class",
                 "F"."ISMS_SubjectName",
                 COUNT(DISTINCT "A"."AMST_Id")::INTEGER
          FROM "Exm"."Exm_Student_Marks_Process" "A"
          INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_Id" = "A"."ASMCL_Id"
          INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_Id" = "A"."ASMS_Id"
          INNER JOIN "Exm"."Exm_Master_Exam" "D" ON "D"."EME_Id" = "A"."EME_Id" AND "A"."MI_Id" = "D"."MI_Id"
          INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "E" ON "A"."MI_Id" = "E"."MI_Id" 
              AND "E"."ASMAY_Id" = "A"."ASMAY_Id" AND "B"."ASMCL_Id" = "E"."ASMCL_Id" 
              AND "C"."ASMS_Id" = "E"."ASMS_Id" AND "A"."MI_Id" = "E"."MI_Id"
          INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_Id" = "E"."ISMS_Id" AND "F"."MI_Id" = "E"."MI_Id"
          WHERE "E"."MI_Id" = ' || "p_MI_Id" || ' AND "E"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
              AND "E"."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND "E"."ASMS_Id" = ' || "p_ASMS_Id" || ' 
              AND "E"."ISMS_Id" = ' || "p_ISMS_Id" || ' AND "E"."ESTMPS_PassFailFlg" = ''''Fail''''
          GROUP BY "B"."ASMCL_ClassName", "C"."ASMC_SectionName", "F"."ISMS_SubjectName"
          ORDER BY 1, 2''
    ) AS ct("Class" TEXT, ' || "v_PivotColumnNames" || ')
    GROUP BY "ASMCL_ClassName", "ASMC_SectionName"';

    "v_sqldynamic3" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp3" AS 
    SELECT ("ASMCL_ClassName" || ''('' || "ASMC_SectionName" || '')'') AS "Class", 
           ''Topper Marks'' AS "Details", ' || "v_PivotSelectColumnNames" || '
    FROM CROSSTAB(
        ''SELECT "ASMCL_ClassName" || ''''('''''' || "ASMC_SectionName" || '''')'''' AS "Class",
                 "ISMS_SubjectName",
                 "ESTMPS_ClassHighest"::INTEGER
          FROM (
              SELECT "B"."ASMCL_ClassName", "C"."ASMC_SectionName", "F"."ISMS_SubjectName", 
                     "E"."ESTMPS_ClassHighest",
                     ROW_NUMBER() OVER(PARTITION BY "F"."ISMS_SubjectName" ORDER BY "E"."ESTMPS_ClassHighest" DESC) AS "Rno"
              FROM "Exm"."Exm_Student_Marks_Process" "A"
              INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_Id" = "A"."ASMCL_Id"
              INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_Id" = "A"."ASMS_Id"
              INNER JOIN "Exm"."Exm_Master_Exam" "D" ON "D"."EME_Id" = "A"."EME_Id" AND "A"."MI_Id" = "D"."MI_Id"
              INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "E" ON "A"."MI_Id" = "E"."MI_Id" 
                  AND "E"."ASMAY_Id" = "A"."ASMAY_Id" AND "B"."ASMCL_Id" = "E"."ASMCL_Id" 
                  AND "C"."ASMS_Id" = "E"."ASMS_Id" AND "A"."MI_Id" = "E"."MI_Id"
              INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_Id" = "E"."ISMS_Id" AND "F"."MI_Id" = "E"."MI_Id"
              WHERE "E"."MI_Id" = ' || "p_MI_Id" || ' AND "E"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
                  AND "E"."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND "E"."ASMS_Id" = ' || "p_ASMS_Id" || ' 
                  AND "E"."ISMS_Id" = ' || "p_ISMS_Id" || '
          ) "SubQ"
          WHERE "Rno" = 1
          ORDER BY 1, 2''
    ) AS ct("Class" TEXT, ' || "v_PivotColumnNames" || ')
    GROUP BY "ASMCL_ClassName", "ASMC_SectionName"';

    "v_sqldynamic4" := 'CREATE TEMP TABLE "ExamStudentMarks_Temp4" AS 
    SELECT ("ASMCL_ClassName" || ''('' || "ASMC_SectionName" || '')'') AS "Class", 
           ''Section Average Marks'' AS "Details", ' || "v_PivotSelectColumnNames" || '
    FROM CROSSTAB(
        ''SELECT "ASMCL_ClassName" || ''''('''''' || "ASMC_SectionName" || '''')'''' AS "Class",
                 "ISMS_SubjectName",
                 "ESTMPS_SectionAverage"::INTEGER
          FROM (
              SELECT "B"."ASMCL_ClassName", "C"."ASMC_SectionName", "F"."ISMS_SubjectName", 
                     "E"."ESTMPS_SectionAverage",
                     ROW_NUMBER() OVER(PARTITION BY "F"."ISMS_SubjectName" ORDER BY "E"."ESTMPS_SectionAverage" DESC) AS "Rno"
              FROM "Exm"."Exm_Student_Marks_Process" "A"
              INNER JOIN "Adm_School_M_Class" "B" ON "B"."ASMCL_Id" = "A"."ASMCL_Id"
              INNER JOIN "Adm_School_M_Section" "C" ON "C"."ASMS_Id" = "A"."ASMS_Id"
              INNER JOIN "Exm"."Exm_Master_Exam" "D" ON "D"."EME_Id" = "A"."EME_Id" AND "A"."MI_Id" = "D"."MI_Id"
              INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "E" ON "A"."MI_Id" = "E"."MI_Id" 
                  AND "E"."ASMAY_Id" = "A"."ASMAY_Id" AND "B"."ASMCL_Id" = "E"."ASMCL_Id" 
                  AND "C"."ASMS_Id" = "E"."ASMS_Id" AND "A"."MI_Id" = "E"."MI_Id"
              INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_Id" = "E"."ISMS_Id" AND "F"."MI_Id" = "E"."MI_Id"
              WHERE "E"."MI_Id" = ' || "p_MI_Id" || ' AND "E"."ASMAY_Id" = ' || "p_ASMAY_Id" || ' 
                  AND "E"."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND "E"."ASMS_Id" = ' || "p_ASMS_Id" || ' 
                  AND "E"."ISMS_Id" = ' || "p_ISMS_Id" || '
          ) "SubQ"
          WHERE "Rno" = 1
          ORDER BY 1, 2''
    ) AS ct("Class" TEXT, ' || "v_PivotColumnNames" || ')
    GROUP BY "ASMCL_ClassName", "ASMC_SectionName"';

    EXECUTE "v_sqldynamic";
    EXECUTE "v_sqldynamic1";
    EXECUTE "v_sqldynamic2";
    EXECUTE "v_sqldynamic3";
    EXECUTE "v_sqldynamic4";

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