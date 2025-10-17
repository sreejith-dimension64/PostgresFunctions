CREATE OR REPLACE FUNCTION "dbo"."CLG_HOSTEL_SINGLE_STUDENT_DETAILS"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCST_Id BIGINT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "studentName" TEXT,
    "AMCO_CourseName" VARCHAR,
    "AMCO_CourseCode" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMB_BranchCode" VARCHAR,
    "AMCST_RegistrationNo" VARCHAR,
    "AMCST_AdmNo" VARCHAR,
    "ACYST_RollNo" VARCHAR,
    "ASMAY_Id" BIGINT,
    "AMSE_SEMName" VARCHAR,
    "AMSE_SEMCode" VARCHAR,
    "ACMS_SectionName" VARCHAR,
    "ACMS_SectionCode" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "AMCS"."AMCST_Id",
        COALESCE("AMCS"."AMCST_FirstName", '') || ' ' || COALESCE("AMCS"."AMCST_MiddleName", '') || ' ' || COALESCE("AMCS"."AMCST_LastName", '') as "studentName",
        "MC"."AMCO_CourseName",
        "MC"."AMCO_CourseCode",
        "MB"."AMB_BranchName",
        "MB"."AMB_BranchCode",
        "AMCS"."AMCST_RegistrationNo",
        "AMCS"."AMCST_AdmNo",
        "AYS"."ACYST_RollNo",
        "AYS"."ASMAY_Id",
        "MS"."AMSE_SEMName",
        "MS"."AMSE_SEMCode",
        "MSec"."ACMS_SectionName",
        "MSec"."ACMS_SectionCode"
    FROM "CLG"."Adm_Master_College_Student" "AMCS"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" "AYS" ON "AYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
        AND "AMCS"."AMCST_ActiveFlag" = 1 
        AND "AMCS"."AMCST_SOL" = 'S' 
        AND "AYS"."ACYST_ActiveFlag" = 1
    INNER JOIN "CLG"."Adm_Master_Course" "MC" ON "AYS"."AMCO_Id" = "MC"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "MB" ON "AYS"."AMB_Id" = "MB"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" "MS" ON "AYS"."AMSE_Id" = "MS"."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" "MSec" ON "AYS"."ACMS_Id" = "MSec"."ACMS_Id"
    WHERE "AMCS"."MI_Id" = p_MI_Id 
        AND "AYS"."ASMAY_Id" = p_ASMAY_Id 
        AND "AYS"."AMCST_Id" = p_AMCST_Id;
END;
$$;