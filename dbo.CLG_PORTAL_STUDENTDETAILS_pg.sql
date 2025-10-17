CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_STUDENTDETAILS"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCST_Id BIGINT
)
RETURNS TABLE(
    studentname TEXT,
    fatherName TEXT,
    mothername TEXT,
    "AMCO_Id" BIGINT,
    "AMCO_CourseName" TEXT,
    "AMB_Id" BIGINT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "ACMS_SectionName" TEXT,
    "ASMAY_Id" BIGINT,
    "ASMAY_Year" TEXT,
    "AMCST_AdmNo" TEXT,
    "AMCST_DOB" TIMESTAMP,
    "AMCST_emailId" TEXT,
    "AMCST_MobileNo" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "AMCST_StudentPhoto" TEXT,
    "AMCST_PerStreet" TEXT,
    "AMCST_PerArea" TEXT,
    "AMCST_PerCity" TEXT,
    "ACYST_RollNo" TEXT,
    "AMCST_Sex" TEXT,
    "AMCST_FatherMobleNo" TEXT,
    "AMCST_FatheremailId" TEXT,
    "AMCST_MotherMobleNo" TEXT,
    "AMCST_MotheremailId" TEXT,
    "AMCST_Date" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        (CASE WHEN AMCS."AMCST_FirstName" IS NULL OR AMCS."AMCST_FirstName" = '' THEN '' ELSE AMCS."AMCST_FirstName" END || 
         CASE WHEN AMCS."AMCST_MiddleName" IS NULL OR AMCS."AMCST_MiddleName" = '' OR AMCS."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || AMCS."AMCST_MiddleName" END || 
         CASE WHEN AMCS."AMCST_LastName" IS NULL OR AMCS."AMCST_LastName" = '' OR AMCS."AMCST_LastName" = '0' THEN '' ELSE ' ' || AMCS."AMCST_LastName" END)::TEXT as studentname,
        
        (CASE WHEN AMCS."AMCST_FatherName" IS NULL OR AMCS."AMCST_FatherName" = '' THEN '' ELSE AMCS."AMCST_FatherName" END || 
         CASE WHEN AMCS."AMCST_FatherSurname" IS NULL OR AMCS."AMCST_FatherSurname" = '' OR AMCS."AMCST_FatherSurname" = '0' THEN '' ELSE ' ' || AMCS."AMCST_FatherSurname" END)::TEXT as fatherName,
        
        (CASE WHEN AMCS."AMCST_MotherName" IS NULL OR AMCS."AMCST_MotherName" = '' THEN '' ELSE AMCS."AMCST_MotherName" END || 
         CASE WHEN AMCS."AMCST_MotherSurname" IS NULL OR AMCS."AMCST_MotherSurname" = '' OR AMCS."AMCST_MotherSurname" = '0' THEN '' ELSE ' ' || AMCS."AMCST_MotherSurname" END)::TEXT as mothername,
        
        AMCO."AMCO_Id",
        AMCO."AMCO_CourseName"::TEXT,
        AMB."AMB_Id",
        AMB."AMB_BranchName"::TEXT,
        AMSE."AMSE_SEMName"::TEXT,
        ACMS."ACMS_SectionName"::TEXT,
        ACYS."ASMAY_Id",
        ASMAY."ASMAY_Year"::TEXT,
        AMCS."AMCST_AdmNo"::TEXT,
        AMCS."AMCST_DOB",
        AMCS."AMCST_emailId"::TEXT,
        AMCS."AMCST_MobileNo"::TEXT,
        AMCS."AMCST_RegistrationNo"::TEXT,
        AMCS."AMCST_StudentPhoto"::TEXT,
        AMCS."AMCST_PerStreet"::TEXT,
        AMCS."AMCST_PerArea"::TEXT,
        AMCS."AMCST_PerCity"::TEXT,
        ACYS."ACYST_RollNo"::TEXT,
        AMCS."AMCST_Sex"::TEXT,
        AMCS."AMCST_FatherMobleNo"::TEXT,
        AMCS."AMCST_FatheremailId"::TEXT,
        AMCS."AMCST_MotherMobleNo"::TEXT,
        AMCS."AMCST_MotheremailId"::TEXT,
        AMCS."AMCST_Date"
    FROM "CLG"."Adm_Master_College_Student" AMCS
    INNER JOIN "CLG"."Adm_College_Yearly_Student" ACYS ON AMCS."AMCST_Id" = ACYS."AMCST_Id" 
        AND AMCS."AMCST_SOL" = 'S' 
        AND ACYS."ASMAY_Id" = p_ASMAY_Id 
        AND AMCS."AMCST_ActiveFlag" = 1 
        AND ACYS."ACYST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_Master_Course" AMCO ON AMCO."MI_Id" = p_MI_Id 
        AND AMCO."AMCO_Id" = ACYS."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" AMB ON AMB."MI_Id" = p_MI_Id 
        AND AMB."AMB_Id" = ACYS."AMB_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ASMAY ON ASMAY."ASMAY_Id" = p_ASMAY_Id 
        AND ASMAY."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."MI_Id" = p_MI_Id 
        AND AMSE."AMSE_Id" = ACYS."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" ACMS ON ACMS."ACMS_Id" = ACYS."ACMS_Id" 
        AND ACMS."MI_Id" = p_MI_Id
    WHERE ASMAY."MI_Id" = p_MI_Id 
        AND ASMAY."ASMAY_Id" = p_ASMAY_Id 
        AND ACYS."AMCST_Id" = p_AMCST_Id;
END;
$$;