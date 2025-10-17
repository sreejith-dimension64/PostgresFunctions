CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Student_Address_Book_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT
)
RETURNS TABLE(
    "STUDENTNAME" TEXT,
    "AMCST_AdmNo" VARCHAR,
    "AMCST_RegistrationNo" VARCHAR,
    "AMCST_BloodGroup" VARCHAR,
    "DOB" VARCHAR,
    "STUDENTMOBILE" VARCHAR,
    "FATHERMOBILENO" VARCHAR,
    "MOTHERMOBILE" VARCHAR,
    "STUDENTEMAIL" VARCHAR,
    "FATHEREMAILID" VARCHAR,
    "MOTHEREMAILID" VARCHAR,
    "AMCST_StudentPhoto" TEXT,
    "course" TEXT,
    "addressd1" TEXT,
    "AMCO_Order" INTEGER,
    "AMB_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQLQUERY TEXT;
BEGIN
    v_SQLQUERY := 'SELECT (COALESCE(B."AMCST_FirstName",'''') || '' '' || COALESCE(B."AMCST_MiddleName",'''') || '' '' || COALESCE(B."AMCST_LastName",'''')) AS "STUDENTNAME", 
    B."AMCST_AdmNo", B."AMCST_RegistrationNo", 
    B."AMCST_BloodGroup", TO_CHAR(B."AMCST_DOB", ''DD/MM/YYYY'') AS "DOB", B."AMCST_MobileNo" AS "STUDENTMOBILE", 
    B."AMCST_FatherMobleNo" AS "FATHERMOBILENO", B."AMCST_MotherMobleNo" AS "MOTHERMOBILE", 
    B."AMCST_emailId" AS "STUDENTEMAIL", B."AMCST_FatheremailId" AS "FATHEREMAILID", B."AMCST_MotheremailId" AS "MOTHEREMAILID", 
    B."AMCST_StudentPhoto",
    (C."amco_coursename" || '' : '' || D."amb_branchname") AS "course",
    TRIM(BOTH '','' FROM 
        COALESCE('','' || NULLIF(B."AMCST_PerStreet", ''''), '''') || 
        COALESCE('','' || NULLIF(B."AMCST_PerArea", ''''), '''') ||
        COALESCE('','' || NULLIF(B."AMCST_PerCity", ''''), '''') ||
        COALESCE('','' || NULLIF(MS."ivrmms_name", ''''), '''') ||
        COALESCE('','' || NULLIF(MC."IVRMMC_CountryName", ''''), '''')
    ) AS "addressd1", 
    C."AMCO_Order", D."AMB_Order"
    FROM "CLG"."Adm_College_Yearly_Student" A 
    INNER JOIN "CLG"."Adm_Master_College_Student" B ON A."AMCST_Id" = B."AMCST_Id"
    INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = A."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id" = A."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = A."AMSE_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" F ON F."ACMS_Id" = A."ACMS_Id"
    LEFT OUTER JOIN "IVRM_Master_Country" MC ON MC."IVRMMC_Id" = B."IVRMMC_Id"
    LEFT OUTER JOIN "IVRM_Master_State" MS ON B."AMCST_PerState" = MS."IVRMMS_Id"
    WHERE A."ASMAY_Id" = ' || p_ASMAY_Id || ' 
    AND A."AMCO_Id" = ' || p_AMCO_Id || ' 
    AND B."AMCST_SOL" = ''S'' 
    AND B."AMCST_ActiveFlag" = 1
    AND A."AMB_Id" IN (' || p_AMB_Id || ') 
    AND A."AMSE_Id" = ' || p_AMSE_Id || ' 
    AND A."ACMS_Id" = ' || p_ACMS_Id || ' 
    AND B."MI_Id" = ' || p_MI_Id || ' 
    ORDER BY C."AMCO_Order", D."AMB_Order", "STUDENTNAME"';

    RETURN QUERY EXECUTE v_SQLQUERY;
END;
$$;