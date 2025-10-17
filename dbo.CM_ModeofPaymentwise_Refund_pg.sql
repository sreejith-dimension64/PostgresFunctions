CREATE OR REPLACE FUNCTION "CM_ModeofPaymentwise_Refund" (
    p_Flag VARCHAR(50)
)
RETURNS TABLE (
    "Total_Amount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN 
    IF p_Flag = 'pda' THEN
        RETURN QUERY
        SELECT SUM("CMTRANS_VoidAmount") AS "Total_Amount"
        FROM "CM_Transaction_Items" a
        INNER JOIN "CM_Transaction" b ON b."CMTRANS_Id" = a."CMTRANS_Id"
        INNER JOIN "CM_Transaction_PaymentMode" e ON e."CMTRANS_Id" = a."CMTRANS_Id"
        WHERE "CMTRANSI_VoidItemFlg" = 1 AND "CMTRANSPM_PaymentMode" = 'pda';
    ELSE
        RETURN QUERY
        SELECT SUM("CMTRANS_VoidAmount") AS "Total_Amount"
        FROM "CM_Transaction_Items" a
        INNER JOIN "CM_Transaction" b ON b."CMTRANS_Id" = a."CMTRANS_Id"
        INNER JOIN "CM_Transaction_PaymentMode" e ON e."CMTRANS_Id" = a."CMTRANS_Id"
        WHERE "CMTRANSI_VoidItemFlg" = 1 
        AND "CMTRANSPM_PaymentMode" IN ('student_wallet','staff_wallet','student_wallet_clg');
    END IF;
END;
$$;