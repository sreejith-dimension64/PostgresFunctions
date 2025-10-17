CREATE OR REPLACE FUNCTION "dbo"."College_Student_Register_Report" (
    "mi_id" BIGINT, 
    "asmay_id" BIGINT, 
    "amco_id" BIGINT, 
    "amb_id" BIGINT, 
    "amse_id" BIGINT, 
    "acms_id" BIGINT,
    "column" TEXT, 
    "gender" VARCHAR
)
RETURNS TABLE AS
$$
DECLARE
    "gender_" VARCHAR(20);
    "sql_query" TEXT;
BEGIN
    IF "gender" = '1' THEN
        "gender_" := 'male';
        
        "sql_query" := 'SELECT ' || "column" || ' FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
        WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" = ' || "asmay_id" || 
        ' AND a."AMCO_Id" = ' || "amco_id" || ' AND a."AMB_Id" = ' || "amb_id" || 
        ' AND b."AMSE_Id" = ' || "amse_id" || ' AND b."ACMS_Id" = ' || "acms_id" || 
        ' AND a."AMCST_Sex" = ''' || "gender_" || '''';
        
        RETURN QUERY EXECUTE "sql_query";
        
    ELSIF "gender" = '2' THEN
        "gender_" := 'female';
        
        "sql_query" := 'SELECT ' || "column" || ' FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
        WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" = ' || "asmay_id" || 
        ' AND a."AMCO_Id" = ' || "amco_id" || ' AND a."AMB_Id" = ' || "amb_id" || 
        ' AND b."AMSE_Id" = ' || "amse_id" || ' AND b."ACMS_Id" = ' || "acms_id" || 
        ' AND a."AMCST_Sex" = ''' || "gender_" || '''';
        
        RETURN QUERY EXECUTE "sql_query";
        
    ELSIF "gender" = '3' THEN
        
        "sql_query" := 'SELECT ' || "column" || ' FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
        WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" = ' || "asmay_id" || 
        ' AND a."AMCO_Id" = ' || "amco_id" || ' AND a."AMB_Id" = ' || "amb_id" || 
        ' AND b."AMSE_Id" = ' || "amse_id" || ' AND b."ACMS_Id" = ' || "acms_id";
        
        RETURN QUERY EXECUTE "sql_query";
        
    END IF;
    
    RETURN;
END;
$$
LANGUAGE plpgsql;