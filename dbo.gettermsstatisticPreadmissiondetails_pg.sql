CREATE OR REPLACE FUNCTION "dbo"."gettermsstatisticPreadmissiondetails"(
    p_Asmay_id BIGINT,
    p_Mi_Id BIGINT,
    p_amst_id VARCHAR(100),
    p_fmtids VARCHAR(100)
)
RETURNS TABLE(
    paid NUMERIC,
    netamount NUMERIC,
    balance NUMERIC,
    fmt_id BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql1head TEXT;
    v_headflag VARCHAR(100);
BEGIN
    
    v_headflag := 'T';
    
    v_sql1head := 'SELECT sum("FTP_Paid_Amt") as paid, sum("FMA_Amount") as netamount, sum("FMA_Amount") as balance, "fmt_id" 
FROM "Fee_Master_Amount"  
INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "Fee_Master_Amount"."fmh_id"  
AND "Fee_Master_Terms_FeeHeads"."fti_id" = "Fee_Master_Amount"."fti_id"  
INNER JOIN "fee_master_head" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "fee_master_head"."fmh_id"  
INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
INNER JOIN "Fee_Y_Payment_PA_Application" ON "Fee_Y_Payment_PA_Application"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
WHERE "Fee_Y_Payment_PA_Application"."PASA_Id" = ' || p_amst_id || ' AND "fmt_id" IN (' || p_fmtids || ') AND "FTP_Paid_Amt" > 0  
GROUP BY "fmt_id"';
    
    RETURN QUERY EXECUTE v_sql1head;
    
END;
$$;