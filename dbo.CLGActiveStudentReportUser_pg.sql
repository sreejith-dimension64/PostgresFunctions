CREATE OR REPLACE FUNCTION "dbo"."CLGActiveStudentReportUser"(
    "MI_Id" VARCHAR,
    "asmay_id" VARCHAR,
    "amco_id" VARCHAR,
    "amb_id" VARCHAR,
    "amse_id" VARCHAR
)
RETURNS TABLE(
    "amcsT_Id" BIGINT,
    "studentName" TEXT,
    "amcsT_Admno" VARCHAR,
    "acmS_SectionName" VARCHAR,
    "amB_BranchName" VARCHAR,
    "amcO_CourseName" VARCHAR,
    "amsE_SEMName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
BEGIN
    "sql" := 'SELECT a."AMCST_Id" as "amcsT_Id",
        COALESCE(a."AMCST_FirstName",'' '') || '' '' || COALESCE(a."AMCST_MiddleName",'' '') || '' '' || COALESCE(a."AMCST_LastName",'' '') as "studentName",
        a."AMCST_AdmNo" as "amcsT_Admno",
        f."ACMS_SectionName" as "acmS_SectionName",
        d."AMB_BranchName" as "amB_BranchName",
        c."AMCO_CourseName" as "amcO_CourseName",
        e."AMSE_SEMName" as "amsE_SEMName"
    FROM "clg"."Adm_Master_College_Student" a
    INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."adm_master_course" c ON c."amco_id" = b."amco_id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
    INNER JOIN "clg"."Adm_College_Master_Section" f ON f."ACMS_Id" = b."ACMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
    WHERE a."AMCST_SOL" = ''S'' 
        AND a."AMCST_ActiveFlag" = 1 
        AND b."ACYST_ActiveFlag" = 1 
        AND b."AMCO_Id" = ' || "amco_id" || ' 
        AND a."mi_id" = ' || "MI_Id" || ' 
        AND b."AMB_Id" IN (' || "amb_id" || ') 
        AND b."AMSE_Id" IN (' || "amse_id" || ') 
        AND b."ASMAY_Id" = ' || "asmay_id" || ' 
        AND a."amcst_id" NOT IN (
            SELECT a."amcst_id" 
            FROM "clg"."Adm_Master_College_Student" a
            INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
            INNER JOIN "clg"."adm_master_course" c ON c."amco_id" = b."amco_id"
            INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
            INNER JOIN "clg"."Adm_College_Master_Section" f ON f."ACMS_Id" = b."ACMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = b."ASMAY_Id"
            INNER JOIN "IVRM_User_Login_Student_College" h ON h."AMCST_Id" = a."AMCST_Id"
            INNER JOIN "ApplicationUser" i ON i."Id" = h."IVRMUL_Id" 
            WHERE a."AMCST_SOL" = ''S'' 
                AND a."AMCST_ActiveFlag" = 1 
                AND b."ACYST_ActiveFlag" = 1 
                AND b."AMCO_Id" = ' || "amco_id" || ' 
                AND a."mi_id" = ' || "MI_Id" || ' 
                AND b."AMB_Id" IN (' || "amb_id" || ') 
                AND b."AMSE_Id" IN (' || "amse_id" || ') 
                AND b."ASMAY_Id" = ' || "asmay_id" || '
            LIMIT 1
        )';

    RAISE NOTICE '%', "sql";
    
    RETURN QUERY EXECUTE "sql";
END;
$$;