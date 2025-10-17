CREATE OR REPLACE FUNCTION "dbo"."College_Get_Employee_Student_Details_Course_Branch_Semester_Report"(
    "p_MI_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_AMSE_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ACMS_Id" TEXT,
    "p_FLAG" TEXT,
    "p_HRME_Id" TEXT
)
RETURNS TABLE(
    "studentname" TEXT,
    "amcsT_Id" BIGINT,
    "ammeC_Id" BIGINT,
    "admno" VARCHAR,
    "regno" VARCHAR,
    "coursename" VARCHAR,
    "branchname" VARCHAR,
    "semname" VARCHAR,
    "sectionname" VARCHAR,
    "employeename" TEXT,
    "yearname" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        (CASE WHEN "A"."AMCST_FirstName" = '' OR "A"."AMCST_FirstName" IS NULL THEN '' ELSE "A"."AMCST_FirstName" END ||
         CASE WHEN "A"."AMCST_MiddleName" = '' OR "A"."AMCST_MiddleName" IS NULL THEN '' ELSE ' ' || "A"."AMCST_MiddleName" END ||
         CASE WHEN "A"."AMCST_LastName" = '' OR "A"."AMCST_LastName" IS NULL THEN '' ELSE ' ' || "A"."AMCST_LastName" END)::TEXT AS "studentname",
        "A"."AMCST_Id" AS "amcsT_Id",
        "I"."AMMEC_Id" AS "ammeC_Id",
        "A"."AMCST_AdmNo" AS "admno",
        "A"."AMCST_RegistrationNo" AS "regno",
        "c"."AMCO_CourseName" AS "coursename",
        "d"."AMB_BranchName" AS "branchname",
        "e"."AMSE_SEMName" AS "semname",
        "f"."ACMS_SectionName" AS "sectionname",
        (COALESCE("J"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("J"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("J"."HRME_EmployeeLastName", ''))::TEXT AS "employeename",
        "G"."ASMAY_Year" AS "yearname"
    FROM "CLG"."Adm_Master_College_Student" "A"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" "B" ON "A"."AMCST_Id" = "B"."AMCST_Id"
    INNER JOIN "CLG"."Adm_Master_Course" "C" ON "C"."AMCO_Id" = "B"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "D" ON "D"."AMB_Id" = "B"."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" "E" ON "E"."AMSE_Id" = "B"."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" "F" ON "F"."ACMS_Id" = "B"."ACMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "G" ON "G"."ASMAY_Id" = "B"."ASMAY_Id"
    INNER JOIN "CLG"."Adm_Master_Mentor_College_Mentee" "H" ON "H"."AMCST_Id" = "B"."AMCST_Id" 
        AND "C"."AMCO_Id" = "H"."AMCO_Id" 
        AND "H"."AMB_Id" = "D"."AMB_Id"
        AND "H"."AMSE_Id" = "E"."AMSE_Id" 
        AND "H"."acms_id" = "F"."ACMS_Id"
    INNER JOIN "CLG"."Adm_Master_Mentor_College" "I" ON "I"."AMMEC_Id" = "H"."AMMEC_Id" 
        AND "I"."ASMAY_Id" = "G"."ASMAY_Id"
    INNER JOIN "HR_Master_Employee" "J" ON "J"."HRME_Id" = "I"."HRME_Id" 
        AND "I"."ASMAY_Id" = "G"."ASMAY_Id"
    WHERE "B"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
        AND "B"."AMCO_Id" = "p_AMCO_Id"::BIGINT 
        AND "B"."AMB_Id" = "p_AMB_Id"::BIGINT 
        AND "B"."ACMS_Id" = "p_ACMS_Id"::BIGINT 
        AND "B"."AMSE_Id" = "p_AMSE_Id"::BIGINT
        AND "B"."ACYST_ActiveFlag" = 1 
        AND "A"."AMCST_SOL" = 'S' 
        AND "A"."AMCST_ActiveFlag" = 1 
        AND "I"."HRME_Id" = "p_HRME_Id"::BIGINT
        AND "I"."ASMAY_Id" = "p_ASMAY_Id"::BIGINT 
        AND "H"."AMCO_Id" = "p_AMCO_Id"::BIGINT 
        AND "H"."AMB_Id" = "p_AMB_Id"::BIGINT 
        AND "H"."ACMS_Id" = "p_ACMS_Id"::BIGINT 
        AND "H"."AMSE_Id" = "p_AMSE_Id"::BIGINT
        AND "J"."HRME_LeftFlag" = 0 
        AND "J"."HRME_ActiveFlag" = 1
    ORDER BY "studentname";
END;
$$;