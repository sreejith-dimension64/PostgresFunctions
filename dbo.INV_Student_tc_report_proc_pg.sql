CREATE OR REPLACE FUNCTION "dbo"."INV_Student_tc_report_proc"(
    "MI_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "stu_id" TEXT
)
RETURNS TABLE(
    "AMST_FirstName" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASCA_ApplyDate" TIMESTAMP,
    "ASCA_Reason" VARCHAR,
    "ASCA_Status" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Dynamic" TEXT;
BEGIN
    "Dynamic" := 'SELECT DISTINCT e."AMST_FirstName", e."AMST_AdmNo", b."ASMCL_ClassName", c."ASMC_SectionName", a."ASCA_ApplyDate", a."ASCA_Reason", a."ASCA_Status" 
    FROM "Adm_Students_Certificate_Apply" a, "Adm_School_M_Class" b, "Adm_School_M_Section" c, "Adm_School_Y_Student" d, "Adm_M_Student" e 
    WHERE a."AMST_Id" = e."AMST_Id" 
    AND a."AMST_Id" = d."AMST_Id" 
    AND e."ASMCL_Id" = b."ASMCL_Id" 
    AND b."ASMCL_Id" = d."ASMCL_Id" 
    AND c."ASMS_Id" = d."ASMS_Id" 
    AND a."MI_Id" = b."MI_Id" 
    AND e."MI_Id" = a."MI_Id" 
    AND a."MI_Id" = ' || "MI_Id"::TEXT || ' 
    AND e."AMST_Id" IN (' || "stu_id" || ')';
    
    RETURN QUERY EXECUTE "Dynamic";
END;
$$;