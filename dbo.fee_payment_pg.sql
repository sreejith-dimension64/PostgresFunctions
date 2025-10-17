
CREATE OR REPLACE FUNCTION fee_payment(
    p_asmay_id VARCHAR(10),
    p_fromdate VARCHAR(10),
    p_todate VARCHAR(10),
    p_MI_Id VARCHAR
)
RETURNS TABLE (
    dynamic_result JSON
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cols TEXT;
    v_query TEXT;
    v_cols1 TEXT;
    v_cols2 TEXT;
BEGIN
    
    SELECT STRING_AGG(QUOTE_IDENT(REPLACE("IVRMMOD_ModeOfPayment", ' ', '')), ',')
    INTO v_cols
    FROM (
        SELECT DISTINCT "IVRMMOD_ModeOfPayment"
        FROM "IVRM_ModeOfPayment"
        WHERE "MI_Id" = p_MI_Id::BIGINT
    ) sub;
    
    SELECT STRING_AGG(QUOTE_IDENT(REPLACE("IVRMMOD_ModeOfPayment" || 'count', ' ', '')), ',')
    INTO v_cols2
    FROM (
        SELECT DISTINCT "IVRMMOD_ModeOfPayment"
        FROM "IVRM_ModeOfPayment"
        WHERE "MI_Id" = p_MI_Id::BIGINT
    ) sub;
    
    RAISE NOTICE '%', v_cols2;
    
    v_cols1 := 'CAST("FYP_DATE" AS DATE) BETWEEN ''' || p_fromdate || ''' AND ''' || p_todate || '''';
    
    v_query := '
    SELECT * FROM (
        SELECT DISTINCT 
            "FYP_Date",
            fyp."FYP_Receipt_No" AS recieptnumber,
            C."IVRMMOD_ModeOfPayment" || ''count'' AS IVRMMOD_ModeOfPaymentcount,
            C."IVRMMOD_ModeOfPayment" AS IVRMMOD_ModeOfPayment,
            ftp."FTP_Paid_Amt" AS amount
        FROM "Fee_Yearly_Group_Head_Mapping" fyghm
        INNER JOIN "Fee_Master_Amount" fma ON fyghm."FMH_Id" = fma."FMH_Id"
        INNER JOIN "Fee_T_Payment" ftp 
            INNER JOIN "Fee_Y_Payment" fyp ON ftp."FYP_Id" = fyp."FYP_Id"
            ON fma."FMA_Id" = ftp."FMA_Id"
        INNER JOIN "Fee_Master_Head" fmh ON fyghm."FMH_Id" = fmh."FMH_Id"
        INNER JOIN "IVRM_ModeOfPayment" C ON C."IVRMMOD_ModeOfPayment_Code" = fyp."FYP_Bank_Or_Cash"
        WHERE fyp."FYP_Id" IN (
            SELECT ftp2."FYP_Id"
            FROM "Fee_Master_Amount" fma2
            INNER JOIN "Fee_T_Payment" ftp2 ON fma2."FMA_Id" = ftp2."FMA_Id"
            INNER JOIN "Fee_Yearly_Group_Head_Mapping" fyghm2 ON fma2."FMH_Id" = fyghm2."FMH_Id"
            INNER JOIN "Fee_Yearly_Group" fyg ON fyghm2."FMG_Id" = fyg."FMG_Id"
            INNER JOIN "Fee_Y_Payment" fyp2 ON ftp2."FYP_Id" = fyp2."FYP_Id"
            WHERE fyp2."asmay_id" = ' || p_asmay_id || '
                AND fyp2."mi_id" = ' || p_mi_id || '
                AND ' || v_cols1 || '
        )
    ) src';
    
    v_query := v_query || ' 
    ORDER BY "FYP_Date"';
    
    RAISE NOTICE '%', v_query;
    
    RETURN QUERY EXECUTE v_query;
    
END;
$$;