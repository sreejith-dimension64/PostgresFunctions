CREATE OR REPLACE FUNCTION "dbo"."Exam_Studentwise_Marks_Details_Promotion_New1"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "EME_Id" BIGINT,
    "GROUPNAME" TEXT,
    "DISPLAYNAME" TEXT,
    "OBTAINEDMARKS" DECIMAL(18,2),
    "MAXMARKS" DECIMAL(18,2),
    "GRADE" TEXT,
    "PASSORFAIL" TEXT,
    "EXAMATTENDED_NOTATTENDEDFLAG" TEXT,
    "ExamConductFlag" INT,
    "EMGD_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_GROUPNAME TEXT;
    v_DISPLAYNAME TEXT;
    v_GROUPORDER INT;
    v_EMCA_Id BIGINT;
    v_EYC_Id BIGINT;
    v_AMST_Id_N BIGINT;
    v_ISMS_Id_N BIGINT;
    v_EMGR_Id INT;
    v_ExamProcessRnt BIGINT;
    v_EMEID INT;
    v_EMEORDER INT;
    v_ProGroupRnt BIGINT;
    v_ROW_COUNT INT;
    v_EXAMATTENDED_NOTATTENDED_FLAG TEXT;
    rec_student RECORD;
    rec_exam RECORD;
    rec_subject RECORD;
BEGIN

    DROP TABLE IF EXISTS "BGHS_EXAM_PROMOTION_DETIAL1_N1";

    CREATE TEMP TABLE "BGHS_EXAM_PROMOTION_DETIAL1_N1" (
        "AMST_Id" BIGINT,
        "ISMS_Id" BIGINT,
        "EME_Id" BIGINT,
        "GROUPNAME" TEXT,
        "DISPLAYNAME" TEXT,
        "OBTAINEDMARKS" DECIMAL(18,2),
        "MAXMARKS" DECIMAL(18,2),
        "GRADE" TEXT,
        "PASSORFAIL" TEXT,
        "EXAMATTENDED_NOTATTENDEDFLAG" TEXT,
        "ExamConductFlag" INT,
        "EMGD_Remarks" TEXT
    );

    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND "ASMS_Id" = p_ASMS_Id::BIGINT 
        AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1;

    FOR rec_student IN
        SELECT DISTINCT "AMST_Id" 
        FROM "Adm_School_Y_Student" 
        WHERE "ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
            AND "ASMS_Id" = p_ASMS_Id::BIGINT
    LOOP
        v_AMST_Id_N := rec_student."AMST_Id";

        FOR rec_exam IN
            SELECT DISTINCT A."EME_Id" 
            FROM "Exm"."Exm_Yearly_Category_Exams" A 
            INNER JOIN "Exm"."Exm_Yearly_Category" B ON A."EYC_Id" = B."EYC_Id" 
            INNER JOIN "Exm"."Exm_Category_Class" C ON C."EMCA_Id" = B."EMCA_Id" 
            WHERE B."MI_Id" = p_MI_Id::BIGINT 
                AND B."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND A."EYC_Id" = v_EYC_Id 
                AND C."MI_Id" = p_MI_Id::BIGINT 
                AND C."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND C."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND C."ASMS_Id" = p_ASMS_Id::BIGINT 
                AND A."EYCE_ActiveFlg" = 1 
                AND B."EYC_ActiveFlg" = 1 
                AND C."ECAC_ActiveFlag" = 1
        LOOP
            v_EMEID := rec_exam."EME_Id";

            FOR rec_subject IN
                SELECT DISTINCT "ISMS_Id", CES."EMGR_Id" 
                FROM "Exm"."Exm_Category_Class" CC 
                INNER JOIN "Exm"."Exm_Yearly_Category" EYC ON CC."EMCA_Id" = EYC."EMCA_Id" 
                    AND EYC."ASMAY_Id" = CC."ASMAY_Id" 
                    AND CC."MI_Id" = EYC."MI_Id"
                INNER JOIN "Exm"."Exm_Yearly_Category_Exams" CE ON CE."EYC_Id" = EYC."EYC_Id" 
                    AND "EYCE_ActiveFlg" = 1
                INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" CES ON CES."EYCE_Id" = CE."EYCE_Id" 
                    AND CES."EYCES_ActiveFlg" = 1
                WHERE CC."MI_Id" = p_MI_Id::BIGINT 
                    AND CC."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                    AND CC."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                    AND CC."ASMS_Id" = p_ASMS_Id::BIGINT 
                    AND EYC."EYC_ActiveFlg" = 1 
                    AND CC."ECAC_ActiveFlag" = 1 
                    AND EYC."EYC_Id" = v_EYC_Id 
                    AND CC."EMCA_Id" = v_EMCA_Id 
                    AND CE."EME_Id" = v_EMEID
                    AND "ISMS_Id" IN (
                        SELECT DISTINCT "ISMS_Id" 
                        FROM "Exm"."Exm_Studentwise_Subjects" ESS 
                        WHERE ESS."AMST_Id" = v_AMST_Id_N 
                            AND ESS."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                            AND ESS."MI_Id" = p_MI_Id::BIGINT 
                            AND ESS."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                            AND ESS."ASMS_Id" = p_ASMS_Id::BIGINT 
                            AND ESS."ESTSU_ActiveFlg" = 1
                    )
            LOOP
                v_ISMS_Id_N := rec_subject."ISMS_Id";
                v_EMGR_Id := rec_subject."EMGR_Id";

                v_ROW_COUNT := 0;
                v_EXAMATTENDED_NOTATTENDED_FLAG := '';

                SELECT COUNT(*) INTO v_ROW_COUNT 
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "MI_Id" = p_MI_Id::BIGINT 
                    AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                    AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
                    AND "ASMS_Id" = p_ASMS_Id::BIGINT 
                    AND "EME_Id" = v_EMEID 
                    AND "AMST_Id" = v_AMST_Id_N 
                    AND "ISMS_Id" = v_ISMS_Id_N;

                IF (v_ROW_COUNT <> 0) THEN
                    v_EXAMATTENDED_NOTATTENDED_FLAG := 'Attendend';
                    
                    INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1_N1" (
                        "AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", 
                        "OBTAINEDMARKS", "MAXMARKS", "GRADE", "PASSORFAIL",
                        "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag", "EMGD_Remarks"
                    )
                    SELECT 
                        "AMST_Id", "ISMS_Id", "EME_Id", v_GROUPNAME, v_DISPLAYNAME, 
                        "ESTMPS_ObtainedMarks", "ESTMPS_MaxMarks", "ESTMPS_ObtainedGrade", 
                        "ESTMPS_PassFailFlg", v_EXAMATTENDED_NOTATTENDED_FLAG, 
                        1 AS "ExamConductFlag", "EMGD_Remarks"
                    FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" A 
                    LEFT JOIN "Exm"."Exm_Master_Grade_Details" B 
                        ON A."ESTMPS_ObtainedGrade" = B."EMGD_Name" 
                        AND B."EMGR_Id" = v_EMGR_Id
                    WHERE "MI_Id" = p_MI_Id::BIGINT 
                        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
                        AND "ASMS_Id" = p_ASMS_Id::BIGINT 
                        AND "EME_Id" = v_EMEID 
                        AND "AMST_Id" = v_AMST_Id_N 
                        AND "ISMS_Id" = v_ISMS_Id_N;
                ELSE
                    v_EXAMATTENDED_NOTATTENDED_FLAG := 'Not Attendend';
                    
                    INSERT INTO "BGHS_EXAM_PROMOTION_DETIAL1_N1" (
                        "AMST_Id", "ISMS_Id", "EME_Id", "GROUPNAME", "DISPLAYNAME", 
                        "OBTAINEDMARKS", "MAXMARKS", "GRADE", "PASSORFAIL",
                        "EXAMATTENDED_NOTATTENDEDFLAG", "ExamConductFlag", "EMGD_Remarks"
                    )
                    VALUES (
                        v_AMST_Id_N, v_ISMS_Id_N, v_EMEID, v_GROUPNAME, v_DISPLAYNAME, 
                        0, 0, '', '', v_EXAMATTENDED_NOTATTENDED_FLAG, 0, ''
                    );
                END IF;

            END LOOP;

        END LOOP;

    END LOOP;

    RETURN QUERY SELECT * FROM "BGHS_EXAM_PROMOTION_DETIAL1_N1";

    DROP TABLE IF EXISTS "BGHS_EXAM_PROMOTION_DETIAL1_N1";

END;
$$;