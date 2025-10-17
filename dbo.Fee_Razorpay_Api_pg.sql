CREATE OR REPLACE FUNCTION "dbo"."Fee_Razorpay_Api"(
    p_mi_id TEXT,
    p_asmay_id TEXT,
    p_amst_id TEXT,
    p_orderid TEXT
)
RETURNS TABLE(
    amount NUMERIC,
    account TEXT,
    currency TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "FMOT_Amount" AS amount,
        "FMOT_Trans_Id" AS account,
        'INR'::TEXT AS currency
    FROM "Fee_M_Online_Transaction"
    WHERE "FMOT_Id" IN (11641, 11642);
END;
$$;