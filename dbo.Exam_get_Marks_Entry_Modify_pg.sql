CREATE OR REPLACE FUNCTION "dbo"."Exam_get_Marks_Entry_Modify"(
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_MI_Id TEXT,
    p_EME_Id TEXT,
    p_ISMS_Id TEXT,
    p_EMSS_Id TEXT,
    p_EMSE_Id TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "AMST_LastName" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "AMAY_RollNo" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "EYCES_MaxMarks" NUMERIC,
    "EYCES_MarksEntryMax" NUMERIC,
    "EYCES_MinMarks" NUMERIC,
    "ESTM_Flg" VARCHAR,
    "ESTM_Marks" NUMERIC,
    "ESTM_Grade" VARCHAR,
    "ESTM_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order TEXT;
    v_ordertype TEXT;
    v_sqlquery TEXT;
    v_EMSS_Id_int INTEGER;
    v_EMSE_Id_int INTEGER;
BEGIN
    SELECT "ExmConfig_Recordsearchtype" 
    INTO v_order
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_MI_Id::INTEGER;

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

    v_EMSS_Id_int := p_EMSS_Id::INTEGER;
    v_EMSE_Id_int := p_EMSE_Id::INTEGER;

    /* WHEN SUB SUBJECT AND SUB EXAM IS NOT THERE */
    IF v_EMSS_Id_int = 0 AND v_EMSE_Id_int = 0 THEN
        v_sqlquery := 'SELECT DISTINCT e."AMST_Id", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName", 
            e."AMST_AdmNo", f."AMAY_RollNo", e."AMST_RegistrationNo",
            g."ISMS_SubjectName", h."EYCES_MaxMarks", h."EYCES_MarksEntryMax", h."EYCES_MinMarks",
            COALESCE(i."ESTM_Flg", '''') as "ESTM_Flg", COALESCE(i."ESTM_Marks", 0) as "ESTM_Marks",
            COALESCE(i."ESTM_Grade", '''') as "ESTM_Grade", COALESCE(i."ESTM_Id", 0) as "ESTM_Id"
        FROM "Adm_M_Student" as e
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks" as i ON e."AMST_Id" = i."AMST_Id" 
            AND i."MI_Id" = ' || p_MI_Id || ' AND i."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND i."ASMCL_Id" = ' || p_ASMCL_Id || ' AND i."ASMS_Id" = ' || p_ASMS_Id || ' 
            AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || ' AND i."ESTM_ActiveFlg" = true
        INNER JOIN "Adm_School_Y_Student" as f ON f."AMST_Id" = e."AMST_Id" 
            AND e."AMST_ActiveFlag" = 1 AND e."mi_id" = ' || p_MI_Id || ' AND e."AMST_SOL" = ''S'' 
            AND f."AMAY_ActiveFlag" = 1 AND f."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND f."ASMCL_Id" = ' || p_ASMCL_Id || ' AND f."ASMS_Id" = ' || p_ASMS_Id || '
        JOIN "Exm"."Exm_Studentwise_Subjects" as m ON m."AMST_Id" = f."AMST_Id" 
            AND m."ESTSU_ActiveFlg" = 1 AND m."mi_id" = ' || p_MI_Id || ' 
            AND m."ASMAY_Id" = ' || p_ASMAY_Id || ' AND m."ASMCL_Id" = ' || p_ASMCL_Id || ' 
            AND m."ASMS_Id" = ' || p_ASMS_Id || ' AND m."ISMS_Id" = ' || p_ISMS_Id || '
        LEFT OUTER JOIN "IVRM_Master_Subjects" as g ON g."ISMS_Id" = ' || p_ISMS_Id || ' 
            AND g."Mi_id" = ' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = 1 AND g."ISMS_ExamFlag" = 1
        LEFT OUTER JOIN "Exm"."Exm_Category_Class" as l ON l."MI_Id" = ' || p_MI_Id || ' 
            AND l."ASMAY_Id" = ' || p_ASMAY_Id || ' AND l."ASMCL_Id" = ' || p_ASMCL_Id || ' 
            AND l."ASMS_Id" = ' || p_ASMS_Id || ' AND l."ECAC_ActiveFlag" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yearly_Category" as k ON k."EMCA_Id" = l."EMCA_Id" 
            AND k."MI_Id" = ' || p_MI_Id || ' AND k."ASMAY_Id" = ' || p_ASMAY_Id || ' AND k."EYC_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yearly_Category_Exams" as j ON j."EYC_Id" = k."EYC_Id" 
            AND j."EME_Id" = ' || p_EME_Id || ' AND j."EYCE_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" as h ON h."ISMS_Id" = g."ISMS_Id" 
            AND j."EYCE_Id" = h."EYCE_Id" AND h."EYCES_ActiveFlg" = 1
        ORDER BY ' || v_ordertype;

        RETURN QUERY EXECUTE v_sqlquery;

    /* WHEN SUB SUBJECT IS THERE AND SUB EXAM IS NOT THERE */
    ELSIF v_EMSS_Id_int > 0 AND v_EMSE_Id_int = 0 THEN
        v_sqlquery := 'SELECT DISTINCT e."AMST_Id", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName",
            e."AMST_AdmNo", f."AMAY_RollNo", e."AMST_RegistrationNo",
            g."ISMS_SubjectName", i1."EYCESSS_MaxMarks" as "EYCES_MaxMarks", i1."EYCESSS_MaxMarks" as "EYCES_MarksEntryMax",
            i1."EYCESSS_MinMarks" as "EYCES_MinMarks", COALESCE("SSUB"."ESTMSS_Flg", '''') as "ESTM_Flg",
            COALESCE("SSUB"."ESTMSS_Marks", 0) as "ESTM_Marks", COALESCE("SSUB"."ESTMSS_Grade", '''') as "ESTM_Grade",
            COALESCE(i."ESTM_Id", 0) as "ESTM_Id"
        FROM "Adm_M_Student" as e
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks" as i ON e."AMST_Id" = i."AMST_Id" 
            AND i."MI_Id" = ' || p_MI_Id || ' AND i."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND i."ASMCL_Id" = ' || p_ASMCL_Id || ' AND i."ASMS_Id" = ' || p_ASMS_Id || ' 
            AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || ' AND i."ESTM_ActiveFlg" = true
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks_SubSubject" "SSUB" ON "SSUB"."ESTM_Id" = i."ESTM_Id" 
            AND "SSUB"."EMSS_Id" = ' || p_EMSS_Id || '
        JOIN "Adm_School_Y_Student" as f ON f."AMST_Id" = e."AMST_Id" 
            AND e."AMST_ActiveFlag" = 1 AND e."mi_id" = ' || p_MI_Id || ' AND e."AMST_SOL" = ''S'' 
            AND f."AMAY_ActiveFlag" = 1 AND f."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND f."ASMCL_Id" = ' || p_ASMCL_Id || ' AND f."ASMS_Id" = ' || p_ASMS_Id || '
        JOIN "Exm"."Exm_Studentwise_Subjects" as m ON m."AMST_Id" = f."AMST_Id" 
            AND m."ESTSU_ActiveFlg" = 1 AND m."mi_id" = ' || p_MI_Id || ' 
            AND m."ASMAY_Id" = ' || p_ASMAY_Id || ' AND m."ASMCL_Id" = ' || p_ASMCL_Id || ' 
            AND m."ASMS_Id" = ' || p_ASMS_Id || ' AND m."ISMS_Id" = ' || p_ISMS_Id || '
        LEFT OUTER JOIN "IVRM_Master_Subjects" as g ON g."ISMS_Id" = ' || p_ISMS_Id || ' 
            AND g."Mi_id" = ' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = 1 AND g."ISMS_ExamFlag" = 1
        LEFT OUTER JOIN "Exm"."Exm_Category_Class" as l ON l."MI_Id" = ' || p_MI_Id || ' 
            AND l."ASMAY_Id" = ' || p_ASMAY_Id || ' AND l."ASMCL_Id" = ' || p_ASMCL_Id || ' 
            AND l."ASMS_Id" = ' || p_ASMS_Id || ' AND l."ECAC_ActiveFlag" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yearly_Category" as k ON k."EMCA_Id" = l."EMCA_Id" 
            AND k."MI_Id" = ' || p_MI_Id || ' AND k."ASMAY_Id" = ' || p_ASMAY_Id || ' AND k."EYC_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yearly_Category_Exams" as j ON j."EYC_Id" = k."EYC_Id" 
            AND j."EME_Id" = ' || p_EME_Id || ' AND j."EYCE_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" as h ON h."ISMS_Id" = g."ISMS_Id" 
            AND j."EYCE_Id" = h."EYCE_Id" AND h."EYCES_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" as i1 ON i1."EYCES_Id" = h."EYCES_Id" 
            AND i1."EYCESSS_ActiveFlg" = 1 AND i1."EMSS_Id" = ' || p_EMSS_Id || '
        LEFT OUTER JOIN "Exm"."Exm_Master_SubSubject" "J1" ON "J1"."EMSS_Id" = i1."EMSS_Id" 
            AND "J1"."MI_Id" = ' || p_MI_Id || '
        ORDER BY ' || v_ordertype;

        RETURN QUERY EXECUTE v_sqlquery;

    /* WHEN SUB SUBJECT IS NOT THERE AND SUB EXAM IS THERE */
    ELSIF v_EMSS_Id_int = 0 AND v_EMSE_Id_int > 0 THEN
        v_sqlquery := 'SELECT DISTINCT e."AMST_Id", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName",
            e."AMST_AdmNo", f."AMAY_RollNo", e."AMST_RegistrationNo",
            g."ISMS_SubjectName", i1."EYCESSS_MaxMarks" as "EYCES_MaxMarks", i1."EYCESSS_MaxMarks" as "EYCES_MarksEntryMax",
            i1."EYCESSS_MinMarks" as "EYCES_MinMarks", COALESCE("SSUB"."ESTMSS_Flg", '''') as "ESTM_Flg",
            COALESCE("SSUB"."ESTMSS_Marks", 0) as "ESTM_Marks", COALESCE("SSUB"."ESTMSS_Grade", '''') as "ESTM_Grade",
            COALESCE(i."ESTM_Id", 0) as "ESTM_Id"
        FROM "Adm_M_Student" as e
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks" as i ON e."AMST_Id" = i."AMST_Id" 
            AND i."MI_Id" = ' || p_MI_Id || ' AND i."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND i."ASMCL_Id" = ' || p_ASMCL_Id || ' AND i."ASMS_Id" = ' || p_ASMS_Id || ' 
            AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || ' AND i."ESTM_ActiveFlg" = true
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks_SubSubject" "SSUB" ON "SSUB"."ESTM_Id" = i."ESTM_Id" 
            AND "SSUB"."EMSE_Id" = ' || p_EMSE_Id || '
        JOIN "Adm_School_Y_Student" as f ON f."AMST_Id" = e."AMST_Id" 
            AND e."AMST_ActiveFlag" = 1 AND e."mi_id" = ' || p_MI_Id || ' AND e."AMST_SOL" = ''S'' 
            AND f."AMAY_ActiveFlag" = 1 AND f."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND f."ASMCL_Id" = ' || p_ASMCL_Id || ' AND f."ASMS_Id" = ' || p_ASMS_Id || '
        JOIN "Exm"."Exm_Studentwise_Subjects" as m ON m."AMST_Id" = f."AMST_Id" 
            AND m."ESTSU_ActiveFlg" = 1 AND m."mi_id" = ' || p_MI_Id || ' 
            AND m."ASMAY_Id" = ' || p_ASMAY_Id || ' AND m."ASMCL_Id" = ' || p_ASMCL_Id || ' 
            AND m."ASMS_Id" = ' || p_ASMS_Id || ' AND m."ISMS_Id" = ' || p_ISMS_Id || '
        LEFT OUTER JOIN "IVRM_Master_Subjects" as g ON g."ISMS_Id" = ' || p_ISMS_Id || ' 
            AND g."Mi_id" = ' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = 1 AND g."ISMS_ExamFlag" = 1
        LEFT OUTER JOIN "Exm"."Exm_Category_Class" as l ON l."MI_Id" = ' || p_MI_Id || ' 
            AND l."ASMAY_Id" = ' || p_ASMAY_Id || ' AND l."ASMCL_Id" = ' || p_ASMCL_Id || ' 
            AND l."ASMS_Id" = ' || p_ASMS_Id || ' AND l."ECAC_ActiveFlag" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yearly_Category" as k ON k."EMCA_Id" = l."EMCA_Id" 
            AND k."MI_Id" = ' || p_MI_Id || ' AND k."ASMAY_Id" = ' || p_ASMAY_Id || ' AND k."EYC_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yearly_Category_Exams" as j ON j."EYC_Id" = k."EYC_Id" 
            AND j."EME_Id" = ' || p_EME_Id || ' AND j."EYCE_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" as h ON h."ISMS_Id" = g."ISMS_Id" 
            AND j."EYCE_Id" = h."EYCE_Id" AND h."EYCES_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" as i1 ON i1."EYCES_Id" = h."EYCES_Id" 
            AND i1."EYCESSS_ActiveFlg" = 1 AND i1."EMSE_Id" = ' || p_EMSE_Id || '
        LEFT OUTER JOIN "Exm"."Exm_Master_SubExam" "J1" ON "J1"."EMSE_Id" = i1."EMSE_Id" 
            AND "J1"."MI_Id" = ' || p_MI_Id || '
        ORDER BY ' || v_ordertype;

        RETURN QUERY EXECUTE v_sqlquery;

    /* WHEN SUB SUBJECT IS THERE AND SUB EXAM IS THERE */
    ELSIF v_EMSS_Id_int > 0 AND v_EMSE_Id_int > 0 THEN
        v_sqlquery := 'SELECT DISTINCT e."AMST_Id", e."AMST_FirstName", e."AMST_MiddleName", e."AMST_LastName",
            e."AMST_AdmNo", f."AMAY_RollNo", e."AMST_RegistrationNo",
            g."ISMS_SubjectName", i1."EYCESSS_MaxMarks" as "EYCES_MaxMarks", i1."EYCESSS_MaxMarks" as "EYCES_MarksEntryMax",
            i1."EYCESSS_MinMarks" as "EYCES_MinMarks", COALESCE("SSUB"."ESTMSS_Flg", '''') as "ESTM_Flg",
            COALESCE("SSUB"."ESTMSS_Marks", 0) as "ESTM_Marks", COALESCE("SSUB"."ESTMSS_Grade", '''') as "ESTM_Grade",
            COALESCE(i."ESTM_Id", 0) as "ESTM_Id"
        FROM "Adm_M_Student" as e
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks" as i ON e."AMST_Id" = i."AMST_Id" 
            AND i."MI_Id" = ' || p_MI_Id || ' AND i."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND i."ASMCL_Id" = ' || p_ASMCL_Id || ' AND i."ASMS_Id" = ' || p_ASMS_Id || ' 
            AND i."ISMS_Id" = ' || p_ISMS_Id || ' AND i."EME_Id" = ' || p_EME_Id || ' AND i."ESTM_ActiveFlg" = true
        LEFT OUTER JOIN "Exm"."Exm_Student_Marks_SubSubject" "SSUB" ON "SSUB"."ESTM_Id" = i."ESTM_Id" 
            AND "SSUB"."EMSE_Id" = ' || p_EMSE_Id || ' AND "SSUB"."EMSS_Id" = ' || p_EMSS_Id || '
        JOIN "Adm_School_Y_Student" as f ON f."AMST_Id" = e."AMST_Id" 
            AND e."AMST_ActiveFlag" = 1 AND e."mi_id" = ' || p_MI_Id || ' AND e."AMST_SOL" = ''S'' 
            AND f."AMAY_ActiveFlag" = 1 AND f."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND f."ASMCL_Id" = ' || p_ASMCL_Id || ' AND f."ASMS_Id" = ' || p_ASMS_Id || '
        JOIN "Exm"."Exm_Studentwise_Subjects" as m ON m."AMST_Id" = f."AMST_Id" 
            AND m."ESTSU_ActiveFlg" = 1 AND m."mi_id" = ' || p_MI_Id || ' 
            AND m."ASMAY_Id" = ' || p_ASMAY_Id || ' AND m."ASMCL_Id" = ' || p_ASMCL_Id || ' 
            AND m."ASMS_Id" = ' || p_ASMS_Id || ' AND m."ISMS_Id" = ' || p_ISMS_Id || '
        LEFT OUTER JOIN "IVRM_Master_Subjects" as g ON g."ISMS_Id" = ' || p_ISMS_Id || ' 
            AND g."Mi_id" = ' || p_MI_Id || ' AND g."ISMS_ActiveFlag" = 1 AND g."ISMS_ExamFlag" = 1
        LEFT OUTER JOIN "Exm"."Exm_Category_Class" as l ON l."MI_Id" = ' || p_MI_Id || ' 
            AND l."ASMAY_Id" = ' || p_ASMAY_Id || ' AND l."ASMCL_Id" = ' || p_ASMCL_Id || ' 
            AND l."ASMS_Id" = ' || p_ASMS_Id || ' AND l."ECAC_ActiveFlag" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yearly_Category" as k ON k."EMCA_Id" = l."EMCA_Id" 
            AND k."MI_Id" = ' || p_MI_Id || ' AND k."ASMAY_Id" = ' || p_ASMAY_Id || ' AND k."EYC_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yearly_Category_Exams" as j ON j."EYC_Id" = k."EYC_Id" 
            AND j."EME_Id" = ' || p_EME_Id || ' AND j."EYCE_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" as h ON h."ISMS_Id" = g."ISMS_Id" 
            AND j."EYCE_Id" = h."EYCE_Id" AND h."EYCES_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" as i1 ON i1."EYCES_Id" = h."EYCES_Id" 
            AND i1."EYCESSS_ActiveFlg" = 1
        LEFT OUTER JOIN "Exm"."Exm_Master_SubSubject" "J1" ON "J1"."EMSS_Id" = i1."EMSS_Id" 
            AND "J1"."MI_Id" = ' || p_MI_Id || '
        LEFT OUTER JOIN "Exm"."Exm_Master_SubExam" "J2" ON "J2"."EMSE_Id" = i1."EMSE_Id" 
            AND "J2"."MI_Id" = ' || p_MI_Id || '
        ORDER BY ' || v_ordertype;

        RETURN QUERY EXECUTE v_sqlquery;
    END IF;

    RETURN;
END;
$$;