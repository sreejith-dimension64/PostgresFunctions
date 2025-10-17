CREATE OR REPLACE FUNCTION "dbo"."CLG_Exam_Get_Students_Subjects_Marks_Entry"(
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_MI_Id TEXT,
    p_ACSS_Id TEXT,
    p_ACST_Id TEXT,
    p_EME_Id TEXT,
    p_ISMS_Id TEXT,
    p_EMSS_Id TEXT,
    p_EMSE_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT
)
RETURNS TABLE (
    "AMCST_Id" BIGINT,
    "AMCST_FirstName" TEXT,
    "AMCST_MiddleName" TEXT,
    "AMCST_LastName" TEXT,
    "AMCST_AdmNo" TEXT,
    "ACYST_RollNo" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "ISMS_SubjectName" TEXT,
    "SubName" TEXT,
    "ECYSES_MaxMarks" NUMERIC,
    "ECYSES_MarksEntryMax" NUMERIC,
    "ECYSES_MinMarks" NUMERIC,
    "ECSTM_Flg" TEXT,
    "ECSTM_Marks" NUMERIC,
    "ECSTM_Grade" TEXT,
    "ECSTM_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order TEXT;
    v_ordertype TEXT;
    v_Sqlquery TEXT;
    v_cnt BIGINT;
    v_ECYS_Id INT;
BEGIN

    SELECT "ExmConfig_Recordsearchtype" INTO v_order 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_MI_Id::BIGINT;
    
    SELECT DISTINCT "ECYS_Id" INTO v_ECYS_Id 
    FROM "clg"."Exm_Col_Yearly_Scheme"
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "AMCO_Id" = p_AMCO_Id::BIGINT
        AND "AMB_Id" = p_AMB_Id::BIGINT 
        AND "AMSE_Id" = p_AMSE_Id::BIGINT 
        AND "ACSS_Id" = p_ACSS_Id::BIGINT
        AND "ACST_Id" = p_ACST_Id::BIGINT
        AND "ECYS_ActiveFlag" = TRUE
    LIMIT 1;
    
    IF v_order = 'Name' THEN
        v_ordertype := '"AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName"';
    ELSIF v_order = 'AdmNo' THEN
        v_ordertype := '"AMCST_AdmNo"';
    ELSIF v_order = 'RollNo' THEN
        v_ordertype := '"ACYST_RollNo"';
    ELSIF v_order = 'RegNo' THEN
        v_ordertype := '"AMCST_RegistrationNo"';
    ELSE
        v_ordertype := '"ACYST_RollNo"';
    END IF;
    
    /* WHEN SUB SUBJECT AND SUB EXAM IS NOT THERE */
    IF p_EMSS_Id::INT = 0 AND p_EMSE_Id::INT = 0 THEN
        RETURN QUERY EXECUTE 
        'SELECT DISTINCT f."AMCST_Id", e."AMCST_FirstName", e."AMCST_MiddleName", e."AMCST_LastName", 
            e."AMCST_AdmNo", f."ACYST_RollNo", e."AMCST_RegistrationNo", g."ISMS_SubjectName",
            ''''::TEXT as SubName,
            COALESCE(h."ECYSES_MaxMarks", 0) as "ECYSES_MaxMarks",
            COALESCE(h."ECYSES_MarksEntryMax", 0) as "ECYSES_MarksEntryMax",
            COALESCE(h."ECYSES_MinMarks", 0) as "ECYSES_MinMarks",
            COALESCE(i."ECSTM_Flg", '''') as "ECSTM_Flg",
            COALESCE(i."ECSTM_Marks", 0) as "ECSTM_Marks",
            COALESCE(i."ECSTM_Grade", '''') as "ECSTM_Grade",
            COALESCE(i."ECSTM_Id", 0) as "ECSTM_Id"
        FROM "CLG"."Adm_Master_College_Student" as e
        INNER JOIN "CLG"."Adm_College_Yearly_Student" as f 
            ON f."AMCST_Id" = e."AMCST_Id" 
            AND e."AMCST_SOL" = ''S''
            AND f."ACYST_ActiveFlag" = TRUE 
            AND f."ASMAY_Id" = ' || p_ASMAY_Id || '
            AND f."AMCO_Id" = ' || p_AMCO_Id || '
            AND f."AMB_Id" = ' || p_AMB_Id || '
            AND f."AMSE_Id" = ' || p_AMSE_Id || '
            AND f."ACMS_Id" = ' || p_ACMS_Id || '
            AND f."AMCST_Id" = e."AMCST_Id"
        LEFT OUTER JOIN "IVRM_Master_Subjects" as g 
            ON g."ISMS_ActiveFlag" = TRUE 
            AND g."ISMS_ExamFlag" = TRUE
            AND g."ISMS_Id" = ' || p_ISMS_Id || '
        INNER JOIN "clg"."Exm_Col_Yearly_Scheme" as l 
            ON l."ECYS_ActiveFlag" = TRUE
            AND l."MI_Id" = ' || p_MI_Id || '
            AND l."AMCO_Id" = ' || p_AMCO_Id || '
            AND l."AMB_Id" = ' || p_AMB_Id || '
            AND l."AMSE_Id" = ' || p_AMSE_Id || '
            AND l."ACSS_Id" = ' || p_ACSS_Id || '
            AND l."ACST_Id" = ' || p_ACST_Id || '
        INNER JOIN "clg"."Exm_Col_Yearly_Scheme_Exams" as j 
            ON j."ECYSE_ActiveFlg" = TRUE 
            AND l."ECYS_Id" = j."ECYS_Id"
            AND j."AMCO_Id" = ' || p_AMCO_Id || '
            AND j."AMB_Id" = ' || p_AMB_Id || '
            AND j."AMSE_Id" = ' || p_AMSE_Id || '
            AND j."ACSS_Id" = ' || p_ACSS_Id || '
            AND j."EME_Id" = ' || p_EME_Id || '
        LEFT OUTER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" as h 
            ON h."ISMS_Id" = g."ISMS_Id"
            AND h."ECYSES_ActiveFlg" = TRUE 
            AND h."ISMS_Id" = ' || p_ISMS_Id || '
            AND h."ECYSE_Id" = j."ECYSE_Id"
        LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks" as i 
            ON e."AMCST_Id" = i."AMCST_Id" 
            AND i."ECSTM_ActiveFlg" = TRUE
            AND i."MI_Id" = ' || p_MI_Id || '
            AND i."AMCO_Id" = ' || p_AMCO_Id || '
            AND i."AMB_Id" = ' || p_AMB_Id || '
            AND i."AMSE_Id" = ' || p_AMSE_Id || '
            AND i."ACMS_Id" = ' || p_ACMS_Id || '
            AND i."EME_Id" = ' || p_EME_Id || '
            AND i."ISMS_Id" = ' || p_ISMS_Id || '
            AND i."ASMAY_Id" = ' || p_ASMAY_Id || '
        INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" as m 
            ON m."AMCST_Id" = f."AMCST_Id" 
            AND m."ECSTSU_ActiveFlg" = TRUE
            AND m."MI_Id" = ' || p_MI_Id || '
            AND m."ASMAY_Id" = ' || p_ASMAY_Id || '
            AND m."AMCO_Id" = ' || p_AMCO_Id || '
            AND m."AMB_Id" = ' || p_AMB_Id || '
            AND m."AMSE_Id" = ' || p_AMSE_Id || '
            AND m."ACMS_Id" = ' || p_ACMS_Id || '
            AND m."ISMS_Id" = ' || p_ISMS_Id || '
            AND m."AMCST_Id" = e."AMCST_Id"
        WHERE h."ECYSES_MarksEntryMax" > 0
        ORDER BY ' || v_ordertype;
        
    ELSIF p_EMSS_Id::INT > 0 AND p_EMSE_Id::INT = 0 THEN
        RETURN QUERY EXECUTE
        'SELECT DISTINCT f."AMCST_Id", e."AMCST_FirstName", e."AMCST_MiddleName", e."AMCST_LastName",
            e."AMCST_AdmNo", f."ACYST_RollNo", e."AMCST_RegistrationNo", g."ISMS_SubjectName",
            J1."EMSS_SubSubjectName"::TEXT as SubName,
            COALESCE(h."ECYSES_MaxMarks", 0) as "ECYSES_MaxMarks",
            COALESCE(h."ECYSES_MarksEntryMax", 0) as "ECYSES_MarksEntryMax",
            COALESCE(h."ECYSES_MinMarks", 0) as "ECYSES_MinMarks",
            COALESCE(i."ECSTM_Flg", '''') as "ECSTM_Flg",
            COALESCE(LKL."ECSTMSS_Marks", 0) as "ECSTM_Marks",
            COALESCE(LKL."ECSTMSS_Grade", '''') as "ECSTM_Grade",
            COALESCE(LKL."ECSTM_Id", 0) as "ECSTM_Id"
        FROM "CLG"."Adm_Master_College_Student" as e
        INNER JOIN "CLG"."Adm_College_Yearly_Student" as f 
            ON f."AMCST_Id" = e."AMCST_Id" 
            AND e."AMCST_SOL" = ''S''
            AND f."ACYST_ActiveFlag" = TRUE 
            AND f."ASMAY_Id" = ' || p_ASMAY_Id || '
            AND f."AMCO_Id" = ' || p_AMCO_Id || '
            AND f."AMB_Id" = ' || p_AMB_Id || '
            AND f."AMSE_Id" = ' || p_AMSE_Id || '
            AND f."ACMS_Id" = ' || p_ACMS_Id || '
            AND f."AMCST_Id" = e."AMCST_Id"
        LEFT OUTER JOIN "IVRM_Master_Subjects" as g 
            ON g."ISMS_ActiveFlag" = TRUE 
            AND g."ISMS_ExamFlag" = TRUE
            AND g."ISMS_Id" = ' || p_ISMS_Id || '
        INNER JOIN "clg"."Exm_Col_Yearly_Scheme" as l 
            ON l."ECYS_ActiveFlag" = TRUE
            AND l."MI_Id" = ' || p_MI_Id || '
            AND l."AMCO_Id" = ' || p_AMCO_Id || '
            AND l."AMB_Id" = 31
            AND l."AMSE_Id" = ' || p_AMSE_Id || '
            AND l."ACSS_Id" = ' || p_ACSS_Id || '
            AND l."ACST_Id" = ' || p_ACST_Id || '
        INNER JOIN "clg"."Exm_Col_Yearly_Scheme_Exams" as j 
            ON j."ECYSE_ActiveFlg" = TRUE 
            AND l."ECYS_Id" = j."ECYS_Id"
            AND j."AMCO_Id" = ' || p_AMCO_Id || '
            AND j."AMB_Id" = ' || p_AMB_Id || '
            AND j."AMSE_Id" = ' || p_AMSE_Id || '
            AND j."ACSS_Id" = ' || p_ACSS_Id || '
            AND j."EME_Id" = ' || p_EME_Id || '
        LEFT OUTER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" as h 
            ON h."ISMS_Id" = g."ISMS_Id"
            AND h."ECYSES_ActiveFlg" = TRUE 
            AND h."ISMS_Id" = ' || p_ISMS_Id || '
            AND h."ECYSE_Id" = j."ECYSE_Id"
        LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks" as i 
            ON e."AMCST_Id" = i."AMCST_Id" 
            AND i."ECSTM_ActiveFlg" = TRUE
            AND i."MI_Id" = ' || p_MI_Id || '
            AND i."AMCO_Id" = ' || p_AMCO_Id || '
            AND i."AMB_Id" = ' || p_AMB_Id || '
            AND i."AMSE_Id" = ' || p_AMSE_Id || '
            AND i."ACMS_Id" = ' || p_ACMS_Id || '
            AND i."EME_Id" = ' || p_EME_Id || '
            AND i."ISMS_Id" = ' || p_ISMS_Id || '
            AND i."ASMAY_Id" = ' || p_ASMAY_Id || '
        INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" as m 
            ON m."AMCST_Id" = f."AMCST_Id" 
            AND m."ECSTSU_ActiveFlg" = TRUE
            AND m."MI_Id" = ' || p_MI_Id || '
            AND m."ASMAY_Id" = ' || p_ASMAY_Id || '
            AND m."AMCO_Id" = ' || p_AMCO_Id || '
            AND m."AMB_Id" = ' || p_AMB_Id || '
            AND m."AMSE_Id" = ' || p_AMSE_Id || '
            AND m."ACMS_Id" = ' || p_ACMS_Id || '
            AND m."ISMS_Id" = ' || p_ISMS_Id || '
            AND m."AMCST_Id" = e."AMCST_Id"
        LEFT OUTER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise_Sub" as I1 
            ON I1."ECYSES_Id" = h."ECYSES_Id"
            AND I1."ECYSESSS_ActiveFlg" = TRUE 
            AND I1."EMSS_Id" = ' || p_EMSS_Id || '
        LEFT OUTER JOIN "Exm"."Exm_Master_SubSubject" J1 
            ON J1."EMSS_Id" = I1."EMSS_Id"
            AND I1."EMSS_Id" = ' || p_EMSS_Id || '
        LEFT OUTER JOIN "clg"."Exm_Col_Student_Marks_SubSubject" LKL 
            ON i."ECSTM_Id" = LKL."ECSTM_Id" 
            AND i."ISMS_Id" = LKL."ISMS_Id"
            AND J1."EMSS_Id" = LKL."EMSS_Id" 
            AND LKL."EMSS_Id" = ' || p_EMSS_Id || '
        WHERE h."ECYSES_MarksEntryMax" > 0
        ORDER BY ' || v_ordertype;
        
    ELSIF p_EMSS_Id::INT = 0 AND p_EMSE_Id::INT > 0 THEN
        RETURN QUERY EXECUTE
        'SELECT DISTINCT f."AMCST_Id", e."AMCST_FirstName", e."AMCST_MiddleName", e."AMCST_LastName",
            e."AMCST_AdmNo", f."ACYST_RollNo", e."AMCST_RegistrationNo", g."ISMS_SubjectName",
            J1."EMSE_SubExamName"::TEXT as SubName,
            COALESCE(h."ECYSES_MaxMarks", 0) as "ECYSES_MaxMarks",
            COALESCE(h."ECYSES_MarksEntryMax", 0) as "ECYSES_MarksEntryMax",
            COALESCE(h."ECYSES_MinMarks", 0) as "ECYSES_MinMarks",
            COALESCE(i."ECSTM_Flg", '''') as "ECSTM_Flg",
            COALESCE(i."ECSTM_Marks", 0) as "ECSTM_Marks",
            COALESCE(i."ECSTM_Grade", '''') as "ECSTM_Grade",
            COALESCE(i."ECSTM_Id", 0) as "ECSTM_Id"
        FROM "CLG"."Adm_Master_College_Student" as e
        INNER JOIN "CLG"."Adm_College_Yearly_Student" as f 
            ON f."AMCST_Id" = e."AMCST_Id" 
            AND e."AMCST_SOL" = ''S''
            AND f."ACYST_ActiveFlag" = TRUE 
            AND f."ASMAY_Id" = ' || p_ASMAY_Id || '
            AND f."AMCO_Id" = ' || p_AMCO_Id || '
            AND f."AMB_Id" = ' || p_AMB_Id || '
            AND f."AMSE_Id" = ' || p_AMSE_Id || '
            AND f."ACMS_Id" = ' || p_ACMS_Id || '
            AND f."AMCST_Id" = e."AMCST_Id"
        LEFT OUTER JOIN "IVRM_Master_Subjects" as g 
            ON g."ISMS_ActiveFlag" = TRUE 
            AND g."ISMS_ExamFlag" = TRUE
            AND g."ISMS_Id" = ' || p_ISMS_Id || '
        INNER JOIN "clg"."Exm_Col_Yearly_Scheme" as l 
            ON l."ECYS_ActiveFlag" = TRUE
            AND l."MI_Id" = ' || p_MI_Id || '
            AND l."AMCO_Id" = ' || p_AMCO_Id || '
            AND l."AMB_Id" = 31
            AND l."AMSE_Id" = ' || p_AMSE_Id || '
            AND l."ACSS_Id" = ' || p_ACSS_Id || '
            AND l."ACST_Id" = ' || p_ACST_Id || '
        INNER JOIN "clg"."Exm_Col_Yearly_Scheme_Exams" as j 
            ON j."ECYSE_ActiveFlg" = TRUE 
            AND l."ECYS_Id" = j."ECYS_Id"
            AND j."AMCO_Id" = ' || p_AMCO_Id || '
            AND j."AMB_Id" = ' || p_AMB_Id || '
            AND j."AMSE_Id" = ' || p_AMSE_Id || '
            AND j."ACSS_Id" = ' || p_ACSS_Id || '
            AND j."EME_Id" = ' || p_EME_Id || '
        LEFT OUTER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" as h 
            ON h."ISMS_Id" = g."ISMS_Id"
            AND h."ECYSES_ActiveFlg" = TRUE 
            AND h."ISMS_Id" = ' || p_ISMS_Id || '
            AND h."ECYSE_Id" = j."ECYSE_Id"
        LEFT OUTER JOIN "CLG"."Exm_Col_Student_Marks" as i 
            ON e."AMCST_Id" = i."AMCST_Id" 
            AND i."ECSTM_ActiveFlg" = TRUE
            AND i."MI_Id" = ' || p_MI_Id || '
            AND i."AMCO_Id" = ' || p_AMCO_Id || '
            AND i."AMB_Id" = ' || p_AMB_Id || '
            AND i."AMSE_Id" = ' || p_AMSE_Id || '
            AND i."ACMS_Id" = ' || p_ACMS_Id || '
            AND i."EME_Id" = ' || p_EME_Id || '
            AND i."ISMS_Id" = ' || p_ISMS_Id || '
            AND i."ASMAY_Id" = ' || p_ASMAY_Id || '
        INNER JOIN "CLG"."Exm_Col_Studentwise_Subjects" as m 
            ON m."AMCST_Id" = f."AMCST_Id" 
            AND m."ECSTSU_ActiveFlg" = TRUE
            AND m."MI_Id" = ' || p_MI_Id || '
            AND m."ASMAY_Id" = ' || p_ASMAY_Id || '
            AND m."AMCO_Id" = ' || p_AMCO_Id || '
            AND m."AMB_Id" = ' || p_AMB_Id || '
            AND m."AMSE_Id" = ' || p_AMSE_Id || '
            AND m."ACMS_Id" = ' || p_ACMS_Id || '
            AND m."ISMS_Id" = ' || p_ISMS_Id || '
            AND m."AMCST_Id" = e."AMCST_Id"
        LEFT OUTER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise_Sub" as I1 
            ON I1."ECYSES_Id" = h."ECYSES_Id"
            AND I1."ECYSESSS_ActiveFlg" = TRUE 
            AND I1."EMSE_Id" = ' || p_EMSE_Id || '
        LEFT OUTER JOIN "Exm"."Exm_Master_SubExam" J1 
            ON J1."EMSE_Id" = I1."EMSE_Id"
            AND I1."EMSE_Id" = ' || p_EMSE_Id || '
        LEFT OUTER JOIN "clg"."Exm_Col_Student_Marks_SubSubject" LKL 
            ON i."ECSTM_Id" = LKL."ECSTM_Id" 
            AND i."ISMS_Id" = LKL."ISMS_Id"
            AND J1."EMSE_Id" = LKL."EMSE_Id" 
            AND LKL."EMSE_Id" = ' || p_EMSE_Id || '
        WHERE h."ECYSES_MarksEntryMax" > 0
        ORDER BY ' || v_ordertype;
    END IF;

    RETURN;
END;
$$;