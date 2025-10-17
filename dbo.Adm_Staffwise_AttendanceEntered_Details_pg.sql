CREATE OR REPLACE FUNCTION "dbo"."Adm_Staffwise_AttendanceEntered_Details"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FromDate VARCHAR(10),
    p_ToDate VARCHAR(10),
    p_ISMS_Id TEXT,
    p_Flag VARCHAR(100)
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASA_FROMDATE" VARCHAR,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "ASA_fROMDATETemp" TIMESTAMP,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_Id" INTEGER,
    "Periods" TEXT,
    "columnname" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SqlDynamic TEXT;
    v_Current DATE;
BEGIN

IF p_Flag = '1' THEN

    DROP TABLE IF EXISTS "Adm_Staffwise_AttendanceEnteredXmlPath_Temp";

    v_SqlDynamic := '
    CREATE TEMP TABLE "Adm_Staffwise_AttendanceEnteredXmlPath_Temp" AS
    SELECT DISTINCT "MY"."ASMAY_Year", "MC"."ASMCL_ClassName", "MS"."ASMC_SectionName", 
    TO_CHAR("ASA"."ASA_fROMDATE", ''DD-MM-YYYY'') AS "ASA_FROMDATE",
    TO_CHAR("ASA"."ASA_Entry_DateTime", ''DD/MM/YYYY'') AS "ASA_Entry_DateTime",
    COALESCE("HRME"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HRME"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HRME"."HRME_EmployeeLastName", '''') AS "EMPLOYEENAME",
    "MC"."ASMCL_Order", "MS"."ASMC_Order", "ASA"."ASA_fROMDATE" as "ASA_fROMDATETemp", "ASASU"."ISMS_Id", "IMS"."ISMS_SubjectName", "ASAP"."TTMP_Id", "TTMP"."TTMP_PeriodName"
    FROM "Adm_Student_Attendance" "ASA"
    INNER JOIN "HR_Master_Employee" "HRME" ON "HRME"."HRME_Id" = "ASA"."HRME_Id"
    INNER JOIN "Adm_School_M_Class" "MC" ON "MC"."ASMCL_Id" = "ASA"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "MS" ON "MS"."ASMS_Id" = "ASA"."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "MY" ON "MY"."ASMAY_Id" = "ASA"."ASMAY_Id"
    INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASAP"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "Adm_Student_Attendance_Subjects" "ASASU" ON "ASASU"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASASU"."ISMS_Id"
    INNER JOIN "TT_MASTER_PERIOD" "TTMP" ON "TTMP"."TTMP_Id" = "ASAP"."TTMP_Id"
    WHERE "ASA"."MI_Id" = ' || p_MI_Id || ' AND "ASA"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
    AND "ASA"."ASMCL_Id" IN (' || p_ASMCL_Id || ') AND "ASA"."ASMS_Id" IN (' || p_ASMS_Id || ')
    AND (CAST("ASA"."ASA_FROMDATE" AS DATE) >= ''' || p_FromDate || ''' AND CAST("ASA"."ASA_FROMDATE" AS DATE) <= ''' || p_ToDate || ''')
    AND "ASA"."ASA_Activeflag" = 1
    AND "IMS"."ISMS_Id" IN (SELECT "ISMS_Id" FROM "IVRM_Master_Subjects" WHERE "MI_Id" = ' || p_MI_Id || ' AND "ISMS_Id" IN (' || p_ISMS_Id || '))
    ORDER BY "ASMCL_Order", "ASMC_Order", "ASA_fROMDATETemp"';

    EXECUTE v_SqlDynamic;

    RETURN QUERY
    SELECT DISTINCT "S"."ASMAY_Year", "S"."ASMCL_ClassName", "S"."ASMC_SectionName", "S"."ASA_FROMDATE", "S"."ASMCL_Order", "S"."ASMC_Order", 
    "S"."ASA_fROMDATETemp", "S"."ISMS_SubjectName", "S"."ISMS_Id",
    (SELECT STRING_AGG(DISTINCT 'Staff/Period:' || TRIM("T"."EMPLOYEENAME") || '/' || "T"."TTMP_PeriodName", ', ')
     FROM "Adm_Staffwise_AttendanceEnteredXmlPath_Temp" "T"
     WHERE "S"."ASA_FROMDATE" = "T"."ASA_FROMDATE"
     AND "T"."ISMS_SubjectName" = "S"."ISMS_SubjectName"
     AND "T"."ISMS_Id" = "S"."ISMS_Id") AS "Periods",
    NULL::VARCHAR AS "columnname"
    FROM "Adm_Staffwise_AttendanceEnteredXmlPath_Temp" "S";

ELSIF p_Flag = '2' THEN

    v_Current := p_FromDate::DATE;

    DROP TABLE IF EXISTS "Temp_All_Days_InBetween_FromDate_ToDate";

    CREATE TEMP TABLE "Temp_All_Days_InBetween_FromDate_ToDate"("displayDate" DATE);

    WHILE v_Current <= p_ToDate::DATE LOOP
        INSERT INTO "Temp_All_Days_InBetween_FromDate_ToDate" VALUES(v_Current);
        v_Current := v_Current + INTERVAL '1 day';
    END LOOP;

    RETURN QUERY
    SELECT NULL::VARCHAR AS "ASMAY_Year", NULL::VARCHAR AS "ASMCL_ClassName", NULL::VARCHAR AS "ASMC_SectionName",
    NULL::VARCHAR AS "ASA_FROMDATE", NULL::INTEGER AS "ASMCL_Order", NULL::INTEGER AS "ASMC_Order",
    NULL::TIMESTAMP AS "ASA_fROMDATETemp", NULL::VARCHAR AS "ISMS_SubjectName", NULL::INTEGER AS "ISMS_Id",
    NULL::TEXT AS "Periods",
    TO_CHAR("displayDate", 'DD-MM-YYYY') AS "columnname"
    FROM "Temp_All_Days_InBetween_FromDate_ToDate";

END IF;

END;
$$;