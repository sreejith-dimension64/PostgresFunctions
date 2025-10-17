CREATE OR REPLACE FUNCTION "dbo"."INV_PurchageOrderItemsForApproval"(
    "User_Id" bigint,
    "INVMPO_Id" bigint
)
RETURNS TABLE(
    "INVMPO_Id" bigint,
    "INVMPI_Id" bigint,
    "INVMI_Id" bigint,
    "INVMI_ItemName" varchar,
    "INVMUOM_Id" bigint,
    "INVMUOM_UOMName" varchar,
    "INVTPO_Amount" numeric,
    "INVTPO_TaxAmount" numeric,
    "INVTPO_POQty" numeric,
    "INVTPO_ApproveQty" numeric,
    "INVTPO_Remarks" varchar,
    "INVTPO_RatePerUnit" numeric,
    "INVTPO_Id" bigint,
    "INVTPOAPP_RejectFlg" boolean
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SanctionLevelNo" bigint;
    "PrevUser_Id" bigint;
    "MaxSanctionLevelNo" bigint;
BEGIN

    SELECT "HRPAON_SanctionLevelNo" INTO "SanctionLevelNo"
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'PO' AND "IVRMUL_Id" = "User_Id";

    SELECT MAX("HRPAON_SanctionLevelNo") INTO "MaxSanctionLevelNo"
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'PO';

    IF ("SanctionLevelNo" = 1) THEN
        
        RETURN QUERY
        SELECT DISTINCT "IMP"."INVMPO_Id", "ITP"."INVMPI_Id", "ITP"."INVMI_Id", "IMI"."INVMI_ItemName", 
               "ITP"."INVMUOM_Id", "IMU"."INVMUOM_UOMName",
               "INVTPO_Amount", "INVTPO_TaxAmount", "INVTPO_POQty" AS "INVTPO_POQty", 
               "INVTPO_POQty" AS "INVTPO_ApproveQty", ''::varchar AS "INVTPO_Remarks", 
               "INVTPO_RatePerUnit", "ITP"."INVTPO_Id" AS "INVTPO_Id", NULL::boolean AS "INVTPOAPP_RejectFlg"
        FROM "INV"."INV_M_PurchaseOrder" "IMP"
        INNER JOIN "INV"."INV_T_PurchaseOrder" "ITP" ON "IMP"."MI_Id" = "ITP"."MI_Id" AND "IMP"."INVMPO_Id" = "ITP"."INVMPO_Id"
        INNER JOIN "INV"."INV_Master_Item" "IMI" ON "IMI"."INVMI_Id" = "ITP"."INVMI_Id" AND "IMI"."MI_Id" = "ITP"."MI_Id" AND "IMI"."INVMI_ActiveFlg" = 1
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."INVMUOM_Id" = "ITP"."INVMUOM_Id" AND "IMU"."MI_Id" = "ITP"."MI_Id" AND "IMU"."INVMUOM_ActiveFlg" = 1
        WHERE "ITP"."INVMPO_Id" = "INVMPO_Id" AND "INVTPO_ActiveFlg" = 1 
          AND ("INVTPO_RejectFlg" IS NULL OR "INVTPO_RejectFlg" = true OR "INVTPO_RejectFlg" = false)
          AND ("INVTPO_ApproveQty" IS NULL OR "INVTPO_ApproveQty" = 0 OR "INVTPO_ApproveQty" = 0.00);

    ELSE
        
        IF ("SanctionLevelNo" <> 1) THEN
            
            SELECT DISTINCT "IVRMUL_Id" INTO "PrevUser_Id"
            FROM "HR_Process_Authorisation" "PA"
            INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
            WHERE "HRPA_TypeFlag" = 'PO' 
              AND "HRPAON_SanctionLevelNo" = (
                  SELECT DISTINCT ("HRPAON_SanctionLevelNo") - 1
                  FROM "HR_Process_Authorisation" "PA"
                  INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                  WHERE "HRPA_TypeFlag" = 'PO' AND "IVRMUL_Id" = "User_Id"
              )
            LIMIT 1;

            RETURN QUERY
            SELECT DISTINCT "INVMPI_Id", "POA"."INVMPO_Id", "TPOA"."INVMI_Id", "INVMI_ItemName", 
                   "TPOA"."INVMUOM_Id", "INVMUOM_UOMName",
                   "INVTPOAPP_POQty" AS "INVTPO_POQty", "INVTPOAPP_Amount" AS "INVTPO_Amount", 
                   "INVTPOAPP_ApprovedQty" AS "INVTPO_ApproveQty", ''::varchar AS "INVTPO_Remarks", 
                   "INVTPOAPP_RatePerUnit" AS "INVTPO_RatePerUnit", "TPOA"."INVTPO_Id" AS "INVTPO_Id", 
                   "TPOA"."INVTPOAPP_RejectFlg"
            FROM "INV"."INV_M_PurchaseOrder_Approval" "POA"
            INNER JOIN "INV"."INV_T_PurchaseOrder_Approval" "TPOA" ON "POA"."INVMPOAPP_Id" = "TPOA"."INVMPOAPP_Id"
            INNER JOIN "Master_Institution" "MI" ON "POA"."MI_Id" = "MI"."MI_Id" AND "POA"."INVMPOAPP_ActiveFlg" = 1
            INNER JOIN "INV"."INV_Master_Item" "IMI" ON "IMI"."INVMI_Id" = "TPOA"."INVMI_Id" AND "IMI"."MI_Id" = "TPOA"."MI_Id" AND "IMI"."INVMI_ActiveFlg" = 1
            INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."INVMUOM_Id" = "TPOA"."INVMUOM_Id" AND "IMU"."MI_Id" = "TPOA"."MI_Id" AND "IMU"."INVMUOM_ActiveFlg" = 1
            WHERE ("POA"."INVMPOAPP_RejectFlg" = false OR "POA"."INVMPOAPP_RejectFlg" = true) 
              AND "POA"."INVMPO_Id" = "INVMPO_Id" 
              AND "POA"."INVMPOAPP_ApprovedBy" = "PrevUser_Id";

        END IF;
        
    END IF;

    RETURN;

END;
$$;