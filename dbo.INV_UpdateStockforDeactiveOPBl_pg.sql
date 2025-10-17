CREATE OR REPLACE FUNCTION "INV"."INV_UpdateStockforDeactiveOPBl"(
    p_MI_Id bigint,
    p_INVOB_Id bigint,
    p_INVMST_Id bigint,
    p_INVOB_ActiveFlg boolean
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_INVMI_Id bigint;
    v_INVOB_PurchaseRate decimal(18,2);
    v_INVOB_SaleRate decimal(18,2);
    v_INVOB_Qty decimal(18,2);
    v_INVOB_ActiveFlgs boolean;
    v_inv_Itemid bigint;
    v_INVMI_Ids bigint;
    v_salesItem bigint;
    v_salesStID bigint;
    v_SalesQty decimal(18,2);
    v_INVOB_PurchaseDate date;
    rec RECORD;
BEGIN

    v_SalesQty := 0;
    v_INVOB_PurchaseDate := NULL;

    SELECT DISTINCT "INVMI_Id" INTO v_INVMI_Ids
    FROM "INV"."INV_OpeningBalance"
    WHERE "MI_Id" = p_MI_Id 
        AND "INVMST_Id" = p_INVMST_Id 
        AND "INVOB_Id" = p_INVOB_Id 
        AND "INVOB_ActiveFlg" = p_INVOB_ActiveFlg;

    SELECT DISTINCT "ITS"."INVMI_Id", "ITS"."INVMST_Id" 
    INTO v_salesItem, v_salesStID
    FROM "INV"."INV_T_Sales" "ITS"
    INNER JOIN "INV"."INV_M_Sales" "IMS" ON "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id" 
        AND "IMS"."INVMSL_ActiveFlg" = true 
        AND "ITS"."INVTSL_ActiveFlg" = true
    WHERE "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id" 
        AND "IMS"."INVMSL_ActiveFlg" = true 
        AND "ITS"."INVTSL_ActiveFlg" = true  
        AND "IMS"."MI_Id" = p_MI_Id 
        AND "IMS"."INVMST_Id" = p_INVMST_Id 
        AND "ITS"."INVMI_Id" = v_INVMI_Ids;

    SELECT COALESCE(SUM("ITS"."INVTSL_SalesQty"), 0) INTO v_SalesQty
    FROM "INV"."INV_T_Sales" "ITS"
    INNER JOIN "INV"."INV_M_Sales" "IMS" ON "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id" 
        AND "IMS"."INVMSL_ActiveFlg" = true 
        AND "ITS"."INVTSL_ActiveFlg" = true
    WHERE "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id" 
        AND "IMS"."INVMSL_ActiveFlg" = true 
        AND "ITS"."INVTSL_ActiveFlg" = true  
        AND "IMS"."MI_Id" = p_MI_Id 
        AND "IMS"."INVMST_Id" = p_INVMST_Id 
        AND "ITS"."INVMI_Id" = v_INVMI_Ids;

    IF (v_salesItem = v_INVMI_Ids) THEN
        SELECT "INVOB_ActiveFlg" INTO v_INVOB_ActiveFlgs 
        FROM "INV"."INV_OpeningBalance"  
        WHERE "INVOB_Id" = p_INVOB_Id 
            AND "MI_Id" = p_MI_Id 
            AND "INVMST_Id" = p_INVMST_Id;

        IF (v_INVOB_ActiveFlgs = false) THEN
            FOR rec IN 
                SELECT DISTINCT "INVMI_Id", "INVOB_PurchaseRate", "INVOB_SaleRate", 
                    COALESCE("INVOB_Qty", 0) AS "INVOB_Qty", 
                    CAST("INVOB_PurchaseDate" AS date) AS "INVOB_PurchaseDate"
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
                v_INVOB_PurchaseDate := rec."INVOB_PurchaseDate";

                UPDATE "INV"."INV_Stock" 
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - v_INVOB_Qty,
                    "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - v_INVOB_Qty,
                    "INVSTO_CheckedOutQty" = 0
                WHERE "MI_Id" = p_MI_Id 
                    AND "INVMST_Id" = p_INVMST_Id  
                    AND "INVMI_Id" = v_INVMI_Id 
                    AND "INVSTO_SalesRate" = v_INVOB_SaleRate
                    AND "INVSTO_PurchaseRate" = v_INVOB_PurchaseRate  
                    AND "INVSTO_PurchaseDate" = v_INVOB_PurchaseDate;
            END LOOP;
        ELSE
            FOR rec IN 
                SELECT DISTINCT "INVMI_Id", "INVOB_PurchaseRate", "INVOB_SaleRate", 
                    COALESCE("INVOB_Qty", 0) AS "INVOB_Qty", 
                    CAST("INVOB_PurchaseDate" AS date) AS "INVOB_PurchaseDate"
                FROM "INV"."INV_OpeningBalance"  
                WHERE "MI_Id" = p_MI_Id 
                    AND "INVMST_Id" = p_INVMST_Id 
                    AND "INVOB_Id" = p_INVOB_Id 
                    AND "INVOB_ActiveFlg" = true 
                    AND "INVOB_Qty" > v_SalesQty
            LOOP
                v_INVMI_Id := rec."INVMI_Id";
                v_INVOB_PurchaseRate := rec."INVOB_PurchaseRate";
                v_INVOB_SaleRate := rec."INVOB_SaleRate";
                v_INVOB_Qty := rec."INVOB_Qty";
                v_INVOB_PurchaseDate := rec."INVOB_PurchaseDate";

                UPDATE "INV"."INV_Stock" 
                SET "INVSTO_AvaiableStock" = v_INVOB_Qty - COALESCE("INVSTO_SalesQty", 0) - COALESCE("INVSTO_CheckedOutQty", 0),
                    "INVSTO_PurOBQty" = v_INVOB_Qty - "INVSTO_SalesQty" - COALESCE("INVSTO_CheckedOutQty", 0)
                WHERE "MI_Id" = p_MI_Id 
                    AND "INVMST_Id" = p_INVMST_Id  
                    AND "INVMI_Id" = v_INVMI_Id  
                    AND "INVSTO_SalesRate" = v_INVOB_SaleRate 
                    AND "INVSTO_PurchaseRate" = v_INVOB_PurchaseRate 
                    AND "INVSTO_PurchaseDate" = v_INVOB_PurchaseDate;
            END LOOP;
        END IF;
    ELSE
        IF (p_INVOB_ActiveFlg = false) THEN
            FOR rec IN 
                SELECT DISTINCT "INVMI_Id", "INVOB_PurchaseRate", "INVOB_SaleRate", 
                    COALESCE("INVOB_Qty", 0) AS "INVOB_Qty", 
                    CAST("INVOB_PurchaseDate" AS date) AS "INVOB_PurchaseDate"
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
                v_INVOB_PurchaseDate := rec."INVOB_PurchaseDate";

                UPDATE "INV"."INV_Stock" 
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - v_INVOB_Qty,
                    "INVSTO_PurOBQty" = "INVSTO_PurOBQty" - v_INVOB_Qty,
                    "INVSTO_CheckedOutQty" = 0
                WHERE "MI_Id" = p_MI_Id 
                    AND "INVMST_Id" = p_INVMST_Id  
                    AND "INVMI_Id" = v_INVMI_Id 
                    AND "INVSTO_SalesRate" = v_INVOB_SaleRate
                    AND "INVSTO_PurchaseRate" = v_INVOB_PurchaseRate 
                    AND "INVSTO_PurchaseDate" = v_INVOB_PurchaseDate;
            END LOOP;
        ELSE
            FOR rec IN 
                SELECT DISTINCT "INVMI_Id", "INVOB_PurchaseRate", "INVOB_SaleRate", 
                    COALESCE("INVOB_Qty", 0) AS "INVOB_Qty", 
                    CAST("INVOB_PurchaseDate" AS date) AS "INVOB_PurchaseDate"
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
                v_INVOB_PurchaseDate := rec."INVOB_PurchaseDate";

                UPDATE "INV"."INV_Stock" 
                SET "INVSTO_AvaiableStock" = v_INVOB_Qty,
                    "INVSTO_PurOBQty" = v_INVOB_Qty,
                    "INVSTO_CheckedOutQty" = 0
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