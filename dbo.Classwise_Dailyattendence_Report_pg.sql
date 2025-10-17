CREATE OR REPLACE FUNCTION "dbo"."Classwise_Dailyattendence_Report"(
    "@year" VARCHAR,
    "@fromdate" VARCHAR,
    "@class" VARCHAR(50),
    "@sec" VARCHAR(100),
    "@miid" VARCHAR(100)
)
RETURNS TABLE(
    "AMST_FirstName" TEXT,
    "AMAY_RollNo" VARCHAR,
    "asmcl_classname" VARCHAR,
    "asmc_sectionname" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "ASA_Att_EntryType" VARCHAR,
    "ASA_AttendanceFlag" VARCHAR,
    "ASA_Class_Attended" VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@flag" VARCHAR(100);
    "@sqlText" TEXT;
BEGIN
    "@fromdate" := TO_CHAR(TO_DATE("@fromdate", 'DD/MM/YYYY'), 'DD/MM/YYYY');
    
    "@sqlText" := 'SELECT DISTINCT 
        (COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || 
        COALESCE("Adm_M_Student"."AMST_LastName", '''')) as "AMST_FirstName",
        "adm_school_Y_student"."AMAY_RollNo",
        "asmcl_classname",
        "asmc_sectionname",
        "Adm_M_Student"."AMST_AdmNo",
        "Adm_Student_Attendance"."ASA_Att_EntryType",
        "Adm_Student_Attendance_Students"."ASA_AttendanceFlag",
        "Adm_Student_Attendance_Students"."ASA_Class_Attended"
    FROM 
        "dbo"."Adm_School_Y_Student" AS "Adm_School_Y_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" ON 
            "dbo"."Adm_Student_Attendance"."ASA_Id" = "dbo"."Adm_Student_Attendance_Students"."ASA_Id" 
        INNER JOIN "dbo"."Adm_M_Student" ON 
            "dbo"."Adm_Student_Attendance_Students"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" ON 
            "Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
        INNER JOIN "dbo"."Adm_School_M_Class" ON 
            "Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
        INNER JOIN "dbo"."Adm_School_M_Section" ON 
            "Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "adm_school_M_academic_year" ON 
            "adm_school_M_academic_year"."asmay_id" = "Adm_School_Y_Student"."asmay_id"
    WHERE 
        "Adm_School_M_Class"."ASMCL_Id" = ' || "@class" || ' 
        AND "Adm_School_M_Section"."ASMS_Id" IN (' || "@sec" || ') 
        AND "Adm_Student_Attendance"."ASMAY_Id" = ' || "@year" || ' 
        AND "ASA_Activeflag" = 1 
        AND "Adm_School_Y_Student"."asmay_id" = ' || "@year" || '
        AND TO_DATE("Adm_Student_Attendance"."ASA_FromDate"::TEXT, ''DD/MM/YYYY'') = TO_DATE(''' || "@fromdate" || ''', ''DD/MM/YYYY'')
        AND "Adm_Student_Attendance"."MI_Id" = ' || "@miid" || ' 
        AND "Adm_M_Student"."AMST_SOL" = ''S'' 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1 
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1';
    
    RETURN QUERY EXECUTE "@sqlText";
END;
$$;