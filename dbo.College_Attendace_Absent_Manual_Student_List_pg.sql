CREATE OR REPLACE FUNCTION "dbo"."College_Attendace_Absent_Manual_Student_List"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_Todates TEXT
)
RETURNS TABLE(
    "ACSA_AttendanceDate" DATE,
    "AMCST_FirstName" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "AMCST_Id" BIGINT,
    "AMCST_MobileNo" BIGINT,
    "subject" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASC_DefaultSMS_Flag TEXT;
BEGIN

    SELECT "ASC_DefaultSMS_Flag" INTO v_ASC_DefaultSMS_Flag 
    FROM "Adm_School_Configuration" 
    WHERE "mi_id" = p_MI_Id::BIGINT;

    RAISE NOTICE 'ASC_DefaultSMS_Flag: %', v_ASC_DefaultSMS_Flag;

    DROP TABLE IF EXISTS temp11;

    IF v_ASC_DefaultSMS_Flag = 'F' THEN

        RAISE NOTICE 'AAAAA';
        
        CREATE TEMP TABLE temp11 AS
        SELECT b."AMCST_Id",
        (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
        CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
        CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
        ('Subject : ' || sub."ISMS_SubjectName" || ' -- ' || 'Period : ' || j."TTMP_PeriodName") AS subject,
        COALESCE(dd."AMCST_FatherMobleNo", 9999999999) AS "AMCST_MobileNo",
        a."MI_Id",
        a."ACSA_AttendanceDate",
        e."AMCO_CourseName",
        f."AMB_BranchName",
        (g."AMSE_SEMName" || '-' || h."ACMS_SectionName") AS "AMSE_SEMName"
        FROM "clg"."Adm_College_Student_Attendance" a 
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" c ON c."ACSA_Id" = a."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" d ON d."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" dd ON dd."AMCST_Id" = d."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id" AND e."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id" AND f."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id" AND g."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id" AND h."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" i ON i."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "TT_Master_Period" j ON j."TTMP_Id" = c."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" sub ON sub."ISMS_Id" = a."ISMS_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND d."ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND dd."AMCST_SOL" = 'S' 
        AND dd."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 
        AND a."ACSA_ActiveFlag" = 1
        AND b."ACSAS_ClassAttended" = 0.00 
        AND a."MI_Id" = p_MI_Id::BIGINT 
        AND d."ASMAY_Id" = p_ASMAY_Id::BIGINT
        AND d."AMCO_Id" = p_AMCO_Id::BIGINT 
        AND d."AMB_Id" = p_AMB_Id::BIGINT
        AND CAST(a."ACSA_AttendanceDate" AS DATE) = p_Todates::DATE 
        AND a."AMCO_Id" = p_AMCO_Id::BIGINT 
        AND a."AMB_Id" = p_AMB_Id::BIGINT
        AND a."AMSE_Id" = p_AMSE_Id::BIGINT 
        AND a."ACMS_Id" = p_ACMS_Id::BIGINT 
        AND d."AMSE_Id" = p_AMSE_Id::BIGINT 
        AND d."ACMS_Id" = p_ACMS_Id::BIGINT;

        RETURN QUERY
        SELECT CAST(B."ACSA_AttendanceDate" AS DATE) AS "ACSA_AttendanceDate",
        B."AMCST_FirstName" AS "AMCST_FirstName",
        B."AMCO_CourseName",
        B."AMB_BranchName",
        B."AMSE_SEMName",
        B."AMCST_Id",
        COALESCE(B."AMCST_MobileNo", 0) AS "AMCST_MobileNo",
        STRING_AGG(A.subject, ', ') AS subject
        FROM temp11 B
        LEFT JOIN temp11 A ON COALESCE(A."AMCST_MobileNo", 9999999999) = COALESCE(B."AMCST_MobileNo", 9999999999)
        AND A."AMCST_FirstName" = B."AMCST_FirstName"
        GROUP BY CAST(B."ACSA_AttendanceDate" AS DATE), B."AMCST_FirstName", B."AMCO_CourseName", B."AMB_BranchName", B."AMSE_SEMName", B."AMCST_MobileNo", B."AMCST_Id";

    ELSIF v_ASC_DefaultSMS_Flag = 'M' THEN

        DROP TABLE IF EXISTS temp11;

        CREATE TEMP TABLE temp11 AS
        SELECT b."AMCST_Id",
        (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
        CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
        CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
        'Subject : ' || sub."ISMS_SubjectName" || ' -- ' || 'Period : ' || j."TTMP_PeriodName" AS subject,
        COALESCE(dd."AMCST_MotherMobleNo", 0) AS "AMCST_MobileNo",
        a."MI_Id",
        a."ACSA_AttendanceDate",
        e."AMCO_CourseName",
        f."AMB_BranchName",
        (g."AMSE_SEMName" || '-' || h."ACMS_SectionName") AS "AMSE_SEMName"
        FROM "clg"."Adm_College_Student_Attendance" a 
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" c ON c."ACSA_Id" = a."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" d ON d."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" dd ON dd."AMCST_Id" = d."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id" AND e."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id" AND f."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id" AND g."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id" AND h."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" i ON i."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "TT_Master_Period" j ON j."TTMP_Id" = c."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" sub ON sub."ISMS_Id" = a."ISMS_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND d."ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND dd."AMCST_SOL" = 'S' 
        AND dd."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 
        AND a."ACSA_ActiveFlag" = 1
        AND b."ACSAS_ClassAttended" = 0.00 
        AND a."MI_Id" = p_MI_Id::BIGINT 
        AND d."ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND d."AMCO_Id" = p_AMCO_Id::BIGINT 
        AND d."AMB_Id" = p_AMB_Id::BIGINT 
        AND d."AMSE_Id" = p_AMSE_Id::BIGINT 
        AND d."ACMS_Id" = p_ACMS_Id::BIGINT 
        AND a."ACSA_AttendanceDate" = p_Todates::DATE 
        AND a."AMCO_Id" = p_AMCO_Id::BIGINT 
        AND a."AMB_Id" = p_AMB_Id::BIGINT 
        AND a."AMSE_Id" = p_AMSE_Id::BIGINT 
        AND a."ACMS_Id" = p_ACMS_Id::BIGINT;

        RETURN QUERY
        SELECT CAST(B."ACSA_AttendanceDate" AS DATE) AS "ACSA_AttendanceDate",
        B."AMCST_FirstName" AS "AMCST_FirstName",
        B."AMCO_CourseName",
        B."AMB_BranchName",
        B."AMSE_SEMName",
        B."AMCST_Id",
        B."AMCST_MobileNo",
        STRING_AGG(A.subject, ', ') AS subject
        FROM temp11 B
        LEFT JOIN temp11 A ON COALESCE(A."AMCST_MobileNo", 0) = COALESCE(B."AMCST_MobileNo", 0)
        AND A."AMCST_FirstName" = B."AMCST_FirstName"
        GROUP BY CAST(B."ACSA_AttendanceDate" AS DATE), B."AMCST_FirstName", B."AMCO_CourseName", B."AMB_BranchName", B."AMSE_SEMName", B."AMCST_Id", B."AMCST_MobileNo";

    ELSE

        DROP TABLE IF EXISTS temp11;

        CREATE TEMP TABLE temp11 AS
        SELECT b."AMCST_Id",
        (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
        CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
        CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
        'Subject : ' || sub."ISMS_SubjectName" || ' -- ' || 'Period : ' || j."TTMP_PeriodName" AS subject,
        dd."AMCST_MobileNo",
        a."MI_Id",
        a."ACSA_AttendanceDate",
        e."AMCO_CourseName",
        f."AMB_BranchName",
        (g."AMSE_SEMName" || '-' || h."ACMS_SectionName") AS "AMSE_SEMName"
        FROM "clg"."Adm_College_Student_Attendance" a 
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" c ON c."ACSA_Id" = a."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" d ON d."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" dd ON dd."AMCST_Id" = d."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id" AND e."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id" AND f."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = a."AMSE_Id" AND g."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = a."ACMS_Id" AND h."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "IVRM_Master_Subjects" i ON i."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "TT_Master_Period" j ON j."TTMP_Id" = c."TTMP_Id"
        INNER JOIN "IVRM_Master_Subjects" sub ON sub."ISMS_Id" = a."ISMS_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND d."ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND dd."AMCST_SOL" = 'S' 
        AND dd."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 
        AND a."ACSA_ActiveFlag" = 1
        AND b."ACSAS_ClassAttended" = 0.00 
        AND a."MI_Id" = p_MI_Id::BIGINT 
        AND d."ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND d."AMCO_Id" = p_AMCO_Id::BIGINT 
        AND d."AMB_Id" = p_AMB_Id::BIGINT 
        AND d."AMSE_Id" = p_AMSE_Id::BIGINT 
        AND d."ACMS_Id" = p_ACMS_Id::BIGINT 
        AND a."ACSA_AttendanceDate" = p_Todates::DATE 
        AND a."AMCO_Id" = p_AMCO_Id::BIGINT 
        AND a."AMB_Id" = p_AMB_Id::BIGINT 
        AND a."AMSE_Id" = p_AMSE_Id::BIGINT 
        AND a."ACMS_Id" = p_ACMS_Id::BIGINT;

        RETURN QUERY
        SELECT CAST(B."ACSA_AttendanceDate" AS DATE) AS "ACSA_AttendanceDate",
        B."AMCST_FirstName" AS "AMCST_FirstName",
        B."AMCO_CourseName",
        B."AMB_BranchName",
        B."AMSE_SEMName",
        B."AMCST_Id",
        B."AMCST_MobileNo",
        STRING_AGG(A.subject, ', ') AS subject
        FROM temp11 B
        LEFT JOIN temp11 A ON COALESCE(A."AMCST_MobileNo", 0) = COALESCE(B."AMCST_MobileNo", 0)
        AND A."AMCST_FirstName" = B."AMCST_FirstName"
        GROUP BY CAST(B."ACSA_AttendanceDate" AS DATE), B."AMCST_FirstName", B."AMCO_CourseName", B."AMB_BranchName", B."AMSE_SEMName", B."AMCST_Id", B."AMCST_MobileNo";

    END IF;

    DROP TABLE IF EXISTS temp11;

    RETURN;

END;
$$;