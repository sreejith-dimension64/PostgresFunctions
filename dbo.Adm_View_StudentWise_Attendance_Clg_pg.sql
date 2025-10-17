CREATE OR REPLACE FUNCTION "dbo"."Adm_View_StudentWise_Attendance_Clg"(
    "@MI_Id" VARCHAR,
    "@ASMAY_Id" VARCHAR,
    "@AMST_Id" VARCHAR
)
RETURNS TABLE (
    "ASMAY_Year" VARCHAR,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "ASMAY_Order" INTEGER,
    "ASMAY_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMB_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "AMCST_Id" BIGINT,
    "WORKINGDAYS" BIGINT,
    "PRESENTDAYS" BIGINT,
    "PERCENTAGE" NUMERIC(18,2),
    "STATUS_FLAG" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ASMAY_Year" VARCHAR;
BEGIN

    SELECT "ASMAY_Year" INTO "v_ASMAY_Year" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "@MI_Id" AND "ASMAY_Id" = "@ASMAY_Id";

    RETURN QUERY
    SELECT 
        D."ASMAY_Year",
        D."AMCO_CourseName",
        D."AMB_BranchName",
        D."AMSE_SEMName",
        D."ASMAY_Order",
        D."ASMAY_Id",
        D."AMCO_Id",
        D."AMB_Id",
        D."AMSE_Id",
        D."AMCST_Id",
        D."WORKINGDAYS",
        D."PRESENTDAYS",
        D."PERCENTAGE",
        CASE WHEN "v_ASMAY_Year" = D."ASMAY_Year" THEN 'Current Year' ELSE '' END AS "STATUS_FLAG"
    FROM (
        SELECT 
            E."ASMAY_Year",
            F."AMCO_CourseName",
            G."AMB_BranchName",
            H."AMSE_SEMName",
            E."ASMAY_Order",
            A."ASMAY_Id",
            A."AMCO_Id",
            A."AMB_Id",
            A."AMSE_Id",
            B."AMCST_Id",
            SUM(A."ACSA_ClassHeld") AS "WORKINGDAYS",
            SUM(B."ACSAS_ClassAttended") AS "PRESENTDAYS",
            CAST((SUM(B."ACSAS_ClassAttended") * 100.0 / SUM(A."ACSA_ClassHeld")) AS NUMERIC(18,2)) AS "PERCENTAGE"
        FROM "clg"."Adm_College_Student_Attendance" A
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" B ON A."ACSA_Id" = B."ACSA_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" C ON C."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" D ON D."AMCST_Id" = C."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = A."ASMAY_Id" AND C."ASMAY_Id" = E."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" F ON F."AMCO_Id" = A."AMCO_Id" AND C."AMCO_Id" = F."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" G ON G."AMB_Id" = A."AMB_Id" AND C."AMB_Id" = G."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" H ON H."AMSE_Id" = A."AMSE_Id" AND C."AMSE_Id" = H."AMSE_Id"
        WHERE B."AMCST_Id" = "@AMST_Id" 
            AND C."AMCST_Id" = "@AMST_Id" 
            AND A."ACSA_Activeflag" = 1 
            AND A."MI_Id" = "@MI_Id"
        GROUP BY 
            E."ASMAY_Year",
            F."AMCO_CourseName",
            G."AMB_BranchName",
            H."AMSE_SEMName",
            E."ASMAY_Order",
            A."ASMAY_Id",
            A."AMCO_Id",
            A."AMB_Id",
            A."AMSE_Id",
            B."AMCST_Id"
    ) AS D
    ORDER BY D."ASMAY_Order" DESC;

END;
$$;