CREATE OR REPLACE FUNCTION "dbo"."HHS_ProgressReport_I_to_IV"()
RETURNS TABLE(
    "eme_id" int,
    "ISMS_Id" bigint,
    "Isms_SubjectName" varchar(100),
    "eyces_id" int,
    "emss_id" int,
    "emss_SubsubjectName" varchar(100),
    "ISMS_OrderFlag" int,
    "amst_id" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_eme_id int;
    v_ISMS_Id bigint;
    v_amst_id bigint;
    v_Isms_SubjectName varchar(100);
    v_eyces_id int;
    v_emss_id int;
    v_emss_SubsubjectName varchar(100);
    v_ISMS_OrderFlag int;
    
    rec1 RECORD;
    rec2 RECORD;
    rec3 RECORD;
BEGIN
    DROP TABLE IF EXISTS "tempSubjects";
    
    CREATE TEMP TABLE "tempSubjects" (
        "eme_id" int,
        "ISMS_Id" bigint,
        "Isms_SubjectName" varchar(100),
        "eyces_id" int,
        "emss_id" int,
        "emss_SubsubjectName" varchar(100),
        "ISMS_OrderFlag" int,
        "amst_id" bigint
    );

    FOR rec1 IN
        SELECT DISTINCT d."eme_id"
        FROM "Exm"."Exm_Category_Class" a
        INNER JOIN "exm"."Exm_Yearly_Category" b ON a."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" c ON c."EYC_Id" = b."EYC_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" d ON d."EME_Id" = c."EME_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" e ON e."EYCE_Id" = c."EYCE_Id"
        INNER JOIN "exm"."Exm_Student_Marks_Process" g ON g."AMST_Id" = 5782
        INNER JOIN "dbo"."adm_school_Y_student" f ON g."amst_id" = f."amst_id"
        INNER JOIN "dbo"."Adm_M_Student" h ON h."AMST_Id" = f."AMST_Id"
        WHERE b."EYC_ActiveFlg" = 1
        AND c."EYCE_ActiveFlg" = 1
        AND d."EME_ActiveFlag" = 1
        AND a."MI_Id" = 5
        AND a."ASMAY_Id" = 3
        AND a."ASMCL_Id" = 14
        AND a."ECAC_ActiveFlag" = 1
        AND a."ASMS_Id" = 13
        AND b."MI_Id" = 5
        AND b."ASMAY_Id" = 3
    LOOP
        v_eme_id := rec1."eme_id";
        
        FOR rec2 IN
            SELECT DISTINCT e."ISMS_Id"
            FROM "Exm"."Exm_Category_Class" a
            INNER JOIN "exm"."Exm_Yearly_Category" b ON a."EMCA_Id" = b."EMCA_Id"
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" c ON c."EYC_Id" = b."EYC_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" d ON d."EME_Id" = c."EME_Id"
            INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" e ON e."EYCE_Id" = c."EYCE_Id"
            INNER JOIN "IVRM_Master_Subjects" f ON f."isms_id" = e."isms_id"
            INNER JOIN "exm"."Exm_Student_Marks_Process" g ON g."AMST_Id" = 5782
            INNER JOIN "dbo"."adm_school_Y_student" h ON g."amst_id" = h."amst_id"
            INNER JOIN "dbo"."Adm_M_Student" i ON h."AMST_Id" = i."AMST_Id"
            WHERE b."EYC_ActiveFlg" = 1
            AND c."EYCE_ActiveFlg" = 1
            AND d."EME_ActiveFlag" = 1
            AND e."EYCES_ActiveFlg" = 1
            AND a."MI_Id" = 5
            AND a."ASMAY_Id" = 3
            AND a."ASMCL_Id" = 14
            AND a."ECAC_ActiveFlag" = 1
            AND a."ASMS_Id" = 13
            AND b."MI_Id" = 5
            AND b."ASMAY_Id" = 3
            AND f."isms_activeflag" = 1
            AND d."EME_Id" = v_eme_id
        LOOP
            v_ISMS_Id := rec2."ISMS_Id";
            
            FOR rec3 IN
                SELECT DISTINCT z."eme_id", z."ISMS_Id", z."Isms_SubjectName", z."eyces_id", y."emss_id", x."emss_SubsubjectName", z."ISMS_OrderFlag", z."amst_id"
                FROM (
                    SELECT d."eme_id", e."ISMS_Id", f."Isms_SubjectName", e."EYCES_SubSubjectFlg", e."eyces_id", h."amst_id",
                           e."EYCES_SubExamFlg", f."ISMS_OrderFlag"
                    FROM "Exm"."Exm_Category_Class" a
                    INNER JOIN "exm"."Exm_Yearly_Category" b ON a."EMCA_Id" = b."EMCA_Id"
                    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" c ON c."EYC_Id" = b."EYC_Id"
                    INNER JOIN "Exm"."Exm_Master_Exam" d ON d."EME_Id" = c."EME_Id"
                    INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" e ON e."EYCE_Id" = c."EYCE_Id"
                    INNER JOIN "IVRM_Master_Subjects" f ON f."isms_id" = e."isms_id"
                    INNER JOIN "exm"."Exm_Student_Marks_Process" g ON g."AMST_Id" = 5782
                    INNER JOIN "dbo"."adm_school_Y_student" h ON g."amst_id" = h."amst_id"
                    INNER JOIN "dbo"."Adm_M_Student" i ON h."AMST_Id" = i."AMST_Id"
                    WHERE b."EYC_ActiveFlg" = 1
                    AND c."EYCE_ActiveFlg" = 1
                    AND d."EME_ActiveFlag" = 1
                    AND e."EYCES_ActiveFlg" = 1
                    AND a."MI_Id" = 5
                    AND a."ASMAY_Id" = 3
                    AND a."ASMCL_Id" = 14
                    AND a."ECAC_ActiveFlag" = 1
                    AND a."ASMS_Id" = 13
                    AND b."MI_Id" = 5
                    AND b."ASMAY_Id" = 3
                    AND e."isms_id" = v_ISMS_Id
                    AND f."isms_activeflag" = 1
                    AND d."EME_Id" = 21
                ) z
                INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise_Subsubjects" y ON z."eyces_id" = y."eyces_id"
                INNER JOIN "Exm"."Exm_master_subsubject" x ON x."emss_id" = y."emss_id"
                WHERE z."EYCES_SubSubjectFlg" = 1
                AND x."emss_activeflag" = 1
            LOOP
                INSERT INTO "tempSubjects" VALUES(
                    rec3."eme_id",
                    rec3."ISMS_Id",
                    rec3."Isms_SubjectName",
                    rec3."eyces_id",
                    rec3."emss_id",
                    rec3."emss_SubsubjectName",
                    rec3."ISMS_OrderFlag",
                    rec3."amst_id"
                );
            END LOOP;
            
        END LOOP;
        
    END LOOP;

    RETURN QUERY SELECT * FROM "tempSubjects";
END;
$$;