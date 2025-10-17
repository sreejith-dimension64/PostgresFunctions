CREATE OR REPLACE FUNCTION "dbo"."Exm_Multiple_Exam_Cumulative_Calcutta"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@EMGR_Id" TEXT,
    "@EME_Id" TEXT,
    "@FLAG" TEXT
)
RETURNS TABLE (
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "EYCES_SubjectOrder" INTEGER,
    "AMST_Id" BIGINT,
    "TOTALWORKINGDAYS" BIGINT,
    "PRESENTDAYS" BIGINT,
    "ATTENDANCEPERCENTAGE" NUMERIC,
    "AMST_FirstName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMAY_RollNo" VARCHAR,
    "EME_Id" BIGINT,
    "EMSE_SubExamName" VARCHAR,
    "Subject_Flag" INTEGER,
    "EMSE_SubExamOrder" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@FROM_DATE" TIMESTAMP;
    "@TO_DATE" TIMESTAMP;
    "@EYC_Id" BIGINT;
    "@FROM_DATE_New" TIMESTAMP;
    "@TO_DATE_New" TIMESTAMP;
    "@EMCA_Id" BIGINT;
    "@ExmConfig_AdmNoRegNoRollNo" VARCHAR(100);
BEGIN

    SELECT "EMCA_Id" INTO "@EMCA_Id"
    FROM "Exm"."Exm_Category_Class"
    WHERE "MI_Id" = "@MI_Id"::BIGINT
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT
        AND "ASMS_Id" = "@ASMS_Id"::BIGINT
        AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO "@EYC_Id"
    FROM "Exm"."Exm_Yearly_Category"
    WHERE "MI_Id" = "@MI_Id"::BIGINT
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND "EMCA_Id" = "@EMCA_Id"
        AND "EYC_ActiveFlg" = 1;

    RAISE NOTICE '%', "@EMCA_Id";
    RAISE NOTICE '%', "@EYC_Id";

    SELECT "EYCE_AttendanceFromDate", "EYCE_AttendanceToDate"
    INTO "@FROM_DATE", "@TO_DATE"
    FROM "exm"."Exm_Yearly_Category_Exams"
    WHERE "EYC_Id" = "@EYC_Id"
    ORDER BY "EYCE_AttendanceFromDate" ASC
    LIMIT 1;

    CREATE TEMP TABLE "#temp" AS
    SELECT "EYCE_AttendanceFromDate", "EYCE_AttendanceToDate"
    FROM "exm"."Exm_Yearly_Category_Exams"
    WHERE "EYC_Id" = "@EYC_Id"
    ORDER BY "EYCE_Id" ASC
    LIMIT 2;

    SELECT "EYCE_AttendanceFromDate" INTO "@FROM_DATE_New"
    FROM "#temp"
    ORDER BY "EYCE_AttendanceFromDate" ASC
    LIMIT 1;

    SELECT "EYCE_AttendanceToDate" INTO "@TO_DATE_New"
    FROM "#temp"
    ORDER BY "EYCE_AttendanceToDate" DESC
    LIMIT 1;

    RAISE NOTICE '%', "@FROM_DATE_New";
    RAISE NOTICE '%', "@TO_DATE_New";

    IF "@FLAG" = '2' THEN
        RETURN QUERY
        SELECT DISTINCT
            F."ISMS_Id",
            F."ISMS_SubjectName",
            F."ISMS_OrderFlag" AS "EYCES_SubjectOrder",
            NULL::BIGINT AS "AMST_Id",
            NULL::BIGINT AS "TOTALWORKINGDAYS",
            NULL::BIGINT AS "PRESENTDAYS",
            NULL::NUMERIC AS "ATTENDANCEPERCENTAGE",
            NULL::TEXT AS "AMST_FirstName",
            NULL::VARCHAR AS "AMST_AdmNo",
            NULL::VARCHAR AS "AMAY_RollNo",
            NULL::BIGINT AS "EME_Id",
            NULL::VARCHAR AS "EMSE_SubExamName",
            NULL::INTEGER AS "Subject_Flag",
            NULL::INTEGER AS "EMSE_SubExamOrder"
        FROM "Exm"."Exm_Category_Class" A
        INNER JOIN "Exm"."Exm_Master_Category" B ON A."EMCA_Id" = B."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category" C ON C."EMCA_Id" = B."EMCA_Id"
            AND C."EYC_ActiveFlg" = 1 AND C."EYC_Id" = "@EYC_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" D ON D."EYC_Id" = C."EYC_Id"
            AND D."EYCE_ActiveFlg" = 1 AND D."EYC_Id" = "@EYC_Id"
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" E ON E."EYCE_Id" = D."EYCE_Id"
        INNER JOIN "IVRM_Master_Subjects" F ON F."ISMS_Id" = E."ISMS_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" G ON G."ISMS_Id" = F."ISMS_Id"
            AND G."ISMS_Id" = E."ISMS_Id"
            AND A."ASMAY_Id" = G."ASMAY_Id"
            AND A."ASMCL_Id" = G."ASMCL_Id"
            AND A."ASMS_Id" = G."ASMS_Id"
            AND G."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[])
        WHERE A."MI_Id" = "@MI_Id"::BIGINT
            AND A."ASMAY_Id" = "@ASMAY_Id"::BIGINT
            AND A."ASMCL_Id" = "@ASMCL_Id"::BIGINT
            AND A."ASMS_Id" = "@ASMS_Id"::BIGINT
            AND C."ASMAY_Id" = "@ASMAY_Id"::BIGINT
            AND C."EYC_ActiveFlg" = 1
            AND A."ECAC_ActiveFlag" = 1
            AND D."EYCE_ActiveFlg" = 1
            AND E."EYCES_ActiveFlg" = 1
            AND E."EYCES_AplResultFlg" = 1
            AND D."EYCE_ActiveFlg" = 1
            AND D."EME_Id" = ANY(STRING_TO_ARRAY("@EME_Id", ',')::BIGINT[])
        ORDER BY F."ISMS_OrderFlag";

    ELSIF "@FLAG" = '3' THEN
        RETURN QUERY
        SELECT
            NULL::BIGINT AS "ISMS_Id",
            NULL::VARCHAR AS "ISMS_SubjectName",
            NULL::INTEGER AS "EYCES_SubjectOrder",
            C."AMST_Id",
            SUM(ASA_ClassHeld) AS "TOTALWORKINGDAYS",
            SUM(ASA_Class_Attended) AS "PRESENTDAYS",
            ROUND(CAST(SUM(ASA_Class_Attended) * 100.0 / NULLIF(SUM(ASA_ClassHeld), 0) AS NUMERIC), 0) AS "ATTENDANCEPERCENTAGE",
            CONCAT(D."AMST_FirstName", ' ', D."AMST_MiddleName", ' ', D."AMST_LastName", ' ') AS "AMST_FirstName",
            D."AMST_AdmNo",
            C."AMAY_RollNo",
            NULL::BIGINT AS "EME_Id",
            NULL::VARCHAR AS "EMSE_SubExamName",
            NULL::INTEGER AS "Subject_Flag",
            NULL::INTEGER AS "EMSE_SubExamOrder"
        FROM "Adm_Student_Attendance" A
        INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id" = B."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = B."AMST_Id"
            AND D."AMST_ActiveFlag" = 1 AND D."AMST_SOL" = 'S'
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id"
        WHERE A."ASA_Activeflag" = 1
            AND A."MI_Id" = "@MI_Id"::BIGINT
            AND C."ASMAY_Id" = "@ASMAY_Id"::BIGINT
            AND C."ASMCL_Id" = "@ASMCL_Id"::BIGINT
            AND C."ASMS_Id" = "@ASMS_Id"::BIGINT
            AND C."AMAY_RollNo" IS NOT NULL
            AND CAST(A."ASA_FromDate" AS DATE) BETWEEN "@FROM_DATE_New" AND "@TO_DATE_New"
        GROUP BY C."AMST_Id", D."AMST_AdmNo", C."AMAY_RollNo", D."AMST_FirstName", D."AMST_MiddleName", D."AMST_LastName"
        ORDER BY C."AMAY_RollNo";

    ELSIF "@FLAG" = '1' THEN
        RETURN QUERY
        SELECT
            NULL::BIGINT AS "ISMS_Id",
            NULL::VARCHAR AS "ISMS_SubjectName",
            NULL::INTEGER AS "EYCES_SubjectOrder",
            NULL::BIGINT AS "AMST_Id",
            NULL::BIGINT AS "TOTALWORKINGDAYS",
            NULL::BIGINT AS "PRESENTDAYS",
            NULL::NUMERIC AS "ATTENDANCEPERCENTAGE",
            NULL::TEXT AS "AMST_FirstName",
            NULL::VARCHAR AS "AMST_AdmNo",
            NULL::VARCHAR AS "AMAY_RollNo",
            CBS."EME_Id",
            CBS."ISMS_Id",
            CBS."EMSE_SubExamName",
            CBS."EYCES_SubjectOrder",
            CBS."ISMS_SubjectName",
            CBS."Subject_Flag",
            CBS."EMSE_SubExamOrder"
        FROM "CBS_Temp_StudentDetails" CBS
        ORDER BY CBS."EYCES_SubjectOrder", CBS."EME_Id", CBS."Subject_Flag", CBS."EMSE_SubExamOrder";

    END IF;

    DROP TABLE IF EXISTS "#temp";

    RETURN;

END;
$$;