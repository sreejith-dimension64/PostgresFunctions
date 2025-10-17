CREATE OR REPLACE FUNCTION "dbo"."INV_IC_Report_Details"(
    "MI_Id" BIGINT,
    "optionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMI_ItemCode" VARCHAR,
    "HRME_Id" BIGINT,
    "HRME_EmployeeCode" VARCHAR,
    "HRME_EmployeeOrder" INTEGER,
    "employeename" TEXT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMD_Order" INTEGER,
    "AMST_Id" BIGINT,
    "AMST_AdmNo" VARCHAR,
    "studentname" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "optionflag" = 'Item' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode",
            NULL::BIGINT AS "HRME_Id",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::INTEGER AS "HRME_EmployeeOrder",
            NULL::TEXT AS "employeename",
            NULL::BIGINT AS "HRMD_Id",
            NULL::VARCHAR AS "HRMD_DepartmentName",
            NULL::INTEGER AS "HRMD_Order",
            NULL::BIGINT AS "AMST_Id",
            NULL::VARCHAR AS "AMST_AdmNo",
            NULL::TEXT AS "studentname"
        FROM "INV"."INV_Master_Item" a
        INNER JOIN "INV"."INV_T_ItemConsumption" b ON a."INVMI_Id" = b."INVMI_Id"
        INNER JOIN "INV"."INV_M_ItemConsumption" c ON c."INVMIC_Id" = b."INVMIC_Id"
        WHERE a."INVMI_ActiveFlg" = 1 
            AND c."INVMIC_ActiveFlg" = 1 
            AND b."INVTIC_ActiveFlg" = 1 
            AND a."MI_Id" = "MI_Id";

    ELSIF "optionflag" = 'Staff' THEN
        RETURN QUERY
        SELECT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::VARCHAR AS "INVMI_ItemName",
            NULL::VARCHAR AS "INVMI_ItemCode",
            b."HRME_Id",
            a."HRME_EmployeeCode",
            a."HRME_EmployeeOrder",
            (CASE WHEN a."HRME_EmployeeFirstName" IS NULL OR a."HRME_EmployeeFirstName" = '' THEN '' ELSE a."HRME_EmployeeFirstName" END ||
             CASE WHEN a."HRME_EmployeeMiddleName" IS NULL OR a."HRME_EmployeeMiddleName" = '' OR a."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeMiddleName" END ||
             CASE WHEN a."HRME_EmployeeLastName" IS NULL OR a."HRME_EmployeeLastName" = '' OR a."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeLastName" END)::TEXT AS "employeename",
            NULL::BIGINT AS "HRMD_Id",
            NULL::VARCHAR AS "HRMD_DepartmentName",
            NULL::INTEGER AS "HRMD_Order",
            NULL::BIGINT AS "AMST_Id",
            NULL::VARCHAR AS "AMST_AdmNo",
            NULL::TEXT AS "studentname"
        FROM "HR_Master_Employee" a
        INNER JOIN "INV"."INV_M_IC_Staff" b ON a."HRME_Id" = b."HRME_Id"
        INNER JOIN "INV"."INV_M_ItemConsumption" c ON b."INVMIC_Id" = c."INVMIC_Id"
        WHERE a."HRME_ActiveFlag" = 1 
            AND b."INVMICST_ActiveFlg" = 1 
            AND c."INVMIC_ActiveFlg" = 1 
            AND a."MI_Id" = "MI_Id"
        ORDER BY a."HRME_EmployeeOrder";

    ELSIF "optionflag" = 'Department' THEN
        RETURN QUERY
        SELECT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::VARCHAR AS "INVMI_ItemName",
            NULL::VARCHAR AS "INVMI_ItemCode",
            NULL::BIGINT AS "HRME_Id",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::INTEGER AS "HRME_EmployeeOrder",
            NULL::TEXT AS "employeename",
            b."HRMD_Id",
            a."HRMD_DepartmentName",
            a."HRMD_Order",
            NULL::BIGINT AS "AMST_Id",
            NULL::VARCHAR AS "AMST_AdmNo",
            NULL::TEXT AS "studentname"
        FROM "HR_Master_Department" a
        INNER JOIN "INV"."INV_M_IC_Department" b ON a."HRMD_Id" = b."HRMD_Id"
        INNER JOIN "INV"."INV_M_ItemConsumption" c ON c."INVMIC_Id" = b."INVMIC_Id"
        WHERE a."HRMD_ActiveFlag" = 1 
            AND b."INVMICD_ActiveFlg" = 1 
            AND c."INVMIC_ActiveFlg" = 1 
            AND a."MI_Id" = "MI_Id"
        ORDER BY a."HRMD_Order";

    ELSIF "optionflag" = 'Student' THEN
        RETURN QUERY
        SELECT 
            NULL::BIGINT AS "INVMI_Id",
            NULL::VARCHAR AS "INVMI_ItemName",
            NULL::VARCHAR AS "INVMI_ItemCode",
            NULL::BIGINT AS "HRME_Id",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::INTEGER AS "HRME_EmployeeOrder",
            NULL::TEXT AS "employeename",
            NULL::BIGINT AS "HRMD_Id",
            NULL::VARCHAR AS "HRMD_DepartmentName",
            NULL::INTEGER AS "HRMD_Order",
            b."AMST_Id",
            a."AMST_AdmNo",
            (CASE WHEN a."AMST_FirstName" IS NULL OR a."AMST_FirstName" = '' THEN '' ELSE a."AMST_FirstName" END ||
             CASE WHEN a."AMST_MiddleName" IS NULL OR a."AMST_MiddleName" = '' OR a."AMST_MiddleName" = '0' THEN '' ELSE ' ' || a."AMST_MiddleName" END ||
             CASE WHEN a."AMST_LastName" IS NULL OR a."AMST_LastName" = '' OR a."AMST_LastName" = '0' THEN '' ELSE ' ' || a."AMST_LastName" END)::TEXT AS "studentname"
        FROM "Adm_M_Student" a
        INNER JOIN "INV"."INV_M_IC_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "INV"."INV_M_ItemConsumption" c ON c."INVMIC_Id" = b."INVMIC_Id"
        WHERE a."AMST_ActiveFlag" = 1 
            AND b."INVMICS_ActiveFlg" = 1 
            AND c."INVMIC_ActiveFlg" = 1 
            AND a."MI_Id" = "MI_Id"
        ORDER BY "studentname";

    END IF;

    RETURN;

END;
$$;