CREATE OR REPLACE FUNCTION "dbo"."HSMINV_SaleReport_Details"(
    p_MI_Id BIGINT,
    p_type VARCHAR(20),
    p_INVMST_Id BIGINT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_INVMST_Id = 0 THEN
        IF p_type = 'Store' THEN
            RETURN QUERY
            SELECT DISTINCT a."INVMST_Id", a."INVMS_StoreName"
            FROM "INV"."INV_Master_Store" a,
                 "INV"."INV_Stock" b,
                 "INV"."INV_M_Sales" c
            WHERE a."INVMST_Id" = b."INVMST_Id" 
              AND b."INVMST_Id" = c."INVMST_Id" 
              AND a."MI_Id" = b."MI_Id" 
              AND a."INVMS_ActiveFlg" = true 
              AND a."MI_Id" = p_MI_Id
            ORDER BY a."INVMST_Id";

        ELSIF p_type = 'Saleno' THEN
            RETURN QUERY
            SELECT DISTINCT a."INVMSL_Id", a."INVMSL_SalesNo"
            FROM "INV"."INV_M_Sales" a,
                 "INV"."INV_T_Sales" b
            WHERE a."INVMSL_Id" = b."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id
            ORDER BY a."INVMSL_Id";

        ELSIF p_type = 'Item' THEN
            RETURN QUERY
            SELECT DISTINCT a."INVMI_Id", a."INVMI_ItemName", a."INVMI_ItemCode"
            FROM "INV"."INV_Master_Item" a,
                 "INV"."INV_M_Sales" b,
                 "INV"."INV_T_Sales" c
            WHERE a."INVMI_Id" = c."INVMI_Id" 
              AND b."INVMSL_Id" = c."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id
            ORDER BY a."INVMI_Id";

        ELSIF p_type = 'Student' THEN
            RETURN QUERY
            SELECT DISTINCT a."AMST_Id", a."AMST_AdmNo",
                   (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
                    CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
                    CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END) as studentname
            FROM "Adm_M_Student" a,
                 "INV"."INV_M_Sales" c,
                 "INV"."INV_M_Sales_Student" d
            WHERE a."AMST_Id" = d."AMST_Id" 
              AND c."INVMSL_Id" = d."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id
            ORDER BY a."AMST_Id";

        ELSIF p_type = 'Staff' THEN
            RETURN QUERY
            SELECT DISTINCT a."HRME_Id", a."HRME_EmployeeCode", a."HRME_EmployeeOrder",
                   (CASE WHEN a."HRME_EmployeeFirstName" IS NULL OR a."HRME_EmployeeFirstName" = '' THEN '' ELSE a."HRME_EmployeeFirstName" END ||
                    CASE WHEN a."HRME_EmployeeMiddleName" IS NULL OR a."HRME_EmployeeMiddleName" = '' OR a."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeMiddleName" END ||
                    CASE WHEN a."HRME_EmployeeLastName" IS NULL OR a."HRME_EmployeeLastName" = '' OR a."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeLastName" END) as employeename
            FROM "HR_Master_Employee" a,
                 "INV"."INV_M_Sales" c,
                 "INV"."INV_M_Sales_Staff" d
            WHERE a."HRME_Id" = d."HRME_Id" 
              AND c."INVMSL_Id" = d."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id
            ORDER BY a."HRME_EmployeeOrder";

        ELSIF p_type = 'Customer' THEN
            RETURN QUERY
            SELECT DISTINCT a."INVMC_Id", a."INVMC_CustomerName"
            FROM "INV"."INV_Master_Customer" a,
                 "INV"."INV_M_Sales" b,
                 "INV"."INV_M_Sales_Customer" c
            WHERE a."INVMC_Id" = c."INVMC_Id" 
              AND b."INVMSL_Id" = c."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id
            ORDER BY a."INVMC_Id";
        END IF;

    ELSE
        IF p_type = 'Store' THEN
            RETURN QUERY
            SELECT DISTINCT a."INVMST_Id", a."INVMS_StoreName"
            FROM "INV"."INV_Master_Store" a,
                 "INV"."INV_Stock" b,
                 "INV"."INV_M_Sales" c
            WHERE a."INVMST_Id" = b."INVMST_Id" 
              AND b."INVMST_Id" = c."INVMST_Id" 
              AND a."MI_Id" = b."MI_Id" 
              AND a."INVMS_ActiveFlg" = true 
              AND a."MI_Id" = p_MI_Id 
              AND a."INVMST_Id" = p_INVMST_Id
            ORDER BY a."INVMST_Id";

        ELSIF p_type = 'Saleno' THEN
            RETURN QUERY
            SELECT DISTINCT a."INVMSL_Id", a."INVMSL_SalesNo"
            FROM "INV"."INV_M_Sales" a,
                 "INV"."INV_T_Sales" b
            WHERE a."INVMSL_Id" = b."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id 
              AND a."INVMST_Id" = p_INVMST_Id
            ORDER BY a."INVMSL_Id";

        ELSIF p_type = 'Item' THEN
            RETURN QUERY
            SELECT DISTINCT a."INVMI_Id", a."INVMI_ItemName", a."INVMI_ItemCode"
            FROM "INV"."INV_Master_Item" a,
                 "INV"."INV_M_Sales" b,
                 "INV"."INV_T_Sales" c
            WHERE a."INVMI_Id" = c."INVMI_Id" 
              AND b."INVMSL_Id" = c."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id 
              AND b."INVMST_Id" = p_INVMST_Id
            ORDER BY a."INVMI_Id";

        ELSIF p_type = 'Student' THEN
            RETURN QUERY
            SELECT DISTINCT a."AMST_Id", a."AMST_AdmNo",
                   (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
                    CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
                    CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END) as studentname
            FROM "Adm_M_Student" a,
                 "INV"."INV_M_Sales" c,
                 "INV"."INV_M_Sales_Student" d
            WHERE a."AMST_Id" = d."AMST_Id" 
              AND c."INVMSL_Id" = d."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id 
              AND c."INVMST_Id" = p_INVMST_Id
            ORDER BY a."AMST_Id";

        ELSIF p_type = 'Staff' THEN
            RETURN QUERY
            SELECT DISTINCT a."HRME_Id", a."HRME_EmployeeCode", a."HRME_EmployeeOrder",
                   (CASE WHEN a."HRME_EmployeeFirstName" IS NULL OR a."HRME_EmployeeFirstName" = '' THEN '' ELSE a."HRME_EmployeeFirstName" END ||
                    CASE WHEN a."HRME_EmployeeMiddleName" IS NULL OR a."HRME_EmployeeMiddleName" = '' OR a."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeMiddleName" END ||
                    CASE WHEN a."HRME_EmployeeLastName" IS NULL OR a."HRME_EmployeeLastName" = '' OR a."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeLastName" END) as employeename
            FROM "HR_Master_Employee" a,
                 "INV"."INV_M_Sales" c,
                 "INV"."INV_M_Sales_Staff" d
            WHERE a."HRME_Id" = d."HRME_Id" 
              AND c."INVMSL_Id" = d."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id 
              AND c."INVMST_Id" = p_INVMST_Id
            ORDER BY a."HRME_EmployeeOrder";

        ELSIF p_type = 'Customer' THEN
            RETURN QUERY
            SELECT DISTINCT a."INVMC_Id", a."INVMC_CustomerName"
            FROM "INV"."INV_Master_Customer" a,
                 "INV"."INV_M_Sales" b,
                 "INV"."INV_M_Sales_Customer" c
            WHERE a."INVMC_Id" = c."INVMC_Id" 
              AND b."INVMSL_Id" = c."INVMSL_Id" 
              AND a."MI_Id" = p_MI_Id 
              AND b."INVMST_Id" = p_INVMST_Id
            ORDER BY a."INVMC_Id";
        END IF;
    END IF;

    RETURN;
END;
$$;