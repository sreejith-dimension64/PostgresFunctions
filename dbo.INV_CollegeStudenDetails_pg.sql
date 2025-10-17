CREATE OR REPLACE FUNCTION "dbo"."INV_CollegeStudenDetails"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "ACMS_Id" BIGINT
)
RETURNS TABLE(
    "amsT_Id" BIGINT,
    "studentname" TEXT,
    "AMST_AdmNo" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        b."AMCST_Id" AS "amsT_Id",
        CONCAT(b."AMCST_FirstName", ' ', b."AMCST_MiddleName", ' ', b."AMCST_LastName") AS "studentname",
        b."AMCST_AdmNo" AS "AMST_AdmNo"
    FROM "CLG"."Adm_College_Yearly_Student" a
    INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    WHERE b."MI_Id" = "MI_Id" 
        AND a."ASMAY_Id" = "ASMAY_Id" 
        AND a."AMSE_Id" = "AMSE_Id" 
        AND a."ACMS_Id" = "ACMS_Id" 
        AND b."AMCST_ActiveFlag" = 1;
END;
$$;