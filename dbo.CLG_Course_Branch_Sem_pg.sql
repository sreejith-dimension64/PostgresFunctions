CREATE OR REPLACE FUNCTION "dbo"."CLG_Course_Branch_Sem" (
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE (
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "AMCO"."AMCO_CourseName",
        "AMB"."AMB_BranchName",
        "AMSE"."AMSE_SEMName"
    FROM "CLG"."Adm_Master_College_Student" "AMCS" 
    INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" 
        ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id" 
        AND "AMCS"."AMCST_SOL" = 'S' 
        AND "AMCS"."AMCST_ActiveFlag" = 1 
        AND "ACYS"."ACYST_ActiveFlag" = 1 
        AND "AMCS"."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Adm_Master_Course" "AMCO" 
        ON "AMCO"."MI_Id" = p_MI_Id 
        AND "AMCO"."AMCO_Id" = "AMCS"."AMCO_Id" 
        AND "AMCO"."AMCO_Id" = "ACYS"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "AMB" 
        ON "AMB"."AMB_Id" = "AMCS"."AMB_Id" 
        AND "AMB"."MI_Id" = p_MI_Id 
        AND "AMB"."AMB_Id" = "ACYS"."AMB_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" "ASMAY" 
        ON "ASMAY"."ASMAY_Id" = p_ASMAY_Id 
        AND "ASMAY"."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" 
        ON "AMSE"."MI_Id" = p_MI_Id 
        AND "AMSE"."AMSE_Id" = "ACYS"."AMSE_Id" 
        AND "AMSE"."AMSE_Id" = "AMCS"."AMSE_Id"
    WHERE "AMCS"."MI_Id" = p_MI_Id 
        AND "AMCS"."ASMAY_Id" = p_ASMAY_Id;
END;
$$;