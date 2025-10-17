CREATE OR REPLACE FUNCTION "dbo"."clg_Adm_View_StudentWise_Attendance"(
    "p_MI_Id" VARCHAR,
    "p_ASMAY_Id" VARCHAR,
    "p_AMCST_Id" VARCHAR
)
RETURNS TABLE(
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
    "STATUS_FLAG" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_ASMAY_Year" VARCHAR;
BEGIN

    SELECT "Adm_School_M_Academic_Year"."ASMAY_Year" INTO "v_ASMAY_Year"
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = "p_MI_Id"::BIGINT
    AND "ASMAY_Id" = "p_ASMAY_Id"::BIGINT;

    RETURN QUERY
    SELECT 
        "D"."ASMAY_Year",
        "D"."AMCO_CourseName",
        "D"."AMB_BranchName",
        "D"."AMSE_SEMName",
        "D"."ASMAY_Order",
        "D"."ASMAY_Id",
        "D"."AMCO_Id",
        "D"."AMB_Id",
        "D"."AMSE_Id",
        "D"."AMCST_Id",
        "D"."WORKINGDAYS",
        "D"."PRESENTDAYS",
        "D"."PERCENTAGE",
        CASE WHEN "v_ASMAY_Year" = "D"."ASMAY_Year" THEN 'Current Year' ELSE '' END AS "STATUS_FLAG"
    FROM (
        SELECT 
            "g"."ASMAY_Year",
            "c"."AMCO_CourseName",
            "d"."AMB_BranchName",
            "e"."AMSE_SEMName",
            "g"."ASMAY_Order",
            "a"."ASMAY_Id",
            "a"."AMCO_Id",
            "a"."AMB_Id",
            "e"."AMSE_Id",
            "b"."AMCST_Id",
            SUM("a"."ACSA_ClassHeld") AS "WORKINGDAYS",
            SUM("b"."ACSAS_ClassAttended") AS "PRESENTDAYS",
            CAST((SUM("b"."ACSAS_ClassAttended") * 100.0 / SUM("a"."ACSA_ClassHeld")) AS NUMERIC(18,2)) AS "PERCENTAGE"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" 
            ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "f" 
            ON "f"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" "h" 
            ON "h"."AMCST_Id" = "f"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "c" 
            ON "c"."AMCO_Id" = "a"."AMCO_Id" AND "c"."AMCO_Id" = "f"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "d" 
            ON "d"."AMB_Id" = "a"."AMB_Id" AND "d"."AMB_Id" = "f"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "e" 
            ON "e"."AMSE_Id" = "a"."AMSE_Id" AND "e"."AMSE_Id" = "f"."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "g" 
            ON "g"."ASMAY_Id" = "a"."ASMAY_Id"
        WHERE "b"."AMCST_Id" = "p_AMCST_Id"::BIGINT
        AND "f"."AMCST_Id" = "p_AMCST_Id"::BIGINT
        AND "a"."ACSA_ActiveFlag" = 1
        AND "a"."MI_Id" = "p_MI_Id"::BIGINT
        GROUP BY 
            "g"."ASMAY_Year",
            "c"."AMCO_CourseName",
            "d"."AMB_BranchName",
            "e"."AMSE_SEMName",
            "g"."ASMAY_Order",
            "a"."ASMAY_Id",
            "a"."AMCO_Id",
            "a"."AMB_Id",
            "e"."AMSE_Id",
            "b"."AMCST_Id"
    ) AS "D"
    ORDER BY "D"."ASMAY_Order" DESC;

END;
$$;