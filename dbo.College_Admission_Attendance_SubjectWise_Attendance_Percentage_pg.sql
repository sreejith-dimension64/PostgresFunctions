CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Attendance_SubjectWise_Attendance_Percentage"(
    p_asmay_id TEXT,
    p_mi_id TEXT,
    p_amco_id TEXT,
    p_amb_id TEXT,
    p_amse_id TEXT,
    p_acms_id TEXT,
    p_isms_id TEXT,
    p_flag TEXT,
    p_fromdate TEXT,
    p_todate TEXT
)
RETURNS TABLE(
    student TEXT,
    admno TEXT,
    regno TEXT,
    coursename TEXT,
    branchname TEXT,
    semestername TEXT,
    sectionname TEXT,
    subjectname TEXT,
    "AMCO_Order" INTEGER,
    "AMB_Order" INTEGER,
    "AMSE_SEMOrder" INTEGER,
    totalpresentdays NUMERIC,
    totalworkingdays NUMERIC,
    totalpercentage NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Query TEXT;
    v_Year INTEGER := EXTRACT(YEAR FROM CURRENT_TIMESTAMP);
    v_sqlquery TEXT;
    v_cursorValue TEXT;
    v_Cl TEXT;
    v_C2 TEXT;
    v_query1 TEXT;
    v_cols TEXT;
    v_monthyearsd TEXT;
    v_monthyearsd1 TEXT;
    v_cols1 TEXT;
BEGIN

    IF (p_flag = '2') THEN
    
        v_query1 := 'SELECT (COALESCE(stuadm."AMCST_FirstName", '''') || '' '' || COALESCE(stuadm."AMCST_MiddleName", '''') || '' '' || COALESCE(stuadm."AMCST_LastName", '''')) as student, 
                    stuadm."AMCST_AdmNo" admno, 
                    stuadm."AMCST_RegistrationNo" regno, 
                    "AMCO_CourseName" coursename, 
                    "AMB_BranchName" branchname, 
                    "AMSE_SEMName" semestername, 
                    "ACMS_SectionName" sectionname, 
                    ("ISMS_SubjectName" || '':'' || "ISMS_SubjectCode") subjectname, 
                    "AMCO_Order", 
                    "AMB_Order", 
                    "AMSE_SEMOrder", 
                    SUM("ACSAS_ClassAttended") as totalpresentdays, 
                    SUM("ACSA_ClassHeld") as totalworkingdays, 
                    CAST((CAST(SUM("ACSAS_ClassAttended") AS DECIMAL(10,2)) / SUM("ACSA_ClassHeld") * 100) AS DECIMAL(10,2)) as totalpercentage 
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
                WHERE att."ASMAY_Id" = ' || p_asmay_id || ' AND stuyear."ASMAY_Id" = ' || p_asmay_id || '
                AND att."AMCO_Id" = ' || p_amco_id || ' AND stuyear."AMCO_Id" = ' || p_amco_id || '
                AND att."AMB_Id" IN (' || p_amb_id || ') AND stuyear."AMB_Id" IN (' || p_amb_id || ')
                AND att."AMSE_Id" = ' || p_amse_id || ' AND stuyear."AMSE_Id" = ' || p_amse_id || '
                AND att."ACMS_Id" = ' || p_acms_id || ' AND stuyear."ACMS_Id" = ' || p_acms_id || '
                AND att."ISMS_Id" = ' || p_isms_id || ' AND stuadm."AMCST_SOL" = ''S''
                AND stuadm."AMCST_ActiveFlag" = 1 AND stuyear."ACYST_ActiveFlag" = 1 
                GROUP BY "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "AMCST_AdmNo", "AMCST_RegistrationNo", 
                         "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", "ISMS_SubjectName", 
                         "ISMS_SubjectCode", "AMCO_Order", "AMB_Order", "AMSE_SEMOrder" 
                ORDER BY "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", student 
                LIMIT 100';
    
    ELSIF p_flag = '1' THEN
    
        v_query1 := 'SELECT (COALESCE(stuadm."AMCST_FirstName", '''') || '' '' || COALESCE(stuadm."AMCST_MiddleName", '''') || '' '' || COALESCE(stuadm."AMCST_LastName", '''')) as student, 
                    stuadm."AMCST_AdmNo" admno, 
                    stuadm."AMCST_RegistrationNo" regno, 
                    "AMCO_CourseName" coursename, 
                    "AMB_BranchName" branchname, 
                    "AMSE_SEMName" semestername, 
                    "ACMS_SectionName" sectionname, 
                    ("ISMS_SubjectName" || '':'' || "ISMS_SubjectCode") subjectname, 
                    "AMCO_Order", 
                    "AMB_Order", 
                    "AMSE_SEMOrder", 
                    SUM("ACSAS_ClassAttended") as totalpresentdays, 
                    SUM("ACSA_ClassHeld") as totalworkingdays, 
                    CAST((CAST(SUM("ACSAS_ClassAttended") AS DECIMAL(10,2)) / SUM("ACSA_ClassHeld") * 100) AS DECIMAL(10,2)) as totalpercentage 
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
                WHERE att."ASMAY_Id" = ' || p_asmay_id || ' AND stuyear."ASMAY_Id" = ' || p_asmay_id || '
                AND att."AMCO_Id" = ' || p_amco_id || ' AND stuyear."AMCO_Id" = ' || p_amco_id || '
                AND att."AMB_Id" IN (' || p_amb_id || ') AND stuyear."AMB_Id" IN (' || p_amb_id || ')
                AND att."AMSE_Id" = ' || p_amse_id || ' AND stuyear."AMSE_Id" = ' || p_amse_id || '
                AND att."ACMS_Id" = ' || p_acms_id || ' AND stuyear."ACMS_Id" = ' || p_acms_id || '
                AND att."ISMS_Id" = ' || p_isms_id || ' AND stuadm."AMCST_SOL" = ''S''
                AND stuadm."AMCST_ActiveFlag" = 1 AND stuyear."ACYST_ActiveFlag" = 1 
                AND "ACSA_AttendanceDate" BETWEEN ''' || p_fromdate || ''' AND ''' || p_todate || '''
                GROUP BY "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "AMCST_AdmNo", "AMCST_RegistrationNo", 
                         "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", "ISMS_SubjectName", 
                         "ISMS_SubjectCode", "AMCO_Order", "AMB_Order", "AMSE_SEMOrder" 
                ORDER BY "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", student 
                LIMIT 100';
    
    ELSIF p_flag = '0' THEN
    
        v_query1 := 'SELECT (COALESCE(stuadm."AMCST_FirstName", '''') || '' '' || COALESCE(stuadm."AMCST_MiddleName", '''') || '' '' || COALESCE(stuadm."AMCST_LastName", '''')) as student, 
                    stuadm."AMCST_AdmNo" admno, 
                    stuadm."AMCST_RegistrationNo" regno, 
                    "AMCO_CourseName" coursename, 
                    "AMB_BranchName" branchname, 
                    "AMSE_SEMName" semestername, 
                    "ACMS_SectionName" sectionname, 
                    ("ISMS_SubjectName" || '':'' || "ISMS_SubjectCode") subjectname, 
                    "AMCO_Order", 
                    "AMB_Order", 
                    "AMSE_SEMOrder", 
                    SUM("ACSAS_ClassAttended") as totalpresentdays, 
                    SUM("ACSA_ClassHeld") as totalworkingdays, 
                    CAST((CAST(SUM("ACSAS_ClassAttended") AS DECIMAL(10,2)) / SUM("ACSA_ClassHeld") * 100) AS DECIMAL(10,2)) as totalpercentage 
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
                WHERE att."ASMAY_Id" = ' || p_asmay_id || ' AND stuyear."ASMAY_Id" = ' || p_asmay_id || '
                AND att."AMCO_Id" = ' || p_amco_id || ' AND stuyear."AMCO_Id" = ' || p_amco_id || '
                AND att."AMB_Id" IN (' || p_amb_id || ') AND stuyear."AMB_Id" IN (' || p_amb_id || ')
                AND att."AMSE_Id" = ' || p_amse_id || ' AND stuyear."AMSE_Id" = ' || p_amse_id || '
                AND att."ACMS_Id" = ' || p_acms_id || ' AND stuyear."ACMS_Id" = ' || p_acms_id || '
                AND att."ISMS_Id" = ' || p_isms_id || ' AND stuadm."AMCST_SOL" = ''S''
                AND stuadm."AMCST_ActiveFlag" = 1 AND stuyear."ACYST_ActiveFlag" = 1 
                AND "ACSA_AttendanceDate" BETWEEN ''' || p_fromdate || ''' AND ''' || p_todate || '''
                GROUP BY "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "AMCST_AdmNo", "AMCST_RegistrationNo", 
                         "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName", "ISMS_SubjectName", 
                         "ISMS_SubjectCode", "AMCO_Order", "AMB_Order", "AMSE_SEMOrder" 
                ORDER BY "AMCO_Order", "AMB_Order", "AMSE_SEMOrder", student 
                LIMIT 100';
    
    END IF;

    RETURN QUERY EXECUTE v_query1;

END;
$$;