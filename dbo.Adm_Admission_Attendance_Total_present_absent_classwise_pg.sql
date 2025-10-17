CREATE OR REPLACE FUNCTION "dbo"."Adm_Admission_Attendance_Total_present_absent_classwise"(
    p_mi_id TEXT,
    p_monthid TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_type VARCHAR(10)
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
    v_monthyearsd TEXT;
    v_monthyearsd1 TEXT;
    v_cols1 TEXT;
    v_fromdate TEXT;
    v_todate TEXT;
    v_sqlquery1 TEXT;
    v_startDate DATE;
    v_endDate DATE;
    rec RECORD;
BEGIN

    CREATE TEMP TABLE IF NOT EXISTS "NewTablemonth"(
        id SERIAL NOT NULL,
        "MonthId" INT,
        "AYear" INT
    ) ON COMMIT DROP;

    IF p_type = '1' THEN

        SELECT "ASMAY_From_Date" INTO v_startDate 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_mi_id::INT AND "ASMAY_Id" = p_ASMAY_Id::INT;
        
        SELECT "ASMAY_To_Date" INTO v_endDate 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_mi_id::INT AND "ASMAY_Id" = p_ASMAY_Id::INT;

        WITH CTE AS (
            SELECT v_startDate::DATE AS "Dates"
            UNION ALL
            SELECT ("Dates" + INTERVAL '1 month')::DATE
            FROM CTE 
            WHERE "Dates"::DATE <= v_endDate::DATE
        )
        INSERT INTO "NewTablemonth"("MonthId", "AYear")
        SELECT EXTRACT(MONTH FROM "Dates")::INT, EXTRACT(YEAR FROM "Dates")::INT FROM CTE;

        SELECT "AYear" INTO v_year FROM "NewTablemonth" WHERE "MonthId" = p_monthid::INT;

        DROP TABLE IF EXISTS "calender";

        CREATE TEMP TABLE "calender"(
            day INT,
            date VARCHAR(50)
        ) ON COMMIT DROP;

        v_fromdate := TO_CHAR(v_fromdate::DATE, 'DD/MM/YYYY');
        v_todate := TO_CHAR(v_todate::DATE, 'DD/MM/YYYY');

        v_Query := 'WITH days AS (
            SELECT generate_series(1, 
                EXTRACT(DAY FROM (DATE ''' || v_year::TEXT || '-' || p_monthid || '-01''::DATE + INTERVAL ''1 month - 1 day''))::INT
            ) AS day
        )
        SELECT day, TO_CHAR(DATE ''' || v_year::TEXT || '-' || p_monthid || '-'' || day, ''DD-MM-YYYY'') as date FROM days';

        FOR rec IN EXECUTE v_Query LOOP
            INSERT INTO "calender"(day, date) VALUES (rec.day, rec.date);
        END LOOP;

        v_monthyearsd := '';
        v_monthyearsd1 := '';

        FOR rec IN SELECT date, day FROM "calender" LOOP
            v_cols := rec.date;
            v_cols1 := rec.day::TEXT;
            
            v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || v_cols1 || '"' || ', ', '');

            v_monthyearsd1 := COALESCE(v_monthyearsd1, '') || 
            'CASE WHEN (SELECT COUNT(*) FROM "Adm_Student_Attendance" a 
                INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id" 
                WHERE a."mi_id" = ' || p_mi_id || ' AND "ASA_Activeflag" = TRUE 
                AND a."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND TO_CHAR(a."ASA_FromDate", ''DD-MM-YYYY'') = ''' || v_cols || ''') > 0 
            THEN "' || v_cols1 || '" 
            WHEN TO_CHAR(TO_DATE(''' || v_cols || ''', ''DD-MM-YYYY''), ''Day'') = ''Sunday'' THEN -1 
            WHEN (SELECT COUNT(*) FROM "FO"."FO_HolidayWorkingDay_Type" "FHDT" 
                INNER JOIN "FO"."FO_Master_HolidayWorkingDay" "FMH" ON "FHDT"."FOHWDT_Id" = "FMH"."FOHWDT_Id"
                INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHD" ON "FMHD"."FOHWDT_Id" = "FMH"."FOHWDT_Id"
                WHERE "FHDT"."mi_id" = ' || p_mi_id || ' AND "FHDT"."FOHTWD_HolidayWDTypeFlag" = ''PH'' 
                AND (TO_CHAR("FMHD"."FOMHWDD_FromDate", ''DD-MM-YYYY'') >= ''' || v_cols || ''' 
                OR TO_CHAR("FMHD"."FOMHWDD_ToDate", ''DD-MM-YYYY'') <= ''' || v_cols || ''')) > 0 
            THEN -2 ELSE -3 END AS "' || v_cols1 || '", ';
        END LOOP;

        v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 1);
        v_monthyearsd1 := LEFT(v_monthyearsd1, LENGTH(v_monthyearsd1) - 1);

        v_sqlquery1 := 'SELECT "ASMCL_ClassName", "ASMC_SectionName", "ASMCL_Order", "ASMC_Order", 
            "ASMCL_Id", "ASMS_Id", flag, ' || v_monthyearsd1 || ' FROM (
            SELECT * FROM (
                SELECT "ASMCL_ClassName", "ASMC_SectionName", "ASMCL_Order", "ASMC_Order", 
                    e."ASMCL_Id", f."ASMS_Id", ''P'' as flag, (b."ASA_Class_Attended") as "TOTAL_PRESENT", 
                    EXTRACT(DAY FROM a."asa_fromdate")::INT as "MONTH_NAME"
                FROM "Adm_Student_Attendance" a 
                INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_Id" = a."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id" AND f."ASMS_Id" = a."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id" AND g."ASMAY_Id" = a."ASMAY_Id"
                WHERE a."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "ASA_Activeflag" = TRUE 
                AND c."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || p_monthid || ' 
                AND EXTRACT(YEAR FROM a."asa_fromdate") = 2017 
                AND b."ASA_Class_Attended" = 1.00
            ) as a 
            UNION
            SELECT * FROM (
                SELECT "ASMCL_ClassName", "ASMC_SectionName", "ASMCL_Order", "ASMC_Order", 
                    e."ASMCL_Id", f."ASMS_Id", ''A'' as flag, (b."ASA_Class_Attended") as "TOTAL_PRESENT", 
                    EXTRACT(DAY FROM a."asa_fromdate")::INT as "MONTH_NAME"
                FROM "Adm_Student_Attendance" a 
                INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_Id" = a."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id" AND f."ASMS_Id" = a."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id" AND g."ASMAY_Id" = a."ASMAY_Id"
                WHERE a."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "ASA_Activeflag" = TRUE 
                AND c."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || p_monthid || ' 
                AND EXTRACT(YEAR FROM a."asa_fromdate") = 2017 
                AND b."ASA_Class_Attended" = 0.00
            ) as a
        ) as dfdfdf ORDER BY "ASMCL_Order", "ASMC_Order" LIMIT 100';

        RETURN QUERY EXECUTE v_sqlquery1;

    ELSE

        DELETE FROM "NewTablemonth";

        SELECT "ASMAY_From_Date" INTO v_startDate 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_mi_id::INT AND "ASMAY_Id" = p_ASMAY_Id::INT;
        
        SELECT "ASMAY_To_Date" INTO v_endDate 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_mi_id::INT AND "ASMAY_Id" = p_ASMAY_Id::INT;

        WITH CTE AS (
            SELECT v_startDate::DATE AS "Dates"
            UNION ALL
            SELECT ("Dates" + INTERVAL '1 month')::DATE
            FROM CTE 
            WHERE "Dates"::DATE <= v_endDate::DATE
        )
        INSERT INTO "NewTablemonth"("MonthId", "AYear")
        SELECT EXTRACT(MONTH FROM "Dates")::INT, EXTRACT(YEAR FROM "Dates")::INT FROM CTE;

        SELECT "AYear" INTO v_year FROM "NewTablemonth" WHERE "MonthId" = p_monthid::INT;

        DROP TABLE IF EXISTS "calender";

        CREATE TEMP TABLE "calender"(
            day INT,
            date VARCHAR(50)
        ) ON COMMIT DROP;

        v_fromdate := TO_CHAR(v_fromdate::DATE, 'DD/MM/YYYY');
        v_todate := TO_CHAR(v_todate::DATE, 'DD/MM/YYYY');

        v_Query := 'WITH days AS (
            SELECT generate_series(1, 
                EXTRACT(DAY FROM (DATE ''' || v_year::TEXT || '-' || p_monthid || '-01''::DATE + INTERVAL ''1 month - 1 day''))::INT
            ) AS day
        )
        SELECT day, TO_CHAR(DATE ''' || v_year::TEXT || '-' || p_monthid || '-'' || day, ''DD-MM-YYYY'') as date FROM days';

        FOR rec IN EXECUTE v_Query LOOP
            INSERT INTO "calender"(day, date) VALUES (rec.day, rec.date);
        END LOOP;

        v_monthyearsd := '';
        v_monthyearsd1 := '';

        FOR rec IN SELECT date, day FROM "calender" LOOP
            v_cols := rec.date;
            v_cols1 := rec.day::TEXT;
            
            v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || v_cols1 || '"' || ', ', '');

            v_monthyearsd1 := COALESCE(v_monthyearsd1, '') || 
            'CASE WHEN (SELECT COUNT(*) FROM "Adm_Student_Attendance" a 
                INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id" 
                WHERE a."mi_id" = ' || p_mi_id || ' AND "ASA_Activeflag" = TRUE 
                AND a."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND a."asmcl_id" = ' || p_ASMCL_Id || ' 
                AND a."asms_id" = ' || p_ASMS_Id || ' 
                AND TO_CHAR(a."ASA_FromDate", ''DD-MM-YYYY'') = ''' || v_cols || ''') > 0 
            THEN "' || v_cols1 || '" 
            WHEN TO_CHAR(TO_DATE(''' || v_cols || ''', ''DD-MM-YYYY''), ''Day'') = ''Sunday'' THEN -1 
            WHEN (SELECT COUNT(*) FROM "FO"."FO_HolidayWorkingDay_Type" "FHDT" 
                INNER JOIN "FO"."FO_Master_HolidayWorkingDay" "FMH" ON "FHDT"."FOHWDT_Id" = "FMH"."FOHWDT_Id"
                INNER JOIN "FO"."FO_Master_HolidayWorkingDay_Dates" "FMHD" ON "FMHD"."FOHWDT_Id" = "FMH"."FOHWDT_Id"
                WHERE "FHDT"."mi_id" = ' || p_mi_id || ' AND "FHDT"."FOHTWD_HolidayWDTypeFlag" = ''PH'' 
                AND (TO_CHAR("FMHD"."FOMHWDD_FromDate", ''DD-MM-YYYY'') >= ''' || v_cols || ''' 
                OR TO_CHAR("FMHD"."FOMHWDD_ToDate", ''DD-MM-YYYY'') <= ''' || v_cols || ''')) > 0 
            THEN -2 ELSE -3 END AS "' || v_cols1 || '", ';
        END LOOP;

        v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 1);
        v_monthyearsd1 := LEFT(v_monthyearsd1, LENGTH(v_monthyearsd1) - 1);

        v_sqlquery1 := 'SELECT "ASMCL_ClassName", "ASMC_SectionName", "ASMCL_Order", "ASMC_Order", 
            "ASMCL_Id", "ASMS_Id", flag, ' || v_monthyearsd1 || ' FROM (
            SELECT * FROM (
                SELECT "ASMCL_ClassName", "ASMC_SectionName", "ASMCL_Order", "ASMC_Order", 
                    e."ASMCL_Id", f."ASMS_Id", ''P'' as flag, (b."ASA_Class_Attended") as "TOTAL_PRESENT", 
                    EXTRACT(DAY FROM a."asa_fromdate")::INT as "MONTH_NAME"
                FROM "Adm_Student_Attendance" a 
                INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_Id" = a."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id" AND f."ASMS_Id" = a."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id" AND g."ASMAY_Id" = a."ASMAY_Id"
                WHERE a."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "ASA_Activeflag" = TRUE 
                AND a."asmcl_id" = ' || p_ASMCL_Id || ' AND a."asms_id" = ' || p_ASMS_Id || ' 
                AND c."asmcl_id" = ' || p_ASMCL_Id || ' AND c."asms_id" = ' || p_ASMS_Id || ' 
                AND c."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || p_monthid || ' 
                AND EXTRACT(YEAR FROM a."asa_fromdate") = 2017 
                AND b."ASA_Class_Attended" = 1.00
            ) as a 
            UNION
            SELECT * FROM (
                SELECT "ASMCL_ClassName", "ASMC_SectionName", "ASMCL_Order", "ASMC_Order", 
                    e."ASMCL_Id", f."ASMS_Id", ''A'' as flag, (b."ASA_Class_Attended") as "TOTAL_PRESENT", 
                    EXTRACT(DAY FROM a."asa_fromdate")::INT as "MONTH_NAME"
                FROM "Adm_Student_Attendance" a 
                INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id" AND e."ASMCL_Id" = a."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id" AND f."ASMS_Id" = a."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id" AND g."ASMAY_Id" = a."ASMAY_Id"
                WHERE a."ASMAY_Id" = ' || p_ASMAY_Id || ' AND "ASA_Activeflag" = TRUE 
                AND c."ASMAY_Id" = ' || p_ASMAY_Id || ' AND a."asms_id" = ' || p_ASMS_Id || ' 
                AND c."asmcl_id" = ' || p_ASMCL_Id || ' AND c."asms_id" = ' || p_ASMS_Id || ' 
                AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || p_monthid || ' 
                AND EXTRACT(YEAR FROM a."asa_fromdate") = 2017 
                AND b."ASA_Class_Attended" = 0.00
            ) as a
        ) as dfdfdf ORDER BY "ASMCL_Order", "ASMC_Order" LIMIT 100';

        RETURN QUERY EXECUTE v_sqlquery1;

    END IF;

END;
$$;