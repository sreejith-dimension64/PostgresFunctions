CREATE OR REPLACE FUNCTION dbo."College_Attendace_Auto_Scheduler"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ACSA_AttendanceDate TEXT,
    p_ACMST_Id TEXT
)
RETURNS TABLE(
    "DATE" DATE,
    "STUDENT_NAME" TEXT,
    "PARENTNAME" TEXT,
    "SUBJECTS" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASC_DefaultSMS_Flag TEXT;
BEGIN
    SELECT "ASC_DefaultSMS_Flag" INTO v_ASC_DefaultSMS_Flag 
    FROM "Adm_School_Configuration" 
    WHERE "mi_id" = p_MI_Id;

    IF v_ASC_DefaultSMS_Flag = 'F' THEN
    
        DROP TABLE IF EXISTS temp1;
        
        CREATE TEMP TABLE temp1 AS
        SELECT 
            (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '' THEN '' ELSE "AMCST_FirstName" END ||
            CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '' OR "AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "AMCST_MiddleName" END ||
            CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '' OR "AMCST_LastName" = '0' THEN '' ELSE ' ' || "AMCST_LastName" END) AS "AMCST_FirstName",
            (CASE WHEN "AMCST_FatherName" = '' THEN '' ELSE "AMCST_FatherName" END || 
            CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '' THEN '' ELSE ' ' || "AMCST_FatherSurname" END) AS "AMCST_FatherName",
            'Subject : ' || COALESCE(sub."ISMS_SubjectName", '') || ' -- ' || 'Period : ' || COALESCE(j."TTMP_PeriodName", '') AS subject,
            dd."AMCST_FatherMobleNo" AS "AMCST_MobileNo",
            a."MI_Id",
            a."ACSA_AttendanceDate"
        FROM clg."Adm_College_Student_Attendance" a 
        INNER JOIN clg."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN clg."Adm_College_Student_Attendance_Periodwise" c ON c."ACSA_Id" = a."ACSA_Id"
        INNER JOIN clg."Adm_College_Yearly_Student" d ON d."AMCST_Id" = b."AMCST_Id"
        INNER JOIN clg."Adm_Master_College_Student" dd ON dd."AMCST_Id" = d."AMCST_Id"
        INNER JOIN clg."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id" AND e."AMCO_Id" = d."AMCO_Id"
        INNER JOIN clg."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id" AND f."AMB_Id" = d."AMB_Id"
        INNER JOIN clg."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id" AND g."AMSE_Id" = d."AMSE_Id"
        INNER JOIN clg."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id" AND h."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" i ON i."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "TT_Master_Period" j ON j."TTMP_Id" = c."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" sub ON sub."ISMS_Id" = a."ISMS_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id AND d."ASMAY_Id" = p_ASMAY_Id AND dd."AMCST_SOL" = 'S' 
        AND dd."AMCST_ActiveFlag" = 1 AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_ActiveFlag" = 1
        AND b."ACSAS_ClassAttended" = 0.00 AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate 
        AND a."MI_Id" = p_MI_Id AND d."ASMAY_Id" = p_ASMAY_Id AND b."AMCST_Id" = p_ACMST_Id AND d."AMCST_Id" = p_ACMST_Id;

        RETURN QUERY
        SELECT 
            CAST(B."ACSA_AttendanceDate" AS DATE) AS "DATE",
            B."AMCST_FirstName" AS "STUDENT_NAME",
            B."AMCST_FatherName" AS "PARENTNAME",
            (SELECT STRING_AGG(A.subject, ', ' ORDER BY A.subject)
             FROM temp1 A 
             WHERE COALESCE(A."AMCST_MobileNo", '0') = COALESCE(B."AMCST_MobileNo", '0')
             AND A."AMCST_FirstName" = B."AMCST_FirstName") AS "SUBJECTS"
        FROM temp1 B 
        GROUP BY COALESCE(B."AMCST_MobileNo", '0'), B."AMCST_FirstName", B."MI_Id", B."ACSA_AttendanceDate", B."AMCST_FatherName";

    ELSIF v_ASC_DefaultSMS_Flag = 'M' THEN
    
        DROP TABLE IF EXISTS temp1;
        
        CREATE TEMP TABLE temp1 AS
        SELECT 
            (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '' THEN '' ELSE "AMCST_FirstName" END ||
            CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '' OR "AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "AMCST_MiddleName" END ||
            CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '' OR "AMCST_LastName" = '0' THEN '' ELSE ' ' || "AMCST_LastName" END) AS "AMCST_FirstName",
            (CASE WHEN "AMCST_FatherName" = '' THEN '' ELSE "AMCST_FatherName" END || 
            CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '' THEN '' ELSE ' ' || "AMCST_FatherSurname" END) AS "AMCST_FatherName",
            'Subject : ' || COALESCE(sub."ISMS_SubjectName", '') || ' -- ' || 'Period : ' || COALESCE(j."TTMP_PeriodName", '') AS subject,
            dd."AMCST_MotherMobleNo" AS "AMCST_MobileNo",
            a."MI_Id",
            a."ACSA_AttendanceDate"
        FROM clg."Adm_College_Student_Attendance" a 
        INNER JOIN clg."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN clg."Adm_College_Student_Attendance_Periodwise" c ON c."ACSA_Id" = a."ACSA_Id"
        INNER JOIN clg."Adm_College_Yearly_Student" d ON d."AMCST_Id" = b."AMCST_Id"
        INNER JOIN clg."Adm_Master_College_Student" dd ON dd."AMCST_Id" = d."AMCST_Id"
        INNER JOIN clg."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id" AND e."AMCO_Id" = d."AMCO_Id"
        INNER JOIN clg."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id" AND f."AMB_Id" = d."AMB_Id"
        INNER JOIN clg."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id" AND g."AMSE_Id" = d."AMSE_Id"
        INNER JOIN clg."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id" AND h."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" i ON i."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "TT_Master_Period" j ON j."TTMP_Id" = c."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" sub ON sub."ISMS_Id" = a."ISMS_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id AND d."ASMAY_Id" = p_ASMAY_Id AND dd."AMCST_SOL" = 'S' 
        AND dd."AMCST_ActiveFlag" = 1 AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_ActiveFlag" = 1
        AND b."ACSAS_ClassAttended" = 0.00 AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate 
        AND a."MI_Id" = p_MI_Id AND d."ASMAY_Id" = p_ASMAY_Id AND b."AMCST_Id" = p_ACMST_Id AND d."AMCST_Id" = p_ACMST_Id;

        RETURN QUERY
        SELECT 
            CAST(B."ACSA_AttendanceDate" AS DATE) AS "DATE",
            B."AMCST_FirstName" AS "STUDENT_NAME",
            B."AMCST_FatherName" AS "PARENTNAME",
            (SELECT STRING_AGG(A.subject, ', ' ORDER BY A.subject)
             FROM temp1 A 
             WHERE COALESCE(A."AMCST_MobileNo", '0') = COALESCE(B."AMCST_MobileNo", '0')
             AND A."AMCST_FirstName" = B."AMCST_FirstName") AS "SUBJECTS"
        FROM temp1 B 
        GROUP BY COALESCE(B."AMCST_MobileNo", '0'), B."AMCST_FirstName", B."MI_Id", B."ACSA_AttendanceDate", B."AMCST_FatherName";

    ELSE
    
        DROP TABLE IF EXISTS temp1;
        
        CREATE TEMP TABLE temp1 AS
        SELECT 
            (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '' THEN '' ELSE "AMCST_FirstName" END ||
            CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '' OR "AMCST_MiddleName" = '0' THEN '' ELSE ' ' || "AMCST_MiddleName" END ||
            CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '' OR "AMCST_LastName" = '0' THEN '' ELSE ' ' || "AMCST_LastName" END) AS "AMCST_FirstName",
            (CASE WHEN "AMCST_FatherName" = '' THEN '' ELSE "AMCST_FatherName" END || 
            CASE WHEN "AMCST_FatherSurname" IS NULL OR "AMCST_FatherSurname" = '' THEN '' ELSE ' ' || "AMCST_FatherSurname" END) AS "AMCST_FatherName",
            'Subject : ' || COALESCE(sub."ISMS_SubjectName", '') || ' -- ' || 'Period : ' || COALESCE(j."TTMP_PeriodName", '') AS subject,
            dd."AMCST_MobileNo",
            a."MI_Id",
            a."ACSA_AttendanceDate"
        FROM clg."Adm_College_Student_Attendance" a 
        INNER JOIN clg."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN clg."Adm_College_Student_Attendance_Periodwise" c ON c."ACSA_Id" = a."ACSA_Id"
        INNER JOIN clg."Adm_College_Yearly_Student" d ON d."AMCST_Id" = b."AMCST_Id"
        INNER JOIN clg."Adm_Master_College_Student" dd ON dd."AMCST_Id" = d."AMCST_Id"
        INNER JOIN clg."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id" AND e."AMCO_Id" = d."AMCO_Id"
        INNER JOIN clg."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id" AND f."AMB_Id" = d."AMB_Id"
        INNER JOIN clg."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id" AND g."AMSE_Id" = d."AMSE_Id"
        INNER JOIN clg."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id" AND h."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" i ON i."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "TT_Master_Period" j ON j."TTMP_Id" = c."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" sub ON sub."ISMS_Id" = a."ISMS_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id AND d."ASMAY_Id" = p_ASMAY_Id AND dd."AMCST_SOL" = 'S' 
        AND dd."AMCST_ActiveFlag" = 1 AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_ActiveFlag" = 1
        AND b."ACSAS_ClassAttended" = 0.00 AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate 
        AND a."MI_Id" = p_MI_Id AND d."ASMAY_Id" = p_ASMAY_Id AND b."AMCST_Id" = p_ACMST_Id AND d."AMCST_Id" = p_ACMST_Id;

        BEGIN
            RETURN QUERY
            SELECT 
                CAST(B."ACSA_AttendanceDate" AS DATE) AS "DATE",
                B."AMCST_FirstName" AS "STUDENT_NAME",
                B."AMCST_FatherName" AS "PARENTNAME",
                (SELECT STRING_AGG(A.subject, ', ' ORDER BY A.subject)
                 FROM temp1 A 
                 WHERE COALESCE(A."AMCST_MobileNo", '0') = COALESCE(B."AMCST_MobileNo", '0')
                 AND A."AMCST_FirstName" = B."AMCST_FirstName") AS "SUBJECTS"
            FROM temp1 B 
            GROUP BY COALESCE(B."AMCST_MobileNo", '0'), B."AMCST_FirstName", B."MI_Id", B."ACSA_AttendanceDate", B."AMCST_FatherName";
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Error occurred: %', SQLERRM;
                RETURN;
        END;

    END IF;

    RETURN;
END;
$$;