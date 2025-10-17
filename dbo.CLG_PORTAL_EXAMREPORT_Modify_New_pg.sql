CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_EXAMREPORT_Modify_New"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCO_Id BIGINT,
    p_AMB_Id BIGINT,
    p_AMSE_Id BIGINT,
    p_AMCST_Id BIGINT,
    p_EME_Id BIGINT,
    p_ISMS_Id BIGINT,
    p_type VARCHAR(20)
)
RETURNS TABLE(
    "EME_ExamName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "ECSTMPS_MaxMarks" NUMERIC,
    "ECSTMPS_ObtainedMarks" NUMERIC,
    "ECSTMPS_ObtainedGrade" VARCHAR,
    "ECSTMPS_SemAverage" NUMERIC,
    "ECSTMPS_SectionAverage" NUMERIC,
    "ECSTMPS_SemHighest" NUMERIC,
    "ECSTMPS_SectionHighest" NUMERIC,
    "ASMAY_Year" VARCHAR,
    "EME_ExamOrder" INTEGER,
    "ASMAY_Order" INTEGER,
    "ECSTMP_SemRank" INTEGER,
    "ECSTMP_SectionRank" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_type = 'EWAS' THEN
        RETURN QUERY
        SELECT 
            NULL::VARCHAR AS "EME_ExamName",
            NULL::VARCHAR AS "AMSE_SEMName",
            C."ISMS_SubjectName",
            B."ECSTMPS_MaxMarks",
            B."ECSTMPS_ObtainedMarks",
            B."ECSTMPS_ObtainedGrade",
            B."ECSTMPS_SemAverage",
            B."ECSTMPS_SectionAverage",
            B."ECSTMPS_SemHighest",
            B."ECSTMPS_SectionHighest",
            E."ASMAY_Year",
            NULL::INTEGER AS "EME_ExamOrder",
            NULL::INTEGER AS "ASMAY_Order",
            NULL::INTEGER AS "ECSTMP_SemRank",
            NULL::INTEGER AS "ECSTMP_SectionRank"
        FROM "clg"."Adm_Master_College_Student" A
        INNER JOIN "clg"."Exm_Col_Student_Marks_Process_Subjectwise" B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "IVRM_Master_Subjects" C ON B."ISMS_Id" = C."ISMS_Id" AND C."MI_Id" = B."MI_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON B."EME_Id" = D."EME_Id" AND D."MI_Id" = B."MI_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = B."ASMAY_Id"
        WHERE A."AMCST_Id" = p_AMCST_Id 
            AND A."MI_Id" = p_MI_Id 
            AND D."EME_Id" = p_EME_Id 
            AND A."AMCST_ActiveFlag" = TRUE 
            AND A."AMCST_SOL" = 'S' 
            AND B."ASMAY_Id" = p_ASMAY_Id 
        ORDER BY C."ISMS_OrderFlag";

    ELSIF p_type = 'SWAE' THEN
        RETURN QUERY
        SELECT 
            D."EME_ExamName",
            NULL::VARCHAR AS "AMSE_SEMName",
            C."ISMS_SubjectName",
            B."ECSTMPS_MaxMarks",
            B."ECSTMPS_ObtainedMarks",
            B."ECSTMPS_ObtainedGrade",
            B."ECSTMPS_SemAverage",
            B."ECSTMPS_SectionAverage",
            B."ECSTMPS_SemHighest",
            B."ECSTMPS_SectionHighest",
            E."ASMAY_Year",
            D."EME_ExamOrder",
            NULL::INTEGER AS "ASMAY_Order",
            NULL::INTEGER AS "ECSTMP_SemRank",
            NULL::INTEGER AS "ECSTMP_SectionRank"
        FROM "clg"."Adm_Master_College_Student" A
        INNER JOIN "clg"."Exm_Col_Student_Marks_Process_Subjectwise" B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "IVRM_Master_Subjects" C ON B."ISMS_Id" = C."ISMS_Id" AND C."MI_Id" = B."MI_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON B."EME_Id" = D."EME_Id" AND D."MI_Id" = B."MI_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = B."ASMAY_Id"
        WHERE A."AMCST_Id" = p_AMCST_Id 
            AND A."MI_Id" = p_MI_Id 
            AND C."ISMS_Id" = p_ISMS_Id 
            AND A."AMCST_ActiveFlag" = TRUE 
            AND A."AMCST_SOL" = 'S' 
            AND B."ASMAY_Id" = p_ASMAY_Id 
        ORDER BY D."EME_ExamOrder";

    ELSIF p_type = 'ESW' THEN
        RETURN QUERY
        SELECT 
            NULL::VARCHAR AS "EME_ExamName",
            NULL::VARCHAR AS "AMSE_SEMName",
            C."ISMS_SubjectName",
            B."ECSTMPS_MaxMarks",
            B."ECSTMPS_ObtainedMarks",
            B."ECSTMPS_ObtainedGrade",
            B."ECSTMPS_SemAverage",
            B."ECSTMPS_SectionAverage",
            B."ECSTMPS_SemHighest",
            B."ECSTMPS_SectionHighest",
            E."ASMAY_Year",
            D."EME_ExamOrder",
            NULL::INTEGER AS "ASMAY_Order",
            NULL::INTEGER AS "ECSTMP_SemRank",
            NULL::INTEGER AS "ECSTMP_SectionRank"
        FROM "clg"."Adm_Master_College_Student" A
        INNER JOIN "clg"."Exm_Col_Student_Marks_Process_Subjectwise" B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "IVRM_Master_Subjects" C ON B."ISMS_Id" = C."ISMS_Id" AND C."MI_Id" = B."MI_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON B."EME_Id" = D."EME_Id" AND D."MI_Id" = B."MI_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = B."ASMAY_Id"
        WHERE A."AMCST_Id" = p_AMCST_Id 
            AND A."MI_Id" = p_MI_Id 
            AND C."ISMS_Id" = p_ISMS_Id 
            AND D."EME_Id" = p_EME_Id 
            AND A."AMCST_ActiveFlag" = TRUE 
            AND A."AMCST_SOL" = 'S' 
            AND B."ASMAY_Id" = p_ASMAY_Id 
        ORDER BY D."EME_ExamOrder";

    ELSIF p_type = 'OVERALL' THEN
        RETURN QUERY
        SELECT 
            D."EME_ExamName",
            G."AMSE_SEMName",
            H."ISMS_SubjectName",
            B."ECSTMPS_MaxMarks",
            B."ECSTMPS_ObtainedMarks",
            B."ECSTMPS_ObtainedGrade",
            NULL::NUMERIC AS "ECSTMPS_SemAverage",
            NULL::NUMERIC AS "ECSTMPS_SectionAverage",
            B."ECSTMPS_SemHighest",
            B."ECSTMPS_SectionHighest",
            E."ASMAY_Year",
            D."EME_ExamOrder",
            E."ASMAY_Order",
            F."ECSTMP_SemRank",
            F."ECSTMP_SectionRank"
        FROM "clg"."Adm_Master_College_Student" A
        INNER JOIN "clg"."Exm_Col_Student_Marks_Process_Subjectwise" B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Semester" G ON G."MI_Id" = 21 AND G."AMSE_ActiveFlg" = TRUE AND G."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Exm_Col_Student_Marks_Process" F ON F."ASMAY_Id" = B."ASMAY_Id" AND F."AMCST_Id" = A."AMCST_Id" AND F."EME_Id" = B."EME_Id" AND F."ASMAY_Id" = E."ASMAY_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON B."EME_Id" = D."EME_Id" AND D."MI_Id" = B."MI_Id"
        INNER JOIN "IVRM_Master_Subjects" H ON H."MI_Id" = 21 AND H."ISMS_ActiveFlag" = TRUE AND H."ISMS_Id" = B."ISMS_ID"
        WHERE A."AMCST_Id" = p_AMCST_Id 
            AND A."MI_Id" = p_MI_Id 
            AND A."AMCST_ActiveFlag" = TRUE 
            AND A."AMCST_SOL" = 'S' 
            AND D."EME_Id" IN (SELECT "eme_id" FROM "CLG"."Exm_Col_Student_Marks_Process" WHERE "mi_id" = p_MI_Id AND "AMCST_Id" = p_AMCST_Id) 
        ORDER BY E."ASMAY_Order", D."EME_ExamOrder";

    ELSIF p_type = 'SubOVERALL' THEN
        RETURN QUERY
        SELECT 
            D."EME_ExamName",
            G."AMSE_SEMName",
            H."ISMS_SubjectName",
            B."ECSTMPS_MaxMarks",
            B."ECSTMPS_ObtainedMarks",
            B."ECSTMPS_ObtainedGrade",
            NULL::NUMERIC AS "ECSTMPS_SemAverage",
            NULL::NUMERIC AS "ECSTMPS_SectionAverage",
            B."ECSTMPS_SemHighest",
            B."ECSTMPS_SectionHighest",
            E."ASMAY_Year",
            D."EME_ExamOrder",
            E."ASMAY_Order",
            F."ECSTMP_SemRank",
            F."ECSTMP_SectionRank"
        FROM "clg"."Adm_Master_College_Student" A
        INNER JOIN "clg"."Exm_Col_Student_Marks_Process_Subjectwise" B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Semester" G ON G."MI_Id" = 21 AND G."AMSE_ActiveFlg" = TRUE AND G."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Exm_Col_Student_Marks_Process" F ON F."ASMAY_Id" = B."ASMAY_Id" AND F."AMCST_Id" = A."AMCST_Id" AND F."EME_Id" = B."EME_Id" AND F."ASMAY_Id" = E."ASMAY_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON B."EME_Id" = D."EME_Id" AND D."MI_Id" = B."MI_Id"
        INNER JOIN "IVRM_Master_Subjects" H ON H."MI_Id" = 21 AND H."ISMS_ActiveFlag" = TRUE AND H."ISMS_Id" = B."ISMS_ID"
        WHERE A."AMCST_Id" = p_AMCST_Id 
            AND A."MI_Id" = p_MI_Id 
            AND A."AMCST_ActiveFlag" = TRUE 
            AND A."AMCST_SOL" = 'S' 
            AND D."EME_Id" IN (SELECT "eme_id" FROM "CLG"."Exm_Col_Student_Marks_Process" WHERE "mi_id" = p_MI_Id AND "AMCST_Id" = p_AMCST_Id) 
        ORDER BY E."ASMAY_Order", D."EME_ExamOrder";

    ELSIF p_type = 'ExmOVERALL' THEN
        RETURN QUERY
        SELECT 
            D."EME_ExamName",
            G."AMSE_SEMName",
            H."ISMS_SubjectName",
            B."ECSTMPS_MaxMarks",
            B."ECSTMPS_ObtainedMarks",
            B."ECSTMPS_ObtainedGrade",
            NULL::NUMERIC AS "ECSTMPS_SemAverage",
            NULL::NUMERIC AS "ECSTMPS_SectionAverage",
            B."ECSTMPS_SemHighest",
            B."ECSTMPS_SectionHighest",
            E."ASMAY_Year",
            D."EME_ExamOrder",
            E."ASMAY_Order",
            F."ECSTMP_SemRank",
            F."ECSTMP_SectionRank"
        FROM "clg"."Adm_Master_College_Student" A
        INNER JOIN "clg"."Exm_Col_Student_Marks_Process_Subjectwise" B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Semester" G ON G."MI_Id" = 21 AND G."AMSE_ActiveFlg" = TRUE AND G."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Exm_Col_Student_Marks_Process" F ON F."ASMAY_Id" = B."ASMAY_Id" AND F."AMCST_Id" = A."AMCST_Id" AND F."EME_Id" = B."EME_Id" AND F."ASMAY_Id" = E."ASMAY_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON B."EME_Id" = D."EME_Id" AND D."MI_Id" = B."MI_Id"
        INNER JOIN "IVRM_Master_Subjects" H ON H."MI_Id" = 21 AND H."ISMS_ActiveFlag" = TRUE AND H."ISMS_Id" = B."ISMS_ID"
        WHERE A."AMCST_Id" = p_AMCST_Id 
            AND A."MI_Id" = p_MI_Id 
            AND A."AMCST_ActiveFlag" = TRUE 
            AND A."AMCST_SOL" = 'S' 
            AND D."EME_Id" IN (SELECT "eme_id" FROM "CLG"."Exm_Col_Student_Marks_Process" WHERE "mi_id" = p_MI_Id AND "AMCST_Id" = p_AMCST_Id) 
        ORDER BY E."ASMAY_Order", D."EME_ExamOrder";

    END IF;

END;
$$;