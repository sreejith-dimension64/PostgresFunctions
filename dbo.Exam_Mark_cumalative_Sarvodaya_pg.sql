CREATE OR REPLACE FUNCTION "dbo"."Exam_Mark_cumalative_Sarvodaya"(
    p_MI_Id BIGINT,
    p_ASMS_Id BIGINT,
    p_ASMCL_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_EME_Id TEXT,
    p_EMGR_Id TEXT,
    p_Percentage BIGINT,
    p_Percentage2 BIGINT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "EMPSG_GroupName" VARCHAR,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "EME_Id" BIGINT,
    "EME_ExamCode" VARCHAR,
    "EME_ExamName" VARCHAR,
    "EMSE_SubExamName" VARCHAR,
    "ESTMPSSS_ObtainedGrade" VARCHAR,
    "ESTMPSSS_ObtainedMarks" DECIMAL(18,0),
    "ESTMPSSS_MaxMarks" DECIMAL(18,0),
    "Subject_Flag" INTEGER,
    "EYCES_SubjectOrder" INTEGER,
    "EYCES_MarksDisplayFlg" VARCHAR,
    "EYCES_GradeDisplayFlg" VARCHAR,
    "ESTMPSSS_PassFailFlg" VARCHAR,
    "AMAY_RollNo" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EYC_Id BIGINT;
    v_EMCA_Id BIGINT;
    v_EMGR_Id1 BIGINT;
    v_EMGR_MarksPerFlag VARCHAR(10);
    v_EMP_Id BIGINT;
    v_EME_ExamCode1 BIGINT;
    v_EME_ExamCode VARCHAR(10);
BEGIN

    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" = p_ASMCL_Id 
        AND "ASMS_Id" = p_ASMS_Id   
        AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1;
    
    SELECT "EMP_Id" INTO v_EMP_Id 
    FROM "Exm"."Exm_M_Promotion"  
    WHERE "MI_Id" = p_MI_Id 
        AND "EYC_Id" = v_EYC_Id 
        AND "EMP_ActiveFlag" = 1;
  
    SELECT "EMGR_GradeName" INTO v_EMGR_MarksPerFlag 
    FROM "exm"."Exm_Master_Grade"  
    WHERE "MI_Id" = p_MI_Id  
        AND "EMGR_Id" = p_EMGR_Id::BIGINT;

    SELECT "EMGR_Id" INTO v_EMGR_Id1 
    FROM "Exm"."Exm_Master_Grade_Details"  
    WHERE "EMGR_Id" = 80;

    SELECT "EME_Id", "EME_ExamCode" INTO v_EME_ExamCode1, v_EME_ExamCode 
    FROM "Exm"."Exm_Master_Exam" 
    WHERE "MI_ID" = p_MI_Id  
        AND "EME_Id" IN (SELECT UNNEST(STRING_TO_ARRAY(p_EME_Id, ','))::BIGINT)
        AND "EME_ExamCode" = 'SA-01'
    LIMIT 1;

    DROP TABLE IF EXISTS "Sarvodaya_Temp_StudentDetails";
    DROP TABLE IF EXISTS "SarvodayaStudentDetails_NEW";

    CREATE TEMP TABLE "Sarvodaya_Temp_StudentDetails" AS
    WITH "CTE_Exam" AS (
        SELECT b."AMST_Id", T."EMPSG_GroupName", c."ISMS_Id", c."ISMS_SubjectName", b."EME_Id", d."EME_ExamCode", d."EME_ExamName", 
            COALESCE(f."EMSE_SubExamName", e."EMSS_SubSubjectName") AS "EMSE_SubExamName", 
            a."ESTMPSSS_ObtainedGrade", a."ESTMPSSS_ObtainedMarks", a."ESTMPSSS_MaxMarks", 0 AS "Subject_Flag",
            c."ISMS_OrderFlag" AS "EYCES_SubjectOrder", I."EYCES_MarksDisplayFlg", I."EYCES_GradeDisplayFlg", 
            a."ESTMPSSS_PassFailFlg", YS."AMAY_RollNo"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" b
        INNER JOIN "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" a ON a."ESTMPS_Id" = b."ESTMPS_Id"	
        INNER JOIN "Adm_School_Y_Student" YS ON YS."AMST_Id" = b."AMST_Id" 
            AND YS."ASMCL_Id" = b."ASMCL_Id" 
            AND YS."ASMS_Id" = b."ASMS_Id"  
            AND YS."AMAY_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Yearly_Category" G ON G."ASMAY_Id" = B."ASMAY_Id" 
            AND G."EYC_Id" = v_EYC_Id  
            AND g."EMCA_Id" = v_EMCA_Id
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" H ON G."EYC_Id" = H."EYC_Id" 
            AND H."EYC_Id" = v_EYC_Id 
            AND h."EME_Id" = b."EME_Id" 
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" I ON I."EYCE_Id" = H."EYCE_Id" 
            AND I."ISMS_Id" = b."ISMS_Id"
        INNER JOIN "IVRM_Master_Subjects" C ON c."ISMS_Id" = b."ISMS_Id" 
            AND I."ISMS_Id" = c."ISMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON d."EME_Id" = b."EME_Id" 
            AND D."EME_Id" = H."EME_Id" 
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" R ON R."ISMS_ID" = B."ISMS_ID" 
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" T ON T."EMPS_Id" = R."EMPS_Id"
        INNER JOIN "Adm_M_Student" STD ON STD."AMST_Id" = b."AMST_Id"
        LEFT JOIN "Exm"."Exm_Master_SubExam" F ON f."EMSE_Id" = a."EMSE_Id"  
        LEFT JOIN "Exm"."Exm_Master_SubSubject" E ON E."EMSS_Id" = a."EMSS_Id"
        WHERE b."MI_Id" = p_MI_Id  
            AND b."ASMS_Id" = p_ASMS_Id 
            AND b."ASMCL_Id" = p_ASMCL_Id 
            AND b."ASMAY_Id" = p_ASMAY_Id
            AND d."EME_Id" IN (SELECT UNNEST(STRING_TO_ARRAY(p_EME_Id, ','))::BIGINT)
            AND R."EMP_ID" = v_EMP_Id
            AND "AMST_ActiveFlag" = 1  

        UNION ALL

        SELECT b."AMST_Id", T."EMPSG_GroupName", c."ISMS_Id", c."ISMS_SubjectName", b."EME_Id", d."EME_ExamCode", d."EME_ExamName", 
            d."EME_ExamName" AS "EMSE_SubExamName", b."ESTMPS_ObtainedGrade" AS "ESTMPSSS_ObtainedGrade", 
            b."ESTMPS_ObtainedMarks", b."ESTMPS_MaxMarks" AS "ESTMPSSS_MaxMarks", 1 AS "Subject_Flag",
            c."ISMS_OrderFlag" AS "EYCES_SubjectOrder", I."EYCES_MarksDisplayFlg", I."EYCES_GradeDisplayFlg", 
            b."ESTMPS_PassFailFlg", YS."AMAY_RollNo"
        FROM "Exm"."Exm_Master_Exam" D 
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" b ON d."EME_Id" = b."EME_Id"
        INNER JOIN "Adm_School_Y_Student" YS ON YS."AMST_Id" = b."AMST_Id" 
            AND YS."ASMCL_Id" = b."ASMCL_Id" 
            AND YS."ASMS_Id" = b."ASMS_Id" 
            AND YS."AMAY_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Yearly_Category" G ON G."ASMAY_Id" = B."ASMAY_Id" 
            AND G."EYC_Id" = v_EYC_Id  
            AND g."EMCA_Id" = v_EMCA_Id   
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" H ON G."EYC_Id" = H."EYC_Id" 
            AND H."EYC_Id" = v_EYC_Id 
            AND h."EME_Id" = b."EME_Id" 
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" I ON I."EYCE_Id" = H."EYCE_Id" 
            AND I."ISMS_Id" = b."ISMS_Id"
        INNER JOIN "IVRM_Master_Subjects" C ON c."ISMS_Id" = b."ISMS_Id" 
            AND I."ISMS_Id" = C."ISMS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" R ON R."ISMS_ID" = B."ISMS_ID" 
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" T ON T."EMPS_Id" = R."EMPS_Id"
        INNER JOIN "Adm_M_Student" STD ON STD."AMST_Id" = b."AMST_Id"
        WHERE b."MI_Id" = p_MI_Id  
            AND b."ASMS_Id" = p_ASMS_Id 
            AND b."ASMCL_Id" = p_ASMCL_Id 
            AND b."ASMAY_Id" = p_ASMAY_Id  
            AND d."EME_Id" IN (SELECT UNNEST(STRING_TO_ARRAY(p_EME_Id, ','))::BIGINT)
            AND R."EMP_ID" = v_EMP_Id  
            AND "AMST_ActiveFlag" = 1  
        GROUP BY c."ISMS_Id", T."EMPSG_GroupName", c."ISMS_SubjectName", b."AMST_Id", b."EME_Id", d."EME_ExamCode", 
            d."EME_ExamName", b."ESTMPS_ObtainedGrade", b."ESTMPS_ObtainedMarks", b."ESTMPS_MaxMarks", 
            c."ISMS_OrderFlag", I."EYCES_MarksDisplayFlg", I."EYCES_GradeDisplayFlg", b."ESTMPS_PassFailFlg", YS."AMAY_RollNo"
    )
    SELECT "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", "EME_Id", "EME_ExamCode", "EME_ExamName",
        "EMSE_SubExamName", "ESTMPSSS_ObtainedGrade", "ESTMPSSS_ObtainedMarks", "ESTMPSSS_MaxMarks", 
        "Subject_Flag", "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg", 
        "ESTMPSSS_PassFailFlg", "AMAY_RollNo"
    FROM "CTE_Exam" 
    WHERE "Subject_Flag" = 0 AND "EME_ExamCode" NOT IN ('SA-01','SA-02')

    UNION 

    SELECT "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", "EME_Id", 'Total', 'Total',
        "EMSE_SubExamName",
        (SELECT "EMGD_Name" 
         FROM "Exm"."Exm_Master_Grade_Details" 
         WHERE (ROUND(SUM("ESTMPSSS_ObtainedMarks"), 0) BETWEEN "EMGD_From" AND "EMGD_To" 
             AND "EMGR_Id" = p_EMGR_Id::BIGINT)
        ) AS "ESTMPSSS_ObtainedGrade",
        "ESTMPSSS_ObtainedMarks", "ESTMPSSS_MaxMarks", 2, "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", 
        "EYCES_GradeDisplayFlg", "ESTMPSSS_PassFailFlg", "AMAY_RollNo"
    FROM "CTE_Exam" 
    WHERE "Subject_Flag" = 1 AND "EME_ExamCode" NOT IN ('SA-01','SA-02')
    GROUP BY "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", "EME_Id",
        "EMSE_SubExamName", "ESTMPSSS_ObtainedGrade", "ESTMPSSS_ObtainedMarks", "ESTMPSSS_MaxMarks", 
        "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg",
        "ESTMPSSS_PassFailFlg", "AMAY_RollNo"

    UNION 

    SELECT "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", "EME_Id", "EME_ExamCode", 'Grade',
        "EMSE_SubExamName",
        (SELECT "EMGD_Name" 
         FROM "Exm"."Exm_Master_Grade_Details" 
         WHERE (ROUND(SUM("ESTMPSSS_ObtainedMarks" * p_Percentage / "ESTMPSSS_MaxMarks"), 0) BETWEEN "EMGD_From" AND "EMGD_To" 
             AND "EMGR_Id" = v_EMGR_Id1)
        ) AS "ESTMPSSS_ObtainedGrade",
        NULL AS "ESTMPSSS_ObtainedMarks", NULL AS "ESTMPSSS_MaxMarks", 4, "EYCES_SubjectOrder", 
        "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg", "ESTMPSSS_PassFailFlg", "AMAY_RollNo"
    FROM "CTE_Exam" 
    WHERE "Subject_Flag" = 1 AND "EME_ExamCode" NOT IN ('SA-01','SA-02')
    GROUP BY "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", "EME_Id", "EME_ExamCode", "EME_ExamName",
        "EMSE_SubExamName", "ESTMPSSS_ObtainedGrade", "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", 
        "EYCES_GradeDisplayFlg", "ESTMPSSS_PassFailFlg", "AMAY_RollNo"

    UNION 

    SELECT "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", "EME_Id", "EME_ExamCode", 
        "EMPSG_GroupName" || ' ' || p_Percentage2::VARCHAR || ' Marks', "EMPSG_GroupName",
        "ESTMPSSS_ObtainedGrade", 
        ROUND(("ESTMPSSS_ObtainedMarks" * p_Percentage2 / "ESTMPSSS_MaxMarks"), 0) AS "ESTMPSSS_ObtainedMarks", 
        p_Percentage2 AS "ESTMPSSS_MaxMarks",
        6, "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg", "ESTMPSSS_PassFailFlg", "AMAY_RollNo"
    FROM "CTE_Exam" 
    WHERE "Subject_Flag" = 1 AND "EME_ExamCode" IN ('SA-01','SA-02');

    CREATE TEMP TABLE "SarvodayaStudentDetails_NEW" AS
    SELECT "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", "EME_Id", "EME_ExamCode", "EME_ExamName", 
        "EMSE_SubExamName", "ESTMPSSS_ObtainedGrade",
        ROUND("ESTMPSSS_ObtainedMarks", 2) AS "ESTMPSSS_ObtainedMarks", "ESTMPSSS_MaxMarks", "Subject_Flag", 
        "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg",
        "ESTMPSSS_PassFailFlg", "AMAY_RollNo"
    FROM "Sarvodaya_Temp_StudentDetails"

    UNION 

    SELECT "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", v_EME_ExamCode1 AS "EME_Id", 
        'FA-1 + FA-2' AS "EME_ExamCode", 'FA-1 + FA-2' AS "EME_ExamName", 'FA-1 + FA-2' AS "EMSE_SubExamName", 
        NULL AS "ESTMPSSS_ObtainedGrade",
        ROUND(SUM("ESTMPSSS_ObtainedMarks"), 0), (2 * p_Percentage) AS "ESTMPSSS_MaxMarks", 5, 
        "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg",
        NULL AS "ESTMPSSS_PassFailFlg", "AMAY_RollNo"
    FROM "Sarvodaya_Temp_StudentDetails" 
    WHERE "Subject_Flag" = 3
    GROUP BY "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName",
        "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg", "AMAY_RollNo"

    UNION

    SELECT "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", 980000 AS "EME_Id", 
        'TOTAL' AS "EME_ExamCode", 'TOTAL' AS "EME_ExamName", 'TOTAL' AS "EMSE_SubExamName", 
        NULL AS "ESTMPSSS_ObtainedGrade",
        ROUND(SUM("ESTMPSSS_ObtainedMarks"), 0), ROUND(SUM("ESTMPSSS_MaxMarks"), 0) AS "ESTMPSSS_MaxMarks", 7, 
        "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg",
        NULL AS "ESTMPSSS_PassFailFlg", "AMAY_RollNo"
    FROM "Sarvodaya_Temp_StudentDetails" 
    WHERE "Subject_Flag" IN (6, 3)
    GROUP BY "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName",
        "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg", "AMAY_RollNo"

    UNION

    SELECT "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName", 980001 AS "EME_Id", 
        'GRADE' AS "EME_ExamCode", 'GRADE' AS "EME_ExamName", 'GRADE' AS "EMSE_SubExamName", 
        (SELECT "EMGD_Name" 
         FROM "Exm"."Exm_Master_Grade_Details" 
         WHERE (ROUND(SUM("ESTMPSSS_ObtainedMarks"), 0) BETWEEN "EMGD_From" AND "EMGD_To" 
             AND "EMGR_Id" = p_EMGR_Id::BIGINT)
        ),
        ROUND(SUM("ESTMPSSS_ObtainedMarks"), 0), ROUND(SUM("ESTMPSSS_MaxMarks"), 0) AS "ESTMPSSS_MaxMarks", 8, 
        "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg",
        NULL AS "ESTMPSSS_PassFailFlg", "AMAY_RollNo" 
    FROM "Sarvodaya_Temp_StudentDetails"  
    WHERE "Subject_Flag" IN (6, 3)
    GROUP BY "AMST_Id", "EMPSG_GroupName", "ISMS_Id", "ISMS_SubjectName",
        "EYCES_SubjectOrder", "EYCES_MarksDisplayFlg", "EYCES_GradeDisplayFlg", "AMAY_RollNo"
    ORDER BY "AMST_Id", "EMPSG_GroupName", "EYCES_SubjectOrder", "EME_Id", "Subject_Flag";

    DROP TABLE IF EXISTS "Sarvodaya_Temp_StudentDetails";

    UPDATE "SarvodayaStudentDetails_NEW" 
    SET "EMSE_SubExamName" = "EME_ExamName" 
    WHERE "EME_ExamName" = 'REDUCED TO 15';

    UPDATE "SarvodayaStudentDetails_NEW" 
    SET "EMSE_SubExamName" = "EME_ExamName" 
    WHERE "EME_ExamName" = 'Total';

    UPDATE "SarvodayaStudentDetails_NEW" 
    SET "EMSE_SubExamName" = "EME_ExamName" 
    WHERE "EME_ExamName" = 'Grade';

    UPDATE "SarvodayaStudentDetails_NEW" 
    SET "EMSE_SubExamName" = "EME_ExamName"  
    WHERE "EMSE_SubExamName" IS NULL;

    UPDATE "SarvodayaStudentDetails_NEW" 
    SET "ESTMPSSS_PassFailFlg" = 'Pass' 
    WHERE "EME_ExamName" = 'Grade' AND "ESTMPSSS_PassFailFlg" = 'AB';

    UPDATE "SarvodayaStudentDetails_NEW" 
    SET "EME_ExamName" = 'FA-3 + FA-4', "EMSE_SubExamName" = 'FA-3 + FA-4' 
    WHERE "EMPSG_GroupName" = 'SEM II' AND "Subject_Flag" = 5;

    RETURN QUERY
    SELECT 
        "AMST_Id",
        "EMPSG_GroupName",
        "ISMS_Id",
        "ISMS_SubjectName",
        "EME_Id",
        "EME_ExamCode",
        "EME_ExamName",
        "EMSE_SubExamName",
        "ESTMPSSS_ObtainedGrade",
        CAST(ROUND("ESTMPSSS_ObtainedMarks", 0) AS DECIMAL(18,0)) AS "ESTMPSSS_ObtainedMarks",
        CAST(ROUND("ESTMPSSS_MaxMarks", 0) AS DECIMAL(18,0)) AS "ESTMPSSS_MaxMarks",
        "Subject_Flag",
        "EYCES_SubjectOrder",
        "EYCES_MarksDisplayFlg",
        "EYCES_GradeDisplayFlg",
        CASE 
            WHEN "ESTMPSSS_ObtainedMarks" > 0 AND "Subject_Flag" IN (2, 3) THEN NULL 
            ELSE "ESTMPSSS_PassFailFlg" 
        END AS "ESTMPSSS_PassFailFlg",
        "AMAY_RollNo"
    FROM "SarvodayaStudentDetails_NEW" 
    WHERE "EME_ExamName" NOT IN ('REDUCED TO 15');

END;
$$;