CREATE OR REPLACE FUNCTION "dbo"."INV_AMSTID_CLASS_SECTION"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "type" VARCHAR(20)
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "ASMCL_Id" BIGINT,
    "ASMCL_ClassName" TEXT,
    "ASMS_Id" BIGINT,
    "ASMC_SectionName" TEXT,
    "ASMCL_Order" INTEGER,
    "clsSec" TEXT,
    "ASMC_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "type" = 'I' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."AMST_Id",
            (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
             CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
             CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END)::TEXT AS "studentname",
            d."ASMCL_Id",
            d."ASMCL_ClassName"::TEXT,
            e."ASMS_Id",
            e."ASMC_SectionName"::TEXT,
            NULL::INTEGER AS "ASMCL_Order",
            NULL::TEXT AS "clsSec",
            NULL::INTEGER AS "ASMC_Order"
        FROM "Adm_M_Student" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."MI_Id" = c."MI_Id" AND b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" e ON b."ASMS_Id" = e."ASMS_Id"
        WHERE a."MI_Id" = "MI_Id" 
            AND c."ASMAY_Id" = "ASMAY_Id"
            AND a."AMST_ActiveFlag" = 1 
            AND a."AMST_SOL" = 'S'
        ORDER BY "studentname";

    ELSIF "type" = 'C' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "AMST_Id",
            NULL::TEXT AS "studentname",
            d."ASMCL_Id",
            d."ASMCL_ClassName"::TEXT,
            NULL::BIGINT AS "ASMS_Id",
            NULL::TEXT AS "ASMC_SectionName",
            d."ASMCL_Order",
            NULL::TEXT AS "clsSec",
            NULL::INTEGER AS "ASMC_Order"
        FROM "Adm_M_Student" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."MI_Id" = c."MI_Id" AND b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
        WHERE a."MI_Id" = "MI_Id" 
            AND c."ASMAY_Id" = "ASMAY_Id"
        ORDER BY d."ASMCL_Order";

    ELSIF "type" = 'CS' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "AMST_Id",
            NULL::TEXT AS "studentname",
            d."ASMCL_Id",
            NULL::TEXT AS "ASMCL_ClassName",
            e."ASMS_Id",
            NULL::TEXT AS "ASMC_SectionName",
            d."ASMCL_Order",
            (d."ASMCL_ClassName" || ' : ' || e."ASMC_SectionName")::TEXT AS "clsSec",
            e."ASMC_Order"
        FROM "Adm_M_Student" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."MI_Id" = c."MI_Id" AND b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" e ON b."ASMS_Id" = e."ASMS_Id"
        WHERE a."MI_Id" = "MI_Id" 
            AND c."ASMAY_Id" = "ASMAY_Id"
        ORDER BY d."ASMCL_Order", e."ASMC_Order";

    END IF;

    RETURN;

END;
$$;