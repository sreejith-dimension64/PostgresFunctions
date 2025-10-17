CREATE OR REPLACE FUNCTION "dbo"."IndExamMarksCalculationSectionWise"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMS_Id bigint,
    p_EME_Id int
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_ESTMP_TotalMaxMarks decimal(10,2);
    v_ESTMP_TotalObtMarks decimal(10,2);
    v_EYCES_Id int;
    v_EYCE_Id int;
    v_ISMS_Id decimal(10,2);
    v_EYCES_AplResultFlg boolean;
    v_EYCES_MarksEntryMax decimal(10,2);
    v_EYCES_MaxMarks decimal(10,2);
    v_EYCES_MinMarks decimal(10,2);
    v_EMGR_Id int;
    v_ESTM_Marks decimal(10,2);
    v_ESTM_MarksGradeFlg char(1);
    v_ESTMP_Result varchar(30);
    v_AMST_Id bigint;
    v_ESTMP_Percentage decimal(10,2);
    v_ESTMPS_ObtainedGrade varchar(30);
    v_Exm_Grade int;
    v_ESTMP_TotalGrade varchar(30);
    v_ESTMPS_Percentage decimal(10,2);
    v_ESTMPS_MaxMarks decimal(10,2);
    v_Subject_Percentage decimal(10,2);
    v_Class_Totalmarks decimal(10,2);
    v_Class_Totalcount int;
    v_Section_Totalmarks decimal(10,2);
    v_Section_Totalcount int;
    v_FailCount int;
    v_ESTMPS_PassFailFlg varchar(30);
    v_ESTMPS_ClassAverage decimal(10,2);
    v_ESTMPS_SectionAverage decimal(10,2);
    v_ESTMPS_ClassHighest decimal(10,2);
    v_ESTMPS_SectionHighest decimal(10,2);
    v_ESTMP_ClassRank int;
    v_ESTMP_SectionRank int;
    v_ASMCL_Id bigint;
    v_ESTM_Flg varchar(10);
    v_Absentcount int;
    v_Sportscount int;
    v_Medicalcount int;
    v_Normalclassrank int;
    v_NormalSectionrank int;
    v_ExmConfig_RankingMethod varchar(50);
    v_Rank boolean;
    v_MI_Id bigint;
    v_ASMAY_Id bigint;
    v_ASMS_Id bigint;
    v_EME_Id int;
    rec_exmsubjectdetails RECORD;
    rec_studentmarksprocess RECORD;
BEGIN

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'Exm' AND table_name = 'Exm_Student_Marks_Process_Subjectwise') THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'Exm' AND table_name = 'Exm_Student_Marks_Process') THEN
        DELETE FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;
    END IF;

    SELECT "ExmConfig_RankingMethod" INTO v_ExmConfig_RankingMethod 
    FROM "Exm"."exm_configuration" 
    WHERE "MI_Id" = p_MI_Id 
    LIMIT 1;

    IF (v_ExmConfig_RankingMethod = 'Dense') THEN
        v_Rank := false;
    ELSE
        v_Rank := true;
    END IF;

    BEGIN

        FOR rec_exmsubjectdetails IN
            SELECT "ESM"."MI_Id", "ESM"."ASMAY_Id", "ESM"."ASMCL_Id", "ESM"."ASMS_Id", "ESM"."AMST_Id", "ESM"."ISMS_Id", 
                   "ESM"."EME_Id", "EYCES_AplResultFlg", "EYCES_MarksEntryMax", "EYCES_MaxMarks", "EYCES_MinMarks", 
                   "EYCES"."EMGR_Id", "ESM"."ESTM_Marks", "ESM"."ESTM_MarksGradeFlg", "ESM"."ESTM_Flg"
            FROM "Exm"."Exm_Category_Class" "ECC" 
            INNER JOIN "Exm"."Exm_Yearly_Category" "EYC" ON "ECC"."EMCA_Id" = "EYC"."EMCA_Id" 
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id" = "EYC"."EYC_Id" 
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id" = "EYCE"."EYCE_Id"  
            INNER JOIN "Exm"."Exm_Student_Marks" "ESM" ON "ESM"."ISMS_Id" = "EYCES"."ISMS_Id"
                AND "EYC"."MI_Id" = "ESM"."MI_Id" AND "EYCE"."EME_Id" = "ESM"."EME_Id" 
                AND "ECC"."ASMAY_Id" = "ESM"."ASMAY_Id" AND "ECC"."ASMS_Id" = "ESM"."ASMS_Id" 
                AND "ECC"."ASMCL_Id" = "ESM"."ASMCL_Id"
            WHERE "EYC"."MI_Id" = p_MI_Id AND "EYC"."ASMAY_Id" = p_ASMAY_Id 
                AND "ECC"."ASMS_Id" = p_ASMS_Id AND "EYCE"."EME_Id" = p_EME_Id 
            ORDER BY "ESM"."AMST_Id"
        LOOP
            v_MI_Id := rec_exmsubjectdetails."MI_Id";
            v_ASMAY_Id := rec_exmsubjectdetails."ASMAY_Id";
            v_ASMCL_Id := rec_exmsubjectdetails."ASMCL_Id";
            v_ASMS_Id := rec_exmsubjectdetails."ASMS_Id";
            v_AMST_Id := rec_exmsubjectdetails."AMST_Id";
            v_ISMS_Id := rec_exmsubjectdetails."ISMS_Id";
            v_EME_Id := rec_exmsubjectdetails."EME_Id";
            v_EYCES_AplResultFlg := rec_exmsubjectdetails."EYCES_AplResultFlg";
            v_EYCES_MarksEntryMax := rec_exmsubjectdetails."EYCES_MarksEntryMax";
            v_EYCES_MaxMarks := rec_exmsubjectdetails."EYCES_MaxMarks";
            v_EYCES_MinMarks := rec_exmsubjectdetails."EYCES_MinMarks";
            v_EMGR_Id := rec_exmsubjectdetails."EMGR_Id";
            v_ESTM_Marks := rec_exmsubjectdetails."ESTM_Marks";
            v_ESTM_MarksGradeFlg := rec_exmsubjectdetails."ESTM_MarksGradeFlg";
            v_ESTM_Flg := rec_exmsubjectdetails."ESTM_Flg";

            IF ((v_EYCES_AplResultFlg = true OR v_EYCES_AplResultFlg = false) AND (v_EYCES_MinMarks > v_ESTM_Marks)) THEN
                v_ESTMPS_PassFailFlg := 'Fail';
            ELSE
                v_ESTMPS_PassFailFlg := 'Pass';
            END IF;

            IF (v_ESTM_Flg = 'AB') THEN
                v_ESTMPS_PassFailFlg := 'AB';
            ELSIF (v_ESTM_Flg = 'ML') THEN
                v_ESTMPS_PassFailFlg := 'ML';
            ELSIF (v_ESTM_Flg = 'SL') THEN
                v_ESTMPS_PassFailFlg := 'SL';
            END IF;

            v_Subject_Percentage := CAST((v_ESTM_Marks / v_EYCES_MaxMarks) * 100 AS DECIMAL(10,2));

            SELECT "EMGD_Name" INTO v_ESTMPS_ObtainedGrade 
            FROM "Exm"."Exm_Master_Grade_Details" 
            WHERE (("EMGD_From" >= v_Subject_Percentage AND "EMGD_To" <= v_Subject_Percentage AND "EMGR_Id" = v_EMGR_Id) 
                OR ("EMGD_From" <= v_Subject_Percentage AND "EMGD_To" >= v_Subject_Percentage AND "EMGR_Id" = v_EMGR_Id))
            LIMIT 1;

            INSERT INTO "Exm"."Exm_Student_Marks_Process_Subjectwise" 
            ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ISMS_Id", "EME_Id", "ESTMPS_MaxMarks", 
             "ESTMPS_ObtainedMarks", "ESTMPS_ObtainedGrade", "ESTMPS_PassFailFlg", "CreatedDate", "UpdatedDate")
            VALUES (v_MI_Id, v_ASMAY_Id, v_ASMCL_Id, v_ASMS_Id, v_AMST_Id, v_ISMS_Id, v_EME_Id, v_EYCES_MaxMarks, 
                    v_ESTM_Marks, v_ESTMPS_ObtainedGrade, v_ESTMPS_PassFailFlg, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        END LOOP;

        SELECT "ASMCL_Id", "ISMS_Id" INTO v_ASMCL_Id, v_ISMS_Id 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMS_Id" = p_ASMS_Id 
            AND "ESTMPS_PassFailFlg" = 'Pass' AND "EME_Id" = p_EME_Id
        LIMIT 1;

        SELECT SUM("ESTMPS_ObtainedMarks") INTO v_Section_Totalmarks 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = v_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id AND "ISMS_Id" = v_ISMS_Id
        GROUP BY "ASMCL_Id", "ASMS_Id", "ISMS_Id";

        SELECT COUNT("AMST_Id") INTO v_Section_Totalcount 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ISMS_Id" = v_ISMS_Id 
            AND "ASMCL_Id" = v_ASMCL_Id AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;

        v_ESTMPS_SectionAverage := v_Section_Totalmarks / v_Section_Totalcount;

        UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ESTMPS_SectionAverage" = v_ESTMPS_SectionAverage
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = v_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id AND "EME_Id" = p_EME_Id;

        SELECT SUM("ESTMPS_ObtainedMarks") INTO v_Class_Totalmarks 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = v_ASMCL_Id AND "EME_Id" = p_EME_Id
        GROUP BY "ASMCL_Id", "ISMS_Id";

        SELECT COUNT("AMST_Id") INTO v_Class_Totalcount 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = v_ASMCL_Id AND "EME_Id" = p_EME_Id;

        v_ESTMPS_ClassAverage := v_Class_Totalmarks / v_Class_Totalcount;

        UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ESTMPS_ClassAverage" = v_ESTMPS_ClassAverage
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = v_ASMCL_Id AND "EME_Id" = p_EME_Id;

        SELECT "ESTMPS_ObtainedMarks" INTO v_ESTMPS_ClassHighest 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = v_ASMCL_Id 
            AND "ISMS_Id" = v_ISMS_Id AND "EME_Id" = p_EME_Id 
        ORDER BY "ESTMPS_ObtainedMarks" DESC
        LIMIT 1;

        UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ESTMPS_ClassHighest" = v_ESTMPS_ClassHighest
        WHERE "MI_Id" = p_MI_Id AND "ASMCL_Id" = v_ASMCL_Id AND "ISMS_Id" = v_ISMS_Id AND "EME_Id" = p_EME_Id;

        SELECT "ESTMPS_ObtainedMarks" INTO v_ESTMPS_SectionHighest 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = v_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id AND "ISMS_Id" = v_ISMS_Id AND "EME_Id" = p_EME_Id 
        ORDER BY "ESTMPS_ObtainedMarks" DESC
        LIMIT 1;

        UPDATE "Exm"."Exm_Student_Marks_Process_Subjectwise" 
        SET "ESTMPS_SectionHighest" = v_ESTMPS_SectionHighest
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMCL_Id" = v_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id AND "ISMS_Id" = v_ISMS_Id AND "EME_Id" = p_EME_Id;

        FOR rec_studentmarksprocess IN
            SELECT DISTINCT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ESMPS"."EME_Id",
                   SUM("ESTMPS_MaxMarks") AS "TotalMaxMarks", 
                   SUM("ESTMPS_ObtainedMarks") AS "TotalObtMarks",
                   COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'Fail' THEN "ESTMPS_PassFailFlg" END) AS "Failcount",
                   COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'AB' THEN "ESTMPS_PassFailFlg" END) AS "Absentcount",
                   COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'ML' THEN "ESTMPS_PassFailFlg" END) AS "Medicalcount",
                   COUNT(CASE WHEN "ESTMPS_PassFailFlg" = 'SL' THEN "ESTMPS_PassFailFlg" END) AS "Sportscount"
            FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" 
            WHERE "ESMPS"."EME_Id" IN (SELECT DISTINCT "EYCE"."EME_Id" FROM "Exm"."Exm_Yearly_Category_Exams" "EYCE") 
                AND "ESMPS"."ISMS_Id" IN (SELECT DISTINCT "EYCES"."ISMS_Id" FROM "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" 
                                          WHERE "EYCES"."EYCES_AplResultFlg" = true) 
                AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id AND "ASMS_Id" = p_ASMS_Id 
                AND "ESMPS"."EME_Id" = p_EME_Id 
            GROUP BY "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "ESMPS"."EME_Id", "ESTMPS_PassFailFlg"
        LOOP
            v_MI_Id := rec_studentmarksprocess."MI_Id";
            v_ASMAY_Id := rec_studentmarksprocess."ASMAY_Id";
            v_ASMCL_Id := rec_studentmarksprocess."ASMCL_Id";
            v_ASMS_Id := rec_studentmarksprocess."ASMS_Id";
            v_AMST_Id := rec_studentmarksprocess."AMST_Id";
            v_EME_Id := rec_studentmarksprocess."EME_Id";
            v_ESTMP_TotalMaxMarks := rec_studentmarksprocess."TotalMaxMarks";
            v_ESTMP_TotalObtMarks := rec_studentmarksprocess."TotalObtMarks";
            v_FailCount := rec_studentmarksprocess."Failcount";
            v_Absentcount := rec_studentmarksprocess."Absentcount";
            v_Medicalcount := rec_studentmarksprocess."Medicalcount";
            v_Sportscount := rec_studentmarksprocess."Sportscount";

            IF (v_FailCount > 0 OR v_Absentcount > 0 OR v_Medicalcount > 0 OR v_Sportscount > 0) THEN
                v_ESTMP_Result := 'Fail';
            ELSE
                v_ESTMP_Result := 'Pass';
            END IF;

            v_ESTMP_Percentage := CAST((v_ESTMP_TotalObtMarks / v_ESTMP_TotalMaxMarks) * 100 AS DECIMAL(10,2));

            SELECT "EMGR_Id" INTO v_Exm_Grade 
            FROM "Exm"."Exm_Yearly_Category_Exams" 
            WHERE "EME_Id" = v_EME_Id
            LIMIT 1;

            SELECT "EMGD_Name" INTO v_ESTMP_TotalGrade 
            FROM "Exm"."Exm_Master_Grade_Details" 
            WHERE (("EMGD_From" >= v_ESTMP_Percentage AND "EMGD_To" <= v_ESTMP_Percentage AND "EMGR_Id" = v_Exm_Grade) 
                OR ("EMGD_From" <= v_ESTMP_Percentage AND "EMGD_To" >= v_ESTMP_Percentage AND "EMGR_Id" = v_Exm_Grade))
            LIMIT 1;

            INSERT INTO "Exm"."Exm_Student_Marks_Process" 
            ("MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "ESTMP_TotalMaxMarks", 
             "ESTMP_TotalObtMarks", "ESTMP_Percentage", "ESTMP_TotalGrade", "ESTMP_Result", "CreatedDate", "UpdatedDate")
            VALUES (v_MI_Id, v_ASMAY_Id, v_ASMCL_Id, v_ASMS_Id, v_AMST_Id, v_EME_Id, v_ESTMP_TotalMaxMarks, 
                    v_ESTMP_TotalObtMarks, v_ESTMP_Percentage, v_ESTMP_TotalGrade, v_ESTMP_Result, 
                    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        END LOOP;

        IF (v_Rank = false) THEN

            WITH "ClassWiseRank" AS (
                SELECT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "ESTMP_Percentage",
                       DENSE_RANK() OVER(PARTITION BY "ASMCL_Id", "EME_Id" ORDER BY "ESTMP_Percentage" DESC) AS "Class_Rnk" 
                FROM "Exm"."Exm_Student_Marks_Process" 
                WHERE "ESTMP_Result" = 'Pass'
            )
            UPDATE "Exm"."Exm_Student_Marks_Process" 
            SET "ESTMP_ClassRank" = "A"."Class_Rnk"  
            FROM "ClassWiseRank" "A" 
            WHERE "A"."MI_Id" = "Exm"."Exm_Student_Marks_Process"."MI_Id" 
                AND "A"."ASMAY_Id" = "Exm"."Exm_Student_Marks_Process"."ASMAY_Id" 
                AND "A"."ASMCL_Id" = "Exm"."Exm_Student_Marks_Process"."ASMCL_Id" 
                AND "A"."AMST_Id" = "Exm"."Exm_Student_Marks_Process"."AMST_Id" 
                AND "A"."EME_Id" = "Exm"."Exm_Student_Marks_Process"."EME_Id"
                AND "Exm"."Exm_Student_Marks_Process"."ESTMP_Result" = 'Pass' 
                AND "A"."MI_Id" = p_MI_Id AND "A"."ASMAY_Id" = p_ASMAY_Id 
                AND "A"."ASMS_Id" = p_ASMS_Id AND "A"."EME_Id" = p_EME_Id;

            WITH "SectionWiseRank" AS (
                SELECT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "ESTMP_Percentage",
                       ROW_NUMBER() OVER(PARTITION BY "ASMS_Id", "EME_Id" ORDER BY "ESTMP_Percentage" DESC) AS "Section_Rnk" 
                FROM "Exm"."Exm_Student_Marks_Process" 
                WHERE "ESTMP_Result" = 'Pass'
            ) 
            UPDATE "Exm"."Exm_Student_Marks_Process" 
            SET "ESTMP_SectionRank" = "A"."Section_Rnk" 
            FROM "SectionWiseRank" "A" 
            WHERE "A"."MI_Id" = "Exm"."Exm_Student_Marks_Process"."MI_Id" 
                AND "A"."ASMAY_Id" = "Exm"."Exm_Student_Marks_Process"."ASMAY_Id" 
                AND "A"."ASMCL_Id" = "Exm"."Exm_Student_Marks_Process"."ASMCL_Id" 
                AND "A"."ASMS_Id" = "Exm"."Exm_Student_Marks_Process"."ASMS_Id" 
                AND "A"."AMST_Id" = "Exm"."Exm_Student_Marks_Process"."AMST_Id" 
                AND "A"."EME_Id" = "Exm"."Exm_Student_Marks_Process"."EME_Id"
                AND "Exm"."Exm_Student_Marks_Process"."ESTMP_Result" = 'Pass' 
                AND "A"."MI_Id" = p_MI_Id AND "A"."ASMAY_Id" = p_ASMAY_Id 
                AND "A"."ASMS_Id" = p_ASMS_Id AND "A"."EME_Id" = p_EME_Id;

        ELSE

            WITH "ClassWiseRank" AS (
                SELECT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "ESTMP_Percentage",
                       RANK() OVER(PARTITION BY "ASMCL_Id", "EME_Id" ORDER BY "ESTMP_Percentage" DESC) AS "Class_Rnk" 
                FROM "Exm"."Exm_Student_Marks_Process" 
                WHERE "ESTMP_Result" = 'Pass'
            )
            UPDATE "Exm"."Exm_Student_Marks_Process" 
            SET "ESTMP_ClassRank" = "A"."Class_Rnk"  
            FROM "ClassWiseRank" "A" 
            WHERE "A"."MI_Id" = "Exm"."Exm_Student_Marks_Process"."MI_Id" 
                AND "A"."ASMAY_Id" = "Exm"."Exm_Student_Marks_Process"."ASMAY_Id" 
                AND "A"."ASMS_Id" = "Exm"."Exm_Student_Marks_Process"."ASMS_Id" 
                AND "A"."AMST_Id" = "Exm"."Exm_Student_Marks_Process"."AMST_Id" 
                AND "A"."EME_Id" = "Exm"."Exm_Student_Marks_Process"."EME_Id"
                AND "Exm"."Exm_Student_Marks_Process"."ESTMP_Result" = 'Pass' 
                AND "A"."MI_Id" = p_MI_Id AND "A"."ASMAY_Id" = p_ASMAY_Id 
                AND "A"."ASMCL_Id" = v_ASMCL_Id AND "A"."ASMS_Id" = p_ASMS_Id 
                AND "A"."EME_Id" = p_EME_Id;

            WITH "SectionWiseRank" AS (
                SELECT "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "AMST_Id", "EME_Id", "ESTMP_Percentage",
                       RANK() OVER(PARTITION BY "ASMS_Id", "EME_Id" ORDER BY "ESTMP_Percentage" DESC) AS "Section_Rnk" 
                FROM "Exm"."Exm_Student_Marks_Process" 
                WHERE "ESTMP_Result" = 'Pass'
            )
            UPDATE "Exm"."Exm_Student_Marks_Process" 
            SET "ESTMP_SectionRank" = "A"."Section_Rnk" 
            FROM "SectionWiseRank" "A" 
            WHERE "A"."MI_Id" = "Exm"."Exm_Student_Marks_Process"."MI_Id" 
                AND "A"."ASMAY_Id" = "Exm"."Exm_Student_Marks_Process"."ASMAY_Id" 
                AND "A"."ASMS_Id" = "Exm"."Exm_Student_Marks_Process"."ASMS_Id" 
                AND "A"."AMST_Id" = "Exm"."Exm_Student_Marks_Process"."AMST_Id" 
                AND "A"."EME_Id" = "Exm"."Exm_Student_Marks_Process"."EME_Id"
                AND "Exm"."Exm_Student_Marks