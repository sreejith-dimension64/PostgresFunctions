CREATE OR REPLACE FUNCTION "dbo"."Attendance_Periods_daywise_report"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "StudentName" text,
    "Class-Section" text,
    "ASA_FromDate" varchar(10),
    "ASA_ClassHeld" bigint,
    "PresentCount" bigint,
    "AbsentCount" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT 
    (COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '')) AS "StudentName",
    ("ASMC"."ASMCL_ClassName" || ':' || "ASMS"."ASMC_SectionName") AS "Class-Section",
    TO_CHAR("ASA"."ASA_FromDate", 'DD/MM/YYYY') AS "ASA_FromDate",
    COALESCE(SUM("ASA"."ASA_ClassHeld"), 0) AS "ASA_ClassHeld",
    COALESCE(SUM(CASE WHEN "ASAS"."ASA_Class_Attended" = 1.00 THEN 1 END), 0) AS "PresentCount",
    COALESCE(SUM(CASE WHEN "ASAS"."ASA_Class_Attended" = 0.00 THEN 1 END), 0) AS "AbsentCount"
FROM "Adm_Student_Attendance" "ASA"
INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id" = "ASAP"."ASA_Id"
INNER JOIN "Adm_Student_Attendance_Students" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASA"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASA"."ASMS_Id"
INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "ASAS"."AMST_Id"
INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
WHERE "ASA"."MI_Id" = p_MI_Id 
    AND "ASA"."ASMAY_Id" = p_ASMAY_Id 
    AND "ASA"."ASA_Att_Type" = 'Period'
    AND "AMS"."AMST_SOL" = 'S' 
    AND "AMS"."AMST_ActiveFlag" = 1 
    AND "ASYS"."AMAY_ActiveFlag" = 1
GROUP BY 
    (COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '')),
    ("ASMC"."ASMCL_ClassName" || ':' || "ASMS"."ASMC_SectionName"),
    "ASA"."ASA_FromDate"
ORDER BY 
    "StudentName",
    "ASA"."ASA_FromDate";

END;
$$;