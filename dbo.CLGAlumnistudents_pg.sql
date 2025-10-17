CREATE OR REPLACE FUNCTION "dbo"."CLGAlumnistudents"(p_MI_Id bigint)
RETURNS TABLE(
    "ALCSREG_Id" bigint,
    "ALCSREG_MemberName" text,
    "A_year" text,
    "L_year" text,
    "Admit_course" text,
    "Left_course" text,
    "Admit_branch" text,
    "Left_branch" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS student_temp3;
    DROP TABLE IF EXISTS student_temp4;

    CREATE TEMP TABLE student_temp3 AS
    SELECT DISTINCT 
        a."ALCSREG_Id",
        a."ALCSREG_MemberName",
        c."ASMAY_Year",
        b."AMCO_CourseName",
        d."AMB_BranchName"
    FROM "CLG"."Alumni_College_Student_Registration" a,
         "CLG"."Adm_Master_Course" b,
         "Adm_School_M_Academic_Year" c,
         "CLG"."Adm_Master_Branch" d
    WHERE a."ALCSREG_AdmittedYear" = c."ASMAY_Id" 
      AND a."MI_Id" = c."MI_Id" 
      AND a."ALCSREG_AdmittedCourse" = b."AMCO_Id" 
      AND a."MI_Id" = b."MI_Id" 
      AND a."ALCSREG_AdmisstedBranch" = d."AMB_Id"
      AND a."MI_Id" = p_MI_Id 
      AND a."ALCSREG_ApprovedFlag" = 0 
      AND a."ALCSREG_ActiveFlg" = 1;

    CREATE TEMP TABLE student_temp4 AS
    SELECT DISTINCT 
        a."ALCSREG_Id",
        a."ALCSREG_MemberName",
        c."ASMAY_Year",
        b."AMCO_CourseName",
        d."AMB_BranchName"
    FROM "CLG"."Alumni_College_Student_Registration" a,
         "CLG"."Adm_Master_Course" b,
         "Adm_School_M_Academic_Year" c,
         "CLG"."Adm_Master_Branch" d
    WHERE a."ALCSREG_LeftYear" = c."ASMAY_Id" 
      AND a."MI_Id" = c."MI_Id" 
      AND a."ALCSREG_LeftCourse" = b."AMCO_Id" 
      AND a."MI_Id" = b."MI_Id" 
      AND a."ALCSREG_LeftBranch" = d."AMB_Id"
      AND a."MI_Id" = p_MI_Id 
      AND a."ALCSREG_ApprovedFlag" = 0 
      AND a."ALCSREG_ActiveFlg" = 1;

    RETURN QUERY
    SELECT 
        a."ALCSREG_Id",
        a."ALCSREG_MemberName",
        a."ASMAY_Year" AS "A_year",
        b."ASMAY_Year" AS "L_year",
        a."AMCO_CourseName" AS "Admit_course",
        b."AMCO_CourseName" AS "Left_course",
        a."AMB_BranchName" AS "Admit_branch",
        b."AMB_BranchName" AS "Left_branch"
    FROM student_temp3 a,
         student_temp4 b
    WHERE a."ALCSREG_Id" = b."ALCSREG_Id";

    DROP TABLE IF EXISTS student_temp3;
    DROP TABLE IF EXISTS student_temp4;

    RETURN;
END;
$$;