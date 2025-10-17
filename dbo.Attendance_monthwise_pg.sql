CREATE OR REPLACE FUNCTION dbo."Attendance_monthwise"(
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_fromdate TEXT,
    p_todate TEXT,
    p_type TEXT,
    p_radiotype TEXT,
    p_AMST_Id TEXT,
    p_monthid TEXT,
    p_mi_id TEXT,
    p_datewise TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_Query TEXT;
    v_Year INT;
    v_sqlquery TEXT;
    v_cursorValue TEXT;
    v_Cl TEXT;
    v_C2 TEXT;
    v_query1 TEXT;
    v_cols TEXT;
    v_monthyearsd TEXT;
    v_monthyearsd1 TEXT;
    v_cols1 TEXT;
    v_startDate DATE;
    v_endDate DATE;
    rec RECORD;
BEGIN
    v_Year := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    v_monthyearsd := '';
    v_monthyearsd1 := '';
    v_cols := '';
    v_cols1 := '';

    DROP TABLE IF EXISTS temp_NewTablemonth;
    CREATE TEMP TABLE temp_NewTablemonth(
        id SERIAL,
        "MonthId" INT,
        "AYear" INT
    );

    SELECT "ASMAY_From_Date" INTO v_startDate 
    FROM dbo."Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_mi_id::INT AND "ASMAY_Id" = p_ASMAY_Id::INT;
    
    SELECT "ASMAY_To_Date" INTO v_endDate 
    FROM dbo."Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_mi_id::INT AND "ASMAY_Id" = p_ASMAY_Id::INT;

    WITH RECURSIVE CTE AS (
        SELECT v_startDate::DATE AS Dates
        UNION ALL
        SELECT (Dates + INTERVAL '1 month')::DATE 
        FROM CTE 
        WHERE (Dates + INTERVAL '1 month')::DATE <= v_endDate::DATE
    )
    INSERT INTO temp_NewTablemonth("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM Dates)::INT, EXTRACT(YEAR FROM Dates)::INT 
    FROM CTE;

    SELECT "AYear" INTO v_Year 
    FROM temp_NewTablemonth 
    WHERE "MonthId" = p_monthid::INT 
    LIMIT 1;

    DROP TABLE IF EXISTS calender;
    CREATE TEMP TABLE calender(day INT, date TEXT);

    p_fromdate := TO_CHAR(TO_DATE(p_fromdate, 'MM/DD/YYYY'), 'DD/MM/YYYY');
    p_todate := TO_CHAR(TO_DATE(p_todate, 'MM/DD/YYYY'), 'DD/MM/YYYY');

    IF p_type::INT = 1 AND p_radiotype::INT = 1 AND p_AMST_Id::INT = 0 THEN
        IF p_datewise::INT = 0 THEN
            RETURN QUERY
            SELECT 
                s."AMST_Id",
                (COALESCE(s."AMST_FirstName", '') || ' ' || 
                 COALESCE(s."AMST_MiddleName", '') || ' ' || 
                 COALESCE(s."AMST_LastName", ''))::TEXT AS name,
                s."AMST_AdmNo",
                sys."AMAY_RollNo",
                SUM(sa."ASA_ClassHeld")::BIGINT AS "ASA_ClassHeld",
                SUM(sas."ASA_Class_Attended")::NUMERIC AS "ASA_Class_Attended",
                (SUM(sas."ASA_Class_Attended") / SUM(sa."ASA_ClassHeld") * 100)::NUMERIC AS "Percentage"
            FROM dbo."Adm_M_Student" s
            INNER JOIN dbo."Adm_Student_Attendance_Students" sas ON s."AMST_Id" = sas."AMST_Id"
            INNER JOIN dbo."Adm_Student_Attendance" sa ON sas."ASA_Id" = sa."ASA_Id"
            INNER JOIN dbo."Adm_School_Y_Student" sys ON s."AMST_Id" = sys."AMST_Id"
            WHERE sa."ASMAY_Id" = p_ASMAY_Id::INT
                AND sys."ASMAY_Id" = p_ASMAY_Id::INT
                AND sa."ASMCL_Id" = p_ASMCL_Id::INT
                AND sa."ASMS_Id" = p_ASMS_Id::INT
                AND sa."ASA_Activeflag" = 1
                AND sa."MI_Id" = p_mi_id::INT
                AND EXTRACT(MONTH FROM sa."ASA_FromDate") = p_monthid::INT
                AND s."AMST_SOL" = 'S'
                AND s."AMST_ActiveFlag" = 1
                AND sys."AMAY_ActiveFlag" = 1
            GROUP BY s."AMST_Id", s."AMST_FirstName", s."AMST_MiddleName", s."AMST_LastName", 
                     s."AMST_AdmNo", sys."AMAY_RollNo";
        ELSE
            v_Query := 'WITH RECURSIVE N AS (
                SELECT 1 AS n
                UNION ALL
                SELECT n + 1 FROM N WHERE n < EXTRACT(DAY FROM (DATE_TRUNC(''MONTH'', DATE ''' || 
                v_Year || '-' || p_monthid || '-01'') + INTERVAL ''1 MONTH'' - INTERVAL ''1 DAY''))
            )
            SELECT n::INT, TO_CHAR(DATE ''' || v_Year || '-' || p_monthid || '-'' || n, ''DD-MM-YYYY'')
            FROM N';

            FOR rec IN EXECUTE v_Query LOOP
                INSERT INTO calender(day, date) VALUES (rec.n, rec.to_char);
            END LOOP;

            FOR rec IN SELECT date, day FROM calender LOOP
                v_cols := rec.day::TEXT;
                v_cols1 := rec.day::TEXT;
                v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || v_cols1 || '"' || ', ', '');
                v_monthyearsd1 := COALESCE(v_monthyearsd1, '') || 
                    ('CASE WHEN "' || v_cols1 || '" = 1.00 THEN ''P'' ' ||
                     'WHEN "' || v_cols1 || '" = 0.00 THEN ''A'' ' ||
                     'WHEN "' || v_cols1 || '" = 0.50 THEN ''H'' ' ||
                     'WHEN TRIM(TO_CHAR(TO_DATE(''' || rec.date || ''', ''DD-MM-YYYY''), ''Day'')) = ''Sunday'' THEN ''S'' ' ||
                     'WHEN (SELECT COUNT(*) FROM "FO"."FO_HolidayWorkingDay_Type" "FHDT" ' ||
                     'INNER JOIN "FO"."FO_Master_HolidayWorkingDay" "FMH" ON "FHDT"."FOHWDT_Id" = "FMH"."FOHWDT_Id" ' ||
                     'INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHD" ON "FMHD"."FOHWDT_Id" = "FMH"."FOHWDT_Id" ' ||
                     'WHERE "FHDT"."mi_id" = ' || p_mi_id || ' AND "FHDT"."FOHTWD_HolidayWDTypeFlag" = ''PH'' ' ||
                     'AND TO_DATE(''' || rec.date || ''', ''DD-MM-YYYY'') BETWEEN "FMHD"."FOMHWDD_FromDate" AND "FMHD"."FOMHWDD_ToDate") > 0 THEN ''HO'' ' ||
                     'ELSE ''NE'' END AS "' || v_cols1 || '", ');
            END LOOP;

            v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);
            v_monthyearsd1 := LEFT(v_monthyearsd1, LENGTH(v_monthyearsd1) - 2);

            v_query1 := 'SELECT name, "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", "AMST_Id", amst_sex, ' || 
                v_monthyearsd1 || ' FROM (SELECT ' ||
                '(COALESCE(d."AMST_FirstName", '''') || '' '' || COALESCE(d."AMST_MiddleName", '''') || '' '' || ' ||
                'COALESCE(d."AMST_LastName", '''')) AS name, d."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo", ' ||
                'd."ASA_Class_Attended" AS "TOTAL_PRESENT", c."AMST_Id", ' ||
                '(CASE WHEN d.amst_sex = ''Female'' THEN ''F'' ELSE ''M'' END) AS amst_sex, ' ||
                'EXTRACT(DAY FROM a."ASA_FromDate")::INT AS "MONTH_NAME" ' ||
                'FROM dbo."adm_student_attendance" a ' ||
                'INNER JOIN dbo."adm_student_attendance_students" b ON a."asa_id" = b."asa_id" ' ||
                'INNER JOIN dbo."adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id" ' ||
                'INNER JOIN dbo."Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" ' ||
                'WHERE c."ASMAY_Id" = ' || p_asmay_id || ' AND a."MI_Id" = ' || p_mi_id || 
                ' AND c."ASMCL_Id" = ' || p_asmcl_id || ' AND c."ASMS_Id" = ' || p_asms_id ||
                ' AND d."amst_sol" = ''S'' AND d."amst_activeflag" = 1 AND c."amay_activeflag" = 1 ' ||
                'AND a."ASA_Activeflag" = 1 AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || p_monthid ||
                ' AND EXTRACT(YEAR FROM a."asa_fromdate") = ' || v_year || ') AS s';

            RETURN QUERY EXECUTE v_query1;
        END IF;

    ELSIF p_type::INT = 1 AND p_radiotype::INT = 2 AND p_AMST_Id::INT = 0 THEN
        RETURN QUERY
        SELECT 
            s."AMST_Id",
            (COALESCE(s."AMST_FirstName", '') || ' ' || 
             COALESCE(s."AMST_MiddleName", '') || ' ' || 
             COALESCE(s."AMST_LastName", ''))::TEXT AS name,
            s."AMST_AdmNo",
            sys."AMAY_RollNo",
            SUM(sa."ASA_ClassHeld")::BIGINT AS "ASA_ClassHeld",
            SUM(sas."ASA_Class_Attended")::NUMERIC AS "ASA_Class_Attended",
            (SUM(sas."ASA_Class_Attended") / SUM(sa."ASA_ClassHeld") * 100)::NUMERIC AS "Percentage"
        FROM dbo."Adm_M_Student" s
        INNER JOIN dbo."Adm_Student_Attendance_Students" sas ON s."AMST_Id" = sas."AMST_Id"
        INNER JOIN dbo."Adm_Student_Attendance" sa ON sas."ASA_Id" = sa."ASA_Id"
        INNER JOIN dbo."Adm_School_Y_Student" sys ON s."AMST_Id" = sys."AMST_Id"
        WHERE sa."ASMAY_Id" = p_ASMAY_Id::INT
            AND sys."ASMAY_Id" = p_ASMAY_Id::INT
            AND sa."ASMCL_Id" = p_ASMCL_Id::INT
            AND sa."ASMS_Id" = p_ASMS_Id::INT
            AND sa."MI_Id" = p_mi_id::INT
            AND sa."ASA_Activeflag" = 1
            AND TO_DATE(TO_CHAR(sa."ASA_FromDate", 'DD/MM/YYYY'), 'DD/MM/YYYY') 
                BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') 
                AND TO_DATE(p_todate, 'DD/MM/YYYY')
            AND s."AMST_SOL" = 'S'
            AND s."AMST_ActiveFlag" = 1
            AND sys."AMAY_ActiveFlag" = 1
        GROUP BY s."AMST_Id", s."AMST_FirstName", s."AMST_MiddleName", s."AMST_LastName", 
                 s."AMST_AdmNo", sys."AMAY_RollNo";

    ELSIF p_type::INT = 1 AND p_radiotype::INT = 3 AND p_AMST_Id::INT = 0 THEN
        RETURN QUERY
        SELECT 
            s."AMST_Id",
            (COALESCE(s."AMST_FirstName", '') || ' ' || 
             COALESCE(s."AMST_MiddleName", '') || ' ' || 
             COALESCE(s."AMST_LastName", ''))::TEXT AS name,
            s."AMST_AdmNo",
            sys."AMAY_RollNo",
            SUM(sa."ASA_ClassHeld")::BIGINT AS "ASA_ClassHeld",
            SUM(sas."ASA_Class_Attended")::NUMERIC AS "ASA_Class_Attended",
            (SUM(sas."ASA_Class_Attended") / SUM(sa."ASA_ClassHeld") * 100)::NUMERIC AS "Percentage"
        FROM dbo."Adm_M_Student" s
        INNER JOIN dbo."Adm_Student_Attendance_Students" sas ON s."AMST_Id" = sas."AMST_Id"
        INNER JOIN dbo."Adm_Student_Attendance" sa ON sas."ASA_Id" = sa."ASA_Id"
        INNER JOIN dbo."Adm_School_Y_Student" sys ON s."AMST_Id" = sys."AMST_Id"
        WHERE sa."ASMAY_Id" = p_ASMAY_Id::INT
            AND sys."ASMAY_Id" = p_ASMAY_Id::INT
            AND sa."ASMCL_Id" = p_ASMCL_Id::INT
            AND sa."ASMS_Id" = p_ASMS_Id::INT
            AND sa."MI_Id" = p_mi_id::INT
            AND sa."ASA_Activeflag" = 1
            AND TO_DATE(TO_CHAR(sa."ASA_FromDate", 'DD/MM/YYYY'), 'DD/MM/YYYY') = TO_DATE(p_fromdate, 'DD/MM/YYYY')
            AND s."AMST_SOL" = 'S'
            AND s."AMST_ActiveFlag" = 1
            AND sys."AMAY_ActiveFlag" = 1
        GROUP BY s."AMST_Id", s."AMST_FirstName", s."AMST_MiddleName", s."AMST_LastName", 
                 s."AMST_AdmNo", sys."AMAY_RollNo";

    ELSIF p_type::INT = 2 AND p_radiotype::INT = 1 AND p_AMST_Id::INT != 0 THEN
        IF p_datewise::INT = 0 THEN
            RETURN QUERY
            SELECT 
                s."AMST_Id",
                (COALESCE(s."AMST_FirstName", '') || ' ' || 
                 COALESCE(s."AMST_MiddleName", '') || ' ' || 
                 COALESCE(s."AMST_LastName", ''))::TEXT AS name,
                s."AMST_AdmNo",
                sys."AMAY_RollNo",
                SUM(sa."ASA_ClassHeld")::BIGINT AS "ASA_ClassHeld",
                SUM(sas."ASA_Class_Attended")::NUMERIC AS "ASA_Class_Attended",
                (SUM(sas."ASA_Class_Attended") / SUM(sa."ASA_ClassHeld") * 100)::NUMERIC AS "Percentage"
            FROM dbo."Adm_M_Student" s
            INNER JOIN dbo."Adm_Student_Attendance_Students" sas ON s."AMST_Id" = sas."AMST_Id"
            INNER JOIN dbo."Adm_Student_Attendance" sa ON sas."ASA_Id" = sa."ASA_Id"
            INNER JOIN dbo."Adm_School_Y_Student" sys ON s."AMST_Id" = sys."AMST_Id"
            WHERE sa."ASMAY_Id" = p_ASMAY_Id::INT
                AND sys."ASMAY_Id" = p_ASMAY_Id::INT
                AND sa."ASMCL_Id" = p_ASMCL_Id::INT
                AND sa."ASMS_Id" = p_ASMS_Id::INT
                AND sa."MI_Id" = p_mi_id::INT
                AND EXTRACT(MONTH FROM sa."ASA_FromDate") = p_monthid::INT
                AND sa."ASA_Activeflag" = 1
                AND s."AMST_SOL" = 'S'
                AND s."AMST_ActiveFlag" = 1
                AND sys."AMAY_ActiveFlag" = 1
                AND s."AMST_Id" = p_AMST_Id::INT
            GROUP BY s."AMST_Id", s."AMST_FirstName", s."AMST_MiddleName", s."AMST_LastName", 
                     s."AMST_AdmNo", sys."AMAY_RollNo";
        ELSE
            v_Query := 'WITH RECURSIVE N AS (
                SELECT 1 AS n
                UNION ALL
                SELECT n + 1 FROM N WHERE n < EXTRACT(DAY FROM (DATE_TRUNC(''MONTH'', DATE ''' || 
                v_Year || '-' || p_monthid || '-01'') + INTERVAL ''1 MONTH'' - INTERVAL ''1 DAY''))
            )
            SELECT n::INT, TO_CHAR(DATE ''' || v_Year || '-' || p_monthid || '-'' || n, ''DD-MM-YYYY'')
            FROM N';

            FOR rec IN EXECUTE v_Query LOOP
                INSERT INTO calender(day, date) VALUES (rec.n, rec.to_char);
            END LOOP;

            FOR rec IN SELECT date, day FROM calender LOOP
                v_cols := rec.date;
                v_cols1 := rec.day::TEXT;
                v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || v_cols1 || '"' || ', ', '');
                v_monthyearsd1 := COALESCE(v_monthyearsd1, '') || 
                    ('CASE WHEN "' || v_cols1 || '" = 1.00 THEN ''P'' ' ||
                     'WHEN "' || v_cols1 || '" = 0.00 THEN ''A'' ' ||
                     'WHEN "' || v_cols1 || '" = 0.50 THEN ''H'' ' ||
                     'WHEN TRIM(TO_CHAR(TO_DATE(''' || rec.date || ''', ''DD-MM-YYYY''), ''Day'')) = ''Sunday'' THEN ''S'' ' ||
                     'WHEN (SELECT COUNT(*) FROM "FO"."FO_HolidayWorkingDay_Type" a ' ||
                     'INNER JOIN "FO"."FO_Master_HolidayWorkingDay" b ON a."FOHWDT_Id" = b."FOHWDT_Id" ' ||
                     'INNER JOIN "fo"."FO_Master_HolidayWorkingDay_dates" c ON c."FOMHWD_Id" = b."FOMHWD_Id" ' ||
                     'WHERE a."mi_id" = ' || p_mi_id || ' AND a."FOHTWD_HolidayWDTypeFlag" = ''PH'' ' ||
                     'AND TO_DATE(c."fomhwdd_date"::TEXT, ''DD/MM/YYYY'') = TO_DATE(''' || rec.date || ''', ''DD-MM-YYYY'')) > 0 THEN ''HO'' ' ||
                     'ELSE ''NE'' END AS "' || v_cols1 || '", ');
            END LOOP;

            v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);
            v_monthyearsd1 := LEFT(v_monthyearsd1, LENGTH(v_monthyearsd1) - 2);

            v_query1 := 'SELECT name, "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", "AMST_Id", ' || 
                v_monthyearsd1 || ' FROM (SELECT c."AMST_Id", ' ||
                '(COALESCE(d."AMST_FirstName", '''') || '' '' || COALESCE(d."AMST_MiddleName", '''') || '' '' || ' ||
                'COALESCE(d."AMST_LastName", '''')) AS name, d."AMST_AdmNo", d."AMST_RegistrationNo", c."AMAY_RollNo", ' ||
                'b."ASA_Class_Attended" AS "TOTAL_PRESENT", ' ||
                'EXTRACT(DAY FROM a."ASA_FromDate")::INT AS "MONTH_NAME" ' ||
                'FROM dbo."adm_student_attendance" a ' ||
                'INNER JOIN dbo."adm_student_attendance_students" b ON a."asa_id" = b."asa_id" ' ||
                'INNER JOIN dbo."adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id" ' ||
                'INNER JOIN dbo."Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" ' ||
                'WHERE c."ASMAY_Id" = ' || p_asmay_id || ' AND a."MI_Id" = ' || p_mi_id || 
                ' AND a."ASA_Activeflag" = 1 AND c."ASMCL_Id" = ' || p_asmcl_id || 
                ' AND c."ASMS_Id" = ' || p_asms_id || ' AND d."amst_sol" = ''S'' ' ||
                'AND d."amst_activeflag" = 1 AND c."amay_activeflag" = 1 AND c."amst_id" = ' || p_AMST_Id ||
                ' AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || p_monthid ||
                ' AND EXTRACT(YEAR FROM a."asa_fromdate") = ' || v_year || ') AS s';

            RETURN QUERY EXECUTE v_query1;
        END IF;

    ELSIF p_type::INT = 2 AND p_radiotype::INT = 2 AND p_AMST_Id::INT != 0 THEN
        RETURN QUERY
        SELECT 
            s."AMST_Id",
            (COALESCE(s."AMST_FirstName", '') || ' ' || 
             COALESCE(s."AMST_MiddleName", '') || ' ' || 
             COALESCE(s."AMST_LastName", ''))::TEXT AS name,
            s."AMST_AdmNo",
            sys."AMAY_RollNo",
            SUM(sa."ASA_ClassHeld")::BIGINT AS "ASA_ClassHeld",
            SUM(sas."ASA_Class_Attended")::NUMERIC AS "ASA_Class_Attended",
            (SUM(sas."ASA_Class_Attended") / SUM(sa."ASA_ClassHeld") * 100)::NUMERIC AS "Percentage"
        FROM dbo."Adm_M_Student" s
        INNER JOIN dbo."Adm_Student_Attendance_Students" sas ON s."AMST_Id" = sas."AMST_Id"
        INNER JOIN dbo."Adm_Student_Attendance" sa ON sas."ASA_Id" = sa."ASA_Id"
        INNER JOIN dbo."Adm_School_Y_Student" sys ON s."AMST_Id" = sys."AMST_Id"
        WHERE sa."ASMAY_Id" = p_ASMAY_Id::INT
            AND sys."ASMAY_Id" = p_ASMAY_Id::INT
            AND sa."ASMCL_Id" = p_ASMCL_Id::INT
            AND sa."ASMS_Id" = p_ASMS_Id::INT
            AND sa."MI_Id" = p_mi_id::INT
            AND sa."ASA_Activeflag" = 1
            AND TO_DATE(TO_CHAR(sa."ASA_FromDate", 'DD/MM/YYYY'), 'DD/MM/YYYY') 
                BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') 
                AND TO_DATE(p_todate, 'DD/MM/YYYY')
            AND s."AMST_Id" = p_AMST_Id::INT
            AND s."AMST_SOL" = 'S'
            AND s."AMST_ActiveFlag" = 1
            AND sys."AMAY_ActiveFlag" = 1
        GROUP BY s."AMST_Id", s."AMST_FirstName", s."AMST_MiddleName", s."AMST_LastName", 
                 s."AMST_AdmNo", sys."AMAY_RollNo";

    ELSIF p_type::INT = 2 AND p_radiotype::INT = 3 AND p_AMST_Id::INT != 0 THEN
        RETURN QUERY
        SELECT 
            s."AMST_Id",
            (COALESCE(s."AMST_FirstName", '') || ' ' || 
             COALESCE(s."AMST_MiddleName", '') || ' ' || 
             COALESCE(s."AMST_LastName", ''))::TEXT AS name,
            s."AMST_AdmNo",
            sys."AMAY_RollNo",
            SUM(sa."ASA_ClassHeld")::BIGINT AS "ASA_ClassHeld",
            SUM(sas."ASA_Class_Attended")::NUMERIC AS "ASA_Class_Attended",
            (SUM(sas."ASA_Class_Attended") / SUM(sa."ASA_ClassHeld") * 100)::NUMERIC AS "Percentage"
        FROM dbo."Adm_M_Student" s
        INNER JOIN dbo."Adm_Student_Attendance_Students" sas ON s."AMST_Id" = sas."AMST_Id"
        INNER JOIN dbo."Adm_Student_Attendance" sa ON sas."ASA_Id" = sa."ASA_Id"
        INNER JOIN dbo."Adm_School_Y_Student" sys ON s."AMST_Id" = sys."AMST_Id"
        WHERE sa."ASMAY_Id" = p_ASMAY_Id::INT
            AND sys."ASMAY_Id" = p_ASMAY_Id::INT
            AND sa."ASMCL_Id" = p_ASMCL_Id::INT
            AND sa."ASMS_Id" = p_ASMS_Id::INT
            AND sa."MI_Id" = p_mi_id::INT
            AND sa."ASA_Activeflag" = 1
            AND s."AMST_SOL" = 'S'
            AND s."AMST_ActiveFlag" = 1
            AND sys."AMAY_ActiveFlag" = 1
            AND TO_DATE(TO_CHAR(sa."ASA_FromDate", 'DD/MM/YYYY'), 'DD/MM/YYYY') = TO_DATE(p_fromdate, 'DD/MM/YYYY')
            AND s."AMST_Id" = p_AMST_Id::INT
        GROUP BY s."AMST_Id", s."AMST_FirstName", s."AMST_MiddleName", s."AMST_LastName", 
                 s."AMST_AdmNo", sys."AMAY_RollNo";
    END IF;

    RETURN;
END;
$$;