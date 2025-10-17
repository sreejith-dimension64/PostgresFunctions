CREATE OR REPLACE FUNCTION "dbo"."Attendance_monthwise_category"(
    "ASMAY_Id" VARCHAR,
    "ASMCL_Id" VARCHAR,
    "ASMS_Id" VARCHAR,
    "fromdate" VARCHAR,
    "todate" VARCHAR,
    "type" VARCHAR,
    "radiotype" VARCHAR,
    "AMST_Id" VARCHAR,
    "monthid" VARCHAR,
    "mi_id" VARCHAR,
    "datewise" VARCHAR,
    "AMC_Id" VARCHAR
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "Query" TEXT;
    "Year" INT := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    "sqlquery" TEXT;
    "CursorInput1" REFCURSOR;
    "cursorValue" VARCHAR;
    "Cl" VARCHAR;
    "C2" VARCHAR;
    "query1" TEXT;
    "cols" VARCHAR;
    "monthyearsd" VARCHAR;
    "monthyearsd1" VARCHAR;
    "cols1" VARCHAR;
    "category" TEXT;
    "startDate" DATE;
    "endDate" DATE;
    "rec" RECORD;
BEGIN

    IF "AMC_Id" != '0' AND "AMC_Id" != '' THEN
        "category" := 'and "Adm_M_Category"."AMC_Id" = ' || "AMC_Id";
    ELSE
        "category" := '';
    END IF;

    DROP TABLE IF EXISTS "NewTablemonth";
    CREATE TEMP TABLE "NewTablemonth"(
        "id" SERIAL NOT NULL,
        "MonthId" INT,
        "AYear" INT
    );

    SELECT "ASMAY_From_Date" INTO "startDate" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "mi_id"::INT AND "ASMAY_Id" = "ASMAY_Id"::INT;

    SELECT "ASMAY_To_Date" INTO "endDate" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "mi_id"::INT AND "ASMAY_Id" = "ASMAY_Id"::INT;

    WITH RECURSIVE CTE AS (
        SELECT "startDate"::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 month')::DATE 
        FROM CTE 
        WHERE ("Dates" + INTERVAL '1 month')::DATE <= "endDate"::DATE
    )
    INSERT INTO "NewTablemonth"("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM "Dates")::INT, EXTRACT(YEAR FROM "Dates")::INT 
    FROM CTE;

    SELECT "AYear" INTO "Year" 
    FROM "NewTablemonth" 
    WHERE "monthid" = "monthid"::INT
    LIMIT 1;

    DROP TABLE IF EXISTS "dbo"."calender";
    CREATE TEMP TABLE "calender"("day" INT, "date" VARCHAR(50));

    "fromdate" := TO_CHAR(TO_DATE("fromdate", 'MM/DD/YYYY'), 'DD/MM/YYYY');
    "todate" := TO_CHAR(TO_DATE("todate", 'MM/DD/YYYY'), 'DD/MM/YYYY');

    IF "type"::INT = 1 AND "radiotype"::INT = 1 AND "AMST_Id"::INT = 0 THEN
        IF "datewise"::INT = 0 THEN
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
                 SUM("Adm_Student_Attendance"."ASA_ClassHeld")::NUMERIC * 100) AS "Percentage"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
            INNER JOIN "dbo"."Adm_Student_Attendance" 
                ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_M_Category" 
                ON "Adm_M_Category"."amc_id" = "Adm_M_Student"."amc_id"
            WHERE "Adm_Student_Attendance"."ASMAY_Id" = "ASMAY_Id"::INT
                AND "Adm_Student_Attendance"."ASMCL_Id" = "ASMCL_Id"::INT
                AND "Adm_School_Y_Student"."ASMCL_Id" = "ASMCL_Id"::INT
                AND "Adm_School_Y_Student"."ASMS_Id" = "ASMS_Id"::INT
                AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::INT
                AND "Adm_Student_Attendance"."ASMS_Id" = "ASMS_Id"::INT
                AND "ASA_Activeflag" = 1
                AND "Adm_Student_Attendance"."MI_Id" = "mi_id"::INT
                AND EXTRACT(MONTH FROM "Adm_Student_Attendance"."ASA_FromDate") = "monthid"::INT
                AND "Adm_M_Student"."AMST_SOL" = 'S'
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
                AND "Adm_M_Category"."amc_id" = "AMC_Id"::INT
            GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                     "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";
        ELSE
            "Query" := 'WITH N(N) AS (
                SELECT 1 FROM (VALUES(1),(1),(1),(1),(1),(1)) M(N)
            ),
            tally(N) AS (
                SELECT ROW_NUMBER() OVER(ORDER BY N.N) FROM N, N a
            )
            SELECT N::INT as day, 
                   REPLACE(TO_CHAR(MAKE_DATE(' || "Year"::VARCHAR || ',' || "monthid" || ',N::INT), ''DD/MM/YYYY''), '' '', ''-'') as date 
            FROM tally
            WHERE N <= EXTRACT(DAY FROM (DATE_TRUNC(''MONTH'', MAKE_DATE(' || "Year"::VARCHAR || ',' || "monthid" || ',1)) + INTERVAL ''1 MONTH'' - INTERVAL ''1 DAY''))';

            EXECUTE 'INSERT INTO "calender"("day", "date") ' || "Query";

            "monthyearsd" := '';
            "monthyearsd1" := '';

            FOR "rec" IN SELECT "date", "day" FROM "calender" LOOP
                "cols" := "rec"."date";
                "cols1" := "rec"."day";
                
                "monthyearsd" := COALESCE("monthyearsd", '') || COALESCE('"' || "cols1" || '", ', '');
                
                "monthyearsd1" := COALESCE("monthyearsd1", '') || 
                    'CASE WHEN "' || "cols1" || '" = 1.00 THEN ''P'' ' ||
                    'WHEN "' || "cols1" || '" = 0.00 THEN ''A'' ' ||
                    'WHEN "' || "cols1" || '" = 0.50 THEN ''H'' ' ||
                    'WHEN TO_CHAR(TO_DATE(''' || "cols" || ''', ''DD-MM-YYYY''), ''Day'') = ''Sunday'' THEN ''S'' ' ||
                    'WHEN (SELECT COUNT(*) FROM "FO"."FO_HolidayWorkingDay_Type" "FHDT" ' ||
                    'INNER JOIN "FO"."FO_Master_HolidayWorkingDay" "FMH" ON "FHDT"."FOHWDT_Id" = "FMH"."FOHWDT_Id" ' ||
                    'INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHD" ON "FMHD"."FOHWDT_Id" = "FMH"."FOHWDT_Id" ' ||
                    'WHERE "FHDT"."mi_id" = ' || "mi_id" || ' AND "FHDT"."FOHTWD_HolidayWDTypeFlag" = ''PH'' ' ||
                    'AND TO_DATE("FMHD"."FOMHWDD_FromDate"::TEXT, ''DD/MM/YYYY'') >= TO_DATE(''' || "cols" || ''', ''DD-MM-YYYY'') ' ||
                    'OR TO_DATE("FMHD"."FOMHWDD_ToDate"::TEXT, ''DD/MM/YYYY'') <= TO_DATE(''' || "cols" || ''', ''DD-MM-YYYY'')) > 0 THEN ''HO'' ' ||
                    'ELSE ''NE'' END AS "' || "cols1" || '", ';
            END LOOP;

            "monthyearsd" := LEFT("monthyearsd", LENGTH("monthyearsd") - 2);
            "monthyearsd1" := LEFT("monthyearsd1", LENGTH("monthyearsd1") - 2);

            "query1" := 'SELECT "name", "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", "AMST_Id", "amst_sex", ' || 
                       "monthyearsd1" || ' FROM (
                SELECT 
                    (COALESCE(d."AMST_FirstName", '''') || '' '' || COALESCE(d."AMST_MiddleName", '''') || '' '' || COALESCE(d."AMST_LastName", '''')) AS "name",
                    d."AMST_AdmNo",
                    d."AMST_RegistrationNo",
                    c."AMAY_RollNo",
                    "ASA_Class_Attended" AS "TOTAL_PRESENT",
                    c."AMST_Id",
                    (CASE WHEN d."amst_sex" = ''Female'' THEN ''F'' ELSE ''M'' END) AS "amst_sex",
                    EXTRACT(DAY FROM TO_DATE(a."ASA_FromDate"::TEXT, ''DD/MM/YYYY''))::INT AS "MONTH_NAME"
                FROM "adm_student_attendance" a
                INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id"
                INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = d."amc_id"
                WHERE c."ASMAY_Id" = ' || "asmay_id" || '
                    AND a."MI_Id" = ' || "mi_id" || '
                    AND c."ASMCL_Id" = ' || "asmcl_id" || '
                    AND c."ASMS_Id" = ' || "asms_id" || '
                    AND a."ASMCL_Id" = ' || "asmcl_id" || '
                    AND a."ASMS_Id" = ' || "asms_id" || '
                    AND "amst_sol" = ''S''
                    AND "amst_activeflag" = 1
                    AND "amay_activeflag" = 1
                    AND "ASA_Activeflag" = 1
                    AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || "monthid" || '
                    AND "Adm_M_Category"."amc_id" = ' || "AMC_Id" || '
                    AND EXTRACT(YEAR FROM a."asa_fromdate") = ' || "Year"::VARCHAR || '
            ) AS s
            PIVOT (SUM("TOTAL_PRESENT") FOR "MONTH_NAME" IN(' || "monthyearsd" || '))';

            EXECUTE "query1";
        END IF;
    ELSIF "type"::INT = 1 AND "radiotype"::INT = 2 AND "AMST_Id"::INT = 0 THEN
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
             SUM("Adm_Student_Attendance"."ASA_ClassHeld")::NUMERIC * 100) AS "Percentage"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
            ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_M_Category" 
            ON "Adm_M_Category"."amc_id" = "Adm_M_Student"."amc_id"
        WHERE "Adm_Student_Attendance"."ASMAY_Id" = "ASMAY_Id"::INT
            AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::INT
            AND "Adm_Student_Attendance"."ASMCL_Id" = "ASMCL_Id"::INT
            AND "Adm_Student_Attendance"."ASMS_Id" = "ASMS_Id"::INT
            AND "Adm_Student_Attendance"."MI_Id" = "mi_id"::INT
            AND "ASA_Activeflag" = 1
            AND TO_DATE("Adm_Student_Attendance"."ASA_FromDate"::TEXT, 'DD/MM/YYYY') 
                BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY')
            AND "AMST_SOL" = 'S'
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."ASMCL_Id" = "ASMCL_Id"::INT
            AND "Adm_School_Y_Student"."ASMS_Id" = "ASMS_Id"::INT
            AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::INT
            AND "Adm_M_Category"."amc_id" = "AMC_Id"::INT
        GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                 "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";
    ELSIF "type"::INT = 1 AND "radiotype"::INT = 3 AND "AMST_Id"::INT = 0 THEN
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
             SUM("Adm_Student_Attendance"."ASA_ClassHeld")::NUMERIC * 100) AS "Percentage"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
            ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "Adm_M_Category" 
            ON "Adm_M_Category"."amc_id" = "Adm_M_Student"."amc_id"
        WHERE "Adm_Student_Attendance"."ASMAY_Id" = "ASMAY_Id"::INT
            AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::INT
            AND "Adm_Student_Attendance"."ASMCL_Id" = "ASMCL_Id"::INT
            AND "Adm_Student_Attendance"."ASMS_Id" = "ASMS_Id"::INT
            AND "Adm_Student_Attendance"."MI_Id" = "mi_id"::INT
            AND "ASA_Activeflag" = 1
            AND TO_DATE("Adm_Student_Attendance"."ASA_FromDate"::TEXT, 'DD/MM/YYYY') = TO_DATE("fromdate", 'DD/MM/YYYY')
            AND "AMST_SOL" = 'S'
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."ASMCL_Id" = "ASMCL_Id"::INT
            AND "Adm_School_Y_Student"."ASMS_Id" = "ASMS_Id"::INT
            AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::INT
            AND "Adm_M_Category"."amc_id" = "AMC_Id"::INT
        GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                 "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";
    ELSIF "type"::INT = 2 AND "radiotype"::INT = 1 AND "AMST_Id"::INT != 0 THEN
        IF "datewise"::INT = 0 THEN
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
                 SUM("Adm_Student_Attendance"."ASA_ClassHeld")::NUMERIC * 100) AS "Percentage"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
            INNER JOIN "dbo"."Adm_Student_Attendance" 
                ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_M_Category" 
                ON "Adm_M_Category"."amc_id" = "Adm_M_Student"."amc_id"
            WHERE "Adm_Student_Attendance"."ASMAY_Id" = "ASMAY_Id"::INT
                AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::INT
                AND "Adm_Student_Attendance"."ASMCL_Id" = "ASMCL_Id"::INT
                AND "Adm_Student_Attendance"."ASMS_Id" = "ASMS_Id"::INT
                AND "Adm_Student_Attendance"."MI_Id" = "mi_id"::INT
                AND EXTRACT(MONTH FROM "Adm_Student_Attendance"."ASA_FromDate") = "monthid"::INT
                AND "ASA_Activeflag" = 1
                AND "AMST_SOL" = 'S'
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."ASMCL_Id" = "ASMCL_Id"::INT
                AND "Adm_School_Y_Student"."ASMS_Id" = "ASMS_Id"::INT
                AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"::INT
                AND "Adm_M_Student"."AMST_Id" = "AMST_Id"::INT
                AND "Adm_M_Category"."amc_id" = "AMC_Id"::INT
            GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                     "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";
        ELSE
            "Query" := 'WITH N(N) AS (
                SELECT 1 FROM (VALUES(1),(1),(1),(1),(1),(1)) M(N)
            ),
            tally(N) AS (
                SELECT ROW_NUMBER() OVER(ORDER BY N.N) FROM N, N a
            )
            SELECT N::INT as day, 
                   REPLACE(TO_CHAR(MAKE_DATE(' || "Year"::VARCHAR || ',' || "monthid" || ',N::INT), ''DD/MM/YYYY''), '' '', ''-'') as date 
            FROM tally
            WHERE N <= EXTRACT(DAY FROM (DATE_TRUNC(''MONTH'', MAKE_DATE(' || "Year"::VARCHAR || ',' || "monthid" || ',1)) + INTERVAL ''1 MONTH'' - INTERVAL ''1 DAY''))';

            EXECUTE 'INSERT INTO "calender"("day", "date") ' || "Query";

            "monthyearsd" := '';
            "monthyearsd1" := '';

            FOR "rec" IN SELECT "date", "day" FROM "calender" LOOP
                "cols" := "rec"."date";
                "cols1" := "rec"."day";
                
                "monthyearsd" := COALESCE("monthyearsd", '') || COALESCE('"' || "cols1" || '", ', '');
                
                "monthyearsd1" := COALESCE("monthyearsd1", '') || 
                    'CASE WHEN "' || "cols1" || '" = 1.00 THEN ''P'' ' ||
                    'WHEN "' || "cols1" || '" = 0.00 THEN ''A'' ' ||
                    'WHEN "' || "cols1" || '" = 0.50 THEN ''H'' ' ||
                    'WHEN TO_CHAR(TO_DATE(''' || "cols" || ''', ''DD-MM-YYYY''), ''Day'') = ''Sunday'' THEN ''S'' ' ||
                    'WHEN (SELECT COUNT(*) FROM "fo"."FO_HolidayWorkingDay_Type" a ' ||
                    'INNER JOIN "fo"."FO_Master_HolidayWorkingDay" b ON a."FOHWDT_Id" = b."FOHWDT_Id" ' ||
                    'INNER JOIN "fo"."FO_Master_HolidayWorkingDay_dates" c ON c."FOHWDT_Id" = b."FOHWDT_Id" ' ||
                    'WHERE a."mi_id" = ' || "mi_id" || ' AND a."FOHTWD_HolidayWDTypeFlag" = ''PH'' ' ||
                    'AND TO_DATE(c."FOMHWDD_FromDate"::TEXT, ''DD/MM/YYYY'') >= TO_DATE(''' || "cols" || ''', ''DD-MM-YYYY'') ' ||
                    'OR TO_DATE(c."FOMHWDD_ToDate"::TEXT, ''DD/MM/YYYY'') <= TO_DATE(''' || "cols" || ''', ''DD-MM-YYYY'')) > 0 THEN ''HO'' ' ||
                    'ELSE ''NE'' END AS "' || "cols1" || '", ';
            END LOOP;

            "monthyearsd" := LEFT("monthyearsd", LENGTH("monthyearsd") - 2);
            "monthyearsd1" := LEFT("monthyearsd1", LENGTH("monthyearsd1") - 2);

            "query1" := 'SELECT "name", "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", "AMST_Id", ' || 
                       "monthyearsd1" || ' FROM (
                SELECT 
                    c."AMST_Id",
                    (COALESCE(d."AMST_FirstName", '''') || '' '' || COALESCE(d."AMST_MiddleName", '''') || '' '' || COALESCE(d."AMST_LastName", '''')) AS "name",
                    d."AMST_AdmNo",
                    d."AMST_RegistrationNo",
                    c."AMAY_RollNo",
                    "ASA_Class_Attended" AS "TOTAL_PRESENT",
                    EXTRACT(DAY FROM TO_DATE(a."ASA_FromDate"::TEXT, ''DD/MM/YYYY''))::INT AS "MONTH_NAME"
                FROM "adm_student_attendance" a
                INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id"
                INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_