CREATE OR REPLACE FUNCTION "dbo"."INV_PurchageIndentItemsForApproval"(
    "User_Id" bigint,
    "INVMPI_Id" bigint
)
RETURNS TABLE(
    "INVMPI_Id" bigint,
    "INVMI_Id" bigint,
    "INVMI_ItemName" varchar,
    "INVMUOM_Id" bigint,
    "INVMUOM_UOMName" varchar,
    "INVTPI_PRQty" numeric,
    "INVTPI_ApproxAmount" numeric,
    "INVTPI_PIQty" numeric,
    "INVTPIAPP_ApprovedQty" numeric,
    "INVTPI_Remarks" varchar,
    "INVTPI_PIUnitRate" numeric,
    "INVTPI_Id" bigint,
    "INVMPR_Id" bigint,
    "INVMPIAPP_RejectFlg" integer
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
    WHERE "HRPA_TypeFlag" = 'PI' AND "IVRMUL_Id" = "User_Id"
    LIMIT 1;

    SELECT MAX("HRPAON_SanctionLevelNo") INTO "MaxSanctionLevelNo"
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'PI';

    IF("SanctionLevelNo" = 1) THEN
        RETURN QUERY
        SELECT DISTINCT 
            "ITP"."INVMPI_Id",
            "ITP"."INVMI_Id",
            "IMI"."INVMI_ItemName",
            "ITP"."INVMUOM_Id",
            "IMU"."INVMUOM_UOMName",
            "INVTPI_PRQty",
            "INVTPI_ApproxAmount",
            "INVTPI_PIQty" AS "INVTPI_PIQty",
            "INVTPI_PIQty" AS "INVTPIAPP_ApprovedQty",
            "INVTPI_Remarks",
            "INVTPI_PIUnitRate",
            "ITP"."INVTPI_Id",
            "ITP"."INVMPR_Id",
            NULL::integer AS "INVMPIAPP_RejectFlg"
        FROM "INV"."INV_M_PurchaseIndent" "IMP"
        INNER JOIN "INV"."INV_T_PurchaseIndent" "ITP" ON "IMP"."MI_Id" = "ITP"."MI_Id" AND "IMP"."INVMPI_Id" = "ITP"."INVMPI_Id"
        INNER JOIN "INV"."INV_Master_Item" "IMI" ON "IMI"."INVMI_Id" = "ITP"."INVMI_Id" AND "IMI"."MI_Id" = "ITP"."MI_Id" AND "IMI"."INVMI_ActiveFlg" = 1
        INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."INVMUOM_Id" = "ITP"."INVMUOM_Id" AND "IMU"."MI_Id" = "ITP"."MI_Id" AND "IMU"."INVMUOM_ActiveFlg" = 1
        WHERE "ITP"."INVMPI_Id" = "INVMPI_Id" 
            AND "INVTPI_ActiveFlg" = 1 
            AND ("INVTPI_RejectFlg" IS NULL OR "INVTPI_RejectFlg" = 1 OR "INVTPI_RejectFlg" = 0)
            AND ("INVTPI_ApproveQty" IS NULL OR "INVTPI_ApproveQty" = 0 OR "INVTPI_ApproveQty" = 0.00);
    ELSE
        IF("SanctionLevelNo" <> 1) THEN
            SELECT DISTINCT "IVRMUL_Id" INTO "PrevUser_Id"
            FROM "HR_Process_Authorisation" "PA"
            INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
            WHERE "HRPA_TypeFlag" = 'PI' 
                AND "HRPAON_SanctionLevelNo" = (
                    SELECT DISTINCT ("HRPAON_SanctionLevelNo") - 1 
                    FROM "HR_Process_Authorisation" "PA"
                    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                    WHERE "HRPA_TypeFlag" = 'PI' AND "IVRMUL_Id" = "User_Id"
                )
            LIMIT 1;

            RETURN QUERY
            SELECT DISTINCT 
                "INVMPI_Id",
                "TPIA"."INVMI_Id",
                "INVMI_ItemName",
                "TPIA"."INVMUOM_Id",
                "INVMUOM_UOMName",
                "INVTPIAPP_PRQty" AS "INVTPI_PRQty",
                "INVTPIAPP_ApproxAmount" AS "INVTPI_ApproxAmount",
                "INVTPIAPP_PIQty" AS "INVTPI_PIQty",
                "INVTPIAPP_ApprovedQty" AS "INVTPIAPP_ApprovedQty",
                ''::varchar AS "INVTPI_Remarks",
                "INVTPIAPP_PIUnitRate" AS "INVTPI_PIUnitRate",
                "TPIA"."INVTPI_Id",
                "TPIA"."INVMPR_Id",
                "TPIA"."INVTPIAPP_RejectFlg" AS "INVMPIAPP_RejectFlg"
            FROM "INV"."INV_M_PurchaseIndent_Approval" "PIA"
            INNER JOIN "INV"."INV_T_PurchaseIndent_Approval" "TPIA" ON "PIA"."INVMPIAPP_Id" = "TPIA"."INVMPIAPP_Id"
            INNER JOIN "Master_Institution" "MI" ON "PIA"."MI_Id" = "MI"."MI_Id" AND "PIA"."INVMPIAPP_ActiveFlg" = 1
            INNER JOIN "INV"."INV_Master_Item" "IMI" ON "IMI"."INVMI_Id" = "TPIA"."INVMI_Id" AND "IMI"."MI_Id" = "TPIA"."MI_Id" AND "IMI"."INVMI_ActiveFlg" = 1
            INNER JOIN "INV"."INV_Master_UOM" "IMU" ON "IMU"."INVMUOM_Id" = "TPIA"."INVMUOM_Id" AND "IMU"."MI_Id" = "TPIA"."MI_Id" AND "IMU"."INVMUOM_ActiveFlg" = 1
            WHERE ("PIA"."INVMPIAPP_RejectFlg" = 0 OR "PIA"."INVMPIAPP_RejectFlg" = 1) 
                AND "PIA"."INVMPI_Id" = "INVMPI_Id" 
                AND "PIA"."INVMPIAPP_ApprovedBy" = "PrevUser_Id";
        END IF;
    END IF;

    RETURN;
END;
$$;