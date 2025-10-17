CREATE OR REPLACE FUNCTION "dbo"."INV_AMSTID_CLASS_SECTION_ITEM_SALENO"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_type VARCHAR(20)
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_type = 'S' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."AMST_Id",
            (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
             CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
             CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END) AS studentname,
            a."AMST_AdmNo",
            d."ASMCL_Id",
            d."ASMCL_ClassName",
            e."ASMS_Id",
            e."ASMC_SectionName"
        FROM "Adm_M_Student" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."MI_Id" = c."MI_Id" AND b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" e ON b."ASMS_Id" = e."ASMS_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND c."ASMAY_Id" = p_ASMAY_Id 
            AND a."AMST_ActiveFlag" = 1 
            AND a."AMST_SOL" = 'S'
        ORDER BY studentname;

    ELSIF p_type = 'C' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."ASMCL_Id",
            d."ASMCL_ClassName",
            d."ASMCL_Order"
        FROM "Adm_M_Student" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."MI_Id" = c."MI_Id" AND b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND c."ASMAY_Id" = p_ASMAY_Id 
            AND a."AMST_ActiveFlag" = 1 
            AND a."AMST_SOL" = 'S'
        ORDER BY d."ASMCL_Order";

    ELSIF p_type = 'CS' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."ASMCL_Id",
            e."ASMS_Id",
            (d."ASMCL_ClassName" || ' : ' || e."ASMC_SectionName") AS clsSec,
            d."ASMCL_Order",
            e."ASMC_Order"
        FROM "Adm_M_Student" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON a."MI_Id" = c."MI_Id" AND b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" d ON b."ASMCL_Id" = d."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" e ON b."ASMS_Id" = e."ASMS_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND c."ASMAY_Id" = p_ASMAY_Id 
            AND a."AMST_ActiveFlag" = 1 
            AND a."AMST_SOL" = 'S'
        ORDER BY d."ASMCL_Order", e."ASMC_Order";

    ELSIF p_type = 'I' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_Stock" b ON a."INVMI_Id" = b."INVMI_Id" AND a."MI_Id" = b."MI_Id"
        WHERE a."INVMI_ActiveFlg" = 1 
            AND a."MI_Id" = p_MI_Id
        ORDER BY a."INVMI_ItemName";

    ELSIF p_type = 'SN' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "INVMSL_Id",
            "INVMSL_SalesNo"
        FROM "INV"."INV_M_Sales"
        WHERE "INVMSL_ActiveFlg" = 1 
            AND "MI_Id" = p_MI_Id
        ORDER BY "INVMSL_Id";

    END IF;

    RETURN;

END;
$$;