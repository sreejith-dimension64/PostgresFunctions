CREATE OR REPLACE FUNCTION "dbo"."Adm_Attendance_Percentage_Report_Modify"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@fromdate" VARCHAR(10),
    "@todate" VARCHAR(10),
    "@percentage" TEXT,
    "@allorindi" TEXT,
    "@flag" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "AMST_AdmNo" VARCHAR,
    "studentname" TEXT,
    "rollno" INTEGER,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "asmcl_order" INTEGER,
    "asmc_order" INTEGER,
    "AMST_MobileNo" VARCHAR,
    "AMST_emailId" VARCHAR,
    "totalworkingdays" BIGINT,
    "totalpresentdays" BIGINT,
    "percentage" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@SQLQUERY" TEXT;
BEGIN
    
    "@SQLQUERY" := '
    SELECT c."AMST_Id", "AMST_AdmNo", ("AMST_FirstName" || '' '' || "AMST_MiddleName" || '' '' || "AMST_LastName") AS studentname, "AMAY_RollNo" AS rollno, "ASMCL_ClassName" AS classname,
    "ASMC_SectionName" AS sectionname, "asmcl_order", "asmc_order", "AMST_MobileNo", "AMST_emailId",
    SUM("ASA_ClassHeld") AS totalworkingdays, SUM("ASA_Class_Attended") AS totalpresentdays, CAST((SUM("ASA_Class_Attended")*100.0/SUM("ASA_ClassHeld")) AS NUMERIC(18,2)) AS percentage
    FROM "Adm_Student_Attendance" a 
    INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
    INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
    INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = c."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = c."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = c."ASMS_Id"
    WHERE a."MI_Id" = ' || "@MI_Id" || ' AND a."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND c."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND "ASA_Activeflag" = 1 AND "AMST_SOL" = ''S'' AND "AMAY_ActiveFlag" = 1 AND "AMST_ActiveFlag" = 1
    AND ("ASA_FromDate" BETWEEN ''' || "@fromdate" || ''' AND ''' || "@todate" || ''') AND a."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND c."ASMCL_Id" = ' || "@ASMCL_Id" || ' AND a."ASMS_Id" IN (' || "@ASMS_Id" || ')
    AND c."ASMS_Id" IN (' || "@ASMS_Id" || ')
    GROUP BY c."AMST_Id", "AMST_AdmNo", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName", "AMAY_RollNo", "ASMCL_ClassName", "ASMC_SectionName", "asmcl_order", "AMST_MobileNo", "AMST_emailId", "asmc_order"
    HAVING CAST((SUM("ASA_Class_Attended")*100.0/SUM("ASA_ClassHeld")) AS NUMERIC(18,2)) ' || "@flag" || ' ' || "@percentage" || '
    ORDER BY "asmcl_order", "asmc_order", rollno';
    
    RETURN QUERY EXECUTE "@SQLQUERY";
    
END;
$$;