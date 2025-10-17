CREATE OR REPLACE FUNCTION "dbo"."Adm_Attendance_Periods_daywise_report"(
    "@MI_Id" VARCHAR,
    "@ASMAY_Id" VARCHAR,
    "@ASMCL_Id" VARCHAR,
    "@ASMS_Id" VARCHAR,
    "@MonthId" VARCHAR,
    "@YearId" VARCHAR,
    "@Flag" VARCHAR
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "ClassSection" TEXT,
    "amst_admno" VARCHAR,
    "ASA_FromDate" VARCHAR,
    "ASA_ClassHeld" NUMERIC,
    "PresentCount" BIGINT,
    "AbsentCount" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@Flag" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "AMS"."AMST_Id",
            (COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '')) AS "StudentName",
            ("ASMC"."ASMCL_ClassName" || ':' || "ASMS"."ASMC_SectionName") AS "ClassSection",
            "AMS"."amst_admno",
            TO_CHAR("ASA"."ASA_FromDate", 'DD-MM-YYYY') AS "ASA_FromDate",
            COALESCE(SUM("ASA"."ASA_ClassHeld"), 0) AS "ASA_ClassHeld",
            COALESCE(SUM(CASE WHEN "ASAS"."ASA_Class_Attended" = 1.00 THEN 1 ELSE 0 END), 0) AS "PresentCount",
            COALESCE(SUM(CASE WHEN "ASAS"."ASA_Class_Attended" = 0.00 THEN 1 ELSE 0 END), 0) AS "AbsentCount",
            NULL::BIGINT AS "ASMAY_Id",
            NULL::BIGINT AS "ASMCL_Id",
            NULL::BIGINT AS "ASMS_Id"
        FROM "Adm_Student_Attendance" "ASA"
        INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id" = "ASAP"."ASA_Id"
        INNER JOIN "Adm_Student_Attendance_Students" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
        INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASA"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASA"."ASMS_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "ASAS"."AMST_Id" 
            AND "ASYS"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "ASYS"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "ASYS"."ASMS_Id" = "@ASMS_Id"::BIGINT
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
        WHERE "ASA"."MI_Id" = "@MI_Id"::BIGINT 
            AND "ASA"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "ASA"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "ASA"."ASMS_Id" = "@ASMS_Id"::BIGINT
            AND "ASA"."ASA_Att_Type" = 'Period' 
            AND EXTRACT(MONTH FROM "ASA"."ASA_FromDate") = "@MonthId"::INTEGER 
            AND EXTRACT(YEAR FROM "ASA"."ASA_FromDate") = "@YearId"::INTEGER 
            AND "ASA"."ASA_Activeflag" = 1
        GROUP BY "AMS"."AMST_Id", 
            (COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '')),
            "ASMC"."ASMCL_ClassName" || ':' || "ASMS"."ASMC_SectionName",
            "ASA"."ASA_FromDate",
            "AMS"."amst_admno"
        ORDER BY "StudentName", "ASA_FromDate"
        LIMIT 100;

    ELSIF "@Flag" = '2' THEN
        RETURN QUERY
        SELECT 
            NULL::BIGINT AS "AMST_Id",
            NULL::TEXT AS "StudentName",
            NULL::TEXT AS "ClassSection",
            NULL::VARCHAR AS "amst_admno",
            TO_CHAR("a"."ASA_FromDate", 'DD-MM-YYYY') AS "ASA_FromDate",
            COALESCE(SUM("a"."ASA_ClassHeld"), 0) AS "ASA_ClassHeld",
            NULL::BIGINT AS "PresentCount",
            NULL::BIGINT AS "AbsentCount",
            "a"."ASMAY_Id",
            "a"."ASMCL_Id",
            "a"."ASMS_Id"
        FROM "Adm_Student_Attendance" "a"
        WHERE "a"."MI_Id" = "@MI_Id"::BIGINT 
            AND "a"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "a"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "a"."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "a"."ASA_Activeflag" = 1
            AND "a"."ASA_Att_Type" = 'Period' 
            AND EXTRACT(MONTH FROM "a"."ASA_FromDate") = "@MonthId"::INTEGER 
            AND EXTRACT(YEAR FROM "a"."ASA_FromDate") = "@YearId"::INTEGER
        GROUP BY "a"."ASMAY_Id", "a"."ASMCL_Id", "a"."ASMS_Id", TO_CHAR("a"."ASA_FromDate", 'DD-MM-YYYY');

    END IF;

    RETURN;

END;
$$;