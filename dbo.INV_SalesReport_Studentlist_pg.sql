CREATE OR REPLACE FUNCTION "dbo"."INV_SalesReport_Studentlist"(
    "@MI_Id" BIGINT,
    "@ASMCL_Id" VARCHAR(20),
    "@ASMS_Id" VARCHAR(20),
    "@type" VARCHAR(20)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "studentname" TEXT,
    "AMST_AdmNo" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@type" = 'C' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."AMST_Id", 
            d."ASMCL_Id",
            NULL::BIGINT AS "ASMS_Id",
            (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
             CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
             CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END)::TEXT AS studentname,
            a."AMST_AdmNo"
        FROM "Adm_M_Student" a,
             "INV"."INV_M_Sales" b,
             "INV"."INV_M_Sales_Student" c,
             "Adm_School_Y_Student" d,
             "Adm_School_M_Class" e
        WHERE a."AMST_Id" = c."AMST_Id" 
          AND c."AMST_Id" = d."AMST_Id" 
          AND b."INVMSL_Id" = c."INVMSL_Id" 
          AND d."ASMCL_Id" = e."ASMCL_Id" 
          AND d."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
          AND b."MI_Id" = "@MI_Id"
        ORDER BY studentname;
    
    ELSIF "@type" = 'CS' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."AMST_Id", 
            d."ASMCL_Id", 
            d."ASMS_Id",
            (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
             CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
             CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END)::TEXT AS studentname,
            a."AMST_AdmNo"
        FROM "Adm_M_Student" a,
             "INV"."INV_M_Sales" b,
             "INV"."INV_M_Sales_Student" c,
             "Adm_School_Y_Student" d,
             "Adm_School_M_Class" e,
             "Adm_School_M_Section" f
        WHERE a."AMST_Id" = c."AMST_Id" 
          AND c."AMST_Id" = d."AMST_Id" 
          AND b."INVMSL_Id" = c."INVMSL_Id" 
          AND d."ASMCL_Id" = e."ASMCL_Id" 
          AND d."ASMS_Id" = f."ASMS_Id" 
          AND d."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
          AND d."ASMS_Id" = "@ASMS_Id"::BIGINT 
          AND b."MI_Id" = "@MI_Id"
        ORDER BY studentname;
    
    END IF;

    RETURN;

END;
$$;