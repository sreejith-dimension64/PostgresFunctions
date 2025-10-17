CREATE OR REPLACE FUNCTION "dbo"."Exam_Get_Students_Subjects_Marks_Entry"(
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_MI_Id TEXT,
    p_EME_Id TEXT,
    p_ISMS_Id TEXT,
    p_EMSS_Id TEXT,
    p_EMSE_Id TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_order TEXT;
    v_ordertype TEXT;
    v_EMCA_Id INT;
    v_EYC_Id INT;
    v_Count BIGINT;
    v_EXAM_Id_WHERE_CONDITION TEXT;
    v_Sqlquery TEXT;
    v_cnt BIGINT;
BEGIN

    SELECT "ExmConfig_Recordsearchtype" INTO v_order 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_MI_Id::BIGINT;

    IF v_order = 'Name' THEN
        v_ordertype := '"AMST_FirstName", "AMST_MiddleName", "AMST_LastName"';
    ELSIF v_order = 'AdmNo' THEN
        v_ordertype := '"AMST_AdmNo"';
    ELSIF v_order = 'RollNo' THEN
        v_ordertype := '"AMAY_RollNo"';
    ELSIF v_order = 'RegNo' THEN
        v_ordertype := '"AMST_RegistrationNo"';
    ELSE
        v_ordertype := '"AMAY_RollNo"';
    END IF;

    SELECT DISTINCT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND "ASMS_Id" = p_ASMS_Id::BIGINT 
        AND "ECAC_ActiveFlag" = TRUE;

    SELECT COUNT(*) INTO v_Count 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = TRUE 
        AND "EYC_BasedOnPaperTypeFlg" = TRUE;

    IF v_Count > 0 THEN
        v_EXAM_Id_WHERE_CONDITION := ' AND m."EME_Id" = ' || p_EME_Id || '';
    ELSE
        v_EXAM_Id_WHERE_CONDITION := '';
    END IF;

    IF p_EMSS_Id = '0' AND p_EMSE_Id = '0' THEN
        SELECT COUNT(*) INTO v_cnt 
        FROM "Exm"."Exm_Studentwise_Subjects" 
        WHERE "ISMS_Id" = p_ISMS_Id::BIGINT 
            AND "MI_Id" = p_MI_Id::BIGINT 
            AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND "ASMS_Id" = p_ASMS_Id::BIGINT 
            AND "ESTSU_ElecetiveFlag" = TRUE;

        IF v_cnt > 0 THEN
            v_Sqlquery := 'SELECT DISTINCT e."AMST_Id", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName", e."AMST_AdmNo", f."AMAY_RollNo", 
                e."AMST_RegistrationNo", g."ISMS_SubjectName", h."EYCES_MaxMarks", h."EYCES_MarksEntryMax", h."EYCES_MinMarks", 
                COALESCE(i."ESTM_Flg", '''') AS "ESTM_Flg", COALESCE(i."ESTM_Marks", 0) AS "ESTM_Marks", COALESCE(i."ESTM_Grade", '''') AS "ESTM_Grade", 
                COALESCE(i."ESTM_Id", 0) AS "ESTM_Id"
                FROM "Adm_M_Student" AS e
                LEFT OUTER JOIN "Exm"."Exm_Student_Marks" AS i ON e."AMST_Id" = i."AMST_Id" AND i."MI_Id" = ' || p_MI_Id || ' AND i."ASMAY_Id" = ' || p_ASMAY_Id || '
                    AND i."ASMCL_Id" = ' || p_ASMCL_Id || ' AND i."ASMS_Id" = ' || p_ASMS_Id || ' AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || ' AND i."ESTM_ActiveFlg" = TRUE
                INNER JOIN "Adm_School_Y_Student" AS f ON f."AMST_Id" = e."AMST_Id" AND e."AMST_ActiveFlag" = TRUE AND e."mi_id" = ' || p_MI_Id || ' AND e."AMST_SOL" = ''S''
                    AND f."AMAY_ActiveFlag" = TRUE AND f."ASMAY_Id" = ' || p_ASMAY_Id || ' AND f."ASMCL_Id" = ' || p_ASMCL_Id || ' AND f."ASMS_Id" = ' || p_ASMS_Id || '
                INNER JOIN "Exm"."Exm_Studentwise_Subjects" AS m ON m."AMST_Id" = f."AMST_Id" AND m."ESTSU_ElecetiveFlag" = TRUE AND m."ESTSU_ActiveFlg" = TRUE 
                    AND m."mi_id" = ' || p_MI_Id || ' AND m."ASMAY_Id" = ' || p_ASMAY_Id || ' AND m."ASMCL_Id" = ' || p_ASMCL_Id || ' AND m."ASMS_Id" = ' || p_ASMS_Id || ' 
                    AND m."ISMS_Id" = ' || p_ISMS_Id || ' ' || v_EXAM_Id_WHERE_CONDITION || '
                LEFT OUTER JOIN "IVRM_Master_Subjects" AS g ON g."ISMS_Id" = ' || p_ISMS_Id || ' AND g."Mi_id" = ' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = TRUE AND g."ISMS_ExamFlag" = TRUE
                LEFT OUTER JOIN "Exm"."Exm_Category_Class" AS l ON l."MI_Id" = ' || p_MI_Id || ' AND l."ASMAY_Id" = ' || p_ASMAY_Id || ' AND l."ASMCL_Id" = ' || p_ASMCL_Id || '
                    AND l."ASMS_Id" = ' || p_ASMS_Id || ' AND l."ECAC_ActiveFlag" = TRUE
                LEFT OUTER JOIN "Exm"."Exm_Yearly_Category" AS k ON k."EMCA_Id" = l."EMCA_Id" AND k."MI_Id" = ' || p_MI_Id || ' AND k."ASMAY_Id" = ' || p_ASMAY_Id || ' AND k."EYC_ActiveFlg" = TRUE
                LEFT OUTER JOIN "Exm"."Exm_Yearly_Category_Exams" AS j ON j."EYC_Id" = k."EYC_Id" AND j."EME_Id" = ' || p_EME_Id || ' AND j."EYCE_ActiveFlg" = TRUE
                LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS h ON h."ISMS_Id" = g."ISMS_Id" AND j."EYCE_Id" = h."EYCE_Id" AND h."EYCES_ActiveFlg" = TRUE
                ORDER BY ' || v_ordertype;
        ELSE
            v_Sqlquery := 'SELECT DISTINCT e."AMST_Id", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName", e."AMST_AdmNo", f."AMAY_RollNo", 
                e."AMST_RegistrationNo", g."ISMS_SubjectName", h."EYCES_MaxMarks", h."EYCES_MarksEntryMax", h."EYCES_MinMarks", 
                COALESCE(i."ESTM_Flg", '''') AS "ESTM_Flg", COALESCE(i."ESTM_Marks", 0) AS "ESTM_Marks", COALESCE(i."ESTM_Grade", '''') AS "ESTM_Grade", 
                COALESCE(i."ESTM_Id", 0) AS "ESTM_Id"
                FROM "Adm_M_Student" AS e
                LEFT OUTER JOIN "Exm"."Exm_Student_Marks" AS i ON e."AMST_Id" = i."AMST_Id" AND i."MI_Id" = ' || p_MI_Id || ' AND i."ASMAY_Id" = ' || p_ASMAY_Id || '
                    AND i."ASMCL_Id" = ' || p_ASMCL_Id || ' AND i."ASMS_Id" = ' || p_ASMS_Id || ' AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || ' AND i."ESTM_ActiveFlg" = TRUE
                INNER JOIN "Adm_School_Y_Student" AS f ON f."AMST_Id" = e."AMST_Id" AND e."AMST_ActiveFlag" = TRUE AND e."mi_id" = ' || p_MI_Id || ' AND e."AMST_SOL" = ''S''
                    AND f."AMAY_ActiveFlag" = TRUE AND f."ASMAY_Id" = ' || p_ASMAY_Id || ' AND f."ASMCL_Id" = ' || p_ASMCL_Id || ' AND f."ASMS_Id" = ' || p_ASMS_Id || '
                INNER JOIN "Exm"."Exm_Studentwise_Subjects" AS m ON m."AMST_Id" = f."AMST_Id" AND m."ESTSU_ActiveFlg" = TRUE AND m."mi_id" = ' || p_MI_Id || ' 
                    AND m."ASMAY_Id" = ' || p_ASMAY_Id || ' AND m."ASMCL_Id" = ' || p_ASMCL_Id || ' AND m."ASMS_Id" = ' || p_ASMS_Id || ' AND m."ISMS_Id" = ' || p_ISMS_Id || ' ' || v_EXAM_Id_WHERE_CONDITION || '
                LEFT OUTER JOIN "IVRM_Master_Subjects" AS g ON g."ISMS_Id" = ' || p_ISMS_Id || ' AND g."Mi_id" = ' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = TRUE AND g."ISMS_ExamFlag" = TRUE
                LEFT OUTER JOIN "Exm"."Exm_Category_Class" AS l ON l."MI_Id" = ' || p_MI_Id || ' AND l."ASMAY_Id" = ' || p_ASMAY_Id || ' AND l."ASMCL_Id" = ' || p_ASMCL_Id || '
                    AND l."ASMS_Id" = ' || p_ASMS_Id || ' AND l."ECAC_ActiveFlag" = TRUE
                LEFT OUTER JOIN "Exm"."Exm_Yearly_Category" AS k ON k."EMCA_Id" = l."EMCA_Id" AND k."MI_Id" = ' || p_MI_Id || ' AND k."ASMAY_Id" = ' || p_ASMAY_Id || ' AND k."EYC_ActiveFlg" = TRUE
                LEFT OUTER JOIN "Exm"."Exm_Yearly_Category_Exams" AS j ON j."EYC_Id" = k."EYC_Id" AND j."EME_Id" = ' || p_EME_Id || ' AND j."EYCE_ActiveFlg" = TRUE
                LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS h ON h."ISMS_Id" = g."ISMS_Id" AND j."EYCE_Id" = h."EYCE_Id" AND h."EYCES_ActiveFlg" = TRUE
                ORDER BY ' || v_ordertype;
        END IF;

        RETURN QUERY EXECUTE v_Sqlquery;

    ELSIF p_EMSS_Id::INT > 0 AND p_EMSE_Id = '0' THEN
        v_Sqlquery := 'SELECT DISTINCT e."AMST_Id", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName", e."AMST_AdmNo", f."AMAY_RollNo", 
            e."AMST_RegistrationNo", g."ISMS_SubjectName", i1."EYCESSS_MaxMarks" AS "EYCES_MaxMarks", i1."EYCESSS_MaxMarks" AS "EYCES_MarksEntryMax",
            i1."EYCESSS_MinMarks" AS "EYCES_MinMarks", COALESCE(SSUB."ESTMSS_Flg", '''') AS "ESTM_Flg", COALESCE(SSUB."ESTMSS_Marks", 0) AS "ESTM_Marks",
            COALESCE(SSUB."ESTMSS_Grade", '''') AS "ESTM_Grade", COALESCE(i."ESTM_Id", 0) AS "ESTM_Id" 
            FROM "Adm_M_Student" AS e 
            LEFT OUTER JOIN "Exm"."Exm_Student_Marks" AS i ON e."AMST_Id" = i."AMST_Id" AND i."MI_Id" = ' || p_MI_Id || ' AND i."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND i."ASMCL_Id" = ' || p_ASMCL_Id || ' AND i."ASMS_Id" = ' || p_ASMS_Id || ' AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || ' AND i."ESTM_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Student_Marks_SubSubject" SSUB ON SSUB."ESTM_Id" = I."ESTM_Id" AND SSUB."EMSS_Id" = ' || p_EMSS_Id || ' AND SSUB."ESTMSS_ActiveFlg" = TRUE
            INNER JOIN "Adm_School_Y_Student" AS f ON f."AMST_Id" = e."AMST_Id" AND e."AMST_ActiveFlag" = TRUE AND e."mi_id" = ' || p_MI_Id || ' AND e."AMST_SOL" = ''S'' 
                AND f."AMAY_ActiveFlag" = TRUE AND f."ASMAY_Id" = ' || p_ASMAY_Id || ' AND f."ASMCL_Id" = ' || p_ASMCL_Id || ' AND f."ASMS_Id" = ' || p_ASMS_Id || '
            INNER JOIN "Exm"."Exm_Studentwise_Subjects" AS m ON m."AMST_Id" = f."AMST_Id" AND m."ESTSU_ActiveFlg" = TRUE AND m."mi_id" = ' || p_MI_Id || ' 
                AND m."ASMAY_Id" = ' || p_ASMAY_Id || ' AND m."ASMCL_Id" = ' || p_ASMCL_Id || ' AND m."ASMS_Id" = ' || p_ASMS_Id || ' AND m."ISMS_Id" = ' || p_ISMS_Id || ' ' || v_EXAM_Id_WHERE_CONDITION || '
            LEFT OUTER JOIN "IVRM_Master_Subjects" AS g ON g."ISMS_Id" = ' || p_ISMS_Id || ' AND g."Mi_id" = ' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = TRUE AND g."ISMS_ExamFlag" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Category_Class" AS l ON l."MI_Id" = ' || p_MI_Id || ' AND l."ASMAY_Id" = ' || p_ASMAY_Id || ' AND l."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND l."ASMS_Id" = ' || p_ASMS_Id || ' AND l."ECAC_ActiveFlag" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Yearly_Category" AS k ON k."EMCA_Id" = l."EMCA_Id" AND k."MI_Id" = ' || p_MI_Id || ' AND k."ASMAY_Id" = ' || p_ASMAY_Id || ' AND k."EYC_ActiveFlg" = TRUE	 
            LEFT OUTER JOIN "Exm"."Exm_Yearly_Category_Exams" AS j ON j."EYC_Id" = k."EYC_Id" AND j."EME_Id" = ' || p_EME_Id || ' AND j."EYCE_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS h ON h."ISMS_Id" = g."ISMS_Id" AND j."EYCE_Id" = h."EYCE_Id" AND h."EYCES_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" AS I1 ON I1."EYCES_Id" = h."EYCES_Id" AND I1."EYCESSS_ActiveFlg" = TRUE AND I1."EMSS_Id" = ' || p_EMSS_Id || '
            LEFT OUTER JOIN "Exm"."Exm_Master_SubSubject" J1 ON J1."EMSS_Id" = I1."EMSS_Id" AND J1."MI_Id" = ' || p_MI_Id || '
            ORDER BY ' || v_ordertype;

        RETURN QUERY EXECUTE v_Sqlquery;

    ELSIF p_EMSS_Id = '0' AND p_EMSE_Id::INT > 0 THEN
        v_Sqlquery := 'SELECT DISTINCT e."AMST_Id", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName", e."AMST_AdmNo", f."AMAY_RollNo", 
            e."AMST_RegistrationNo", g."ISMS_SubjectName", i1."EYCESSS_MaxMarks" AS "EYCES_MaxMarks", i1."EYCESSS_MaxMarks" AS "EYCES_MarksEntryMax", 
            i1."EYCESSS_MinMarks" AS "EYCES_MinMarks", COALESCE(SSUB."ESTMSS_Flg", '''') AS "ESTM_Flg", COALESCE(SSUB."ESTMSS_Marks", 0) AS "ESTM_Marks",
            COALESCE(SSUB."ESTMSS_Grade", '''') AS "ESTM_Grade", COALESCE(i."ESTM_Id", 0) AS "ESTM_Id"
            FROM "Adm_M_Student" AS e 
            LEFT OUTER JOIN "Exm"."Exm_Student_Marks" AS i ON e."AMST_Id" = i."AMST_Id" AND i."MI_Id" = ' || p_MI_Id || ' AND i."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND i."ASMCL_Id" = ' || p_ASMCL_Id || ' AND i."ASMS_Id" = ' || p_ASMS_Id || ' AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || ' AND i."ESTM_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Student_Marks_SubSubject" SSUB ON SSUB."ESTM_Id" = I."ESTM_Id" AND SSUB."EMSE_Id" = ' || p_EMSE_Id || ' AND SSUB."ESTMSS_ActiveFlg" = TRUE
            INNER JOIN "Adm_School_Y_Student" AS f ON f."AMST_Id" = e."AMST_Id" AND e."AMST_ActiveFlag" = TRUE AND e."mi_id" = ' || p_MI_Id || ' AND e."AMST_SOL" = ''S'' 
                AND f."AMAY_ActiveFlag" = TRUE AND f."ASMAY_Id" = ' || p_ASMAY_Id || ' AND f."ASMCL_Id" = ' || p_ASMCL_Id || ' AND f."ASMS_Id" = ' || p_ASMS_Id || '
            INNER JOIN "Exm"."Exm_Studentwise_Subjects" AS m ON m."AMST_Id" = f."AMST_Id" AND m."ESTSU_ActiveFlg" = TRUE AND m."mi_id" = ' || p_MI_Id || ' 
                AND m."ASMAY_Id" = ' || p_ASMAY_Id || ' AND m."ASMCL_Id" = ' || p_ASMCL_Id || ' AND m."ASMS_Id" = ' || p_ASMS_Id || ' AND m."ISMS_Id" = ' || p_ISMS_Id || ' ' || v_EXAM_Id_WHERE_CONDITION || '
            LEFT OUTER JOIN "IVRM_Master_Subjects" AS g ON g."ISMS_Id" = ' || p_ISMS_Id || ' AND g."Mi_id" = ' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = TRUE AND g."ISMS_ExamFlag" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Category_Class" AS l ON l."MI_Id" = ' || p_MI_Id || ' AND l."ASMAY_Id" = ' || p_ASMAY_Id || ' AND l."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND l."ASMS_Id" = ' || p_ASMS_Id || ' AND l."ECAC_ActiveFlag" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Yearly_Category" AS k ON k."EMCA_Id" = l."EMCA_Id" AND k."MI_Id" = ' || p_MI_Id || ' AND k."ASMAY_Id" = ' || p_ASMAY_Id || ' AND k."EYC_ActiveFlg" = TRUE	 
            LEFT OUTER JOIN "Exm"."Exm_Yearly_Category_Exams" AS j ON j."EYC_Id" = k."EYC_Id" AND j."EME_Id" = ' || p_EME_Id || ' AND j."EYCE_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS h ON h."ISMS_Id" = g."ISMS_Id" AND j."EYCE_Id" = h."EYCE_Id" AND h."EYCES_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" AS I1 ON I1."EYCES_Id" = h."EYCES_Id" AND I1."EYCESSS_ActiveFlg" = TRUE AND I1."EMSE_Id" = ' || p_EMSE_Id || '
            LEFT OUTER JOIN "Exm"."Exm_Master_SubExam" J1 ON J1."EMSE_Id" = I1."EMSE_Id" AND J1."MI_Id" = ' || p_MI_Id || ' 
            ORDER BY ' || v_ordertype;

        RETURN QUERY EXECUTE v_Sqlquery;

    ELSIF p_EMSS_Id::INT > 0 AND p_EMSE_Id::INT > 0 THEN
        v_Sqlquery := 'SELECT DISTINCT e."AMST_Id", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName", e."AMST_AdmNo", f."AMAY_RollNo", 
            e."AMST_RegistrationNo", g."ISMS_SubjectName", i1."EYCESSS_MaxMarks" AS "EYCES_MaxMarks", i1."EYCESSS_MaxMarks" AS "EYCES_MarksEntryMax",
            i1."EYCESSS_MinMarks" AS "EYCES_MinMarks", COALESCE(SSUB."ESTMSS_Flg", '''') AS "ESTM_Flg", COALESCE(SSUB."ESTMSS_Marks", 0) AS "ESTM_Marks",
            COALESCE(SSUB."ESTMSS_Grade", '''') AS "ESTM_Grade", COALESCE(i."ESTM_Id", 0) AS "ESTM_Id"
            FROM "Adm_M_Student" AS e
            LEFT OUTER JOIN "Exm"."Exm_Student_Marks" AS i ON e."AMST_Id" = i."AMST_Id" AND i."MI_Id" = ' || p_MI_Id || ' AND i."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND i."ASMCL_Id" = ' || p_ASMCL_Id || ' AND i."ASMS_Id" = ' || p_ASMS_Id || ' AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || ' AND i."ESTM_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Student_Marks_SubSubject" SSUB ON SSUB."ESTM_Id" = I."ESTM_Id" AND SSUB."EMSE_Id" = ' || p_EMSE_Id || ' AND SSUB."EMSS_Id" = ' || p_EMSS_Id || ' AND SSUB."ESTMSS_ActiveFlg" = TRUE
            INNER JOIN "Adm_School_Y_Student" AS f ON f."AMST_Id" = e."AMST_Id" AND e."AMST_ActiveFlag" = TRUE AND e."mi_id" = ' || p_MI_Id || ' AND e."AMST_SOL" = ''S''
                AND f."AMAY_ActiveFlag" = TRUE AND f."ASMAY_Id" = ' || p_ASMAY_Id || ' AND f."ASMCL_Id" = ' || p_ASMCL_Id || ' AND f."ASMS_Id" = ' || p_ASMS_Id || '
            INNER JOIN "Exm"."Exm_Studentwise_Subjects" AS m ON m."AMST_Id" = f."AMST_Id" AND m."ESTSU_ActiveFlg" = TRUE AND m."mi_id" = ' || p_MI_Id || ' 
                AND m."ASMAY_Id" = ' || p_ASMAY_Id || ' AND m."ASMCL_Id" = ' || p_ASMCL_Id || ' AND m."ASMS_Id" = ' || p_ASMS_Id || ' AND m."ISMS_Id" = ' || p_ISMS_Id || ' ' || v_EXAM_Id_WHERE_CONDITION || '
            LEFT OUTER JOIN "IVRM_Master_Subjects" AS g ON g."ISMS_Id" = ' || p_ISMS_Id || ' AND g."Mi_id" = ' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = TRUE AND g."ISMS_ExamFlag" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Category_Class" AS l ON l."MI_Id" = ' || p_MI_Id || ' AND l."ASMAY_Id" = ' || p_ASMAY_Id || ' AND l."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                AND l."ASMS_Id" = ' || p_ASMS_Id || ' AND l."ECAC_ActiveFlag" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Yearly_Category" AS k ON k."EMCA_Id" = l."EMCA_Id" AND k."MI_Id" = ' || p_MI_Id || ' AND k."ASMAY_Id" = ' || p_ASMAY_Id || ' AND k."EYC_ActiveFlg" = TRUE	 
            LEFT OUTER JOIN "Exm"."Exm_Yearly_Category_Exams" AS j ON j."EYC_Id" = k."EYC_Id" AND j."EME_Id" = ' || p_EME_Id || ' AND j."EYCE_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS h ON h."ISMS_Id" = g."ISMS_Id" AND j."EYCE_Id" = h."EYCE_Id" AND h."EYCES_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" AS I1 ON I1."EYCES_Id" = h."EYCES_Id" AND I1."EYCESSS_ActiveFlg" = TRUE
            LEFT OUTER JOIN "Exm"."Exm_Master_SubSubject"