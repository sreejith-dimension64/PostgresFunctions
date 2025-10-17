CREATE OR REPLACE FUNCTION "dbo"."FeeImportInstallmentDetailsFineAmt" (
    p_ASMAY_Id BIGINT,
    p_MI_Id BIGINT,
    p_AMST_Id BIGINT,
    p_FMT_Id BIGINT
)
RETURNS TABLE (
    "FMG_Id" BIGINT,
    "FMH_Id" BIGINT,
    "FTI_Id" BIGINT,
    "FMA_Id" BIGINT,
    "AMST_Id" BIGINT,
    "FSS_ToBePaid" NUMERIC,
    "FSS_PaidAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        A."FMG_Id",
        A."FMH_Id",
        A."FTI_Id",
        A."FMA_Id",
        A."AMST_Id",
        A."FSS_ToBePaid",
        A."FSS_PaidAmount"
    FROM "dbo"."Fee_Student_Status" A
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" B 
        ON A."FMH_Id" = B."FMH_Id" AND A."FTI_Id" = B."FTI_Id"
    INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" C 
        ON C."FMG_Id" = A."FMG_Id" AND C."FMH_Id" = A."FMH_Id"
    INNER JOIN "dbo"."Fee_Master_Head" D 
        ON D."FMH_Id" = A."FMH_Id"
    WHERE A."ASMAY_Id" = p_ASMAY_Id 
        AND A."MI_Id" = p_MI_Id 
        AND A."AMST_Id" = p_AMST_Id 
        AND B."FMT_Id" = p_FMT_Id 
        AND C."FYGHM_FineApplicableFlag" = 'Y' 
        AND D."FMH_Flag" != 'F';
END;
$$;