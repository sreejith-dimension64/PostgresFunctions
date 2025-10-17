CREATE OR REPLACE FUNCTION "dbo"."Admission_ReligionCasteCategory_Report"(
    "p_MI_Id" bigint,
    "p_flag" text,
    "p_ASMAY_Id" text,
    "p_ASMCL_Id" text,
    "p_castecategory" text,
    "p_religion" text
)
RETURNS TABLE(
    "id_column" bigint,
    "ASMCL_Id" bigint,
    "ASMCL_ClassName" text,
    "category_name" text,
    "boycount" bigint,
    "girlcount" bigint,
    "totalcount" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
BEGIN
    IF "p_flag" = 'flag1' THEN
        v_sqldynamic := '
        SELECT DISTINCT d."IMCC_Id", d."ASMCL_Id", d."ASMCL_ClassName", d."IMCC_CategoryName", 
               sum(d.boys) AS boycount, sum(d.girls) AS girlcount, (sum(d.boys) + sum(d.girls)) AS totalcount
        FROM (
            SELECT DISTINCT c."IMCC_Id", b."ASMCL_Id", b."ASMCL_ClassName", c."IMCC_CategoryName", 
                   0 AS girls, count(*) AS boys
            FROM "Adm_M_Student" a
            INNER JOIN "Adm_School_Y_Student" d ON a."AMST_Id" = d."AMST_Id" AND d."AMAY_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Class" b ON d."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "IVRM_Master_Caste_Category" c ON a."IVRMMR_Id" = c."IMCC_Id"
            WHERE a."MI_Id" = ' || "p_MI_Id" || ' 
              AND d."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') 
              AND a."AMST_Sex" = ''Male''
              AND d."ASMCL_Id" IN (' || "p_ASMCL_Id" || ') 
              AND c."IMCC_Id" IN (' || "p_castecategory" || ')
            GROUP BY a."AMST_Sex", c."IMCC_Id", b."ASMCL_Id", b."ASMCL_ClassName", c."IMCC_CategoryName"
            
            UNION ALL
            
            SELECT DISTINCT c."IMCC_Id", b."ASMCL_Id", b."ASMCL_ClassName", c."IMCC_CategoryName", 
                   count(*) AS girls, 0 AS boys
            FROM "Adm_M_Student" a
            INNER JOIN "Adm_School_Y_Student" d ON a."AMST_Id" = d."AMST_Id" AND d."AMAY_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Class" b ON d."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "IVRM_Master_Caste_Category" c ON a."IVRMMR_Id" = c."IMCC_Id"
            WHERE a."MI_Id" = ' || "p_MI_Id" || ' 
              AND d."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') 
              AND a."AMST_Sex" = ''Female''
              AND d."ASMCL_Id" IN (' || "p_ASMCL_Id" || ') 
              AND c."IMCC_Id" IN (' || "p_castecategory" || ')
            GROUP BY a."AMST_Sex", c."IMCC_Id", b."ASMCL_Id", b."ASMCL_ClassName", c."IMCC_CategoryName"
        ) d
        GROUP BY d."IMCC_Id", d."ASMCL_Id", d."ASMCL_ClassName", d."IMCC_CategoryName"
        LIMIT 100';
        
        RETURN QUERY EXECUTE v_sqldynamic;
        
    ELSIF "p_flag" = 'flag2' THEN
        v_sqldynamic := '
        SELECT DISTINCT d."IVRMMR_Id", d."ASMCL_Id", d."ASMCL_ClassName", d."IVRMMR_Name", 
               sum(d.boys) AS boycount, sum(d.girls) AS girlcount, (sum(d.boys) + sum(d.girls)) AS totalcount
        FROM (
            SELECT DISTINCT c."IVRMMR_Id", b."ASMCL_Id", b."ASMCL_ClassName", c."IVRMMR_Name", 
                   0 AS girls, count(*) AS boys
            FROM "Adm_M_Student" a
            INNER JOIN "Adm_School_Y_Student" d ON a."AMST_Id" = d."AMST_Id" AND d."AMAY_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Class" b ON d."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "IVRM_Master_Religion" c ON a."IVRMMR_Id" = c."IVRMMR_Id"
            WHERE a."MI_Id" = ' || "p_MI_Id" || ' 
              AND d."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') 
              AND a."AMST_Sex" = ''Male''
              AND d."ASMCL_Id" IN (' || "p_ASMCL_Id" || ') 
              AND c."IVRMMR_Id" IN (' || "p_religion" || ')
            GROUP BY a."AMST_Sex", c."IVRMMR_Id", b."ASMCL_Id", b."ASMCL_ClassName", c."IVRMMR_Name"
            
            UNION ALL
            
            SELECT DISTINCT c."IVRMMR_Id", b."ASMCL_Id", b."ASMCL_ClassName", c."IVRMMR_Name", 
                   count(*) AS girls, 0 AS boys
            FROM "Adm_M_Student" a
            INNER JOIN "Adm_School_Y_Student" d ON a."AMST_Id" = d."AMST_Id" AND d."AMAY_ActiveFlag" = 1
            INNER JOIN "Adm_School_M_Class" b ON d."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "IVRM_Master_Religion" c ON a."IVRMMR_Id" = c."IVRMMR_Id"
            WHERE a."MI_Id" = ' || "p_MI_Id" || ' 
              AND d."ASMAY_Id" IN (' || "p_ASMAY_Id" || ') 
              AND a."AMST_Sex" = ''Female''
              AND d."ASMCL_Id" IN (' || "p_ASMCL_Id" || ') 
              AND c."IVRMMR_Id" IN (' || "p_religion" || ')
            GROUP BY a."AMST_Sex", c."IVRMMR_Id", b."ASMCL_Id", b."ASMCL_ClassName", c."IVRMMR_Name"
        ) d
        GROUP BY d."IVRMMR_Id", d."ASMCL_Id", d."ASMCL_ClassName", d."IVRMMR_Name"
        LIMIT 100';
        
        RETURN QUERY EXECUTE v_sqldynamic;
    END IF;
    
    RETURN;
END;
$$;