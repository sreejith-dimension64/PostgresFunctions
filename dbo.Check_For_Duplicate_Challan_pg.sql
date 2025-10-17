CREATE OR REPLACE FUNCTION "dbo"."Check_For_Duplicate_Challan"(
    p_MI_Id INTEGER,
    p_ASMAY_Id BIGINT,
    p_FMT_Id BIGINT,
    p_AMST_Id BIGINT
)
RETURNS TABLE(
    "FMT_Id" BIGINT,
    "AMST_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT fee."FMT_Id", sttus."AMST_Id" 
    FROM "fee_Y_payment" y
    INNER JOIN "fee_t_payment" t ON y."FYP_Id" = t."FYP_Id"
    INNER JOIN "Fee_Student_Status" sttus ON sttus."FMA_Id" = t."FMA_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads" fee ON fee."FMH_Id" = sttus."FMH_Id" 
        AND fee."FTI_Id" = sttus."FTI_Id"
    WHERE y."MI_Id" = p_MI_Id 
        AND y."ASMAY_ID" = p_ASMAY_Id 
        AND fee."FMT_Id" = p_FMT_Id
        AND sttus."AMST_Id" = p_AMST_Id 
        AND "FYP_OnlineChallanStatusFlag" = '1';
END;
$$;