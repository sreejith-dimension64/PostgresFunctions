CREATE OR REPLACE FUNCTION "Admission_classwisestudentdetails"(
    p_year TEXT,
    p_class TEXT,
    p_tablepara TEXT,
    p_flag TEXT,
    p_mi_id TEXT,
    p_sec TEXT,
    p_concessionid TEXT
)
RETURNS TABLE(
    serial_num BIGINT,
    data_columns TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlall TEXT;
    v_pre_yr_id TEXT;
    v_last_id TEXT;
    v_last_id_num INTEGER;
BEGIN
    
    SELECT "ASMAY_Year" INTO v_last_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Id" = p_year::INTEGER;
    
    v_last_id_num := CAST(SUBSTRING(v_last_id, 1, 4) AS INTEGER);
    v_last_id := CAST((v_last_id_num - 1) AS VARCHAR) || '-' || CAST(v_last_id_num AS VARCHAR);
    
    SELECT "Asmay_id" INTO v_pre_yr_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Year" LIKE v_last_id 
    AND "MI_Id" = p_mi_id::INTEGER;
    
    IF p_flag = 'newad' THEN
        
        IF p_sec = '0' THEN
            
            v_sqlall := 'SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS serial_num, * FROM (
                SELECT DISTINCT ' || p_tablepara || ' 
                FROM "Adm_M_Student" 
                INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                    AND "Adm_School_Y_Student"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
                INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
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
                LEFT JOIN "SPC"."SPCC_Student_House" "Student_House" ON "Student_House"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                    AND "Student_House"."ASMAY_Id" = "Adm_School_Y_Student"."AMST_Id"
                LEFT JOIN "SPC"."SPCC_Master_House" "SPCC_Master_House" ON "SPCC_Master_House"."SPCCMH_Id" = "Student_House"."SPCCMH_Id"
                INNER JOIN "Fee_Master_Concession" ON "Fee_Master_Concession"."FMCC_Id" = "Adm_M_Student"."AMST_Concession_Type"
                WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
                AND "Adm_M_Student"."ASMCL_Id" IN (' || p_class || ')
                AND "Adm_School_M_Section"."ASMS_Id" IN (' || p_sec || ')
                AND "Adm_M_Student"."AMST_SOL" = ''S''
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."amay_activeflag" = 1
                AND (' || p_concessionid || ' = 0 OR "FMCC_Id" = ' || p_concessionid || ')
            ) AS dd';
            
        ELSE
            
            IF p_concessionid::INTEGER > 0 THEN
                v_sqlall := 'SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS serial_num, * FROM (
                    SELECT DISTINCT ' || p_tablepara || ' 
                    FROM "Adm_M_Student" 
                    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                        AND "Adm_School_Y_Student"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
                    INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
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
                    LEFT JOIN "SPC"."SPCC_Student_House" "Student_House" ON "Student_House"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                        AND "Student_House"."ASMAY_Id" = "Adm_School_Y_Student"."AMST_Id"
                    LEFT JOIN "SPC"."SPCC_Master_House" "SPCC_Master_House" ON "SPCC_Master_House"."SPCCMH_Id" = "Student_House"."SPCCMH_Id"
                    INNER JOIN "Fee_Master_Concession" ON "Fee_Master_Concession"."FMCC_Id" = "Adm_M_Student"."AMST_Concession_Type"
                    WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                    AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
                    AND "Adm_M_Student"."ASMCL_Id" IN (' || p_class || ')
                    AND "Adm_School_M_Section"."ASMS_Id" IN (' || p_sec || ')
                    AND "Adm_M_Student"."AMST_SOL" = ''S''
                    AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                    AND "Adm_School_Y_Student"."amay_activeflag" = 1
                    AND (' || p_concessionid || ' = 0 OR "FMCC_Id" = ' || p_concessionid || ')
                ) AS dd';
            ELSE
                v_sqlall := 'SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS serial_num, * FROM (
                    SELECT DISTINCT ' || p_tablepara || ' 
                    FROM "Adm_M_Student" 
                    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                        AND "Adm_School_Y_Student"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
                    INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
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
                    LEFT JOIN "SPC"."SPCC_Student_House" "Student_House" ON "Student_House"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                        AND "Student_House"."ASMAY_Id" = "Adm_School_Y_Student"."AMST_Id"
                    LEFT JOIN "SPC"."SPCC_Master_House" "SPCC_Master_House" ON "SPCC_Master_House"."SPCCMH_Id" = "Student_House"."SPCCMH_Id"
                    INNER JOIN "Fee_Master_Concession" ON "Fee_Master_Concession"."FMCC_Id" = "Adm_M_Student"."AMST_Concession_Type"
                    WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                    AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
                    AND "Adm_M_Student"."ASMCL_Id" IN (' || p_class || ')
                    AND "Adm_School_M_Section"."ASMS_Id" IN (' || p_sec || ')
                    AND "Adm_M_Student"."AMST_SOL" = ''S''
                    AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                    AND "Adm_School_Y_Student"."amay_activeflag" = 1
                ) AS dd';
            END IF;
        END IF;
        
    ELSIF p_flag = 'totstd' THEN
        
        IF p_sec = '0' THEN
            v_sqlall := 'SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS serial_num, * FROM (
                SELECT DISTINCT ' || p_tablepara || ' 
                FROM "Adm_M_Student" 
                INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                    AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
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
                LEFT JOIN "SPC"."SPCC_Student_House" "Student_House" ON "Student_House"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                    AND "Student_House"."ASMAY_Id" = "Adm_School_Y_Student"."AMST_Id"
                LEFT JOIN "SPC"."SPCC_Master_House" "SPCC_Master_House" ON "SPCC_Master_House"."SPCCMH_Id" = "Student_House"."SPCCMH_Id"
                INNER JOIN "Fee_Master_Concession" ON "Fee_Master_Concession"."FMCC_Id" = "Adm_M_Student"."AMST_Concession_Type"
                WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
                AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || p_class || ')
                AND "Adm_School_M_Section"."ASMS_Id" IN (' || p_sec || ')
                AND "Adm_M_Student"."AMST_SOL" = ''S''
                AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                AND "Adm_School_Y_Student"."amay_activeflag" = 1
                AND (' || p_concessionid || ' = 0 OR "FMCC_Id" = ' || p_concessionid || ')
            ) AS dd';
        ELSE
            IF p_concessionid::INTEGER > 0 THEN
                v_sqlall := 'SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS serial_num, * FROM (
                    SELECT DISTINCT ' || p_tablepara || ' 
                    FROM "Adm_M_Student" 
                    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                        AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                    INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
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
                    LEFT JOIN "SPC"."SPCC_Student_House" "Student_House" ON "Student_House"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                        AND "Student_House"."ASMAY_Id" = "Adm_School_Y_Student"."AMST_Id"
                    LEFT JOIN "SPC"."SPCC_Master_House" "SPCC_Master_House" ON "SPCC_Master_House"."SPCCMH_Id" = "Student_House"."SPCCMH_Id"
                    INNER JOIN "Fee_Master_Concession" ON "Fee_Master_Concession"."FMCC_Id" = "Adm_M_Student"."AMST_Concession_Type"
                    WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                    AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
                    AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || p_class || ')
                    AND "Adm_School_Y_Student"."ASMS_Id" IN (' || p_sec || ')
                    AND "Adm_M_Student"."AMST_SOL" = ''S''
                    AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                    AND "Adm_School_Y_Student"."amay_activeflag" = 1
                    AND (' || p_concessionid || ' = 0 OR "FMCC_Id" = ' || p_concessionid || ')
                ) AS dd';
            ELSE
                v_sqlall := 'SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS serial_num, * FROM (
                    SELECT DISTINCT ' || p_tablepara || ' 
                    FROM "Adm_M_Student" 
                    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                        AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                    INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
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
                    LEFT JOIN "SPC"."SPCC_Student_House" "Student_House" ON "Student_House"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                        AND "Student_House"."ASMAY_Id" = "Adm_School_Y_Student"."AMST_Id"
                    LEFT JOIN "SPC"."SPCC_Master_House" "SPCC_Master_House" ON "SPCC_Master_House"."SPCCMH_Id" = "Student_House"."SPCCMH_Id"
                    INNER JOIN "Fee_Master_Concession" ON "Fee_Master_Concession"."FMCC_Id" = "Adm_M_Student"."AMST_Concession_Type"
                    WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                    AND "Adm_M_Student"."MI_Id" = ' || p_mi_id || '
                    AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || p_class || ')
                    AND "Adm_School_Y_Student"."ASMS_Id" IN (' || p_sec || ')
                    AND "Adm_M_Student"."AMST_SOL" = ''S''
                    AND "Adm_M_Student"."AMST_ActiveFlag" = 1
                    AND "Adm_School_Y_Student"."amay_activeflag" = 1
                ) AS dd';
            END IF;
        END IF;
        
    ELSIF p_flag = 'prom' THEN
        
        IF p_sec = '0' THEN
            v_sqlall := 'SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS serial_num, * FROM (
                SELECT DISTINCT ' || p_tablepara || ' 
                FROM "Adm_M_Student" 
                INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
                    AND "Adm_School_Y_Student"."ASMAY_Id" = ' || p_year || '
                INNER JOIN "Adm_School_M_Class