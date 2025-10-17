CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Attendance_SubjectWise_Shortage_Attendance_Percentage"(
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
    "shortage" TEXT
)
RETURNS TABLE(
    "student" TEXT,
    "admno" VARCHAR,
    "regno" VARCHAR,
    "coursename" VARCHAR,
    "branchname" VARCHAR,
    "semestername" VARCHAR,
    "sectionname" VARCHAR,
    "subjectname" TEXT,
    "AMCO_Order" INTEGER,
    "AMB_Order" INTEGER,
    "AMSE_SEMOrder" INTEGER,
    "totalpresentdays" BIGINT,
    "totalworkingdays" BIGINT,
    "totalpercentage" NUMERIC,
    "ISMS_SubjectName" VARCHAR
)
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
    "shortage_value" TEXT;
BEGIN

    IF ("shortage" != '0') THEN
        "shortage_value" := "shortage";
    ELSE
        "shortage_value" := '100';
    END IF;

    IF ("flag" = '2') THEN
        "query1" := 'SELECT * FROM (SELECT (COALESCE(stuadm."AMCST_FirstName", '''') || '' '' || COALESCE(stuadm."AMCST_MiddleName", '''') || '' '' || COALESCE(stuadm."AMCST_LastName", '''')) AS student, stuadm."AMCST_AdmNo" AS admno, stuadm."AMCST_RegistrationNo" AS regno, "AMCO_CourseName" AS coursename, "AMB_BranchName" AS branchname, "AMSE_SEMName" AS semestername, "ACMS_SectionName" AS sectionname, ("ISMS_SubjectName" || '':'' || "ISMS_SubjectCode") AS subjectname, "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", SUM("ACSAS_ClassAttended") AS totalpresentdays, SUM("ACSA_ClassHeld") AS totalworkingdays, CAST((CAST(SUM("ACSAS_ClassAttended") AS DECIMAL(10,2)) / SUM("ACSA_ClassHeld") * 100) AS DECIMAL(10,2)) AS totalpercentage, sub."ISMS_SubjectName" 
        FROM "clg"."Adm_College_Student_Attendance" att 
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" attstu ON att."ACSA_Id" = attstu."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" attstupre ON attstupre."ACSA_Id" = attstu."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" stuyear ON stuyear."AMCST_Id" = attstu."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" stuadm ON stuadm."AMCST_Id" = stuyear."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" co ON co."AMCO_Id" = att."AMCO_Id" AND co."AMCO_Id" = stuyear."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" bo ON bo."AMB_Id" = att."AMB_Id" AND bo."AMB_Id" = stuyear."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" sem ON sem."AMSE_Id" = att."AMSE_Id" AND sem."AMSE_Id" = stuyear."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" sec ON sec."ACMS_Id" = att."ACMS_Id" AND sec."ACMS_Id" = stuyear."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" sub ON sub."ISMS_Id" = att."ISMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" yer ON yer."ASMAY_Id" = att."ASMAY_Id" AND yer."ASMAY_Id" = stuyear."ASMAY_Id"
        WHERE att."ASMAY_Id" = ' || "asmay_id" || ' AND stuyear."ASMAY_Id" = ' || "asmay_id" || '
        AND att."AMCO_Id" = ' || "amco_id" || ' AND stuyear."AMCO_Id" = ' || "amco_id" || '
        AND att."AMB_Id" IN (' || "amb_id" || ') AND stuyear."AMB_Id" IN (' || "amb_id" || ')
        AND att."AMSE_Id" = ' || "amse_id" || ' AND stuyear."AMSE_Id" = ' || "amse_id" || '
        AND att."ACMS_Id" = ' || "acms_id" || ' AND stuyear."ACMS_Id" = ' || "acms_id" || '
        AND att."ISMS_Id" = ' || "isms_id" || ' AND stuadm."AMCST_SOL" = ''S''
        AND stuadm."AMCST_ActiveFlag" = 1 
        GROUP BY stuadm."AMCST_FirstName", stuadm."AMCST_MiddleName", stuadm."AMCST_LastName", stuadm."AMCST_AdmNo", stuadm."AMCST_RegistrationNo", "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", "ISMS_SubjectName", "ISMS_SubjectCode", "AMCO_Order", "AMB_Order", "AMSE_SEMOrder"
        ORDER BY "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", student LIMIT 100) mydata WHERE totalpercentage <= ' || "shortage_value";

    ELSIF ("flag" = '1') THEN
        "query1" := 'SELECT * FROM (SELECT (COALESCE(stuadm."AMCST_FirstName", '''') || '' '' || COALESCE(stuadm."AMCST_MiddleName", '''') || '' '' || COALESCE(stuadm."AMCST_LastName", '''')) AS student, stuadm."AMCST_AdmNo" AS admno, stuadm."AMCST_RegistrationNo" AS regno, "AMCO_CourseName" AS coursename, "AMB_BranchName" AS branchname, "AMSE_SEMName" AS semestername, "ACMS_SectionName" AS sectionname, ("ISMS_SubjectName" || '':'' || "ISMS_SubjectCode") AS subjectname, "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", SUM("ACSAS_ClassAttended") AS totalpresentdays, SUM("ACSA_ClassHeld") AS totalworkingdays, CAST((CAST(SUM("ACSAS_ClassAttended") AS DECIMAL(10,2)) / SUM("ACSA_ClassHeld") * 100) AS DECIMAL(10,2)) AS totalpercentage, sub."ISMS_SubjectName" 
        FROM "clg"."Adm_College_Student_Attendance" att 
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" attstu ON att."ACSA_Id" = attstu."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" attstupre ON attstupre."ACSA_Id" = attstu."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" stuyear ON stuyear."AMCST_Id" = attstu."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" stuadm ON stuadm."AMCST_Id" = stuyear."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" co ON co."AMCO_Id" = att."AMCO_Id" AND co."AMCO_Id" = stuyear."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" bo ON bo."AMB_Id" = att."AMB_Id" AND bo."AMB_Id" = stuyear."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" sem ON sem."AMSE_Id" = att."AMSE_Id" AND sem."AMSE_Id" = stuyear."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" sec ON sec."ACMS_Id" = att."ACMS_Id" AND sec."ACMS_Id" = stuyear."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" sub ON sub."ISMS_Id" = att."ISMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" yer ON yer."ASMAY_Id" = att."ASMAY_Id" AND yer."ASMAY_Id" = stuyear."ASMAY_Id"
        WHERE att."ASMAY_Id" = ' || "asmay_id" || ' AND stuyear."ASMAY_Id" = ' || "asmay_id" || '
        AND att."AMCO_Id" = ' || "amco_id" || ' AND stuyear."AMCO_Id" = ' || "amco_id" || '
        AND att."AMB_Id" IN (' || "amb_id" || ') AND stuyear."AMB_Id" IN (' || "amb_id" || ')
        AND att."AMSE_Id" = ' || "amse_id" || ' AND stuyear."AMSE_Id" = ' || "amse_id" || '
        AND att."ACMS_Id" = ' || "acms_id" || ' AND stuyear."ACMS_Id" = ' || "acms_id" || '
        AND att."ISMS_Id" = ' || "isms_id" || ' AND stuadm."AMCST_SOL" = ''S''
        AND stuadm."AMCST_ActiveFlag" = 1 AND att."ACSA_AttendanceDate" BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
        GROUP BY stuadm."AMCST_FirstName", stuadm."AMCST_MiddleName", stuadm."AMCST_LastName", stuadm."AMCST_AdmNo", stuadm."AMCST_RegistrationNo", "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", "ISMS_SubjectName", "ISMS_SubjectCode", "AMCO_Order", "AMB_Order", "AMSE_SEMOrder"
        ORDER BY "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", student LIMIT 100) mydata WHERE totalpercentage <= ' || "shortage_value";

    ELSIF ("flag" = '0') THEN
        "query1" := 'SELECT * FROM (SELECT (COALESCE(stuadm."AMCST_FirstName", '''') || '' '' || COALESCE(stuadm."AMCST_MiddleName", '''') || '' '' || COALESCE(stuadm."AMCST_LastName", '''')) AS student, stuadm."AMCST_AdmNo" AS admno, stuadm."AMCST_RegistrationNo" AS regno, "AMCO_CourseName" AS coursename, "AMB_BranchName" AS branchname, "AMSE_SEMName" AS semestername, "ACMS_SectionName" AS sectionname, ("ISMS_SubjectName" || '':'' || "ISMS_SubjectCode") AS subjectname, "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", SUM("ACSAS_ClassAttended") AS totalpresentdays, SUM("ACSA_ClassHeld") AS totalworkingdays, CAST((CAST(SUM("ACSAS_ClassAttended") AS DECIMAL(10,2)) / SUM("ACSA_ClassHeld") * 100) AS DECIMAL(10,2)) AS totalpercentage, sub."ISMS_SubjectName" 
        FROM "clg"."Adm_College_Student_Attendance" att 
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" attstu ON att."ACSA_Id" = attstu."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" attstupre ON attstupre."ACSA_Id" = attstu."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" stuyear ON stuyear."AMCST_Id" = attstu."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" stuadm ON stuadm."AMCST_Id" = stuyear."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" co ON co."AMCO_Id" = att."AMCO_Id" AND co."AMCO_Id" = stuyear."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" bo ON bo."AMB_Id" = att."AMB_Id" AND bo."AMB_Id" = stuyear."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" sem ON sem."AMSE_Id" = att."AMSE_Id" AND sem."AMSE_Id" = stuyear."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" sec ON sec."ACMS_Id" = att."ACMS_Id" AND sec."ACMS_Id" = stuyear."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" sub ON sub."ISMS_Id" = att."ISMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" yer ON yer."ASMAY_Id" = att."ASMAY_Id" AND yer."ASMAY_Id" = stuyear."ASMAY_Id"
        WHERE att."ASMAY_Id" = ' || "asmay_id" || ' AND stuyear."ASMAY_Id" = ' || "asmay_id" || '
        AND att."AMCO_Id" = ' || "amco_id" || ' AND stuyear."AMCO_Id" = ' || "amco_id" || '
        AND att."AMB_Id" IN (' || "amb_id" || ') AND stuyear."AMB_Id" IN (' || "amb_id" || ')
        AND att."AMSE_Id" = ' || "amse_id" || ' AND stuyear."AMSE_Id" = ' || "amse_id" || '
        AND att."ACMS_Id" = ' || "acms_id" || ' AND stuyear."ACMS_Id" = ' || "acms_id" || '
        AND att."ISMS_Id" = ' || "isms_id" || ' AND stuadm."AMCST_SOL" = ''S''
        AND stuadm."AMCST_ActiveFlag" = 1 AND att."ACSA_AttendanceDate" BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''
        GROUP BY stuadm."AMCST_FirstName", stuadm."AMCST_MiddleName", stuadm."AMCST_LastName", stuadm."AMCST_AdmNo", stuadm."AMCST_RegistrationNo", "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", "ISMS_SubjectName", "ISMS_SubjectCode", "AMCO_Order", "AMB_Order", "AMSE_SEMOrder"
        ORDER BY "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", student LIMIT 100) mydata WHERE totalpercentage <= ' || "shortage_value";
    END IF;

    RETURN QUERY EXECUTE "query1";

END;
$$;