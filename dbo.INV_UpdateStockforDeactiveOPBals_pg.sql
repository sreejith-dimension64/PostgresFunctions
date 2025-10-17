CREATE OR REPLACE FUNCTION "INV"."INV_UpdateStockforDeactiveOPBals"(
    p_MI_Id BIGINT,
    p_INVOB_Id BIGINT,
    p_INVMST_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_INVMI_Id BIGINT;
    v_INVOB_PurchaseRate DECIMAL(18,2);
    v_INVOB_SaleRate DECIMAL(18,2);
    v_INVOB_Qty DECIMAL(18,2);
    v_INVOB_ActiveFlg BOOLEAN;
    v_inv_Itemid BIGINT;
    v_INVMI_Ids BIGINT;
    v_salesItem BIGINT;
    v_salesStID BIGINT;
    rec RECORD;
BEGIN
    SELECT DISTINCT "INVMI_Id" INTO v_INVMI_Ids
    FROM "INV"."INV_OpeningBalance"
    WHERE "MI_Id" = p_MI_Id 
        AND "INVMST_Id" = p_INVMST_Id 
        AND "INVOB_Id" = p_INVOB_Id 
        AND "INVOB_ActiveFlg" = FALSE;

    SELECT DISTINCT "ITS"."INVMI_Id", "ITS"."INVMST_Id" 
    INTO v_salesItem, v_salesStID
    FROM "INV"."INV_T_Sales" "ITS"
    INNER JOIN "INV"."INV_M_Sales" "IMS" ON "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id" 
        AND "IMS"."INVMSL_ActiveFlg" = TRUE 
        AND "ITS"."INVTSL_ActiveFlg" = TRUE
    WHERE "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id" 
        AND "IMS"."INVMSL_ActiveFlg" = TRUE 
        AND "ITS"."INVTSL_ActiveFlg" = TRUE  
        AND "IMS"."MI_Id" = p_MI_Id 
        AND "IMS"."INVMST_Id" = p_INVMST_Id 
        AND "ITS"."INVMI_Id" = v_INVMI_Ids;

    IF (v_salesItem = p_MI_Id) THEN
        SELECT "INVOB_ActiveFlg" INTO v_INVOB_ActiveFlg 
        FROM "INV"."INV_OpeningBalance"  
        WHERE "INVOB_Id" = p_INVOB_Id 
            AND "MI_Id" = p_MI_Id 
            AND "INVMST_Id" = p_INVMST_Id;

        SELECT "INVOB_ActiveFlg" INTO v_INVOB_ActiveFlg 
        FROM "INV"."INV_OpeningBalance"  
        WHERE "INVOB_Id" = p_INVOB_Id 
            AND "MI_Id" = p_MI_Id 
            AND "INVMST_Id" = p_INVMST_Id;

        IF (v_INVOB_ActiveFlg = TRUE) THEN
            FOR rec IN 
                SELECT DISTINCT "INVMI_Id", "INVOB_PurchaseRate", "INVOB_SaleRate", "INVOB_Qty"
                FROM "INV"."INV_OpeningBalance"
                WHERE "MI_Id" = p_MI_Id 
                    AND "INVMST_Id" = p_INVMST_Id 
                    AND "INVOB_Id" = p_INVOB_Id 
                    AND "INVOB_ActiveFlg" = TRUE
            LOOP
                v_INVMI_Id := rec."INVMI_Id";
                v_INVOB_PurchaseRate := rec."INVOB_PurchaseRate";
                v_INVOB_SaleRate := rec."INVOB_SaleRate";
                v_INVOB_Qty := rec."INVOB_Qty";

                UPDATE "INV"."INV_Stock"
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - v_INVOB_Qty,
                    "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - v_INVOB_Qty
                WHERE "MI_Id" = p_MI_Id 
                    AND "INVMST_Id" = p_INVMST_Id  
                    AND "INVMI_Id" = v_INVMI_Id 
                    AND "INVSTO_SalesRate" = v_INVOB_SaleRate
                    AND "INVSTO_PurchaseRate" = v_INVOB_PurchaseRate;
            END LOOP;
        ELSE
            FOR rec IN 
                SELECT DISTINCT "INVMI_Id", "INVOB_PurchaseRate", "INVOB_SaleRate", "INVOB_Qty"
                FROM "INV"."INV_OpeningBalance"
                WHERE "MI_Id" = p_MI_Id 
                    AND "INVMST_Id" = p_INVMST_Id 
                    AND "INVOB_Id" = p_INVOB_Id
                    AND "INVOB_ActiveFlg" = FALSE
            LOOP
                v_INVMI_Id := rec."INVMI_Id";
                v_INVOB_PurchaseRate := rec."INVOB_PurchaseRate";
                v_INVOB_SaleRate := rec."INVOB_SaleRate";
                v_INVOB_Qty := rec."INVOB_Qty";

                UPDATE "INV"."INV_Stock"
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_INVOB_Qty,
                    "INVSTO_PurOBQty" = "INVSTO_PurOBQty" + v_INVOB_Qty
                WHERE "MI_Id" = p_MI_Id 
                    AND "INVMST_Id" = p_INVMST_Id  
                    AND "INVMI_Id" = v_INVMI_Id  
                    AND "INVSTO_SalesRate" = v_INVOB_SaleRate 
                    AND "INVSTO_PurchaseRate" = v_INVOB_PurchaseRate;
            END LOOP;
        END IF;
    END IF;

    RETURN;
END;
$$;