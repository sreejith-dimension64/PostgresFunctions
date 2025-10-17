CREATE OR REPLACE FUNCTION "dbo"."College_Quota_Category" (
    "MI_Id" bigint, 
    "ASMAY_Id" bigint, 
    "AMCO_Id" bigint, 
    "AMSE_Id" text, 
    "AMB_Id" text, 
    "ACMS_Id" bigint, 
    "ACQ_Id" text, 
    "ACQC_Id" text
)
RETURNS TABLE (
    std_name text,
    regno text,
    dob text,
    fathername text,
    fatheroccupation text,
    sex text,
    std_address text,
    mobileno text,
    quotaname text,
    categoryname text,
    coursename text,
    semname text,
    brachname text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SqlQuery" text;
BEGIN
    "SqlQuery" := '
    SELECT DISTINCT 
        CONCAT(a."AMCST_FirstName",'' '',a."AMCST_MiddleName",'' '',a."AMCST_LastName") as std_name, 
        a."AMCST_RegistrationNo" as regno,
        TO_CHAR(a."AMCST_DOB", ''DD/MM/YYYY'') as dob, 
        COALESCE(a."AMCST_FatherName",'''') as fathername, 
        COALESCE(a."AMCST_FatherOccupation",'''') as fatheroccupation, 
        a."AMCST_Sex" as sex, 
        CONCAT(a."AMCST_PerStreet",'' '',a."AMCST_PerArea",'' '',a."AMCST_PerCity",'' '',a."AMCST_Taluk",'' '',a."AMCST_District") as std_address, 
        a."AMCST_MobileNo" as mobileno, 
        f."ACQ_QuotaName" as quotaname, 
        g."ACQC_CategoryName" as categoryname, 
        b."AMCO_CourseName" as coursename, 
        c."amse_semname" as semname,
        d."AMB_BranchName" as brachname
    FROM "CLG"."Adm_Master_College_Student" a
    INNER JOIN "CLG"."Adm_Master_Course" b ON a."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" c ON c."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
    INNER JOIN "CLG"."Adm_College_Quota" f ON f."ACQ_Id" = a."ACQ_Id"
    INNER JOIN "CLG"."Adm_College_Quota_Category" g ON g."ACQC_Id" = a."ACQC_Id"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" h ON h."AMCST_Id" = a."AMCST_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" i ON i."ACMS_Id" = h."ACMS_Id"
    WHERE a."MI_Id" = ' || "MI_Id" || ' 
        AND a."ASMAY_Id" = ' || "ASMAY_Id" || ' 
        AND a."AMCO_Id" = ' || "AMCO_Id" || ' 
        AND a."AMB_Id" IN (' || "AMB_Id" || ') 
        AND a."ACQ_Id" IN (' || "ACQ_Id" || ')  
        AND h."ACMS_Id" = ' || "ACMS_Id" || ' 
        AND a."AMSE_Id" IN (' || "AMSE_Id" || ')';

    RETURN QUERY EXECUTE "SqlQuery";
END;
$$;