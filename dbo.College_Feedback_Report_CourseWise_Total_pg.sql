CREATE OR REPLACE FUNCTION "dbo"."College_Feedback_Report_CourseWise_Total"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "Flag" TEXT,
    "Type" TEXT,
    "FlagType" TEXT,
    "REPORT" TEXT,
    "AMCO_Id" TEXT
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
    "AMCST_RegistrationNo" TEXT,
    "AMCST_MobileNo" TEXT,
    "AMCST_emailId" TEXT,
    "AMSE_SEMName" TEXT,
    "AMB_Id" BIGINT,
    "AMB_BranchName" TEXT,
    "AMB_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "REPORT" = '0' THEN
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
            NULL::TEXT AS "AMCST_RegistrationNo",
            NULL::TEXT AS "AMCST_MobileNo",
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
                COUNT(*) AS "GIVENSTUDENTS",
                0::BIGINT AS "NOTGIVENSTUDENTS"
            FROM "CLG"."Adm_College_Yearly_Student" B
            INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_Id" = B."AMCST_Id"
            INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = B."AMCO_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = B."AMB_Id"
            INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = B."AMSE_Id"
            INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id" = B."ACMS_Id"
            WHERE C."AMCST_SOL" = 'S' 
                AND C."AMCST_ActiveFlag" = 1 
                AND B."ACYST_ActiveFlag" = 1 
                AND C."MI_Id"::TEXT = "MI_Id" 
                AND B."ASMAY_Id"::TEXT = "ASMAY_Id"
                AND B."AMCST_Id" IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "CLG"."Feedback_College_Student_Transaction" 
                    WHERE "MI_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."MI_Id" 
                        AND "ASMAY_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."ASMAY_Id" 
                        AND "FMTY_Id"::TEXT = "Type"
                        AND "FCSTR_StudParFlg"::TEXT = "Flag"
                )
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
                COUNT(*) AS "NOTGIVENSTUDENTS"
            FROM "CLG"."Adm_College_Yearly_Student" B
            INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_Id" = B."AMCST_Id"
            INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = B."AMCO_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = B."AMB_Id"
            INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = B."AMSE_Id"
            INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id" = B."ACMS_Id"
            WHERE C."AMCST_SOL" = 'S' 
                AND C."AMCST_ActiveFlag" = 1 
                AND B."ACYST_ActiveFlag" = 1 
                AND C."MI_Id"::TEXT = "MI_Id" 
                AND B."ASMAY_Id"::TEXT = "ASMAY_Id"
                AND B."AMCST_Id" NOT IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "CLG"."Feedback_College_Student_Transaction" 
                    WHERE "MI_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."MI_Id" 
                        AND "ASMAY_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."ASMAY_Id" 
                        AND "FMTY_Id"::TEXT = "Type"
                        AND "FCSTR_StudParFlg"::TEXT = "Flag"
                )
            GROUP BY D."AMCO_Id", D."AMCO_CourseName", D."AMCO_Order", F."AMSE_Id", F."AMSE_Year", F."AMSE_SEMOrder"
        ) AS T
        GROUP BY T."AMCO_Id", T."AMCO_CourseName", T."AMCO_Order", T."AMSE_Id", T."semyear", T."AMSE_SEMOrder"
        ORDER BY T."AMCO_Order", T."AMSE_SEMOrder"
        LIMIT 100;

    ELSIF "REPORT" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT
            D."AMCO_Id",
            D."AMCO_CourseName",
            D."AMCO_Order",
            F."AMSE_Id",
            NULL::TEXT AS "semyear",
            F."AMSE_SEMOrder",
            NULL::BIGINT AS "GIVENSTUDENTS",
            NULL::BIGINT AS "NOTGIVENSTUDENTS",
            (CASE WHEN C."AMCST_FirstName" IS NULL OR C."AMCST_FirstName" = '' THEN '' ELSE C."AMCST_FirstName" END ||
             CASE WHEN C."AMCST_MiddleName" IS NULL OR C."AMCST_MiddleName" = '' THEN '' ELSE ' ' || C."AMCST_MiddleName" END ||
             CASE WHEN C."AMCST_LastName" IS NULL OR C."AMCST_LastName" = '' THEN '' ELSE ' ' || C."AMCST_LastName" END) AS "studentname",
            C."AMCST_AdmNo",
            C."AMCST_RegistrationNo",
            C."AMCST_MobileNo",
            C."AMCST_emailId",
            F."AMSE_SEMName",
            E."AMB_Id",
            E."AMB_BranchName",
            E."AMB_Order"
        FROM "CLG"."Adm_College_Yearly_Student" B
        INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = B."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = B."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id" = B."ACMS_Id"
        WHERE C."AMCST_SOL" = 'S' 
            AND C."AMCST_ActiveFlag" = 1 
            AND B."ACYST_ActiveFlag" = 1 
            AND C."MI_Id"::TEXT = "MI_Id" 
            AND B."ASMAY_Id"::TEXT = "ASMAY_Id" 
            AND B."AMCO_Id"::TEXT = "AMCO_Id"
            AND B."AMCST_Id" IN (
                SELECT DISTINCT "AMCST_Id" 
                FROM "CLG"."Feedback_College_Student_Transaction" 
                WHERE "MI_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."MI_Id" 
                    AND "ASMAY_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."ASMAY_Id" 
                    AND "FMTY_Id"::TEXT = "Type"
                    AND "FCSTR_StudParFlg"::TEXT = "Flag"
                    AND "AMCO_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."AMCO_Id"
            )
        ORDER BY D."AMCO_Order", F."AMSE_SEMOrder", E."AMB_Order", "studentname"
        LIMIT 100;

    ELSIF "REPORT" = '2' THEN
        RETURN QUERY
        SELECT DISTINCT
            D."AMCO_Id",
            D."AMCO_CourseName",
            D."AMCO_Order",
            F."AMSE_Id",
            NULL::TEXT AS "semyear",
            F."AMSE_SEMOrder",
            NULL::BIGINT AS "GIVENSTUDENTS",
            NULL::BIGINT AS "NOTGIVENSTUDENTS",
            (CASE WHEN C."AMCST_FirstName" IS NULL OR C."AMCST_FirstName" = '' THEN '' ELSE C."AMCST_FirstName" END ||
             CASE WHEN C."AMCST_MiddleName" IS NULL OR C."AMCST_MiddleName" = '' THEN '' ELSE ' ' || C."AMCST_MiddleName" END ||
             CASE WHEN C."AMCST_LastName" IS NULL OR C."AMCST_LastName" = '' THEN '' ELSE ' ' || C."AMCST_LastName" END) AS "studentname",
            C."AMCST_AdmNo",
            C."AMCST_RegistrationNo",
            C."AMCST_MobileNo",
            C."AMCST_emailId",
            F."AMSE_SEMName",
            E."AMB_Id",
            E."AMB_BranchName",
            E."AMB_Order"
        FROM "CLG"."Adm_College_Yearly_Student" B
        INNER JOIN "CLG"."Adm_Master_College_Student" C ON C."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" D ON D."AMCO_Id" = B."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" E ON E."AMB_Id" = B."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" F ON F."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id" = B."ACMS_Id"
        WHERE C."AMCST_SOL" = 'S' 
            AND C."AMCST_ActiveFlag" = 1 
            AND B."ACYST_ActiveFlag" = 1 
            AND C."MI_Id"::TEXT = "MI_Id" 
            AND B."ASMAY_Id"::TEXT = "ASMAY_Id" 
            AND B."AMCO_Id"::TEXT = "AMCO_Id"
            AND B."AMCST_Id" NOT IN (
                SELECT DISTINCT "AMCST_Id" 
                FROM "CLG"."Feedback_College_Student_Transaction" 
                WHERE "MI_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."MI_Id" 
                    AND "ASMAY_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."ASMAY_Id" 
                    AND "FMTY_Id"::TEXT = "Type"
                    AND "AMCO_Id"::TEXT = "College_Feedback_Report_CourseWise_Total"."AMCO_Id"
                    AND "FCSTR_StudParFlg"::TEXT = "Flag"
            )
        ORDER BY D."AMCO_Order", F."AMSE_SEMOrder", E."AMB_Order", "studentname"
        LIMIT 100;

    END IF;

    RETURN;

END;
$$;