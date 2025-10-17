CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Student_Address_Book_Report_Format2"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMCO_Id" TEXT,
    "AMB_Id" TEXT,
    "AMSE_Id" TEXT,
    "ACMS_Id" TEXT,
    "AMCST_Id" TEXT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
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
    "SQLQUERY" TEXT;
BEGIN
    "SQLQUERY" := ' SELECT "AMCST_Id" , "STUDENTNAME","AMCST_AdmNo","AMCST_RegistrationNo","AMCST_BloodGroup","DOB","STUDENTMOBILE" , "FATHERMOBILENO" ,"MOTHERMOBILE", 
"STUDENTEMAIL","FATHEREMAILID" ,"MOTHEREMAILID","AMCST_StudentPhoto","course", REPLACE("addressd1",'','','','') "addressd1" , "AMCO_Order","AMB_Order"
FROM (SELECT DISTINCT  B."AMCST_Id" ,
(COALESCE(B."AMCST_FirstName",'''')||'' ''|| COALESCE(B."AMCST_MiddleName",'''')||'' '' ||COALESCE(B."AMCST_LastName",'''')) "STUDENTNAME" , "AMCST_AdmNo", "AMCST_RegistrationNo",
"AMCST_BloodGroup", TO_CHAR("AMCST_DOB",''DD/MM/YYYY'') "DOB", "AMCST_MobileNo" "STUDENTMOBILE" , "AMCST_FatherMobleNo" "FATHERMOBILENO" , 
"AMCST_MotherMobleNo" "MOTHERMOBILE", "AMCST_emailId" "STUDENTEMAIL", "AMCST_FatheremailId" "FATHEREMAILID" , "AMCST_MotheremailId" "MOTHEREMAILID", 
"AMCST_StudentPhoto",("amco_coursename" ||'' : ''||"amb_branchname") "course",TRIM(LEADING '','' FROM COALESCE('','' || NULLIF(B."AMCST_PerStreet",''''), '''')  || 
COALESCE('','' || NULLIF("AMCST_PerArea",''''), '''') ||COALESCE('','' || NULLIF("AMCST_PerCity",''''), '''') ||COALESCE('','' || NULLIF("ivrmms_name",''''), '''') ||
COALESCE('','' || NULLIF("IVRMMC_CountryName",''''),'''')) AS "addressd1", "AMCO_Order","AMB_Order"

FROM "CLG"."Adm_College_Yearly_Student" A
INNER JOIN "CLG"."Adm_Master_College_Student" B ON A."AMCST_Id"=B."AMCST_Id"
INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" =A."AMCO_Id"
INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id"=A."AMB_Id"
INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id"=A."AMSE_Id"
INNER JOIN "CLG"."Adm_College_Master_Section" F ON F."ACMS_Id"=A."ACMS_Id"
LEFT OUTER JOIN "IVRM_Master_Country" on "IVRM_Master_Country"."IVRMMC_Id"=B."IVRMMC_Id"
LEFT OUTER JOIN "IVRM_Master_State" on B."AMCST_PerState" ="IVRM_Master_State"."IVRMMS_Id"
WHERE A."ASMAY_Id"=' || "ASMAY_Id" || ' AND A."AMCO_Id"=' || "AMCO_Id" || ' AND B."AMCST_SOL"=''S'' AND B."AMCST_ActiveFlag"=1
AND A."AMB_Id" IN (' || "AMB_Id" || ') AND A."AMSE_Id" =' || "AMSE_Id" || ' AND A."ACMS_Id" =' || "ACMS_Id" || ' AND B."MI_Id"=' || "MI_Id" || '
AND A."AMCST_Id" IN (' || "AMCST_Id" || ')
ORDER BY "AMCO_Order","AMB_Order" ,"STUDENTNAME" LIMIT 100 )AS D';

    RETURN QUERY EXECUTE "SQLQUERY";
END;
$$;