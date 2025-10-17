CREATE OR REPLACE FUNCTION "dbo"."Adm_School_SubjectwiseAttendanceSMS_multiple"(
    "@MI_Id" VARCHAR(100),
    "@ASMAY_Id" VARCHAR(200),
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@FromDate" VARCHAR(10),
    "@ToDate" VARCHAR(10),
    "@ISMS_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE(
    "SUBJECTS" TEXT,
    "STUDENT_NAME" TEXT,
    "AMST_Id" INTEGER,
    "AMST_AdmNo" VARCHAR,
    "AMST_MobileNo" VARCHAR,
    "ASA_FromDate" DATE,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASA_Class_Attended" TEXT,
    "CLASS" TEXT,
    "DATE" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@query" TEXT;
BEGIN

    "@query" := 'SELECT DISTINCT STRING_AGG(DISTINCT ''"IMS"."ISMS_SubjectName"'','','') as "SUBJECTS",
    COALESCE("AMS"."AMST_FirstName",'''') || '' '' || COALESCE("AMS"."AMST_MiddleName",'''') || '' '' || COALESCE("AMS"."AMST_LastName",'''') AS "STUDENT_NAME"
    ,"AMS"."AMST_Id","AMS"."AMST_AdmNo","AMS"."AMST_MobileNo",CAST("ASA_FromDate" AS DATE) AS "ASA_FromDate","ASMC"."ASMCL_ClassName","ASMS"."ASMC_SectionName",
    STRING_AGG((CASE WHEN "ASA_Class_Attended"=1.00 THEN CAST("MP"."TTMP_PeriodName" AS TEXT) || '':'' || ''P'' WHEN "ASA_Class_Attended"=0.00 THEN CAST("MP"."TTMP_PeriodName" AS TEXT) || '':'' || ''A'' END),'', '' ORDER BY (CASE WHEN "ASA_Class_Attended"=1.00 THEN CAST("MP"."TTMP_PeriodName" AS TEXT) || '':'' || ''P'' WHEN "ASA_Class_Attended"=0.00 THEN CAST("MP"."TTMP_PeriodName" AS TEXT) || '':'' || ''A'' END)) AS "ASA_Class_Attended",
    ("ASMC"."ASMCL_ClassName" || '' Class '' || "ASMS"."ASMC_SectionName") || '' Section'' AS "CLASS",
    TO_CHAR(TO_DATE(''' || "@FromDate" || ''',''YYYY-MM-DD''),''DD/MM/YYYY'') AS "DATE"
    FROM "Adm_Student_Attendance" "ASA"
    INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id"="ASAP"."ASA_Id"
    INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id"="ASA"."ASA_Id"
    INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id"="ASAS"."ISMS_Id" AND "IMS"."MI_Id"=' || "@MI_Id" || '
    INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id"="ASA"."ASA_Id"
    INNER JOIN "TT_Master_Period" "MP" ON "MP"."TTMP_Id"="ASAP"."TTMP_Id" AND "MP"."MI_Id"=' || "@MI_Id" || '
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id"="ASAST"."AMST_Id" AND "ASYS"."ASMAY_Id"="ASA"."ASMAY_Id"
    INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id"="ASYS"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id"="ASYS"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id"="ASYS"."ASMS_Id"
    WHERE "ASA"."MI_Id"=' || "@MI_Id" || ' AND "ASA"."ASMAY_Id"=' || "@ASMAY_Id" || '
    AND "ASYS"."ASMAY_Id"=' || "@ASMAY_Id" || ' AND "ASA"."ASMCL_Id" IN (' || "@ASMCL_Id" || ')
    AND "ASA"."ASMS_Id" IN (' || "@ASMS_Id" || ') AND "ASAS"."ISMS_Id" IN (' || "@ISMS_Id" || ')
    AND "ASAST"."ASA_Class_Attended"=0.00 AND "ASAST"."AMST_Id" IN (' || "@AMST_Id" || ')
    AND CAST("ASA_FromDate" AS DATE)=''' || "@FromDate" || '''
    AND "ASA_Activeflag"=1 AND "ASA_Att_Type"=''Period'' AND "ASYS"."AMAY_ActiveFlag"=1 AND "AMS"."AMST_ActiveFlag"=1 AND "AMS"."AMST_SOL"=''S''
    GROUP BY "ASAST"."AMST_Id","ASA_FromDate","ASMC"."ASMCL_ClassName","AMS"."AMST_AdmNo","AMS"."AMST_Id","AMS"."AMST_MobileNo","AMS"."AMST_FirstName","AMS"."AMST_MiddleName","AMS"."AMST_LastName","ASMC_SectionName"';

    RETURN QUERY EXECUTE "@query";

END;
$$;