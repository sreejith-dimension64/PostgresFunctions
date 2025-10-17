CREATE OR REPLACE FUNCTION "dbo"."Adm_SchoolSubjectwiseAbsentAttendanceSMS"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FromDate VARCHAR(10),
    p_ToDate VARCHAR(10),
    p_ISMS_Id TEXT
)
RETURNS TABLE(
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" TEXT,
    "ASA_FromDate" DATE,
    "AMonthName" TEXT,
    "AMST_Id" BIGINT,
    "StuName" TEXT,
    "AMST_AdmNo" TEXT,
    "AMAY_RollNo" TEXT,
    "ASA_Class_Attended" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRMLY_Id BIGINT;
BEGIN
    DROP TABLE IF EXISTS "Adm_School_PeriodwiseAttendancedates_Temp";

    SELECT "HRMLY_Id" INTO v_HRMLY_Id 
    FROM "HR_Master_LeaveYear" 
    WHERE "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP) 
    AND "MI_Id" = p_MI_Id::BIGINT;

    CREATE TEMP TABLE "Adm_School_PeriodwiseAttendancedates_Temp" AS
    WITH RECURSIVE CTE AS (
        SELECT CAST(p_FromDate AS DATE) AS "ADates"
        UNION ALL
        SELECT "ADates" + INTERVAL '1 day'
        FROM CTE
        WHERE "ADates" + INTERVAL '1 day' <= CAST(p_ToDate AS DATE)
    )
    SELECT 
        "ADates",
        SUBSTRING(TO_CHAR("ADates", 'Month'), 1, 3) || 
        CASE 
            WHEN EXTRACT(DAY FROM "ADates") BETWEEN 0 AND 9 
            THEN '0' || CAST(EXTRACT(DAY FROM "ADates") AS TEXT)
            ELSE CAST(EXTRACT(DAY FROM "ADates") AS TEXT)
        END AS "AMonthName"
    FROM CTE;

    DROP TABLE IF EXISTS "SubjectwiseAttendance_Temp";

    CREATE TEMP TABLE "SubjectwiseAttendance_Temp" AS
    SELECT 
        "ISMS_Id",
        "ISMS_SubjectName",
        "ASA_FromDate",
        "AMonthName",
        "AMST_Id",
        ("TTMP_PeriodName" || ':' || "ASA_Class_Attended") AS "ASA_Class_Attended"
    FROM (
        SELECT DISTINCT 
            "ASAS"."ISMS_Id",
            "IMS"."ISMS_SubjectName",
            CAST("ASA"."ASA_FromDate" AS DATE) AS "ASA_FromDate",
            "PAT"."AMonthName",
            "ASAST"."AMST_Id",
            "MP"."TTMP_PeriodName",
            CASE 
                WHEN "ASAST"."ASA_Class_Attended" = 1.00 THEN 'P' 
                WHEN "ASAST"."ASA_Class_Attended" = 0.00 THEN 'A' 
            END AS "ASA_Class_Attended"
        FROM "Adm_Student_Attendance" "ASA"
        INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id" = "ASAP"."ASA_Id"
        INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
        INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASAS"."ISMS_Id" AND "IMS"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Adm_School_PeriodwiseAttendancedates_Temp" "PAT" ON "PAT"."ADates" = CAST("ASA"."ASA_FromDate" AS DATE)
        INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
        INNER JOIN "TT_Master_Period" "MP" ON "MP"."TTMP_Id" = "ASAP"."TTMP_Id" AND "MP"."MI_Id" = p_MI_Id::BIGINT
        WHERE "ASA"."MI_Id" = p_MI_Id::BIGINT 
        AND "ASA"."ASMAY_Id" = p_ASMAY_Id::BIGINT
        AND "ASA"."ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND "ASA"."ASMS_Id" = p_ASMS_Id::BIGINT 
        AND "ASAS"."ISMS_Id" = p_ISMS_Id::BIGINT
        AND "ASAST"."ASA_Class_Attended" = 0.00
        AND CAST("ASA"."ASA_FromDate" AS DATE) >= CAST(p_FromDate AS DATE)
        AND CAST("ASA"."ASA_ToDate" AS DATE) <= CAST(p_ToDate AS DATE)
        AND "ASA"."ASA_Activeflag" = 1
        AND "ASA"."ASA_Att_Type" = 'Period'
    ) AS "New";

    RETURN QUERY
    SELECT DISTINCT 
        "A2"."ISMS_Id",
        "A2"."ISMS_SubjectName",
        "A2"."ASA_FromDate",
        "A2"."AMonthName",
        "A2"."AMST_Id",
        COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '') AS "StuName",
        "AMS"."AMST_AdmNo",
        "ASYS"."AMAY_RollNo",
        (
            SELECT STRING_AGG("A1"."ASA_Class_Attended", ',' ORDER BY "A1"."ASA_Class_Attended")
            FROM "SubjectwiseAttendance_Temp" "A1"
            WHERE "A1"."ISMS_Id" = "A2"."ISMS_Id" 
            AND "A1"."ASA_FromDate" = "A2"."ASA_FromDate" 
            AND "A1"."AMonthName" = "A2"."AMonthName" 
            AND "A1"."AMST_Id" = "A2"."AMST_Id"
        ) AS "ASA_Class_Attended"
    FROM "SubjectwiseAttendance_Temp" "A2"
    INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "A2"."AMST_Id"
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
    WHERE "ASYS"."ASMAY_Id" = p_ASMAY_Id::BIGINT
    AND "AMS"."AMST_SOL" = 'S'
    AND "AMS"."AMST_ActiveFlag" = 1
    AND "ASYS"."AMAY_ActiveFlag" = 1;

    DROP TABLE IF EXISTS "Adm_School_PeriodwiseAttendancedates_Temp";
    DROP TABLE IF EXISTS "SubjectwiseAttendance_Temp";

    RETURN;
END;
$$;