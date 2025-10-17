CREATE OR REPLACE FUNCTION "dbo"."Admission_Register_Report"(
    "tableparam" TEXT,
    "year" TEXT,
    "class" TEXT,
    "miid" TEXT,
    "att" TEXT,
    "AMC_Id" VARCHAR(10)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "flag" VARCHAR(100);
    "sqlText" TEXT;
    "category" TEXT;
BEGIN
    
    IF ("AMC_Id" != '0' AND "AMC_Id" != '') THEN
        "category" := 'and "AMC"."AMC_Id"=' || "AMC_Id" || '';
    ELSE
        "category" := '';
    END IF;
    
    IF "att" = '0' THEN
        "sqlText" := 'SELECT DISTINCT "Adm_M_Student"."AMST_Id", ' || "tableparam" || ' FROM "dbo"."adm_M_student" 
        LEFT JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."amst_id" = "adm_M_student"."amst_id"
        LEFT JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        LEFT JOIN "dbo"."Adm_School_M_section" ON "dbo"."Adm_School_M_section"."asms_id" = "dbo"."Adm_School_Y_Student"."asms_id"
        LEFT JOIN "IVRM_Master_Country" ON "Adm_M_Student"."AMST_Nationality" = "IVRM_Master_Country"."IVRMMC_Id"
        LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
        LEFT JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
        LEFT JOIN "Adm_M_Student_Guardian" ON "Adm_M_Student"."amst_id" = "Adm_M_Student_Guardian"."amst_id"
        LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        LEFT JOIN "IVRM_Master_Caste" ON "IVRM_Master_Caste"."imc_id" = "Adm_M_Student"."IC_Id"
        LEFT JOIN "ivrm_master_caste_category" ON "ivrm_master_caste_category"."IMCC_Id" = "Adm_M_Student"."IMCC_Id"
        INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "dbo"."Adm_M_Student"."amc_id"
        INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id"
        WHERE "Adm_M_Student"."MI_Id" = ' || "miid" || ' AND "Adm_M_Student"."asmay_id" = ' || "year" || ' ' || "category" || '
        AND "Adm_M_Student"."asmcl_id" IN (' || "class" || ')';
        
    ELSIF "att" = '1' THEN
        "flag" := 'S';
        "sqlText" := 'SELECT DISTINCT "Adm_M_Student"."AMST_Id", ' || "tableparam" || ' FROM "dbo"."adm_M_student"
        LEFT JOIN "IVRM_Master_Country" ON "Adm_M_Student"."AMST_Nationality" = "IVRM_Master_Country"."IVRMMC_Id"
        LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
        LEFT JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_M_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        LEFT JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
        LEFT JOIN "Adm_M_Student_Guardian" ON "Adm_M_Student"."amst_id" = "Adm_M_Student_Guardian"."amst_id"
        LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        LEFT JOIN "IVRM_Master_Caste" ON "IVRM_Master_Caste"."imc_id" = "Adm_M_Student"."IC_Id"
        LEFT JOIN "ivrm_master_caste_category" ON "ivrm_master_caste_category"."IMCC_Id" = "Adm_M_Student"."IMCC_Id"
        INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "dbo"."Adm_M_Student"."amc_id"
        INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id"
        WHERE "Adm_M_Student"."MI_Id" = ' || "miid" || ' AND "Adm_M_Student"."asmay_id" = ' || "year" || ' AND "Adm_M_Student"."asmcl_id" IN (' || "class" || ')
        AND "Adm_M_Student"."amst_sol" = ''' || "flag" || ''' AND "Adm_M_Student"."AMST_ActiveFlag" = 1 ' || "category" || '';
        
    ELSIF "att" = '2' THEN
        "flag" := 'L';
        "sqlText" := 'SELECT DISTINCT "Adm_M_Student"."AMST_Id", ' || "tableparam" || ' FROM "dbo"."adm_M_student"
        INNER JOIN "adm_student_tc" ON "adm_student_tc"."amst_id" = "adm_M_student"."amst_id"
        LEFT JOIN "IVRM_Master_Country" ON "Adm_M_Student"."AMST_Nationality" = "IVRM_Master_Country"."IVRMMC_Id"
        LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
        LEFT JOIN "dbo"."Adm_School_M_Class" ON "dbo"."adm_student_tc"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        LEFT JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
        LEFT JOIN "Adm_M_Student_Guardian" ON "Adm_M_Student"."amst_id" = "Adm_M_Student_Guardian"."amst_id"
        LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        LEFT JOIN "IVRM_Master_Caste" ON "IVRM_Master_Caste"."imc_id" = "Adm_M_Student"."IC_Id"
        LEFT JOIN "ivrm_master_caste_category" ON "ivrm_master_caste_category"."IMCC_Id" = "Adm_M_Student"."IMCC_Id"
        INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "dbo"."Adm_M_Student"."amc_id"
        INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id"
        WHERE "Adm_M_Student"."MI_Id" = ' || "miid" || ' AND "Adm_M_Student"."asmay_id" = ' || "year" || ' AND "adm_student_tc"."asmcl_id" IN (' || "class" || ')
        AND "Adm_M_Student"."amst_sol" = ''' || "flag" || ''' AND "Adm_M_Student"."AMST_ActiveFlag" = 0 ' || "category" || '';
        
    ELSIF "att" = '3' THEN
        "flag" := 'D';
        "sqlText" := 'SELECT DISTINCT "Adm_M_Student"."AMST_Id", ' || "tableparam" || ' FROM "dbo"."adm_M_student"
        LEFT JOIN "IVRM_Master_Country" ON "Adm_M_Student"."AMST_Nationality" = "IVRM_Master_Country"."IVRMMC_Id"
        LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
        LEFT JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_M_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        LEFT JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
        LEFT JOIN "Adm_M_Student_Guardian" ON "Adm_M_Student"."amst_id" = "Adm_M_Student_Guardian"."amst_id"
        LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        LEFT JOIN "IVRM_Master_Caste" ON "IVRM_Master_Caste"."imc_id" = "Adm_M_Student"."IC_Id"
        LEFT JOIN "ivrm_master_caste_category" ON "ivrm_master_caste_category"."IMCC_Id" = "Adm_M_Student"."IMCC_Id"
        INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "dbo"."Adm_M_Student"."amc_id"
        INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id"
        WHERE "Adm_M_Student"."MI_Id" = ' || "miid" || ' AND "Adm_M_Student"."asmay_id" = ' || "year" || ' AND "Adm_M_Student"."asmcl_id" IN (' || "class" || ')
        AND "Adm_M_Student"."amst_sol" = ''' || "flag" || ''' AND "Adm_M_Student"."AMST_ActiveFlag" = 1 ' || "category" || '';
        
    ELSIF "att" = '4' THEN
        "flag" := 'S';
        "sqlText" := 'SELECT DISTINCT "Adm_M_Student"."AMST_Id", ' || "tableparam" || ' FROM "dbo"."adm_M_student"
        LEFT JOIN "IVRM_Master_Country" ON "Adm_M_Student"."AMST_Nationality" = "IVRM_Master_Country"."IVRMMC_Id"
        LEFT OUTER JOIN "IVRM_Master_State" ON "IVRM_Master_State"."IVRMMS_Id" = "Adm_M_Student"."AMST_PerState"
        LEFT JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_M_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        LEFT JOIN "IVRM_Master_Religion" ON "Adm_M_Student"."IVRMMR_Id" = "IVRM_Master_Religion"."IVRMMR_Id"
        LEFT JOIN "Adm_M_Student_Guardian" ON "Adm_M_Student"."amst_id" = "Adm_M_Student_Guardian"."amst_id"
        LEFT OUTER JOIN "Adm_Master_Student_PrevSchool" ON "Adm_Master_Student_PrevSchool"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        LEFT JOIN "IVRM_Master_Caste" ON "IVRM_Master_Caste"."imc_id" = "Adm_M_Student"."IC_Id"
        LEFT JOIN "ivrm_master_caste_category" ON "ivrm_master_caste_category"."IMCC_Id" = "Adm_M_Student"."IMCC_Id"
        INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" ON "ASMCC"."ASMCC_Id" = "dbo"."Adm_M_Student"."amc_id"
        INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id" = "AMC"."AMC_Id"
        WHERE "Adm_M_Student"."MI_Id" = ' || "miid" || ' AND "Adm_M_Student"."asmay_id" = ' || "year" || ' AND "Adm_M_Student"."asmcl_id" IN (' || "class" || ')';
    END IF;
    
    EXECUTE "sqlText";
    
    RETURN;
END;
$$;