CREATE OR REPLACE FUNCTION "dbo"."Group_Wise_Student_Report"(
    "Where" TEXT,
    "flag" TEXT,
    "userid" TEXT
)
RETURNS TABLE(
    "Amount" NUMERIC,
    "AMST_SOL" VARCHAR,
    "AMST_Id" INTEGER,
    "AMST_FirstName" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "FMG_GroupName" VARCHAR,
    "AMAY_RollNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "query1" TEXT;
BEGIN

    IF("flag" != 'unmapped') THEN
    
        "query" := 'SELECT distinct sum("dbo"."Fee_Student_Status"."FSS_CurrentYrCharges") AS "Amount", "dbo"."Adm_M_Student"."AMST_SOL","dbo"."Adm_M_Student"."AMST_Id",COALESCE("Adm_M_Student"."AMST_FirstName",'''')|| '' ''||COALESCE("Adm_M_Student"."AMST_MiddleName",'''')|| '' '' ||COALESCE("Adm_M_Student"."AMST_LastName",'' '') as "AMST_FirstName","dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Adm_M_Student"."AMST_RegistrationNo","dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Fee_Master_Group"."FMG_GroupName", 
        "dbo"."Adm_School_Y_Student"."AMAY_RollNo" FROM 
        "dbo"."Fee_Student_Status" INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Student_Status"."Amst_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id" INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" INNER JOIN 
        "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id" INNER JOIN 
        "dbo"."Fee_Master_Group" ON "dbo"."Fee_Student_Status"."fmg_id" = "dbo"."Fee_Master_Group"."FMG_Id" INNER JOIN 
        "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" INNER JOIN 
        "dbo"."Fee_Master_Amount" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_Student_Status"."FMA_Id" INNER JOIN 
        "dbo"."Fee_Master_Class_Category" ON "dbo"."Fee_Master_Class_Category"."FMCC_Id" = "dbo"."Fee_Master_Amount"."FMCC_Id" 
        inner join "IVRM_Master_Caste_Category" on "IVRM_Master_Caste_Category"."IMCC_Id"="Adm_M_Student"."IMCC_Id"
        WHERE "AMST_SOL"=''S'' and "AMAY_ActiveFlag"=1 and "AMST_ActiveFlag"=1 and  "Fee_Master_Group"."User_Id"=' || "userid" || ' ' || "Where" || '  
        GROUP BY "dbo"."Adm_School_M_Class"."ASMCL_Id", "dbo"."Adm_School_M_Section"."ASMS_Id","dbo"."Adm_School_M_Class"."ASMCL_ClassName","dbo"."Adm_School_M_Section"."ASMC_SectionName","dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_MiddleName","dbo"."Adm_M_Student"."AMST_LastName",  "dbo"."Adm_M_Student"."AMST_RegistrationNo","dbo"."Adm_M_Student"."AMST_AdmNo", "dbo"."Fee_Master_Group"."FMG_GroupName", "dbo"."Adm_School_Y_Student"."AMAY_RollNo",  "dbo"."Fee_Master_Group"."FMG_Id", "dbo"."Adm_M_Student"."AMST_Id","dbo"."Adm_M_Student"."AMST_SOL"';

        RETURN QUERY EXECUTE "query";
        
    END IF;
    
    IF("flag" = 'unmapped') THEN
    
        "query1" := 'select distinct "AMST_FirstName"|| '' '' || "AMST_MiddleName" || '' '' ||"AMST_LastName" as "AMST_FirstName","AMST_AdmNo","ASMCL_ClassName","ASMC_SectionName","AMAY_RollNo" ,'''' as "FMG_GroupName", NULL::NUMERIC as "Amount", NULL as "AMST_SOL", NULL::INTEGER as "AMST_Id", NULL as "AMST_RegistrationNo"
        from "Adm_M_Student" inner join "Adm_School_Y_Student" on "Adm_M_Student"."AMST_Id"="Adm_School_Y_Student"."AMST_Id"              
        inner join "Adm_School_M_Class" on "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id"              
        inner join "Adm_School_M_Section" on "Adm_School_M_Section"."ASMS_Id"="Adm_School_Y_Student"."ASMS_Id"                
        where ' || "where" || '         
        order by "ASMCL_ClassName","ASMC_SectionName"';
        
        RETURN QUERY EXECUTE "query1";
        
    END IF;

    RETURN;
    
END;
$$;