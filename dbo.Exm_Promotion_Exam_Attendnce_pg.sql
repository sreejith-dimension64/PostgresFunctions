CREATE OR REPLACE FUNCTION "dbo"."Exm_Promotion_Exam_Attendnce"(
    "@MI_ID" BIGINT,
    "@AMST_Id" TEXT,
    "@ASMS_Id" BIGINT,
    "@ASMCL_Id" BIGINT,
    "@EYC_Id" BIGINT,
    "@FLAG" VARCHAR(10),
    "@ASMAY_Id" BIGINT
)
RETURNS TABLE(
    "EMPSG_DisplayName" VARCHAR,
    "EYC_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "AMST_Id" BIGINT,
    "EME_Id" TEXT,
    "EME_ExamName" VARCHAR,
    "EYCE_AttendanceFromDate" DATE,
    "EYCE_AttendanceToDate" DATE,
    "TOTALWORKINGDAYS" NUMERIC,
    "TOTALPRESENTDAYS" NUMERIC,
    "TOTALAttendancePercentage" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "temp_exam_Mark";
    DROP TABLE IF EXISTS "temp_exam_Mark2";

    CREATE TEMPORARY TABLE "temp_exam_Mark" AS
    SELECT DISTINCT c."EMPSG_GroupName",
        c."EMPSG_DisplayName",
        a."EYC_Id",
        h."ASMS_Id",
        h."AMST_Id",
        e."EME_Id",
        e."EME_ExamName",
        G."EYCE_AttendanceFromDate",
        G."EYCE_AttendanceToDate"
    FROM "exm"."Exm_M_Promotion" a 
    INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id"
    INNER JOIN "exm"."Exm_M_Prom_Subj_Group" c ON c."EMPS_Id" = b."EMPS_Id"
    INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON d."EMPSG_Id" = c."EMPSG_Id"
    INNER JOIN "exm"."Exm_Master_Exam" e ON e."EME_Id" = d."EME_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category" f ON f."EYC_Id" = a."EYC_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" g ON g."EYC_Id" = a."EYC_Id" AND g."EME_ID" = e."EME_Id"
    INNER JOIN "Adm_School_Y_Student" h ON h."ASMAY_Id" = f."ASMAY_Id"
    WHERE a."MI_Id" = "@MI_ID"
    AND a."EYC_Id" = "@EYC_Id"
    AND H."ASMS_Id" = "@ASMS_Id"
    AND H."ASMCL_Id" = "@ASMCL_Id"
    AND H."AMST_Id" IN (SELECT CAST(TRIM(unnest(string_to_array("@AMST_Id", ','))) AS BIGINT))
    AND H."ASMAY_Id" = "@ASMAY_Id"
    AND a."EMP_ActiveFlag" = 1
    AND b."EMPS_ActiveFlag" = 1
    AND c."EMPSG_ActiveFlag" = 1
    AND d."EMPSGE_ActiveFlg" = 1;

    CREATE TEMPORARY TABLE "temp_exam_Mark2" AS
    SELECT 
        temp."EMPSG_DisplayName",
        temp."EYC_Id",
        temp."ASMS_Id",
        temp."AMST_Id",
        temp."EME_Id",
        temp."EME_ExamName",
        temp."EYCE_AttendanceFromDate",
        temp."EYCE_AttendanceToDate",
        SUM(k."ASA_ClassHeld") AS "TOTALWORKINGDAYS",
        SUM(k."ASA_Class_Attended") AS "TOTALPRESENTDAYS",
        CAST(SUM(k."ASA_Class_Attended") * 100.0 / NULLIF(SUM(k."ASA_ClassHeld"), 0) AS NUMERIC(18,2)) AS "TOTALAttendancePercentage"
    FROM "temp_exam_Mark" temp
    LEFT JOIN "Adm_Student_Attendance_Students" j ON j."AMST_Id" = temp."AMST_Id"
    LEFT JOIN "Adm_Student_Attendance" k ON k."ASA_Id" = j."ASA_Id"
        AND (CAST(K."ASA_FromDate" AS DATE) BETWEEN temp."EYCE_AttendanceFromDate" AND temp."EYCE_AttendanceToDate")
    WHERE K."ASA_FromDate" IS NOT NULL
    GROUP BY 
        temp."EMPSG_DisplayName",
        temp."EYC_Id",
        temp."ASMS_Id",
        temp."AMST_Id",
        temp."EME_Id",
        temp."EME_ExamName",
        temp."EYCE_AttendanceFromDate",
        temp."EYCE_AttendanceToDate";

    IF "@FLAG" = '2' THEN
        RETURN QUERY
        SELECT 
            t."EMPSG_DisplayName",
            t."EYC_Id",
            t."ASMS_Id",
            t."AMST_Id",
            CAST(t."EME_Id" AS TEXT),
            t."EME_ExamName",
            t."EYCE_AttendanceFromDate",
            t."EYCE_AttendanceToDate",
            t."TOTALWORKINGDAYS",
            t."TOTALPRESENTDAYS",
            t."TOTALAttendancePercentage"
        FROM "temp_exam_Mark2" t;
    END IF;

    IF "@FLAG" = '1' THEN
        RETURN QUERY
        SELECT 
            t."EMPSG_DisplayName",
            t."EYC_Id",
            t."ASMS_Id",
            t."AMST_Id",
            CAST(t."EME_Id" AS TEXT),
            t."EME_ExamName",
            t."EYCE_AttendanceFromDate",
            t."EYCE_AttendanceToDate",
            t."TOTALWORKINGDAYS",
            t."TOTALPRESENTDAYS",
            t."TOTALAttendancePercentage"
        FROM "temp_exam_Mark2" t
        UNION ALL
        SELECT 
            temp2."EMPSG_DisplayName",
            temp2."EYC_Id",
            temp2."ASMS_Id",
            temp2."AMST_Id",
            '9800000'::TEXT,
            '9800000'::VARCHAR,
            NULL::DATE,
            NULL::DATE,
            SUM(temp2."TOTALWORKINGDAYS"),
            SUM(temp2."TOTALPRESENTDAYS"),
            ROUND(CAST(SUM(temp2."TOTALAttendancePercentage") / NULLIF(COUNT(temp2."TOTALAttendancePercentage"), 0) AS NUMERIC), 2)
        FROM "temp_exam_Mark2" temp2
        GROUP BY 
            temp2."EMPSG_DisplayName",
            temp2."EYC_Id",
            temp2."ASMS_Id",
            temp2."AMST_Id";
    END IF;

    DROP TABLE IF EXISTS "temp_exam_Mark";
    DROP TABLE IF EXISTS "temp_exam_Mark2";

    RETURN;
END;
$$;