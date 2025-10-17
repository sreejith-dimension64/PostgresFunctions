CREATE OR REPLACE FUNCTION "CM_Payment_deatils_Cat_print"(
    p_CM_orderID TEXT
)
RETURNS TABLE(
    "CM_Transactionnum" VARCHAR,
    "CM_orderID" VARCHAR,
    "price" NUMERIC,
    "CMMCA_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c."CM_Transactionnum",
        c."CM_orderID",
        SUM(a."CMTRANS_Qty" * a."CMTRANSI_UnitRate") AS "price",
        b."CMMCA_Id"
    FROM "CM_Transaction_Items" a
    INNER JOIN "CM_Master_FoodItem" b ON b."CMMFI_Id" = a."CMMFI_Id"
    INNER JOIN "CM_Transaction" c ON c."CMTRANS_Id" = a."CMTRANS_Id"
    WHERE c."CM_orderID" = p_CM_orderID
    GROUP BY c."CM_Transactionnum", c."CM_orderID", b."CMMCA_Id";
END;
$$;