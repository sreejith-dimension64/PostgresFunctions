CREATE OR REPLACE FUNCTION "dbo"."IVRM_CWSubjectwiseCount"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "FromDate" VARCHAR(10),
    "Todate" VARCHAR(10)
)
RETURNS TABLE(
    "EmpName" TEXT,
    "ISMS_SubjectName" VARCHAR,
    "SubStudentsCount" BIGINT,
    "ISMS_Id" INTEGER,
    "ASMCL_ClassName" VARCHAR,
    "ASMCL_Id" INTEGER,
    "ASMS_Id" INTEGER,
    "ASMC_SectionName" VARCHAR,
    "ICW_Topic" TEXT,
    "ICW_FromDate" TIMESTAMP,
    "ICW_ToDate" TIMESTAMP,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "StudentsCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqldynamic" TEXT;
BEGIN

"sqldynamic" := '
WITH "StudentsCount"
AS
(
SELECT DISTINCT count(DISTINCT "ASYS"."AMST_Id") AS "StudentsCount", "ASYS"."ASMCL_Id", "ASYS"."ASMS_Id", "ASMCL_Order", "ASMC_Order"
FROM "Adm_M_Student" "AMS" 
INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id"="ASYS"."AMST_Id"
INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id"="ASYS"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id"="ASYS"."ASMS_Id"
WHERE "AMS"."MI_Id"=' || "MI_Id" || ' AND "ASYS"."ASMAY_Id"=' || "ASMAY_Id" || ' AND "ASYS"."ASMCL_Id"=' || "ASMCL_Id" || ' AND "ASYS"."ASMS_Id" IN (' || "ASMS_Id" || ')
AND "AMS"."AMST_SOL"=''S'' AND "AMS"."AMST_ActiveFlag"=1 AND "ASYS"."AMAY_ActiveFlag"=1 
GROUP BY "ASYS"."ASMCL_Id", "ASYS"."ASMS_Id", "ASMCL_Order", "ASMC_Order" 
ORDER BY "ASMCL_Order", "ASMC_Order"
LIMIT 100
),
"SubAssigCount"
AS
(
SELECT DISTINCT concat("HRME_EmployeeFirstName","HRME_EmployeeMiddleName","HRME_EmployeeLastName") AS "EmpName","ISMS_SubjectName",
count(DISTINCT "AMST_Id") AS "SubStudentsCount","IMS"."ISMS_Id","scl"."ASMCL_ClassName","scl"."ASMCL_Id","ASS"."ASMS_Id","sec"."ASMC_SectionName","ASS"."ICW_Topic","ASS"."ICW_FromDate",
"ICW_ToDate",
"ASMCL_Order", "ASMC_Order"
FROM "IVRM_Assignment" "ASS"
INNER JOIN "IVRM_ClassWork_Upload" "CU" ON "ASS"."ICW_Id"="CU"."ICW_Id"
INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Id"="ASS"."Login_Id"
INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="SUL"."Emp_Code" 
INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id"="ASS"."ISMS_Id"
INNER JOIN "Adm_School_M_Class" "scl" ON "scl"."ASMCL_Id"="ASS"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" "sec" ON "sec"."ASMS_Id"="ASS"."ASMS_Id"
WHERE "ASS"."MI_Id"=' || "MI_Id" || ' AND "ASS"."ASMAY_Id"=' || "ASMAY_Id" || ' AND "ASS"."ASMCL_Id"=' || "ASMCL_Id" || ' AND "ASS"."ASMS_Id" IN (' || "ASMS_Id" || ') AND
((CAST("ICW_FromDate" AS DATE) BETWEEN ''' || "FromDate" || ''' AND ''' || "Todate" || ''') OR (CAST("ICW_ToDate" AS DATE) BETWEEN ''' || "FromDate" || ''' AND ''' || "Todate" || '''))
AND "HME"."MI_Id"=' || "MI_Id" || ' AND "IMS"."MI_Id"=' || "MI_Id" || '
GROUP BY "ASS"."MI_Id","ASS"."ASMAY_Id","ASS"."ASMCL_Id","ASS"."ASMS_Id",concat("HRME_EmployeeFirstName","HRME_EmployeeMiddleName","HRME_EmployeeLastName"),
"ISMS_SubjectName","IMS"."ISMS_Id","scl"."ASMCL_ClassName","scl"."ASMCL_Id","ICW_ToDate",
"sec"."ASMC_SectionName","ASS"."ICW_Topic","ASS"."ICW_FromDate","ASMCL_Order", "ASMC_Order"
ORDER BY "ASMCL_Order", "ASMC_Order"
LIMIT 100
)
SELECT "b".*, "a"."StudentsCount" 
FROM "StudentsCount" "a" 
INNER JOIN "SubAssigCount" "b" ON "a"."ASMCL_Id"="b"."ASMCL_Id" AND "a"."ASMS_Id"="b"."ASMS_Id" 
ORDER BY "b"."ASMCL_Order", "b"."ASMC_Order"';

RETURN QUERY EXECUTE "sqldynamic";

END;
$$;