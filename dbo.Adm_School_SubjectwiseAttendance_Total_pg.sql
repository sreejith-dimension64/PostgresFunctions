CREATE OR REPLACE FUNCTION "dbo"."Adm_School_SubjectwiseAttendance_Total"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_FromDate varchar(10),
    p_ToDate varchar(10),
    p_ISMS_Id bigint
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "ISMS_SubjectName" varchar,
    "AMST_Id" bigint,
    "AMST_AdmNo" varchar,
    "AMAY_RollNo" varchar,
    "StuName" text,
    "ASA_Class_Attended" bigint,
    "ASA_ClassHeld" numeric,
    "Absentcount" numeric,
    "StudentPercentage" numeric
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRMLY_Id bigint;
BEGIN

    DROP TABLE IF EXISTS "Adm_School_PeriodwiseAttendancedatesTotal_Temp";

    SELECT "HRMLY_Id" INTO v_HRMLY_Id 
    FROM "HR_Master_LeaveYear" 
    WHERE "HRMLY_LeaveYear" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP) 
    AND "MI_Id" = p_MI_Id;

    CREATE TEMP TABLE "Adm_School_PeriodwiseAttendancedatesTotal_Temp" AS
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
            THEN '0' || CAST(EXTRACT(DAY FROM "ADates") AS varchar)
            ELSE CAST(EXTRACT(DAY FROM "ADates") AS varchar)
        END AS "AMonthName"
    FROM CTE;

    RETURN QUERY
    SELECT 
        "New"."ISMS_Id",
        "New"."ISMS_SubjectName",
        "New"."AMST_Id",
        "New"."AMST_AdmNo",
        "New"."AMAY_RollNo",
        "New"."StuName",
        "New"."ASA_Class_Attended",
        "New"."ASA_ClassHeld",
        ("New"."ASA_ClassHeld" - "New"."ASA_Class_Attended") AS "Absentcount",
        CAST(("New"."ASA_Class_Attended" / "New"."ASA_ClassHeld") * 100 AS numeric(18,2)) AS "StudentPercentage"
    FROM (
        SELECT DISTINCT 
            "ASAS"."ISMS_Id",
            "IMS"."ISMS_SubjectName",
            "ASAST"."AMST_Id",
            "AMS"."AMST_AdmNo",
            "ASYS"."AMAY_RollNo",
            COALESCE("AMS"."AMST_FirstName", '') || ' ' || 
            COALESCE("AMS"."AMST_MiddleName", ' ') || ' ' || 
            COALESCE("AMS"."AMST_LastName", ' ') AS "StuName",
            COUNT(CASE WHEN "ASA"."ASA_Class_Attended" = 1.00 THEN 1 END) AS "ASA_Class_Attended",
            SUM("ASA"."ASA_ClassHeld") AS "ASA_ClassHeld"
        FROM "Adm_Student_Attendance" "ASA"
        INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" 
            ON "ASA"."ASA_Id" = "ASAP"."ASA_Id"
        INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" 
            ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
        INNER JOIN "IVRM_Master_Subjects" "IMS" 
            ON "IMS"."ISMS_Id" = "ASAS"."ISMS_Id" 
            AND "IMS"."MI_Id" = p_MI_Id
        INNER JOIN "Adm_School_PeriodwiseAttendancedatesTotal_Temp" "PAT" 
            ON "PAT"."ADates" = CAST("ASA"."ASA_FromDate" AS date)
        INNER JOIN "Adm_Student_Attendance_Students" "ASAST" 
            ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
        INNER JOIN "TT_Master_Period" "MP" 
            ON "MP"."TTMP_Id" = "ASAP"."TTMP_Id" 
            AND "MP"."MI_Id" = p_MI_Id
        INNER JOIN "Adm_M_Student" "AMS" 
            ON "AMS"."AMST_Id" = "ASAST"."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" 
            ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
        WHERE "ASA"."MI_Id" = p_MI_Id 
            AND "ASA"."ASMAY_Id" = p_ASMAY_Id 
            AND "ASA"."ASMCL_Id" = p_ASMCL_Id 
            AND "ASA"."ASMS_Id" = p_ASMS_Id 
            AND "ASAS"."ISMS_Id" = p_ISMS_Id 
            AND "ASYS"."ASMAY_Id" = p_ASMAY_Id 
            AND "AMS"."AMST_SOL" = 'S' 
            AND "AMS"."AMST_ActiveFlag" = 1 
            AND "ASYS"."AMAY_ActiveFlag" = 1
            AND CAST("ASA"."ASA_FromDate" AS date) >= CAST(p_FromDate AS date)
            AND CAST("ASA"."ASA_ToDate" AS date) <= CAST(p_ToDate AS date)
            AND "ASA"."ASA_Activeflag" = 1 
            AND "ASA"."ASA_Att_Type" = 'Period'
        GROUP BY 
            "ASAS"."ISMS_Id",
            "IMS"."ISMS_SubjectName",
            "ASAST"."AMST_Id",
            "AMS"."AMST_AdmNo",
            "ASYS"."AMAY_RollNo",
            "AMS"."AMST_FirstName",
            "AMS"."AMST_MiddleName",
            "AMS"."AMST_LastName"
    ) AS "New";

    DROP TABLE IF EXISTS "Adm_School_PeriodwiseAttendancedatesTotal_Temp";

END;
$$;