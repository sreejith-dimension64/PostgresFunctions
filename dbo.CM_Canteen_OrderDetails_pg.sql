CREATE OR REPLACE FUNCTION "CM_Canteen_OrderDetails"()
RETURNS TABLE(
    "Total_QtySold" INTEGER,
    "Total_Amount" NUMERIC(18, 2),
    "Today_Total_QtySold" INTEGER,
    "Today_Total_Amount" NUMERIC(18, 2),
    "Veg_Total_QtySold" INTEGER,
    "Veg_Total_Amount" NUMERIC(18, 2),
    "NonVeg_Total_QtySold" INTEGER,
    "NonVeg_Total_Amount" NUMERIC(18, 2),
    "Month_Total_QtySold" INTEGER,
    "Month_Total_Amount" NUMERIC(18, 2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Total_QtySold INTEGER;
    v_Total_Amount NUMERIC(18, 2);
    v_Today_Total_QtySold INTEGER;
    v_Today_Total_Amount NUMERIC(18, 2);
    v_Veg_Total_QtySold INTEGER;
    v_Veg_Total_Amount NUMERIC(18, 2);
    v_NonVeg_Total_QtySold INTEGER;
    v_NonVeg_Total_Amount NUMERIC(18, 2);
    v_Month_Total_QtySold INTEGER;
    v_Month_Total_Amount NUMERIC(18, 2);
BEGIN
    -- Total sales
    SELECT SUM("CMTRANS_Qty"),
           ROUND(SUM("CMTRANS_Qty" * "CMTRANSI_UnitRate"), 2)
    INTO v_Total_QtySold, v_Total_Amount
    FROM "CM_Transaction_Items" a
    INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
    INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id";

    -- Today's sales
    SELECT SUM("CMTRANS_Qty"),
           ROUND(SUM("CMTRANS_Qty" * "CMTRANSI_UnitRate"), 2)
    INTO v_Today_Total_QtySold, v_Today_Total_Amount
    FROM "CM_Transaction_Items" a
    INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
    INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
    WHERE CAST("CMTRANSI_Updateddate" AS DATE) = CURRENT_DATE;

    -- Veg sales
    SELECT SUM("CMTRANS_Qty"),
           ROUND(SUM("CMTRANS_Qty" * "CMTRANSI_UnitRate"), 2)
    INTO v_Veg_Total_QtySold, v_Veg_Total_Amount
    FROM "CM_Transaction_Items" a
    INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
    INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
    WHERE "CMMFI_FoodItemFlag" = 1;

    -- Non-veg sales
    SELECT SUM("CMTRANS_Qty"),
           ROUND(SUM("CMTRANS_Qty" * "CMTRANSI_UnitRate"), 2)
    INTO v_NonVeg_Total_QtySold, v_NonVeg_Total_Amount
    FROM "CM_Transaction_Items" a
    INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
    INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
    WHERE "CMMFI_FoodItemFlag" = 0;

    -- Monthly sales
    SELECT SUM("CMTRANS_Qty"),
           ROUND(SUM("CMTRANS_Qty" * "CMTRANSI_UnitRate"), 2)
    INTO v_Month_Total_QtySold, v_Month_Total_Amount
    FROM "CM_Transaction_Items" a
    INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
    INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
    WHERE EXTRACT(MONTH FROM "CMTRANSI_Updateddate") = EXTRACT(MONTH FROM CURRENT_TIMESTAMP);

    RETURN QUERY
    SELECT v_Total_QtySold, 
           v_Total_Amount,
           v_Today_Total_QtySold, 
           v_Today_Total_Amount,
           v_Veg_Total_QtySold, 
           v_Veg_Total_Amount,
           v_NonVeg_Total_QtySold, 
           v_NonVeg_Total_Amount,
           v_Month_Total_QtySold, 
           v_Month_Total_Amount;
END;
$$;