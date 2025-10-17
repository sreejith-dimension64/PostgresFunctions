CREATE OR REPLACE FUNCTION dbo."Buspass_Form_details_onload"(
    p_amst BIGINT,
    p_asmay BIGINT,
    p_mi_id BIGINT
)
RETURNS TABLE(
    "AMST_FirstName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMST_BloodGroup" VARCHAR,
    "AMST_PerStreet" VARCHAR,
    "AMST_PerArea" VARCHAR,
    "AMST_PerCity" VARCHAR,
    "AMST_PerPincode" VARCHAR,
    "AMST_DOB" TIMESTAMP,
    "AMST_MobileNo" VARCHAR,
    "AMST_emailId" VARCHAR,
    "IVRMMC_CountryName" VARCHAR,
    "IVRMMS_Name" VARCHAR,
    "AMST_FatherName" VARCHAR,
    "AMST_MotherName" VARCHAR,
    "ASTA_FatherMobileNo" VARCHAR,
    "ASTA_MotherMobileNo" VARCHAR,
    "AMST_FatherOfficeAdd" VARCHAR,
    "ASTA_AreaZoneName" VARCHAR,
    "ASTA_PickUp_TRMR_Id" BIGINT,
    "ASTA_PickUp_TRML_Id" BIGINT,
    "ASTA_Drop_TRMR_Id" BIGINT,
    "ASTA_Drop_TRML_Id" BIGINT,
    "ASTA_Landmark" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (ams."AMST_FirstName" || ' ' || ams."AMST_MiddleName" || ' ' || ams."AMST_LastName") AS "AMST_FirstName",
        ams."AMST_AdmNo",
        ams."AMST_BloodGroup",
        ams."AMST_PerStreet",
        ams."AMST_PerArea",
        ams."AMST_PerCity",
        ams."AMST_PerPincode",
        ams."AMST_DOB",
        ams."AMST_MobileNo",
        ams."AMST_emailId",
        imc."IVRMMC_CountryName",
        ims."IVRMMS_Name",
        ams."AMST_FatherName",
        ams."AMST_MotherName",
        asta."ASTA_FatherMobileNo",
        asta."ASTA_MotherMobileNo",
        ams."AMST_FatherOfficeAdd",
        asta."ASTA_AreaZoneName",
        asta."ASTA_PickUp_TRMR_Id",
        asta."ASTA_PickUp_TRML_Id",
        asta."ASTA_Drop_TRMR_Id",
        asta."ASTA_Drop_TRML_Id",
        asta."ASTA_Landmark"
    FROM 
        dbo."IVRM_Master_State" ims
        INNER JOIN dbo."Adm_M_Student" ams 
            INNER JOIN dbo."Adm_Student_Transport_Application" asta
                INNER JOIN dbo."Adm_School_Y_Student" asys 
                    ON asta."AMST_Id" = asys."AMST_Id" 
                    AND asta."ASTA_CurrentClass" = asys."ASMCL_Id"
                ON ams."AMST_Id" = asta."AMST_Id"
            INNER JOIN dbo."Adm_School_M_Class" asmc 
                ON asys."ASMCL_Id" = asmc."ASMCL_Id"
            INNER JOIN dbo."Adm_School_M_Academic_Year" asmay 
                ON asys."ASMAY_Id" = asmay."ASMAY_Id"
            INNER JOIN dbo."IVRM_Master_Country" imc 
                ON ams."AMST_PerCountry" = imc."IVRMMC_Id"
            ON ims."IVRMMS_Id" = ams."AMST_PerState" 
            AND ims."IVRMMC_Id" = imc."IVRMMC_Id"
    WHERE 
        asta."MI_Id" = p_mi_id 
        AND asys."AMST_Id" = p_amst 
        AND asta."ASTA_CurrentAY" = p_asmay;
END;
$$;