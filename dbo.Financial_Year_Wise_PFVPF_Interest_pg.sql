CREATE OR REPLACE FUNCTION "Financial_Year_Wise_PFVPF_Interest"(
    p_MI_Id TEXT
)
RETURNS TABLE (
    "IMFY_FinancialYear" VARCHAR,
    "HRMPFVPFINT_PFInterestRate" NUMERIC,
    "HRMPFVPFINT_VPFInterestRate" NUMERIC,
    "IMFY_Id" BIGINT,
    "HRMPFVPFINT_Id" BIGINT,
    "HRMPFVPFINT_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "B"."IMFY_FinancialYear",
        "A"."HRMPFVPFINT_PFInterestRate",
        "A"."HRMPFVPFINT_VPFInterestRate",
        "B"."IMFY_Id",
        "A"."HRMPFVPFINT_Id",
        "A"."HRMPFVPFINT_ActiveFlg"
    FROM "HR_Master_PFVPF_Interest" "A"
    INNER JOIN "IVRM_Master_FinancialYear" "B" ON "B"."IMFY_Id" = "A"."IMFY_Id"
    WHERE "A"."MI_Id" = p_MI_Id;
END;
$$;