CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Attendance_BetweenDates_Report"(
    p_asmay_id TEXT,
    p_mi_id TEXT,
    p_month TEXT,
    p_amco_id TEXT,
    p_amb_id TEXT,
    p_amse_id TEXT,
    p_acms_id TEXT,
    p_isms_id TEXT
)
RETURNS TABLE(
    "AMCST_Id" INTEGER,
    "student" TEXT,
    "admno" TEXT,
    "regno" TEXT,
    "rollno" TEXT,
    "coursename" TEXT,
    "branchname" TEXT,
    "semestername" TEXT,
    "sectionname" TEXT,
    "subjectname" TEXT,
    "ACSA_AttendanceDate" INTEGER,
    "AMCO_Order" INTEGER,
    "AMB_Order" INTEGER,
    "AMSE_SEMOrder" INTEGER,
    "P_ATT" TEXT
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
    v_startDate DATE;
    v_endDate DATE;
    v_year_from_temp INTEGER;
BEGIN
    
    DROP TABLE IF EXISTS "StudentPeriodWiseAttendance_Temp";
    
    CREATE TEMP TABLE "NewTablemonthcollege_new"(
        "id" SERIAL NOT NULL,
        "MonthId" INTEGER,
        "AYear" INTEGER
    );

    SELECT "ASMAY_From_Date" INTO v_startDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_mi_id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT;
    
    SELECT "ASMAY_To_Date" INTO v_endDate 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_mi_id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT;

    WITH RECURSIVE CTE AS (
        SELECT v_startDate::DATE AS "Dates"
        UNION ALL
        SELECT ("Dates" + INTERVAL '1 month')::DATE 
        FROM CTE 
        WHERE ("Dates" + INTERVAL '1 month')::DATE <= v_endDate::DATE
    )
    INSERT INTO "NewTablemonthcollege_new"("MonthId", "AYear")
    SELECT EXTRACT(MONTH FROM "Dates")::INTEGER, EXTRACT(YEAR FROM "Dates")::INTEGER 
    FROM CTE;

    SELECT "AYear" INTO v_year_from_temp 
    FROM "NewTablemonthcollege_new" 
    WHERE "monthid" = p_month::INTEGER;

    v_query1 := 'CREATE TEMP TABLE "StudentPeriodWiseAttendance_Temp" AS 
    SELECT DISTINCT stuyear."AMCST_Id", 
        (COALESCE(stuadm."AMCST_FirstName", '''') || '' '' || COALESCE(stuadm."AMCST_MiddleName", '''') || '' '' || COALESCE(stuadm."AMCST_LastName", '''')) AS student,
        stuadm."AMCST_AdmNo" AS admno, 
        stuadm."AMCST_RegistrationNo" AS regno,
        "ACYST_RollNo" AS rollno, 
        "AMCO_CourseName" AS coursename,
        "AMB_BranchName" AS branchname,
        "AMSE_SEMName" AS semestername,
        "ACMS_SectionName" AS sectionname, 
        "ISMS_SubjectName" AS subjectname,
        EXTRACT(DAY FROM att."ACSA_AttendanceDate"::TIMESTAMP)::INTEGER AS "ACSA_AttendanceDate",
        "AMCO_Order", 
        "AMB_Order", 
        "AMSE_SEMOrder",
        "TTMP_PeriodName" || '':'' || (CASE WHEN "ACSAS_ClassAttended" = TRUE THEN ''P'' WHEN "ACSAS_ClassAttended" = FALSE THEN ''A'' END) AS "P_ATT"
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
    INNER JOIN "TT_Master_Period" per ON per."TTMP_Id" = attstupre."TTMP_Id" AND per."MI_Id" = ' || p_mi_id || '
    WHERE att."ASMAY_Id" = ' || p_asmay_id || ' AND stuyear."ASMAY_Id" = ' || p_asmay_id || '
    AND att."AMCO_Id" = ' || p_amco_id || ' AND stuyear."AMCO_Id" = ' || p_amco_id || '
    AND att."AMB_Id" IN (' || p_amb_id || ') AND stuyear."AMB_Id" IN (' || p_amb_id || ')
    AND att."AMSE_Id" = ' || p_amse_id || ' AND stuyear."AMSE_Id" = ' || p_amse_id || '
    AND att."ACMS_Id" = ' || p_acms_id || ' AND stuyear."ACMS_Id" = ' || p_acms_id || ' AND att."ACSA_ActiveFlag" = TRUE
    AND att."ISMS_Id" = ' || p_isms_id || ' AND stuadm."AMCST_SOL" = ''S'' 
    AND EXTRACT(MONTH FROM att."ACSA_AttendanceDate") = ' || p_month || '
    AND EXTRACT(YEAR FROM att."ACSA_AttendanceDate") = ' || v_year_from_temp::TEXT || '
    AND stuadm."AMCST_ActiveFlag" = TRUE
    ORDER BY student, "AMCO_Order", "AMB_Order", "AMSE_SEMOrder"';

    EXECUTE v_query1;

    RETURN QUERY
    SELECT DISTINCT 
        A."AMCST_Id", 
        A.student,
        A.admno,
        A.regno,
        A.rollno,
        A.coursename,
        A.branchname,
        A.semestername,
        A.sectionname,
        A.subjectname,
        A."ACSA_AttendanceDate",
        A."AMCO_Order",
        A."AMB_Order",
        A."AMSE_SEMOrder",
        STRING_AGG(B."P_ATT", ',' ORDER BY B."P_ATT") AS "P_ATT"
    FROM "StudentPeriodWiseAttendance_Temp" A
    LEFT JOIN "StudentPeriodWiseAttendance_Temp" B 
        ON A."AMCST_Id" = B."AMCST_Id" 
        AND B.admno = A.admno 
        AND A."ACSA_AttendanceDate" = B."ACSA_AttendanceDate"
    GROUP BY A."AMCST_Id", A.student, A.admno, A.regno, A.rollno, A.coursename, 
             A.branchname, A.semestername, A.sectionname, A.subjectname, 
             A."ACSA_AttendanceDate", A."AMCO_Order", A."AMB_Order", A."AMSE_SEMOrder"
    ORDER BY "AMB_Order", student;

    DROP TABLE IF EXISTS "StudentPeriodWiseAttendance_Temp";
    DROP TABLE IF EXISTS "NewTablemonthcollege_new";
    
    RETURN;
END;
$$;