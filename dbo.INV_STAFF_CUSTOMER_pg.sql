CREATE OR REPLACE FUNCTION "dbo"."INV_STAFF_CUSTOMER"(
    p_MI_Id BIGINT,
    p_type VARCHAR(20)
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "HRME_EmployeeCode" VARCHAR,
    "HRME_EmployeeOrder" INTEGER,
    "employeename" TEXT,
    "INVMC_Id" BIGINT,
    "INVMC_CustomerName" VARCHAR,
    "INVMC_CustomerContactPerson" VARCHAR,
    "INVMC_CustomerContactNo" VARCHAR,
    "INVMC_CustomerAddress" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_type = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."HRME_Id",
            a."HRME_EmployeeCode",
            a."HRME_EmployeeOrder",
            (CASE WHEN a."HRME_EmployeeFirstName" IS NULL OR a."HRME_EmployeeFirstName" = '' THEN '' ELSE a."HRME_EmployeeFirstName" END ||
             CASE WHEN a."HRME_EmployeeMiddleName" IS NULL OR a."HRME_EmployeeMiddleName" = '' OR a."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeMiddleName" END ||
             CASE WHEN a."HRME_EmployeeLastName" IS NULL OR a."HRME_EmployeeLastName" = '' OR a."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeLastName" END)::TEXT AS "employeename",
            NULL::BIGINT AS "INVMC_Id",
            NULL::VARCHAR AS "INVMC_CustomerName",
            NULL::VARCHAR AS "INVMC_CustomerContactPerson",
            NULL::VARCHAR AS "INVMC_CustomerContactNo",
            NULL::TEXT AS "INVMC_CustomerAddress"
        FROM "HR_Master_Employee" a
        WHERE a."MI_Id" = p_MI_Id AND a."HRME_ActiveFlag" = 1
        ORDER BY a."HRME_EmployeeOrder";
        
    ELSIF p_type = 'Customer' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT AS "HRME_Id",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::INTEGER AS "HRME_EmployeeOrder",
            NULL::TEXT AS "employeename",
            a."INVMC_Id",
            a."INVMC_CustomerName",
            a."INVMC_CustomerContactPerson",
            a."INVMC_CustomerContactNo",
            a."INVMC_CustomerAddress"
        FROM "INV"."INV_Master_Customer" a
        WHERE a."MI_Id" = p_MI_Id AND a."INVMC_ActiveFlg" = 1
        ORDER BY a."INVMC_Id";
        
    END IF;

END;
$$;