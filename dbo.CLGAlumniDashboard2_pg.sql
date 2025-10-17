CREATE OR REPLACE FUNCTION "dbo"."CLGAlumniDashboard2"(
    "MI_Id" varchar
)
RETURNS TABLE(
    "Name" varchar,
    "AMCO_CourseName" varchar,
    "AMB_BranchName" varchar,
    "ASMAY_Year" varchar,
    "ALCMST_AdmNo" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "CLG"."Alumni_College_Master_Student"."ALCMST_FirstName" as "Name",
        "CLG"."Adm_Master_Course"."AMCO_CourseName",
        "CLG"."Adm_Master_Branch"."AMB_BranchName",
        "dbo"."Adm_School_M_Academic_Year"."ASMAY_Year",
        "CLG"."Alumni_College_Master_Student"."ALCMST_AdmNo"
    FROM "CLG"."Alumni_College_Master_Student"
    INNER JOIN "CLG"."Adm_Master_Branch" 
        ON "CLG"."Alumni_College_Master_Student"."AMB_Id_Left" = "CLG"."Adm_Master_Branch"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Course" 
        ON "CLG"."Alumni_College_Master_Student"."AMCO_Left_Id" = "CLG"."Adm_Master_Course"."AMCO_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
        ON "CLG"."Alumni_College_Master_Student"."ASMAY_Id_Left" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
    WHERE "CLG"."Alumni_College_Master_Student"."MI_Id" = "MI_Id";
END;
$$;