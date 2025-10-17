CREATE OR REPLACE FUNCTION "dbo"."Adm_School_AbsentSubjectwiseAttendance_multiple"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id text,
    p_ASMS_Id text,
    p_FromDate varchar(10),
    p_ToDate varchar(10),
    p_ISMS_Id text
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "ISMS_SubjectName" varchar,
    "AMST_Id" bigint,
    "StuName" text,
    "AMST_AdmNo" varchar,
    "ASA_FromDate" date,
    "TTMP_PeriodName" varchar,
    "ASA_Class_Attended" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query text;
BEGIN

    v_query := 'SELECT DISTINCT "ASAS"."ISMS_Id",
                       "IMS"."ISMS_SubjectName",
                       "AMS"."AMST_Id",
                       COALESCE("AMS"."AMST_FirstName",'''') || '' '' || COALESCE("AMS"."AMST_MiddleName",'''') || '' '' || COALESCE("AMS"."AMST_LastName",'''') AS "StuName",
                       "AMS"."AMST_AdmNo",
                       CAST("ASA"."ASA_FromDate" AS date) AS "ASA_FromDate",
                       "MP"."TTMP_PeriodName",
                       (CASE WHEN "ASAST"."ASA_Class_Attended" = 1.00 THEN ''P'' 
                             WHEN "ASAST"."ASA_Class_Attended" = 0.00 THEN ''A'' 
                        END) AS "ASA_Class_Attended"
                FROM "Adm_Student_Attendance" "ASA"
                INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id" = "ASAP"."ASA_Id"
                INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
                INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASAS"."ISMS_Id" 
                           AND "IMS"."MI_Id" = ' || p_MI_Id || '
                INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
                INNER JOIN "TT_Master_Period" "MP" ON "MP"."TTMP_Id" = "ASAP"."TTMP_Id" 
                           AND "MP"."MI_Id" = ' || p_MI_Id || '
                INNER JOIN "adm_school_y_student" "ASYS" ON "ASYS"."AMST_Id" = "ASAST"."AMST_Id" 
                           AND "ASYS"."ASMAY_Id" = "ASA"."ASMAY_Id" 
                           AND "ASYS"."ASMAY_Id" = ' || p_ASMAY_Id || '
                INNER JOIN "adm_m_student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                WHERE "ASA"."MI_Id" = ' || p_MI_Id || ' 
                  AND "ASA"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                  AND "ASA"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
                  AND "ASA"."ASMS_Id" IN (' || p_ASMS_Id || ') 
                  AND "ASAS"."ISMS_Id" IN (' || p_ISMS_Id || ') 
                  AND "ASAST"."ASA_Class_Attended" = 0.00
                  AND CAST("ASA"."ASA_FromDate" AS date) >= ''' || p_FromDate || '''
                  AND CAST("ASA"."ASA_ToDate" AS date) <= ''' || p_ToDate || '''
                  AND "ASA"."ASA_Activeflag" = 1 
                  AND "ASA"."ASA_Att_Type" = ''Period'' 
                  AND "ASYS"."AMAY_ActiveFlag" = 1 
                  AND "AMS"."AMST_ActiveFlag" = 1';

    RETURN QUERY EXECUTE v_query;

END;
$$;