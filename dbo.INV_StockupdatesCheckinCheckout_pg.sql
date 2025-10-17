CREATE OR REPLACE FUNCTION "INV"."INV_StockupdatesCheckinCheckout"(
    p_MI_Id bigint,
    p_INVMST_Id bigint,
    p_INVMLO_Id bigint,
    p_INVMI_Id bigint,
    p_INVSTO_SalesRate decimal(18,2),
    p_INVACO_Id bigint,
    p_INVACI_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_AvailableStock decimal(18,2);
    v_CheckOutQty decimal(18,2);
    v_CheckInQty decimal(18,2);
    v_INVACI_ActiveFlg integer;
    v_MasterCheckOutQty decimal(18,2);
BEGIN

    SELECT SUM("INVSTO_AvaiableStock"), SUM("INVSTO_CheckedOutQty") 
    INTO v_AvailableStock, v_CheckOutQty
    FROM "INV"."INV_Stock" 
    WHERE "MI_Id" = p_MI_Id 
        AND "INVMST_Id" = p_INVMST_Id 
        AND "INVMI_Id" = p_INVMI_Id 
        AND "INVSTO_AvaiableStock" <> 0 
        AND "INVSTO_SalesRate" = p_INVSTO_SalesRate 
        AND "INVSTO_PurchaseDate" IS NOT NULL;

    IF (v_CheckOutQty = 0 OR v_CheckOutQty IS NULL) THEN
        
        SELECT SUM("INVACO_CheckOutQty") 
        INTO v_MasterCheckOutQty
        FROM "INV"."INV_Asset_CheckOut" 
        WHERE "MI_Id" = p_MI_Id 
            AND "INVMLO_Id" = p_INVMLO_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVACO_ActiveFlg" = 1 
            AND "INVSTO_SalesRate" = p_INVSTO_SalesRate 
            AND "INVACO_Id" = p_INVACO_Id;
        
        UPDATE "INV"."INV_Stock" 
        SET "INVSTO_AvaiableStock" = (v_AvailableStock - v_MasterCheckOutQty),
            "INVSTO_CheckedOutQty" = v_MasterCheckOutQty
        WHERE "MI_Id" = p_MI_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVSTO_AvaiableStock" <> 0 
            AND "INVSTO_SalesRate" = p_INVSTO_SalesRate;

    ELSIF (v_CheckOutQty != 0) THEN
        
        SELECT SUM("INVACO_CheckOutQty") 
        INTO v_MasterCheckOutQty
        FROM "INV"."INV_Asset_CheckOut" 
        WHERE "MI_Id" = p_MI_Id 
            AND "INVMLO_Id" = p_INVMLO_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVACO_ActiveFlg" = 1 
            AND "INVSTO_SalesRate" = p_INVSTO_SalesRate 
            AND "INVACO_Id" = p_INVACO_Id;
        
        UPDATE "INV"."INV_Stock" 
        SET "INVSTO_AvaiableStock" = (v_AvailableStock - v_MasterCheckOutQty),
            "INVSTO_CheckedOutQty" = "INVSTO_CheckedOutQty" + v_MasterCheckOutQty
        WHERE "MI_Id" = p_MI_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVSTO_AvaiableStock" <> 0 
            AND "INVSTO_SalesRate" = p_INVSTO_SalesRate;

    END IF;

    SELECT SUM("INVACO_CheckOutQty") 
    INTO v_MasterCheckOutQty
    FROM "INV"."INV_Asset_CheckOut" 
    WHERE "MI_Id" = p_MI_Id 
        AND "INVMLO_Id" = p_INVMLO_Id 
        AND "INVMST_Id" = p_INVMST_Id 
        AND "INVMI_Id" = p_INVMI_Id 
        AND "INVACO_ActiveFlg" = 1 
        AND "INVSTO_SalesRate" = p_INVSTO_SalesRate 
        AND "INVACO_Id" = p_INVACO_Id;

    SELECT SUM("INVACI_CheckInQty") 
    INTO v_CheckInQty
    FROM "INV"."INV_Asset_CheckIn"
    WHERE "MI_Id" = p_MI_Id 
        AND "INVMLO_Id" = p_INVMLO_Id 
        AND "INVMST_Id" = p_INVMST_Id 
        AND "INVMI_Id" = p_INVMI_Id 
        AND "INVSTO_SalesRate" = p_INVSTO_SalesRate 
        AND "INVACI_Id" = p_INVACI_Id;

    SELECT "INVACI_ActiveFlg" 
    INTO v_INVACI_ActiveFlg
    FROM "INV"."INV_Asset_CheckIn"
    WHERE "MI_Id" = p_MI_Id 
        AND "INVMLO_Id" = p_INVMLO_Id 
        AND "INVMST_Id" = p_INVMST_Id 
        AND "INVMI_Id" = p_INVMI_Id 
        AND "INVSTO_SalesRate" = p_INVSTO_SalesRate 
        AND "INVACI_Id" = p_INVACI_Id;

    IF (v_INVACI_ActiveFlg = 1) THEN

        UPDATE "INV"."INV_Stock" 
        SET "INVSTO_AvaiableStock" = ("INVSTO_AvaiableStock" + v_CheckInQty),
            "INVSTO_CheckedOutQty" = ("INVSTO_CheckedOutQty" - v_CheckInQty)
        WHERE "MI_Id" = p_MI_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVSTO_AvaiableStock" <> 0 
            AND "INVSTO_SalesRate" = p_INVSTO_SalesRate;

        UPDATE "INV"."INV_Asset_CheckOut" 
        SET "INVACO_CheckOutQty" = "INVACO_CheckOutQty" - v_CheckInQty
        WHERE "MI_Id" = p_MI_Id 
            AND "INVMLO_Id" = p_INVMLO_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVACO_ActiveFlg" = 1 
            AND "INVSTO_SalesRate" = p_INVSTO_SalesRate 
            AND "INVACO_Id" = p_INVACO_Id;

    ELSIF (v_INVACI_ActiveFlg = 0) THEN

        UPDATE "INV"."INV_Stock" 
        SET "INVSTO_AvaiableStock" = ("INVSTO_AvaiableStock" - v_CheckInQty),
            "INVSTO_CheckedOutQty" = ("INVSTO_CheckedOutQty" + v_CheckInQty)
        WHERE "MI_Id" = p_MI_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVSTO_AvaiableStock" <> 0 
            AND "INVSTO_SalesRate" = p_INVSTO_SalesRate;

        UPDATE "INV"."INV_Asset_CheckOut" 
        SET "INVACO_CheckOutQty" = "INVACO_CheckOutQty" + v_CheckInQty
        WHERE "MI_Id" = p_MI_Id 
            AND "INVMLO_Id" = p_INVMLO_Id 
            AND "INVMST_Id" = p_INVMST_Id 
            AND "INVMI_Id" = p_INVMI_Id 
            AND "INVACO_ActiveFlg" = 1 
            AND "INVSTO_SalesRate" = p_INVSTO_SalesRate 
            AND "INVACO_Id" = p_INVACO_Id;

    END IF;

    RETURN;

END;
$$;