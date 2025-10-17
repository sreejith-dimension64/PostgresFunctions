CREATE OR REPLACE FUNCTION dbo."College_Attendace_Auto_Scheduler_Modify"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ACSA_AttendanceDate TEXT
)
RETURNS TABLE (
    "AMCST_MobileNo" VARCHAR,
    "AMCST_Id" BIGINT,
    "DATE" VARCHAR,
    "NAME" TEXT,
    "SUBJECTS" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASC_DefaultSMS_Flag TEXT;
BEGIN
    SELECT "ASC_DefaultSMS_Flag" INTO v_ASC_DefaultSMS_Flag 
    FROM "Adm_School_Configuration" 
    WHERE "MI_Id" = p_MI_Id;

    IF v_ASC_DefaultSMS_Flag = 'F' THEN
        
        DROP TABLE IF EXISTS temp1modify;

        CREATE TEMP TABLE temp1modify AS
        SELECT 
            (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
             CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
             CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
            'Subject : ' || COALESCE(sub."ISMS_SubjectName", '') || ' -- ' || 'Period : ' || COALESCE(j."TTMP_PeriodName", '') AS subject,
            dd."AMCST_FatherMobleNo" AS "AMCST_MobileNo",
            a."MI_Id",
            a."ACSA_AttendanceDate",
            d."AMCST_Id"
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
        WHERE a."ASMAY_Id" = p_ASMAY_Id AND d."ASMAY_Id" = p_ASMAY_Id 
            AND dd."AMCST_SOL" = 'S' AND dd."AMCST_ActiveFlag" = 1 
            AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_ActiveFlag" = 1
            AND b."ACSAS_ClassAttended" = 0.00 
            AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate::DATE
            AND a."MI_Id" = p_MI_Id AND d."ASMAY_Id" = p_ASMAY_Id
            AND dd."AMCST_FatherMobleNo" IS NOT NULL;

        RETURN QUERY
        SELECT 
            B."AMCST_MobileNo",
            B."AMCST_Id",
            TO_CHAR(B."ACSA_AttendanceDate", 'DD/MM/YYYY') AS "DATE",
            B."AMCST_FirstName" AS "NAME",
            STRING_AGG(A.subject, ', ' ORDER BY A.subject) AS "SUBJECTS"
        FROM temp1modify B
        LEFT JOIN temp1modify A ON A."AMCST_MobileNo" = B."AMCST_MobileNo" 
            AND A."AMCST_FirstName" = B."AMCST_FirstName"
        GROUP BY B."AMCST_MobileNo", B."AMCST_FirstName", B."MI_Id", B."ACSA_AttendanceDate", B."AMCST_Id";

    ELSIF v_ASC_DefaultSMS_Flag = 'M' THEN
        
        DROP TABLE IF EXISTS temp1modify;

        CREATE TEMP TABLE temp1modify AS
        SELECT 
            (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
             CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
             CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
            'Subject : ' || COALESCE(sub."ISMS_SubjectName", '') || ' -- ' || 'Period : ' || COALESCE(j."TTMP_PeriodName", '') AS subject,
            dd."AMCST_MotherMobleNo" AS "AMCST_MobileNo",
            a."MI_Id",
            a."ACSA_AttendanceDate",
            d."AMCST_Id"
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
        WHERE a."ASMAY_Id" = p_ASMAY_Id AND d."ASMAY_Id" = p_ASMAY_Id 
            AND dd."AMCST_SOL" = 'S' AND dd."AMCST_ActiveFlag" = 1 
            AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_ActiveFlag" = 1
            AND b."ACSAS_ClassAttended" = 0.00 
            AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate::DATE
            AND a."MI_Id" = p_MI_Id AND d."ASMAY_Id" = p_ASMAY_Id
            AND dd."AMCST_MotherMobleNo" IS NOT NULL;

        RETURN QUERY
        SELECT 
            B."AMCST_MobileNo",
            B."AMCST_Id",
            TO_CHAR(B."ACSA_AttendanceDate", 'DD/MM/YYYY') AS "DATE",
            B."AMCST_FirstName" AS "NAME",
            STRING_AGG(A.subject, ', ' ORDER BY A.subject) AS "SUBJECTS"
        FROM temp1modify B
        LEFT JOIN temp1modify A ON A."AMCST_MobileNo" = B."AMCST_MobileNo" 
            AND A."AMCST_FirstName" = B."AMCST_FirstName"
        GROUP BY B."AMCST_MobileNo", B."AMCST_FirstName", B."MI_Id", B."ACSA_AttendanceDate", B."AMCST_Id";

    ELSE
        
        DROP TABLE IF EXISTS temp1modify;

        CREATE TEMP TABLE temp1modify AS
        SELECT 
            (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
             CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
             CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
            'Subject : ' || COALESCE(sub."ISMS_SubjectName", '') || ' -- ' || 'Period : ' || COALESCE(j."TTMP_PeriodName", '') AS subject,
            dd."AMCST_MobileNo",
            a."MI_Id",
            a."ACSA_AttendanceDate",
            d."AMCST_Id"
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
        WHERE a."ASMAY_Id" = p_ASMAY_Id AND d."ASMAY_Id" = p_ASMAY_Id 
            AND dd."AMCST_SOL" = 'S' AND dd."AMCST_ActiveFlag" = 1 
            AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_ActiveFlag" = 1
            AND b."ACSAS_ClassAttended" = 0.00 
            AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate::DATE
            AND a."MI_Id" = p_MI_Id AND d."ASMAY_Id" = p_ASMAY_Id
            AND dd."AMCST_MobileNo" IS NOT NULL;

        BEGIN
            RETURN QUERY
            SELECT 
                B."AMCST_MobileNo",
                B."AMCST_Id",
                TO_CHAR(B."ACSA_AttendanceDate", 'DD/MM/YYYY') AS "DATE",
                B."AMCST_FirstName" AS "NAME",
                STRING_AGG(A.subject, ', ' ORDER BY A.subject) AS "SUBJECTS"
            FROM temp1modify B
            LEFT JOIN temp1modify A ON A."AMCST_MobileNo" = B."AMCST_MobileNo" 
                AND A."AMCST_FirstName" = B."AMCST_FirstName"
            GROUP BY B."AMCST_MobileNo", B."AMCST_FirstName", B."MI_Id", B."ACSA_AttendanceDate", B."AMCST_Id";

        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Error occurred: %', SQLERRM;
                RETURN;
        END;

    END IF;

    RETURN;
END;
$$;