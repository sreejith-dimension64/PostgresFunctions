CREATE OR REPLACE FUNCTION "clg"."College_Get_Studentwise_SubjectList"(
    "@MI_Id" VARCHAR,
    "@ASMAY_Id" VARCHAR,
    "@AMCO_Id" VARCHAR,
    "@AMB_Id" VARCHAR,
    "@AMSE_Id" VARCHAR,
    "@AMCST_Id" VARCHAR
)
RETURNS TABLE(
    "subjectname" TEXT,
    "ismS_Id" BIGINT,
    "ISMS_OrderFlag" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (g."ISMS_SubjectName" || ':' || g."ISMS_SubjectCode")::TEXT AS "subjectname",
        g."ISMS_Id" AS "ismS_Id",
        g."ISMS_OrderFlag"
    FROM "clg"."Exm_Col_Studentwise_Subjects" a
    INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_College_Student" c ON c."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" d ON d."AMCO_Id" = b."AMCO_Id" AND d."AMCO_Id" = a."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" e ON e."AMB_Id" = b."AMB_Id" AND e."AMB_Id" = a."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = b."AMSE_Id" AND f."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "IVRM_Master_Subjects" g ON g."ISMS_Id" = a."ISMS_Id"
    WHERE a."ASMAY_Id" = "@ASMAY_Id" 
        AND a."AMCO_Id" = "@AMCO_Id" 
        AND a."AMB_Id" = "@AMB_Id" 
        AND a."AMSE_Id" = "@AMSE_Id" 
        AND a."AMCST_Id" = "@AMCST_Id"
        AND b."ASMAY_Id" = "@ASMAY_Id" 
        AND b."AMCO_Id" = "@AMCO_Id" 
        AND b."AMB_Id" = "@AMB_Id" 
        AND b."AMSE_Id" = "@AMSE_Id" 
        AND b."AMCST_Id" = "@AMCST_Id"
        AND a."MI_Id" = "@MI_Id" 
        AND b."ACYST_ActiveFlag" = 1 
        AND a."ECSTSU_ActiveFlg" = 1 
        AND c."AMCST_SOL" = 'S' 
        AND c."AMCST_ActiveFlag" = 1
        AND g."ISMS_ActiveFlag" = 1
    ORDER BY g."ISMS_OrderFlag";
END;
$$;