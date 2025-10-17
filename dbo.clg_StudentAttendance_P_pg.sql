CREATE OR REPLACE FUNCTION "dbo"."clg_StudentAttendance_P" (
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_from date,
    p_to date
)
RETURNS TABLE (
    "AMST_Id" bigint,
    "January" numeric,
    "Febrauary" numeric,
    "March" numeric,
    "April" numeric,
    "May" numeric,
    "June" numeric,
    "July" numeric,
    "August" numeric,
    "September" numeric,
    "October" numeric,
    "November" numeric,
    "December" numeric,
    "TotalPresentDays" numeric,
    "Total_Percentage" numeric,
    "TotalSchoolDays" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS temp_A;
    
    CREATE TEMP TABLE temp_A AS
    WITH cte AS (
        SELECT DISTINCT "ASAS"."AMST_Id", 
               TO_CHAR("ASA"."ASA_fromDate", 'Month') AS "Months",
               SUM("ASAS"."ASA_Class_Attended") AS "PresentCount"
        FROM "adm_student_attendance_students" "ASAS" 
        INNER JOIN "Adm_Student_Attendance" "ASA" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
        WHERE "ASA"."ASA_Att_type" = 'Dailyonce' 
            AND "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASA_Activeflag" = 1 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id 
            AND (("ASA"."ASA_FromDate" BETWEEN p_from AND p_to) OR ("ASA"."ASA_ToDate" BETWEEN p_from AND p_to))
        GROUP BY "ASAS"."AMST_Id", TO_CHAR("ASA"."ASA_fromDate", 'Month')
        
        UNION
        
        SELECT DISTINCT "ASAS"."AMST_Id",
               TO_CHAR("ASA"."ASA_fromDate", 'Month') AS "Months",
               SUM("ASAS"."ASA_Class_Attended") AS "PresentCount"
        FROM "adm_student_attendance_students" "ASAS" 
        INNER JOIN "Adm_Student_Attendance" "ASA" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
        WHERE "ASA"."ASA_Att_type" = 'Dailytwice' 
            AND "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASA_Activeflag" = 1 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id 
            AND (("ASA"."ASA_FromDate" BETWEEN p_from AND p_to) OR ("ASA"."ASA_ToDate" BETWEEN p_from AND p_to))
        GROUP BY "ASAS"."AMST_Id", TO_CHAR("ASA"."ASA_fromDate", 'Month')
        
        UNION
        
        SELECT DISTINCT "ASAS"."AMST_Id",
               TO_CHAR("ASA"."ASA_fromDate", 'Month') AS "Months",
               SUM("ASAS"."ASA_Class_Attended") AS "PresentCount"
        FROM "adm_student_attendance_students" "ASAS" 
        INNER JOIN "Adm_Student_Attendance" "ASA" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
        WHERE "ASA"."ASA_Att_type" = 'Monthly' 
            AND "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "ASA_Activeflag" = 1 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id 
            AND (("ASA"."ASA_FromDate" BETWEEN p_from AND p_to) OR ("ASA"."ASA_ToDate" BETWEEN p_from AND p_to))
        GROUP BY "ASAS"."AMST_Id", TO_CHAR("ASA"."ASA_fromDate", 'Month')
        
        UNION
        
        SELECT DISTINCT "b"."AMST_Id",
               TO_CHAR("ASA_fromDate", 'Month') AS "Months",
               SUM("b"."ASA_Class_Attended") AS "PresentCount"
        FROM "adm_student_attendance" "a"
        INNER JOIN "Adm_Student_Attendance_Students" "b" ON "a"."ASA_Id" = "b"."ASA_Id"
        INNER JOIN "Adm_Student_Attendance_Periodwise" "c" ON "c"."ASA_Id" = "a"."ASA_Id"
        INNER JOIN "Adm_Student_Attendance_Subjects" "d" ON "d"."ASA_Id" = "a"."ASA_Id"
        INNER JOIN "TT_Master_Period" "e" ON "e"."TTMP_Id" = "c"."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" "f" ON "f"."ISMS_Id" = "d"."ISMS_Id"
        WHERE "a"."mi_id" = p_MI_Id 
            AND "asmay_id" = p_ASMAY_Id 
            AND "asmcl_id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id 
            AND "asa_activeflag" = 1
            AND (("a"."ASA_FromDate" BETWEEN p_from AND p_to) OR ("a"."ASA_ToDate" BETWEEN p_from AND p_to))
            AND "a"."ASA_Att_Type" = 'period'
        GROUP BY "b"."AMST_Id", TO_CHAR("ASA_fromDate", 'Month')
    )
    SELECT DISTINCT 
        "AMST_Id",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'January' THEN "PresentCount" END), 0) AS "January",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'February' THEN "PresentCount" END), 0) AS "Febrauary",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'March' THEN "PresentCount" END), 0) AS "March",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'April' THEN "PresentCount" END), 0) AS "April",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'May' THEN "PresentCount" END), 0) AS "May",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'June' THEN "PresentCount" END), 0) AS "June",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'July' THEN "PresentCount" END), 0) AS "July",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'August' THEN "PresentCount" END), 0) AS "August",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'September' THEN "PresentCount" END), 0) AS "September",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'October' THEN "PresentCount" END), 0) AS "October",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'November' THEN "PresentCount" END), 0) AS "November",
        COALESCE(MAX(CASE WHEN TRIM("Months") = 'December' THEN "PresentCount" END), 0) AS "December",
        (COALESCE(MAX(CASE WHEN TRIM("Months") = 'January' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'February' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'March' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'April' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'May' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'June' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'July' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'August' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'September' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'October' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'November' THEN "PresentCount" END), 0) +
         COALESCE(MAX(CASE WHEN TRIM("Months") = 'December' THEN "PresentCount" END), 0)) AS "TotalPresentDays"
    FROM cte
    GROUP BY "AMST_Id"
    ORDER BY "AMST_Id";

    RETURN QUERY
    WITH cte2 AS (
        SELECT * FROM temp_A
    ), cte3 AS (
        SELECT "TotalSchoolDays", "amst_id"
        FROM (
            SELECT SUM("asa_classheld") AS "TotalSchoolDays", "b"."amst_id"
            FROM "adm_student_attendance" "a" 
            INNER JOIN "Adm_Student_Attendance_Students" "b" ON "a"."asa_id" = "b"."asa_id"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "ASA_Activeflag" = 1
                AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id 
                AND (("ASA_FromDate" BETWEEN p_from AND p_to) OR ("ASA_ToDate" BETWEEN p_from AND p_to))
            GROUP BY "amst_id"
        ) "a"
    )
    SELECT 
        cte2."AMST_Id",
        cte2."January",
        cte2."Febrauary",
        cte2."March",
        cte2."April",
        cte2."May",
        cte2."June",
        cte2."July",
        cte2."August",
        cte2."September",
        cte2."October",
        cte2."November",
        cte2."December",
        cte2."TotalPresentDays",
        CAST(((cte2."TotalPresentDays" / NULLIF(cte3."TotalSchoolDays", 0)) * 100) AS NUMERIC(10,2)) AS "Total_Percentage",
        cte3."TotalSchoolDays"
    FROM cte2
    INNER JOIN cte3 ON cte2."AMST_Id" = cte3."amst_id";
    
    RETURN;
END;
$$;