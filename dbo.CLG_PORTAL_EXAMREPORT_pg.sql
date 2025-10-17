CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_EXAMREPORT"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCO_Id BIGINT,
    p_AMB_Id BIGINT,
    p_AMSE_Id BIGINT,
    p_ACMS_Id BIGINT,
    p_AMCST_Id BIGINT,
    p_EME_Id BIGINT,
    p_ISMS_Id BIGINT,
    p_type VARCHAR(20)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_type = 'EWAS' THEN
        -- Exam-wise All Subject
        RETURN QUERY
        SELECT 
            a."ISMS_Id",
            b."ISMS_SubjectName",
            a."EME_Id",
            a."ECSTMPS_MaxMarks",
            a."ECSTMPS_ObtainedMarks",
            a."ECSTMPS_ObtainedGrade",
            a."ECSTMPS_SemAverage",
            a."ECSTMPS_SectionAverage",
            a."ECSTMPS_SemHighest",
            a."ECSTMPS_SectionHighest",
            a."ECSTMPS_PassFailFlg"
        FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" a
        INNER JOIN "IVRM_Master_subjects" b ON a."ISMS_Id" = b."ISMS_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND a."AMCO_Id" = p_AMCO_Id 
            AND a."AMB_Id" = p_AMB_Id 
            AND a."AMSE_Id" = p_AMSE_Id 
            AND a."ACMS_Id" = p_ACMS_Id 
            AND a."AMCST_Id" = p_AMCST_Id 
            AND a."EME_Id" = p_EME_Id;

    ELSIF p_type = 'SWAE' THEN
        -- Subject-wise all Exam
        RETURN QUERY
        SELECT 
            a."ISMS_Id",
            b."EME_ExamName",
            a."EME_Id",
            a."ECSTMPS_MaxMarks",
            a."ECSTMPS_ObtainedMarks",
            a."ECSTMPS_ObtainedGrade",
            a."ECSTMPS_SemAverage",
            a."ECSTMPS_SectionAverage",
            a."ECSTMPS_SemHighest",
            a."ECSTMPS_SectionHighest",
            a."ECSTMPS_PassFailFlg"
        FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" a
        INNER JOIN "Exm"."Exm_Master_Exam" b ON a."EME_Id" = b."EME_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND a."AMCO_Id" = p_AMCO_Id 
            AND a."AMB_Id" = p_AMB_Id 
            AND a."AMSE_Id" = p_AMSE_Id 
            AND a."ACMS_Id" = p_ACMS_Id 
            AND a."AMCST_Id" = p_AMCST_Id 
            AND a."ISMS_Id" = p_ISMS_Id;

    ELSIF p_type = 'ESW' THEN
        -- Exam-Subject-wise Data
        RETURN QUERY
        SELECT 
            a."EME_Id",
            d."ASMAY_Year",
            a."ISMS_Id",
            b."EME_ExamName",
            c."ISMS_SubjectName",
            a."ECSTMPS_MaxMarks",
            a."ECSTMPS_ObtainedMarks",
            a."ECSTMPS_ObtainedGrade",
            a."ECSTMPS_SemAverage",
            a."ECSTMPS_SectionAverage",
            a."ECSTMPS_SemHighest",
            a."ECSTMPS_SectionHighest",
            a."ECSTMPS_PassFailFlg"
        FROM "clg"."Exm_Col_Student_Marks_Process_Subjectwise" a
        INNER JOIN "Exm"."Exm_Master_Exam" b ON a."EME_Id" = b."EME_Id"
        INNER JOIN "IVRM_Master_subjects" c ON a."ISMS_Id" = c."ISMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON a."ASMAY_Id" = d."ASMAY_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."AMCO_Id" = p_AMCO_Id 
            AND a."AMB_Id" = p_AMB_Id 
            AND a."AMSE_Id" = p_AMSE_Id 
            AND a."ACMS_Id" = p_ACMS_Id 
            AND a."AMCST_Id" = p_AMCST_Id 
            AND a."EME_Id" = p_EME_Id;

    ELSIF p_type = 'OVERALL' THEN
        -- Overall Data
        RETURN QUERY
        SELECT 
            g."ISMS_SubjectName",
            h."EME_ExamName",
            a."ECSTMPS_ObtainedMarks",
            d."ASMAY_Year",
            h."EME_ExamOrder",
            d."ASMAY_Order"
        FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" a
        INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" c ON c."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = a."ASMAY_Id" AND d."ASMAY_Id" = b."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id" AND e."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id" AND f."AMB_Id" = b."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" I ON I."AMSE_Id" = a."AMSE_Id" AND I."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" J ON J."ACMS_Id" = a."ACMS_Id" AND J."ACMS_Id" = b."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" g ON g."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" h ON h."EME_Id" = a."EME_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND c."MI_Id" = p_MI_Id 
            AND c."AMCST_SOL" = 'S' 
            AND c."AMCST_ActiveFlag" = 1 
            AND d."ASMAY_ActiveFlag" = 1 
            AND a."AMCST_Id" = p_AMCST_Id 
            AND b."AMCST_Id" = p_AMCST_Id 
            AND a."AMCO_Id" = p_AMCO_Id 
            AND f."AMB_Id" = p_AMB_Id 
            AND a."AMSE_Id" = p_AMSE_Id 
            AND a."ACMS_Id" = p_ACMS_Id 
            AND h."EME_Id" = p_EME_Id
        ORDER BY d."ASMAY_Order", h."EME_ExamOrder";

    END IF;

END;
$$;