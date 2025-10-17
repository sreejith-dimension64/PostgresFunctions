CREATE OR REPLACE FUNCTION "dbo"."ConLateinStudentsReport"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id text,
    p_ASMS_Id text
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "FromDate" date,
    "ToDate" date,
    "AbsentCount" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS "Adm_Student_AttendanceV_Temp";
    DROP TABLE IF EXISTS "absent_StudentsV";
    DROP TABLE IF EXISTS "New_conabsstudentV";

    EXECUTE format('
        CREATE TEMP TABLE "Adm_Student_AttendanceV_Temp" AS
        SELECT DISTINCT "AMST_Id", 
               TO_TIMESTAMP("ALIEOS_AttendanceDate", ''DD/MM/YYYY'')::timestamp AS absent_date
        FROM "Attendance_LateIn_Students" 
        WHERE "MI_Id" = %s 
          AND "ASMAY_Id" = %s 
          AND "ASMCL_Id" IN (%s) 
          AND "ASMS_Id" IN (%s)',
        p_MI_Id,
        p_ASMAY_Id,
        p_ASMCL_Id,
        p_ASMS_Id
    );

    CREATE TEMP TABLE "absent_StudentsV" AS
    WITH consec_dates AS (
        SELECT a.*, 
               CASE 
                   WHEN a.absent_date - LAG(a.absent_date, 1, a.absent_date) OVER (PARTITION BY a."AMST_Id" ORDER BY a.absent_date) = INTERVAL '1 day'
                   AND a.absent_date - LAG(a.absent_date, 2, a.absent_date) OVER (PARTITION BY a."AMST_Id" ORDER BY a.absent_date) = INTERVAL '2 days'
                   THEN EXTRACT(DAY FROM (a.absent_date - LAG(a.absent_date, 3, a.absent_date) OVER (PARTITION BY a."AMST_Id" ORDER BY a.absent_date)))::integer
                   ELSE 0 
               END AS num_consec_abs
        FROM "Adm_Student_AttendanceV_Temp" a
    )
    SELECT DISTINCT a.*
    FROM "Adm_Student_AttendanceV_Temp" a
    INNER JOIN consec_dates b ON a."AMST_Id" = b."AMST_Id"
    WHERE b.num_consec_abs = 3
      AND a.absent_date BETWEEN b.absent_date - INTERVAL '3 days' AND b.absent_date;

    CREATE TEMP TABLE "New_conabsstudentV" AS
    WITH dates AS (
        SELECT DISTINCT CAST(absent_date AS DATE) AS date, "AMST_Id"
        FROM "absent_StudentsV"
    ),
    groups AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY date) AS rn,
            date - (ROW_NUMBER() OVER (ORDER BY date) || ' days')::interval AS grp,
            date,
            "AMST_Id"
        FROM dates
    )
    SELECT 
        "AMST_Id",
        COUNT(*) AS "consecutiveDates",
        MIN(date) AS "SDate",
        MAX(date) AS "TDate"
    FROM groups
    GROUP BY grp, "AMST_Id";

    RETURN QUERY
    SELECT 
        "AMST_Id",
        MIN("SDate") AS "FromDate",
        MAX("TDate") AS "ToDate",
        SUM("consecutiveDates") AS "AbsentCount"
    FROM "New_conabsstudentV"
    GROUP BY "consecutiveDates", "AMST_Id";

    DROP TABLE IF EXISTS "Adm_Student_AttendanceV_Temp";
    DROP TABLE IF EXISTS "absent_StudentsV";
    DROP TABLE IF EXISTS "New_conabsstudentV";
END;
$$;