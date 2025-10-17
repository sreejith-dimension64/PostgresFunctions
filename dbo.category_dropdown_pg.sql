CREATE OR REPLACE FUNCTION "dbo"."category_dropdown"(
    "MIID" integer
)
RETURNS TABLE(
    "IMC_CasteName" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT "dbo"."IVRM_Master_Caste"."IMC_CasteName"
    FROM "dbo"."Adm_M_Student" 
    INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_Y_Student"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" 
    INNER JOIN "dbo"."Adm_M_Category" ON "dbo"."Adm_M_Student"."AMC_Id" = "dbo"."Adm_M_Category"."AMC_Id" 
    INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
    INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
    INNER JOIN "dbo"."IVRM_Master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id" 
    WHERE ("dbo"."Adm_School_Y_Student"."AMAY_ActiveFlag" = 1 AND "dbo"."Adm_M_Student"."MI_Id" = "MIID");

END;
$$;