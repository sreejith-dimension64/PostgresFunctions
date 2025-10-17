CREATE OR REPLACE FUNCTION "Admission_classwisestudentdetails_bkp" (
    "year" TEXT,
    "class" TEXT,
    "tablepara" TEXT,
    "flag" TEXT,
    "mi_id" TEXT,
    "sec" TEXT
)
RETURNS SETOF RECORD
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
    WHERE "ASMAY_Id" = "year";
    
    RAISE NOTICE '%', "last_id";
    
    "last_id_num" := CAST(SUBSTRING("last_id", 1, 4) AS INTEGER);
    "last_id" := CAST(("last_id_num" - 1) AS VARCHAR) || '-' || CAST("last_id_num" AS VARCHAR);
    
    RAISE NOTICE '%', "last_id";
    
    SELECT "Asmay_id" INTO "pre_yr_id" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Year" LIKE "last_id" AND "MI_Id" = "mi_id";
    
    IF "flag" = 'newad' THEN
        
        IF "sec" = '0' THEN
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "Adm_M_Student" INNER JOIN "Adm_School_Y_Student"
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class"
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
            LEFT JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
            LEFT JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            LEFT JOIN "IVRM_Master_District" ON "IVRM_Master_District"."IVRMMD_Id" = "Adm_M_Student"."AMST_PerDistrict"
            WHERE "Adm_M_Student"."ASMAY_Id" = ' || "year" || '
            AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_M_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1';
            
        ELSE
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "Adm_M_Student" INNER JOIN "Adm_School_Y_Student"
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class"
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
            LEFT JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
            LEFT JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            LEFT JOIN "IVRM_Master_District" ON "IVRM_Master_District"."IVRMMD_Id" = "Adm_M_Student"."AMST_PerDistrict"
            WHERE "Adm_M_Student"."ASMAY_Id" = ' || "year" || '
            AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_M_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_School_M_Section"."ASMS_Id" = ' || "sec" || '
            AND "Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1';
            
        END IF;
        
    END IF;
    
    IF "flag" = 'totstd' THEN
        
        IF "sec" = '0' THEN
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "Adm_M_Student" INNER JOIN "Adm_School_Y_Student"
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class"
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            LEFT JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
            LEFT JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            LEFT JOIN "IVRM_Master_District" ON "IVRM_Master_District"."IVRMMD_Id" = "Adm_M_Student"."AMST_PerDistrict"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "year" || '
            AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1';
            
        ELSE
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "Adm_M_Student" INNER JOIN "Adm_School_Y_Student"
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class"
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            LEFT JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
            LEFT JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            LEFT JOIN "IVRM_Master_District" ON "IVRM_Master_District"."IVRMMD_Id" = "Adm_M_Student"."AMST_PerDistrict"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "year" || '
            AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_School_Y_Student"."ASMS_Id" = ' || "sec" || '
            AND "Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1';
            
        END IF;
        
    END IF;
    
    IF "flag" = 'prom' THEN
        
        IF "sec" = '0' THEN
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "Adm_M_Student" INNER JOIN "Adm_School_Y_Student"
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class"
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            LEFT JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
            LEFT JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            LEFT JOIN "IVRM_Master_District" ON "IVRM_Master_District"."IVRMMD_Id" = "Adm_M_Student"."AMST_PerDistrict"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "year" || '
            AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMST_Id" IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" FROM "ADM_M_STUDENT" INNER JOIN
            "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID"
            WHERE "ADM_M_STUDENT"."ASMAY_Id" = ' || "pre_yr_id" || ')
            AND "Adm_School_Y_Student"."AMST_Id" NOT IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" FROM "ADM_M_STUDENT" INNER JOIN
            "Adm_School_Y_Student" ON "ADM_M_STUDENT"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id")';
            
        ELSE
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "Adm_M_Student" INNER JOIN "Adm_School_Y_Student"
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class"
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            LEFT JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
            LEFT JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            LEFT JOIN "IVRM_Master_District" ON "IVRM_Master_District"."IVRMMD_Id" = "Adm_M_Student"."AMST_PerDistrict"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "year" || '
            AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_School_Y_Student"."ASMS_Id" = ' || "sec" || '
            AND "Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."AMST_Id" IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" FROM "ADM_M_STUDENT" INNER JOIN
            "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID"
            WHERE "ADM_M_STUDENT"."ASMAY_Id" = ' || "pre_yr_id" || ')
            AND "Adm_School_Y_Student"."AMST_Id" NOT IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" FROM "ADM_M_STUDENT" INNER JOIN
            "Adm_School_Y_Student" ON "ADM_M_STUDENT"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id")';
            
        END IF;
        
    END IF;
    
    IF "flag" = 'yrloss' THEN
        
        IF "sec" = '0' THEN
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "Adm_M_Student" INNER JOIN "Adm_School_Y_Student"
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class"
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            LEFT JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
            LEFT JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
            LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            LEFT JOIN "IVRM_Master_District" ON "IVRM_Master_District"."IVRMMD_Id" = "Adm_M_Student"."AMST_PerDistrict"
            WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "pre_yr_id" || '
            AND "Adm_School_Y_Student"."ASMCL_Id" = ' || "class" || '
            AND "Adm_School_M_Academic_Year"."MI_Id" = ' || "mi_id" || '
            AND "Adm_M_Student"."AMST_SOL" = ''S''
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1
            AND "Adm_School_Y_Student"."AMST_Id" IN
            (SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" FROM "ADM_M_STUDENT" INNER JOIN
            "Adm_School_Y_Student" ON "ADM_M_STUDENT"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id")';
            
        ELSE
            
            "sqlall" := 'SELECT DISTINCT ' || "tablepara" || ' FROM "Adm_M_Student" INNER JOIN "Adm_School_Y_Student"
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
            INNER JOIN "Adm_School_M_Class"
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            LEFT JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
            LEFT JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
            LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
            LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
            LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
            LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
            LEFT OUTER JOIN "IVR