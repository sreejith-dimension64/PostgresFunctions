CREATE OR REPLACE FUNCTION "dbo"."Adm_getClassSectiondata_By_Classteacher" (
    p_MI_ID INT,
    p_asmay_id TEXT,
    p_HRME_Id TEXT,
    p_type INT
)
RETURNS TABLE (
    "name" TEXT,
    "ASMCL_Id" INTEGER,
    "ASMC_Id" INTEGER,
    "classsection" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_type = 1 THEN
        RETURN QUERY
        SELECT 
            "class"."ASMCL_ClassName" || ' - ' || "section"."ASMC_SectionName" AS "name",
            "class"."ASMCL_Id",
            "section"."ASMS_Id" AS "ASMC_Id",
            "class"."ASMCL_Id"::TEXT || '-' || "section"."ASMS_Id"::TEXT AS "classsection"
        FROM 
            "Adm_School_M_Class" AS "class",
            "Adm_School_M_Section" AS "section"
        WHERE 
            "class"."MI_Id" = p_MI_ID 
            AND "class"."ASMCL_ActiveFlag" = 1 
            AND "section"."MI_Id" = p_MI_ID 
            AND "section"."ASMC_ActiveFlag" = 1
        ORDER BY 
            "class"."ASMCL_Id",
            "section"."ASMS_Id";
    ELSE
        RETURN QUERY
        SELECT 
            "class"."ASMCL_ClassName" || ' - ' || "section"."ASMC_SectionName" AS "name",
            "class"."ASMCL_Id",
            "section"."ASMS_Id" AS "ASMC_Id",
            "class"."ASMCL_Id"::TEXT || '-' || "section"."ASMS_Id"::TEXT AS "classsection"
        FROM 
            "IVRM_Master_ClassTeacher" "a"
            INNER JOIN "Adm_School_M_Class" AS "class" ON "class"."ASMCL_Id" = "a"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" AS "section" ON "section"."ASMS_Id" = "a"."ASMS_Id"
        WHERE 
            "class"."MI_Id" = p_MI_ID 
            AND "class"."ASMCL_ActiveFlag" = 1 
            AND "section"."MI_Id" = p_MI_ID 
            AND "section"."ASMC_ActiveFlag" = 1 
            AND "a"."ASMAY_Id" = p_asmay_id 
            AND "a"."HRME_Id" = p_HRME_Id
        ORDER BY 
            "class"."ASMCL_Id",
            "section"."ASMS_Id";
    END IF;

END;
$$;