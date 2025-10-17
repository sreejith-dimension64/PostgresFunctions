CREATE OR REPLACE FUNCTION "dbo"."HHS_Get_Exam_Subject_SubSubj_Marks_List_1TEMP"(
    p_MI_Id TEXT, 
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    emeid TEXT,
    examname TEXT,
    subid TEXT,
    flag BOOLEAN,
    subjectname TEXT,
    ssubj TEXT,
    SubsubjectName TEXT,
    obtainmarks TEXT,
    maxmarks TEXT,
    ObtainedGrade TEXT,
    PassFailFlg TEXT,
    Marksdispaly TEXT,
    Gradedisplay TEXT,
    Medicalmaxmarks TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_eme_id TEXT;
    v_eme_name TEXT;
    v_eme_order TEXT;
    v_amst_id1 TEXT;
    v_ISMS_Id TEXT;
    v_Isms_SubjectName TEXT;
    v_ISMS_OrderFlag TEXT;
    v_EYCES_SubjectOrder TEXT;
    v_emeid TEXT;
    v_EMSS_Id TEXT;
    v_EMSS_SubSubjectName TEXT;
    v_ESTMPSSS_MaxMarks TEXT;
    v_ESTMPSSS_ObtainedMarks TEXT;
    v_EMSS_Order TEXT;
    v_ESTMPS_MaxMarks TEXT;
    v_ESTMPS_Medical_Marks TEXT;
    v_ESTMPS_ObtainedMarks TEXT;
    v_appnoappflg TEXT;
    v_EYCES_AplResultFlg BOOLEAN;
    v_ESTMPS_ObtainedGrade TEXT;
    v_ESTMPSSS_ObtainedGrade TEXT;
    v_ESTMPS_PassFailFlg TEXT;
    v_ESTMPSSS_PassFailFlg TEXT;
    v_Marksvalues TEXT;
    v_Gradevalues TEXT;
    
    exam_list_rec RECORD;
    exam_subject_rec RECORD;
    exam_subject_sub_subject_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS tempSubjectsall;
    
    CREATE TEMP TABLE tempSubjectsall (
        emeid TEXT,
        examname TEXT,
        subid TEXT,
        flag BOOLEAN,
        subjectname TEXT,
        ssubj TEXT,
        SubsubjectName TEXT,
        obtainmarks TEXT,
        maxmarks TEXT,
        ObtainedGrade TEXT,
        PassFailFlg TEXT,
        Marksdispaly TEXT,
        Gradedisplay TEXT,
        Medicalmaxmarks TEXT
    );
    
    FOR exam_list_rec IN
        SELECT DISTINCT d."eme_id", d."EME_ExamName", d."EME_ExamOrder", g."AMST_Id"
        FROM "Exm"."Exm_Category_Class" a
        INNER JOIN "exm"."Exm_Yearly_Category" b ON a."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" c ON c."EYC_Id" = b."EYC_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" d ON d."EME_Id" = c."EME_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" e ON e."EYCE_Id" = c."EYCE_Id"
        INNER JOIN "exm"."Exm_Student_Marks_Process" g ON 1=1
        INNER JOIN "dbo"."adm_school_Y_student" f ON g."amst_id" = f."amst_id"
        INNER JOIN "dbo"."Adm_M_Student" h ON h."AMST_Id" = f."AMST_Id"
        WHERE "EYC_ActiveFlg" = 1 
        AND "EYCE_ActiveFlg" = 1 
        AND d."EME_ActiveFlag" = 1
        AND a."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND a."ASMCL_Id" = p_ASMCL_Id 
        AND "ECAC_ActiveFlag" = 1 
        AND a."ASMS_Id" = p_ASMS_Id
        AND b."MI_Id" = p_MI_Id 
        AND b."ASMAY_Id" = p_ASMAY_Id
        AND g."AMST_Id" = p_AMST_Id
        ORDER BY d."EME_ExamOrder"
    LOOP
        v_eme_id := exam_list_rec."eme_id";
        v_eme_name := exam_list_rec."EME_ExamName";
        v_eme_order := exam_list_rec."EME_ExamOrder";
        v_amst_id1 := exam_list_rec."AMST_Id";
        
        FOR exam_subject_rec IN
            SELECT DISTINCT e."ISMS_Id", f."Isms_SubjectName", f."ISMS_OrderFlag", d."eme_id", 
                   e."EYCES_AplResultFlg", e."EYCES_MarksDisplayFlg", e."EYCES_GradeDisplayFlg",
                   e."EYCES_SubjectOrder"
            FROM "Exm"."Exm_Category_Class" a
            INNER JOIN "exm"."Exm_Yearly_Category" b ON a."EMCA_Id" = b."EMCA_Id"
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" c ON c."EYC_Id" = b."EYC_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" d ON d."EME_Id" = c."EME_Id"
            INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" e ON e."EYCE_Id" = c."EYCE_Id"
            INNER JOIN "IVRM_Master_Subjects" f ON f."isms_id" = e."isms_id"
            INNER JOIN "exm"."Exm_Student_Marks_Process" g ON 1=1
            INNER JOIN "dbo"."adm_school_Y_student" h ON g."amst_id" = h."amst_id"
            INNER JOIN "dbo"."Adm_M_Student" i ON h."AMST_Id" = i."AMST_Id"
            WHERE "EYC_ActiveFlg" = 1 
            AND "EYCE_ActiveFlg" = 1 
            AND d."EME_ActiveFlag" = 1
            AND e."EYCES_ActiveFlg" = 1 
            AND a."MI_Id" = p_MI_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND a."ASMCL_Id" = p_ASMCL_Id 
            AND "ECAC_ActiveFlag" = 1 
            AND a."ASMS_Id" = p_ASMS_Id
            AND b."MI_Id" = p_MI_Id 
            AND b."ASMAY_Id" = p_ASMAY_Id
            AND f."isms_activeflag" = 1 
            AND d."EME_Id" = v_eme_id
            AND g."AMST_Id" = v_amst_id1
            AND e."ISMS_Id" IN (
                SELECT DISTINCT "ISMS_Id" 
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "AMST_Id" = v_amst_id1 
                AND "ASMAY_Id" = p_ASMAY_Id
                AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id 
                AND "MI_Id" = p_MI_Id 
                AND "EME_Id" = v_eme_id
            )
            ORDER BY e."EYCES_SubjectOrder"
        LOOP
            v_ISMS_Id := exam_subject_rec."ISMS_Id";
            v_Isms_SubjectName := exam_subject_rec."Isms_SubjectName";
            v_ISMS_OrderFlag := exam_subject_rec."ISMS_OrderFlag";
            v_emeid := exam_subject_rec."eme_id";
            v_EYCES_AplResultFlg := exam_subject_rec."EYCES_AplResultFlg";
            v_Marksvalues := exam_subject_rec."EYCES_MarksDisplayFlg";
            v_Gradevalues := exam_subject_rec."EYCES_GradeDisplayFlg";
            v_EYCES_SubjectOrder := exam_subject_rec."EYCES_SubjectOrder";
            
            FOR exam_subject_sub_subject_rec IN
                SELECT DISTINCT f."EMSS_Id", f."EMSS_SubSubjectName", f."EMSS_Order"
                FROM "exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" a
                INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" b ON a."EYCES_Id" = b."EYCES_Id"
                INNER JOIN "exm"."Exm_Yearly_Category_Exams" c ON b."EYCE_Id" = c."EYCE_Id"
                INNER JOIN "exm"."Exm_Yearly_Category" d ON c."EYC_Id" = d."EYC_Id"
                INNER JOIN "exm"."Exm_Category_Class" e ON e."EMCA_Id" = d."EMCA_Id"
                INNER JOIN "exm"."Exm_Master_SubSubject" f ON f."EMSS_Id" = a."EMSS_Id"
                INNER JOIN "exm"."exm_studentwise_subjects" g ON g."isms_id" = b."ISMS_Id"
                WHERE e."MI_Id" = p_MI_Id 
                AND e."ASMAY_Id" = p_ASMAY_Id 
                AND e."ASMCL_Id" = p_ASMCL_Id 
                AND e."ASMS_Id" = p_ASMS_Id 
                AND e."ECAC_ActiveFlag" = 1
                AND d."MI_Id" = p_MI_Id 
                AND d."ASMAY_Id" = p_ASMAY_Id 
                AND d."EYC_ActiveFlg" = 1 
                AND c."EME_Id" = v_emeid
                AND c."EYCE_ActiveFlg" = 1 
                AND b."ISMS_Id" = v_ISMS_Id 
                AND b."EYCES_ActiveFlg" = 1
                AND a."EYCESSS_ActiveFlg" = 1 
                AND f."MI_Id" = p_MI_Id 
                AND f."EMSS_ActiveFlag" = 1 
                AND g."MI_Id" = p_MI_Id
                AND g."ASMAY_Id" = p_ASMAY_Id 
                AND g."ASMCL_Id" = p_ASMCL_Id 
                AND g."ASMS_Id" = p_ASMS_Id 
                AND g."amst_id" = p_AMST_Id 
                AND g."ESTSU_ActiveFlg" = 1
                ORDER BY f."EMSS_Order"
            LOOP
                v_EMSS_Id := exam_subject_sub_subject_rec."EMSS_Id";
                v_EMSS_SubSubjectName := exam_subject_sub_subject_rec."EMSS_SubSubjectName";
                v_EMSS_Order := exam_subject_sub_subject_rec."EMSS_Order";
                
                v_ESTMPSSS_MaxMarks := '';
                v_ESTMPSSS_ObtainedMarks := '';
                v_ESTMPSSS_ObtainedGrade := '';
                v_ESTMPSSS_PassFailFlg := '';
                
                SELECT SUM(a."ESTMPSSS_MaxMarks"), SUM(a."ESTMPSSS_ObtainedMarks"),
                       a."ESTMPSSS_ObtainedGrade", a."ESTMPSSS_PassFailFlg"
                INTO v_ESTMPSSS_MaxMarks, v_ESTMPSSS_ObtainedMarks,
                     v_ESTMPSSS_ObtainedGrade, v_ESTMPSSS_PassFailFlg
                FROM "exm"."Exm_Student_Marks_Pro_Sub_SubSubject" a
                INNER JOIN "exm"."Exm_Student_Marks_Process_Subjectwise" b ON a."estmps_id" = b."estmps_id"
                WHERE b."asmcl_id" = p_ASMCL_Id 
                AND b."ASMS_Id" = p_ASMS_Id
                AND b."ASMAY_Id" = p_ASMAY_Id 
                AND b."AMST_Id" = v_amst_id1 
                AND b."EME_Id" = v_emeid 
                AND a."EMSS_Id" = v_EMSS_Id 
                AND b."isms_id" = v_ISMS_Id
                GROUP BY a."ESTMPSSS_ObtainedGrade", a."ESTMPSSS_PassFailFlg";
                
                INSERT INTO tempSubjectsall 
                VALUES(v_eme_id, v_eme_name, v_ISMS_Id, v_EYCES_AplResultFlg, v_Isms_SubjectName, 
                       v_EMSS_Id, v_EMSS_SubSubjectName, v_ESTMPSSS_ObtainedMarks, v_ESTMPSSS_MaxMarks,
                       v_ESTMPSSS_ObtainedGrade, v_ESTMPSSS_PassFailFlg, '', '', '0');
            END LOOP;
            
            v_ESTMPS_MaxMarks := '';
            v_ESTMPS_Medical_Marks := '';
            v_ESTMPS_ObtainedMarks := '';
            v_ESTMPS_ObtainedGrade := '';
            v_ESTMPS_PassFailFlg := '';
            
            SELECT "ESTMPS_MaxMarks", "ESTMPS_ObtainedMarks", "ESTMPS_ObtainedGrade", 
                   "ESTMPS_PassFailFlg", "ESTMPS_Medical_MaxMarks"
            INTO v_ESTMPS_MaxMarks, v_ESTMPS_ObtainedMarks, v_ESTMPS_ObtainedGrade,
                 v_ESTMPS_PassFailFlg, v_ESTMPS_Medical_Marks
            FROM "exm"."Exm_Student_Marks_Process_Subjectwise"
            WHERE "mi_id" = p_MI_Id 
            AND "asmcl_id" = p_ASMCL_Id
            AND "ASMS_Id" = p_ASMS_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "AMST_Id" = v_amst_id1 
            AND "EME_Id" = v_emeid 
            AND "isms_id" = v_ISMS_Id;
            
            INSERT INTO tempSubjectsall 
            VALUES(v_eme_id, v_eme_name, v_ISMS_Id, v_EYCES_AplResultFlg, v_Isms_SubjectName,
                   '', '', v_ESTMPS_ObtainedMarks, v_ESTMPS_MaxMarks, v_ESTMPS_ObtainedGrade,
                   v_ESTMPS_PassFailFlg, v_Marksvalues, v_Gradevalues, v_ESTMPS_Medical_Marks);
        END LOOP;
    END LOOP;
    
    RETURN QUERY SELECT * FROM tempSubjectsall;
    
    DROP TABLE IF EXISTS tempSubjectsall;
    
END;
$$;