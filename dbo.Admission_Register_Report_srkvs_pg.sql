CREATE OR REPLACE FUNCTION "dbo"."Admission_Register_Report_srkvs"(
    "p_tableparam" TEXT,
    "p_year" TEXT,
    "p_class" TEXT,
    "p_miid" TEXT,
    "p_att" TEXT,
    "p_AMC_Id" VARCHAR(10)
)
RETURNS TABLE(
    "AMST_Id" INTEGER
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_flag" VARCHAR(100);
    "v_sqlText" TEXT;
    "v_category" TEXT;
BEGIN
    
    IF ("p_AMC_Id" != '0' AND "p_AMC_Id" != '' AND "p_AMC_Id" IS NOT NULL) THEN
        "v_category" := 'and "AMC"."AMC_Id"=' || "p_AMC_Id" || '';
    ELSE
        "v_category" := '';
    END IF;
    
    IF "p_att" = '0' THEN
        "v_sqlText" := 'SELECT distinct "Adm_M_Student"."AMST_Id", ' || "p_tableparam" || ' FROM "dbo"."adm_M_student"
left join "Adm_School_Y_Student" on "Adm_School_Y_Student"."amst_id"="adm_M_student"."amst_id"
left JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
left JOIN "dbo"."Adm_School_M_section" ON "dbo"."Adm_School_M_section"."asms_id" = "dbo"."Adm_School_Y_Student"."asms_id"
left join "IVRM_Master_Country"
on "Adm_M_Student"."AMST_Nationality"="IVRM_Master_Country"."IVRMMC_Id"
Left outer join "IVRM_Master_State" on "IVRM_Master_State"."IVRMMS_Id"= "Adm_M_Student"."AMST_PerState"
left join "IVRM_Master_Religion" on "Adm_M_Student"."IVRMMR_Id"= "IVRM_Master_Religion"."IVRMMR_Id"
left join "Adm_M_Student_Guardian" on "Adm_M_Student"."amst_id"="Adm_M_Student_Guardian"."amst_id"
left outer join "Adm_Master_Student_PrevSchool" on "Adm_Master_Student_PrevSchool"."AMST_Id"="dbo"."Adm_M_Student"."AMST_Id"
left join "IVRM_Master_Caste" on "IVRM_Master_Caste"."imc_id"="Adm_M_Student"."IC_Id"
left join "ivrm_master_caste_category" on "ivrm_master_caste_category"."IMCC_Id"="Adm_M_Student"."IMCC_Id"
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" on "ASMCC"."ASMCC_Id"="dbo"."Adm_M_Student"."amc_id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id"="AMC"."AMC_Id"
where "Adm_M_Student"."MI_Id"=' || "p_miid" || ' and "Adm_M_Student"."asmay_id"=' || "p_year" || ' ' || "v_category" || '
and "Adm_M_Student"."asmcl_id" in (' || "p_class" || ')';
    
    ELSIF "p_att" = '1' THEN
        "v_flag" := 'S';
        "v_sqlText" := 'SELECT distinct "Adm_M_Student"."AMST_Id",' || "p_tableparam" || ' FROM "dbo"."adm_M_student"
left join "IVRM_Master_Country" on "Adm_M_Student"."AMST_Nationality"="IVRM_Master_Country"."IVRMMC_Id"
Left outer join "IVRM_Master_State" on "IVRM_Master_State"."IVRMMS_Id"= "Adm_M_Student"."AMST_PerState"
left JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_M_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
left join "IVRM_Master_Religion" on "Adm_M_Student"."IVRMMR_Id"= "IVRM_Master_Religion"."IVRMMR_Id"
left join "Adm_M_Student_Guardian" on "Adm_M_Student"."amst_id"="Adm_M_Student_Guardian"."amst_id"
left outer join "Adm_Master_Student_PrevSchool" on "Adm_Master_Student_PrevSchool"."AMST_Id"="dbo"."Adm_M_Student"."AMST_Id"
left join "IVRM_Master_Caste" on "IVRM_Master_Caste"."imc_id"="Adm_M_Student"."IC_Id"
left join "ivrm_master_caste_category" on "ivrm_master_caste_category"."IMCC_Id"="Adm_M_Student"."IMCC_Id"
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" on "ASMCC"."ASMCC_Id"="dbo"."Adm_M_Student"."amc_id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id"="AMC"."AMC_Id"
where "Adm_M_Student"."MI_Id"=' || "p_miid" || ' and "Adm_M_Student"."asmay_id"=' || "p_year" || ' and "Adm_M_Student"."asmcl_id" in (' || "p_class" || ')
and "Adm_M_Student"."amst_sol"=''' || "v_flag" || ''' and "Adm_M_Student"."AMST_ActiveFlag"=1 ' || "v_category" || '';
    
    ELSIF "p_att" = '2' THEN
        "v_flag" := 'L';
        "v_sqlText" := 'SELECT distinct "Adm_M_Student"."AMST_Id",' || "p_tableparam" || ' FROM "dbo"."adm_M_student"
Inner join "adm_student_tc" on "adm_student_tc"."amst_id"="adm_M_student"."amst_id"
left join "IVRM_Master_Country" on "Adm_M_Student"."AMST_Nationality"="IVRM_Master_Country"."IVRMMC_Id"
Left outer join "IVRM_Master_State" on "IVRM_Master_State"."IVRMMS_Id"= "Adm_M_Student"."AMST_PerState"
left JOIN "dbo"."Adm_School_M_Class" ON "dbo"."adm_student_tc"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
left join "IVRM_Master_Religion" on "Adm_M_Student"."IVRMMR_Id"= "IVRM_Master_Religion"."IVRMMR_Id"
left join "Adm_M_Student_Guardian" on "Adm_M_Student"."amst_id"="Adm_M_Student_Guardian"."amst_id"
left outer join "Adm_Master_Student_PrevSchool" on "Adm_Master_Student_PrevSchool"."AMST_Id"="dbo"."Adm_M_Student"."AMST_Id"
left join "IVRM_Master_Caste" on "IVRM_Master_Caste"."imc_id"="Adm_M_Student"."IC_Id"
left join "ivrm_master_caste_category" on "ivrm_master_caste_category"."IMCC_Id"="Adm_M_Student"."IMCC_Id"
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" on "ASMCC"."ASMCC_Id"="dbo"."Adm_M_Student"."amc_id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id"="AMC"."AMC_Id"
where "Adm_M_Student"."MI_Id"=' || "p_miid" || ' and "Adm_M_Student"."asmay_id"=' || "p_year" || ' and "adm_student_tc"."asmcl_id" in (' || "p_class" || ')
and "Adm_M_Student"."amst_sol"=''' || "v_flag" || ''' and "Adm_M_Student"."AMST_ActiveFlag"=0 ' || "v_category" || '';
    
    ELSIF "p_att" = '3' THEN
        "v_flag" := 'D';
        "v_sqlText" := 'SELECT distinct "Adm_M_Student"."AMST_Id",' || "p_tableparam" || ' FROM "dbo"."adm_M_student"
left join "IVRM_Master_Country" on "Adm_M_Student"."AMST_Nationality"="IVRM_Master_Country"."IVRMMC_Id"
Left outer join "IVRM_Master_State" on "IVRM_Master_State"."IVRMMS_Id"= "Adm_M_Student"."AMST_PerState"
left JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_M_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
left join "IVRM_Master_Religion" on "Adm_M_Student"."IVRMMR_Id"= "IVRM_Master_Religion"."IVRMMR_Id"
left join "Adm_M_Student_Guardian" on "Adm_M_Student"."amst_id"="Adm_M_Student_Guardian"."amst_id"
left outer join "Adm_Master_Student_PrevSchool" on "Adm_Master_Student_PrevSchool"."AMST_Id"="dbo"."Adm_M_Student"."AMST_Id"
left join "IVRM_Master_Caste" on "IVRM_Master_Caste"."imc_id"="Adm_M_Student"."IC_Id"
left join "ivrm_master_caste_category" on "ivrm_master_caste_category"."IMCC_Id"="Adm_M_Student"."IMCC_Id"
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" on "ASMCC"."ASMCC_Id"="dbo"."Adm_M_Student"."amc_id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id"="AMC"."AMC_Id"
where "Adm_M_Student"."MI_Id"=' || "p_miid" || ' and "Adm_M_Student"."asmay_id"=' || "p_year" || ' and "Adm_M_Student"."asmcl_id" in (' || "p_class" || ')
and "Adm_M_Student"."amst_sol"=''' || "v_flag" || ''' and "Adm_M_Student"."AMST_ActiveFlag"=1 ' || "v_category" || '';
    
    ELSIF "p_att" = '4' THEN
        "v_flag" := 'S';
        "v_sqlText" := 'SELECT distinct "Adm_M_Student"."AMST_Id",' || "p_tableparam" || ' FROM "dbo"."adm_M_student"
left join "IVRM_Master_Country" on "Adm_M_Student"."AMST_Nationality"="IVRM_Master_Country"."IVRMMC_Id"
Left outer join "IVRM_Master_State" on "IVRM_Master_State"."IVRMMS_Id"= "Adm_M_Student"."AMST_PerState"
left JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_M_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
left join "IVRM_Master_Religion" on "Adm_M_Student"."IVRMMR_Id"= "IVRM_Master_Religion"."IVRMMR_Id"
left join "Adm_M_Student_Guardian" on "Adm_M_Student"."amst_id"="Adm_M_Student_Guardian"."amst_id"
left outer join "Adm_Master_Student_PrevSchool" on "Adm_Master_Student_PrevSchool"."AMST_Id"="dbo"."Adm_M_Student"."AMST_Id"
left join "IVRM_Master_Caste" on "IVRM_Master_Caste"."imc_id"="Adm_M_Student"."IC_Id"
left join "ivrm_master_caste_category" on "ivrm_master_caste_category"."IMCC_Id"="Adm_M_Student"."IMCC_Id"
INNER JOIN "dbo"."Adm_School_M_Class_Category" "ASMCC" on "ASMCC"."ASMCC_Id"="dbo"."Adm_M_Student"."amc_id"
INNER JOIN "dbo"."Adm_M_Category" "AMC" ON "ASMCC"."AMC_Id"="AMC"."AMC_Id"
where "Adm_M_Student"."MI_Id"=' || "p_miid" || ' and "Adm_M_Student"."asmay_id"=' || "p_year" || ' and "Adm_M_Student"."asmcl_id" in (' || "p_class" || ')';
    
    END IF;
    
    RETURN QUERY EXECUTE "v_sqlText";
    
END;
$$;