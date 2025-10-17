CREATE OR REPLACE FUNCTION "dbo"."HHS_Get_Exam_Subject_SubSubj_Marks_List_1"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_AMST_Id" TEXT
)
RETURNS TABLE(
    "emeid" TEXT,
    "examname" TEXT,
    "subid" TEXT,
    "flag" BOOLEAN,
    "subjectname" TEXT,
    "ssubj" TEXT,
    "SubsubjectName" TEXT,
    "obtainmarks" TEXT,
    "maxmarks" BIGINT,
    "ObtainedGrade" TEXT,
    "PassFailFlg" TEXT,
    "Marksdispaly" TEXT,
    "Gradedisplay" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_eme_id" TEXT;
    "v_eme_name" TEXT;
    "v_eme_order" TEXT;
    "v_amst_id1" TEXT;
    "v_ISMS_Id" TEXT;
    "v_Isms_SubjectName" TEXT;
    "v_ISMS_OrderFlag" TEXT;
    "v_emeid" TEXT;
    "v_EMSS_Id" TEXT;
    "v_EMSS_SubSubjectName" TEXT;
    "v_ESTMPSSS_MaxMarks" BIGINT;
    "v_ESTMPSSS_ObtainedMarks" DECIMAL(18,1);
    "v_EMSS_Order" TEXT;
    "v_ESTMPS_MaxMarks" BIGINT;
    "v_ESTMPS_ObtainedMarks" DECIMAL(18,1);
    "v_appnoappflg" TEXT;
    "v_EYCES_AplResultFlg" BOOLEAN;
    "v_ESTMPS_ObtainedGrade" TEXT;
    "v_ESTMPSSS_ObtainedGrade" TEXT;
    "v_ESTMPS_PassFailFlg" TEXT;
    "v_ESTMPSSS_PassFailFlg" TEXT;
    "v_Marksvalues" TEXT;
    "v_Gradevalues" TEXT;
    "v_EMCA_Id" TEXT;
    "v_complosry" TEXT;
    "v_complosryflag" TEXT;
    "exam_rec" RECORD;
    "subject_rec" RECORD;
    "subsubject_rec" RECORD;
BEGIN

    DROP TABLE IF EXISTS "tempSubjectsall";
    
    CREATE TEMP TABLE "tempSubjectsall" (
        "emeid" TEXT,
        "examname" TEXT,
        "subid" TEXT,
        "flag" BOOLEAN,
        "subjectname" TEXT,
        "ssubj" TEXT,
        "SubsubjectName" TEXT,
        "obtainmarks" DECIMAL(18,1),
        "maxmarks" BIGINT,
        "ObtainedGrade" TEXT,
        "PassFailFlg" TEXT,
        "Marksdispaly" TEXT,
        "Gradedisplay" TEXT,
        "complusoryflag" TEXT
    );

    SELECT DISTINCT a."EMCA_Id" INTO "v_EMCA_Id"
    FROM "exm"."Exm_Master_Category" a 
    INNER JOIN "exm"."Exm_Category_Class" b ON a."EMCA_Id" = b."EMCA_Id" 
    WHERE a."MI_Id" = "p_MI_Id"
    AND b."MI_Id" = "p_MI_Id" 
    AND b."ASMAY_Id" = "p_ASMAY_Id" 
    AND b."ASMCL_Id" = "p_ASMCL_Id" 
    AND b."ASMS_Id" = "p_ASMS_Id" 
    AND a."EMCA_ActiveFlag" = 1 
    AND b."ECAC_ActiveFlag" = 1;

    FOR "exam_rec" IN 
        SELECT DISTINCT d."eme_id", d."EME_ExamName", d."EME_ExamOrder", g."AMST_Id" 
        FROM "Exm"."Exm_Category_Class" a,
             "exm"."Exm_Yearly_Category" b,
             "Exm"."Exm_Yearly_Category_Exams" c,
             "Exm"."Exm_Master_Exam" d,
             "exm"."Exm_Yrly_Cat_Exams_Subwise" e,
             "exm"."Exm_Student_Marks_Process" g,
             "dbo"."adm_school_Y_student" f,
             "dbo"."Adm_M_Student" h 
        WHERE c."EYC_Id" = b."EYC_Id" 
        AND "EYC_ActiveFlg" = 1 
        AND "EYCE_ActiveFlg" = 1 
        AND d."EME_Id" = c."EME_Id" 
        AND d."EME_ActiveFlag" = 1 
        AND a."MI_Id" = "p_MI_Id" 
        AND a."ASMAY_Id" = "p_ASMAY_Id"
        AND a."ASMCL_Id" = "p_ASMCL_Id" 
        AND "ECAC_ActiveFlag" = 1 
        AND a."ASMS_Id" = "p_ASMS_Id" 
        AND a."EMCA_Id" = b."EMCA_Id" 
        AND b."MI_Id" = "p_MI_Id" 
        AND b."ASMAY_Id" = "p_ASMAY_Id" 
        AND g."amst_id" = f."amst_id" 
        AND h."AMST_Id" = f."AMST_Id" 
        AND g."AMST_Id" = "p_AMST_Id" 
        ORDER BY d."EME_ExamOrder"
    LOOP
        "v_eme_id" := "exam_rec"."eme_id";
        "v_eme_name" := "exam_rec"."EME_ExamName";
        "v_eme_order" := "exam_rec"."EME_ExamOrder";
        "v_amst_id1" := "exam_rec"."AMST_Id";

        FOR "subject_rec" IN 
            SELECT DISTINCT e."ISMS_Id", f."Isms_SubjectName", f."ISMS_OrderFlag", d."eme_id", 
                   e."EYCES_AplResultFlg", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg"
            FROM "Exm"."Exm_Category_Class" a,
                 "exm"."Exm_Yearly_Category" b,
                 "Exm"."Exm_Yearly_Category_Exams" c,
                 "Exm"."Exm_Master_Exam" d,
                 "exm"."Exm_Yrly_Cat_Exams_Subwise" e,
                 "IVRM_Master_Subjects" f,
                 "exm"."Exm_Student_Marks_Process" g,
                 "dbo"."adm_school_Y_student" h,
                 "dbo"."Adm_M_Student" i,
                 "exm"."Exm_Studentwise_Subjects" j
            WHERE c."EYC_Id" = b."EYC_Id" 
            AND "EYC_ActiveFlg" = 1 
            AND "EYCE_ActiveFlg" = 1 
            AND d."EME_Id" = c."EME_Id" 
            AND d."EME_ActiveFlag" = 1 
            AND e."EYCE_Id" = c."EYCE_Id" 
            AND e."EYCES_ActiveFlg" = 1 
            AND j."ISMS_Id" = e."ISMS_Id" 
            AND j."ASMAY_Id" = b."ASMAY_Id" 
            AND j."ASMCL_Id" = g."ASMCL_Id" 
            AND j."ASMS_Id" = g."ASMS_Id" 
            AND j."ASMAY_Id" = h."ASMAY_Id" 
            AND j."ASMCL_Id" = h."ASMCL_Id" 
            AND j."ASMS_Id" = h."ASMS_Id" 
            AND j."AMST_Id" = h."AMST_Id" 
            AND j."MI_Id" = "p_MI_Id" 
            AND j."ASMAY_Id" = "p_ASMAY_Id" 
            AND j."ASMCL_Id" = "p_ASMCL_Id" 
            AND j."ASMS_Id" = "p_ASMS_Id" 
            AND j."ESTSU_ActiveFlg" = 1 
            AND a."MI_Id" = "p_MI_Id" 
            AND a."ASMAY_Id" = "p_ASMAY_Id" 
            AND a."ASMCL_Id" = "p_ASMCL_Id" 
            AND "ECAC_ActiveFlag" = 1 
            AND a."ASMS_Id" = "p_ASMS_Id" 
            AND a."EMCA_Id" = b."EMCA_Id" 
            AND b."MI_Id" = "p_MI_Id" 
            AND b."ASMAY_Id" = "p_ASMAY_Id" 
            AND f."isms_id" = e."isms_id" 
            AND f."isms_activeflag" = 1 
            AND d."EME_Id" = "v_eme_id" 
            AND g."amst_id" = h."amst_id" 
            AND h."AMST_Id" = i."AMST_Id" 
            AND g."AMST_Id" = "v_amst_id1" 
            ORDER BY f."ISMS_OrderFlag"
        LOOP
            "v_ISMS_Id" := "subject_rec"."ISMS_Id";
            "v_Isms_SubjectName" := "subject_rec"."Isms_SubjectName";
            "v_ISMS_OrderFlag" := "subject_rec"."ISMS_OrderFlag";
            "v_emeid" := "subject_rec"."eme_id";
            "v_EYCES_AplResultFlg" := "subject_rec"."EYCES_AplResultFlg";
            "v_Marksvalues" := "subject_rec"."EYCES_MarksDisplayFlg";
            "v_Gradevalues" := "subject_rec"."EYCES_GradeDisplayFlg";

            FOR "subsubject_rec" IN 
                SELECT DISTINCT f."EMSS_Id", f."EMSS_SubSubjectName", f."EMSS_Order" 
                FROM "exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" a,
                     "exm"."Exm_Yrly_Cat_Exams_Subwise" b,
                     "exm"."Exm_Yearly_Category_Exams" c,
                     "exm"."Exm_Yearly_Category" d,
                     "exm"."Exm_Category_Class" e,
                     "exm"."Exm_Master_SubSubject" f,
                     "exm"."exm_studentwise_subjects" g
                WHERE e."MI_Id" = "p_MI_Id" 
                AND e."ASMAY_Id" = "p_ASMAY_Id" 
                AND e."ASMCL_Id" = "p_ASMCL_Id" 
                AND e."ASMS_Id" = "p_ASMS_Id" 
                AND e."ECAC_ActiveFlag" = 1 
                AND e."EMCA_Id" = d."EMCA_Id" 
                AND d."MI_Id" = "p_MI_Id" 
                AND d."ASMAY_Id" = "p_ASMAY_Id"
                AND d."EYC_ActiveFlg" = 1 
                AND c."EYC_Id" = d."EYC_Id" 
                AND c."EME_Id" = "v_emeid" 
                AND c."EYCE_ActiveFlg" = 1 
                AND b."EYCE_Id" = c."EYCE_Id" 
                AND b."ISMS_Id" = "v_ISMS_Id" 
                AND b."EYCES_ActiveFlg" = 1 
                AND a."EYCES_Id" = b."EYCES_Id" 
                AND a."EYCESSS_ActiveFlg" = 1 
                AND f."MI_Id" = "p_MI_Id" 
                AND f."EMSS_Id" = a."EMSS_Id" 
                AND f."EMSS_ActiveFlag" = 1 
                AND g."isms_id" = b."ISMS_Id" 
                AND g."MI_Id" = "p_MI_Id" 
                AND g."ASMAY_Id" = "p_ASMAY_Id" 
                AND g."ASMCL_Id" = "p_ASMCL_Id" 
                AND g."ASMS_Id" = "p_ASMS_Id" 
                AND g."amst_id" = "p_AMST_Id" 
                AND g."ESTSU_ActiveFlg" = 1 
                ORDER BY "EMSS_Order"
            LOOP
                "v_EMSS_Id" := "subsubject_rec"."EMSS_Id";
                "v_EMSS_SubSubjectName" := "subsubject_rec"."EMSS_SubSubjectName";
                "v_EMSS_Order" := "subsubject_rec"."EMSS_Order";
                
                "v_ESTMPSSS_MaxMarks" := NULL;
                "v_ESTMPSSS_ObtainedMarks" := NULL;
                "v_ESTMPSSS_ObtainedGrade" := '';
                "v_ESTMPSSS_PassFailFlg" := '';
                
                SELECT SUM(a."ESTMPSSS_MaxMarks"), SUM(a."ESTMPSSS_ObtainedMarks")
                INTO "v_ESTMPSSS_MaxMarks", "v_ESTMPSSS_ObtainedMarks"
                FROM "exm"."Exm_Student_Marks_Pro_Sub_SubSubject" a,
                     "exm"."Exm_Student_Marks_Process_Subjectwise" b 
                WHERE a."estmps_id" = b."estmps_id" 
                AND b."asmcl_id" = "p_ASMCL_Id" 
                AND b."ASMS_Id" = "p_ASMS_Id"
                AND b."ASMAY_Id" = "p_ASMAY_Id" 
                AND b."AMST_Id" = "v_amst_id1" 
                AND b."EME_Id" = "v_emeid" 
                AND a."EMSS_Id" = "v_EMSS_Id" 
                AND b."isms_id" = "v_ISMS_Id";

                INSERT INTO "tempSubjectsall" VALUES(
                    "v_eme_id", "v_eme_name", "v_ISMS_Id", "v_EYCES_AplResultFlg", 
                    "v_Isms_SubjectName", "v_EMSS_Id", "v_EMSS_SubSubjectName", 
                    "v_ESTMPSSS_ObtainedMarks", "v_ESTMPSSS_MaxMarks", 
                    "v_ESTMPSSS_ObtainedGrade", "v_ESTMPSSS_PassFailFlg", '', '', ''
                );

            END LOOP;

            "v_ESTMPS_MaxMarks" := NULL;
            "v_ESTMPS_ObtainedMarks" := NULL;
            "v_ESTMPS_ObtainedGrade" := '';
            "v_ESTMPS_PassFailFlg" := '';

            SELECT "ESTMPS_MaxMarks", "ESTMPS_ObtainedMarks", "ESTMPS_ObtainedGrade", "ESTMPS_PassFailFlg"
            INTO "v_ESTMPS_MaxMarks", "v_ESTMPS_ObtainedMarks", "v_ESTMPS_ObtainedGrade", "v_ESTMPS_PassFailFlg"
            FROM "exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "mi_id" = "p_MI_Id" 
            AND "asmcl_id" = "p_ASMCL_Id" 
            AND "ASMS_Id" = "p_ASMS_Id" 
            AND "ASMAY_Id" = "p_ASMAY_Id" 
            AND "AMST_Id" = "v_amst_id1" 
            AND "EME_Id" = "v_emeid" 
            AND "isms_id" = "v_ISMS_Id";

            "v_complosry" := '';
            "v_complosryflag" := '';

            SELECT DISTINCT a."ESG_CompulsoryFlag" INTO "v_complosry"
            FROM "exm"."Exm_Subject_Group" a 
            INNER JOIN "exm"."Exm_Subject_Group_Exams" b ON a."ESG_Id" = b."ESG_Id"
            INNER JOIN "exm"."Exm_Subject_Group_Subjects" c ON c."ESG_Id" = b."ESG_Id" AND a."ESG_Id" = c."ESG_Id" 
            WHERE a."ASMAY_Id" = "p_ASMAY_Id" 
            AND a."MI_Id" = "p_MI_Id" 
            AND "EMCA_Id" = "v_EMCA_Id" 
            AND "ESG_ExamPromotionFlag" = 'IE' 
            AND b."EME_Id" = "v_eme_id" 
            AND c."ISMS_Id" = "v_ISMS_Id"
            AND a."ESG_ActiveFlag" = 1 
            AND b."ESGE_ActiveFlag" = 1 
            AND c."ESGS_ActiveFlag" = 1;

            IF "v_complosry" = 'Y' THEN
                "v_complosryflag" := 'C';
            ELSE
                "v_complosryflag" := '';
            END IF;

            INSERT INTO "tempSubjectsall" VALUES(
                "v_eme_id", "v_eme_name", "v_ISMS_Id", "v_EYCES_AplResultFlg", 
                "v_Isms_SubjectName", '', '', "v_ESTMPS_ObtainedMarks", "v_ESTMPS_MaxMarks", 
                "v_ESTMPS_ObtainedGrade", "v_ESTMPS_PassFailFlg", "v_Marksvalues", 
                "v_Gradevalues", "v_complosryflag"
            );

        END LOOP;

    END LOOP;

    RETURN QUERY
    SELECT 
        t."emeid",
        t."examname",
        t."subid",
        t."flag",
        t."subjectname",
        t."ssubj",
        t."SubsubjectName",
        REPLACE(CAST(t."obtainmarks" AS VARCHAR(50)), '.0', '') AS "obtainmarks",
        t."maxmarks",
        t."ObtainedGrade",
        t."PassFailFlg",
        t."Marksdispaly",
        t."Gradedisplay"
    FROM "tempSubjectsall" t;

END;
$$;