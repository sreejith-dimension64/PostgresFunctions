CREATE OR REPLACE FUNCTION "dbo"."CLG_CHAIRMANPORTAL_TOTAL_STD_STRENGTH_NEWSTD"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_TC boolean,
    p_DE boolean
)
RETURNS TABLE(
    "AMCO_Id" bigint,
    "AMCO_CourseName" text,
    "AMCO_Order" integer,
    "AMB_Id" bigint,
    "AMB_BranchName" text,
    "AMSE_Id" bigint,
    "AMSE_SEMName" text,
    "ACMS_Id" bigint,
    "ACMS_SectionName" text,
    "AMSE_SEMOrder" integer,
    "ACMS_Order" integer,
    "AMB_Order" integer,
    "stud_count" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_TC = FALSE AND p_DE = FALSE THEN
        RETURN QUERY
        SELECT
            C."AMCO_Id",
            C."AMCO_CourseName",
            C."AMCO_Order",
            D."AMB_Id",
            D."AMB_BranchName",
            E."AMSE_Id",
            E."AMSE_SEMName",
            F."ACMS_Id",
            F."ACMS_SectionName",
            E."AMSE_SEMOrder",
            F."ACMS_Order",
            D."AMB_Order",
            COUNT(DISTINCT B."AMCST_Id") AS stud_count
        FROM "Clg"."Adm_Master_College_Student" AS A
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" AS C ON C."AMCO_Id" = B."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS D ON D."AMB_Id" = B."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS E ON E."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" AS F ON F."ACMS_Id" = B."ACMS_Id"
        WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id
        AND A."AMCST_SOL" = 'S' AND A."AMCST_ActiveFlag" = 1 AND B."ACYST_ActiveFlag" = 1 AND C."AMCO_ActiveFlag" = 1
        GROUP BY C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order", D."AMB_Id", D."AMB_BranchName", 
                 E."AMSE_Id", E."AMSE_SEMName", F."ACMS_Id", F."ACMS_SectionName", E."AMSE_SEMOrder", 
                 F."ACMS_Order", D."AMB_Order"
        ORDER BY C."AMCO_Order", D."AMB_Order", E."AMSE_SEMOrder", F."ACMS_Order";
    
    ELSIF p_TC = TRUE AND p_DE = FALSE THEN
        RETURN QUERY
        SELECT
            C."AMCO_Id",
            C."AMCO_CourseName",
            C."AMCO_Order",
            D."AMB_Id",
            D."AMB_BranchName",
            E."AMSE_Id",
            E."AMSE_SEMName",
            F."ACMS_Id",
            F."ACMS_SectionName",
            E."AMSE_SEMOrder",
            F."ACMS_Order",
            D."AMB_Order",
            COUNT(DISTINCT B."AMCST_Id") AS stud_count
        FROM "Clg"."Adm_Master_College_Student" AS A
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" AS C ON C."AMCO_Id" = B."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS D ON D."AMB_Id" = B."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS E ON E."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" AS F ON F."ACMS_Id" = B."ACMS_Id"
        WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id
        AND A."AMCST_SOL" IN ('S', 'L') AND A."AMCST_ActiveFlag" IN (1, 0) AND B."ACYST_ActiveFlag" IN (1, 0) AND C."AMCO_ActiveFlag" = 1
        GROUP BY C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order", D."AMB_Id", D."AMB_BranchName", 
                 E."AMSE_Id", E."AMSE_SEMName", F."ACMS_Id", F."ACMS_SectionName", E."AMSE_SEMOrder", 
                 F."ACMS_Order", D."AMB_Order"
        ORDER BY C."AMCO_Order", D."AMB_Order", E."AMSE_SEMOrder", F."ACMS_Order";
    
    ELSIF p_TC = FALSE AND p_DE = TRUE THEN
        RETURN QUERY
        SELECT
            C."AMCO_Id",
            C."AMCO_CourseName",
            C."AMCO_Order",
            D."AMB_Id",
            D."AMB_BranchName",
            E."AMSE_Id",
            E."AMSE_SEMName",
            F."ACMS_Id",
            F."ACMS_SectionName",
            E."AMSE_SEMOrder",
            F."ACMS_Order",
            D."AMB_Order",
            COUNT(DISTINCT B."AMCST_Id") AS stud_count
        FROM "Clg"."Adm_Master_College_Student" AS A
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" AS C ON C."AMCO_Id" = B."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS D ON D."AMB_Id" = B."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS E ON E."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" AS F ON F."ACMS_Id" = B."ACMS_Id"
        WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id
        AND A."AMCST_SOL" IN ('S', 'D') AND A."AMCST_ActiveFlag" IN (1) AND B."ACYST_ActiveFlag" IN (1) AND C."AMCO_ActiveFlag" = 1
        GROUP BY C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order", D."AMB_Id", D."AMB_BranchName", 
                 E."AMSE_Id", E."AMSE_SEMName", F."ACMS_Id", F."ACMS_SectionName", E."AMSE_SEMOrder", 
                 F."ACMS_Order", D."AMB_Order"
        ORDER BY C."AMCO_Order", D."AMB_Order", E."AMSE_SEMOrder", F."ACMS_Order";
    
    ELSIF p_TC = TRUE AND p_DE = TRUE THEN
        RETURN QUERY
        SELECT
            C."AMCO_Id",
            C."AMCO_CourseName",
            C."AMCO_Order",
            D."AMB_Id",
            D."AMB_BranchName",
            E."AMSE_Id",
            E."AMSE_SEMName",
            F."ACMS_Id",
            F."ACMS_SectionName",
            E."AMSE_SEMOrder",
            F."ACMS_Order",
            D."AMB_Order",
            COUNT(DISTINCT B."AMCST_Id") AS stud_count
        FROM "Clg"."Adm_Master_College_Student" AS A
        INNER JOIN "CLG"."Adm_College_Yearly_Student" AS B ON A."AMCST_Id" = B."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" AS C ON C."AMCO_Id" = B."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AS D ON D."AMB_Id" = B."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AS E ON E."AMSE_Id" = B."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" AS F ON F."ACMS_Id" = B."ACMS_Id"
        WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id
        AND A."AMCST_SOL" IN ('S', 'D', 'L') AND A."AMCST_ActiveFlag" IN (1, 0) AND B."ACYST_ActiveFlag" IN (1, 0) AND C."AMCO_ActiveFlag" = 1
        GROUP BY C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order", D."AMB_Id", D."AMB_BranchName", 
                 E."AMSE_Id", E."AMSE_SEMName", F."ACMS_Id", F."ACMS_SectionName", E."AMSE_SEMOrder", 
                 F."ACMS_Order", D."AMB_Order"
        ORDER BY C."AMCO_Order", D."AMB_Order", E."AMSE_SEMOrder", F."ACMS_Order";
    
    END IF;
    
    RETURN;
END;
$$;