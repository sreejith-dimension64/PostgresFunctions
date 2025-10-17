CREATE OR REPLACE FUNCTION "dbo"."Exm_StudentSbjectWiseProgress"(
    p_MI_Id varchar(100),
    p_ASMAY_Id varchar(100),
    p_AMST_Id varchar(100)
)
RETURNS TABLE (
    "ISMS_SubjectName" varchar,
    exam_data jsonb
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
    v_PivotColumnNames text := '';
    v_PivotSelectColumnNames text := '';
BEGIN

    -- Get distinct values of the PIVOT Column
    SELECT STRING_AGG('"' || "EME_ExamName" || '"', ',')
    INTO v_PivotColumnNames
    FROM (
        SELECT DISTINCT "EME"."EME_ExamName"
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
        WHERE "ESS"."MI_Id" = p_MI_Id 
            AND "ESMPS"."ASMAY_Id" = p_ASMAY_Id 
            AND "ESMPS"."AMST_Id" = p_AMST_Id
    ) AS PVColumns;

    -- Get distinct values of the PIVOT Column with coalesce
    SELECT STRING_AGG('COALESCE("' || "EME_ExamName" || '", 0) AS "' || "EME_ExamName" || '"', ',')
    INTO v_PivotSelectColumnNames
    FROM (
        SELECT DISTINCT "EME"."EME_ExamName"
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
        WHERE "ESS"."MI_Id" = p_MI_Id 
            AND "ESMPS"."ASMAY_Id" = p_ASMAY_Id 
            AND "ESMPS"."AMST_Id" = p_AMST_Id
    ) AS PVSelctedColumns;

    v_sqldynamic := '
    SELECT DISTINCT "ISMS_SubjectName", ' || v_PivotSelectColumnNames || ' 
    FROM (
        SELECT "IMS"."ISMS_SubjectName", "EME"."EME_ExamName", "ESMPS"."ESTMPS_ObtainedMarks"
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
        WHERE "ESS"."MI_Id" = ' || quote_literal(p_MI_Id) || ' 
            AND "ESMPS"."ASMAY_Id" = ' || quote_literal(p_ASMAY_Id) || ' 
            AND "ESMPS"."AMST_Id" = ' || quote_literal(p_AMST_Id) || '
        ORDER BY "ESMPS"."EME_Id", "ESMPS"."ISMS_OrderFlag"
        LIMIT 100
    ) AS New 
    CROSSTAB AS ct("ISMS_SubjectName" varchar, ' || v_PivotColumnNames || ')';

    RETURN QUERY EXECUTE v_sqldynamic;

END;
$$;