CREATE OR REPLACE FUNCTION "dbo"."Exm_CCE_ConversionMarksInsert"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id BIGINT,
    p_ASMS_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_ESTMPS_Id BIGINT;
    v_EME_Id INTEGER;
    v_ExamActualMarks DECIMAL(18,2);
    v_ExamConvertedMarks DECIMAL(18,2);
    v_ExamConvertedGrade VARCHAR(10);
    v_EMCA_Id INTEGER;
    v_MarksPercentValue DECIMAL(18,2);
    v_AMST_Id BIGINT;
    v_TotalObtMarks DECIMAL(18,2);
    v_TotalConvertedMarks DECIMAL(18,2);
    v_RoundOffReqFlg BOOLEAN;
    v_MarksPerFlag VARCHAR(10);
    v_Ratio DECIMAL(18,2);
    v_Exm_Grade BIGINT;
    v_ESTMP_TotalGrade VARCHAR(60);
    rec_student RECORD;
    rec_exam RECORD;
BEGIN

    FOR rec_student IN 
        SELECT DISTINCT "AMS"."AMST_Id" 
        FROM "ADM_M_Student" "AMS" 
        INNER JOIN "Adm_School_Y_Student" "YS" ON "AMS"."AMST_Id" = "YS"."AMST_Id" 
            AND "AMS"."AMST_SOL" = 'S' 
            AND "AMS"."AMST_ActiveFlag" = 1 
            AND "YS"."AMAY_ActiveFlag" = 1 
            AND "YS"."ASMCL_Id" = p_ASMCL_Id 
            AND "YS"."ASMS_Id" = p_ASMS_Id 
            AND "YS"."ASMAY_Id" = p_ASMAY_Id
    LOOP
        v_AMST_Id := rec_student."AMST_Id";

        SELECT "EMCA_Id" INTO v_EMCA_Id 
        FROM "Exm"."Exm_Master_Category" 
        WHERE "EMCA_Id" = v_EMCA_Id 
            AND "MI_Id" = p_MI_Id 
            AND "EMCA_ActiveFlag" = 1 
            AND "EMCA_CCECheckingFlg" = 1;

        FOR rec_exam IN 
            SELECT DISTINCT "EME_Id", "ECTEX_MarksPercentValue", "ECTEX_RoundOffReqFlg", "ECTEX_MarksPerFlag"
            FROM "Exm"."EXM_CCE_TERMS" "T"
            INNER JOIN "Exm"."EXM_CCE_TERMS_Exams" "TE" ON "T"."ECT_Id" = "TE"."ECT_Id" 
            WHERE "T"."ECT_ActiveFlag" = 1 
                AND "T"."EMCA_Id" = v_EMCA_Id 
                AND "TE"."ECTEX_ActiveFlag" = 1 
                AND "ECTEX_NotApplToTotalFlg" = 0 
                AND "ECTEX_ConversionReqFlg" = 1
        LOOP
            v_EME_Id := rec_exam."EME_Id";
            v_MarksPercentValue := rec_exam."ECTEX_MarksPercentValue";
            v_RoundOffReqFlg := rec_exam."ECTEX_RoundOffReqFlg";
            v_MarksPerFlag := rec_exam."ECTEX_MarksPerFlag";

            IF (v_MarksPerFlag = 'M') THEN

                SELECT "ESTMP_TotalObtMarks", "ESTMP_TotalConvertedMarks" 
                INTO v_TotalObtMarks, v_TotalConvertedMarks
                FROM "Exm"."Exm_Student_Marks_Process" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "EME_Id" = v_EME_Id 
                    AND "ASMCL_Id" = p_ASMCL_Id 
                    AND "ASMS_Id" = p_ASMS_Id 
                    AND "AMST_Id" = v_AMST_Id;

                IF (v_TotalObtMarks = v_MarksPercentValue) THEN

                    v_ExamActualMarks := v_TotalObtMarks;

                    IF (v_RoundOffReqFlg = TRUE) THEN
                        v_ExamConvertedMarks := ROUND(v_TotalObtMarks, 0);
                    ELSE
                        v_ExamConvertedMarks := v_TotalObtMarks;
                    END IF;

                ELSIF (v_MarksPercentValue > v_TotalObtMarks) THEN

                    v_Ratio := (v_MarksPercentValue / NULLIF(v_TotalObtMarks, 0));
                    v_ExamActualMarks := v_TotalObtMarks;

                    IF (v_RoundOffReqFlg = TRUE) THEN
                        v_ExamConvertedMarks := ROUND(v_TotalObtMarks * v_Ratio, 0);
                    ELSE
                        v_ExamConvertedMarks := v_TotalObtMarks * v_Ratio;
                    END IF;

                ELSE

                    IF (v_MarksPercentValue < v_TotalObtMarks) THEN

                        v_Ratio := (v_TotalObtMarks / NULLIF(v_MarksPercentValue, 0));
                        v_ExamActualMarks := v_TotalObtMarks;

                        IF (v_RoundOffReqFlg = TRUE) THEN
                            v_ExamConvertedMarks := ROUND(v_TotalObtMarks / NULLIF(v_Ratio, 0), 0);
                        ELSE
                            v_ExamConvertedMarks := v_TotalObtMarks / NULLIF(v_Ratio, 0);
                        END IF;

                    END IF;
                END IF;

            ELSE

                IF (v_MarksPerFlag = 'P') THEN

                    v_Ratio := v_MarksPercentValue / 100;
                    v_ExamActualMarks := v_TotalObtMarks;

                    IF (v_RoundOffReqFlg = TRUE) THEN
                        v_ExamConvertedMarks := ROUND(v_TotalObtMarks * v_Ratio, 0);
                    ELSE
                        v_ExamConvertedMarks := v_TotalObtMarks * v_Ratio;
                    END IF;

                END IF;

            END IF;

            SELECT "EYCE"."EMGR_Id" INTO v_Exm_Grade
            FROM "Exm"."Exm_Category_Class" "ECC" 
            INNER JOIN "Exm"."Exm_Yearly_Category" "EYC" ON "ECC"."MI_Id" = "EYC"."MI_Id" 
                AND "ECC"."ASMAY_Id" = "EYC"."ASMAY_Id" 
                AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id" 
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id" 
            WHERE "EYC"."MI_Id" = p_MI_Id 
                AND "EYC"."ASMAY_Id" = p_ASMAY_Id 
                AND "ECC"."ASMCL_Id" = p_ASMCL_Id 
                AND "ECC"."ASMS_Id" = p_ASMS_Id 
                AND "EYCE"."EME_Id" = v_EME_Id
            LIMIT 1;

            SELECT "EMGD_Name" INTO v_ExamConvertedGrade
            FROM "Exm"."Exm_Master_Grade_Details" 
            WHERE ((v_ExamConvertedMarks BETWEEN "EMGD_From" AND "EMGD_To") 
                OR (v_ExamConvertedMarks BETWEEN "EMGD_To" AND "EMGD_From")) 
                AND "EMGR_Id" = v_Exm_Grade;

            SELECT "ESTMPPS_Id" INTO v_ESTMPS_Id
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" 
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id 
                AND "AMST_Id" = v_AMST_Id
            LIMIT 1;

            INSERT INTO "Exm"."Exm_Stu_MP_Promo_Subjectwise_Examwise"(
                "ESTMPPS_Id", "EME_Id", "ESTMPPSE_ExamActualMarks", 
                "ESTMPPSE_ExamConvertedMarks", "ESTMPPSE_ExamConvertedGrade", 
                "ESTMPPSE_ActiveFlg", "CreatedDate", "UpdatedDate"
            )
            VALUES(
                v_ESTMPS_Id, v_EME_Id, v_ExamActualMarks, 
                v_ExamConvertedMarks, v_ExamConvertedGrade, 
                1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
            );

        END LOOP;

    END LOOP;

    RETURN;

END;
$$;