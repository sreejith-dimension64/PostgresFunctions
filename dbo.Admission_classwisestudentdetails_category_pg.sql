CREATE OR REPLACE FUNCTION "Admission_classwisestudentdetails_category"(
    p_year TEXT,
    p_class TEXT,
    p_tablepara TEXT,
    p_flag TEXT,
    p_mi_id TEXT,
    p_sec TEXT,
    p_AMC_Id TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlall TEXT;
    v_pre_yr_id TEXT;
    v_last_id INTEGER;
    v_last_id_num INTEGER;
    v_category TEXT;
    v_WHERECONDITION TEXT;
BEGIN

    IF (p_AMC_Id != '0' AND p_AMC_Id != '') THEN
        v_category := 'and "Adm_M_Category"."AMC_Id" =' || p_AMC_Id || '';
    ELSE
        v_category := '';
    END IF;

    SELECT "ASMAY_Order" INTO v_last_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Id" = p_year::INTEGER;
    
    RAISE NOTICE '%', v_last_id;
    
    v_last_id_num := v_last_id - 1;
    
    RAISE NOTICE '%', v_last_id;
    
    SELECT "ASMAY_Id" INTO v_pre_yr_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Order" = v_last_id_num 
    AND "MI_Id" = p_mi_id::INTEGER;

    IF p_class = '0' THEN
        v_WHERECONDITION := 'SELECT "ASMCL_Id" FROM "Adm_School_M_Class" WHERE "MI_Id"=' || p_mi_id || ' AND "ASMCL_ActiveFlag"=1';
    ELSE
        v_WHERECONDITION := 'SELECT "ASMCL_Id" FROM "Adm_School_M_Class" WHERE "MI_Id"=' || p_mi_id || ' AND "ASMCL_Id"=' || p_class || ' AND "ASMCL_ActiveFlag"=1';
    END IF;

    IF p_flag = 'newad' THEN
        IF p_sec = '0' THEN
            v_sqlall := 'SELECT DISTINCT ' || p_tablepara || ' FROM "Adm_M_Student" 
INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_M_Student"."amc_id"
INNER JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
WHERE "Adm_M_Student"."ASMAY_Id" = ' || p_year || '
AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
AND "Adm_M_Student"."ASMCL_Id" IN (' || v_WHERECONDITION || ')
AND "Adm_M_Student"."AMST_SOL" = ''S''
AND "Adm_M_Student"."AMST_ActiveFlag" = 1 ' || v_category || '
AND "Adm_School_Y_Student"."amay_activeflag" = 1';
        ELSE
            v_sqlall := 'SELECT DISTINCT ' || p_tablepara || ' FROM "Adm_M_Student" 
INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_M_Student"."amc_id"
INNER JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
WHERE "Adm_M_Student"."ASMAY_Id" = ' || p_year || '
AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
AND "Adm_M_Student"."ASMCL_Id" IN (' || v_WHERECONDITION || ')
AND "Adm_School_M_Section"."ASMS_Id" = ' || p_sec || '
AND "Adm_M_Student"."AMST_SOL" = ''S''
AND "Adm_M_Student"."AMST_ActiveFlag" = 1 ' || v_category || '
AND "Adm_School_Y_Student"."amay_activeflag" = 1';
        END IF;
    END IF;

    IF p_flag = 'totstd' THEN
        IF p_sec = '0' THEN
            v_sqlall := 'SELECT DISTINCT ' || p_tablepara || ' FROM "Adm_M_Student" 
INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
LEFT JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
LEFT JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
LEFT JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
LEFT JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
LEFT JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || v_WHERECONDITION || ')
AND ("Adm_M_Student"."AMST_SOL" = ''S'')
AND "Adm_M_Student"."AMST_ActiveFlag" = 1 ' || v_category || '
AND "Adm_School_Y_Student"."amay_activeflag" = 1';
        ELSE
            v_sqlall := 'SELECT DISTINCT ' || p_tablepara || ' FROM "Adm_M_Student" 
INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
LEFT JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
LEFT JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
LEFT JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
LEFT JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
LEFT JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
LEFT JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || v_WHERECONDITION || ')
AND "Adm_School_Y_Student"."ASMS_Id" = ' || p_sec || '
AND ("Adm_M_Student"."AMST_SOL" = ''S'')
AND "Adm_M_Student"."AMST_ActiveFlag" = 1 ' || v_category || '
AND "Adm_School_Y_Student"."amay_activeflag" = 1';
        END IF;
    END IF;

    IF p_flag = 'prom' THEN
        IF p_sec = '0' THEN
            v_sqlall := 'SELECT DISTINCT ' || p_tablepara || ' FROM "Adm_M_Student" 
INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
INNER JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || v_WHERECONDITION || ')
AND "Adm_M_Student"."AMST_SOL" = ''S''
AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
AND "Adm_M_Student"."AMST_ActiveFlag" = 1 ' || v_category || '
AND "Adm_School_Y_Student"."AMST_Id" IN 
(SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" FROM "ADM_M_STUDENT" 
INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID"
WHERE "ADM_M_STUDENT"."ASMAY_Id" = ' || v_pre_yr_id || ')
AND "Adm_School_Y_Student"."AMST_Id" NOT IN 
(SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" FROM "ADM_M_STUDENT" 
INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id")';
        ELSE
            v_sqlall := 'SELECT DISTINCT ' || p_tablepara || ' FROM "Adm_M_Student" 
INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
INNER JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || v_WHERECONDITION || ')
AND "Adm_School_Y_Student"."ASMS_Id" = ' || p_sec || '
AND "Adm_M_Student"."AMST_SOL" = ''S''
AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
AND "Adm_M_Student"."AMST_ActiveFlag" = 1 ' || v_category || '
AND "Adm_School_Y_Student"."AMST_Id" IN 
(SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" FROM "ADM_M_STUDENT" 
INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID"
WHERE "ADM_M_STUDENT"."ASMAY_Id" = ' || v_pre_yr_id || ')
AND "Adm_School_Y_Student"."AMST_Id" NOT IN 
(SELECT DISTINCT "ADM_M_STUDENT"."AMST_ID" FROM "ADM_M_STUDENT" 
INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id")';
        END IF;
    END IF;

    IF p_flag = 'yrloss' THEN
        DROP TABLE IF EXISTS "LastAccClassStudents";
        
        CREATE TEMP TABLE "LastAccClassStudents" AS
        SELECT "Adm_School_Y_Student"."AMST_Id", "Adm_School_Y_Student"."ASMCL_Id"
        FROM "ADM_M_STUDENT"
        INNER JOIN "Adm_School_Y_Student" ON "ADM_M_STUDENT"."AMST_ID" = "Adm_School_Y_Student"."AMST_ID"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = v_pre_yr_id::INTEGER 
        AND "Adm_School_M_Class"."MI_Id" = p_mi_id::INTEGER
        AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1 
        AND "Adm_M_Student"."AMST_ActiveFlag" = 1
        AND "Adm_M_Student"."AMST_SOL" = 'S';
        
        IF p_sec = '0' THEN
            v_sqlall := 'SELECT DISTINCT ' || p_tablepara || ' FROM "Adm_M_Student" 
INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "LastAccClassStudents" L ON L."AMST_Id" = "Adm_School_Y_Student"."AMST_ID" AND L."asmcl_id" = "Adm_School_Y_Student"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
INNER JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "Adm_M_Student"."AMST_Nationality"
LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
WHERE "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || p_year || '
AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || v_WHERECONDITION || ')
AND "Adm_School_M_Academic_Year"."MI_Id" = ' || p_mi_id || '
AND "Adm_M_Student"."AMST_SOL" = ''S''
AND "Adm_M_Student"."AMST_ActiveFlag" = 1
AND "Adm_School_Y_Student"."amay_activeflag" = 1 ' || v_category;
        ELSE
            v_sqlall := 'SELECT DISTINCT ' || p_tablepara || ' FROM "Adm_M_Student" 
INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
INNER JOIN "LastAccClassStudents" L ON L."AMST_Id" = "Adm_School_Y_Student"."AMST_ID" AND L."asmcl_id" = "Adm_School_Y_Student"."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ON "Adm_School_M_Class_Category"."asmcc_id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" ON "Adm_M_Category"."amc_id" = "Adm_School_M_Class_Category"."amc_id"
INNER JOIN "IVRM_master_Caste" ON "Adm_M_Student"."IC_Id" = "IVRM_Master_Caste"."IMC_Id"
LEFT OUTER JOIN "IVRM_Master_Caste_Category" ON "Adm_M_Student"."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id"
LEFT OUTER JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "I