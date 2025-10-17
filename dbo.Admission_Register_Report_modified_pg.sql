CREATE OR REPLACE FUNCTION "dbo"."Admission_Register_Report_modified"(
    "class" TEXT,
    "year" VARCHAR(100),
    "att" VARCHAR(10),
    "tableparam" VARCHAR(5000)
)
RETURNS TABLE AS $$
DECLARE
    "flag" VARCHAR(100);
    "sqlText" TEXT;
BEGIN
    IF "att" = '0' THEN
        "sqlText" := 'SELECT ' || "tableparam" || ' FROM "dbo"."adm_M_student" 
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."amst_id" = "adm_M_student"."amst_id"
        WHERE "mi_Id" = 2 AND "asmay_id" = ' || "year" || ' AND "adm_M_student"."asmcl_id" IN (' || "class" || ') 
        GROUP BY ' || "tableparam";
    
    ELSIF "att" = '1' THEN
        "flag" := 'S';
        "sqlText" := 'SELECT ' || "tableparam" || ' FROM "dbo"."adm_M_student" 
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."amst_id" = "adm_M_student"."amst_id"
        WHERE "mi_Id" = 2 AND "asmay_id" = ' || "year" || ' AND "adm_M_student"."asmcl_id" IN (' || "class" || ') 
        AND "amst_sol" = ''' || "flag" || ''' GROUP BY ' || "tableparam";
    
    ELSIF "att" = '2' THEN
        "flag" := 'L';
        "sqlText" := 'SELECT ' || "tableparam" || ' FROM "dbo"."adm_M_student"
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."amst_id" = "adm_M_student"."amst_id" 
        WHERE "mi_Id" = 2 AND "asmay_id" = ' || "year" || ' AND "adm_M_student"."asmcl_id" IN (' || "class" || ') 
        AND "amst_sol" = ''' || "flag" || ''' GROUP BY ' || "tableparam";
    
    ELSIF "att" = '3' THEN
        "flag" := 'D';
        "sqlText" := 'SELECT ' || "tableparam" || ' FROM "dbo"."adm_M_student" 
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."amst_id" = "adm_M_student"."amst_id" 
        WHERE "mi_Id" = 2 AND "asmay_id" = ' || "year" || ' AND "adm_M_student"."asmcl_id" IN (' || "class" || ') 
        AND "amst_sol" = ''' || "flag" || ''' GROUP BY ' || "tableparam";
    
    END IF;
    
    RETURN QUERY EXECUTE "sqlText";
    
END;
$$ LANGUAGE plpgsql;