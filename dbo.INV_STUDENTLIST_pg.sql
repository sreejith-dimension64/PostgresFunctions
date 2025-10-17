CREATE OR REPLACE FUNCTION "dbo"."INV_STUDENTLIST"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@ASMCL_Id" VARCHAR(20),
    "@ASMS_Id" VARCHAR(20),
    "@type" VARCHAR(20)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "studentname" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "@type" = 'C' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."AMST_Id",
            d."ASMCL_Id",
            e."ASMS_Id",
            (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
             CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
             CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END) AS "studentname"
        FROM "Adm_M_Student" a,
             "Adm_School_Y_Student" b,
             "Adm_School_M_Academic_Year" c,
             "Adm_School_M_Class" d,
             "Adm_School_M_Section" e
        WHERE a."AMST_Id" = b."AMST_Id" 
          AND a."MI_Id" = c."MI_Id" 
          AND b."ASMCL_Id" = d."ASMCL_Id" 
          AND b."ASMS_Id" = e."ASMS_Id" 
          AND b."ASMAY_Id" = c."ASMAY_Id" 
          AND a."MI_Id" = "@MI_Id" 
          AND c."ASMAY_Id" = "@ASMAY_Id" 
          AND d."ASMCL_Id" = "@ASMCL_Id"
        ORDER BY "studentname";
        
    ELSIF "@type" = 'CS' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."AMST_Id",
            d."ASMCL_Id",
            e."ASMS_Id",
            (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
             CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
             CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END) AS "studentname"
        FROM "Adm_M_Student" a,
             "Adm_School_Y_Student" b,
             "Adm_School_M_Academic_Year" c,
             "Adm_School_M_Class" d,
             "Adm_School_M_Section" e
        WHERE a."AMST_Id" = b."AMST_Id" 
          AND a."MI_Id" = c."MI_Id" 
          AND b."ASMCL_Id" = d."ASMCL_Id" 
          AND b."ASMS_Id" = e."ASMS_Id" 
          AND b."ASMAY_Id" = c."ASMAY_Id" 
          AND a."MI_Id" = "@MI_Id" 
          AND c."ASMAY_Id" = "@ASMAY_Id" 
          AND d."ASMCL_Id" = "@ASMCL_Id" 
          AND e."ASMS_Id" = "@ASMS_Id"
        ORDER BY "studentname";
        
    END IF;
    
    RETURN;
END;
$$;