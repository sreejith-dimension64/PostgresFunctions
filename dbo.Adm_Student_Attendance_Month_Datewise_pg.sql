CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Attendance_Month_Datewise"(
    "asmay_id" TEXT,
    "asmcl_id" TEXT,
    "asms_id" TEXT,
    "mi_id" TEXT,
    "month" TEXT
)
RETURNS TABLE(
    "name" TEXT,
    "AMST_AdmNo" TEXT,
    "AMST_RegistrationNo" TEXT,
    "AMAY_RollNo" TEXT
) AS $$
DECLARE
    "Query" TEXT;
    "Year" INT;
    "sqlquery" TEXT;
    "cursorValue" TEXT;
    "Cl" TEXT;
    "C2" TEXT;
    "query1" TEXT;
    "cols" TEXT;
    "monthyearsd" TEXT;
    "monthyearsd1" TEXT;
    "rec" RECORD;
BEGIN
    "Year" := EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::INT;
    
    DROP TABLE IF EXISTS "temp_Calender";
    CREATE TEMP TABLE "temp_Calender"("day" INT, "date" VARCHAR(50));
    
    "Query" := 'WITH RECURSIVE N AS (
        SELECT 1 AS N
        UNION ALL
        SELECT N + 1
        FROM N
        WHERE N < EXTRACT(DAY FROM (DATE_TRUNC(''MONTH'', DATE ''' || "Year"::TEXT || '-' || "month" || '-01'') + INTERVAL ''1 MONTH'' - INTERVAL ''1 DAY''))
    )
    SELECT N AS day, TO_CHAR(DATE ''' || "Year"::TEXT || '-' || "month" || '-'' || LPAD(N::TEXT, 2, ''0''), ''DD-MM-YYYY'') AS date FROM N';
    
    EXECUTE 'INSERT INTO "temp_Calender"("day", "date") ' || "Query";
    
    "monthyearsd" := '';
    "monthyearsd1" := '';
    
    FOR "rec" IN SELECT "date" FROM "temp_Calender" ORDER BY "day"
    LOOP
        "cols" := "rec"."date";
        "monthyearsd" := COALESCE("monthyearsd", '') || COALESCE('"' || "cols" || '"' || ', ', '');
        "monthyearsd1" := COALESCE("monthyearsd1", '') || ('CASE "' || "cols" || '" WHEN 1.00 THEN ''Present'' WHEN 0.00 THEN ''Absent'' WHEN 0.50 THEN '' Half Day Present'' ELSE ''Holiday / NE'' END AS "' || "cols" || '", ');
    END LOOP;
    
    "monthyearsd" := LEFT("monthyearsd", LENGTH("monthyearsd") - 2);
    "monthyearsd1" := LEFT("monthyearsd1", LENGTH("monthyearsd1") - 2);
    
    "query1" := 'SELECT "name", "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", ' || "monthyearsd1" || ' FROM (
        SELECT b."AMST_Id",
        (COALESCE(d."AMST_FirstName", '''') || '' '' || COALESCE(d."AMST_MiddleName", '''') || '' '' || COALESCE(d."AMST_LastName", '''')) AS "name",
        d."AMST_AdmNo",
        d."AMST_RegistrationNo",
        c."AMAY_RollNo",
        a."ASA_Class_Attended" AS "TOTAL_PRESENT",
        TO_CHAR(a."ASA_FromDate", ''DD-MM-YYYY'') AS "MONTH_NAME"
        FROM "adm_student_attendance" a
        INNER JOIN "adm_student_attendance_students" b ON a."asa_id" = b."asa_id"
        INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
        WHERE c."ASMAY_Id" = ' || "asmay_id" || ' 
        AND a."MI_Id" = ' || "mi_id" || ' 
        AND c."ASMCL_Id" = ' || "asmcl_id" || ' 
        AND c."ASMS_Id" = ' || "asms_id" || ' 
        AND d."amst_sol" = ''S'' 
        AND d."amst_activeflag" = 1 
        AND c."amay_activeflag" = 1
        AND EXTRACT(MONTH FROM a."ASA_FromDate") = ' || "month" || '
        AND EXTRACT(YEAR FROM a."asa_fromdate") = ' || "Year"::TEXT || '
    ) AS s
    PIVOT (
        SUM("TOTAL_PRESENT") FOR "MONTH_NAME" IN (' || "monthyearsd" || ')
    ) AS p';
    
    RETURN QUERY EXECUTE "query1";
    
    DROP TABLE IF EXISTS "temp_Calender";
    
END;
$$ LANGUAGE plpgsql;