CREATE OR REPLACE FUNCTION "dbo"."AdhaarNotEnteredList" (
    "ASMAY_ID" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "mi_id" TEXT
)
RETURNS TABLE (
    "AMST_Id" INTEGER,
    "AMST_AdmNo" VARCHAR,
    "AMST_AadharNo" BIGINT,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "Amst_LastName" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMAY_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN
    "query" := 'SELECT "Adm_M_Student"."AMST_Id", 
                       "Adm_M_Student"."AMST_AdmNo", 
                       "Adm_M_Student"."AMST_AadharNo",
                       "Adm_M_Student"."AMST_RegistrationNo", 
                       COALESCE("Adm_M_Student"."AMST_FirstName", '''') as "AMST_FirstName",       
                       COALESCE("Adm_M_Student"."AMST_MiddleName", '''') as "AMST_MiddleName",
                       COALESCE("Adm_M_Student"."Amst_LastName", '''') as "Amst_LastName",     
                       "Adm_School_M_Class"."ASMCL_ClassName",       
                       "Adm_School_M_Section"."ASMC_SectionName", 
                       "Adm_School_Y_Student"."ASMAY_Id"      
                FROM "dbo"."Adm_School_Y_Student" 
                INNER JOIN "dbo"."Adm_M_Student" 
                    ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                INNER JOIN "dbo"."Adm_School_M_Class" 
                    ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
                INNER JOIN "dbo"."Adm_School_M_Section" 
                    ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"      
                WHERE ("Adm_M_Student"."AMST_SOL" = ''S'')    
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || '
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1    
                AND "Adm_School_Y_Student"."amay_activeflag" = 1    
                AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || '  
                AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || "ASMCL_Id" || ')
                AND "Adm_School_Y_Student"."ASMS_Id" IN (' || "ASMS_Id" || ')
                AND ("Adm_M_Student"."AMST_AadharNo" = 0 OR "Adm_M_Student"."AMST_AadharNo" IS NULL)';

    RETURN QUERY EXECUTE "query";
END;
$$;