CREATE OR REPLACE FUNCTION "dbo"."bus_pass_app"(
    "pasr" TEXT,
    "mi_id" BIGINT
)
RETURNS TABLE(
    "PASR_Id" BIGINT,
    "PASR_FirstName" VARCHAR,
    "PASR_ConStreet" VARCHAR,
    "PASR_ConArea" VARCHAR,
    "PASR_ConCity" VARCHAR,
    "PASR_ConPincode" VARCHAR,
    "PASR_FatherName" VARCHAR,
    "PASR_FatherMobleNo" VARCHAR,
    "PASR_MotherMobleNo" VARCHAR,
    "PASR_emailId" VARCHAR,
    "PASR_FatherHomePhNo" VARCHAR,
    "PASR_BloodGroup" VARCHAR,
    "PASR_FatherOfficePhNo" VARCHAR,
    "IVRMMC_Id" BIGINT,
    "IVRMMC_CountryName" VARCHAR,
    "IVRMMS_Id" BIGINT,
    "IVRMMS_Name" VARCHAR,
    "ASMCL_ClassName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."PASR_Id",
        a."PASR_FirstName",
        a."PASR_ConStreet",
        a."PASR_ConArea",
        a."PASR_ConCity",
        a."PASR_ConPincode",
        a."PASR_FatherName",
        a."PASR_FatherMobleNo",
        a."PASR_MotherMobleNo",
        a."PASR_emailId",
        a."PASR_FatherHomePhNo",
        a."PASR_BloodGroup",
        a."PASR_FatherOfficePhNo",
        b."IVRMMC_Id",
        b."IVRMMC_CountryName",
        c."IVRMMS_Id",
        c."IVRMMS_Name",
        d."ASMCL_ClassName"
    FROM "Preadmission_School_Registration" a,
         "IVRM_Master_Country" b,
         "IVRM_Master_State" c,
         "Adm_School_M_Class" d
    WHERE a."PASR_ConCountry" = b."IVRMMC_Id" 
      AND a."PASR_ConState" = c."IVRMMS_Id" 
      AND a."ASMCL_Id" = d."ASMCL_Id"
      AND a."PASR_Id" = "pasr"::BIGINT
      AND a."MI_Id" = "mi_id";
END;
$$;