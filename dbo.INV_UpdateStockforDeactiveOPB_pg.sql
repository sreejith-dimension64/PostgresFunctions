CREATE OR REPLACE FUNCTION "INV"."INV_UpdateStockforDeactiveOPB"(
    p_MI_Id bigint,
    p_INVOB_Id bigint,
    p_INVMST_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_INVMI_Id bigint;
    v_INVOB_PurchaseRate decimal(18,2);
    v_INVOB_SaleRate decimal(18,2);
    v_INVOB_Qty decimal(18,2);
    v_INVOB_ActiveFlg boolean;
    rec RECORD;
BEGIN

    SELECT "INVOB_ActiveFlg" INTO v_INVOB_ActiveFlg 
    FROM "INV"."INV_OpeningBalance" 
    WHERE "INVOB_Id" = p_INVOB_Id 
        AND "MI_Id" = p_MI_Id 
        AND "INVMST_Id" = p_INVMST_Id;

    IF (v_INVOB_ActiveFlg = false) THEN
        
        FOR rec IN 
            SELECT DISTINCT "INVMI_Id", "INVOB_PurchaseRate", "INVOB_SaleRate", "INVOB_Qty"
            FROM "INV"."INV_OpeningBalance"
            WHERE "MI_Id" = p_MI_Id 
                AND "INVMST_Id" = p_INVMST_Id 
                AND "INVOB_Id" = p_INVOB_Id
                AND "INVOB_ActiveFlg" = false
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
                AND "INVOB_ActiveFlg" = true
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

END;
$$;