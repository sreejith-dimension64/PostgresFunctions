CREATE OR REPLACE FUNCTION "dbo"."INV_CLG_STUDENTLIST"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCO_Id VARCHAR(20),
    p_AMB_Id VARCHAR(20),
    p_AMSE_Id VARCHAR(20)
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMB_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "studentname" TEXT,
    "AMCST_AdmNo" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."AMCST_Id",
        b."AMCO_Id",
        b."AMB_Id",
        b."AMSE_Id",
        (CASE WHEN a."AMCST_FirstName" IS NULL OR a."AMCST_FirstName" = '' THEN '' ELSE a."AMCST_FirstName" END ||
         CASE WHEN a."AMCST_MiddleName" IS NULL OR a."AMCST_MiddleName" = '' OR a."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMCST_MiddleName" END ||
         CASE WHEN a."AMCST_LastName" IS NULL OR a."AMCST_LastName" = '' OR a."AMCST_LastName" = '0' THEN '' ELSE ' ' || a."AMCST_LastName" END) AS studentname,
        a."AMCST_AdmNo"
    FROM "CLG"."Adm_Master_College_Student" a
    INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = b."ASMAY_Id"
    INNER JOIN "CLG"."Adm_Master_Course" d ON d."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" e ON e."AMB_Id" = b."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" f ON f."AMSE_Id" = b."AMSE_Id"
    WHERE a."AMCST_ActiveFlag" = 1 
        AND a."AMCST_SOL" = 'S' 
        AND a."MI_Id" = p_MI_Id 
        AND b."ASMAY_Id" = p_ASMAY_Id 
        AND b."AMCO_Id"::VARCHAR = p_AMCO_Id 
        AND b."AMB_Id"::VARCHAR = p_AMB_Id 
        AND b."AMSE_Id"::VARCHAR = p_AMSE_Id
    ORDER BY studentname;
END;
$$;