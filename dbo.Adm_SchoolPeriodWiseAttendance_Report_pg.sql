CREATE OR REPLACE FUNCTION "dbo"."Adm_SchoolPeriodWiseAttendance_Report"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "FromDate" VARCHAR(10),
    "ToDate" VARCHAR(10),
    "HRME_Id" TEXT
)
RETURNS TABLE(
    "ASA_Id" INTEGER,
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASA_FromDate" VARCHAR,
    "ASA_Entry_DateTime" VARCHAR,
    "EmpName" TEXT,
    "ISMS_SubjectName" VARCHAR,
    "TTMP_PeriodName" VARCHAR,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "TotalCount" BIGINT,
    "PresentCount" BIGINT,
    "AbsentCount" BIGINT,
    "ASA_FromDateTemp" DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE
    'SELECT DISTINCT "ASA"."ASA_Id", "ASMAY"."ASMAY_Year", "ASMCL_ClassName", "ASMS"."ASMC_SectionName",
    TO_CHAR("ASA"."ASA_FromDate", ''DD/MM/YYYY'') AS "ASA_FromDate",
    TO_CHAR("ASA"."ASA_Entry_DateTime", ''DD/MM/YYYY'') AS "ASA_Entry_DateTime",
    COALESCE("HME"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeLastName", '''') AS "EmpName",
    "ISMS_SubjectName", "TTMP"."TTMP_PeriodName", "ASMCL_Order", "ASMC_Order",
    COALESCE(SUM(CASE WHEN "ASA_Class_Attended" = 1.00 THEN 1 END), 0) + COALESCE(SUM(CASE WHEN "ASA_Class_Attended" = 0.00 THEN 1 END), 0) AS "TotalCount",
    COALESCE(SUM(CASE WHEN "ASA_Class_Attended" = 1.00 THEN 1 END), 0) AS "PresentCount",
    COALESCE(SUM(CASE WHEN "ASA_Class_Attended" = 0.00 THEN 1 END), 0) AS "AbsentCount",
    CAST("ASA"."ASA_FromDate" AS DATE) AS "ASA_FromDateTemp"
    FROM "Adm_Student_Attendance" "ASA"
    INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASAP"."ASA_Id" = "ASAS"."ASA_Id"
    INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASA"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASA"."ASMS_Id"
    INNER JOIN "IVRM_Master_Subjects" "ISMS" ON "ISMS"."ISMS_Id" = "ASAS"."ISMS_Id"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ASA"."HRME_Id"
    INNER JOIN "TT_Master_Period" "TTMP" ON "TTMP"."TTMP_Id" = "ASAP"."TTMP_Id"
    INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASA"."ASMAY_Id"
    WHERE "ASA"."MI_Id" = ' || $1 || ' AND "ASA"."ASMAY_Id" = ' || $2 || ' AND "ASMAY"."MI_Id" = ' || $1 || '
    AND "ASA"."ASMCL_Id" IN (' || $3 || ') AND "ASA"."ASMS_Id" IN (' || $4 || ')
    AND CAST("ASA"."ASA_FromDate" AS DATE) >= ''' || $5 || ''' AND CAST("ASA"."ASA_ToDate" AS DATE) <= ''' || $6 || '''
    AND "ASA"."ASA_Activeflag" = 1
    GROUP BY "ASA"."ASA_Id", "ASMAY"."ASMAY_Year", "ASMCL_ClassName", "ASMS"."ASMC_SectionName", "ISMS_SubjectName", "TTMP"."TTMP_PeriodName",
    TO_CHAR("ASA"."ASA_FromDate", ''DD/MM/YYYY''), TO_CHAR("ASA"."ASA_Entry_DateTime", ''DD/MM/YYYY''),
    COALESCE("HME"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HME"."HRME_EmployeeLastName", ''''),
    "ISMS_SubjectName", "TTMP"."TTMP_PeriodName", "ASMCL_Order", "ASMC_Order", CAST("ASA"."ASA_FromDate" AS DATE)
    ORDER BY "ASMCL_Order", "ASMC_Order", "ASA_FromDateTemp"'
    USING "MI_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "FromDate", "ToDate";
END;
$$;