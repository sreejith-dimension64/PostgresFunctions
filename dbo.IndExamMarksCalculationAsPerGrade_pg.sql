CREATE OR REPLACE FUNCTION "dbo"."IndExamMarksCalculationAsPerGrade"(
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
    v_Class_TotalGradePoints decimal(10,2);
    v_Class_Totalcount integer;
    v_Section_TotalGradePoints decimal(10,2);
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
    v_ExmConfig_RankingMethod varchar(50);
    v_Rank boolean;
    v_EMGD_GradePoints decimal(10,2);
    v_ESTM_Grade varchar(5);
    v_GradePoints decimal(10,2);
    v_MI_Id bigint;
    v_ASMAY_Id bigint;
    v_ASMCL_Id bigint;
    v_ASMS_Id bigint;
    v_EME_Id integer;
    rec RECORD;
BEGIN

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'Exm' AND table_name = 'Exm_Student_Marks_Process_Subjectwise') THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id 
        AND "ASMCL_Id" = p_ASMCL_Id 
        AND "ASMS_Id" = p_ASMS_Id 
        AND "EME_Id" = p_EME_Id;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'Exm' AND table_name = 'Exm_Student_Marks_Process') THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "MI_Id" = p_MI_Id 
        AND "ASMCL_Id" = p_ASMCL_Id 
        AND "ASMS_Id" = p_ASMS_Id 
        AND "EME_Id" = p_EME_Id;
    END IF;

    SELECT "ExmConfig_RankingMethod" INTO v_ExmConfig_RankingMethod 
    FROM "Exm"."exm_configuration" 
    WHERE "MI_Id" = p_MI_Id 
    LIMIT 1;

    IF (v_ExmConfig_RankingMethod = 'Dense') THEN
        v_Rank := FALSE;
    ELSE
        v_Rank := TRUE;
    END IF;

    BEGIN

        FOR rec IN
            SELECT DISTINCT "ESM"."MI_Id", "ESM"."ASMAY_Id", "ESM"."ASMCL_Id", "ESM"."ASMS_Id", "ESM"."AMST_Id", "ESM"."ISMS_Id", "ESM"."EME_Id", "EYCES_AplResultFlg", "EYCES_MarksEntryMax",
            "EYCES_MaxMarks", "EYCES_MinMarks", "EYCES"."EMGR_Id", "EMGD"."EMGD_GradePoints", "ESM"."ESTM_MarksGradeFlg", "ESTM_Grade", "ESTM_Flg"
            FROM "Adm_M_Student" AS f
            INNER JOIN "Adm_School_Y_Student" AS h ON h."AMST_Id" = f."AMST_Id" 
                AND f."AMST_ActiveFlag" = 1 
                AND f."AMST_SOL" = 'S' 
                AND h."AMAY_ActiveFlag" = 1 
                AND h."ASMAY_Id" = p_ASMAY_Id 
                AND h."ASMCL_Id" = p_ASMCL_Id 
                AND h."ASMS_Id" = p_ASMS_Id 
                AND f."mi_id" = p_MI_Id
            INNER JOIN "Exm"."Exm_Category_Class" "ECC" ON "ECC"."MI_Id" = p_MI_Id 
                AND "ECC"."ASMAY_Id" = p_ASMAY_Id
            INNER JOIN "Exm"."Exm_Yearly_Category" "EYC" ON "ECC"."EMCA_Id" = "EYC"."EMCA_Id"
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id"
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id"
            INNER JOIN "Exm"."Exm_Master_Grade_Details" "EMGD" ON "EMGD"."EMGR_Id" = "EYCES"."EMGR_Id"
            INNER JOIN "Exm"."Exm_Student_Marks" "ESM" ON "ESM"."ISMS_Id" = "EYCES"."ISMS_Id" 
                AND "EYC"."MI_Id" = "ESM"."MI_Id" 
                AND "EYCE"."EME_Id" = "ESM"."EME_Id" 
                AND "ECC"."ASMAY_Id" = "ESM"."ASMAY_Id" 
                AND "ECC"."ASMS_Id" = "ESM"."ASMS_Id" 
                AND "ECC"."ASMCL_Id" = "ESM"."ASMCL_Id"
            WHERE "EYC"."MI_Id" = p_MI_Id 
                AND "EYC"."ASMAY_Id" = p_ASMAY_Id 
                AND "ECC"."ASMCL_Id" = p_ASMCL_Id 
                AND "ECC"."ASMS_Id" = p_ASMS_Id
                AND "EYCE"."EME_Id" = p_EME_Id 
                AND "ESM"."ESTM_MarksGradeFlg" = 'G' 
            ORDER BY "ESM"."AMST_Id"
        LOOP
            v_MI_Id := rec."MI_Id";
            v_ASMAY_Id := rec."ASMAY_Id";
            v_ASMCL_Id := rec."ASMCL_Id";
            v_ASMS_Id := rec."ASMS_Id";
            v_AMST_Id := rec."AMST_Id";
            v_ISMS_Id := rec."ISMS_Id";
            v_EME_Id := rec."EME_Id";
            v_EYCES_AplResultFlg := rec."EYCES_AplResultFlg";
            v_EYCES_MarksEntryMax := rec."EYCES_MarksEntryMax";
            v_EYCES_MaxMarks := rec."EYCES_MaxMarks";
            v_EYCES_MinMarks := rec."EYCES_MinMarks";
            v_EMGR_Id := rec."EMGR_Id";
            v_EMGD_GradePoints := rec."EMGD_GradePoints";
            v_ESTM_MarksGradeFlg := rec."ESTM_MarksGradeFlg";
            v_ESTM_Grade := rec."ESTM_Grade";
            v_ESTM_Flg := rec."ESTM_Flg";

            IF ((v_EYCES_AplResultFlg = TRUE OR v_EYCES_AplResultFlg = FALSE) AND (v_EMGD_GradePoints <= 4)) THEN
                v_ESTMPS_PassFailFlg := 'Fail';
            ELSE
                v_ESTMPS_PassFailFlg := 'Pass';
            END IF;

            IF (v_ESTM_Flg = 'AB') THEN
                v_ESTMPS_PassFailFlg := 'AB';
            ELSIF (v_ESTM_Flg = 'L') THEN
                v_ESTMPS_PassFailFlg := 'L';
            ELSIF (v_ESTM_Flg = 'M') THEN
                v_ESTMPS_PassFailFlg := 'M';
            END IF;

            INSERT INTO "Exm"."Exm_Student_Marks_Process_Subjectwise"
            ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ISMS_Id", "EME_Id", "ESTMPS_MaxMarks", "ESTMPS_ObtainedGrade", "ESTMPS_PassFailFlg", "CreatedDate", "UpdatedDate")
            VALUES(v_MI_Id, v_ASMAY_Id, v_ASMCL_Id, v_ASMS_Id, v_AMST_Id, v_ISMS_Id, v_EME_Id, v_EYCES_MaxMarks, v_ESTM_Grade, v_ESTMPS_PassFailFlg, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        END LOOP;

        SELECT SUM("EMGD"."EMGD_GradePoints") * 10 INTO v_Section_TotalGradePoints
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS"
        INNER JOIN "Exm"."Exm_Master_Grade_Details" "EMGD" ON "EMGD"."EMGD_Name" = "ESMPS"."ESTMPS_ObtainedGrade"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id 
            AND "EME_Id" = p_EME_Id
        GROUP BY "ASMCL_Id", "ASMS_Id", "ISMS_Id";

        SELECT COUNT("AMST_Id") INTO v_Section_Totalcount 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id 
            AND "EME_Id" = p_EME_Id;

        v_ESTMPS_SectionAverage := v_Section_TotalGradePoints / v_Section_Totalcount;

        UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ESTMPS_SectionAverage" = v_ESTMPS_SectionAverage
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id 
            AND "EME_Id" = p_EME_Id;

        SELECT SUM("EMGD"."EMGD_GradePoints") * 10 INTO v_Class_TotalGradePoints
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS"
        INNER JOIN "Exm"."Exm_Master_Grade_Details" "EMGD" ON "EMGD"."EMGD_Name" = "ESMPS"."ESTMPS_ObtainedGrade"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "EME_Id" = p_EME_Id 
        GROUP BY "ASMCL_Id", "ISMS_Id";

        SELECT COUNT("AMST_Id") INTO v_Class_Totalcount 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "EME_Id" = p_EME_Id;

        v_ESTMPS_ClassAverage := v_Class_TotalGradePoints / v_Class_Totalcount;

        UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ESTMPS_ClassAverage" = v_ESTMPS_ClassAverage
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "EME_Id" = p_EME_Id;

        SELECT "EMGD"."EMGD_GradePoints" INTO v_ESTMPS_ClassHighest
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS"
        INNER JOIN "Exm"."Exm_Master_Grade_Details" "EMGD" ON "EMGD"."EMGD_Name" = "ESMPS"."ESTMPS_ObtainedGrade"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "EME_Id" = p_EME_Id 
        ORDER BY "EMGD_GradePoints" DESC
        LIMIT 1;

        UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ESTMPS_ClassHighest" = v_ESTMPS_ClassHighest
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "EME_Id" = p_EME_Id;

        SELECT "EMGD"."EMGD_GradePoints" INTO v_ESTMPS_SectionHighest
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS"
        INNER JOIN "Exm"."Exm_Master_Grade_Details" "EMGD" ON "EMGD"."EMGD_Name" = "ESMPS"."ESTMPS_ObtainedGrade"
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id 
            AND "EME_Id" = p_EME_Id 
        ORDER BY "EMGD_GradePoints" DESC
        LIMIT 1;

        UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ESTMPS_SectionHighest" = v_ESTMPS_SectionHighest
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id 
            AND "EME_Id" = p_EME_Id;

        FOR rec IN
            SELECT DISTINCT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ESMPS"."EME_Id", 
            SUM("ESTMPS_MaxMarks") AS "TotalMaxMarks", 
            SUM("EMGD_GradePoints") AS "GradePoints",
            COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'Fail' THEN "ESTMPS_PassFailFlg" END) AS "Failcount",
            COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'AB' THEN "ESTMPS_PassFailFlg" END) AS "Absentcount",
            COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'ML' THEN "ESTMPS_PassFailFlg" END) AS "Medicalcount",
            COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'SL' THEN "ESTMPS_PassFailFlg" END) AS "Sportscount"
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS"
            INNER JOIN "Exm"."Exm_Master_Grade_Details" "EMGD" ON "ESMPS"."ESTMPS_ObtainedGrade" = "EMGD"."EMGD_Name"
            WHERE "ESMPS"."EME_Id" IN (SELECT DISTINCT "EYCE"."EME_Id" FROM "Exm"."Exm_Yearly_Category_Exams" "EYCE")
                AND "ESMPS"."ISMS_Id" IN (SELECT DISTINCT "EYCES"."ISMS_Id" FROM "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" WHERE "EYCES"."EYCES_AplResultFlg" = TRUE)
                AND "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id 
                AND "ESMPS"."EME_Id" = p_EME_Id
            GROUP BY "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ESMPS"."EME_Id", "ESTMPS_PassFailFlg"
        LOOP
            v_MI_Id := rec."MI_Id";
            v_ASMAY_Id := rec."ASMAY_Id";
            v_ASMCL_Id := rec."ASMCL_Id";
            v_ASMS_Id := rec."ASMS_Id";
            v_AMST_Id := rec."AMST_Id";
            v_EME_Id := rec."EME_Id";
            v_ESTMP_TotalMaxMarks := rec."TotalMaxMarks";
            v_GradePoints := rec."GradePoints";
            v_FailCount := rec."Failcount";
            v_Absentcount := rec."Absentcount";
            v_Medicalcount := rec."Medicalcount";
            v_Sportscount := rec."Sportscount";

            IF (v_FailCount > 0 OR v_Absentcount > 0 OR v_Medicalcount > 0 OR v_Sportscount > 0) THEN
                v_ESTMP_Result := 'Fail';
            ELSE
                v_ESTMP_Result := 'Pass';
            END IF;

            SELECT "EMGD_Name" INTO v_ESTMP_TotalGrade
            FROM "Exm"."Exm_Master_Grade_Details"
            WHERE "EMGD_GradePoints" = v_GradePoints;

            INSERT INTO "Exm"."Exm_Student_Marks_Process"
            ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "ESTMP_TotalMaxMarks", "ESTMP_TotalGrade", "ESTMP_Result", "CreatedDate", "UpdatedDate")
            VALUES(v_MI_Id, v_ASMAY_Id, v_ASMCL_Id, v_ASMS_Id, v_AMST_Id, v_EME_Id, v_ESTMP_TotalMaxMarks, v_ESTMPS_ObtainedGrade, v_ESTMP_Result, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        END LOOP;

        IF (v_Rank = FALSE) THEN

            WITH "ClassWiseRank" AS
            (
                SELECT DISTINCT "AMST_Id", "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "EME_Id", "EMGD_GradePoints", "ESTMP_Result",
                DENSE_RANK() OVER(PARTITION BY "ASMCL_Id", "EME_Id" ORDER BY "EMGD_GradePoints" DESC) AS "Class_Rnk"
                FROM "Exm"."Exm_Student_Marks_Process" "ESMP"
                INNER JOIN "Exm"."Exm_Master_Grade_Details" "EMGD" ON "ESTMP_TotalGrade" = "EMGD_Name"
                WHERE "ESTMP_Result" = 'Pass' AND "EMGD_GradePoints" > 4
            )
            UPDATE "Exm"."Exm_Student_Marks_Process" 
            SET "ESTMP_ClassRank" = A."Class_Rnk"
            FROM "ClassWiseRank" A
            INNER JOIN "Exm"."Exm_Student_Marks_Process" B ON A."MI_Id" = B."MI_Id" 
                AND A."ASMAY_Id" = B."ASMAY_Id" 
                AND A."ASMS_Id" = B."ASMS_Id" 
                AND A."AMST_Id" = B."AMST_Id" 
                AND A."EME_Id" = B."EME_Id"
            WHERE A."MI_Id" = p_MI_Id 
                AND A."ASMAY_Id" = p_ASMAY_Id 
                AND A."ASMCL_Id" = p_ASMCL_Id 
                AND A."ASMS_Id" = p_ASMS_Id 
                AND A."EME_Id" = p_EME_Id;

            WITH "SectionWiseRank" AS
            (
                SELECT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "EMGD_GradePoints",
                DENSE_RANK() OVER(PARTITION BY "ASMS_Id", "EME_Id" ORDER BY "EMGD_GradePoints" DESC) AS "Section_Rnk"
                FROM "Exm"."Exm_Student_Marks_Process" "ESMP"
                INNER JOIN "Exm"."Exm_Master_Grade_Details" "EMGD" ON "ESTMP_TotalGrade" = "EMGD_Name"
                WHERE "ESTMP_Result" = 'Pass' AND "EMGD_GradePoints" > 4
            )
            UPDATE "Exm"."Exm_Student_Marks_Process" 
            SET "ESTMP_SectionRank" = A."Section_Rnk"
            FROM "SectionWiseRank" A
            INNER JOIN "Exm"."Exm_Student_Marks_Process" B ON A."MI_Id" = B."MI_Id" 
                AND A."ASMAY_Id" = B."ASMAY_Id" 
                AND A."ASMS_Id" = B."ASMS_Id" 
                AND A."AMST_Id" = B."AMST_Id" 
                AND A."EME_Id" = B."EME_Id"
            WHERE A."MI_Id" = p_MI_Id 
                AND A."ASMAY_Id" = p_ASMAY_Id 
                AND A."ASMCL_Id" = p_ASMCL_Id 
                AND A."ASMS_Id" = p_ASMS_Id 
                AND A."EME_Id" = p_EME_Id;

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error occurred: %', SQLERRM;
            RAISE;
    END;

    RETURN;
END;
$$;