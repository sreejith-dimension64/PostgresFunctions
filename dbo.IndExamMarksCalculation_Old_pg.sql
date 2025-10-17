CREATE OR REPLACE FUNCTION "dbo"."IndExamMarksCalculation_Old"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_EME_Id integer
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_ESTMP_TotalMaxMarks decimal(10,2);
    v_ESTMP_TotalObtMarks decimal(10,2);
    v_EYCES_Id integer;
    v_EYCE_Id integer;
    v_ISMS_Id decimal(10,2);
    v_EYCES_AplResultFlg boolean;
    v_EYCES_MarksEntryMax decimal(10,2);
    v_EYCES_MaxMarks decimal(10,2);
    v_EYCES_MinMarks decimal(10,2);
    v_EMGR_Id integer;
    v_ESTM_Marks decimal(10,2);
    v_ESTM_MarksGradeFlg char(1);
    v_ESTMP_Result varchar(30);
    v_AMST_Id bigint;
    v_ESTMP_Percentage decimal(10,2);
    v_ESTMPS_ObtainedGrade varchar(30);
    v_Exm_Grade integer;
    v_ESTMP_TotalGrade varchar(30);
    v_ESTMPS_Percentage decimal(10,2);
    v_ESTMPS_MaxMarks decimal(10,2);
    v_Subject_Percentage decimal(10,2);
    v_Class_Totalmarks decimal(10,2);
    v_Class_Totalcount integer;
    v_Section_Totalmarks decimal(10,2);
    v_Section_Totalcount integer;
    v_FailCount integer;
    v_ESTMPS_PassFailFlg varchar(30);
    v_ESTMPS_ClassAverage decimal(10,2);
    v_ESTMPS_SectionAverage decimal(10,2);
    v_ESTMPS_ClassHighest decimal(10,2);
    v_ESTMPS_SectionHighest decimal(10,2);
    v_ESTMP_ClassRank integer;
    v_ESTMP_SectionRank integer;
    v_ESTM_Flg varchar(10);
    v_Absentcount integer;
    v_Sportscount integer;
    v_Medicalcount integer;
    v_Normalclassrank integer;
    v_NormalSectionrank integer;
    v_ExmConfig_RankingMethod varchar(50);
    v_Rank integer;
    v_Ratio decimal(10,2);
    v_GredeFlag varchar(5);
    v_GradeMarksPercentage decimal(10,2);
    v_RoundOffFlg boolean;
    v_EMGRS_Id integer;
    v_MI_Id bigint;
    v_ASMAY_Id bigint;
    v_ASMCL_Id bigint;
    v_ASMS_Id bigint;
    v_EME_Id integer;
    v_table_exists boolean;
BEGIN

    SELECT "ExmConfig_RankingMethod" INTO v_ExmConfig_RankingMethod 
    FROM "Exm"."exm_configuration" 
    WHERE "MI_Id" = p_MI_Id 
    LIMIT 1;

    IF (v_ExmConfig_RankingMethod = 'Dense') THEN
        v_Rank := 0;
    ELSE
        v_Rank := 1;
    END IF;

    BEGIN
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'Exm' 
            AND table_name = 'Exm_Student_Marks_Process_Subjectwise'
        ) INTO v_table_exists;

        IF v_table_exists THEN
            DELETE FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;
        END IF;

        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'Exm' 
            AND table_name = 'Exm_Student_Marks_Process'
        ) INTO v_table_exists;

        IF v_table_exists THEN
            DELETE FROM "Exm"."Exm_Student_Marks_Process" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;
        END IF;

        FOR v_AMST_Id, v_MI_Id, v_ASMAY_Id, v_ASMCL_Id, v_ASMS_Id, v_ISMS_Id, v_EME_Id, v_EYCES_AplResultFlg,
            v_EYCES_MarksEntryMax, v_EYCES_MaxMarks, v_EYCES_MinMarks, v_EMGR_Id, v_ESTM_Marks, v_ESTM_MarksGradeFlg, v_ESTM_Flg IN
        
        SELECT DISTINCT "ESM"."AMST_Id", "ESM"."MI_Id", "ESM"."ASMAY_Id", "ESM"."ASMCL_Id", "ESM"."ASMS_Id", "ESM"."ISMS_Id", 
               "ESM"."EME_Id", "EYCES_AplResultFlg", "EYCES_MarksEntryMax", "EYCES_MaxMarks", "EYCES_MinMarks", 
               "EYCES"."EMGR_Id", "ESM"."ESTM_Marks", "ESM"."ESTM_MarksGradeFlg", "ESTM_Flg"
        FROM "Adm_M_Student" AS f
        JOIN "Adm_School_Y_Student" AS h ON h."AMST_Id" = f."AMST_Id" 
            AND f."AMST_ActiveFlag" = 1 AND f."AMST_SOL" = 'S' 
            AND h."AMAY_ActiveFlag" = 1 AND h."ASMAY_Id" = p_ASMAY_Id 
            AND h."ASMCL_Id" = p_ASMCL_Id AND h."ASMS_Id" = p_ASMS_Id AND f."mi_id" = p_MI_Id
        INNER JOIN "Exm"."Exm_Category_Class" "ECC" ON "ECC"."MI_Id" = p_MI_Id AND "ECC"."ASMAY_Id" = p_ASMAY_Id
        INNER JOIN "Exm"."Exm_Yearly_Category" "EYC" ON "EYC"."MI_Id" = p_MI_Id 
            AND "EYC"."ASMAY_Id" = p_ASMAY_Id AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id"
        INNER JOIN "Exm"."Exm_Student_Marks" "ESM" ON "ESM"."AMST_Id" = f."AMST_Id" 
            AND "ESM"."ISMS_Id" = "EYCES"."ISMS_Id" AND "ESM"."MI_Id" = "EYC"."MI_Id" 
            AND "ESM"."EME_Id" = "EYCE"."EME_Id" AND "ESM"."ASMAY_Id" = "ECC"."ASMAY_Id"
            AND "ESM"."ASMS_Id" = "ECC"."ASMS_Id" AND "ESM"."ASMCL_Id" = "ECC"."ASMCL_Id"
        JOIN "Exm"."Exm_Studentwise_Subjects" AS n ON n."ISMS_Id" = "EYCES"."ISMS_Id" 
            AND n."AMST_Id" = f."AMST_Id" AND n."MI_Id" = p_MI_Id AND n."ASMAY_Id" = p_ASMAY_Id 
            AND n."ASMCL_Id" = p_ASMCL_Id AND n."ASMS_Id" = p_ASMS_Id
        WHERE "EYC"."MI_Id" = p_MI_Id AND "EYC"."ASMAY_Id" = p_ASMAY_Id 
            AND "ECC"."ASMCL_Id" = p_ASMCL_Id AND "ECC"."ASMS_Id" = p_ASMS_Id AND "EYCE"."EME_Id" = p_EME_Id
        ORDER BY "ESM"."AMST_Id"
        
        LOOP
            IF (v_EYCES_MaxMarks > v_EYCES_MarksEntryMax) THEN
                v_Ratio := (v_EYCES_MaxMarks / v_EYCES_MarksEntryMax);
                v_ESTM_Marks := v_ESTM_Marks * v_Ratio;
            ELSIF (v_EYCES_MaxMarks < v_EYCES_MarksEntryMax) THEN
                v_Ratio := (v_EYCES_MarksEntryMax / v_EYCES_MaxMarks);
                v_ESTM_Marks := v_ESTM_Marks / v_Ratio;
            ELSIF (v_EYCES_MaxMarks = v_EYCES_MarksEntryMax) THEN
                v_ESTM_Marks := v_ESTM_Marks;
            END IF;

            SELECT "ExmConfig_RoundoffFlag" INTO v_RoundOffFlg 
            FROM "Exm"."Exm_Configuration" 
            WHERE "MI_Id" = p_MI_Id 
            LIMIT 1;

            IF (v_RoundOffFlg = TRUE) THEN
                v_ESTM_Marks := ROUND(v_ESTM_Marks, 0);
            ELSIF (v_RoundOffFlg = FALSE) THEN
                v_ESTM_Marks := v_ESTM_Marks;
            END IF;

            IF ((v_EYCES_AplResultFlg = TRUE OR v_EYCES_AplResultFlg = FALSE) AND (v_ESTM_Marks < v_EYCES_MinMarks)) THEN
                v_ESTMPS_PassFailFlg := 'Fail';
            ELSIF ((v_EYCES_AplResultFlg = TRUE OR v_EYCES_AplResultFlg = FALSE) AND (v_ESTM_Marks >= v_EYCES_MinMarks)) THEN
                v_ESTMPS_PassFailFlg := 'Pass';
            END IF;

            IF (v_ESTM_Flg = 'AB') THEN
                v_ESTMPS_PassFailFlg := 'AB';
            ELSIF (v_ESTM_Flg = 'L') THEN
                v_ESTMPS_PassFailFlg := 'L';
            ELSIF (v_ESTM_Flg = 'M') THEN
                v_ESTMPS_PassFailFlg := 'M';
            END IF;

            SELECT "EMGR_MarksPerFlag" INTO v_GredeFlag 
            FROM "Exm"."Exm_Master_Grade" 
            WHERE "EMGR_Id" = v_EMGR_Id;

            IF (v_GredeFlag = 'M') THEN
                v_GradeMarksPercentage := v_ESTM_Marks;
            ELSIF (v_GredeFlag = 'P') THEN
                v_Subject_Percentage := (CAST((v_ESTM_Marks / v_EYCES_MaxMarks) * 100 AS DECIMAL(10,2)));
                v_GradeMarksPercentage := v_Subject_Percentage;
            END IF;

            v_ESTMPS_ObtainedGrade := NULL;

            SELECT "EMGD_Name" INTO v_ESTMPS_ObtainedGrade 
            FROM "Exm"."Exm_Master_Grade_Details"
            WHERE ((CAST(v_GradeMarksPercentage AS DECIMAL)) BETWEEN (CAST("EMGD_From" AS DECIMAL)) 
                   AND (CAST("EMGD_To" AS DECIMAL))) 
                   AND "EMGR_Id" = v_EMGR_Id;

            INSERT INTO "Exm"."Exm_Student_Marks_Process_Subjectwise"
            ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ISMS_Id", "EME_Id", "ESTMPS_MaxMarks", 
             "ESTMPS_ObtainedMarks", "ESTMPS_ObtainedGrade", "ESTMPS_PassFailFlg", "CreatedDate", "UpdatedDate")
            VALUES(p_MI_Id, p_ASMAY_Id, p_ASMCL_Id, p_ASMS_Id, v_AMST_Id, v_ISMS_Id, p_EME_Id, v_EYCES_MaxMarks, 
                   v_ESTM_Marks, v_ESTMPS_ObtainedGrade, v_ESTMPS_PassFailFlg, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        END LOOP;

        FOR v_MI_Id, v_ASMAY_Id, v_ASMCL_Id, v_ASMS_Id, v_ISMS_Id, v_EME_Id IN
        
        SELECT DISTINCT "ESM"."MI_Id", "ESM"."ASMAY_Id", "ESM"."ASMCL_Id", "ESM"."ASMS_Id", "ESM"."ISMS_Id", "ESM"."EME_Id"
        FROM "Exm"."Exm_Category_Class" "ECC"
        INNER JOIN "Exm"."Exm_Yearly_Category" "EYC" ON "ECC"."MI_Id" = "EYC"."MI_Id" 
            AND "ECC"."ASMAY_Id" = "EYC"."ASMAY_Id" AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id"
        INNER JOIN "Exm"."Exm_Student_Marks" "ESM" ON "ESM"."ISMS_Id" = "EYCES"."ISMS_Id"
            AND "ESM"."MI_Id" = "EYC"."MI_Id" AND "ESM"."EME_Id" = "EYCE"."EME_Id" 
            AND "ESM"."ASMAY_Id" = "ECC"."ASMAY_Id" AND "ESM"."ASMS_Id" = "ECC"."ASMS_Id" 
            AND "ESM"."ASMCL_Id" = "ECC"."ASMCL_Id"
        WHERE "EYC"."MI_Id" = p_MI_Id AND "EYC"."ASMAY_Id" = p_ASMAY_Id 
            AND "ECC"."ASMCL_Id" = p_ASMCL_Id AND "ECC"."ASMS_Id" = p_ASMS_Id AND "EYCE"."EME_Id" = p_EME_Id
        ORDER BY "ESM"."ISMS_Id"
        
        LOOP
            SELECT SUM("ESTMPS_ObtainedMarks") INTO v_Section_Totalmarks 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise"
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id
            GROUP BY "ASMCL_Id", "ASMS_Id", "ISMS_Id";

            SELECT COUNT("AMST_Id") INTO v_Section_Totalcount 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ISMS_Id" = v_ISMS_Id
                AND "ASMCL_Id" = p_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;

            v_ESTMPS_SectionAverage := v_Section_Totalmarks / NULLIF(v_Section_Totalcount, 0);

            UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            SET "ESTMPS_SectionAverage" = v_ESTMPS_SectionAverage
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id;

            SELECT SUM("ESTMPS_ObtainedMarks") INTO v_Class_Totalmarks 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id
            GROUP BY "ASMCL_Id", "ISMS_Id";

            SELECT COUNT("AMST_Id") INTO v_Class_Totalcount 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id;

            v_ESTMPS_ClassAverage := v_Class_Totalmarks / NULLIF(v_Class_Totalcount, 0);

            UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            SET "ESTMPS_ClassAverage" = v_ESTMPS_ClassAverage
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id;

            SELECT "ESTMPS_ObtainedMarks" INTO v_ESTMPS_ClassHighest 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise"
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id
            ORDER BY "ESTMPS_ObtainedMarks" DESC
            LIMIT 1;

            UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            SET "ESTMPS_ClassHighest" = v_ESTMPS_ClassHighest
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id;

            SELECT "ESTMPS_ObtainedMarks" INTO v_ESTMPS_SectionHighest 
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise"
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id
            ORDER BY "ESTMPS_ObtainedMarks" DESC
            LIMIT 1;

            UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            SET "ESTMPS_SectionHighest" = v_ESTMPS_SectionHighest
            WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id;

        END LOOP;

        FOR v_MI_Id, v_ASMAY_Id, v_ASMCL_Id, v_ASMS_Id, v_AMST_Id, v_EME_Id, v_ESTMP_TotalMaxMarks, 
            v_ESTMP_TotalObtMarks, v_FailCount, v_Absentcount, v_Medicalcount, v_Sportscount IN
        
        SELECT DISTINCT a."MI_Id", a."ASMAY_Id", a."ASMCL_Id", a."ASMS_Id", a."AMST_Id", a."EME_Id",
               SUM(a."ESTMPS_MaxMarks") AS TotalMaxMarks, SUM(a."ESTMPS_ObtainedMarks") AS TotalObtMarks,
               COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'Fail' THEN "ESTMPS_PassFailFlg" END) AS Failcount,
               COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'AB' THEN "ESTMPS_PassFailFlg" END) AS Absentcount,
               COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'M' THEN "ESTMPS_PassFailFlg" END) AS Medicalcount,
               COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'L' THEN "ESTMPS_PassFailFlg" END) AS Sportscount
        FROM "Exm"."Exm_Category_Class" AS j, "Exm"."Exm_Yearly_Category" AS k, 
             "Exm"."Exm_Yearly_Category_Exams" AS l, "Exm"."Exm_Yrly_Cat_Exams_Subwise" AS m, 
             "Exm"."Exm_Student_Marks_Process_Subjectwise" AS a
        WHERE j."ASMAY_Id" = p_ASMAY_Id AND j."ASMCL_Id" = p_ASMCL_Id AND j."ASMS_Id" = p_ASMS_Id 
            AND j."MI_Id" = p_MI_Id AND k."EMCA_Id" = j."EMCA_Id" AND k."ASMAY_Id" = p_ASMAY_Id 
            AND k."MI_Id" = p_MI_Id AND l."EYC_Id" = k."EYC_Id" AND l."EME_Id" = p_EME_Id
            AND m."EYCE_Id" = l."EYCE_Id" AND m."EYCES_ActiveFlg" = 1 AND m."EYCES_AplResultFlg" = 1
            AND a."ISMS_Id" = m."ISMS_Id" AND a."ASMCL_Id" = p_ASMCL_Id AND a."ASMS_Id" = p_ASMS_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id AND a."MI_Id" = p_MI_Id AND a."EME_Id" = p_EME_Id
        GROUP BY a."MI_Id", a."ASMAY_Id", a."ASMCL_Id", a."ASMS_Id", a."AMST_Id", a."EME_Id"
        
        LOOP
            IF (v_FailCount > 0) OR (v_Absentcount > 0) OR (v_Medicalcount > 0) OR (v_Sportscount > 0) THEN
                v_ESTMP_Result := 'Fail';
            ELSE
                v_ESTMP_Result := 'Pass';
            END IF;

            SELECT "EYCE"."EMGR_Id" INTO v_Exm_Grade
            FROM "Exm"."Exm_Category_Class" "ECC"
            INNER JOIN "Exm"."Exm_Yearly_Category" "EYC" ON "ECC"."MI_Id" = "EYC"."MI_Id" 
                AND "ECC"."ASMAY_Id" = "EYC"."ASMAY_Id" AND "ECC"."EMCA_Id" = "EYC"."EMCA_Id"
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id"
            WHERE "EYC"."MI_Id" = p_MI_Id AND "EYC"."ASMAY_Id" = p_ASMAY_Id 
                AND "ECC"."ASMCL_Id" = p_ASMCL_Id AND "ECC"."ASMS_Id" = p_ASMS_Id 
                AND "EYCE"."EME_Id" = p_EME_Id
            LIMIT 1;

            v_ESTMP_Percentage := (CAST((v_ESTMP_TotalObtMarks / v_ESTMP_TotalMaxMarks) * 100 AS DECIMAL(10,2)));

            IF (v_Absentcount > 0) OR (v_Medicalcount > 0) THEN
                v_ESTMP_TotalGrade := '';
            ELSE
                SELECT "EMGD_Name" INTO v_ESTMP_TotalGrade 
                FROM "Exm"."Exm_Master_Grade_Details"
                WHERE (v_ESTMP_Percentage BETWEEN "EMGD_From" AND "EMGD_To") 
                    AND "EMGR_Id" = v_Exm_Grade;
            END IF;

            INSERT INTO "Exm"."Exm_Student_Marks_Process"
            ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "ESTMP_TotalMaxMarks", 
             "ESTMP_TotalObtMarks", "ESTMP_Percentage", "ESTMP_TotalGrade", "ESTMP_Result", 
             "CreatedDate", "UpdatedDate")
            VALUES(p_MI_Id, p_ASMAY_Id, p_ASMCL_Id, p_ASMS_Id, v_AMST_Id, p_EME_Id, v_ESTMP_TotalMaxMarks, 
                   v_ESTMP_TotalObtMarks, v_ESTMP_Percentage, v_ESTMP_TotalGrade, v_ESTMP_Result, 
                   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        END LOOP;

        IF (v_Rank = 0) THEN
            WITH "ClassWiseRank" AS (
                SELECT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "ESTMP_Percentage",
                       DENSE_RANK() OVER(PARTITION BY "ASMCL_Id", "EME_Id" ORDER BY "ESTMP_Percentage" DESC) AS "Class_Rnk"
                FROM "Exm"."Exm_Student_Marks_Process"
                WHERE "ESTMP_Result" = 'Pass' AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "ASMCL_Id" = p_ASMCL_Id AND "EME_Id" = p_EME_Id
            )
            UPDATE "Exm"."Exm_Student_Marks_Process" B
            SET "ESTMP_ClassRank" = A."Class_Rnk"
            FROM "ClassWiseRank" A
            WHERE A."MI_Id" = B."MI_Id" AND A."ASMAY_Id" = B."ASMAY_Id" AND A."ASMCL_Id" = B."ASMCL_Id" 
                AND A."ASMS_Id" = B."