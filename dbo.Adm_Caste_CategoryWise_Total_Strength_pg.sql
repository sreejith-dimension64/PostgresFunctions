CREATE OR REPLACE FUNCTION "dbo"."Adm_Caste_CategoryWise_Total_Strength"(
    p_ASMAY_Id TEXT,
    p_MI_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_ID TEXT,
    p_IMC_ID TEXT,
    p_ALLORINDI INTEGER,
    p_STUDENTORCASTE INTEGER,
    p_casteorcategory INTEGER,
    p_IMCC_ID TEXT,
    p_STUDENTORCATEGORY INTEGER
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    -- CASTE WISE CONDITION
    IF p_casteorcategory = 2 THEN
        -- ALL CONDITION
        IF p_ALLORINDI = 1 THEN
            -- CASTE CATEGORY WISE
            IF p_STUDENTORCASTE = 1 THEN
                v_sql := 'SELECT c."IMC_CasteName" as caste, COUNT(a."amst_id") as total FROM "Adm_M_Student" a 
                         INNER JOIN "Adm_School_Y_Student" b ON a."amst_id" = b."AMST_Id" 
                         INNER JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = a."IC_Id" 
                         WHERE a."MI_Id" = ' || p_MI_Id || ' AND a."AMST_SOL" = ''S'' AND a."AMST_ActiveFlag" = 1 
                         AND b."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = ' || p_ASMAY_Id || '
                         AND a."IC_Id" IN (' || p_IMC_ID || ')
                         GROUP BY c."IMC_CasteName"';
            -- STUDENT WISE
            ELSE
                v_sql := 'SELECT CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '''' THEN '''' ELSE "AMST_FirstName" END || 
                         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMST_MiddleName" END || 
                         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMST_LastName" END as studentname,
                         c."IMC_CasteName" as caste, d."ASMCL_ClassName" as class, e."ASMC_SectionName" as section 
                         FROM "Adm_M_Student" a 
                         INNER JOIN "Adm_School_Y_Student" b ON a."amst_id" = b."AMST_Id" 
                         INNER JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = a."IC_Id" 
                         INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
                         INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id"
                         WHERE a."MI_Id" = 5 AND a."AMST_SOL" = ''S'' AND a."AMST_ActiveFlag" = 1 AND b."AMAY_ActiveFlag" = 1 
                         AND a."IC_Id" IN (' || p_IMC_ID || ')
                         ORDER BY studentname';
            END IF;
        -- INDIVIDUAL
        ELSE
            -- CASTE WISE
            IF p_STUDENTORCASTE = 1 THEN
                v_sql := 'SELECT c."IMC_CasteName" as caste, COUNT(a."amst_id") as total FROM "Adm_M_Student" a 
                         INNER JOIN "Adm_School_Y_Student" b ON a."amst_id" = b."AMST_Id" 
                         INNER JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = a."IC_Id" 
                         WHERE a."MI_Id" = ' || p_MI_Id || ' AND a."AMST_SOL" = ''S'' AND a."AMST_ActiveFlag" = 1 
                         AND b."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = ' || p_ASMAY_Id || '
                         AND a."IC_Id" IN (' || p_IMC_ID || ') AND b."ASMS_Id" = ' || p_ASMS_ID || ' AND b."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                         GROUP BY c."IMC_CasteName"';
            -- STUDENT WISE
            ELSE
                v_sql := 'SELECT CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '''' THEN '''' ELSE "AMST_FirstName" END || 
                         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMST_MiddleName" END || 
                         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMST_LastName" END as studentname,
                         c."IMC_CasteName" as caste, d."ASMCL_ClassName" as class, e."ASMC_SectionName" as section 
                         FROM "Adm_M_Student" a 
                         INNER JOIN "Adm_School_Y_Student" b ON a."amst_id" = b."AMST_Id" 
                         INNER JOIN "IVRM_Master_Caste" c ON c."IMC_Id" = a."IC_Id" 
                         INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
                         INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id"
                         WHERE a."MI_Id" = ' || p_MI_Id || ' AND a."AMST_SOL" = ''S'' AND a."AMST_ActiveFlag" = 1 
                         AND b."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = ' || p_ASMAY_Id || ' AND b."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                         AND b."ASMS_Id" = ' || p_ASMS_ID || ' AND a."IC_Id" IN (' || p_IMC_ID || ') 
                         ORDER BY studentname';
            END IF;
        END IF;
    -- CATEGORY WISE
    ELSE
        -- ALL CONDITION
        IF p_ALLORINDI = 1 THEN
            -- CATEGORY WISE
            IF p_STUDENTORCATEGORY = 1 THEN
                v_sql := 'SELECT c."IMCC_CategoryName" as category, COUNT(a."amst_id") as total FROM "Adm_M_Student" a 
                         INNER JOIN "adm_school_Y_student" b ON a."amst_id" = b."amst_id" 
                         INNER JOIN "IVRM_Master_Caste_Category" c ON c."IMCC_Id" = a."IMCC_Id" 
                         WHERE b."ASMAY_Id" = ' || p_ASMAY_Id || ' AND a."MI_Id" = ' || p_MI_Id || ' AND a."AMST_SOL" = ''S'' 
                         AND a."AMST_ActiveFlag" = 1 AND b."AMAY_ActiveFlag" = 1 AND a."IMCC_Id" IN (' || p_IMCC_ID || ') 
                         GROUP BY "IMCC_CategoryName" ORDER BY "IMCC_CategoryName"';
            ELSE
                v_sql := 'SELECT CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '''' THEN '''' ELSE "AMST_FirstName" END || 
                         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMST_MiddleName" END || 
                         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMST_LastName" END as studentname,
                         c."IMCC_CategoryName" as category, d."ASMCL_ClassName" as class, e."ASMC_SectionName" as section 
                         FROM "Adm_M_Student" a 
                         INNER JOIN "Adm_School_Y_Student" b ON a."amst_id" = b."AMST_Id" 
                         INNER JOIN "ivrm_master_caste_category" c ON c."IMCC_Id" = a."IMCC_Id" 
                         INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
                         INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" 
                         WHERE b."ASMAY_Id" = ' || p_ASMAY_Id || ' AND a."MI_Id" = ' || p_MI_Id || ' AND a."AMST_SOL" = ''S'' 
                         AND a."AMST_ActiveFlag" = 1 AND b."AMAY_ActiveFlag" = 1 AND a."IMCC_Id" IN (' || p_IMCC_ID || ') 
                         ORDER BY studentname';
            END IF;
        -- INDIVIDUAL
        ELSE
            IF p_STUDENTORCATEGORY = 1 THEN
                v_sql := 'SELECT c."IMCC_CategoryName" as category, COUNT(a."amst_id") as total FROM "Adm_M_Student" a 
                         INNER JOIN "adm_school_Y_student" b ON a."amst_id" = b."amst_id" 
                         INNER JOIN "IVRM_Master_Caste_Category" c ON c."IMCC_Id" = a."IMCC_Id" 
                         WHERE b."ASMAY_Id" = ' || p_ASMAY_Id || ' AND a."MI_Id" = ' || p_MI_Id || ' AND a."AMST_SOL" = ''S'' 
                         AND a."AMST_ActiveFlag" = 1 AND b."AMAY_ActiveFlag" = 1 AND a."IMCC_Id" IN (' || p_IMCC_ID || ') 
                         AND b."ASMS_Id" = ' || p_ASMS_ID || ' AND b."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                         GROUP BY "IMCC_CategoryName" ORDER BY "IMCC_CategoryName"';
            ELSE
                v_sql := 'SELECT CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '''' THEN '''' ELSE "AMST_FirstName" END || 
                         CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMST_MiddleName" END || 
                         CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMST_LastName" END as studentname,
                         c."IMCC_CategoryName" as category, d."ASMCL_ClassName" as class, e."ASMC_SectionName" as section 
                         FROM "Adm_M_Student" a 
                         INNER JOIN "Adm_School_Y_Student" b ON a."amst_id" = b."AMST_Id" 
                         INNER JOIN "ivrm_master_caste_category" c ON c."IMCC_Id" = a."IMCC_Id" 
                         INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
                         INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" 
                         WHERE b."ASMAY_Id" = ' || p_ASMAY_Id || ' AND a."MI_Id" = ' || p_MI_Id || ' AND a."AMST_SOL" = ''S'' 
                         AND a."AMST_ActiveFlag" = 1 AND b."AMAY_ActiveFlag" = 1 AND a."IMCC_Id" IN (' || p_IMCC_ID || ') 
                         AND b."ASMS_Id" = ' || p_ASMS_ID || ' AND b."ASMCL_Id" = ' || p_ASMCL_Id || ' 
                         ORDER BY studentname';
            END IF;
        END IF;
    END IF;

    RETURN QUERY EXECUTE v_sql;
END;
$$;