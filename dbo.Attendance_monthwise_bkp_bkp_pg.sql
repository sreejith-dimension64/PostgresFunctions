CREATE OR REPLACE FUNCTION "dbo"."Attendance_monthwise_bkp_bkp"(
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
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "name" TEXT,
    "AMST_AdmNo" TEXT,
    "AMAY_RollNo" TEXT,
    "ASA_ClassHeld" NUMERIC,
    "ASA_Class_Attended" NUMERIC,
    "Percentage" NUMERIC,
    "AMST_RegistrationNo" TEXT,
    "result_data" JSONB
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Query" TEXT;
    "v_Year" INTEGER;
    "v_sqlquery" TEXT;
    "v_cursorValue" TEXT;
    "v_Cl" TEXT;
    "v_C2" TEXT;
    "v_query1" TEXT;
    "v_cols" TEXT;
    "v_monthyearsd" TEXT := '';
    "v_monthyearsd1" TEXT := '';
    "v_cols1" TEXT;
    "v_startDate" DATE;
    "v_endDate" DATE;
    "v_date_val" TEXT;
    "v_day_val" TEXT;
    "v_rec" RECORD;
BEGIN
    "v_Year" := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);

    DROP TABLE IF EXISTS "temp_NewTablemonth";
    CREATE TEMP TABLE "temp_NewTablemonth"(
        "id" SERIAL,
        "MonthId" INTEGER,
        "AYear" INTEGER
    );

    SELECT "ASMAY_From_Date" INTO "v_startDate" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "p_mi_id"::INTEGER AND "ASMAY_Id" = "p_ASMAY_Id"::INTEGER;

    SELECT "ASMAY_To_Date" INTO "v_endDate" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "p_mi_id"::INTEGER AND "ASMAY_Id" = "p_ASMAY_Id"::INTEGER;

    WITH RECURSIVE "CTE" AS (
        SELECT "v_startDate"::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 month')::DATE 
        FROM "CTE" 
        WHERE ("Dates" + INTERVAL '1 month')::DATE <= "v_endDate"::DATE
    )
    INSERT INTO "temp_NewTablemonth"("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM "Dates")::INTEGER, EXTRACT(YEAR FROM "Dates")::INTEGER 
    FROM "CTE";

    SELECT "AYear" INTO "v_Year" 
    FROM "temp_NewTablemonth" 
    WHERE "MonthId" = "p_monthid"::INTEGER 
    LIMIT 1;

    DROP TABLE IF EXISTS "temp_calender";
    CREATE TEMP TABLE "temp_calender"(
        "day" INTEGER, 
        "date" TEXT
    );

    "p_fromdate" := TO_CHAR(TO_DATE("p_fromdate", 'YYYY-MM-DD'), 'DD/MM/YYYY');
    "p_todate" := TO_CHAR(TO_DATE("p_todate", 'YYYY-MM-DD'), 'DD/MM/YYYY');

    -- All Condition
    IF "p_type"::INTEGER = 1 AND "p_radiotype"::INTEGER = 1 AND "p_AMST_Id"::INTEGER = 0 THEN
        IF "p_datewise"::INTEGER = 0 THEN
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
                 NULLIF(SUM("Adm_Student_Attendance"."ASA_ClassHeld"), 0) * 100) AS "Percentage",
                NULL::TEXT AS "AMST_RegistrationNo",
                NULL::JSONB AS "result_data"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
            INNER JOIN "dbo"."Adm_Student_Attendance" 
                ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER
                AND "Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER
                AND "Adm_Student_Attendance"."ASMCL_Id" = ANY(STRING_TO_ARRAY("p_ASMCL_Id", ',')::INTEGER[])
                AND "Adm_Student_Attendance"."ASMS_Id" = ANY(STRING_TO_ARRAY("p_ASMS_Id", ',')::INTEGER[])
                AND "Adm_Student_Attendance"."MI_Id" = "p_mi_id"::INTEGER
                AND EXTRACT(MONTH FROM "Adm_Student_Attendance"."ASA_FromDate") = "p_monthid"::INTEGER
                AND "Adm_M_Student"."AMST_SOL" = 'S'
                AND "Adm_Student_Attendance"."ASA_Activeflag" = 1
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
            GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                     "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";
        ELSE
            -- Generate calendar days for month
            FOR "v_day_val" IN 
                SELECT GENERATE_SERIES(1, EXTRACT(DAY FROM (DATE_TRUNC('month', MAKE_DATE("v_Year", "p_monthid"::INTEGER, 1)) + INTERVAL '1 month - 1 day'))::INTEGER)
            LOOP
                INSERT INTO "temp_calender"("day", "date")
                VALUES (
                    "v_day_val"::INTEGER, 
                    TO_CHAR(MAKE_DATE("v_Year", "p_monthid"::INTEGER, "v_day_val"::INTEGER), 'DD-MM-YYYY')
                );
            END LOOP;

            "v_monthyearsd" := '';
            "v_monthyearsd1" := '';

            FOR "v_rec" IN SELECT "date", "day" FROM "temp_calender" ORDER BY "day"
            LOOP
                "v_monthyearsd" := "v_monthyearsd" || '"' || "v_rec"."day" || '", ';
                
                "v_monthyearsd1" := "v_monthyearsd1" || 
                    'CASE WHEN "' || "v_rec"."day" || '" = 1.00 THEN ''P'' ' ||
                    'WHEN "' || "v_rec"."day" || '" = 0.00 THEN ''A'' ' ||
                    'WHEN "' || "v_rec"."day" || '" = 0.50 THEN ''H'' ' ||
                    'WHEN TO_CHAR(TO_DATE(''' || "v_rec"."date" || ''', ''DD-MM-YYYY''), ''Day'') = ''Sunday'' THEN ''S'' ' ||
                    'WHEN (SELECT COUNT(*) FROM "FO"."FO_HolidayWorkingDay_Type" "FHDT" ' ||
                    'INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHD" ON "FMHD"."FOHWDT_Id" = "FHDT"."FOHWDT_Id" ' ||
                    'WHERE "FHDT"."mi_id" = ' || "p_mi_id" || ' AND "FHDT"."FOHTWD_HolidayWDTypeFlag" = ''PH'' ' ||
                    'AND "FMHD"."mi_id" = ' || "p_mi_id" || ' ' ||
                    'AND "FMHD"."FOMHWDD_FromDate" = TO_DATE(''' || "v_rec"."date" || ''', ''DD-MM-YYYY'')) > 0 THEN ''HO'' ' ||
                    'ELSE ''NE'' END AS "' || "v_rec"."day" || '", ';
            END LOOP;

            "v_monthyearsd" := LEFT("v_monthyearsd", LENGTH("v_monthyearsd") - 2);
            "v_monthyearsd1" := LEFT("v_monthyearsd1", LENGTH("v_monthyearsd1") - 2);

            "v_query1" := 'SELECT "name", "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", "AMST_Id", ' || "v_monthyearsd1" ||
                ' FROM (SELECT DISTINCT (COALESCE(d."AMST_FirstName", '''') || '' '' || COALESCE(d."AMST_MiddleName", '''') || '' '' || ' ||
                'COALESCE(d."AMST_LastName", '''')) AS "name", d."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo", ' ||
                '"ASA_Class_Attended" AS "TOTAL_PRESENT", c."AMST_Id", EXTRACT(DAY FROM a."ASA_FromDate")::INTEGER AS "MONTH_NAME" ' ||
                'FROM "adm_student_attendance" a ' ||
                'INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id" ' ||
                'INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id" ' ||
                'INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" ' ||
                'WHERE c."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND a."MI_Id" = ' || "p_mi_id" || 
                ' AND c."ASMCL_Id" = ANY(ARRAY[' || "p_ASMCL_Id" || ']) ' ||
                'AND c."ASMS_Id" = ANY(ARRAY[' || "p_ASMS_Id" || ']) ' ||
                'AND "amst_sol" = ''S'' AND "ASA_Activeflag" = 1 AND "amst_activeflag" = 1 AND "amay_activeflag" = 1 ' ||
                'AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || "p_monthid" || 
                ' AND EXTRACT(YEAR FROM a."asa_fromdate") = ' || "v_Year" || ') AS s ' ||
                'PIVOT (SUM("TOTAL_PRESENT") FOR "MONTH_NAME" IN(' || "v_monthyearsd" || ')) AS p';

            RETURN QUERY EXECUTE "v_query1";
        END IF;

    ELSIF "p_type"::INTEGER = 1 AND "p_radiotype"::INTEGER = 2 AND "p_AMST_Id"::INTEGER = 0 THEN
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
             NULLIF(SUM("Adm_Student_Attendance"."ASA_ClassHeld"), 0) * 100) AS "Percentage",
            NULL::TEXT AS "AMST_RegistrationNo",
            NULL::JSONB AS "result_data"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
            ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        WHERE "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER
            AND "Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER
            AND "Adm_Student_Attendance"."ASMCL_Id" = ANY(STRING_TO_ARRAY("p_ASMCL_Id", ',')::INTEGER[])
            AND "Adm_Student_Attendance"."ASMS_Id" = ANY(STRING_TO_ARRAY("p_ASMS_Id", ',')::INTEGER[])
            AND "Adm_Student_Attendance"."MI_Id" = "p_mi_id"::INTEGER
            AND "Adm_Student_Attendance"."ASA_FromDate" BETWEEN TO_DATE("p_fromdate", 'DD/MM/YYYY') 
                AND TO_DATE("p_todate", 'DD/MM/YYYY')
            AND "AMST_SOL" = 'S'
            AND "ASA_Activeflag" = 1
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                 "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";

    ELSIF "p_type"::INTEGER = 1 AND "p_radiotype"::INTEGER = 3 AND "p_AMST_Id"::INTEGER = 0 THEN
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
             NULLIF(SUM("Adm_Student_Attendance"."ASA_ClassHeld"), 0) * 100) AS "Percentage",
            NULL::TEXT AS "AMST_RegistrationNo",
            NULL::JSONB AS "result_data"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
            ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        WHERE "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER
            AND "Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER
            AND "Adm_Student_Attendance"."ASMCL_Id" = ANY(STRING_TO_ARRAY("p_ASMCL_Id", ',')::INTEGER[])
            AND "Adm_Student_Attendance"."ASMS_Id" = ANY(STRING_TO_ARRAY("p_ASMS_Id", ',')::INTEGER[])
            AND "Adm_Student_Attendance"."MI_Id" = "p_mi_id"::INTEGER
            AND "Adm_Student_Attendance"."ASA_FromDate" = TO_DATE("p_fromdate", 'DD/MM/YYYY')
            AND "AMST_SOL" = 'S'
            AND "ASA_Activeflag" = 1
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
        GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                 "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";

    -- Individual Condition
    ELSIF "p_type"::INTEGER = 2 AND "p_radiotype"::INTEGER = 1 AND "p_AMST_Id"::INTEGER != 0 THEN
        IF "p_datewise"::INTEGER = 0 THEN
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
                 NULLIF(SUM("Adm_Student_Attendance"."ASA_ClassHeld"), 0) * 100) AS "Percentage",
                NULL::TEXT AS "AMST_RegistrationNo",
                NULL::JSONB AS "result_data"
            FROM "dbo"."Adm_M_Student"
            INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_Student_Attendance_Students"."AMST_Id"
            INNER JOIN "dbo"."Adm_Student_Attendance" 
                ON "Adm_Student_Attendance_Students"."ASA_Id" = "Adm_Student_Attendance"."ASA_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" 
                ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER
                AND "Adm_School_Y_Student"."ASMAY_Id" = "p_ASMAY_Id"::INTEGER
                AND "Adm_Student_Attendance"."ASMCL_Id" = ANY(STRING_TO_ARRAY("p_ASMCL_Id", ',')::INTEGER[])
                AND "Adm_Student_Attendance"."ASMS_Id" = ANY(STRING_TO_ARRAY("p_ASMS_Id", ',')::INTEGER[])
                AND "Adm_Student_Attendance"."MI_Id" = "p_mi_id"::INTEGER
                AND EXTRACT(MONTH FROM "Adm_Student_Attendance"."ASA_FromDate") = "p_monthid"::INTEGER
                AND "AMST_SOL" = 'S'
                AND "ASA_Activeflag" = 1
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
                AND "Adm_M_Student"."AMST_Id" = "p_AMST_Id"::INTEGER
            GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", 
                     "AMST_LastName", "Adm_M_Student"."AMST_AdmNo", "Adm_School_Y_Student"."AMAY_RollNo";
        ELSE
            -- Similar logic as above for datewise
            FOR "v_day_val" IN 
                SELECT GENERATE_SERIES(1, EXTRACT(DAY FROM (DATE_TRUNC('month', MAKE_DATE("v_Year", "p_monthid"::INTEGER, 1)) + INTERVAL '1 month - 1 day'))::INTEGER)
            LOOP
                INSERT INTO "temp_calender"("day", "date")
                VALUES (
                    "v_day_val"::INTEGER, 
                    TO_CHAR(MAKE_DATE("v_Year", "p_monthid"::INTEGER, "v_day_val"::INTEGER), 'DD-MM-YYYY')
                );
            END LOOP;

            "v_monthyearsd" := '';
            "v_monthyearsd1" := '';

            FOR "v_rec" IN SELECT "date", "day" FROM "temp_calender" ORDER BY "day"
            LOOP
                "v_monthyearsd" := "v_monthyearsd" || '"' || "v_rec"."day" || '", ';
                
                "v_monthyearsd1" := "v_monthyearsd1" || 
                    'CASE WHEN "' || "v_rec"."day" || '" = 1.00 THEN ''P'' ' ||
                    'WHEN "' || "v_rec"."day" || '" = 0.00 THEN ''A'' ' ||
                    'WHEN "' || "v_rec"."day" || '" = 0.50 THEN ''H'' ' ||
                    'WHEN TO_CHAR(TO_DATE(''' || "v_rec"."date" || ''', ''DD-MM-YYYY''), ''Day'') = ''Sunday'' THEN ''S'' ' ||
                    'WHEN (SELECT COUNT(*) FROM "FO"."FO_HolidayWorkingDay_Type" a ' ||
                    'INNER JOIN "fo"."FO_Master_HolidayWorkingDay_dates" c ON c."FOMHWDT_Id" = a."FOMHWDT_Id" ' ||
                    'WHERE a."mi_id" = ' || "p_mi_id" || ' AND a."FOHTWD_HolidayWDTypeFlag" = ''PH'' ' ||
                    'AND c."fomhwdd_date" = TO_DATE(''' || "v_rec"."date" || ''', ''DD-MM-YYYY'')) > 0 THEN ''HO'' ' ||
                    'ELSE ''NE'' END AS "' || "v_rec"."day" || '", ';
            END LOOP;

            "v_monthyearsd" := LEFT("v_monthyearsd", LENGTH("v_monthyearsd") - 2);
            "v_monthyearsd1" := LEFT("v_monthyearsd1", LENGTH("v_monthyearsd1") - 2);

            "v_query1" := 'SELECT "name", "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", "AMST_Id", ' || "v_monthyearsd1" ||
                ' FROM (SELECT DISTINCT c."AMST_Id", (COALESCE(d."AMST_FirstName", '''') || '' '' || ' ||
                'COALESCE(d."AMST_MiddleName", '''') || '' '' || COALESCE(d."AMST_LastName", '''')) AS "name", ' ||
                'd."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo", "ASA_Class_Attended" AS "TOTAL_PRESENT", ' ||
                'EXTRACT(DAY FROM a."ASA_FromDate")::INTEGER AS "MONTH_NAME" ' ||
                'FROM "adm_student_attendance" a ' ||
                'INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id" ' ||
                'INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id" ' ||
                'INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" ' ||
                'WHERE c."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND a."MI_Id" = ' || "p_mi_id" || 
                ' AND c."ASMCL_Id" = ANY(ARRAY[' || "p_ASMCL_Id" || ']) ' ||
                'AND c."ASMS_Id" = ANY(ARRAY[' || "p_ASMS_Id" || ']) ' ||
                'AND "amst_sol" = ''S'' AND "ASA_Activeflag" = 1 AND "amst_activeflag" = 1 AND "amay_activeflag" = 1 ' ||
                'AND c."amst_id" = ' || "p_AMST_Id" || ' AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || "p_monthid" || 
                ' AND EXTRACT(YEAR FROM a."asa_fromdate") = ' || "v_Year" || ') AS s ' ||
                'PIVOT (SUM("TOTAL_PRESENT") FOR "MONTH_NAME" IN(' || "v_monthyearsd" || ')) AS p';

            RETURN QUERY EXECUTE "v_query1";
        END IF;

    ELSIF "p_type"::INTEGER = 2 AND "p_radiotype"::INTEGER = 2 AND "p_AMST_Id"::INTEGER != 0 THEN
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
             NULLIF(SUM("Adm_Student_Attendance"."ASA_ClassHeld"), 0)