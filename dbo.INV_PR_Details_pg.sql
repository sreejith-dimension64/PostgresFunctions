CREATE OR REPLACE FUNCTION "dbo"."INV_PR_Details"(
    p_MI_Id BIGINT,
    p_optionflag VARCHAR(50)
)
RETURNS TABLE (
    "INVMPR_Id" BIGINT,
    "INVMPR_PRNo" VARCHAR,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMI_ItemCode" VARCHAR,
    "HRME_Id" BIGINT,
    "HRME_EmployeeCode" VARCHAR,
    "HRME_EmployeeOrder" INTEGER,
    "employeename" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_optionflag = 'PRno' THEN
        RETURN QUERY
        SELECT DISTINCT 
            t."INVMPR_Id",
            t."INVMPR_PRNo",
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::INTEGER,
            NULL::TEXT
        FROM "INV"."INV_M_PurchaseRequisition" t
        WHERE t."MI_Id" = p_MI_Id AND t."INVMPR_ActiveFlg" = true
        ORDER BY t."INVMPR_Id";

    ELSIF p_optionflag = 'Item' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT,
            NULL::VARCHAR,
            a."INVMI_Id",
            a."INVMI_ItemName",
            a."INVMI_ItemCode",
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::INTEGER,
            NULL::TEXT
        FROM "INV"."INV_Master_Item" a,
             "INV"."INV_M_PurchaseRequisition" b,
             "INV"."INV_T_PurchaseRequisition" c
        WHERE a."INVMI_Id" = c."INVMI_Id" 
          AND b."INVMPR_Id" = c."INVMPR_Id" 
          AND a."MI_Id" = p_MI_Id
        ORDER BY a."INVMI_ItemName";

    ELSIF p_optionflag = 'Requestedby' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::VARCHAR,
            a."HRME_Id",
            a."HRME_EmployeeCode",
            a."HRME_EmployeeOrder",
            (CASE WHEN a."HRME_EmployeeFirstName" IS NULL OR a."HRME_EmployeeFirstName" = '' THEN '' ELSE a."HRME_EmployeeFirstName" END ||
             CASE WHEN a."HRME_EmployeeMiddleName" IS NULL OR a."HRME_EmployeeMiddleName" = '' OR a."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeMiddleName" END ||
             CASE WHEN a."HRME_EmployeeLastName" IS NULL OR a."HRME_EmployeeLastName" = '' OR a."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || a."HRME_EmployeeLastName" END)::TEXT
        FROM "HR_Master_Employee" a,
             "INV"."INV_M_PurchaseRequisition" b,
             "INV"."INV_T_PurchaseRequisition" c
        WHERE a."HRME_Id" = b."HRME_Id" 
          AND b."INVMPR_Id" = c."INVMPR_Id" 
          AND a."MI_Id" = p_MI_Id
        ORDER BY a."HRME_EmployeeOrder";

    END IF;

END;
$$;