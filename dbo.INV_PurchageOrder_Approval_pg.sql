CREATE OR REPLACE FUNCTION "dbo"."INV_PurchageOrder_Approval"(p_User_Id bigint)
RETURNS TABLE(
    "MI_Id" bigint,
    "MI_Name" text,
    "INVMPO_Id" bigint,
    "INVMS_Id" bigint,
    "INVMPO_PONo" text,
    "INVMPO_PODate" timestamp,
    "INVMPO_Remarks" text,
    "INVMPO_ReferenceNo" text,
    "INVMPO_TotRate" decimal(25,2),
    "INVMPO_TotTax" decimal(25,2),
    "INVMPO_TotAmount" decimal(25,2),
    "INVMSQ_Id" bigint,
    "User_Id" bigint,
    "SanctionLevelNo" bigint,
    "RejectFlg" boolean,
    "POTemplate" text,
    "INVMS_SupplierName" text,
    "INVMS_SupplierCode" text,
    "INVMS_SupplierConatctPerson" text,
    "INVMS_SupplierConatctNo" bigint,
    "INVMS_SupplierAddress" text,
    "INVMS_EmailId" text,
    "INVMPO_POTemplate" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SanctionLevelNo bigint;
    v_Rcount bigint;
    v_MaxSanctionLevelNo bigint;
    v_MaxSanctionLevelNo_New bigint;
    v_ApprCount bigint;
    v_INVMPO_Id bigint;
    v_MI_Id bigint;
    v_Rcount1 bigint;
    v_Preuserid bigint;
    rec_POrderId RECORD;
BEGIN

    DROP TABLE IF EXISTS "INV_PurchageOrder_Approval_Temp";

    CREATE TEMP TABLE "INV_PurchageOrder_Approval_Temp" (
        "MI_Id" bigint,
        "MI_Name" text,
        "INVMPO_Id" bigint,
        "INVMS_Id" bigint,
        "INVMPO_PONo" text,
        "INVMPO_PODate" timestamp,
        "INVMPO_Remarks" text,
        "INVMPO_ReferenceNo" text,
        "INVMPO_TotRate" decimal(25,2),
        "INVMPO_TotTax" decimal(25,2),
        "INVMPO_TotAmount" decimal(25,2),
        "INVMSQ_Id" bigint,
        "User_Id" bigint,
        "SanctionLevelNo" bigint,
        "RejectFlg" boolean,
        "POTemplate" text,
        "INVMS_SupplierName" text,
        "INVMS_SupplierCode" text,
        "INVMS_SupplierConatctPerson" text,
        "INVMS_SupplierConatctNo" bigint,
        "INVMS_SupplierAddress" text,
        "INVMS_EmailId" text,
        "INVMPO_POTemplate" text
    );

    SELECT COUNT(*) INTO v_Rcount1 
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'PO' AND "IVRMUL_Id" = p_User_Id;

    IF v_Rcount1 > 0 THEN

        v_SanctionLevelNo := 0;
        v_MaxSanctionLevelNo := 0;

        SELECT MAX("HRPAON_SanctionLevelNo") INTO v_MaxSanctionLevelNo
        FROM "HR_Process_Authorisation" "PA"
        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
        WHERE "HRPA_TypeFlag" = 'PO';

        SELECT "HRPAON_SanctionLevelNo" INTO v_SanctionLevelNo
        FROM "HR_Process_Authorisation" "PA"
        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
        WHERE "HRPA_TypeFlag" = 'PO' AND "IVRMUL_Id" = p_User_Id;

        FOR rec_POrderId IN 
            SELECT DISTINCT "MPO"."INVMPO_Id", "MPO"."MI_Id"
            FROM "INV"."INV_M_PurchaseOrder" "MPO"
            INNER JOIN "INV"."INV_T_PurchaseOrder" "TPO" ON "MPO"."INVMPO_Id" = "TPO"."INVMPO_Id" 
                AND "MPO"."MI_Id" = "TPO"."MI_Id" 
            WHERE (COALESCE("INVMPO_FinalProcessFlag", 0) = 0) 
                AND (COALESCE("INVMPO_RejectFlg", 0) = 0)
        LOOP
            v_INVMPO_Id := rec_POrderId."INVMPO_Id";
            v_MI_Id := rec_POrderId."MI_Id";

            IF (v_SanctionLevelNo = 1) THEN

                v_Rcount := 0;
                SELECT COUNT(*) INTO v_Rcount 
                FROM "INV"."INV_M_PurchaseOrder_Approval" "POA" 
                WHERE "INVMPOAPP_ApprovedBy" = p_User_Id 
                    AND ("INVMPOAPP_RejectFlg" = FALSE OR "INVMPOAPP_RejectFlg" = TRUE) 
                    AND "INVMPO_Id" = v_INVMPO_Id 
                    AND "MI_Id" = v_MI_Id;

                IF (v_Rcount = 0) THEN

                    INSERT INTO "INV_PurchageOrder_Approval_Temp" 
                    ("MI_Id", "MI_Name", "INVMPO_Id", "INVMS_Id", "INVMPO_PONo", "INVMPO_PODate", 
                     "INVMPO_Remarks", "INVMPO_ReferenceNo", "INVMPO_TotRate", "INVMPO_TotTax", 
                     "INVMPO_TotAmount", "INVMSQ_Id", "User_Id", "SanctionLevelNo", "RejectFlg", 
                     "POTemplate", "INVMS_SupplierName", "INVMS_SupplierCode", "INVMS_SupplierConatctPerson", 
                     "INVMS_SupplierConatctNo", "INVMS_SupplierAddress", "INVMS_EmailId", "INVMPO_POTemplate")
                    SELECT "PO"."MI_Id", "MI_Name", "INVMPO_Id", "PO"."INVMS_Id", "INVMPO_PONo", "INVMPO_PODate", 
                           "INVMPO_Remarks", "INVMPO_ReferenceNo", "INVMPO_TotRate", "INVMPO_TotTax", 
                           "INVMPO_TotAmount", "INVMSQ_Id", p_User_Id, v_SanctionLevelNo, FALSE, 
                           '', "INVMS_SupplierName", "INVMS_SupplierCode", "INVMS_SupplierConatctPerson", 
                           "INVMS_SupplierConatctNo", "INVMS_SupplierAddress", "INVMS_EmailId", "INVMPO_POTemplate"
                    FROM "INV"."INV_M_PurchaseOrder" "PO"
                    INNER JOIN "Master_Institution" "MI" ON "PO"."MI_Id" = "MI"."MI_Id"
                    LEFT JOIN "inv"."INV_Master_Supplier" "SP" ON "SP"."INVMS_Id" = "PO"."INVMS_Id"
                    WHERE "INVMPO_ActiveFlg" = TRUE 
                        AND "PO"."INVMPO_Id" = v_INVMPO_Id 
                        AND "PO"."MI_Id" = v_MI_Id 
                        AND "PO"."INVMPO_Id" NOT IN (
                            SELECT DISTINCT "INVMPO_Id" 
                            FROM "INV"."INV_M_PurchaseOrder_Approval" 
                            WHERE "INVMPOAPP_ApprovedBy" = p_User_Id
                        );

                END IF;

            END IF;

            SELECT COUNT(*) INTO v_Rcount 
            FROM "INV"."INV_M_PurchaseOrder_Approval" "PIA" 
            WHERE ("INVMPOAPP_RejectFlg" = FALSE OR "INVMPOAPP_RejectFlg" = TRUE) 
                AND "INVMPO_Id" = v_INVMPO_Id 
                AND "MI_Id" = v_MI_Id;

            IF (v_Rcount > 0) THEN

                SELECT DISTINCT "IVRMUL_Id" INTO v_Preuserid
                FROM "HR_Process_Authorisation" "PA"
                INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                WHERE "HRPA_TypeFlag" = 'PO' 
                    AND "IVRMUL_Id" IN (
                        SELECT DISTINCT "IVRMUL_Id"
                        FROM "HR_Process_Authorisation" "PA"
                        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                        WHERE "HRPA_TypeFlag" = 'PO' 
                            AND "HRPAON_SanctionLevelNo" = v_SanctionLevelNo - 1
                    )
                LIMIT 1;

                INSERT INTO "INV_PurchageOrder_Approval_Temp" 
                ("MI_Id", "MI_Name", "INVMPO_Id", "INVMS_Id", "INVMPO_PONo", "INVMPO_PODate", 
                 "INVMPO_Remarks", "INVMPO_ReferenceNo", "INVMPO_TotRate", "INVMPO_TotTax", 
                 "INVMPO_TotAmount", "INVMSQ_Id", "User_Id", "SanctionLevelNo", "RejectFlg", 
                 "POTemplate", "INVMS_SupplierName", "INVMS_SupplierCode", "INVMS_SupplierConatctPerson", 
                 "INVMS_SupplierConatctNo", "INVMS_SupplierAddress", "INVMS_EmailId", "INVMPO_POTemplate")
                SELECT "MI"."MI_Id", "MI_Name", "INVMPO_Id", "POA"."INVMS_Id", "INVMPOAPP_PONo", 
                       "INVMPOAPP_PODate", "INVMPOAPP_Remarks", "INVMPOAPP_ReferenceNo", 
                       "INVMPOAPP_TotRate", "INVMPOAPP_TotTax", "INVMPOAPP_TotAmount", "INVMSQ_Id", 
                       "INVMPOAPP_ApprovedBy", v_SanctionLevelNo, "INVMPOAPP_RejectFlg", 
                       "INVMPOAPP_POTemplate", "INVMS_SupplierName", "INVMS_SupplierCode", 
                       "INVMS_SupplierConatctPerson", "INVMS_SupplierConatctNo", "INVMS_SupplierAddress", 
                       "INVMS_EmailId", "INVMPOAPP_POTemplate"
                FROM "INV"."INV_M_PurchaseOrder_Approval" "POA"
                INNER JOIN "Master_Institution" "MI" ON "POA"."MI_Id" = "MI"."MI_Id" 
                    AND "INVMPOAPP_ActiveFlg" = TRUE
                LEFT JOIN "inv"."INV_Master_Supplier" "SP" ON "SP"."INVMS_Id" = "POA"."INVMS_Id"
                WHERE ("INVMPOAPP_RejectFlg" = FALSE OR "INVMPOAPP_RejectFlg" = TRUE) 
                    AND "INVMPO_Id" = v_INVMPO_Id 
                    AND "POA"."MI_Id" = v_MI_Id 
                    AND "POA"."INVMPO_Id" NOT IN (
                        SELECT DISTINCT "INVMPO_Id" 
                        FROM "INV"."INV_M_PurchaseOrder_Approval" 
                        WHERE "INVMPOAPP_ApprovedBy" = p_User_Id
                    )
                    AND "POA"."INVMPOAPP_ApprovedBy" = v_Preuserid;

            END IF;

            v_ApprCount := 0;
            SELECT COUNT(*) INTO v_ApprCount 
            FROM "INV"."INV_M_PurchaseOrder_Approval" "PIA" 
            WHERE ("INVMPOAPP_RejectFlg" = FALSE OR "INVMPOAPP_RejectFlg" = TRUE) 
                AND "INVMPO_Id" = v_INVMPO_Id 
                AND "MI_Id" = v_MI_Id;

            v_MaxSanctionLevelNo_New := v_MaxSanctionLevelNo - 1;

        END LOOP;

        RETURN QUERY 
        SELECT DISTINCT "A".* 
        FROM "INV_PurchageOrder_Approval_Temp" "A";

    END IF;

END;
$$;