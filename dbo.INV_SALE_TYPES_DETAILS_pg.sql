CREATE OR REPLACE FUNCTION "dbo"."INV_SALE_TYPES_DETAILS"(
    "MI_Id" BIGINT,
    "INVMSL_Id" BIGINT,
    "saletype" VARCHAR(20)
)
RETURNS TABLE (
    "INVMSLS_Id" BIGINT,
    "INVMSL_Id" BIGINT,
    "AMST_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "studentname" TEXT,
    "INVMSLS_ActiveFlg" BOOLEAN,
    "INVMSLST_Id" BIGINT,
    "HRME_Id" BIGINT,
    "employeename" TEXT,
    "HRME_EmployeeCode" VARCHAR,
    "INVMSLST_ActiveFlg" BOOLEAN,
    "INVMSLC_Id" BIGINT,
    "INVMC_Id" BIGINT,
    "INVMC_CustomerName" VARCHAR,
    "INVMC_CustomerContactPerson" VARCHAR,
    "INVMSLC_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "saletype" = 'Student' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."INVMSLS_Id",
            a."INVMSL_Id",
            a."AMST_Id",
            a."ASMCL_Id",
            a."ASMS_Id",
            c."ASMCL_ClassName",
            d."ASMC_SectionName",
            (CASE WHEN e."AMST_FirstName" IS NULL OR e."AMST_FirstName" = '' THEN '' ELSE e."AMST_FirstName" END ||
             CASE WHEN e."AMST_MiddleName" IS NULL OR e."AMST_MiddleName" = '' OR e."AMST_MiddleName" = '0' THEN '' ELSE ' ' || e."AMST_MiddleName" END ||
             CASE WHEN e."AMST_LastName" IS NULL OR e."AMST_LastName" = '' OR e."AMST_LastName" = '0' THEN '' ELSE ' ' || e."AMST_LastName" END)::TEXT AS studentname,
            a."INVMSLS_ActiveFlg",
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::TEXT,
            NULL::VARCHAR,
            NULL::BOOLEAN,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::BOOLEAN
        FROM "INV"."INV_M_Sales_Student" a
        INNER JOIN "INV"."INV_M_Sales" b ON a."INVMSL_Id" = b."INVMSL_Id"
        INNER JOIN "Adm_School_M_Class" c ON a."ASMCL_Id" = c."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" d ON a."ASMS_Id" = d."ASMS_Id"
        INNER JOIN "Adm_M_Student" e ON a."AMST_Id" = e."AMST_Id"
        WHERE b."MI_Id" = "MI_Id" AND a."INVMSL_Id" = "INVMSL_Id";

    ELSIF "saletype" = 'Staff' THEN
        RETURN QUERY
        SELECT 
            NULL::BIGINT,
            a."INVMSL_Id",
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::TEXT,
            NULL::BOOLEAN,
            a."INVMSLST_Id",
            a."HRME_Id",
            (CASE WHEN c."HRME_EmployeeFirstName" IS NULL OR c."HRME_EmployeeFirstName" = '' THEN '' ELSE c."HRME_EmployeeFirstName" END ||
             CASE WHEN c."HRME_EmployeeMiddleName" IS NULL OR c."HRME_EmployeeMiddleName" = '' OR c."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || c."HRME_EmployeeMiddleName" END ||
             CASE WHEN c."HRME_EmployeeLastName" IS NULL OR c."HRME_EmployeeLastName" = '' OR c."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || c."HRME_EmployeeLastName" END)::TEXT AS employeename,
            c."HRME_EmployeeCode",
            a."INVMSLST_ActiveFlg",
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::BOOLEAN
        FROM "INV"."INV_M_Sales_Staff" a
        INNER JOIN "INV"."INV_M_Sales" b ON a."INVMSL_Id" = b."INVMSL_Id"
        INNER JOIN "HR_Master_Employee" c ON a."HRME_Id" = c."HRME_Id"
        WHERE b."MI_Id" = "MI_Id" AND a."INVMSL_Id" = "INVMSL_Id";

    ELSIF "saletype" = 'Customer' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT,
            a."INVMSL_Id",
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::TEXT,
            NULL::BOOLEAN,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::TEXT,
            NULL::VARCHAR,
            NULL::BOOLEAN,
            a."INVMSLC_Id",
            a."INVMC_Id",
            c."INVMC_CustomerName",
            c."INVMC_CustomerContactPerson",
            a."INVMSLC_ActiveFlg"
        FROM "INV"."INV_M_Sales_Customer" a
        INNER JOIN "INV"."INV_M_Sales" b ON a."INVMSL_Id" = b."INVMSL_Id"
        INNER JOIN "INV"."INV_Master_Customer" c ON a."INVMC_Id" = c."INVMC_Id"
        WHERE b."MI_Id" = "MI_Id" AND a."INVMSL_Id" = "INVMSL_Id";

    END IF;

    RETURN;

END;
$$;