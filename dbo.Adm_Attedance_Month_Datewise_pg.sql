CREATE OR REPLACE FUNCTION "dbo"."Adm_Attedance_Month_Datewise"(
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
    "AMAY_RollNo" TEXT,
    "result" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "cols" TEXT;
    "cols1" TEXT;
    "query" TEXT;
    "monthyearsd" TEXT := '';
    "monthids" TEXT;
    "monthids1" TEXT;
    "monthyearsd1" TEXT := '';
    "year" TEXT;
    "date_record" RECORD;
    "day_num" INTEGER;
    "date_str" TEXT;
BEGIN
    SELECT EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::TEXT INTO "year";

    FOR "date_record" IN 
        WITH RECURSIVE "tally"("N") AS (
            SELECT 1
            UNION ALL
            SELECT "N" + 1
            FROM "tally"
            WHERE "N" < EXTRACT(DAY FROM (DATE_TRUNC('MONTH', (("year"||'-'||"month"||'-01')::DATE)) + INTERVAL '1 MONTH' - INTERVAL '1 DAY'))
        )
        SELECT 
            "N" AS "day",
            TO_CHAR(TO_DATE("year"||'-'||"month"||'-'||"N", 'YYYY-MM-DD'), 'DD-MM-YYYY') AS "date"
        FROM "tally"
    LOOP
        "cols1" := "date_record"."day"::TEXT;
        "cols" := "date_record"."date";
        
        IF "monthyearsd" = '' THEN
            "monthyearsd" := '"' || "cols" || '"';
        ELSE
            "monthyearsd" := "monthyearsd" || ', "' || "cols" || '"';
        END IF;
        
        IF "monthyearsd1" = '' THEN
            "monthyearsd1" := 'COALESCE("' || "cols" || '", 0) AS "' || "cols" || '"';
        ELSE
            "monthyearsd1" := "monthyearsd1" || ', COALESCE("' || "cols" || '", 0) AS "' || "cols" || '"';
        END IF;
    END LOOP;

    "query" := 'SELECT "name", "AMST_AdmNo", "AMST_RegistrationNo", "AMAY_RollNo", ' || "monthyearsd1" || 
               ' FROM CROSSTAB(
                   ''SELECT 
                       "b"."AMST_Id"::TEXT || '''' '''' || "name" AS "row_id",
                       "name",
                       "AMST_AdmNo",
                       "AMST_RegistrationNo",
                       "AMAY_RollNo",
                       TO_CHAR("a"."ASA_FromDate", ''''DD-MM-YYYY'''') AS "MONTH_NAME",
                       "b"."ASA_Class_Attended"
                   FROM "adm_student_attendance" "a"
                   INNER JOIN "adm_student_attendance_students" "b" ON "a"."asa_id" = "b"."asa_id"
                   INNER JOIN "adm_school_Y_student" "c" ON "c"."amst_id" = "b"."AMST_Id" AND "c"."asmay_id" = "a"."asmay_id"
                   INNER JOIN "Adm_M_Student" "d" ON "d"."AMST_Id" = "c"."AMST_Id"
                   WHERE "c"."ASMAY_Id" = ' || "asmay_id" || 
                   ' AND "a"."MI_Id" = ' || "mi_id" || 
                   ' AND "c"."ASMCL_Id" = ' || "asmcl_id" || 
                   ' AND "c"."ASMS_Id" = ' || "asms_id" || 
                   ' AND "d"."amst_sol" = ''''S'''' 
                   AND "d"."amst_activeflag" = 1 
                   AND "c"."amay_activeflag" = 1
                   AND EXTRACT(MONTH FROM "a"."ASA_FromDate") = ' || "month" || 
                   ' AND EXTRACT(YEAR FROM "a"."ASA_FromDate") = ' || "year" || 
                   ' ORDER BY 1, 6'',
                   ''SELECT DISTINCT TO_CHAR("ASA_FromDate", ''''DD-MM-YYYY'''') 
                     FROM "adm_student_attendance" 
                     WHERE EXTRACT(MONTH FROM "ASA_FromDate") = ' || "month" || 
                   ' AND EXTRACT(YEAR FROM "ASA_FromDate") = ' || "year" || 
                   ' ORDER BY 1''
               ) AS ct("row_id" TEXT, "name" TEXT, "AMST_AdmNo" TEXT, "AMST_RegistrationNo" TEXT, "AMAY_RollNo" TEXT, ' || "monthyearsd" || ' NUMERIC)';

    RETURN QUERY EXECUTE "query";
END;
$$;