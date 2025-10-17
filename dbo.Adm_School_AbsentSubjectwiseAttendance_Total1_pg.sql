CREATE OR REPLACE FUNCTION "dbo"."Adm_School_AbsentSubjectwiseAttendance_Total1"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint,
    "@FromDate" varchar(10),
    "@ToDate" varchar(10),
    "@ISMS_Id" bigint
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
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "ASAS"."ISMS_Id",
        "IMS"."ISMS_SubjectName",
        "AMS"."AMST_Id",
        COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '') AS "StuName",
        "AMS"."AMST_AdmNo",
        CAST("ASA"."ASA_FromDate" AS date) AS "ASA_FromDate",
        "MP"."TTMP_PeriodName",
        (CASE 
            WHEN "ASAST"."ASA_Class_Attended" = 1.00 THEN 'P' 
            WHEN "ASAST"."ASA_Class_Attended" = 0.00 THEN 'A' 
        END) AS "ASA_Class_Attended"
    FROM "Adm_Student_Attendance" "ASA"
    INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id" = "ASAP"."ASA_Id"
    INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASAS"."ISMS_Id" AND "IMS"."MI_Id" = "@MI_Id"
    INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "TT_Master_Period" "MP" ON "MP"."TTMP_Id" = "ASAP"."TTMP_Id" AND "MP"."MI_Id" = "@MI_Id"
    INNER JOIN "adm_school_y_student" "ASYS" ON "ASYS"."AMST_Id" = "ASAST"."AMST_Id"
    INNER JOIN "adm_m_student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
    WHERE "ASA"."MI_Id" = "@MI_Id" 
        AND "ASA"."ASMAY_Id" = "@ASMAY_Id" 
        AND "ASA"."ASMCL_Id" = "@ASMCL_Id" 
        AND "ASA"."ASMS_Id" = "@ASMS_Id" 
        AND "ASAS"."ISMS_Id" = "@ISMS_Id" 
        AND "ASAST"."ASA_Class_Attended" = 0.00 
        AND CAST("ASA"."ASA_FromDate" AS date) >= CAST("@FromDate" AS date) 
        AND CAST("ASA"."ASA_ToDate" AS date) <= CAST("@ToDate" AS date) 
        AND "ASA"."ASA_Activeflag" = 1 
        AND "ASA"."ASA_Att_Type" = 'Period' 
        AND "ASYS"."AMAY_ActiveFlag" = 1 
        AND "AMS"."AMST_ActiveFlag" = 1;
END;
$$;