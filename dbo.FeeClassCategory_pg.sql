CREATE OR REPLACE FUNCTION "dbo"."FeeClassCategory" (
    p_ASMAY_ID bigint,
    p_MI_Id bigint
)
RETURNS TABLE (
    "ASMCL_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT cls."ASMCL_Id"
    FROM "Adm_School_M_Class_Category" cat
    INNER JOIN "Adm_School_M_Class" cls ON cat."ASMCL_Id" = cls."ASMCL_Id"
    WHERE cat."MI_Id" = p_MI_Id 
        AND cat."ASMAY_Id" = p_ASMAY_ID 
        AND cls."ASMCL_ActiveFlag" = 1
        AND cls."ASMCL_Id" NOT IN (
            SELECT cl."ASMCL_Id" 
            FROM "Fee_Master_Class_Category" cat
            INNER JOIN "Fee_Yearly_Class_Category" c ON cat."FMCC_Id" = c."FMCC_Id"
            INNER JOIN "Fee_Yearly_Class_Category_Classes" cls ON c."FYCC_Id" = cls."FYCC_Id"
            INNER JOIN "Adm_School_M_Class" cl ON cl."ASMCL_Id" = cls."ASMCL_Id"
            INNER JOIN "Adm_School_M_Academic_Year" yr ON yr."ASMAY_Id" = c."ASMAY_Id"
            WHERE cat."MI_Id" = p_MI_Id 
                AND c."ASMAY_Id" = p_ASMAY_ID
        );
END;
$$;