CREATE OR REPLACE FUNCTION "dbo"."Adm_School_SubjectwiseAttendanceSMS1"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FromDate VARCHAR(10),
    p_ToDate VARCHAR(10),
    p_ISMS_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "ISMS_Id" INTEGER,
    "ISMS_SubjectName" TEXT,
    "AMST_Id" INTEGER,
    "StuName" TEXT,
    "AMST_AdmNo" TEXT,
    "ASA_FromDate" DATE,
    "TTMP_PeriodName" TEXT,
    "ASA_Class_Attended" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    v_query := 'SELECT DISTINCT "ASAS"."ISMS_Id", "IMS"."ISMS_SubjectName", "AMS"."AMST_Id", 
        COALESCE("AMS"."AMST_FirstName", '''') || '' '' || COALESCE("AMS"."AMST_MiddleName", '''') || '' '' || COALESCE("AMS"."AMST_LastName", '''') AS "StuName",
        "AMS"."AMST_AdmNo",
        CAST("ASA"."ASA_FromDate" AS DATE) AS "ASA_FromDate",
        "MP"."TTMP_PeriodName",
        (CASE WHEN "ASAST"."ASA_Class_Attended" = 1.00 THEN ''P'' WHEN "ASAST"."ASA_Class_Attended" = 0.00 THEN ''A'' END) AS "ASA_Class_Attended"
    FROM "Adm_Student_Attendance" "ASA"
    INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id" = "ASAP"."ASA_Id"
    INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASAS"."ISMS_Id" AND "IMS"."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "TT_Master_Period" "MP" ON "MP"."TTMP_Id" = "ASAP"."TTMP_Id" AND "MP"."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "adm_school_y_student" "ASYS" ON "ASYS"."AMST_Id" = "ASAST"."AMST_Id"
    INNER JOIN "adm_m_student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
    WHERE "ASA"."MI_Id" = ' || p_MI_Id || ' 
        AND "ASA"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
        AND "ASA"."ASMCL_Id" = ' || p_ASMCL_Id || ' 
        AND "ASA"."ASMS_Id" = ' || p_ASMS_Id || ' 
        AND "ASAS"."ISMS_Id" = ' || p_ISMS_Id || ' 
        AND "ASAST"."ASA_Class_Attended" = 0.00 
        AND "ASAST"."AMST_Id" IN (' || p_AMST_Id || ')
        AND CAST("ASA"."ASA_FromDate" AS DATE) = ''' || p_FromDate || ''' 
        AND CAST("ASA"."ASA_ToDate" AS DATE) <= ''' || p_ToDate || ''' 
        AND "ASA"."ASA_Activeflag" = 1 
        AND "ASA"."ASA_Att_Type" = ''Period'' 
        AND "ASYS"."AMAY_ActiveFlag" = 1 
        AND "AMS"."AMST_ActiveFlag" = 1';

    RETURN QUERY EXECUTE v_query;
END;
$$;