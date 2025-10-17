CREATE OR REPLACE FUNCTION "dbo"."CLG_CHAIRMAN_CASTEWISE_STUDENT_STRENGTH"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "IMCC_Id" bigint,
    "IMCC_CategoryName" varchar,
    "IMC_Id" bigint,
    "IMC_CasteName" varchar,
    "AMCO_Id" bigint,
    "AMCO_CourseName" varchar,
    "AMB_Id" bigint,
    "AMB_BranchName" varchar,
    "AMSE_Id" bigint,
    "AMSE_SEMName" varchar,
    "stud_count" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT  
        DISTINCT cc."IMCC_Id",
        cc."IMCC_CategoryName",
        b."IMC_Id",
        mc."IMC_CasteName",
        c."AMCO_Id",
        c."AMCO_CourseName",
        d."AMB_Id",
        d."AMB_BranchName",
        e."AMSE_Id",
        e."AMSE_SEMName",
        COUNT(DISTINCT a."AMCST_Id")::bigint AS stud_count
    FROM "clg"."Adm_College_Yearly_Student" a
    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = b."IMCC_Id"
    INNER JOIN "IVRM_Master_Caste" mc ON mc."IMC_Id" = b."IMC_Id"
    WHERE b."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND a."AMCST_SOL" = 'S'
        AND b."AMCST_ActiveFlag" = 1 
        AND a."ACYST_ActiveFlag" = 1
    GROUP BY 
        cc."IMCC_CategoryName",
        b."IMC_Id",
        cc."IMCC_Id",
        mc."IMC_CasteName",
        c."AMCO_Id",
        c."AMCO_CourseName",
        d."AMB_Id",
        d."AMB_BranchName",
        e."AMSE_Id",
        e."AMSE_SEMName";
END;
$$;