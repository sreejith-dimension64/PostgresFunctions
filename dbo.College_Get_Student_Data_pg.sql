CREATE OR REPLACE FUNCTION "dbo"."College_Get_Student_Data"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_AMCST_SOL TEXT
)
RETURNS TABLE(
    "amcsT_Id" INTEGER,
    "studentname" TEXT,
    "admno" VARCHAR,
    "regno" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_AMCST_SOL = 'S' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."amcst_id" AS "amcsT_Id",
            (COALESCE(b."AMCST_FirstName", '') || ' ' || COALESCE(b."AMCST_MiddleName", '') || ' ' || COALESCE(b."AMCST_LastName", '')) AS "studentname",
            b."AMCST_AdmNo" AS "admno",
            b."AMCST_RegistrationNo" AS "regno"
        FROM "clg"."Adm_College_Yearly_Student" a
        INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" d ON d."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" e ON e."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" g ON g."ACMS_Id" = a."ACMS_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id 
            AND a."AMCO_Id" = p_AMCO_Id 
            AND a."AMB_Id" = p_AMB_Id 
            AND a."AMSE_Id" = p_AMSE_Id 
            AND a."ACMS_Id" = p_ACMS_Id 
            AND a."ACYST_ActiveFlag" = 1
            AND b."AMCST_SOL" = 'S' 
            AND b."AMCST_ActiveFlag" = 1;
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            b."amcst_id" AS "amcsT_Id",
            (COALESCE(b."AMCST_FirstName", '') || ' ' || COALESCE(b."AMCST_MiddleName", '') || ' ' || COALESCE(b."AMCST_LastName", '')) AS "studentname",
            b."AMCST_AdmNo" AS "admno",
            b."AMCST_RegistrationNo" AS "regno"
        FROM "clg"."Adm_College_Yearly_Student" a
        INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" d ON d."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" e ON e."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" g ON g."ACMS_Id" = a."ACMS_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id 
            AND a."AMCO_Id" = p_AMCO_Id 
            AND a."AMB_Id" = p_AMB_Id 
            AND a."AMSE_Id" = p_AMSE_Id 
            AND a."ACMS_Id" = p_ACMS_Id 
            AND a."ACYST_ActiveFlag" = 1
            AND b."AMCST_SOL" = 'D' 
            AND b."AMCST_ActiveFlag" = 1;
    END IF;
END;
$$;