CREATE OR REPLACE FUNCTION "dbo"."Adm_EndorsementData_EmailParameters"(
    "yearId" TEXT,
    "classid" TEXT,
    "studid" TEXT,
    "mi_id" TEXT,
    "CAUTION_AMT" VARCHAR(10),
    "DEMAND_AMT" VARCHAR(10),
    "BROUGHT_ADMISSION" VARCHAR(10),
    "SELECTED_DATE" VARCHAR(10),
    "FROM_TIME" VARCHAR(10),
    "FROM_BTW_TIME" VARCHAR(10),
    "TO_BTW_TIME" VARCHAR(10),
    "FIRST_INSTALLMENT" VARCHAR(10),
    "PAID_ONOR_BEFORE" VARCHAR(10)
)
RETURNS TABLE(
    "[STUDENT_NAME]" TEXT,
    "[CLASS]" TEXT,
    "[PROSPECTUS_NO]" TEXT,
    "[STREET]" TEXT,
    "[AREA]" TEXT,
    "[CITY]" TEXT,
    "[COUNTRY]" TEXT,
    "[PINCODE]" TEXT,
    "[CASTE]" TEXT,
    "[FIRST_INSTALLMENT]" VARCHAR(10),
    "[PAID_ONOR_BEFORE]" VARCHAR(10),
    "[CAUTION_AMT]" VARCHAR(10),
    "[DEMAND_AMT]" VARCHAR(10),
    "[BROUGHT_ADMISSION]" VARCHAR(10),
    "[DATE]" VARCHAR(10),
    "[BEFORE_TIME]" VARCHAR(10),
    "[BTW_FROM_TIME]" VARCHAR(10),
    "[BTW_TO_TIME]" VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT 
    CASE WHEN "Adm_M_Student"."AMST_FirstName" IS NULL OR "Adm_M_Student"."AMST_FirstName" = '' THEN '' ELSE "Adm_M_Student"."AMST_FirstName" END ||
    CASE WHEN "Adm_M_Student"."AMST_MiddleName" IS NULL OR "Adm_M_Student"."AMST_MiddleName" = '' OR "Adm_M_Student"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_MiddleName" END ||
    CASE WHEN "Adm_M_Student"."AMST_LastName" IS NULL OR "Adm_M_Student"."AMST_LastName" = '' OR "Adm_M_Student"."AMST_LastName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_LastName" END AS "[STUDENT_NAME]",
    "Adm_School_M_Class"."ASMCL_ClassName" AS "[CLASS]",
    "PSR"."PASP_ProspectusNo" AS "[PROSPECTUS_NO]",
    COALESCE("Adm_M_Student"."AMST_PerStreet", '') AS "[STREET]",
    COALESCE("Adm_M_Student"."AMST_PerArea", '') AS "[AREA]",
    COALESCE("Adm_M_Student"."AMST_PerCity", '') AS "[CITY]",
    COALESCE("IVRM_Master_Country"."IVRMMC_CountryName", '') AS "[COUNTRY]",
    "Adm_M_Student"."AMST_PerPincode" AS "[PINCODE]",
    "IVRM_Master_Caste"."IMC_CasteName" AS "[CASTE]",
    "FIRST_INSTALLMENT" AS "[FIRST_INSTALLMENT]",
    "PAID_ONOR_BEFORE" AS "[PAID_ONOR_BEFORE]",
    "CAUTION_AMT" AS "[CAUTION_AMT]",
    "DEMAND_AMT" AS "[DEMAND_AMT]",
    "BROUGHT_ADMISSION" AS "[BROUGHT_ADMISSION]",
    "SELECTED_DATE" AS "[DATE]",
    "FROM_TIME" AS "[BEFORE_TIME]",
    "FROM_BTW_TIME" AS "[BTW_FROM_TIME]",
    "TO_BTW_TIME" AS "[BTW_TO_TIME]"
FROM "Adm_M_Student"
LEFT OUTER JOIN "IVRM_Master_State" ON "Adm_M_Student"."AMST_PerState" = "IVRM_Master_State"."IVRMMS_Id"
INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_PerCountry"
LEFT OUTER JOIN "ivrm_master_caste" ON "ivrm_master_caste"."imc_id" = "Adm_M_Student"."ic_id"
LEFT OUTER JOIN "IVRM_Master_Religion" ON "IVRM_Master_Religion"."IVRMMR_Id" = "Adm_M_Student"."IVRMMR_Id"
INNER JOIN "Adm_Master_Student_PA" "AMPA" ON "AMPA"."AMST_Id" = "Adm_M_Student"."AMST_Id"
INNER JOIN "PA_School_Application_Prospectus" "PAAP" ON "PAAP"."PASR_Id" = "AMPA"."PASR_Id"
INNER JOIN "Preadmission_School_Prospectus" "PSR" ON "PSR"."PASP_Id" = "PAAP"."PASP_Id"
WHERE "Adm_School_Y_Student"."AMST_Id" = "studid"
  AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "yearId"
  AND "Adm_M_Student"."MI_Id" = "mi_id"
  AND "Adm_M_Student"."ASMCL_Id" = "classid"
  AND "Adm_M_Student"."AMST_ActiveFlag" = 1
  AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1

UNION

SELECT 
    CASE WHEN "Adm_M_Student"."AMST_FirstName" IS NULL OR "Adm_M_Student"."AMST_FirstName" = '' THEN '' ELSE "Adm_M_Student"."AMST_FirstName" END ||
    CASE WHEN "Adm_M_Student"."AMST_MiddleName" IS NULL OR "Adm_M_Student"."AMST_MiddleName" = '' OR "Adm_M_Student"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_MiddleName" END ||
    CASE WHEN "Adm_M_Student"."AMST_LastName" IS NULL OR "Adm_M_Student"."AMST_LastName" = '' OR "Adm_M_Student"."AMST_LastName" = '0' THEN '' ELSE ' ' || "Adm_M_Student"."AMST_LastName" END AS "[STUDENT_NAME]",
    "Adm_School_M_Class"."ASMCL_ClassName" AS "[CLASS]",
    '' AS "[PROSPECTUS_NO]",
    COALESCE("Adm_M_Student"."AMST_PerStreet", '') AS "[STREET]",
    COALESCE("Adm_M_Student"."AMST_PerArea", '') AS "[AREA]",
    COALESCE("Adm_M_Student"."AMST_PerCity", '') AS "[CITY]",
    COALESCE("IVRM_Master_Country"."IVRMMC_CountryName", '') AS "[COUNTRY]",
    "Adm_M_Student"."AMST_PerPincode" AS "[PINCODE]",
    "IVRM_Master_Caste"."IMC_CasteName" AS "[CASTE]",
    "FIRST_INSTALLMENT" AS "[FIRST_INSTALLMENT]",
    "PAID_ONOR_BEFORE" AS "[PAID_ONOR_BEFORE]",
    "CAUTION_AMT" AS "[CAUTION_AMT]",
    "DEMAND_AMT" AS "[DEMAND_AMT]",
    "BROUGHT_ADMISSION" AS "[BROUGHT_ADMISSION]",
    "SELECTED_DATE" AS "[DATE]",
    "FROM_TIME" AS "[BEFORE_TIME]",
    "FROM_BTW_TIME" AS "[BTW_FROM_TIME]",
    "TO_BTW_TIME" AS "[BTW_TO_TIME]"
FROM "Adm_M_Student"
LEFT OUTER JOIN "IVRM_Master_State" ON "Adm_M_Student"."AMST_PerState" = "IVRM_Master_State"."IVRMMS_Id"
INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_PerCountry"
LEFT OUTER JOIN "ivrm_master_caste" ON "ivrm_master_caste"."imc_id" = "Adm_M_Student"."ic_id"
LEFT OUTER JOIN "IVRM_Master_Religion" ON "IVRM_Master_Religion"."IVRMMR_Id" = "Adm_M_Student"."IVRMMR_Id"
WHERE "Adm_School_Y_Student"."AMST_Id" = "studid"
  AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "yearId"
  AND "Adm_M_Student"."MI_Id" = "mi_id"
  AND "Adm_M_Student"."ASMCL_Id" = "classid"
  AND "Adm_M_Student"."AMST_ActiveFlag" = 1
  AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1;

END;
$$;