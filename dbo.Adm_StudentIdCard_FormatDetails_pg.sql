CREATE OR REPLACE FUNCTION "dbo"."Adm_StudentIdCard_FormatDetails" (
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE (
    "studentname" TEXT,
    "fatherName" TEXT,
    "mothername" TEXT,
    "pBloodgroup" VARCHAR,
    "AMST_PerStreet" VARCHAR,
    "AMST_PerArea" VARCHAR,
    "AMST_PerCity" VARCHAR,
    "AMST_PerState" VARCHAR,
    "AMST_PerCountry" VARCHAR,
    "AMST_PerPincode" VARCHAR,
    "pResstreet" VARCHAR,
    "pResArea" VARCHAR,
    "pRescity" VARCHAR,
    "AMST_ConState" VARCHAR,
    "AMST_ConCountry" VARCHAR,
    "pResPincode" VARCHAR,
    "studentemail" VARCHAR,
    "studentmobile" VARCHAR,
    "AMST_FatherMobleNo" VARCHAR,
    "AMST_FatheremailId" VARCHAR,
    "ANST_FatherPhoto" VARCHAR,
    "AMST_MotherMobileNo" VARCHAR,
    "AMST_MotherEmailId" VARCHAR,
    "ANST_MotherPhoto" VARCHAR,
    "studentphoto" VARCHAR,
    "admissionno" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_SQL" TEXT;
BEGIN
    "v_SQL" := 'SELECT     
    CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '''' THEN '''' ELSE "AMST_FirstName" END ||
    CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMST_MiddleName" END ||  
    CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMST_LastName" END AS studentname,

    CASE WHEN "AMST_FatherName" IS NULL OR "AMST_FatherName" = '''' THEN '''' ELSE "AMST_FatherName" END ||
    CASE WHEN "AMST_FatherSurname" IS NULL OR "AMST_FatherSurname" = '''' OR "AMST_FatherSurname" = ''0'' THEN '''' ELSE '' '' || "AMST_FatherSurname" END AS fatherName,
    
    CASE WHEN "AMST_MotherName" IS NULL OR "AMST_MotherName" = '''' THEN '''' ELSE "AMST_MotherName" END ||
    CASE WHEN "AMST_MotherSurname" IS NULL OR "AMST_MotherSurname" = '''' OR "AMST_MotherSurname" = ''0'' THEN '''' ELSE '' '' || "AMST_MotherSurname" END AS mothername,
    
    "Adm_M_Student"."AMST_BloodGroup" AS pBloodgroup,
    "Adm_M_Student"."AMST_PerStreet",
    "Adm_M_Student"."AMST_PerArea",
    "Adm_M_Student"."AMST_PerCity",
    "Adm_M_Student"."AMST_PerState",
    "Adm_M_Student"."AMST_PerCountry",
    "Adm_M_Student"."AMST_PerPincode",
    "Adm_M_Student"."AMST_ConStreet" AS pResstreet,
    "Adm_M_Student"."AMST_ConArea" AS pResArea,
    "Adm_M_Student"."AMST_ConCity" AS pRescity,
    "Adm_M_Student"."AMST_ConState",
    "Adm_M_Student"."AMST_ConCountry",
    "Adm_M_Student"."AMST_ConPincode" AS pResPincode,
    "Adm_M_Student"."AMST_emailId" AS studentemail,
    "Adm_M_Student"."AMST_MobileNo" AS studentmobile,
    "Adm_M_Student"."AMST_FatherMobleNo",
    "Adm_M_Student"."AMST_FatheremailId",
    "Adm_M_Student"."ANST_FatherPhoto",
    "Adm_M_Student"."AMST_MotherMobileNo",
    "Adm_M_Student"."AMST_MotherEmailId",
    "Adm_M_Student"."ANST_MotherPhoto",
    "Adm_M_Student"."AMST_Photoname" AS studentphoto,
    "Adm_M_Student"."AMST_AdmNo" AS admissionno
    FROM "dbo"."Adm_M_Student" 
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    WHERE "Adm_School_Y_Student"."AMST_Id" IN (' || "@AMST_Id" || ') 
    AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "@ASMAY_Id" || ' 
    AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "@ASMCL_Id" || '
    AND "Adm_School_Y_Student"."ASMS_Id" = ' || "@ASMS_Id";

    RETURN QUERY EXECUTE "v_SQL";
END;
$$;