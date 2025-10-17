CREATE OR REPLACE FUNCTION "dbo"."Exam_HHS_Progresscard_TotalMarks"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "estmP_TotalObtMarks" NUMERIC,
    "estmP_TotalMaxMarks" NUMERIC,
    "EME_ExamName" VARCHAR,
    "EME_ExamOrder" INTEGER,
    "emE_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EMCA_Id TEXT;
BEGIN
    SELECT DISTINCT A."EMCA_Id" INTO v_EMCA_Id
    FROM "EXM"."Exm_Master_Category" A
    INNER JOIN "EXM"."Exm_Category_Class" B ON A."EMCA_Id" = B."EMCA_Id"
    WHERE B."ASMAY_Id" = p_ASMAY_Id
    AND B."ASMCL_Id" = p_ASMCL_Id
    AND B."ASMS_Id" = p_ASMS_Id
    AND B."ECAC_ActiveFlag" = 1
    AND A."EMCA_ActiveFlag" = 1
    AND A."MI_Id" = p_MI_Id;

    RETURN QUERY
    SELECT 
        SUM(a.obtmarks) AS "estmP_TotalObtMarks",
        SUM(a.maxmarks) AS "estmP_TotalMaxMarks",
        a."EME_ExamName",
        a."EME_ExamOrder",
        a."emE_Id"
    FROM (
        SELECT 
            SUM(a."ESTMPS_ObtainedMarks") AS obtmarks,
            SUM(a."ESTMPS_MaxMarks") AS maxmarks,
            g."EME_ExamName",
            a."EME_Id",
            g."EME_ExamOrder"
        FROM "exm"."Exm_Student_Marks_Process_Subjectwise" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = b."ASMAY_Id" AND d."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = b."ASMCL_Id" AND e."ASMCL_Id" = a."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = b."ASMS_Id" AND f."ASMS_Id" = a."ASMS_Id"
        INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = a."EME_Id"
        INNER JOIN "IVRM_Master_Subjects" h ON h."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "exm"."Exm_Yearly_Category_Exams" i ON i."EME_Id" = a."EME_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" j ON j."EYCE_Id" = i."EYCE_Id" AND j."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "exm"."Exm_Yearly_Category" k ON k."EYC_Id" = i."EYC_Id" AND k."ASMAY_Id" = p_ASMAY_Id AND k."EYC_ActiveFlg" = 1 AND k."EMCA_Id" = v_EMCA_Id
        WHERE a."ASMAY_Id" = p_ASMAY_Id
        AND a."ASMCL_Id" = p_ASMCL_Id
        AND a."ASMS_Id" = p_ASMS_Id
        AND a."AMST_Id" = p_AMST_Id
        AND b."ASMAY_Id" = p_ASMAY_Id
        AND b."ASMCL_Id" = p_ASMCL_Id
        AND b."ASMS_Id" = p_ASMS_Id
        AND b."AMST_Id" = p_AMST_Id
        AND c."AMST_SOL" = 'S'
        AND c."AMST_ActiveFlag" = 1
        AND d."AMAY_ActiveFlag" = 1
        AND j."EYCES_AplResultFlg" = 1
        AND j."EYCES_ActiveFlg" = 1
        AND a."ISMS_Id" NOT IN (
            SELECT DISTINCT "Exm_Subject_Group_Subjects"."ISMS_Id"
            FROM "Exm"."Exm_Subject_Group"
            INNER JOIN "Exm"."Exm_Subject_Group_Subjects" ON "Exm_Subject_Group"."ESG_Id" = "Exm_Subject_Group_Subjects"."ESG_Id"
            INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm_Subject_Group_Exams"."ESG_Id" = "Exm_Subject_Group"."ESG_Id"
            INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" ON "Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm_Student_Marks_Process_Subjectwise"."ISMS_Id"
            INNER JOIN "exm"."Exm_Master_Exam" ON "Exm_Master_Exam"."EME_Id" = "Exm_Student_Marks_Process_Subjectwise"."EME_Id"
                AND "Exm_Master_Exam"."EME_Id" = "Exm_Subject_Group_Exams"."EME_Id"
            WHERE "Exm_Subject_Group"."MI_Id" = p_MI_Id
            AND "Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id
            AND "Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y'
            AND "Exm_Student_Marks_Process_Subjectwise"."AMST_Id" = p_AMST_Id
            AND "Exm_Subject_Group"."EMCA_Id" = v_EMCA_Id
        )
        GROUP BY g."EME_ExamName", g."EME_ExamOrder", a."EME_Id"

        UNION

        SELECT 
            CAST((SUM("Exm_Student_Marks_Process_Subjectwise"."ESTMPS_ObtainedMarks") / 3) AS DECIMAL(18,2)) AS obtmarks,
            (SUM("Exm_Student_Marks_Process_Subjectwise"."ESTMPS_MaxMarks") / 3) AS maxmarks,
            "Exm_Master_Exam"."EME_ExamName",
            "Exm_Subject_Group_Exams"."EME_Id",
            "Exm_Master_Exam"."EME_ExamOrder"
        FROM "Exm"."Exm_Subject_Group"
        INNER JOIN "Exm"."Exm_Subject_Group_Subjects" ON "Exm_Subject_Group"."ESG_Id" = "Exm_Subject_Group_Subjects"."ESG_Id"
        INNER JOIN "Exm"."Exm_Subject_Group_Exams" ON "Exm_Subject_Group_Exams"."ESG_Id" = "Exm_Subject_Group"."ESG_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" ON "Exm_Subject_Group_Subjects"."ISMS_Id" = "Exm_Student_Marks_Process_Subjectwise"."ISMS_Id"
        INNER JOIN "exm"."Exm_Master_Exam" ON "Exm_Master_Exam"."EME_Id" = "Exm_Student_Marks_Process_Subjectwise"."EME_Id"
            AND "Exm_Master_Exam"."EME_Id" = "Exm_Subject_Group_Exams"."EME_Id"
        WHERE "Exm_Subject_Group"."MI_Id" = p_MI_Id
        AND "Exm_Subject_Group"."ASMAY_Id" = p_ASMAY_Id
        AND "Exm_Subject_Group"."ESG_CompulsoryFlag" = 'Y'
        AND "Exm_Student_Marks_Process_Subjectwise"."AMST_Id" = p_AMST_Id
        AND "Exm_Subject_Group"."EMCA_Id" = v_EMCA_Id
        GROUP BY "Exm_Master_Exam"."EME_ExamName", "Exm_Subject_Group_Exams"."EME_Id", "Exm_Master_Exam"."EME_ExamOrder"
    ) a
    GROUP BY a."EME_ExamName", a."EME_ExamOrder", a."emE_Id"
    ORDER BY a."EME_ExamOrder";

    RETURN;
END;
$$;