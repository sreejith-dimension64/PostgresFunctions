CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_FEE_ACADEMICYEAR_CLASS_SECTION"(
    p_mi_id TEXT,
    p_amcst_id TEXT
)
RETURNS TABLE(
    "ASMAY_Id" INTEGER,
    "ASMAY_Year" VARCHAR,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "ACMS_SectionName" VARCHAR,
    "AMSE_SEMName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id",
        "dbo"."Adm_School_M_Academic_Year"."ASMAY_Year",
        "CLG"."Adm_Master_Course"."AMCO_CourseName",
        "CLG"."Adm_Master_Branch"."AMB_BranchName",
        "CLG"."Adm_College_Master_Section"."ACMS_SectionName",
        "CLG"."Adm_Master_Semester"."AMSE_SEMName"
    FROM "CLG"."Adm_Master_College_Student" 
    INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
    INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id" = "CLG"."Adm_College_Yearly_Student"."AMCO_Id" 
    INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id" = "CLG"."Adm_College_Yearly_Student"."AMB_Id" 
    INNER JOIN "CLG"."Adm_College_Master_Section" ON "CLG"."Adm_College_Master_Section"."ACMS_Id" = "CLG"."Adm_College_Yearly_Student"."ACMS_Id" 
    INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id" = "CLG"."Adm_College_Yearly_Student"."AMSE_Id" 
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
    WHERE "CLG"."Adm_Master_College_Student"."MI_Id" = p_mi_id 
    AND "CLG"."Adm_College_Yearly_Student"."AMCST_Id" = p_amcst_id;
END;
$$;