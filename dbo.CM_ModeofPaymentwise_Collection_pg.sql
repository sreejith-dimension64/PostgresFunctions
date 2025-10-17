CREATE OR REPLACE FUNCTION "CM_ModeofPaymentwise_Collection" (
    "Flag" VARCHAR(50)
)
RETURNS TABLE (
    "total_amount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "Flag" = 'pda' THEN
        RETURN QUERY
        SELECT SUM("a"."CMTRANSI_UnitRate") AS "total_amount"
        FROM "CM_Transaction_Items" "a"
        INNER JOIN "CM_Transaction" "b" ON "b"."CMTRANS_Id" = "a"."CMTRANS_Id"
        INNER JOIN "CM_Transaction_PaymentMode" "e" ON "e"."CMTRANS_Id" = "a"."CMTRANS_Id"
        WHERE "e"."CMTRANSPM_PaymentMode" = "Flag";
    ELSE
        RETURN QUERY
        SELECT SUM("a"."CMTRANSI_UnitRate") AS "total_amount"
        FROM "CM_Transaction_Items" "a"
        INNER JOIN "CM_Transaction" "b" ON "b"."CMTRANS_Id" = "a"."CMTRANS_Id"
        INNER JOIN "CM_Transaction_PaymentMode" "e" ON "e"."CMTRANS_Id" = "a"."CMTRANS_Id"
        WHERE "e"."CMTRANSPM_PaymentMode" IN ('student_wallet', 'staff_wallet', 'student_wallet_clg');
    END IF;
END;
$$;