CREATE OR REPLACE FUNCTION "dbo"."Clg_Attendance_SMSDetailsReport"(
    "@MI_Id" bigint,
    "@ASMAY_Id" varchar,
    "@AMCO_Id" varchar,
    "@AMB_Id" varchar,
    "@AMSE_Id" varchar,
    "@ACMS_Id" varchar
)
RETURNS TABLE(
    studentname TEXT,
    "AMCST_RegistrationNo" varchar,
    "AMCST_AdmNo" varchar,
    "AMCST_MobileNo" varchar,
    "AMCST_emailId" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    sqldynamic TEXT;
BEGIN
    sqldynamic := '
    SELECT 
        (COALESCE(a."AMCST_FirstName",'''') || '' '' || COALESCE(a."AMCST_MiddleName",'' '') || '' '' || COALESCE(a."AMCST_LastName",'' '')) AS studentname,
        a."AMCST_RegistrationNo",
        a."AMCST_AdmNo",
        a."AMCST_MobileNo",
        a."AMCST_emailId" 
    FROM "clg"."Adm_Master_College_Student" a 
    INNER JOIN "CLG"."Adm_College_Yearly_Student" BB ON A."AMCST_Id" = BB."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" b ON a."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" c ON c."AMB_Id" = a."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" d ON d."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" G ON G."ACMS_Id" = BB."ACMS_Id"
    WHERE a."MI_Id" = ' || "@MI_Id"::TEXT || ' 
        AND e."ASMAY_Id" = ' || "@ASMAY_Id" || ' 
        AND b."AMCO_Id" = (' || "@AMCO_Id" || ') 
        AND c."AMB_Id" IN (' || "@AMB_Id" || ') 
        AND d."AMSE_Id" IN (' || "@AMSE_Id" || ') 
        AND G."ACMS_Id" = ' || "@ACMS_Id" || ' 
        AND a."AMCST_ActiveFlag" = 1 
        AND a."AMCST_SOL" = ''S'' 
        AND BB."ACYST_ActiveFlag" = 1 
        AND a."AMCST_ActiveFlag" = 1';
    
    RETURN QUERY EXECUTE sqldynamic;
END;
$$;