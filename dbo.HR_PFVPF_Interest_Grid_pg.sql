CREATE OR REPLACE FUNCTION "HR_PFVPF_Interest_Grid"(p_MI_Id bigint)
RETURNS TABLE(
    "IMFY_FinancialYear" VARCHAR,
    "HRMPFVPFINT_PFInterestRate" NUMERIC,
    "HRMPFVPFINT_VPFInterestRate" NUMERIC,
    "HRMPFVPFINT_ActiveFlg" BOOLEAN,
    "IMFY_Id" BIGINT,
    "HRMPFVPFINT_Id" BIGINT
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."IMFY_FinancialYear",
        a."HRMPFVPFINT_PFInterestRate",
        a."HRMPFVPFINT_VPFInterestRate",
        a."HRMPFVPFINT_ActiveFlg",
        a."IMFY_Id",
        a."HRMPFVPFINT_Id"
    FROM "HR_Master_PFVPF_Interest" a
    INNER JOIN "IVRM_Master_FinancialYear" b ON a."IMFY_Id" = b."IMFY_Id"
    WHERE a."MI_Id" = p_MI_Id AND a."HRMPFVPFINT_ActiveFlg" = true;
END;
$$;