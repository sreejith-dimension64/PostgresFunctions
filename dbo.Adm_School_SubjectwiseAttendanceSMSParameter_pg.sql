CREATE OR REPLACE FUNCTION "dbo"."Adm_School_SubjectwiseAttendanceSMSParameter"(
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
    "ISMS_Id" INTEGER,
    "ISMS_SubjectName" VARCHAR,
    "AMST_Id" INTEGER,
    "StuName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMST_MobileNo" VARCHAR,
    "ASA_FromDate" DATE,
    "TTMP_PeriodName" VARCHAR,
    "ASA_Class_Attended" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    v_query := 'SELECT DISTINCT "ASAS"."ISMS_Id", "IMS"."ISMS_SubjectName", "AMS"."AMST_Id", 
                COALESCE("AMS"."AMST_FirstName", '''') || '' '' || COALESCE("AMS"."AMST_MiddleName", '''') || '' '' || COALESCE("AMS"."AMST_LastName", '''') AS "StuName",
                "AMS"."AMST_AdmNo", "AMS"."AMST_MobileNo",
                CAST("ASA_FromDate" AS DATE) AS "ASA_FromDate", "TTMP_PeriodName",
                (CASE WHEN "ASA_Class_Attended" = 1.00 THEN ''P'' WHEN "ASA_Class_Attended" = 0.00 THEN ''A'' END) AS "ASA_Class_Attended"
                FROM "Adm_Student_Attendance" "ASA"
                INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id" = "ASAP"."ASA_Id"
                INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
                INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASAS"."ISMS_Id" AND "IMS"."MI_Id" = ' || "@MI_Id" || '
                INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
                INNER JOIN "TT_Master_Period" "MP" ON "MP"."TTMP_Id" = "ASAP"."TTMP_Id" AND "MP"."MI_Id" = ' || "@MI_Id" || '
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "ASAST"."AMST_Id" AND "ASYS"."ASMAY_Id" = "ASA"."ASMAY_Id"
                INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                WHERE "ASA"."MI_Id" = ' || "@MI_Id" || ' AND "ASA"."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND "ASYS"."ASMAY_Id" = ' || "@ASMAY_Id" || ' 
                AND "ASA"."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND "ASA"."ASMS_Id" = ' || "@ASMS_Id" || ' 
                AND "ASAS"."ISMS_Id" = ' || "@ISMS_Id" || ' AND "ASAST"."AMST_Id" IN (' || "@AMST_Id" || ') AND "ASA_Class_Attended" = 0.00
                AND CAST("ASA_FromDate" AS DATE) >= ''' || "@FromDate" || ''' AND CAST("ASA_ToDate" AS DATE) <= ''' || "@ToDate" || ''' 
                AND "ASA_Activeflag" = 1 AND "ASA_Att_Type" = ''Period'' AND "ASYS"."AMAY_ActiveFlag" = 1 
                AND "AMS"."AMST_ActiveFlag" = 1 AND "AMS"."AMST_SOL" = ''S''';

    RETURN QUERY EXECUTE v_query;
    
    RETURN;
END;
$$;