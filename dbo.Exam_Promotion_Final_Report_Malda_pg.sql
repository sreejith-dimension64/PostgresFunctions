CREATE OR REPLACE FUNCTION "dbo"."Exam_Promotion_Final_Report_Malda"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FLAG TEXT
)
RETURNS TABLE(
    "MI_id" BIGINT,
    "amstid" BIGINT,
    "Admno" TEXT,
    "Studentname" TEXT,
    "ismsid" BIGINT,
    "subjectname" TEXT,
    "emeid" BIGINT,
    "examname" TEXT,
    "marks" DECIMAL(18,2),
    "grade" TEXT,
    "rank" INT,
    "emeorder" INT,
    "ismsorder" INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_STUDENTNAME TEXT;
    v_AMST_Id BIGINT;
    v_AMST_Admno TEXT;
    v_EME_Id TEXT;
    v_EME_EXAMNAME TEXT;
    v_EXAM_ORDER INT;
    v_ISMS_Id TEXT;
    v_ISMS_SUBJECTNAME TEXT;
    v_ISMS_ORDER INT;
    v_MARKSOBTAINED DECIMAL(18,2);
    v_GRADEOBTAINED TEXT;
    v_TOTALMARKSOBTAINED DECIMAL(18,2);
    v_TOTALGRADEOBTAINED TEXT;
    v_RANK INT;
    student_rec RECORD;
    exam_rec RECORD;
    subject_rec RECORD;
BEGIN

    /*---------------- GET THE STUDENT LIST     --------- */
    IF p_FLAG = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            ((CASE WHEN "AMST_FirstName"='' OR "AMST_FirstName" IS NULL THEN '' ELSE "AMST_FirstName" END)|| 
            (CASE WHEN "AMST_MiddleName"='' OR "AMST_MiddleName" IS NULL THEN '' ELSE ' ' ||"AMST_MiddleName" END)||
            (CASE WHEN "AMST_LastName"='' OR "AMST_LastName" IS NULL THEN '' ELSE ' '|| "AMST_LastName" END))::TEXT AS studentname,
            "MS"."AMST_AdmNo"::TEXT AS admno,
            ("MC"."ASMCL_ClassName" || ' '|| "MSEC"."ASMC_SectionName")::TEXT AS classsectionname,
            "MY"."ASMAY_Year"::TEXT AS yearname,
            "YS"."AMST_Id" AS amstid,
            NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, 
            NULL::DECIMAL(18,2), NULL::TEXT, NULL::INT, NULL::INT, NULL::INT
        FROM "Adm_School_Y_Student" "YS"
        INNER JOIN "Adm_M_Student" "MS" ON "YS"."AMST_Id"="MS"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "MY" ON "MY"."ASMAY_Id"="YS"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "MC" ON "MC"."ASMCL_Id"="YS"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "MSEC" ON "MSEC"."ASMS_Id"="YS"."ASMS_Id"
        WHERE "YS"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "YS"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "YS"."ASMS_Id"=p_ASMS_Id::BIGINT 
            AND "MS"."AMST_SOL"='S' AND "MS"."AMST_ActiveFlag"=1
            AND "YS"."AMAY_ActiveFlag"=1 AND "MS"."MI_Id"=p_MI_Id::BIGINT
        ORDER BY studentname;
        RETURN;
    END IF;

    /* -------- GET THE EXAM LIST -----------------*/
    IF p_FLAG = '2' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "A"."EME_Id"::BIGINT,
            "A"."EME_ExamName"::TEXT,
            "A"."EME_ExamOrder"::INT,
            NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, NULL::BIGINT, 
            NULL::TEXT, NULL::DECIMAL(18,2), NULL::TEXT, NULL::INT, NULL::INT, NULL::INT
        FROM "Exm"."Exm_Master_Exam" "A"
        INNER JOIN "EXM"."Exm_Yearly_Category_Exams" "B" ON "A"."EME_Id"="B"."EME_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category" "C" ON "C"."EYC_Id"="B"."EYC_Id" AND "C"."EYC_ActiveFlg"=1
        INNER JOIN "EXM"."Exm_Master_Category" "D" ON "D"."EMCA_Id"="C"."EMCA_Id" AND "D"."EMCA_ActiveFlag"=1
        INNER JOIN "Exm"."Exm_Category_Class" "E" ON "E"."EMCA_Id"="D"."EMCA_Id" AND "E"."ECAC_ActiveFlag"=1
        INNER JOIN "Adm_School_M_Academic_Year" "F" ON "F"."ASMAY_Id"="C"."ASMAY_Id" AND "F"."ASMAY_Id"="C"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "G" ON "G"."ASMCL_Id"="E"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "H" ON "H"."ASMS_Id"="E"."ASMS_Id"
        WHERE "B"."EYCE_ActiveFlg"=1 AND "A"."EME_ActiveFlag"=1 AND "C"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "E"."ASMAY_Id"=p_ASMAY_Id::BIGINT
            AND "E"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "E"."ASMS_Id"=p_ASMS_Id::BIGINT AND "E"."MI_Id"=p_MI_Id::BIGINT AND "C"."MI_Id"=p_MI_Id::BIGINT
        ORDER BY "A"."EME_ExamOrder";
        RETURN;
    END IF;

    /*------------ GET THE SUBJECT LIST ---------------*/
    IF p_FLAG = '3' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "F"."ISMS_Id" AS ismsid,
            "F"."ISMS_SubjectName"::TEXT AS subjectname,
            "F"."ISMS_OrderFlag"::INT,
            "E"."EYCES_AplResultFlg"::TEXT,
            NULL::BIGINT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, NULL::BIGINT, 
            NULL::TEXT, NULL::DECIMAL(18,2), NULL::TEXT, NULL::INT, NULL::INT, NULL::INT
        FROM "EXM"."Exm_Category_Class" "A"
        INNER JOIN "EXM"."Exm_Master_Category" "B" ON "A"."EMCA_Id"="B"."EMCA_Id"
        INNER JOIN "EXM"."Exm_Yearly_Category" "C" ON "C"."EMCA_Id"="B"."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "D" ON "D"."EYC_Id"="C"."EYC_Id"
        INNER JOIN "EXM"."Exm_Yrly_Cat_Exams_Subwise" "E" ON "E"."EYCE_Id"="D"."EYCE_Id"
        INNER JOIN "IVRM_Master_Subjects" "F" ON "F"."ISMS_Id"="E"."ISMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "MY" ON "MY"."ASMAY_Id"="A"."ASMAY_Id" AND "C"."ASMAY_Id"="MY"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "MC" ON "MC"."ASMCL_Id"="A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "MSEC" ON "MSEC"."ASMS_Id"="A"."ASMS_Id"
        WHERE "A"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "A"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "A"."ASMS_Id"=p_ASMS_Id::BIGINT 
            AND "C"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "A"."MI_Id"=p_MI_Id::BIGINT
            AND "F"."MI_Id"=p_MI_Id::BIGINT AND "E"."EYCES_ActiveFlg"=1 AND "E"."EYCES_ActiveFlg"=1 
            AND "C"."EYC_ActiveFlg"=1 AND "A"."ECAC_ActiveFlag"=1
        ORDER BY "E"."EYCES_AplResultFlg" DESC, "F"."ISMS_OrderFlag";
        RETURN;
    END IF;

    IF p_FLAG = '4' THEN
        CREATE TEMP TABLE IF NOT EXISTS temp_malda_exam_finalprogresscard_report (
            "MI_id" BIGINT,
            "amstid" BIGINT,
            "Admno" TEXT,
            "Studentname" TEXT,
            "ismsid" BIGINT,
            "subjectname" TEXT,
            "emeid" BIGINT,
            "examname" TEXT,
            "marks" DECIMAL(18,2),
            "grade" TEXT,
            "rank" INT,
            "emeorder" INT,
            "ismsorder" INT
        ) ON COMMIT DROP;

        DELETE FROM temp_malda_exam_finalprogresscard_report;

        FOR student_rec IN
            SELECT DISTINCT 
                (COALESCE("MS"."AMST_FirstName",'') || ' ' || COALESCE("MS"."AMST_MiddleName",'') || ' ' || COALESCE("MS"."AMST_LastName",'')) AS studentname,
                "YS"."AMST_Id",
                "MS"."AMST_AdmNo"
            FROM "Adm_School_Y_Student" "YS"
            INNER JOIN "Adm_M_Student" "MS" ON "YS"."AMST_Id"="MS"."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" "MY" ON "MY"."ASMAY_Id"="YS"."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" "MC" ON "MC"."ASMCL_Id"="YS"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" "MSEC" ON "MSEC"."ASMS_Id"="YS"."ASMS_Id"
            WHERE "YS"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "YS"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "YS"."ASMS_Id"=p_ASMS_Id::BIGINT 
                AND "MS"."AMST_SOL"='S' AND "MS"."AMST_ActiveFlag"=1
                AND "YS"."AMAY_ActiveFlag"=1 AND "MS"."MI_Id"=p_MI_Id::BIGINT
        LOOP
            v_STUDENTNAME := student_rec.studentname;
            v_AMST_Id := student_rec."AMST_Id";
            v_AMST_Admno := student_rec."AMST_AdmNo";

            FOR exam_rec IN
                SELECT DISTINCT "A"."EME_Id", "A"."EME_ExamName", "A"."EME_ExamOrder"
                FROM "Exm"."Exm_Master_Exam" "A"
                INNER JOIN "EXM"."Exm_Yearly_Category_Exams" "B" ON "A"."EME_Id"="B"."EME_Id"
                INNER JOIN "Exm"."Exm_Yearly_Category" "C" ON "C"."EYC_Id"="B"."EYC_Id" AND "C"."EYC_ActiveFlg"=1
                INNER JOIN "EXM"."Exm_Master_Category" "D" ON "D"."EMCA_Id"="C"."EMCA_Id" AND "D"."EMCA_ActiveFlag"=1
                INNER JOIN "Exm"."Exm_Category_Class" "E" ON "E"."EMCA_Id"="D"."EMCA_Id" AND "E"."ECAC_ActiveFlag"=1
                INNER JOIN "Adm_School_M_Academic_Year" "F" ON "F"."ASMAY_Id"="C"."ASMAY_Id" AND "F"."ASMAY_Id"="C"."ASMAY_Id"
                INNER JOIN "Adm_School_M_Class" "G" ON "G"."ASMCL_Id"="E"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" "H" ON "H"."ASMS_Id"="E"."ASMS_Id"
                WHERE "B"."EYCE_ActiveFlg"=1 AND "A"."EME_ActiveFlag"=1 AND "C"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "E"."ASMAY_Id"=p_ASMAY_Id::BIGINT
                    AND "E"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "E"."ASMS_Id"=p_ASMS_Id::BIGINT AND "E"."MI_Id"=p_MI_Id::BIGINT AND "C"."MI_Id"=p_MI_Id::BIGINT
                ORDER BY "A"."EME_ExamOrder"
            LOOP
                v_EME_Id := exam_rec."EME_Id"::TEXT;
                v_EME_EXAMNAME := exam_rec."EME_ExamName";
                v_EXAM_ORDER := exam_rec."EME_ExamOrder";

                FOR subject_rec IN
                    SELECT DISTINCT "A"."ISMS_Id", "G"."ISMS_SubjectName", "G"."ISMS_OrderFlag"
                    FROM "EXM"."Exm_Studentwise_Subjects" "A"
                    INNER JOIN "Adm_School_Y_Student" "B" ON "A"."AMST_Id"="B"."AMST_Id"
                    INNER JOIN "Adm_M_Student" "C" ON "C"."AMST_Id"="B"."AMST_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" "D" ON "D"."ASMAY_Id"="B"."ASMAY_Id" AND "D"."ASMAY_Id"="A"."ASMAY_Id"
                    INNER JOIN "Adm_School_M_Class" "E" ON "E"."ASMCL_Id"="B"."ASMCL_Id" AND "E"."ASMCL_Id"="A"."ASMCL_Id"
                    INNER JOIN "Adm_School_M_Section" "F" ON "F"."ASMS_Id"="B"."ASMS_Id" AND "F"."ASMS_Id"="A"."ASMS_Id"
                    INNER JOIN "IVRM_Master_Subjects" "G" ON "G"."ISMS_Id"="A"."ISMS_Id"
                    INNER JOIN "Exm"."Exm_Category_Class" "H" ON "H"."ASMAY_Id"="D"."ASMAY_Id" AND "H"."ASMCL_Id"="E"."ASMCL_Id" AND "H"."ASMS_Id"="F"."ASMS_Id" AND "H"."ECAC_ActiveFlag"=1
                    INNER JOIN "Exm"."Exm_Master_Category" "I" ON "I"."EMCA_Id"="H"."EMCA_Id" AND "I"."EMCA_ActiveFlag"=1
                    INNER JOIN "Exm"."Exm_Yearly_Category" "J" ON "J"."EMCA_Id"="I"."EMCA_Id" AND "J"."ASMAY_Id"="D"."ASMAY_Id" AND "J"."EYC_ActiveFlg"=1
                    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "K" ON "K"."EYC_Id"="J"."EYC_Id" AND "K"."EYCE_ActiveFlg"=1
                    INNER JOIN "EXM"."Exm_Yrly_Cat_Exams_Subwise" "L" ON "L"."ISMS_Id"="A"."ISMS_Id" AND "K"."EYCE_Id"="L"."EYCE_Id" AND "L"."EYCES_ActiveFlg"=1
                    WHERE "A"."AMST_Id"=v_AMST_Id AND "A"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "A"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "A"."ASMS_Id"=p_ASMS_Id::BIGINT 
                        AND "H"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "H"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "H"."ASMS_Id"=p_ASMS_Id::BIGINT
                        AND "K"."EME_Id"=v_EME_Id::BIGINT AND "B"."AMST_Id"=v_AMST_Id AND "B"."ASMAY_Id"=p_ASMAY_Id::BIGINT 
                        AND "B"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "B"."ASMS_Id"=p_ASMS_Id::BIGINT AND "B"."AMAY_ActiveFlag"=1
                        AND "C"."AMST_SOL"='S' AND "C"."AMST_ActiveFlag"=1
                LOOP
                    v_ISMS_Id := subject_rec."ISMS_Id"::TEXT;
                    v_ISMS_SUBJECTNAME := subject_rec."ISMS_SubjectName";
                    v_ISMS_ORDER := subject_rec."ISMS_OrderFlag";

                    v_MARKSOBTAINED := NULL;
                    v_GRADEOBTAINED := NULL;

                    SELECT "ESTMPS_ObtainedMarks", "ESTMPS_ObtainedGrade"
                    INTO v_MARKSOBTAINED, v_GRADEOBTAINED
                    FROM "Exm"."Exm_Student_Marks_Process_Subjectwise"
                    WHERE "MI_Id"=p_MI_Id::BIGINT AND "ASMAY_Id"=p_ASMAY_Id::BIGINT AND "ASMCL_Id"=p_ASMCL_Id::BIGINT 
                        AND "ASMS_Id"=p_ASMS_Id::BIGINT AND "EME_Id"=v_EME_Id::BIGINT
                        AND "ISMS_Id"=v_ISMS_Id::BIGINT AND "AMST_Id"=v_AMST_Id;

                    INSERT INTO temp_malda_exam_finalprogresscard_report 
                    VALUES(p_MI_Id::BIGINT, v_AMST_Id, v_AMST_Admno, v_STUDENTNAME, v_ISMS_Id::BIGINT, v_ISMS_SUBJECTNAME, 
                           v_EME_Id::BIGINT, v_EME_EXAMNAME, v_MARKSOBTAINED, v_GRADEOBTAINED, 0, v_EXAM_ORDER, v_ISMS_ORDER);

                END LOOP;

                v_TOTALMARKSOBTAINED := NULL;
                v_TOTALGRADEOBTAINED := NULL;
                v_RANK := NULL;

                SELECT "ESTMP_TotalObtMarks", "ESTMP_TotalGrade", "ESTMP_SectionRank"
                INTO v_TOTALMARKSOBTAINED, v_TOTALGRADEOBTAINED, v_RANK
                FROM "Exm"."Exm_Student_Marks_Process"
                WHERE "MI_Id"=p_MI_Id::BIGINT AND "ASMAY_Id"=p_ASMAY_Id::BIGINT AND "ASMCL_Id"=p_ASMCL_Id::BIGINT 
                    AND "ASMS_Id"=p_ASMS_Id::BIGINT AND "EME_Id"=v_EME_Id::BIGINT AND "AMST_Id"=v_AMST_Id;

                INSERT INTO temp_malda_exam_finalprogresscard_report 
                VALUES(p_MI_Id::BIGINT, v_AMST_Id, v_AMST_Admno, v_STUDENTNAME, 5000, v_EME_EXAMNAME, 
                       v_EME_Id::BIGINT, v_EME_EXAMNAME, v_TOTALMARKSOBTAINED, v_TOTALGRADEOBTAINED, v_RANK, v_EXAM_ORDER, 5000);

            END LOOP;

        END LOOP;

        RETURN QUERY
        SELECT * FROM temp_malda_exam_finalprogresscard_report 
        ORDER BY "Studentname", "emeorder", "ismsorder";
        RETURN;
    END IF;

END;
$$;