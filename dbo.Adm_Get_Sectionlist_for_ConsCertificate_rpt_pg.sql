CREATE OR REPLACE FUNCTION "Adm_Get_Sectionlist_for_ConsCertificate_rpt"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT
)
RETURNS TABLE(
    "ASMS_Id" INTEGER,
    "ASMC_SectionName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQLQUERY TEXT;
BEGIN
    v_SQLQUERY := 'SELECT a."ASMS_Id", a."ASMC_SectionName" 
                   FROM "Adm_School_M_Section" a
                   INNER JOIN "Adm_School_Master_Class_Cat_Sec" b ON a."ASMS_Id" = b."ASMS_Id"
                   INNER JOIN "Adm_School_M_Class_Category" c ON b."ASMCC_Id" = c."ASMCC_Id"
                   WHERE c."ASMAY_Id" = ' || p_ASMAY_Id || ' 
                   AND a."MI_Id" = ' || p_MI_Id || ' 
                   AND c."ASMCL_Id" IN (' || p_ASMCL_Id || ')
                   GROUP BY a."ASMS_Id", a."ASMC_SectionName"';
    
    RETURN QUERY EXECUTE v_SQLQUERY;
END;
$$;