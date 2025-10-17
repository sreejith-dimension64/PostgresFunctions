CREATE OR REPLACE FUNCTION "dbo"."Admission_Get_Continuous_Absent_Attendance_Report"(
    "p_MI_Id" TEXT, 
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "fromdate" DATE,
    "todate" DATE,
    "absentcount" BIGINT,
    "studentname" TEXT,
    "admno" TEXT,
    "classname" TEXT,
    "sectionname" TEXT,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "Adm_Student_Attendance_Temp";
    DROP TABLE IF EXISTS "absent_TestS";
    DROP TABLE IF EXISTS "New_conabsstudents";

    IF "p_ASMS_Id" = '0' THEN
    
        CREATE TEMP TABLE "Adm_Student_Attendance_Temp" AS
        SELECT DISTINCT "AMST_Id", 
            TO_TIMESTAMP("ASA_FromDate", 'DD/MM/YYYY')::TIMESTAMP AS "absent_date",
            CAST("ASA_Class_Attended" AS INTEGER) AS "ASA_Class_Attended"
        FROM "Adm_Student_Attendance" "ASA"
        INNER JOIN "Adm_Student_Attendance_Students" "ASAS" ON "ASA"."ASA_Id" = "ASAS"."ASA_Id"
        WHERE "MI_Id"::TEXT = "p_MI_Id" 
            AND "ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "ASMCL_Id"::TEXT = "p_ASMCL_Id"  
            AND "ASA_Class_Attended" = 0.00;

        CREATE TEMP TABLE "absent_TestS" AS
        WITH "consec_dates" AS (
            SELECT "a".*, 
                CASE 
                    WHEN "absent_date" - LAG("a"."absent_date", 1, "absent_date") OVER (PARTITION BY "AMST_Id" ORDER BY "absent_date") = INTERVAL '1 day'
                        AND "absent_date" - LAG("a"."absent_date", 2, "absent_date") OVER (PARTITION BY "AMST_Id" ORDER BY "absent_date") = INTERVAL '2 days'
                    THEN EXTRACT(DAY FROM ("absent_date" - LAG("a"."absent_date", 3, "absent_date") OVER (PARTITION BY "AMST_Id" ORDER BY "absent_date")))
                    ELSE 0 
                END AS "num_consec_abs"
            FROM "Adm_Student_Attendance_Temp" "a"
        )
        SELECT DISTINCT "a".* 
        FROM "Adm_Student_Attendance_Temp" "a"
        INNER JOIN "consec_dates" "b" ON "a"."AMST_Id" = "b"."AMST_Id"
        WHERE "b"."num_consec_abs" = 3
            AND "a"."absent_date" BETWEEN "b"."absent_date" - INTERVAL '3 days' AND "b"."absent_date";

        CREATE TEMP TABLE "New_conabsstudents" AS
        WITH "dates"("date", "AMST_Id") AS (
            SELECT DISTINCT CAST("absent_date" AS DATE), "AMST_Id" 
            FROM "absent_TestS"
        ),
        "groups" AS (
            SELECT 
                ROW_NUMBER() OVER (ORDER BY "date") AS "rn",
                "date" - (ROW_NUMBER() OVER (ORDER BY "date") * INTERVAL '1 day') AS "grp",
                "date",
                "AMST_Id" 
            FROM "dates"
        )
        SELECT 
            "AMST_Id", 
            COUNT(*) AS "consecutiveDates",
            MIN("date") AS "SDate",
            MAX("date") AS "TDate" 
        FROM "groups"  
        GROUP BY "grp", "AMST_Id";

        RETURN QUERY
        SELECT 
            "a"."AMST_Id", 
            MIN("SDate") AS "fromdate", 
            MAX("TDate") AS "todate", 
            SUM("consecutiveDates") AS "absentcount",
            (COALESCE("c"."AMST_FirstName", '') || ' ' || COALESCE("c"."AMST_MiddleName", '') || ' ' || COALESCE("c"."AMST_LastName", '')) AS "studentname",
            "c"."AMST_AdmNo" AS "admno", 
            "d"."ASMCL_ClassName" AS "classname",
            "e"."ASMC_SectionName" AS "sectionname",
            "d"."ASMCL_Order",
            "e"."ASMC_Order"
        FROM "New_conabsstudents" "a" 
        INNER JOIN "Adm_School_Y_Student" "b" ON "a"."AMST_Id" = "b"."AMST_Id"
        INNER JOIN "Adm_M_Student" "c" ON "c"."AMST_Id" = "b"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" "d" ON "d"."ASMCL_Id" = "b"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "e" ON "e"."ASMS_Id" = "b"."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "f" ON "f"."ASMAY_Id" = "b"."ASMAY_Id"
        WHERE "c"."AMST_SOL" = 'S' 
            AND "c"."AMST_ActiveFlag" = 1 
            AND "f"."AMAY_ActiveFlag" = 1 
            AND "b"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "b"."ASMCL_Id"::TEXT = "p_ASMCL_Id"
        GROUP BY "consecutiveDates", "a"."AMST_Id", "c"."AMST_FirstName", "c"."AMST_MiddleName", "c"."AMST_LastName", 
            "c"."AMST_AdmNo", "d"."ASMCL_ClassName", "d"."ASMCL_Order", "e"."ASMC_Order", "e"."ASMC_SectionName"
        HAVING SUM("consecutiveDates") >= 3
        ORDER BY "d"."ASMCL_Order", "e"."ASMC_Order", "studentname";

    ELSE
    
        CREATE TEMP TABLE "Adm_Student_Attendance_Temp" AS
        SELECT DISTINCT "AMST_Id", 
            TO_TIMESTAMP("ASA_FromDate", 'DD/MM/YYYY')::TIMESTAMP AS "absent_date",
            CAST("ASA_Class_Attended" AS INTEGER) AS "ASA_Class_Attended"
        FROM "Adm_Student_Attendance" "ASA"
        INNER JOIN "Adm_Student_Attendance_Students" "ASAS" ON "ASA"."ASA_Id" = "ASAS"."ASA_Id"
        WHERE "MI_Id"::TEXT = "p_MI_Id" 
            AND "ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "ASMCL_Id"::TEXT = "p_ASMCL_Id" 
            AND "ASMS_Id"::TEXT = "p_ASMS_Id"   
            AND "ASA_Class_Attended" = 0.00;

        CREATE TEMP TABLE "absent_TestS" AS
        WITH "consec_dates" AS (
            SELECT "a".*, 
                CASE 
                    WHEN "absent_date" - LAG("a"."absent_date", 1, "absent_date") OVER (PARTITION BY "AMST_Id" ORDER BY "absent_date") = INTERVAL '1 day'
                        AND "absent_date" - LAG("a"."absent_date", 2, "absent_date") OVER (PARTITION BY "AMST_Id" ORDER BY "absent_date") = INTERVAL '2 days'
                    THEN EXTRACT(DAY FROM ("absent_date" - LAG("a"."absent_date", 3, "absent_date") OVER (PARTITION BY "AMST_Id" ORDER BY "absent_date")))
                    ELSE 0 
                END AS "num_consec_abs"
            FROM "Adm_Student_Attendance_Temp" "a"
        )
        SELECT DISTINCT "a".* 
        FROM "Adm_Student_Attendance_Temp" "a"
        INNER JOIN "consec_dates" "b" ON "a"."AMST_Id" = "b"."AMST_Id"
        WHERE "b"."num_consec_abs" = 3
            AND "a"."absent_date" BETWEEN "b"."absent_date" - INTERVAL '3 days' AND "b"."absent_date";

        CREATE TEMP TABLE "New_conabsstudents" AS
        WITH "dates"("date", "AMST_Id") AS (
            SELECT DISTINCT CAST("absent_date" AS DATE), "AMST_Id" 
            FROM "absent_TestS"
        ),
        "groups" AS (
            SELECT 
                ROW_NUMBER() OVER (ORDER BY "date") AS "rn",
                "date" - (ROW_NUMBER() OVER (ORDER BY "date") * INTERVAL '1 day') AS "grp",
                "date",
                "AMST_Id" 
            FROM "dates"
        )
        SELECT 
            "AMST_Id", 
            COUNT(*) AS "consecutiveDates",
            MIN("date") AS "SDate",
            MAX("date") AS "TDate" 
        FROM "groups"  
        GROUP BY "grp", "AMST_Id";

        RETURN QUERY
        SELECT 
            "a"."AMST_Id", 
            MIN("SDate") AS "fromdate", 
            MAX("TDate") AS "todate", 
            SUM("consecutiveDates") AS "absentcount",
            (COALESCE("c"."AMST_FirstName", '') || ' ' || COALESCE("c"."AMST_MiddleName", '') || ' ' || COALESCE("c"."AMST_LastName", '')) AS "studentname",
            "c"."AMST_AdmNo" AS "admno", 
            "d"."ASMCL_ClassName" AS "classname",
            "e"."ASMC_SectionName" AS "sectionname",
            "d"."ASMCL_Order",
            "e"."ASMC_Order"
        FROM "New_conabsstudents" "a" 
        INNER JOIN "Adm_School_Y_Student" "b" ON "a"."AMST_Id" = "b"."AMST_Id"
        INNER JOIN "Adm_M_Student" "c" ON "c"."AMST_Id" = "b"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" "d" ON "d"."ASMCL_Id" = "b"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "e" ON "e"."ASMS_Id" = "b"."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "f" ON "f"."ASMAY_Id" = "b"."ASMAY_Id"
        WHERE "c"."AMST_SOL" = 'S' 
            AND "c"."AMST_ActiveFlag" = 1 
            AND "f"."AMAY_ActiveFlag" = 1 
            AND "b"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "b"."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
            AND "b"."ASMS_Id"::TEXT = "p_ASMS_Id"
        GROUP BY "consecutiveDates", "a"."AMST_Id", "c"."AMST_FirstName", "c"."AMST_MiddleName", "c"."AMST_LastName", 
            "c"."AMST_AdmNo", "d"."ASMCL_ClassName", "d"."ASMCL_Order", "e"."ASMC_Order", "e"."ASMC_SectionName"
        HAVING SUM("consecutiveDates") >= 3
        ORDER BY "d"."ASMCL_Order", "e"."ASMC_Order", "studentname";

    END IF;

    DROP TABLE IF EXISTS "Adm_Student_Attendance_Temp";
    DROP TABLE IF EXISTS "absent_TestS";
    DROP TABLE IF EXISTS "New_conabsstudents";

END;
$$;