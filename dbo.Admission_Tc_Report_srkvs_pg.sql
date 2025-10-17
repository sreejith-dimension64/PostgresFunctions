CREATE OR REPLACE FUNCTION "dbo"."Admission_Tc_Report_srkvs"(
    "p_Asmayid" TEXT,
    "p_allorind" TEXT,
    "p_asmclid" TEXT,
    "p_asmcid" TEXT,
    "p_tableparam" TEXT,
    "p_PermOrtemp" VARCHAR(10),
    "p_mid" TEXT,
    "p_AMC_Id" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sqlText" TEXT;
    "v_category" TEXT;
BEGIN

    IF ("p_AMC_Id" != '0' AND "p_AMC_Id" != '') THEN
        "v_category" := 'and "AMC"."AMC_Id" = ' || "p_AMC_Id" || '';
    ELSE
        "v_category" := '';
    END IF;

    IF "p_allorind" = 'all' AND "p_PermOrtemp" = 'PTC' THEN
        "v_sqlText" := 'SELECT ' || "p_tableparam" || ' ,"ASMCL_Order" , "ASMC_Order" FROM
"dbo"."Adm_Student_TC" 
INNER JOIN "dbo"."Adm_M_Student" "adm" ON "dbo"."Adm_Student_TC"."AMST_Id" = "adm"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_Student_TC"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_Student_TC"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_Student_TC"."MI_Id" = "dbo"."Adm_School_M_Academic_Year"."MI_Id" AND   
"dbo"."Adm_Student_TC"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" 
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "adm"."AMC_Id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id" 
LEFT OUTER JOIN "ivrm_master_state" ON "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
LEFT JOIN "dbo"."IVRM_master_Caste" ON "adm"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "adm"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "adm"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
WHERE "Adm_Student_TC"."mi_Id" = ' || "p_mid" || '  
AND "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "p_Asmayid" || ' 
AND "dbo"."Adm_Student_TC"."ASTC_ActiveFlag" = ''L'' ' || "v_category" || ' ORDER BY "ASMCL_Order" , "ASMC_Order"';
    
    ELSIF "p_allorind" = 'indi' AND "p_PermOrtemp" = 'PTC' THEN
        IF "p_asmcid" = '0' THEN
            "v_sqlText" := 'SELECT ' || "p_tableparam" || ' ,"ASMCL_Order" , "ASMC_Order" FROM "dbo"."Adm_Student_TC" 
INNER JOIN "dbo"."Adm_M_Student" "adm" ON "dbo"."Adm_Student_TC"."AMST_Id" = "adm"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_Student_TC"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_Student_TC"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_Student_TC"."MI_Id" = "dbo"."Adm_School_M_Academic_Year"."MI_Id" AND   
"dbo"."Adm_Student_TC"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "adm"."AMC_Id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id" 
LEFT OUTER JOIN "ivrm_master_state" ON "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
LEFT JOIN "dbo"."IVRM_master_Caste" ON "adm"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "adm"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "adm"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
WHERE "Adm_Student_TC"."mi_Id" = ' || "p_mid" || '  
AND "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "p_Asmayid" || ' AND "dbo"."Adm_School_M_Class"."ASMCL_Id" = ' || "p_asmclid" || ' 
AND "dbo"."Adm_Student_TC"."ASTC_ActiveFlag" = ''L'' ' || "v_category" || ' ORDER BY "ASMCL_Order" , "ASMC_Order"';
        ELSE
            "v_sqlText" := 'SELECT ' || "p_tableparam" || ' , "ASMCL_Order" , "ASMC_Order" FROM "dbo"."Adm_Student_TC" 
INNER JOIN "dbo"."Adm_M_Student" "adm" ON "dbo"."Adm_Student_TC"."AMST_Id" = "adm"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_Student_TC"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_Student_TC"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_Student_TC"."MI_Id" = "dbo"."Adm_School_M_Academic_Year"."MI_Id" AND   
"dbo"."Adm_Student_TC"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "adm"."AMC_Id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id" 
LEFT OUTER JOIN "ivrm_master_state" ON "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
LEFT JOIN "dbo"."IVRM_master_Caste" ON "adm"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "adm"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "adm"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
WHERE "Adm_Student_TC"."mi_Id" = ' || "p_mid" || '  
AND "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "p_Asmayid" || ' AND "dbo"."Adm_School_M_Class"."ASMCL_Id" = ' || "p_asmclid" || ' 
AND "dbo"."Adm_School_M_Section"."ASMS_Id" = ' || "p_asmcid" || ' AND "dbo"."Adm_Student_TC"."ASTC_ActiveFlag" = ''L'' ' || "v_category" || ' ORDER BY "ASMCL_Order" , "ASMC_Order"';
        END IF;
    END IF;

    IF "p_allorind" = 'all' AND "p_PermOrtemp" = 'TTC' THEN
        "v_sqlText" := 'SELECT ' || "p_tableparam" || ' , "ASMCL_Order" , "ASMC_Order" FROM "dbo"."Adm_Student_TC" 
INNER JOIN "dbo"."Adm_M_Student" "adm" ON "dbo"."Adm_Student_TC"."AMST_Id" = "adm"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_Student_TC"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_Student_TC"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_Student_TC"."MI_Id" = "dbo"."Adm_School_M_Academic_Year"."MI_Id" AND   
"dbo"."Adm_Student_TC"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" 
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "adm"."AMC_Id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id" 
LEFT OUTER JOIN "ivrm_master_state" ON "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
LEFT JOIN "dbo"."IVRM_master_Caste" ON "adm"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "adm"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "adm"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
WHERE "Adm_Student_TC"."mi_Id" = ' || "p_mid" || '  
AND "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "p_Asmayid" || ' AND "dbo"."Adm_Student_TC"."ASTC_ActiveFlag" = ''T'' ' || "v_category" || ' ORDER BY "ASMCL_Order" , "ASMC_Order"';
    
    ELSIF "p_allorind" = 'indi' AND "p_PermOrtemp" = 'TTC' THEN
        IF "p_asmcid" = '0' THEN
            "v_sqlText" := 'SELECT ' || "p_tableparam" || ' ,"ASMCL_Order" , "ASMC_Order" FROM "dbo"."Adm_Student_TC" 
INNER JOIN "dbo"."Adm_M_Student" "adm" ON "dbo"."Adm_Student_TC"."AMST_Id" = "adm"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_Student_TC"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_Student_TC"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_Student_TC"."MI_Id" = "dbo"."Adm_School_M_Academic_Year"."MI_Id" AND   
"dbo"."Adm_Student_TC"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" 
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "dbo"."Adm_M_Student"."AMC_Id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id" 
LEFT OUTER JOIN "ivrm_master_state" ON "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
LEFT JOIN "dbo"."IVRM_master_Caste" ON "adm"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "adm"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "adm"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
WHERE "Adm_Student_TC"."mi_Id" = ' || "p_mid" || '  
AND "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "p_Asmayid" || '  
AND "dbo"."Adm_School_M_Section"."ASMS_Id" = ' || "p_asmcid" || ' AND "dbo"."Adm_Student_TC"."ASTC_ActiveFlag" = ''T'' ' || "v_category" || ' ORDER BY "ASMCL_Order" , "ASMC_Order"';
        ELSE
            "v_sqlText" := 'SELECT ' || "p_tableparam" || ' ,"ASMCL_Order" , "ASMC_Order" FROM "dbo"."Adm_Student_TC" 
INNER JOIN "dbo"."Adm_M_Student" "adm" ON "dbo"."Adm_Student_TC"."AMST_Id" = "adm"."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_Student_TC"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_Student_TC"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_Student_TC"."MI_Id" = "dbo"."Adm_School_M_Academic_Year"."MI_Id" AND   
"dbo"."Adm_Student_TC"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" 
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "dbo"."Adm_M_Student"."AMC_Id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id" 
LEFT OUTER JOIN "ivrm_master_state" ON "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
LEFT OUTER JOIN "IVRM_Master_Country" ON "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
LEFT JOIN "dbo"."IVRM_master_Caste" ON "adm"."IC_Id" = "dbo"."IVRM_Master_Caste"."IMC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Caste_Category" ON "adm"."IMCC_Id" = "dbo"."IVRM_Master_Caste_Category"."IMCC_Id" 
LEFT OUTER JOIN "dbo"."IVRM_Master_Religion" ON "adm"."IVRMMR_Id" = "dbo"."IVRM_Master_Religion"."IVRMMR_Id"
WHERE "Adm_Student_TC"."mi_Id" = ' || "p_mid" || '  
AND "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "p_Asmayid" || ' AND "dbo"."Adm_School_M_Class"."ASMCL_Id" = ' || "p_asmclid" || ' 
AND "dbo"."Adm_School_M_Section"."ASMS_Id" = ' || "p_asmcid" || ' AND "dbo"."Adm_Student_TC"."ASTC_ActiveFlag" = ''T'' ' || "v_category" || ' ORDER BY "ASMCL_Order" , "ASMC_Order"';
        END IF;
    END IF;

    EXECUTE "v_sqlText";
    
    RAISE NOTICE '%', "v_sqlText";

END;
$$;