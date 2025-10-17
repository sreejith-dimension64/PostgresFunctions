CREATE OR REPLACE FUNCTION "dbo"."INV_PR_Report"(
    "p_MI_Id" BIGINT,
    "p_startdate" VARCHAR(10),
    "p_enddate" VARCHAR(10),
    "p_PR_Ids" VARCHAR(100),
    "p_INVMI_Ids" VARCHAR(100),
    "p_HRME_Id" VARCHAR(100),
    "p_optionflag" VARCHAR(50)
)
RETURNS TABLE(
    "INVMPR_Id" BIGINT,
    "INVMPR_PRNo" VARCHAR,
    "INVMPR_PRDate" TIMESTAMP,
    "INVMI_Id" BIGINT,
    "INVMI_ItemName" VARCHAR,
    "INVMUOM_Id" BIGINT,
    "INVMUOM_UOMName" VARCHAR,
    "HRME_Id" BIGINT,
    "requestedby" TEXT,
    "INVTPR_PRQty" NUMERIC,
    "INVTPR_PRUnitRate" NUMERIC,
    "INVTPR_ApproxAmount" NUMERIC,
    "INVMPR_Remarks" TEXT,
    "INVMPR_ApproxTotAmount" NUMERIC,
    "INVMPR_PICreatedFlg" BOOLEAN,
    "INVMPR_ActiveFlg" BOOLEAN,
    "INVTPR_Id" BIGINT,
    "INVTPR_ApprovedQty" NUMERIC,
    "INVTPR_Remarks" TEXT,
    "INVTPR_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
    "v_dates" VARCHAR(200);
BEGIN
    IF "p_startdate" != '' AND "p_enddate" != '' THEN
        "v_dates" := 'AND "INVMPR_PRDate"::date BETWEEN TO_DATE(''' || "p_startdate" || ''',''DD/MM/YYYY'') AND TO_DATE(''' || "p_enddate" || ''',''DD/MM/YYYY'')';
    ELSE
        "v_dates" := '';
    END IF;

    IF ("p_optionflag" = 'All') THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "MPR"."INVMPR_Id", "MPR"."INVMPR_PRNo", "MPR"."INVMPR_PRDate", "TPR"."INVMI_Id", "MI"."INVMI_ItemName", 
        "TPR"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "MPR"."HRME_Id",
        ((CASE WHEN "HRME"."HRME_EmployeeFirstName" IS NULL OR "HRME"."HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME"."HRME_EmployeeFirstName" 
        END || CASE WHEN "HRME"."HRME_EmployeeMiddleName" IS NULL OR "HRME"."HRME_EmployeeMiddleName" = '''' OR "HRME"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME"."HRME_EmployeeMiddleName" END 
        || CASE WHEN "HRME"."HRME_EmployeeLastName" IS NULL OR "HRME"."HRME_EmployeeLastName" = '''' OR "HRME"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME"."HRME_EmployeeLastName" END)) AS "requestedby",
        "TPR"."INVTPR_PRQty", "TPR"."INVTPR_PRUnitRate", "TPR"."INVTPR_ApproxAmount", "MPR"."INVMPR_Remarks", "MPR"."INVMPR_ApproxTotAmount", 
        "MPR"."INVMPR_PICreatedFlg",
        "MPR"."INVMPR_ActiveFlg", "TPR"."INVTPR_Id", "TPR"."INVTPR_ApprovedQty", "TPR"."INVTPR_Remarks", "TPR"."INVTPR_ActiveFlg"
        FROM "INV"."INV_M_PurchaseRequisition" "MPR"
        INNER JOIN "INV"."INV_T_PurchaseRequisition" "TPR" ON "MPR"."INVMPR_Id" = "TPR"."INVMPR_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPR"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPR"."INVMUOM_Id"
        INNER JOIN "dbo"."HR_Master_Employee" "HRME" ON "HRME"."HRME_Id" = "MPR"."HRME_Id"
        WHERE "MPR"."INVMPR_ActiveFlg" = TRUE AND "TPR"."INVTPR_ActiveFlg" = TRUE AND "HRME"."HRME_ActiveFlag" = TRUE 
        AND "MPR"."MI_Id" = ' || "p_MI_Id"::TEXT || ' ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_optionflag" = 'PRno' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "MPR"."INVMPR_Id", "MPR"."INVMPR_PRNo", "MPR"."INVMPR_PRDate", "TPR"."INVMI_Id", "MI"."INVMI_ItemName", 
        "TPR"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "MPR"."HRME_Id",
        ((CASE WHEN "HRME"."HRME_EmployeeFirstName" IS NULL OR "HRME"."HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME"."HRME_EmployeeFirstName" 
        END || CASE WHEN "HRME"."HRME_EmployeeMiddleName" IS NULL OR "HRME"."HRME_EmployeeMiddleName" = '''' OR "HRME"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME"."HRME_EmployeeMiddleName" END 
        || CASE WHEN "HRME"."HRME_EmployeeLastName" IS NULL OR "HRME"."HRME_EmployeeLastName" = '''' OR "HRME"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME"."HRME_EmployeeLastName" END)) AS "requestedby",
        "TPR"."INVTPR_PRQty", "TPR"."INVTPR_PRUnitRate", "TPR"."INVTPR_ApproxAmount", "MPR"."INVMPR_Remarks", "MPR"."INVMPR_ApproxTotAmount", 
        "MPR"."INVMPR_PICreatedFlg",
        "MPR"."INVMPR_ActiveFlg", "TPR"."INVTPR_Id", "TPR"."INVTPR_ApprovedQty", "TPR"."INVTPR_Remarks", "TPR"."INVTPR_ActiveFlg"
        FROM "INV"."INV_M_PurchaseRequisition" "MPR"
        INNER JOIN "INV"."INV_T_PurchaseRequisition" "TPR" ON "MPR"."INVMPR_Id" = "TPR"."INVMPR_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPR"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPR"."INVMUOM_Id"
        INNER JOIN "dbo"."HR_Master_Employee" "HRME" ON "HRME"."HRME_Id" = "MPR"."HRME_Id"
        WHERE "MPR"."INVMPR_ActiveFlg" = TRUE AND "TPR"."INVTPR_ActiveFlg" = TRUE AND "HRME"."HRME_ActiveFlag" = TRUE 
        AND "MPR"."INVMPR_Id" IN (' || "p_PR_Ids" || ') AND "MPR"."MI_Id" = ' || "p_MI_Id"::TEXT || ' ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_optionflag" = 'Item' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "MPR"."INVMPR_Id", "MPR"."INVMPR_PRNo", "MPR"."INVMPR_PRDate", "TPR"."INVMI_Id", "MI"."INVMI_ItemName", 
        "TPR"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "MPR"."HRME_Id",
        ((CASE WHEN "HRME"."HRME_EmployeeFirstName" IS NULL OR "HRME"."HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME"."HRME_EmployeeFirstName" 
        END || CASE WHEN "HRME"."HRME_EmployeeMiddleName" IS NULL OR "HRME"."HRME_EmployeeMiddleName" = '''' OR "HRME"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME"."HRME_EmployeeMiddleName" END 
        || CASE WHEN "HRME"."HRME_EmployeeLastName" IS NULL OR "HRME"."HRME_EmployeeLastName" = '''' OR "HRME"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME"."HRME_EmployeeLastName" END)) AS "requestedby",
        "TPR"."INVTPR_PRQty", "TPR"."INVTPR_PRUnitRate", "TPR"."INVTPR_ApproxAmount", "MPR"."INVMPR_Remarks", "MPR"."INVMPR_ApproxTotAmount", 
        "MPR"."INVMPR_PICreatedFlg",
        "MPR"."INVMPR_ActiveFlg", "TPR"."INVTPR_Id", "TPR"."INVTPR_ApprovedQty", "TPR"."INVTPR_Remarks", "TPR"."INVTPR_ActiveFlg"
        FROM "INV"."INV_M_PurchaseRequisition" "MPR"
        INNER JOIN "INV"."INV_T_PurchaseRequisition" "TPR" ON "MPR"."INVMPR_Id" = "TPR"."INVMPR_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPR"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPR"."INVMUOM_Id"
        INNER JOIN "dbo"."HR_Master_Employee" "HRME" ON "HRME"."HRME_Id" = "MPR"."HRME_Id"
        WHERE "MPR"."INVMPR_ActiveFlg" = TRUE AND "TPR"."INVTPR_ActiveFlg" = TRUE AND "HRME"."HRME_ActiveFlag" = TRUE 
        AND "TPR"."INVMI_Id" IN (' || "p_INVMI_Ids" || ') AND "MPR"."MI_Id" = ' || "p_MI_Id"::TEXT || ' ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
        
    ELSIF "p_optionflag" = 'Requestedby' THEN
        "v_Slqdymaic" := '
        SELECT DISTINCT "MPR"."INVMPR_Id", "MPR"."INVMPR_PRNo", "MPR"."INVMPR_PRDate", "TPR"."INVMI_Id", "MI"."INVMI_ItemName", 
        "TPR"."INVMUOM_Id", "UOM"."INVMUOM_UOMName",
        "MPR"."HRME_Id",
        ((CASE WHEN "HRME"."HRME_EmployeeFirstName" IS NULL OR "HRME"."HRME_EmployeeFirstName" = '''' THEN '''' ELSE "HRME"."HRME_EmployeeFirstName" 
        END || CASE WHEN "HRME"."HRME_EmployeeMiddleName" IS NULL OR "HRME"."HRME_EmployeeMiddleName" = '''' OR "HRME"."HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME"."HRME_EmployeeMiddleName" END 
        || CASE WHEN "HRME"."HRME_EmployeeLastName" IS NULL OR "HRME"."HRME_EmployeeLastName" = '''' OR "HRME"."HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME"."HRME_EmployeeLastName" END)) AS "requestedby",
        "TPR"."INVTPR_PRQty", "TPR"."INVTPR_PRUnitRate", "TPR"."INVTPR_ApproxAmount", "MPR"."INVMPR_Remarks", "MPR"."INVMPR_ApproxTotAmount", 
        "MPR"."INVMPR_PICreatedFlg",
        "MPR"."INVMPR_ActiveFlg", "TPR"."INVTPR_Id", "TPR"."INVTPR_ApprovedQty", "TPR"."INVTPR_Remarks", "TPR"."INVTPR_ActiveFlg"
        FROM "INV"."INV_M_PurchaseRequisition" "MPR"
        INNER JOIN "INV"."INV_T_PurchaseRequisition" "TPR" ON "MPR"."INVMPR_Id" = "TPR"."INVMPR_Id"
        INNER JOIN "INV"."INV_Master_Item" "MI" ON "MI"."INVMI_Id" = "TPR"."INVMI_Id"
        INNER JOIN "INV"."INV_Master_UOM" "UOM" ON "UOM"."INVMUOM_Id" = "TPR"."INVMUOM_Id"
        INNER JOIN "dbo"."HR_Master_Employee" "HRME" ON "HRME"."HRME_Id" = "MPR"."HRME_Id"
        WHERE "MPR"."INVMPR_ActiveFlg" = TRUE AND "TPR"."INVTPR_ActiveFlg" = TRUE AND "HRME"."HRME_ActiveFlag" = TRUE 
        AND "MPR"."HRME_Id" IN (' || "p_HRME_Id" || ') AND "MPR"."MI_Id" = ' || "p_MI_Id"::TEXT || ' ' || "v_dates";
        
        RETURN QUERY EXECUTE "v_Slqdymaic";
    END IF;

    RETURN;
END;
$$;