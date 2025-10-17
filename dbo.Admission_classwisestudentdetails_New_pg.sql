CREATE OR REPLACE FUNCTION "dbo"."Admission_classwisestudentdetails_New"(
    "year" TEXT,
    "class" TEXT,
    "tablepara" TEXT,
    "flag" TEXT,
    "mi_id" TEXT,
    "sec" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlall" TEXT;
    "pre_yr_id" TEXT;
    "last_id" VARCHAR(50);
    "last_id_num" INTEGER;
BEGIN
    
    SELECT "ASMAY_Year" INTO "last_id" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Id" = "year"::BIGINT;
    
    RAISE NOTICE '%', "last_id";
    
    "last_id_num" := CAST(SUBSTRING("last_id", 1, 4) AS INTEGER);
    "last_id" := CAST(("last_id_num" - 1) AS VARCHAR) || '-' || CAST("last_id_num" AS VARCHAR);
    
    RAISE NOTICE '%', "last_id";
    
    SELECT "Asmay_id" INTO "pre_yr_id" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Year" LIKE "last_id" 
    AND "MI_Id" = "mi_id"::BIGINT;
    
    IF "flag" = 'newad' THEN
        
        IF "sec" = '0' THEN
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_School_M_Class_Category"."asmcc_id" = "dbo"."Adm_M_Student"."AMC_Id"
            INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            INNER JOIN "dbo"."IVRM_master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "dbo"."Adm_M_Student"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."Adm_M_Student"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            WHERE "Adm_M_Student"."ASMAY_Id" = ' || "year" || '
            AND "dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_M_Student"."ASMCL_Id" = ' || "class" || '
            AND "dbo"."Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1';
            
        ELSE
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_School_M_Class_Category"."asmcc_id" = "dbo"."Adm_M_Student"."AMC_Id"
            INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            INNER JOIN "dbo"."IVRM_master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "dbo"."Adm_M_Student"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."Adm_M_Student"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            WHERE "Adm_M_Student"."ASMAY_Id" = ' || "year" || '
            AND "dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_M_Student"."ASMCL_Id" = ' || "class" || '
            AND "dbo"."Adm_School_M_Section"."ASMS_Id" = ' || "sec" || '
            AND "dbo"."Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1';
            
        END IF;
        
    END IF;
    
    IF "flag" = 'totstd' THEN
        
        IF "sec" = '0' THEN
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_School_M_Class_Category"."asmcc_id" = "dbo"."Adm_M_Student"."AMC_Id"
            INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            INNER JOIN "dbo"."IVRM_master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "dbo"."Adm_M_Student"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."Adm_M_Student"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "year" || '
            AND "dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "dbo"."Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1';
            
        ELSE
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_School_M_Class_Category"."asmcc_id" = "dbo"."Adm_M_Student"."AMC_Id"
            INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            INNER JOIN "dbo"."IVRM_master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "dbo"."Adm_M_Student"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."Adm_M_Student"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "year" || '
            AND "dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_School_Y_Student"."ASMS_Id" = ' || "sec" || '
            AND "dbo"."Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1';
            
        END IF;
        
    END IF;
    
    IF "flag" = 'prom' THEN
        
        IF "sec" = '0' THEN
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_School_M_Class_Category"."asmcc_id" = "dbo"."Adm_M_Student"."AMC_Id"
            INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            INNER JOIN "dbo"."IVRM_master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "dbo"."Adm_M_Student"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."Adm_M_Student"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "year" || '
            AND "dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "dbo"."Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMST_Id" IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" 
             FROM "ADM_M_STUDENT" 
             INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID"
             WHERE "ADM_M_STUDENT"."ASMAY_Id" = ' || "pre_yr_id" || ')
            AND "Adm_School_Y_Student"."AMST_Id" NOT IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" 
             FROM "ADM_M_STUDENT" 
             INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id")';
            
        ELSE
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_School_M_Class_Category"."asmcc_id" = "dbo"."Adm_M_Student"."AMC_Id"
            INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            INNER JOIN "dbo"."IVRM_master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "dbo"."Adm_M_Student"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."Adm_M_Student"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "year" || '
            AND "dbo"."Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_School_Y_Student"."ASMS_Id" = ' || "sec" || '
            AND "dbo"."Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMST_Id" IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" 
             FROM "ADM_M_STUDENT" 
             INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID"
             WHERE "ADM_M_STUDENT"."ASMAY_Id" = ' || "pre_yr_id" || ')
            AND "Adm_School_Y_Student"."AMST_Id" NOT IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" 
             FROM "ADM_M_STUDENT" 
             INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id")';
            
        END IF;
        
    END IF;
    
    IF "flag" = 'yrloss' THEN
        
        IF "sec" = '0' THEN
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_School_M_Class_Category"."asmcc_id" = "dbo"."Adm_M_Student"."AMC_Id"
            INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            INNER JOIN "dbo"."IVRM_master_Caste" ON "dbo"."Adm_M_Student"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "dbo"."Adm_M_Student"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "dbo"."Adm_M_Student"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "pre_yr_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_School_M_Academic_Year"."MI_Id" = ' || "mi_id" || '
            AND "Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1
            AND "Adm_School_Y_Student"."AMST_Id" IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" 
             FROM "ADM_M_STUDENT" 
             INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id")';
            
        ELSE
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "dbo"."Adm_M_Student" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"