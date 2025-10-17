CREATE OR REPLACE FUNCTION "Admission_Tc_Report"(
    "Asmayid" TEXT,
    "allorind" TEXT,
    "asmclid" TEXT,
    "asmcid" TEXT,
    "tableparam" TEXT,
    "PermOrtemp" VARCHAR(10),
    "mid" TEXT,
    "AMC_Id" TEXT
)
RETURNS TABLE(
    "result" REFCURSOR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlText" TEXT;
    "category" TEXT;
    "result_cursor" REFCURSOR := 'result_cursor';
BEGIN
    
    IF "AMC_Id" != '0' AND "AMC_Id" != '' THEN
        "category" := 'and "AMC"."AMC_Id" = ' || "AMC_Id" || '';
    ELSE
        "category" := '';
    END IF;
    
    IF "allorind" = 'all' AND "PermOrtemp" = 'PTC' THEN
        
        "sqlText" := 'SELECT ' || "tableparam" || ' ,"ASMCL_Order" , "ASMC_Order" FROM
"Adm_Student_TC" 
INNER JOIN  "Adm_M_Student" adm ON "Adm_Student_TC"."AMST_Id" = adm."AMST_Id" 
INNER JOIN  "Adm_School_M_Section" ON "Adm_Student_TC"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
INNER JOIN  "Adm_School_M_Class" ON "Adm_Student_TC"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
INNER JOIN  "Adm_School_M_Academic_Year" ON "Adm_Student_TC"."MI_Id" = "Adm_School_M_Academic_Year"."MI_Id" AND 
"Adm_Student_TC"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
INNER JOIN "Adm_School_M_Class_Category" ASMCC on ASMCC."ASMCC_Id" = adm."AMC_Id"
INNER JOIN "Adm_M_Category" AMC ON ASMCC."AMC_Id" = AMC."AMC_Id" 
left outer join "ivrm_master_state" on "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
left outer join "IVRM_Master_Country" on "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
left JOIN "IVRM_master_Caste" ON adm."IC_Id" = "IVRM_Master_Caste"."IMC_Id" 
Left outer JOIN "IVRM_Master_Caste_Category" ON adm."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id" 
left outer join  "IVRM_Master_Religion" ON  adm."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
Where "Adm_Student_TC"."mi_Id" = ' || "mid" || ' and  "Adm_Student_TC"."ASTC_DeletedFlag" = ''0'' 
and "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' 
and "Adm_Student_TC"."ASTC_ActiveFlag" = ''L'' ' || "category" || ' order by "ASMCL_Order" , "ASMC_Order"';
        
    ELSIF "allorind" = 'indi' AND "PermOrtemp" = 'PTC' THEN
        
        IF "asmcid" = '0' THEN
            
            "sqlText" := 'select ' || "tableparam" || ' ,"ASMCL_Order" , "ASMC_Order"  FROM "Adm_Student_TC" INNER JOIN
"Adm_M_Student" adm ON "Adm_Student_TC"."AMST_Id" = adm."AMST_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_Student_TC"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_Student_TC"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Academic_Year" ON "Adm_Student_TC"."MI_Id" = "Adm_School_M_Academic_Year"."MI_Id" AND 
"Adm_Student_TC"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ASMCC on ASMCC."ASMCC_Id" = adm."AMC_Id"
INNER JOIN "Adm_M_Category" AMC ON ASMCC."AMC_Id" = AMC."AMC_Id" 
left outer join "ivrm_master_state" on "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
left outer join "IVRM_Master_Country" on "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
left JOIN "IVRM_master_Caste" ON adm."IC_Id" = "IVRM_Master_Caste"."IMC_Id" 
Left outer JOIN "IVRM_Master_Caste_Category" ON adm."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id" 
left outer join  "IVRM_Master_Religion" ON  adm."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
Where "Adm_Student_TC"."mi_Id" = ' || "mid" || ' and  "Adm_Student_TC"."ASTC_DeletedFlag" = ''0'' 
and "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' and "Adm_School_M_Class"."ASMCL_Id" = ' || "asmclid" || ' 
and "Adm_Student_TC"."ASTC_ActiveFlag" = ''L'' ' || "category" || ' order by "ASMCL_Order" , "ASMC_Order"';
            
        ELSE
            
            "sqlText" := 'select ' || "tableparam" || ' , "ASMCL_Order" , "ASMC_Order"  FROM "Adm_Student_TC" 
INNER JOIN "Adm_M_Student" adm ON "Adm_Student_TC"."AMST_Id" = adm."AMST_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_Student_TC"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_Student_TC"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Academic_Year" ON "Adm_Student_TC"."MI_Id" = "Adm_School_M_Academic_Year"."MI_Id" AND 
"Adm_Student_TC"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
INNER JOIN "Adm_School_M_Class_Category" ASMCC on ASMCC."ASMCC_Id" = adm."AMC_Id"
INNER JOIN "Adm_M_Category" AMC ON ASMCC."AMC_Id" = AMC."AMC_Id" 
left outer join "ivrm_master_state" on "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
left outer join "IVRM_Master_Country" on "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
left JOIN "IVRM_master_Caste" ON adm."IC_Id" = "IVRM_Master_Caste"."IMC_Id" 
Left outer JOIN "IVRM_Master_Caste_Category" ON adm."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id" 
left outer join  "IVRM_Master_Religion" ON  adm."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
Where "Adm_Student_TC"."mi_Id" = ' || "mid" || ' and  "Adm_Student_TC"."ASTC_DeletedFlag" = ''0'' 
and "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' and "Adm_School_M_Class"."ASMCL_Id" = ' || "asmclid" || ' 
and "Adm_School_M_Section"."ASMS_Id" = ' || "asmcid" || 'and "Adm_Student_TC"."ASTC_ActiveFlag" = ''L'' ' || "category" || ' order by "ASMCL_Order" , "ASMC_Order"';
            
        END IF;
        
    END IF;
    
    IF "allorind" = 'all' AND "PermOrtemp" = 'TTC' THEN
        
        "sqlText" := 'SELECT ' || "tableparam" || ' , "ASMCL_Order" , "ASMC_Order" FROM "Adm_Student_TC" INNER JOIN
"Adm_M_Student" adm ON "Adm_Student_TC"."AMST_Id" = adm."AMST_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_Student_TC"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_Student_TC"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Academic_Year" ON "Adm_Student_TC"."MI_Id" = "Adm_School_M_Academic_Year"."MI_Id" AND 
"Adm_Student_TC"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
INNER JOIN "Adm_School_M_Class_Category" ASMCC on ASMCC."ASMCC_Id" = adm."AMC_Id"
INNER JOIN "Adm_M_Category" AMC ON ASMCC."AMC_Id" = AMC."AMC_Id" 
left outer join "ivrm_master_state" on "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
left outer join "IVRM_Master_Country" on "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
left JOIN "IVRM_master_Caste" ON adm."IC_Id" = "IVRM_Master_Caste"."IMC_Id" 
Left outer JOIN "IVRM_Master_Caste_Category" ON adm."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id" 
left outer join  "IVRM_Master_Religion" ON  adm."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
Where "Adm_Student_TC"."mi_Id" = ' || "mid" || '  and  "Adm_Student_TC"."ASTC_DeletedFlag" = ''0''
and "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' and "Adm_Student_TC"."ASTC_ActiveFlag" = ''T'' ' || "category" || ' order by "ASMCL_Order" , "ASMC_Order"';
        
    ELSIF "allorind" = 'indi' AND "PermOrtemp" = 'TTC' THEN
        
        IF "asmcid" = '0' THEN
            
            "sqlText" := 'select ' || "tableparam" || ' ,"ASMCL_Order" , "ASMC_Order" FROM "Adm_Student_TC" INNER JOIN
"Adm_M_Student" adm ON "Adm_Student_TC"."AMST_Id" = adm."AMST_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_Student_TC"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_Student_TC"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Academic_Year" ON "Adm_Student_TC"."MI_Id" = "Adm_School_M_Academic_Year"."MI_Id" AND 
"Adm_Student_TC"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
INNER JOIN "Adm_School_M_Class_Category" ASMCC on ASMCC."ASMCC_Id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" AMC ON ASMCC."AMC_Id" = AMC."AMC_Id" 
left outer join "ivrm_master_state" on "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
left outer join "IVRM_Master_Country" on "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
left JOIN "IVRM_master_Caste" ON adm."IC_Id" = "IVRM_Master_Caste"."IMC_Id" 
Left outer JOIN "IVRM_Master_Caste_Category" ON adm."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id" 
left outer join  "IVRM_Master_Religion" ON  adm."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
Where "Adm_Student_TC"."mi_Id" = ' || "mid" || ' and  "Adm_Student_TC"."ASTC_DeletedFlag" = ''0'' 
and "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' 
and "Adm_School_M_Section"."ASMS_Id" = ' || "asmcid" || 'and "Adm_Student_TC"."ASTC_ActiveFlag" = ''T'' ' || "category" || ' order by "ASMCL_Order" , "ASMC_Order"';
            
        ELSE
            
            "sqlText" := 'select ' || "tableparam" || ' ,"ASMCL_Order" , "ASMC_Order"  FROM "Adm_Student_TC" INNER JOIN
"Adm_M_Student" adm ON "Adm_Student_TC"."AMST_Id"  = adm."AMST_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_Student_TC"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_Student_TC"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Academic_Year" ON "Adm_Student_TC"."MI_Id" = "Adm_School_M_Academic_Year"."MI_Id" AND 
"Adm_Student_TC"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
INNER JOIN "Adm_School_M_Class_Category" ASMCC on ASMCC."ASMCC_Id" = "Adm_M_Student"."AMC_Id"
INNER JOIN "Adm_M_Category" AMC ON ASMCC."AMC_Id" = AMC."AMC_Id" 
left outer join "ivrm_master_state" on "ivrm_master_state"."IVRMMS_Id" = "AMST_PerState"
left outer join "IVRM_Master_Country" on "IVRM_Master_Country"."IVRMMC_Id" = "AMST_PerCountry"
left JOIN "IVRM_master_Caste" ON adm."IC_Id" = "IVRM_Master_Caste"."IMC_Id" 
Left outer JOIN "IVRM_Master_Caste_Category" ON adm."IMCC_Id" = "IVRM_Master_Caste_Category"."IMCC_Id" 
left outer join  "IVRM_Master_Religion" ON  adm."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
Where "Adm_Student_TC"."mi_Id" = ' || "mid" || '  and  "Adm_Student_TC"."ASTC_DeletedFlag" = ''0''
and "Adm_School_M_Academic_Year"."ASMAY_Id" = ' || "Asmayid" || ' and "Adm_School_M_Class"."ASMCL_Id" = ' || "asmclid" || ' 
and "Adm_School_M_Section"."ASMS_Id" = ' || "asmcid" || 'and "Adm_Student_TC"."ASTC_ActiveFlag" = ''T'' ' || "category" || ' order by "ASMCL_Order" , "ASMC_Order"';
            
        END IF;
        
    END IF;
    
    RAISE NOTICE '%', "sqlText";
    
    OPEN "result_cursor" FOR EXECUTE "sqlText";
    RETURN QUERY SELECT "result_cursor";
    
END;
$$;