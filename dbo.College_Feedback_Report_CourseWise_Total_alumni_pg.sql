CREATE OR REPLACE FUNCTION "dbo"."College_Feedback_Report_CourseWise_Total_alumni"(
    "@MI_Id" TEXT, 
    "@ASMAY_Id" TEXT, 
    "@Flag" TEXT, 
    "@Type" TEXT, 
    "@FlagType" TEXT, 
    "@REPORT" TEXT, 
    "@AMCO_Id" TEXT
)
RETURNS TABLE(
    "AMCO_Id" BIGINT,
    "AMCO_CourseName" TEXT,
    "AMCO_Order" INTEGER,
    "AMSE_Id" BIGINT,
    "semyear" TEXT,
    "AMSE_SEMOrder" INTEGER,
    "GIVENSTUDENTS" BIGINT,
    "NOTGIVENSTUDENTS" BIGINT,
    "studentname" TEXT,
    "AMCST_AdmNo" TEXT,
    "ALCMST_RegistrationNo" TEXT,
    "ALCMST_MobileNo" TEXT,
    "AMCST_emailId" TEXT,
    "AMSE_SEMName" TEXT,
    "AMB_Id" BIGINT,
    "AMB_BranchName" TEXT,
    "AMB_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

IF "@REPORT" = '0' THEN

    RETURN QUERY
    SELECT 
        T."AMCO_Id", 
        T."AMCO_CourseName", 
        T."AMCO_Order", 
        T."AMSE_Id", 
        T."semyear", 
        T."AMSE_SEMOrder",
        SUM(T."GIVENSTUDENTS") AS "GIVENSTUDENTS", 
        SUM(T."NOTGIVENSTUDENTS") AS "NOTGIVENSTUDENTS",
        NULL::TEXT AS "studentname",
        NULL::TEXT AS "AMCST_AdmNo",
        NULL::TEXT AS "ALCMST_RegistrationNo",
        NULL::TEXT AS "ALCMST_MobileNo",
        NULL::TEXT AS "AMCST_emailId",
        NULL::TEXT AS "AMSE_SEMName",
        NULL::BIGINT AS "AMB_Id",
        NULL::TEXT AS "AMB_BranchName",
        NULL::INTEGER AS "AMB_Order"
    FROM (
        SELECT DISTINCT 
            D."AMCO_Id", 
            D."AMCO_CourseName", 
            D."AMCO_Order", 
            F."AMSE_Id", 
            (F."AMSE_Year"::VARCHAR(100) || ' Year') AS "semyear", 
            F."AMSE_SEMOrder",
            COUNT(*)::BIGINT AS "GIVENSTUDENTS", 
            0::BIGINT AS "NOTGIVENSTUDENTS" 
        FROM 
            "CLG"."Alumni_College_Master_Student" B
        INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = B."AMCO_Left_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = B."AMB_Id_Left"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = B."AMSE_Id_Left"
        INNER JOIN "CLG"."Alumni_College_Student_Registration" G ON G."AMCST_Id" = B."ALCMST_Id"
        WHERE B."MI_Id" = "@MI_Id" AND B."ASMAY_Id_Left" = "@ASMAY_Id" AND 
            G."ALCSREG_Id" IN (SELECT DISTINCT "ALCSREG_Id" FROM "CLG"."Feedback_College_Alumni_Transaction" WHERE "MI_Id" = "@MI_Id" AND "FMTY_Id" = "@Type")
        GROUP BY D."AMCO_Id", D."AMCO_CourseName", D."AMCO_Order", F."AMSE_Id", F."AMSE_Year", F."AMSE_SEMOrder"
        
        UNION 
        
        SELECT DISTINCT 
            D."AMCO_Id", 
            D."AMCO_CourseName", 
            D."AMCO_Order", 
            F."AMSE_Id", 
            (F."AMSE_Year"::VARCHAR(100) || ' Year') AS "semyear", 
            F."AMSE_SEMOrder",
            0::BIGINT AS "GIVENSTUDENTS",
            COUNT(*)::BIGINT AS "NOTGIVENSTUDENTS" 
        FROM 
            "CLG"."Alumni_College_Master_Student" B
        INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = B."AMCO_Left_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = B."AMB_Id_Left"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = B."AMSE_Id_Left"
        INNER JOIN "CLG"."Alumni_College_Student_Registration" G ON G."AMCST_Id" = B."ALCMST_Id"
        WHERE B."MI_Id" = "@MI_Id" AND B."ASMAY_Id_Left" = "@ASMAY_Id" AND
            G."ALCSREG_Id" NOT IN (SELECT DISTINCT "ALCSREG_Id" FROM "CLG"."Feedback_College_Alumni_Transaction" WHERE "MI_Id" = "@MI_Id" AND "FMTY_Id" = "@Type")
        GROUP BY D."AMCO_Id", D."AMCO_CourseName", D."AMCO_Order", F."AMSE_Id", F."AMSE_Year", F."AMSE_SEMOrder"
    ) AS T
    GROUP BY T."AMCO_Id", T."AMCO_CourseName", T."AMCO_Order", T."AMSE_Id", T."semyear", T."AMSE_SEMOrder"
    ORDER BY T."AMCO_Order", T."AMSE_SEMOrder";

ELSIF "@REPORT" = '1' THEN

    RETURN QUERY
    SELECT DISTINCT
        NULL::BIGINT AS "AMCO_Id",
        NULL::TEXT AS "AMCO_CourseName",
        NULL::INTEGER AS "AMCO_Order",
        NULL::BIGINT AS "AMSE_Id",
        NULL::TEXT AS "semyear",
        NULL::INTEGER AS "AMSE_SEMOrder",
        NULL::BIGINT AS "GIVENSTUDENTS",
        NULL::BIGINT AS "NOTGIVENSTUDENTS",
        (CASE WHEN B."ALCMST_FirstName" IS NULL OR B."ALCMST_FirstName" = '' THEN '' ELSE B."ALCMST_FirstName" END || 
         CASE WHEN B."ALCMST_MiddleName" IS NULL OR B."ALCMST_MiddleName" = '' THEN '' ELSE ' ' || B."ALCMST_MiddleName" END || 
         CASE WHEN B."ALCMST_LastName" IS NULL OR B."ALCMST_LastName" = '' THEN '' ELSE ' ' || B."ALCMST_LastName" END) AS "studentname",
        B."ALCMST_AdmNo" AS "AMCST_AdmNo",
        B."ALCMST_RegistrationNo",
        B."ALCMST_MobileNo",
        B."ALCMST_emailId" AS "AMCST_emailId",
        F."AMSE_SEMName",
        E."AMB_Id",
        E."AMB_BranchName",
        E."AMB_Order"
    FROM 
        "CLG"."Alumni_College_Master_Student" B
    INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = B."AMCO_Left_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = B."AMB_Id_Left"
    INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = B."AMSE_Id_Left"
    INNER JOIN "CLG"."Alumni_College_Student_Registration" G ON G."AMCST_Id" = B."ALCMST_Id"
    WHERE B."MI_Id" = "@MI_Id" AND B."ASMAY_Id_Left" = "@ASMAY_Id" AND B."AMCO_Left_Id" = "@AMCO_Id" AND 
        G."ALCSREG_Id" IN (SELECT DISTINCT "ALCSREG_Id" FROM "CLG"."Feedback_College_Alumni_Transaction" WHERE "MI_Id" = "@MI_Id" AND "FMTY_Id" = "@Type")
    ORDER BY D."AMCO_Order", F."AMSE_SEMOrder", E."AMB_Order", "studentname";

ELSIF "@REPORT" = '2' THEN

    RETURN QUERY
    SELECT DISTINCT
        NULL::BIGINT AS "AMCO_Id",
        NULL::TEXT AS "AMCO_CourseName",
        NULL::INTEGER AS "AMCO_Order",
        NULL::BIGINT AS "AMSE_Id",
        NULL::TEXT AS "semyear",
        NULL::INTEGER AS "AMSE_SEMOrder",
        NULL::BIGINT AS "GIVENSTUDENTS",
        NULL::BIGINT AS "NOTGIVENSTUDENTS",
        (CASE WHEN B."ALCMST_FirstName" IS NULL OR B."ALCMST_FirstName" = '' THEN '' ELSE B."ALCMST_FirstName" END || 
         CASE WHEN B."ALCMST_MiddleName" IS NULL OR B."ALCMST_MiddleName" = '' THEN '' ELSE ' ' || B."ALCMST_MiddleName" END || 
         CASE WHEN B."ALCMST_LastName" IS NULL OR B."ALCMST_LastName" = '' THEN '' ELSE ' ' || B."ALCMST_LastName" END) AS "studentname",
        B."ALCMST_AdmNo" AS "AMCST_AdmNo",
        B."ALCMST_RegistrationNo",
        B."ALCMST_MobileNo",
        B."ALCMST_emailId" AS "AMCST_emailId",
        F."AMSE_SEMName",
        E."AMB_Id",
        E."AMB_BranchName",
        E."AMB_Order"
    FROM 
        "CLG"."Alumni_College_Master_Student" B
    INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = B."AMCO_Left_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = B."AMB_Id_Left"
    INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = B."AMSE_Id_Left"
    INNER JOIN "CLG"."Alumni_College_Student_Registration" G ON G."AMCST_Id" = B."ALCMST_Id"
    WHERE B."MI_Id" = "@MI_Id" AND B."ASMAY_Id_Left" = "@ASMAY_Id" AND B."AMCO_Left_Id" = "@AMCO_Id" AND 
        G."ALCSREG_Id" NOT IN (SELECT DISTINCT "ALCSREG_Id" FROM "CLG"."Feedback_College_Alumni_Transaction" WHERE "MI_Id" = "@MI_Id" AND "FMTY_Id" = "@Type")
    ORDER BY D."AMCO_Order", F."AMSE_SEMOrder", E."AMB_Order", "studentname";

END IF;

RETURN;

END;
$$;