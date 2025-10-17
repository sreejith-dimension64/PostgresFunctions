CREATE OR REPLACE FUNCTION "dbo"."College_Attendance_Get_Student_List_Batchwise_Saved_Data"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_ACAB_Id TEXT,
    p_ISMS_Id TEXT,
    p_TTMP_Id TEXT,
    p_confromdate TEXT,
    p_regularexta TEXT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "AMCST_FirstName" TEXT,
    "AMCST_AdmNo" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "ACYST_RollNo" TEXT,
    "AMCST_Sex" TEXT,
    "ACSAS_Id" BIGINT,
    "ACSA_Id" BIGINT,
    "TTMP_Id" BIGINT,
    "ASA_Class_Attended" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order INTEGER;
    v_ordderby TEXT;
BEGIN
    SELECT "ASC_Att_Default_OrderFlag" INTO v_order 
    FROM "Adm_School_Configuration" 
    WHERE "mi_id" = p_MI_Id;

    IF (v_order = 1) THEN
        RETURN QUERY
        SELECT DISTINCT a."amcst_id" AS "AMCST_Id",
            (COALESCE(a."amcst_firstname", '') || ' ' || COALESCE(a."amcst_middlename", '') || ' ' || COALESCE(a."amcst_lastname", '')) AS "AMCST_FirstName",
            a."AMCST_AdmNo" AS "AMCST_AdmNo",
            a."AMCST_RegistrationNo" AS "AMCST_RegistrationNo",
            b."ACYST_RollNo" AS "ACYST_RollNo",
            a."AMCST_Sex",
            m."ACSAS_Id",
            k."ACSA_Id",
            l."TTMP_Id" AS "TTMP_Id",
            m."ACSAS_ClassAttended" AS "ASA_Class_Attended"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance" k ON k."AMCO_Id" = b."AMCO_Id" AND k."AMB_Id" = b."AMB_Id" AND k."AMSE_Id" = b."AMSE_Id" AND k."ACMS_Id" = b."ACMS_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" l ON l."ACSA_Id" = k."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" m ON m."ACSA_Id" = k."ACSA_Id" AND m."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subject_Students" c ON c."AMCST_Id" = b."AMCST_Id" AND m."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subjects" d ON d."ACABS_Id" = c."ACABS_Id"
        INNER JOIN "clg"."Adm_College_Attendance_Batch" e ON e."ACAB_Id" = d."ACAB_Id"
        INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = b."AMCO_Id" AND f."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" g ON g."AMB_Id" = b."AMB_Id" AND g."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id" AND h."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" i ON i."ACMS_Id" = b."ACMS_Id" AND i."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" j ON j."ASMAY_Id" = b."ASMAY_Id" AND j."ASMAY_Id" = d."ASMAY_Id"
        WHERE a."MI_Id" = p_MI_Id AND b."ASMAY_Id" = p_ASMAY_Id AND b."AMCO_Id" = p_AMCO_Id AND b."AMB_Id" = p_AMB_Id 
            AND b."AMSE_Id" = p_AMSE_Id AND b."ACMS_Id" = p_ACMS_Id AND k."ASMAY_Id" = p_ASMAY_Id AND k."AMCO_Id" = p_AMCO_Id 
            AND k."AMB_Id" = p_AMB_Id AND k."AMSE_Id" = p_AMSE_Id AND k."ACMS_Id" = p_ACMS_Id AND d."ASMAY_Id" = p_ASMAY_Id 
            AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id 
            AND d."ISMS_Id" = p_ISMS_Id AND d."ACAB_Id" = p_ACAB_Id AND k."ISMS_Id" = p_ISMS_Id AND l."TTMP_Id" = p_TTMP_Id
            AND k."ACSA_AttendanceDate" = p_confromdate AND k."ACSA_Regular_Extra" = p_regularexta AND k."ACSA_ActiveFlag" = TRUE
        ORDER BY a."AMCST_Sex";

    ELSIF (v_order = 2) THEN
        RETURN QUERY
        SELECT DISTINCT a."amcst_id" AS "AMCST_Id",
            (COALESCE(a."amcst_firstname", '') || ' ' || COALESCE(a."amcst_middlename", '') || ' ' || COALESCE(a."amcst_lastname", '')) AS "AMCST_FirstName",
            a."AMCST_AdmNo" AS "AMCST_AdmNo",
            a."AMCST_RegistrationNo" AS "AMCST_RegistrationNo",
            b."ACYST_RollNo" AS "ACYST_RollNo",
            a."AMCST_Sex",
            m."ACSAS_Id",
            k."ACSA_Id",
            l."TTMP_Id" AS "TTMP_Id",
            m."ACSAS_ClassAttended" AS "ASA_Class_Attended"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance" k ON k."AMCO_Id" = b."AMCO_Id" AND k."AMB_Id" = b."AMB_Id" AND k."AMSE_Id" = b."AMSE_Id" AND k."ACMS_Id" = b."ACMS_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" l ON l."ACSA_Id" = k."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" m ON m."ACSA_Id" = k."ACSA_Id" AND m."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subject_Students" c ON c."AMCST_Id" = b."AMCST_Id" AND m."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subjects" d ON d."ACABS_Id" = c."ACABS_Id"
        INNER JOIN "clg"."Adm_College_Attendance_Batch" e ON e."ACAB_Id" = d."ACAB_Id"
        INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = b."AMCO_Id" AND f."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" g ON g."AMB_Id" = b."AMB_Id" AND g."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id" AND h."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" i ON i."ACMS_Id" = b."ACMS_Id" AND i."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" j ON j."ASMAY_Id" = b."ASMAY_Id" AND j."ASMAY_Id" = d."ASMAY_Id"
        WHERE a."MI_Id" = p_MI_Id AND b."ASMAY_Id" = p_ASMAY_Id AND b."AMCO_Id" = p_AMCO_Id AND b."AMB_Id" = p_AMB_Id 
            AND b."AMSE_Id" = p_AMSE_Id AND b."ACMS_Id" = p_ACMS_Id AND k."ASMAY_Id" = p_ASMAY_Id AND k."AMCO_Id" = p_AMCO_Id 
            AND k."AMB_Id" = p_AMB_Id AND k."AMSE_Id" = p_AMSE_Id AND k."ACMS_Id" = p_ACMS_Id AND d."ASMAY_Id" = p_ASMAY_Id 
            AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id 
            AND d."ISMS_Id" = p_ISMS_Id AND d."ACAB_Id" = p_ACAB_Id AND k."ISMS_Id" = p_ISMS_Id AND l."TTMP_Id" = p_TTMP_Id
            AND k."ACSA_AttendanceDate" = p_confromdate AND k."ACSA_Regular_Extra" = p_regularexta AND k."ACSA_ActiveFlag" = TRUE
        ORDER BY a."AMCST_Sex" DESC;

    ELSIF (v_order = 3) THEN
        RETURN QUERY
        SELECT DISTINCT a."amcst_id" AS "AMCST_Id",
            (COALESCE(a."amcst_firstname", '') || ' ' || COALESCE(a."amcst_middlename", '') || ' ' || COALESCE(a."amcst_lastname", '')) AS "AMCST_FirstName",
            a."AMCST_AdmNo" AS "AMCST_AdmNo",
            a."AMCST_RegistrationNo" AS "AMCST_RegistrationNo",
            b."ACYST_RollNo" AS "ACYST_RollNo",
            a."AMCST_Sex",
            m."ACSAS_Id",
            k."ACSA_Id",
            l."TTMP_Id" AS "TTMP_Id",
            m."ACSAS_ClassAttended" AS "ASA_Class_Attended"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance" k ON k."AMCO_Id" = b."AMCO_Id" AND k."AMB_Id" = b."AMB_Id" AND k."AMSE_Id" = b."AMSE_Id" AND k."ACMS_Id" = b."ACMS_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" l ON l."ACSA_Id" = k."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" m ON m."ACSA_Id" = k."ACSA_Id" AND m."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subject_Students" c ON c."AMCST_Id" = b."AMCST_Id" AND m."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subjects" d ON d."ACABS_Id" = c."ACABS_Id"
        INNER JOIN "clg"."Adm_College_Attendance_Batch" e ON e."ACAB_Id" = d."ACAB_Id"
        INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = b."AMCO_Id" AND f."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" g ON g."AMB_Id" = b."AMB_Id" AND g."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id" AND h."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" i ON i."ACMS_Id" = b."ACMS_Id" AND i."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" j ON j."ASMAY_Id" = b."ASMAY_Id" AND j."ASMAY_Id" = d."ASMAY_Id"
        WHERE a."MI_Id" = p_MI_Id AND b."ASMAY_Id" = p_ASMAY_Id AND b."AMCO_Id" = p_AMCO_Id AND b."AMB_Id" = p_AMB_Id 
            AND b."AMSE_Id" = p_AMSE_Id AND b."ACMS_Id" = p_ACMS_Id AND k."ASMAY_Id" = p_ASMAY_Id AND k."AMCO_Id" = p_AMCO_Id 
            AND k."AMB_Id" = p_AMB_Id AND k."AMSE_Id" = p_AMSE_Id AND k."ACMS_Id" = p_ACMS_Id AND d."ASMAY_Id" = p_ASMAY_Id 
            AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id 
            AND d."ISMS_Id" = p_ISMS_Id AND d."ACAB_Id" = p_ACAB_Id AND k."ISMS_Id" = p_ISMS_Id AND l."TTMP_Id" = p_TTMP_Id
            AND k."ACSA_AttendanceDate" = p_confromdate AND k."ACSA_Regular_Extra" = p_regularexta AND k."ACSA_ActiveFlag" = TRUE
        ORDER BY b."ACYST_RollNo";

    ELSIF (v_order = 4) THEN
        RETURN QUERY
        SELECT DISTINCT a."amcst_id" AS "AMCST_Id",
            (COALESCE(a."amcst_firstname", '') || ' ' || COALESCE(a."amcst_middlename", '') || ' ' || COALESCE(a."amcst_lastname", '')) AS "AMCST_FirstName",
            a."AMCST_AdmNo" AS "AMCST_AdmNo",
            a."AMCST_RegistrationNo" AS "AMCST_RegistrationNo",
            b."ACYST_RollNo" AS "ACYST_RollNo",
            a."AMCST_Sex",
            m."ACSAS_Id",
            k."ACSA_Id",
            l."TTMP_Id" AS "TTMP_Id",
            m."ACSAS_ClassAttended" AS "ASA_Class_Attended"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance" k ON k."AMCO_Id" = b."AMCO_Id" AND k."AMB_Id" = b."AMB_Id" AND k."AMSE_Id" = b."AMSE_Id" AND k."ACMS_Id" = b."ACMS_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" l ON l."ACSA_Id" = k."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" m ON m."ACSA_Id" = k."ACSA_Id" AND m."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subject_Students" c ON c."AMCST_Id" = b."AMCST_Id" AND m."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subjects" d ON d."ACABS_Id" = c."ACABS_Id"
        INNER JOIN "clg"."Adm_College_Attendance_Batch" e ON e."ACAB_Id" = d."ACAB_Id"
        INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = b."AMCO_Id" AND f."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" g ON g."AMB_Id" = b."AMB_Id" AND g."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id" AND h."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" i ON i."ACMS_Id" = b."ACMS_Id" AND i."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" j ON j."ASMAY_Id" = b."ASMAY_Id" AND j."ASMAY_Id" = d."ASMAY_Id"
        WHERE a."MI_Id" = p_MI_Id AND b."ASMAY_Id" = p_ASMAY_Id AND b."AMCO_Id" = p_AMCO_Id AND b."AMB_Id" = p_AMB_Id 
            AND b."AMSE_Id" = p_AMSE_Id AND b."ACMS_Id" = p_ACMS_Id AND k."ASMAY_Id" = p_ASMAY_Id AND k."AMCO_Id" = p_AMCO_Id 
            AND k."AMB_Id" = p_AMB_Id AND k."AMSE_Id" = p_AMSE_Id AND k."ACMS_Id" = p_ACMS_Id AND d."ASMAY_Id" = p_ASMAY_Id 
            AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id 
            AND d."ISMS_Id" = p_ISMS_Id AND d."ACAB_Id" = p_ACAB_Id AND k."ISMS_Id" = p_ISMS_Id AND l."TTMP_Id" = p_TTMP_Id
            AND k."ACSA_AttendanceDate" = p_confromdate AND k."ACSA_Regular_Extra" = p_regularexta AND k."ACSA_ActiveFlag" = TRUE
        ORDER BY "AMCST_FirstName";

    ELSIF (v_order = 5) THEN
        RETURN QUERY
        SELECT DISTINCT a."amcst_id" AS "AMCST_Id",
            (COALESCE(a."amcst_firstname", '') || ' ' || COALESCE(a."amcst_middlename", '') || ' ' || COALESCE(a."amcst_lastname", '')) AS "AMCST_FirstName",
            a."AMCST_AdmNo" AS "AMCST_AdmNo",
            a."AMCST_RegistrationNo" AS "AMCST_RegistrationNo",
            b."ACYST_RollNo" AS "ACYST_RollNo",
            a."AMCST_Sex",
            m."ACSAS_Id",
            k."ACSA_Id",
            l."TTMP_Id" AS "TTMP_Id",
            m."ACSAS_ClassAttended" AS "ASA_Class_Attended"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance" k ON k."AMCO_Id" = b."AMCO_Id" AND k."AMB_Id" = b."AMB_Id" AND k."AMSE_Id" = b."AMSE_Id" AND k."ACMS_Id" = b."ACMS_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" l ON l."ACSA_Id" = k."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" m ON m."ACSA_Id" = k."ACSA_Id" AND m."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subject_Students" c ON c."AMCST_Id" = b."AMCST_Id" AND m."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subjects" d ON d."ACABS_Id" = c."ACABS_Id"
        INNER JOIN "clg"."Adm_College_Attendance_Batch" e ON e."ACAB_Id" = d."ACAB_Id"
        INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = b."AMCO_Id" AND f."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" g ON g."AMB_Id" = b."AMB_Id" AND g."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id" AND h."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" i ON i."ACMS_Id" = b."ACMS_Id" AND i."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" j ON j."ASMAY_Id" = b."ASMAY_Id" AND j."ASMAY_Id" = d."ASMAY_Id"
        WHERE a."MI_Id" = p_MI_Id AND b."ASMAY_Id" = p_ASMAY_Id AND b."AMCO_Id" = p_AMCO_Id AND b."AMB_Id" = p_AMB_Id 
            AND b."AMSE_Id" = p_AMSE_Id AND b."ACMS_Id" = p_ACMS_Id AND k."ASMAY_Id" = p_ASMAY_Id AND k."AMCO_Id" = p_AMCO_Id 
            AND k."AMB_Id" = p_AMB_Id AND k."AMSE_Id" = p_AMSE_Id AND k."ACMS_Id" = p_ACMS_Id AND d."ASMAY_Id" = p_ASMAY_Id 
            AND d."AMCO_Id" = p_AMCO_Id AND d."AMB_Id" = p_AMB_Id AND d."AMSE_Id" = p_AMSE_Id AND d."ACMS_Id" = p_ACMS_Id 
            AND d."ISMS_Id" = p_ISMS_Id AND d."ACAB_Id" = p_ACAB_Id AND k."ISMS_Id" = p_ISMS_Id AND l."TTMP_Id" = p_TTMP_Id
            AND k."ACSA_AttendanceDate" = p_confromdate AND k."ACSA_Regular_Extra" = p_regularexta AND k."ACSA_ActiveFlag" = TRUE
        ORDER BY "AMCST_FirstName" DESC;

    ELSIF (v_order = 6) THEN
        RETURN QUERY
        SELECT DISTINCT a."amcst_id" AS "AMCST_Id",
            (COALESCE(a."amcst_firstname", '') || ' ' || COALESCE(a."amcst_middlename", '') || ' ' || COALESCE(a."amcst_lastname", '')) AS "AMCST_FirstName",
            a."AMCST_AdmNo" AS "AMCST_AdmNo",
            a."AMCST_RegistrationNo" AS "AMCST_RegistrationNo",
            b."ACYST_RollNo" AS "ACYST_RollNo",
            a."AMCST_Sex",
            m."ACSAS_Id",
            k."ACSA_Id",
            l."TTMP_Id" AS "TTMP_Id",
            m."ACSAS_ClassAttended" AS "ASA_Class_Attended"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance" k ON k."AMCO_Id" = b."AMCO_Id" AND k."AMB_Id" = b."AMB_Id" AND k."AMSE_Id" = b."AMSE_Id" AND k."ACMS_Id" = b."ACMS_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" l ON l."ACSA_Id" = k."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" m ON m."ACSA_Id" = k."ACSA_Id" AND m."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subject_Students" c ON c."AMCST_Id" = b."AMCST_Id" AND m."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "clg"."Adm_College_Atten_Batch_Subjects" d ON d."ACABS_Id" = c."ACABS_Id"
        INNER JOIN "clg"."Adm_College_Attendance_Batch" e ON e."ACAB_Id" = d."ACAB_Id"
        INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = b."AMCO_Id" AND f."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" g ON g."AMB_Id" = b."AMB_Id" AND g."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id" AND h."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" i ON i."ACMS_Id" = b."ACMS_Id" AND i."ACMS_Id" = d."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" j ON j."ASMAY_Id" = b."ASMAY_Id" AND j."ASMAY_Id" = d."ASMAY_Id"
        WHERE a."MI_Id" = p_MI_Id AND b."ASMAY_Id" = p_ASMAY_Id AND b."AMCO_Id" = p_AMCO_Id AND b."AMB_Id" = p_AMB_Id 
            AND b."AMSE_Id" = p_AMSE_Id AND b."ACMS_I