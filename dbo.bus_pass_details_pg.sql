CREATE OR REPLACE FUNCTION "dbo"."bus_pass_details"(
    "pasr" TEXT,
    "mi_id" BIGINT
)
RETURNS TABLE(
    "PASR_Id" BIGINT,
    "PASR_FirstName" VARCHAR,
    "PASR_PerStreet" VARCHAR,
    "PASR_PerArea" VARCHAR,
    "PASR_PerCity" VARCHAR,
    "PASR_PerPincode" VARCHAR,
    "PASR_FatherName" VARCHAR,
    "PASR_FatherMobleNo" VARCHAR,
    "PASR_MotherMobleNo" VARCHAR,
    "PASR_emailId" VARCHAR,
    "PASR_FatherHomePhNo" VARCHAR,
    "PASR_FatherOfficePhNo" VARCHAR,
    "IVRMMC_Id" BIGINT,
    "IVRMMC_CountryName" VARCHAR,
    "IVRMMS_Id" BIGINT,
    "IVRMMS_Name" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "TRMR_Id" BIGINT,
    "TRMR_RouteName" VARCHAR,
    "TRML_Id" BIGINT,
    "TRML_LocationName" VARCHAR,
    "PASR_BloodGroup" VARCHAR,
    "CreatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."PASR_Id",
        a."PASR_FirstName",
        a."PASR_PerStreet",
        a."PASR_PerArea",
        a."PASR_PerCity",
        a."PASR_PerPincode",
        a."PASR_FatherName",
        a."PASR_FatherMobleNo",
        a."PASR_MotherMobleNo",
        a."PASR_emailId",
        a."PASR_FatherHomePhNo",
        a."PASR_FatherOfficePhNo",
        b."IVRMMC_Id",
        b."IVRMMC_CountryName",
        c."IVRMMS_Id",
        c."IVRMMS_Name",
        d."ASMCL_ClassName",
        e."TRMR_Id",
        e."TRMR_RouteName",
        f."TRML_Id",
        f."TRML_LocationName",
        a."PASR_BloodGroup",
        g."CreatedDate"
    FROM "Preadmission_School_Registration" a
    INNER JOIN "IVRM_Master_Country" b ON a."PASR_ConCountry" = b."IVRMMC_Id"
    INNER JOIN "IVRM_Master_State" c ON a."PASR_ConState" = c."IVRMMS_Id"
    INNER JOIN "Adm_School_M_Class" d ON a."ASMCL_Id" = d."ASMCL_Id"
    INNER JOIN "TRN"."TR_Master_Route" e ON g."PASTA_PickUp_TRMR_Id" = e."TRMR_Id"
    INNER JOIN "TRN"."TR_Master_Location" f ON g."PASTA_PickUp_TRML_Id" = f."TRML_Id"
    INNER JOIN "PA_Student_Transport_Application" g ON a."PASR_Id" = g."PASR_Id"
    WHERE a."PASR_Id" = "pasr"::BIGINT
        AND a."MI_Id" = "mi_id";
END;
$$;