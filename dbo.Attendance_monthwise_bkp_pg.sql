CREATE OR REPLACE FUNCTION "dbo"."Attendance_monthwise_bkp" (
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_fromdate" TEXT,
    "p_todate" TEXT,
    "p_type" TEXT,
    "p_radiotype" TEXT,
    "p_AMST_Id" TEXT,
    "p_monthid" TEXT,
    "p_mi_id" TEXT,
    "p_datewise" TEXT,
    "p_AMC_Id" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_Query TEXT;
    v_Year INT := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    v_sqlquery TEXT;
    v_cursorValue TEXT;
    v_Cl TEXT;
    v_C2 TEXT;
    v_query1 TEXT;
    v_cols TEXT;
    v_monthyearsd TEXT := '';
    v_monthyearsd1 TEXT := '';
    v_cols1 TEXT;
    v_startDate DATE;
    v_endDate DATE;
    v_rec RECORD;
BEGIN

    CREATE TEMP TABLE IF NOT EXISTS "NewTablemonth" (
        "id" SERIAL NOT NULL,
        "MonthId" INT,
        "AYear" INT
    ) ON COMMIT DROP;

    SELECT "ASMAY_From_Date" INTO v_startDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "p_mi_id"::BIGINT AND "ASMAY_Id" = "p_ASMAY_Id"::BIGINT;
    
    SELECT "ASMAY_To_Date" INTO v_endDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "p_mi_id"::BIGINT AND "ASMAY_Id" = "p_ASMAY_Id"::BIGINT;

    WITH RECURSIVE CTE AS (
        SELECT v_startDate::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 MONTH')::DATE 
        FROM CTE 
        WHERE ("Dates" + INTERVAL '1 MONTH')::DATE <= v_endDate::DATE
    )
    INSERT INTO "NewTablemonth" ("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM "Dates")::INT AS "Month", 
           EXTRACT(YEAR FROM "Dates")::INT AS "Year" 
    FROM CTE;

    SELECT "AYear" INTO v_Year 
    FROM "NewTablemonth" 
    WHERE "monthid" = "p_monthid"::INT;

    DROP TABLE IF EXISTS "calender";
    CREATE TEMP TABLE "calender" (
        "day" INT, 
        "date" VARCHAR(50)
    ) ON COMMIT DROP;

    "p_fromdate" := TO_CHAR(TO_DATE("p_fromdate", 'YYYY-MM-DD'), 'DD-MM-YYYY');
    "p_todate" := TO_CHAR(TO_DATE("p_todate", 'YYYY-MM-DD'), 'DD-MM-YYYY');

    IF "p_type"::INT = 1 AND "p_radiotype"::INT = 1 AND "p_AMST_Id"::INT = 0 THEN

        IF "p_datewise"::INT = 0 THEN

            RETURN QUERY
            SELECT 
                "Adm_M_Student"."AMST_Id", 
                (COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || 
                 COALESCE("Adm_M_Student"."Amst_MiddleName", '') || ' ' || 
                 COALESCE("Adm_M_Student"."Amst_LastName", '')) AS "name",
                "Adm_M_Student"."AMST_AdmNo", 
                "Adm_School_Y_Student"."AMAY_RollNo",
                SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS "ASA_ClassHeld",
                SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "ASA_Class_Attended",
                (SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended")::NUMERIC / 
                 SUM("Adm_Student_Attendance"."ASA_ClassHeld") * 100) AS "Percentage"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
            INNER JOIN "dbo"."Adm_Student_Attendance" 
                ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
                AND "Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
                AND "Adm_Student_Attendance"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
                AND "Adm_Student_Attendance"."ASMS_Id" = "p_ASMS_Id"::BIGINT
                AND "Adm_Student_Attendance"."MI_Id" = "p_mi_id"::BIGINT
                AND EXTRACT(MONTH FROM "Adm_Student_Attendance"."ASA_FromDate") = "p_monthid"::INT
                AND "Adm_M_Student"."AMST_SOL" = 'S'
                AND "Adm_Student_Attendance"."ASA_Activeflag" = 1
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
            GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                     "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";

        ELSE

            v_Query := 'WITH RECURSIVE N AS (
                SELECT 1 AS n FROM generate_series(1, 6)
            ),
            tally AS (
                SELECT ROW_NUMBER() OVER (ORDER BY n) AS n FROM N, N a
            )
            SELECT n AS day, 
                   TO_CHAR(TO_DATE(' || v_Year || ' || ''-'' || ' || "p_monthid" || ' || ''-'' || n, ''YYYY-MM-DD''), ''DD-MM-YYYY'') AS date 
            FROM tally 
            WHERE n <= EXTRACT(DAY FROM (DATE_TRUNC(''MONTH'', TO_DATE(' || v_Year || ' || ''-'' || ' || "p_monthid" || ' || ''-01'', ''YYYY-MM-DD'')) + INTERVAL ''1 MONTH'' - INTERVAL ''1 DAY''))';

            EXECUTE v_Query;

            FOR v_rec IN 
                SELECT "date", "day" FROM "calender"
            LOOP
                v_cols := v_rec."date";
                v_cols1 := v_rec."day"::TEXT;
                
                v_monthyearsd := COALESCE(v_monthyearsd, '') || '[' || v_cols1 || '], ';
                
                v_monthyearsd1 := COALESCE(v_monthyearsd1, '') || 
                    'CASE WHEN [' || v_cols1 || '] = 1.00 THEN ''P'' ' ||
                    'WHEN [' || v_cols1 || '] = 0.00 THEN ''A'' ' ||
                    'WHEN [' || v_cols1 || '] = 0.50 THEN ''H'' ' ||
                    'WHEN TO_CHAR(TO_DATE(''' || v_cols || ''', ''DD-MM-YYYY''), ''Day'') = ''Sunday'' THEN ''S'' ' ||
                    'WHEN (SELECT COUNT(*) FROM "FO"."FO_HolidayWorkingDay_Type" "FHDT" ' ||
                    'INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHD" ON "FMHD"."FOHWDT_Id" = "FHDT"."FOHWDT_Id" ' ||
                    'WHERE "FHDT"."mi_id" = ' || "p_mi_id" || ' AND "FHDT"."FOHTWD_HolidayWDTypeFlag" = ''PH'' ' ||
                    'AND "FMHD"."mi_id" = ' || "p_mi_id" || ' ' ||
                    'AND TO_DATE("FMHD"."FOMHWDD_FromDate"::TEXT, ''DD-MM-YYYY'') = TO_DATE(''' || v_cols || ''', ''DD-MM-YYYY'')) > 0 THEN ''HO'' ' ||
                    'ELSE ''NE'' END AS [' || v_cols1 || '], ';
            END LOOP;

            v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);
            v_monthyearsd1 := LEFT(v_monthyearsd1, LENGTH(v_monthyearsd1) - 2);

            v_query1 := 'SELECT name, "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", "AMST_Id", ' || v_monthyearsd1 || 
                ' FROM (SELECT DISTINCT ' ||
                '(COALESCE(d."AMST_FirstName", '''') || '' '' || COALESCE(d."AMST_MiddleName", '''') || '' '' || COALESCE(d."AMST_LastName", '''')) AS name, ' ||
                'd."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo", ' ||
                '"ASA_Class_Attended" AS "TOTAL_PRESENT", c."AMST_Id", ' ||
                'EXTRACT(DAY FROM a."ASA_FromDate") AS "MONTH_NAME" ' ||
                'FROM "adm_student_attendance" a ' ||
                'INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id" ' ||
                'INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id" ' ||
                'INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" ' ||
                'WHERE c."ASMAY_Id" = ' || "p_asmay_id" || ' AND a."MI_Id" = ' || "p_mi_id" || 
                ' AND c."ASMCL_Id" = ' || "p_asmcl_id" || ' AND c."ASMS_Id" = ' || "p_asms_id" ||
                ' AND "amst_sol" = ''S'' AND "ASA_Activeflag" = 1 AND "amst_activeflag" = 1 AND "amay_activeflag" = 1 ' ||
                'AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || "p_monthid" || 
                ' AND EXTRACT(YEAR FROM a."asa_fromdate") = ' || v_Year ||
                ') AS s PIVOT (SUM("TOTAL_PRESENT") FOR "MONTH_NAME" IN(' || v_monthyearsd || ')) AS p';

            RETURN QUERY EXECUTE v_query1;

        END IF;

    ELSIF "p_type"::INT = 1 AND "p_radiotype"::INT = 2 AND "p_AMST_Id"::INT = 0 THEN

        RETURN QUERY
        SELECT 
            "Adm_M_Student"."AMST_Id", 
            (COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || 
             COALESCE("Adm_M_Student"."Amst_MiddleName", '') || ' ' || 
             COALESCE("Adm_M_Student"."Amst_LastName", '')) AS "name",
            "Adm_M_Student"."AMST_AdmNo", 
            "Adm_School_Y_Student"."AMAY_RollNo",
            SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS "ASA_ClassHeld",
            SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "ASA_Class_Attended",
            (SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended")::NUMERIC / 
             SUM("Adm_Student_Attendance"."ASA_ClassHeld") * 100) AS "Percentage"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
            ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        WHERE "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
            AND "Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
            AND "Adm_Student_Attendance"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
            AND "Adm_Student_Attendance"."ASMS_Id" = "p_ASMS_Id"::BIGINT
            AND "Adm_Student_Attendance"."MI_Id" = "p_mi_id"::BIGINT
            AND "Adm_Student_Attendance"."ASA_FromDate" BETWEEN TO_DATE("p_fromdate", 'DD-MM-YYYY') 
                AND TO_DATE("p_todate", 'DD-MM-YYYY')
            AND "Adm_M_Student"."AMST_SOL" = 'S'
            AND "Adm_Student_Attendance"."ASA_Activeflag" = 1
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                 "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";

    ELSIF "p_type"::INT = 1 AND "p_radiotype"::INT = 3 AND "p_AMST_Id"::INT = 0 THEN

        RETURN QUERY
        SELECT 
            "Adm_M_Student"."AMST_Id", 
            (COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || 
             COALESCE("Adm_M_Student"."Amst_MiddleName", '') || ' ' || 
             COALESCE("Adm_M_Student"."Amst_LastName", '')) AS "name",
            "Adm_M_Student"."AMST_AdmNo", 
            "Adm_School_Y_Student"."AMAY_RollNo",
            SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS "ASA_ClassHeld",
            SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "ASA_Class_Attended",
            (SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended")::NUMERIC / 
             SUM("Adm_Student_Attendance"."ASA_ClassHeld") * 100) AS "Percentage"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
            ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        WHERE "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
            AND "Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
            AND "Adm_Student_Attendance"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
            AND "Adm_Student_Attendance"."ASMS_Id" = "p_ASMS_Id"::BIGINT
            AND "Adm_Student_Attendance"."MI_Id" = "p_mi_id"::BIGINT
            AND "Adm_Student_Attendance"."ASA_FromDate" = TO_DATE("p_fromdate", 'DD-MM-YYYY')
            AND "Adm_M_Student"."AMST_SOL" = 'S'
            AND "Adm_Student_Attendance"."ASA_Activeflag" = 1
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                 "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";

    ELSIF "p_type"::INT = 2 AND "p_radiotype"::INT = 1 AND "p_AMST_Id"::INT != 0 THEN

        IF "p_datewise"::INT = 0 THEN

            RETURN QUERY
            SELECT 
                "Adm_M_Student"."AMST_Id", 
                (COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || 
                 COALESCE("Adm_M_Student"."Amst_MiddleName", '') || ' ' || 
                 COALESCE("Adm_M_Student"."Amst_LastName", '')) AS "name",
                "Adm_M_Student"."AMST_AdmNo", 
                "Adm_School_Y_Student"."AMAY_RollNo",
                SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS "ASA_ClassHeld",
                SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "ASA_Class_Attended",
                (SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended")::NUMERIC / 
                 SUM("Adm_Student_Attendance"."ASA_ClassHeld") * 100) AS "Percentage"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
            INNER JOIN "dbo"."Adm_Student_Attendance" 
                ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
                AND "Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
                AND "Adm_Student_Attendance"."ASMCL_Id" = "p_ASMCL_Id"::BIGINT
                AND "Adm_Student_Attendance"."ASMS_Id" = "p_ASMS_Id"::BIGINT
                AND "Adm_Student_Attendance"."MI_Id" = "p_mi_id"::BIGINT
                AND EXTRACT(MONTH FROM "Adm_Student_Attendance"."ASA_FromDate") = "p_monthid"::INT
                AND "Adm_M_Student"."AMST_SOL" = 'S'
                AND "Adm_Student_Attendance"."ASA_Activeflag" = 1
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
                AND "Adm_M_Student"."AMST_Id" = "p_AMST_Id"::BIGINT
            GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                     "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";

        ELSE

            v_Query := 'WITH RECURSIVE N AS (
                SELECT 1 AS n FROM generate_series(1, 6)
            ),
            tally AS (
                SELECT ROW_NUMBER() OVER (ORDER BY n) AS n FROM N, N a
            )
            SELECT n AS day, 
                   TO_CHAR(TO_DATE(' || v_Year || ' || ''-'' || ' || "p_monthid" || ' || ''-'' || n, ''YYYY-MM-DD''), ''DD-MM-YYYY'') AS date 
            FROM tally 
            WHERE n <= EXTRACT(DAY FROM (DATE_TRUNC(''MONTH'', TO_DATE(' || v_Year || ' || ''-'' || ' || "p_monthid" || ' || ''-01'', ''YYYY-MM-DD'')) + INTERVAL ''1 MONTH'' - INTERVAL ''1 DAY''))';

            EXECUTE v_Query;

            FOR v_rec IN 
                SELECT "date", "day" FROM "calender"
            LOOP
                v_cols := v_rec."date";
                v_cols1 := v_rec."day"::TEXT;
                
                v_monthyearsd := COALESCE(v_monthyearsd, '') || '[' || v_cols1 || '], ';
                
                v_monthyearsd1 := COALESCE(v_monthyearsd1, '') || 
                    'CASE WHEN [' || v_cols1 || '] = 1.00 THEN ''P'' ' ||
                    'WHEN [' || v_cols1 || '] = 0.00 THEN ''A'' ' ||
                    'WHEN [' || v_cols1 || '] = 0.50 THEN ''H'' ' ||
                    'WHEN TO_CHAR(TO_DATE(''' || v_cols || ''', ''DD-MM-YYYY''), ''Day'') = ''Sunday'' THEN ''S'' ' ||
                    'WHEN (SELECT COUNT(*) FROM "FO"."FO_HolidayWorkingDay_Type" a ' ||
                    'INNER JOIN "fo"."FO_Master_HolidayWorkingDay_dates" c ON c."FOMHWDT_Id" = a."FOMHWDT_Id" ' ||
                    'WHERE a."mi_id" = ' || "p_mi_id" || ' AND a."FOHTWD_HolidayWDTypeFlag" = ''PH'' ' ||
                    'AND TO_DATE(c."fomhwdd_date"::TEXT, ''DD-MM-YYYY'') = TO_DATE(''' || v_cols || ''', ''DD-MM-YYYY'')) > 0 THEN ''HO'' ' ||
                    'ELSE ''NE'' END AS [' || v_cols1 || '], ';
            END LOOP;

            v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);
            v_monthyearsd1 := LEFT(v_monthyearsd1, LENGTH(v_monthyearsd1) - 2);

            v_query1 := 'SELECT name, "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", "AMST_Id", ' || v_monthyearsd1 || 
                ' FROM (SELECT DISTINCT c."AMST_Id", ' ||
                '(COALESCE(d."AMST_FirstName", '''') || '' '' || COALESCE(d."AMST_MiddleName", '''') || '' '' || COALESCE(d."AMST_LastName", '''')) AS name, ' ||
                'd."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo", ' ||
                '"ASA_Class_Attended" AS "TOTAL_PRESENT", ' ||
                'EXTRACT(DAY FROM a."ASA_FromDate") AS "MONTH_NAME" ' ||
                'FROM "adm_student_attendance" a ' ||
                'INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id" ' ||
                'INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id" ' ||
                'INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" ' ||
                'WHERE c."ASMAY_Id" = ' || "p_asmay_id" || ' AND a."MI_Id" = ' || "p_mi_id" || 
                ' AND c."ASMCL_Id" = ' || "p_asmcl_id" || ' AND c."ASMS_Id" = ' || "p_asms_id" ||
                ' AND "amst_sol" = ''S'' AND "ASA_Activeflag" = 1 AND "amst_activeflag" = 1 AND "amay_activeflag" = 1 ' ||
                'AND c."amst_id" = ' || "p_AMST_Id" ||
                ' AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || "p_monthid" || 
                ' AND EXTRACT(YEAR FROM a."asa_fromdate") = ' || v_Year ||
                ') AS s PIVOT (SUM("TOTAL_PRESENT") FOR "MONTH_NAME" IN(' || v_monthyearsd || ')) AS p';

            RETURN QUERY EXECUTE v_query1;

        END IF;

    ELSIF "p_type"::INT = 2 AND "p_radiotype"::INT = 2 AND "p_AMST_Id"::INT != 0 THEN

        RETURN QUERY
        SELECT 
            "Adm_M_Student"."AMST_Id", 
            (COALESCE("Adm_M_Student"."AMST_FirstName", '') || ' ' || 
             COALESCE("Adm_M_Student"."Amst_MiddleName", '') || ' ' || 
             COALESCE("Adm_M_Student"."Amst_LastName", '')) AS "name",
            "Adm_M_Student"."AMST_AdmNo", 
            "Adm_School_Y_Student"."AMAY_RollNo",
            SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS "ASA_ClassHeld",
            SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "ASA_Class_Attended",
            (SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended")::NUMERIC / 
             SUM("Adm_Student_Attendance"."ASA_ClassHeld") * 100) AS "Percentage"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
            ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        WHERE "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT
            AND "Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id"::BIG