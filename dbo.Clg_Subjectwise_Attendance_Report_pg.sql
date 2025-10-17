CREATE OR REPLACE FUNCTION "dbo"."Clg_Subjectwise_Attendance_Report"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_From" TIMESTAMP,
    "p_To" TIMESTAMP,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_AMSE_Id" TEXT,
    "p_ACMS_Id" TEXT,
    "p_AMCST_Id" TEXT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "StudentName" TEXT,
    "AMCST_AdmNo" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" TEXT,
    "ACMS_Id" BIGINT,
    "ACSA_AttendanceDate" TIMESTAMP,
    "ACSA_ClassHeld" NUMERIC,
    "ACSAS_ClassAttended" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        a."AMCST_Id",
        a."AMCST_FirstName" || ' ' || a."AMCST_MiddleName" || ' ' || a."AMCST_LastName" AS "StudentName",
        a."AMCST_AdmNo",
        a."AMCST_RegistrationNo",
        b."ISMS_Id",
        b."ISMS_SubjectName",
        c."ACMS_Id",
        c."ACSA_AttendanceDate",
        c."ACSA_ClassHeld",
        d."ACSAS_ClassAttended"
    FROM "CLG"."Adm_Master_College_Student" a,
         "IVRM_Master_Subjects" b,
         "CLG"."Adm_College_Student_Attendance" c,
         "CLG"."Adm_College_Student_Attendance_Students" d,
         "CLG"."Adm_College_Student_Attendance_Periodwise" e
    WHERE a."AMCST_Id" = d."AMCST_Id" 
        AND b."ISMS_Id" = c."ISMS_Id" 
        AND c."ACSA_Id" = d."ACSA_Id" 
        AND c."ACSA_Id" = e."ACSA_Id" 
        AND a."MI_Id" = b."MI_Id"
        AND a."MI_Id" = "p_MI_Id" 
        AND a."ASMAY_Id" = "p_ASMAY_Id" 
        AND c."ACSA_AttendanceDate" BETWEEN "p_From" AND "p_To"
        AND b."ISMS_ActiveFlag" = TRUE 
        AND c."AMCO_Id" = "p_AMCO_Id" 
        AND c."AMB_Id" = "p_AMB_Id" 
        AND c."AMSE_Id" = "p_AMSE_Id" 
        AND c."ACMS_Id" = "p_ACMS_Id" 
        AND a."AMCST_Id" = "p_AMCST_Id";

END;
$$;