CREATE OR REPLACE FUNCTION "dbo"."College_Attendance_Get_Student_List_Saved_Data"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_ACSA_Regular_Extra TEXT,
    p_ACSA_AttendanceDate TEXT,
    p_ISMS_Id TEXT,
    p_TTMP_Id TEXT
)
RETURNS TABLE(
    "ASA_Class_Attended" TEXT,
    "ACSAS_Id" BIGINT,
    "ACSA_Id" BIGINT,
    "AMCST_Id" BIGINT,
    "AMCST_FirstName" TEXT,
    "AMCST_AdmNo" TEXT,
    "ACYST_RollNo" BIGINT,
    "AMCST_Sex" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "TTMP_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order TEXT;
    v_ordderby TEXT;
BEGIN
    SELECT "ASC_Att_Default_OrderFlag" INTO v_order 
    FROM "Adm_School_Configuration" 
    WHERE "mi_id" = p_MI_Id;

    IF (v_order = '1') THEN
        RETURN QUERY
        SELECT b."ACSAS_ClassAttended"::TEXT as "ASA_Class_Attended", 
               b."ACSAS_Id" as "ACSAS_Id", 
               a."ACSA_Id" as "ACSA_Id",
               d."AMCST_Id" as "AMCST_Id",
               (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
                CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
                CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
               dd."AMCST_AdmNo" as "AMCST_AdmNo", 
               d."ACYST_RollNo" as "ACYST_RollNo", 
               dd."AMCST_Sex", 
               dd."AMCST_RegistrationNo" as "AMCST_RegistrationNo",
               c."TTMP_Id"
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
        WHERE a."AMCO_Id" = p_AMCO_Id AND a."AMB_Id" = p_AMB_Id AND a."AMSE_Id" = p_AMSE_Id AND a."ACMS_Id" = p_ACMS_Id
        AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate AND a."MI_Id" = p_MI_Id AND a."ISMS_Id" = p_ISMS_Id 
        AND c."TTMP_Id" = p_TTMP_Id AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id 
        AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id AND a."ASMAY_Id" = p_ASMAY_Id 
        AND d."ASMAY_Id" = p_ASMAY_Id AND dd."AMCST_SOL" = 'S' AND dd."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_Regular_Extra" = p_ACSA_Regular_Extra AND a."ACSA_ActiveFlag" = 1
        ORDER BY dd."AMCST_Sex";

    ELSIF (v_order = '2') THEN
        RETURN QUERY
        SELECT b."ACSAS_ClassAttended"::TEXT as "ASA_Class_Attended", 
               b."ACSAS_Id" as "ACSAS_Id", 
               a."ACSA_Id" as "ACSA_Id",
               d."AMCST_Id" as "AMCST_Id",
               (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
                CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
                CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
               dd."AMCST_AdmNo" as "AMCST_AdmNo", 
               d."ACYST_RollNo" as "ACYST_RollNo", 
               dd."AMCST_Sex", 
               dd."AMCST_RegistrationNo" as "AMCST_RegistrationNo",
               c."TTMP_Id"
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
        WHERE a."AMCO_Id" = p_AMCO_Id AND a."AMB_Id" = p_AMB_Id AND a."AMSE_Id" = p_AMSE_Id AND a."ACMS_Id" = p_ACMS_Id
        AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate AND a."MI_Id" = p_MI_Id AND a."ISMS_Id" = p_ISMS_Id 
        AND c."TTMP_Id" = p_TTMP_Id AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id 
        AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id AND a."ASMAY_Id" = p_ASMAY_Id 
        AND d."ASMAY_Id" = p_ASMAY_Id AND dd."AMCST_SOL" = 'S' AND dd."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_Regular_Extra" = p_ACSA_Regular_Extra AND a."ACSA_ActiveFlag" = 1
        ORDER BY dd."AMCST_Sex" DESC;

    ELSIF (v_order = '3') THEN
        RETURN QUERY
        SELECT b."ACSAS_ClassAttended"::TEXT as "ASA_Class_Attended", 
               b."ACSAS_Id" as "ACSAS_Id", 
               a."ACSA_Id" as "ACSA_Id",
               d."AMCST_Id" as "AMCST_Id",
               (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
                CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
                CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
               dd."AMCST_AdmNo" as "AMCST_AdmNo", 
               d."ACYST_RollNo" as "ACYST_RollNo", 
               dd."AMCST_Sex", 
               dd."AMCST_RegistrationNo" as "AMCST_RegistrationNo",
               c."TTMP_Id"
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
        WHERE a."AMCO_Id" = p_AMCO_Id AND a."AMB_Id" = p_AMB_Id AND a."AMSE_Id" = p_AMSE_Id AND a."ACMS_Id" = p_ACMS_Id
        AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate AND a."MI_Id" = p_MI_Id AND a."ISMS_Id" = p_ISMS_Id 
        AND c."TTMP_Id" = p_TTMP_Id AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id 
        AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id AND a."ASMAY_Id" = p_ASMAY_Id 
        AND d."ASMAY_Id" = p_ASMAY_Id AND dd."AMCST_SOL" = 'S' AND dd."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_Regular_Extra" = p_ACSA_Regular_Extra AND a."ACSA_ActiveFlag" = 1
        ORDER BY d."ACYST_RollNo";

    ELSIF (v_order = '4') THEN
        RETURN QUERY
        SELECT b."ACSAS_ClassAttended"::TEXT as "ASA_Class_Attended", 
               b."ACSAS_Id" as "ACSAS_Id", 
               a."ACSA_Id" as "ACSA_Id",
               d."AMCST_Id" as "AMCST_Id",
               (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
                CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
                CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
               dd."AMCST_AdmNo" as "AMCST_AdmNo", 
               d."ACYST_RollNo" as "ACYST_RollNo", 
               dd."AMCST_Sex", 
               dd."AMCST_RegistrationNo" as "AMCST_RegistrationNo",
               c."TTMP_Id"
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
        WHERE a."AMCO_Id" = p_AMCO_Id AND a."AMB_Id" = p_AMB_Id AND a."AMSE_Id" = p_AMSE_Id AND a."ACMS_Id" = p_ACMS_Id
        AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate AND a."MI_Id" = p_MI_Id AND a."ISMS_Id" = p_ISMS_Id 
        AND c."TTMP_Id" = p_TTMP_Id AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id 
        AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id AND a."ASMAY_Id" = p_ASMAY_Id 
        AND d."ASMAY_Id" = p_ASMAY_Id AND dd."AMCST_SOL" = 'S' AND dd."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_Regular_Extra" = p_ACSA_Regular_Extra AND a."ACSA_ActiveFlag" = 1
        ORDER BY "AMCST_FirstName";

    ELSIF (v_order = '5') THEN
        RETURN QUERY
        SELECT b."ACSAS_ClassAttended"::TEXT as "ASA_Class_Attended", 
               b."ACSAS_Id" as "ACSAS_Id", 
               a."ACSA_Id" as "ACSA_Id",
               d."AMCST_Id" as "AMCST_Id",
               (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
                CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
                CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
               dd."AMCST_AdmNo" as "AMCST_AdmNo", 
               d."ACYST_RollNo" as "ACYST_RollNo", 
               dd."AMCST_Sex", 
               dd."AMCST_RegistrationNo" as "AMCST_RegistrationNo",
               c."TTMP_Id"
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
        WHERE a."AMCO_Id" = p_AMCO_Id AND a."AMB_Id" = p_AMB_Id AND a."AMSE_Id" = p_AMSE_Id AND a."ACMS_Id" = p_ACMS_Id
        AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate AND a."MI_Id" = p_MI_Id AND a."ISMS_Id" = p_ISMS_Id 
        AND c."TTMP_Id" = p_TTMP_Id AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id 
        AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id AND a."ASMAY_Id" = p_ASMAY_Id 
        AND d."ASMAY_Id" = p_ASMAY_Id AND dd."AMCST_SOL" = 'S' AND dd."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_Regular_Extra" = p_ACSA_Regular_Extra AND a."ACSA_ActiveFlag" = 1
        ORDER BY "AMCST_FirstName" DESC;

    ELSIF (v_order = '6') THEN
        RETURN QUERY
        SELECT b."ACSAS_ClassAttended"::TEXT as "ASA_Class_Attended", 
               b."ACSAS_Id" as "ACSAS_Id", 
               a."ACSA_Id" as "ACSA_Id",
               d."AMCST_Id" as "AMCST_Id",
               (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
                CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
                CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
               dd."AMCST_AdmNo" as "AMCST_AdmNo", 
               d."ACYST_RollNo" as "ACYST_RollNo", 
               dd."AMCST_Sex", 
               dd."AMCST_RegistrationNo" as "AMCST_RegistrationNo",
               c."TTMP_Id"
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
        WHERE a."AMCO_Id" = p_AMCO_Id AND a."AMB_Id" = p_AMB_Id AND a."AMSE_Id" = p_AMSE_Id AND a."ACMS_Id" = p_ACMS_Id
        AND a."ACSA_AttendanceDate" = p_ACSA_AttendanceDate AND a."MI_Id" = p_MI_Id AND a."ISMS_Id" = p_ISMS_Id 
        AND c."TTMP_Id" = p_TTMP_Id AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id 
        AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id AND a."ASMAY_Id" = p_ASMAY_Id 
        AND d."ASMAY_Id" = p_ASMAY_Id AND dd."AMCST_SOL" = 'S' AND dd."AMCST_ActiveFlag" = 1 
        AND d."ACYST_ActiveFlag" = 1 AND a."ACSA_Regular_Extra" = p_ACSA_Regular_Extra AND a."ACSA_ActiveFlag" = 1
        ORDER BY dd."AMCST_RegistrationNo";

    ELSIF (v_order = '7') THEN
        RETURN QUERY
        SELECT b."ACSAS_ClassAttended"::TEXT as "ASA_Class_Attended", 
               b."ACSAS_Id" as "ACSAS_Id", 
               a."ACSA_Id" as "ACSA_Id",
               d."AMCST_Id" as "AMCST_Id",
               (CASE WHEN dd."AMCST_FirstName" IS NULL OR dd."AMCST_FirstName" = '' THEN '' ELSE dd."AMCST_FirstName" END ||
                CASE WHEN dd."AMCST_MiddleName" IS NULL OR dd."AMCST_MiddleName" = '' OR dd."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || dd."AMCST_MiddleName" END ||
                CASE WHEN dd."AMCST_LastName" IS NULL OR dd."AMCST_LastName" = '' OR dd."AMCST_LastName" = '0' THEN '' ELSE ' ' || dd."AMCST_LastName" END) AS "AMCST_FirstName",
               dd."AMCST_AdmNo" as "AMCST_AdmNo", 
               d."ACYST_RollNo" as "ACYST_RollNo", 
               dd."AMCST_Sex", 
               dd."AMCST_RegistrationNo" as "AMCST_RegistrationNo",
               c."TTMP_Id"
        FROM "clg"."Adm_College_Student_Attendance" a 
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN "clg"."Adm