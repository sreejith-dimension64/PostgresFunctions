CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Attendance_Total_Attendance_Percentage_MultipleSubject"(
    "asmay_id" TEXT,
    "mi_id" TEXT,
    "amco_id" TEXT,
    "amb_id" TEXT,
    "amse_id" TEXT,
    "acms_id" TEXT,
    "isms_id" TEXT,
    "flag" TEXT,
    "fromdate" TEXT,
    "todate" TEXT,
    "shortage" TEXT,
    "monthid" TEXT,
    "AMCST_Id" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "Query" TEXT;
    "Year" INTEGER := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    "sqlquery" TEXT;
    "cursorValue" TEXT;
    "Cl" TEXT;
    "C2" TEXT;
    "query1" TEXT;
    "cols" TEXT;
    "monthyearsd" TEXT;
    "monthyearsd1" TEXT;
    "cols1" TEXT;
    "SQLAMCSTID" TEXT;
BEGIN

    IF "shortage" != '0' THEN
        "shortage" := "shortage";
    ELSE
        "shortage" := '100';
    END IF;

    IF "AMCST_Id" = '0' THEN
        "SQLAMCSTID" := 'SELECT DISTINCT "AMCST_Id" FROM "CLG"."Adm_Master_College_Student" WHERE "MI_Id"=' || "mi_id" || ' AND "AMCST_SOL"=''S'' AND "AMCST_ActiveFlag"=1';
    ELSE
        "SQLAMCSTID" := 'SELECT DISTINCT "AMCST_Id" FROM "CLG"."Adm_Master_College_Student" WHERE "MI_Id"=' || "mi_id" || ' AND "AMCST_SOL"=''S'' AND "AMCST_ActiveFlag"=1 AND "AMCST_Id"=' || "AMCST_Id" || '';
    END IF;

    IF "flag" = '2' THEN

        "query1" := 'SELECT * FROM (SELECT (COALESCE("stuadm"."AMCST_FirstName", '''') || '' '' || COALESCE("stuadm"."AMCST_MiddleName", '''') || '' '' || COALESCE("stuadm"."AMCST_LastName", '''')) AS student, 
"stuadm"."AMCST_AdmNo" AS admno, "stuadm"."AMCST_RegistrationNo" AS regno, "AMCO_CourseName" AS coursename, "AMB_BranchName" AS branchname, "AMSE_SEMName" AS semestername, "ACMS_SectionName" AS sectionname,
"AMCO_Order", "AMB_Order", "AMSE_SEMOrder", SUM("ACSAS_ClassAttended") AS totalpresentdays, SUM("ACSA_ClassHeld") AS totalworkingdays, 
CAST((CAST(SUM("ACSAS_ClassAttended") AS DECIMAL(10,2)) / NULLIF(SUM("ACSA_ClassHeld"), 0) * 100) AS DECIMAL(10,2)) AS totalpercentage, "stuyear"."ACYST_RollNo" AS rollno
FROM "clg"."Adm_College_Student_Attendance" AS "att"
INNER JOIN "clg"."Adm_College_Student_Attendance_Students" AS "attstu" ON "att"."ACSA_Id" = "attstu"."ACSA_Id"
INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" AS "attstupre" ON "attstupre"."ACSA_Id" = "attstu"."ACSA_Id"
INNER JOIN "clg"."Adm_College_Yearly_Student" AS "stuyear" ON "stuyear"."AMCST_Id" = "attstu"."AMCST_Id"
INNER JOIN "clg"."Adm_Master_College_Student" AS "stuadm" ON "stuadm"."AMCST_Id" = "stuyear"."AMCST_Id"
INNER JOIN "clg"."Adm_Master_Course" AS "co" ON "co"."AMCO_Id" = "att"."AMCO_Id" AND "co"."AMCO_Id" = "stuyear"."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" AS "bo" ON "bo"."AMB_Id" = "att"."AMB_Id" AND "bo"."AMB_Id" = "stuyear"."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" AS "sem" ON "sem"."AMSE_Id" = "att"."AMSE_Id" AND "sem"."AMSE_Id" = "stuyear"."AMSE_Id"
INNER JOIN "clg"."Adm_College_Master_Section" AS "sec" ON "sec"."ACMS_Id" = "att"."ACMS_Id" AND "sec"."ACMS_Id" = "stuyear"."ACMS_Id"
INNER JOIN "IVRM_Master_Subjects" AS "sub" ON "sub"."ISMS_Id" = "att"."ISMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" AS "yer" ON "yer"."ASMAY_Id" = "att"."ASMAY_Id" AND "yer"."ASMAY_Id" = "stuyear"."ASMAY_Id"
WHERE "att"."ASMAY_Id" = ' || "asmay_id" || ' AND "stuyear"."ASMAY_Id" = ' || "asmay_id" || '
AND "att"."AMCO_Id" = ' || "amco_id" || ' AND "stuyear"."AMCO_Id" = ' || "amco_id" || '
AND "att"."AMB_Id" IN (' || "amb_id" || ') AND "stuyear"."AMB_Id" IN (' || "amb_id" || ')
AND "att"."AMSE_Id" = ' || "amse_id" || ' AND "stuyear"."AMSE_Id" = ' || "amse_id" || '
AND "att"."ACMS_Id" = ' || "acms_id" || ' AND "stuyear"."ACMS_Id" = ' || "acms_id" || '
AND "att"."ISMS_Id" IN (' || "isms_id" || ') AND "stuadm"."AMCST_SOL" = ''S''
AND "stuadm"."AMCST_ActiveFlag" = 1 AND "stuyear"."AMCST_Id" IN (' || "SQLAMCSTID" || ')
GROUP BY "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName",
"AMCST_AdmNo", "AMCST_RegistrationNo", "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", "AMCO_Order", "AMB_Order",
"AMSE_SEMOrder", "stuyear"."ACYST_RollNo"
ORDER BY "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", "stuyear"."ACYST_RollNo", student) AS mydata WHERE totalpercentage <= ' || "shortage";

    ELSIF "flag" = '1' THEN

        "query1" := 'SELECT * FROM (SELECT (COALESCE("stuadm"."AMCST_FirstName", '''') || '' '' || COALESCE("stuadm"."AMCST_MiddleName", '''') || '' '' || COALESCE("stuadm"."AMCST_LastName", '''')) AS student, 
"stuadm"."AMCST_AdmNo" AS admno, "stuadm"."AMCST_RegistrationNo" AS regno, "AMCO_CourseName" AS coursename, "AMB_BranchName" AS branchname, "AMSE_SEMName" AS semestername, "ACMS_SectionName" AS sectionname,
"AMCO_Order", "AMB_Order", "AMSE_SEMOrder", SUM("ACSAS_ClassAttended") AS totalpresentdays, SUM("ACSA_ClassHeld") AS totalworkingdays, 
CAST((CAST(SUM("ACSAS_ClassAttended") AS DECIMAL(10,2)) / NULLIF(SUM("ACSA_ClassHeld"), 0) * 100) AS DECIMAL(10,2)) AS totalpercentage, "stuyear"."ACYST_RollNo" AS rollno
FROM "clg"."Adm_College_Student_Attendance" AS "att"
INNER JOIN "clg"."Adm_College_Student_Attendance_Students" AS "attstu" ON "att"."ACSA_Id" = "attstu"."ACSA_Id"
INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" AS "attstupre" ON "attstupre"."ACSA_Id" = "attstu"."ACSA_Id"
INNER JOIN "clg"."Adm_College_Yearly_Student" AS "stuyear" ON "stuyear"."AMCST_Id" = "attstu"."AMCST_Id"
INNER JOIN "clg"."Adm_Master_College_Student" AS "stuadm" ON "stuadm"."AMCST_Id" = "stuyear"."AMCST_Id"
INNER JOIN "clg"."Adm_Master_Course" AS "co" ON "co"."AMCO_Id" = "att"."AMCO_Id" AND "co"."AMCO_Id" = "stuyear"."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" AS "bo" ON "bo"."AMB_Id" = "att"."AMB_Id" AND "bo"."AMB_Id" = "stuyear"."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" AS "sem" ON "sem"."AMSE_Id" = "att"."AMSE_Id" AND "sem"."AMSE_Id" = "stuyear"."AMSE_Id"
INNER JOIN "clg"."Adm_College_Master_Section" AS "sec" ON "sec"."ACMS_Id" = "att"."ACMS_Id" AND "sec"."ACMS_Id" = "stuyear"."ACMS_Id"
INNER JOIN "IVRM_Master_Subjects" AS "sub" ON "sub"."ISMS_Id" = "att"."ISMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" AS "yer" ON "yer"."ASMAY_Id" = "att"."ASMAY_Id" AND "yer"."ASMAY_Id" = "stuyear"."ASMAY_Id"
WHERE "att"."ASMAY_Id" = ' || "asmay_id" || ' AND "stuyear"."ASMAY_Id" = ' || "asmay_id" || '
AND "att"."AMCO_Id" = ' || "amco_id" || ' AND "stuyear"."AMCO_Id" = ' || "amco_id" || '
AND "att"."AMB_Id" IN (' || "amb_id" || ') AND "stuyear"."AMB_Id" IN (' || "amb_id" || ')
AND "att"."AMSE_Id" = ' || "amse_id" || ' AND "stuyear"."AMSE_Id" = ' || "amse_id" || '
AND (' || "acms_id" || ' = 0 OR "att"."ACMS_Id" = ' || "acms_id" || ') AND (' || "acms_id" || ' = 0 OR "stuyear"."ACMS_Id" = ' || "acms_id" || ')
AND "att"."ISMS_Id" IN (' || "isms_id" || ') AND "stuadm"."AMCST_SOL" = ''S''
AND "stuadm"."AMCST_ActiveFlag" = 1 AND "stuyear"."AMCST_Id" IN (' || "SQLAMCSTID" || ')
AND "ACSA_AttendanceDate" BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
GROUP BY "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "stuyear"."ACYST_RollNo",
"AMCST_AdmNo", "AMCST_RegistrationNo", "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", "AMCO_Order", "AMB_Order", "AMSE_SEMOrder"
ORDER BY "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", student) AS mydata WHERE totalpercentage <= ' || "shortage";

    ELSIF "flag" = '0' THEN

        "query1" := 'SELECT * FROM (SELECT (COALESCE("stuadm"."AMCST_FirstName", '''') || '' '' || COALESCE("stuadm"."AMCST_MiddleName", '''') || '' '' || COALESCE("stuadm"."AMCST_LastName", '''')) AS student, 
"stuadm"."AMCST_AdmNo" AS admno, "stuadm"."AMCST_RegistrationNo" AS regno, "AMCO_CourseName" AS coursename, "AMB_BranchName" AS branchname, "AMSE_SEMName" AS semestername, "ACMS_SectionName" AS sectionname,
"AMCO_Order", "AMB_Order", "AMSE_SEMOrder", SUM("ACSAS_ClassAttended") AS totalpresentdays, SUM("ACSA_ClassHeld") AS totalworkingdays, 
CAST((CAST(SUM("ACSAS_ClassAttended") AS DECIMAL(10,2)) / NULLIF(SUM("ACSA_ClassHeld"), 0) * 100) AS DECIMAL(10,2)) AS totalpercentage, "stuyear"."ACYST_RollNo" AS rollno
FROM "clg"."Adm_College_Student_Attendance" AS "att"
INNER JOIN "clg"."Adm_College_Student_Attendance_Students" AS "attstu" ON "att"."ACSA_Id" = "attstu"."ACSA_Id"
INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" AS "attstupre" ON "attstupre"."ACSA_Id" = "attstu"."ACSA_Id"
INNER JOIN "clg"."Adm_College_Yearly_Student" AS "stuyear" ON "stuyear"."AMCST_Id" = "attstu"."AMCST_Id"
INNER JOIN "clg"."Adm_Master_College_Student" AS "stuadm" ON "stuadm"."AMCST_Id" = "stuyear"."AMCST_Id"
INNER JOIN "clg"."Adm_Master_Course" AS "co" ON "co"."AMCO_Id" = "att"."AMCO_Id" AND "co"."AMCO_Id" = "stuyear"."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" AS "bo" ON "bo"."AMB_Id" = "att"."AMB_Id" AND "bo"."AMB_Id" = "stuyear"."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" AS "sem" ON "sem"."AMSE_Id" = "att"."AMSE_Id" AND "sem"."AMSE_Id" = "stuyear"."AMSE_Id"
INNER JOIN "clg"."Adm_College_Master_Section" AS "sec" ON "sec"."ACMS_Id" = "att"."ACMS_Id" AND "sec"."ACMS_Id" = "stuyear"."ACMS_Id"
INNER JOIN "IVRM_Master_Subjects" AS "sub" ON "sub"."ISMS_Id" = "att"."ISMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" AS "yer" ON "yer"."ASMAY_Id" = "att"."ASMAY_Id" AND "yer"."ASMAY_Id" = "stuyear"."ASMAY_Id"
WHERE "att"."ASMAY_Id" = ' || "asmay_id" || ' AND "stuyear"."ASMAY_Id" = ' || "asmay_id" || '
AND "att"."AMCO_Id" = ' || "amco_id" || ' AND "stuyear"."AMCO_Id" = ' || "amco_id" || '
AND "att"."AMB_Id" IN (' || "amb_id" || ') AND "stuyear"."AMB_Id" IN (' || "amb_id" || ')
AND "att"."AMSE_Id" = ' || "amse_id" || ' AND "stuyear"."AMSE_Id" = ' || "amse_id" || '
AND "att"."ACMS_Id" = ' || "acms_id" || ' AND "stuyear"."ACMS_Id" = ' || "acms_id" || '
AND "att"."ISMS_Id" IN (' || "isms_id" || ') AND "stuadm"."AMCST_SOL" = ''S'' AND "stuyear"."AMCST_Id" IN (' || "SQLAMCSTID" || ')
AND "stuadm"."AMCST_ActiveFlag" = 1 AND EXTRACT(MONTH FROM "ACSA_AttendanceDate") = ' || "monthid" || '
GROUP BY "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "stuyear"."ACYST_RollNo", "AMCST_AdmNo", "AMCST_RegistrationNo", "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName",
"ACMS_SectionName", "AMCO_Order", "AMB_Order", "AMSE_SEMOrder"
ORDER BY "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", student) AS mydata WHERE totalpercentage <= ' || "shortage";

    END IF;

    RAISE NOTICE '%', "query1";
    
    RETURN QUERY EXECUTE "query1";

END;
$$;