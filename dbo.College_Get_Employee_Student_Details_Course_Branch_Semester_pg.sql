CREATE OR REPLACE FUNCTION "dbo"."College_Get_Employee_Student_Details_Course_Branch_Semester"(
    "p_MI_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_AMSE_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ACMS_Id" TEXT,
    "p_FLAG" TEXT,
    "p_HRME_Id" TEXT,
    "p_ECSMU_Id" TEXT
)
RETURNS TABLE(
    "hrmE_Id" BIGINT,
    "employeename" TEXT,
    "studentname" TEXT,
    "amcsT_Id" BIGINT,
    "admno" TEXT,
    "regno" TEXT,
    "ammeC_Id" BIGINT,
    "ammecM_Activeflag" BOOLEAN,
    "AMMECM_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMB_Id" BIGINT,
    "ACMS_Id" BIGINT,
    "AMSE_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "p_FLAG" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "D"."HRME_Id" AS "hrmE_Id",
            (COALESCE("D"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("D"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("D"."HRME_EmployeeLastName", '')) AS "employeename",
            NULL::TEXT AS "studentname",
            NULL::BIGINT AS "amcsT_Id",
            NULL::TEXT AS "admno",
            NULL::TEXT AS "regno",
            NULL::BIGINT AS "ammeC_Id",
            NULL::BOOLEAN AS "ammecM_Activeflag",
            NULL::BIGINT AS "AMMECM_Id",
            NULL::BIGINT AS "HRME_Id",
            NULL::BIGINT AS "ASMAY_Id",
            NULL::BIGINT AS "AMCO_Id",
            NULL::BIGINT AS "AMB_Id",
            NULL::BIGINT AS "ACMS_Id",
            NULL::BIGINT AS "AMSE_Id"
        FROM "CLG"."Adm_Dept_Course" "A"
        INNER JOIN "CLG"."Adm_Dept_Course_Branch_Semester" "B" ON "A"."ADCO_Id" = "B"."ADCO_Id"
        INNER JOIN "HR_Master_Department" "C" ON "C"."HRMD_Id" = "A"."HRMD_Id"
        INNER JOIN "HR_Master_Employee" "D" ON "D"."HRMD_Id" = "C"."HRMD_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "E" ON "E"."AMCO_Id" = "A"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "F" ON "F"."AMB_Id" = "B"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "G" ON "G"."AMSE_Id" = "B"."AMSE_Id"
        WHERE "A"."AMCO_Id"::TEXT = "p_AMCO_Id" 
            AND "B"."AMB_Id"::TEXT = "p_AMB_Id" 
            AND "B"."AMSE_Id"::TEXT = "p_AMSE_Id" 
            AND "A"."MI_Id"::TEXT = "p_MI_Id" 
            AND "A"."ADCO_ActiveFlag" = TRUE 
            AND "B"."ADCOBS_ActiveFlag" = TRUE
            AND "D"."HRME_ActiveFlag" = TRUE 
            AND "D"."HRME_LeftFlag" = FALSE;

    ELSIF "p_FLAG" = '2' THEN
        RETURN QUERY
        SELECT 
            NULL::BIGINT AS "hrmE_Id",
            NULL::TEXT AS "employeename",
            DISTINCT (CASE WHEN "A"."AMCST_FirstName" = '' OR "A"."AMCST_FirstName" IS NULL THEN '' ELSE "A"."AMCST_FirstName" END ||
            CASE WHEN "A"."AMCST_MiddleName" = '' OR "A"."AMCST_MiddleName" IS NULL THEN '' ELSE ' ' || "A"."AMCST_MiddleName" END ||
            CASE WHEN "A"."AMCST_LastName" = '' OR "A"."AMCST_LastName" IS NULL THEN '' ELSE ' ' || "A"."AMCST_LastName" END) AS "studentname",
            "A"."AMCST_Id" AS "amcsT_Id",
            "A"."AMCST_AdmNo" AS "admno",
            "A"."AMCST_RegistrationNo" AS "regno",
            NULL::BIGINT AS "ammeC_Id",
            NULL::BOOLEAN AS "ammecM_Activeflag",
            NULL::BIGINT AS "AMMECM_Id",
            NULL::BIGINT AS "HRME_Id",
            NULL::BIGINT AS "ASMAY_Id",
            NULL::BIGINT AS "AMCO_Id",
            NULL::BIGINT AS "AMB_Id",
            NULL::BIGINT AS "ACMS_Id",
            NULL::BIGINT AS "AMSE_Id"
        FROM "CLG"."Adm_Master_College_Student" "A" 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "B" ON "A"."AMCST_Id" = "B"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "C" ON "C"."AMCO_Id" = "B"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "D" ON "D"."AMB_Id" = "B"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "E" ON "E"."AMSE_Id" = "B"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "F" ON "F"."ACMS_Id" = "B"."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "G" ON "G"."ASMAY_Id" = "B"."ASMAY_Id"
        WHERE "B"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "B"."AMCO_Id"::TEXT = "p_AMCO_Id" 
            AND "B"."AMB_Id"::TEXT = "p_AMB_Id" 
            AND "B"."ACMS_Id"::TEXT = "p_ACMS_Id" 
            AND "B"."AMSE_Id"::TEXT = "p_AMSE_Id"
            AND "B"."ACYST_ActiveFlag" = TRUE 
            AND "A"."AMCST_SOL" = 'S' 
            AND "A"."AMCST_ActiveFlag" = TRUE 
            AND "A"."AMCST_Id" NOT IN (
                SELECT DISTINCT "me"."AMCST_Id" 
                FROM "CLG"."Adm_Master_Mentor_College_Mentee" "me" 
                INNER JOIN "CLG"."Adm_Master_Mentor_College" "mc" ON "me"."AMMEC_Id" = "mc"."AMMEC_Id"
                WHERE "me"."AMCO_Id"::TEXT = "p_AMCO_Id" 
                    AND "me"."AMB_Id"::TEXT = "p_AMB_Id" 
                    AND "me"."AMSE_Id"::TEXT = "p_AMSE_Id" 
                    AND "me"."ACMS_Id"::TEXT = "p_ACMS_Id" 
                    AND "mc"."HRME_Id"::TEXT != "p_HRME_Id" 
                    AND "mc"."MI_Id"::TEXT = "p_MI_Id" 
                    AND "mc"."ASMAY_Id"::TEXT = "p_ASMAY_Id"
            )
        ORDER BY "studentname";

    ELSIF "p_FLAG" = '3' THEN
        RETURN QUERY
        SELECT 
            NULL::BIGINT AS "hrmE_Id",
            NULL::TEXT AS "employeename",
            DISTINCT (CASE WHEN "A"."AMCST_FirstName" = '' OR "A"."AMCST_FirstName" IS NULL THEN '' ELSE "A"."AMCST_FirstName" END ||
            CASE WHEN "A"."AMCST_MiddleName" = '' OR "A"."AMCST_MiddleName" IS NULL THEN '' ELSE ' ' || "A"."AMCST_MiddleName" END ||
            CASE WHEN "A"."AMCST_LastName" = '' OR "A"."AMCST_LastName" IS NULL THEN '' ELSE ' ' || "A"."AMCST_LastName" END) AS "studentname",
            "A"."AMCST_Id" AS "amcsT_Id",
            NULL::TEXT AS "admno",
            NULL::TEXT AS "regno",
            "I"."AMMEC_Id" AS "ammeC_Id",
            NULL::BOOLEAN AS "ammecM_Activeflag",
            NULL::BIGINT AS "AMMECM_Id",
            NULL::BIGINT AS "HRME_Id",
            NULL::BIGINT AS "ASMAY_Id",
            NULL::BIGINT AS "AMCO_Id",
            NULL::BIGINT AS "AMB_Id",
            NULL::BIGINT AS "ACMS_Id",
            NULL::BIGINT AS "AMSE_Id"
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
            AND "H"."ACMS_Id" = "F"."ACMS_Id"
        INNER JOIN "CLG"."Adm_Master_Mentor_College" "I" ON "I"."AMMEC_Id" = "H"."AMMEC_Id" 
            AND "I"."ASMAY_Id" = "G"."ASMAY_Id"
        WHERE "B"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "B"."AMCO_Id"::TEXT = "p_AMCO_Id" 
            AND "B"."AMB_Id"::TEXT = "p_AMB_Id" 
            AND "B"."ACMS_Id"::TEXT = "p_ACMS_Id" 
            AND "B"."AMSE_Id"::TEXT = "p_AMSE_Id"
            AND "B"."ACYST_ActiveFlag" = TRUE 
            AND "A"."AMCST_SOL" = 'S' 
            AND "A"."AMCST_ActiveFlag" = TRUE 
            AND "I"."HRME_Id"::TEXT = "p_HRME_Id"
            AND "I"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "H"."AMCO_Id"::TEXT = "p_AMCO_Id" 
            AND "H"."AMB_Id"::TEXT = "p_AMB_Id" 
            AND "H"."ACMS_Id"::TEXT = "p_ACMS_Id" 
            AND "H"."AMSE_Id"::TEXT = "p_AMSE_Id"
        ORDER BY "studentname";

    ELSE
        RETURN QUERY
        SELECT 
            NULL::BIGINT AS "hrmE_Id",
            NULL::TEXT AS "employeename",
            DISTINCT (CASE WHEN "A"."AMCST_FirstName" = '' OR "A"."AMCST_FirstName" IS NULL THEN '' ELSE "A"."AMCST_FirstName" END ||
            CASE WHEN "A"."AMCST_MiddleName" = '' OR "A"."AMCST_MiddleName" IS NULL THEN '' ELSE ' ' || "A"."AMCST_MiddleName" END ||
            CASE WHEN "A"."AMCST_LastName" = '' OR "A"."AMCST_LastName" IS NULL THEN '' ELSE ' ' || "A"."AMCST_LastName" END) AS "studentname",
            "A"."AMCST_Id" AS "amcsT_Id",
            "A"."AMCST_AdmNo" AS "admno",
            "A"."AMCST_RegistrationNo" AS "regno",
            "I"."AMMEC_Id" AS "ammeC_Id",
            "H"."AMMECM_Activeflag" AS "ammecM_Activeflag",
            "H"."AMMECM_Id",
            "I"."HRME_Id",
            "I"."ASMAY_Id",
            "H"."AMCO_Id",
            "H"."AMB_Id",
            "H"."ACMS_Id",
            "H"."AMSE_Id"
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
            AND "H"."ACMS_Id" = "F"."ACMS_Id"
        INNER JOIN "CLG"."Adm_Master_Mentor_College" "I" ON "I"."AMMEC_Id" = "H"."AMMEC_Id" 
            AND "I"."ASMAY_Id" = "G"."ASMAY_Id"
        WHERE "B"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "B"."AMCO_Id"::TEXT = "p_AMCO_Id" 
            AND "B"."AMB_Id"::TEXT = "p_AMB_Id" 
            AND "B"."ACMS_Id"::TEXT = "p_ACMS_Id" 
            AND "B"."AMSE_Id"::TEXT = "p_AMSE_Id"
            AND "B"."ACYST_ActiveFlag" = TRUE 
            AND "A"."AMCST_SOL" = 'S' 
            AND "A"."AMCST_ActiveFlag" = TRUE 
            AND "I"."HRME_Id"::TEXT = "p_HRME_Id"
            AND "I"."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
            AND "H"."AMCO_Id"::TEXT = "p_AMCO_Id" 
            AND "H"."AMB_Id"::TEXT = "p_AMB_Id" 
            AND "H"."ACMS_Id"::TEXT = "p_ACMS_Id" 
            AND "H"."AMSE_Id"::TEXT = "p_AMSE_Id" 
            AND "I"."AMMEC_Id"::TEXT = "p_ECSMU_Id"
        ORDER BY "studentname";

    END IF;

    RETURN;

END;
$$;