CREATE OR REPLACE FUNCTION "INV"."INV_UpdateStockforDeactiveSales"(
    p_MI_Id bigint,
    p_IMFY_Id bigint,
    p_INVMSL_Id bigint,
    p_INVMST_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_INVMI_Id bigint;
    v_INVTSL_SalesPrice decimal(18,2);
    v_INVTSL_SalesQty decimal(18,2);
    v_INVMSL_ActiveFlg boolean;
    sales_rec RECORD;
BEGIN

    SELECT "INVMSL_ActiveFlg" INTO v_INVMSL_ActiveFlg 
    FROM "INV"."INV_M_Sales" 
    WHERE "INVMSL_Id" = p_INVMSL_Id 
        AND "MI_Id" = p_MI_Id 
        AND "INVMST_Id" = p_INVMST_Id;

    IF (v_INVMSL_ActiveFlg = false) THEN
        
        FOR sales_rec IN
            SELECT DISTINCT "INVMI_Id", "INVTSL_SalesPrice", "INVTSL_SalesQty"
            FROM "INV"."INV_T_Sales" "ITS"
            INNER JOIN "INV"."INV_M_Sales" "IMS" ON "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id" 
                AND "IMS"."INVMSL_ActiveFlg" = false 
                AND "ITS"."INVTSL_ActiveFlg" = false
            WHERE "ITS"."INVMSL_Id" = p_INVMSL_Id 
                AND "IMS"."MI_Id" = p_MI_Id 
                AND "IMS"."INVMST_Id" = p_INVMST_Id
        LOOP
            v_INVMI_Id := sales_rec."INVMI_Id";
            v_INVTSL_SalesPrice := sales_rec."INVTSL_SalesPrice";
            v_INVTSL_SalesQty := sales_rec."INVTSL_SalesQty";

            UPDATE "INV"."INV_Stock" 
            SET "INVSTO_SalesQty" = "INVSTO_SalesQty" - v_INVTSL_SalesQty,
                "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + v_INVTSL_SalesQty
            WHERE "MI_Id" = p_MI_Id 
                AND "IMFY_Id" = p_IMFY_Id 
                AND "INVMST_Id" = p_INVMST_Id 
                AND "INVMI_Id" = v_INVMI_Id 
                AND "INVSTO_SalesRate" = v_INVTSL_SalesPrice 
                AND "INVSTO_SalesQty" <> 0 
                AND "INVSTO_AvaiableStock" <> 0;
        END LOOP;

    ELSE
        
        FOR sales_rec IN
            SELECT DISTINCT "INVMI_Id", "INVTSL_SalesPrice", "INVTSL_SalesQty"
            FROM "INV"."INV_T_Sales" "ITS"
            INNER JOIN "INV"."INV_M_Sales" "IMS" ON "ITS"."INVMSL_Id" = "IMS"."INVMSL_Id" 
                AND "INVMSL_ActiveFlg" = true 
                AND "INVTSL_ActiveFlg" = true
            WHERE "ITS"."INVMSL_Id" = p_INVMSL_Id 
                AND "IMS"."MI_Id" = p_MI_Id 
                AND "INVMST_Id" = p_INVMST_Id
        LOOP
            v_INVMI_Id := sales_rec."INVMI_Id";
            v_INVTSL_SalesPrice := sales_rec."INVTSL_SalesPrice";
            v_INVTSL_SalesQty := sales_rec."INVTSL_SalesQty";

            UPDATE "INV"."INV_Stock" 
            SET "INVSTO_SalesQty" = "INVSTO_SalesQty" + v_INVTSL_SalesQty,
                "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - v_INVTSL_SalesQty
            WHERE "MI_Id" = p_MI_Id 
                AND "IMFY_Id" = p_IMFY_Id 
                AND "INVMST_Id" = p_INVMST_Id 
                AND "INVMI_Id" = v_INVMI_Id 
                AND "INVSTO_SalesRate" = v_INVTSL_SalesPrice 
                AND ("INVSTO_SalesQty" <> 0 OR "INVSTO_AvaiableStock" <> 0);
        END LOOP;

    END IF;

    RETURN;
END;
$$;