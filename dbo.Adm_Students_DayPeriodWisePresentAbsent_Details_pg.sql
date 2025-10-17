CREATE OR REPLACE FUNCTION "dbo"."Adm_Students_DayPeriodWisePresentAbsent_Details"(
    "MI_Id" VARCHAR(100),
    "ASMAY_Id" VARCHAR(100),
    "ASMCL_Id" VARCHAR(100),
    "ASMS_Id" VARCHAR(100),
    "FromDate" VARCHAR(10),
    "ToDate" VARCHAR(10),
    "AMST_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ASA_Id" BIGINT,
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "AMAY_RollNo" VARCHAR,
    "ASA_FROMDATE" VARCHAR,
    "ASA_Entry_DateTime" VARCHAR,
    "ASA_fROMDATETemp" TIMESTAMP,
    "STUDENTNAME" TEXT,
    "EMPLOYEENAME" TEXT,
    "ISMS_SUBJECTNAME" VARCHAR,
    "TTMP_PeriodName" VARCHAR,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "PresentCount" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SqlDynamic" TEXT;
BEGIN
    "SqlDynamic" := '
SELECT DISTINCT "ASAS"."AMST_Id", "ASA"."ASA_Id" , "ASMAY_Year", "ASMCL_ClassName" , "ASMC_SectionName", "AMST_RegistrationNo","AMST_AdmNo","AMAY_RollNo",
TO_CHAR("ASA_fROMDATE", ''DD/MM/YYYY'') AS "ASA_FROMDATE",
TO_CHAR("ASA_Entry_DateTime", ''DD/MM/YYYY'') AS "ASA_Entry_DateTime", "ASA_fROMDATE" as "ASA_fROMDATETemp",
COALESCE("AMS"."AMST_FirstName",'''')||'' ''||COALESCE("AMS"."AMST_MiddleName",'''')||'' ''||COALESCE("AMS"."AMST_LastName",'''') AS "STUDENTNAME",
COALESCE("HRME"."HRME_EmployeeFirstName",'''')||'' '' ||COALESCE("HRME"."HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME"."HRME_EmployeeLastName",'''') AS "EMPLOYEENAME",
"ISMS_SUBJECTNAME", "TTMP_PeriodName", "ASMCL_Order","ASMC_Order",
CASE WHEN "ASAS"."ASA_Class_Attended"=1 THEN ''Present'' ELSE ''Absent'' END AS "PresentCount"
FROM "Adm_Student_Attendance" "ASA"
INNER JOIN "Adm_Student_Attendance_Students" "ASAS" ON "ASA"."ASA_Id"="ASAS"."ASA_Id"
INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASAP"."ASA_Id"="ASA"."ASA_Id"
INNER JOIN "Adm_Student_Attendance_Subjects" "ASASU" ON "ASASU"."ASA_Id"="ASA"."ASA_Id"
INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id"="ASASU"."ISMS_Id"
INNER JOIN "TT_Master_Period" "TTMP" ON "TTMP"."TTMP_Id"="ASAP"."TTMP_Id"
INNER JOIN "HR_Master_Employee" "HRME" ON "HRME"."HRME_Id"="ASA"."HRME_Id"
INNER JOIN "Adm_School_M_Class" "MC" ON "MC"."ASMCL_Id"="ASA"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" "MS" ON "MS"."ASMS_Id"="ASA"."ASMS_Id"
INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id"="ASAS"."AMST_Id" and "ASYS"."ASMCL_Id"="MC"."ASMCL_Id" and "ASYS"."ASMS_Id"="MS"."ASMS_Id"
INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id"="ASYS"."AMST_Id" and "AMS"."MI_Id"=' || "MI_Id" || '
INNER JOIN "Adm_School_M_Academic_Year" "MY" ON "MY"."ASMAY_Id"="ASA"."ASMAY_Id"
WHERE "ASA"."MI_Id"=' || "MI_Id" || ' AND "ASA"."ASMAY_Id"=' || "ASMAY_Id" || ' AND "ASA"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "ASA"."ASMS_Id" IN (' || "ASMS_Id" || ') 
AND CAST("ASA_FROMDATE" AS DATE) >= ''' || "FromDate" || ''' and CAST("ASA_FROMDATE" AS DATE) <= ''' || "ToDate" || ''' AND "ASA"."ASA_Activeflag"=1
and "ASAS"."AMST_Id" IN (' || "AMST_Id" || ')
ORDER BY "ASMCL_Order","ASMC_Order" , "ASA_fROMDATETemp" , "STUDENTNAME"';

    RETURN QUERY EXECUTE "SqlDynamic";
    
    RETURN;
END;
$$;