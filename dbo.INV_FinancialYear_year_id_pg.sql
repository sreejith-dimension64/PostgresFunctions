CREATE OR REPLACE FUNCTION "dbo"."INV_FinancialYear_year_id"()
RETURNS TABLE("IMFY_Id" INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "IVRM_Master_FinancialYear"."IMFY_Id" 
    FROM "dbo"."IVRM_Master_FinancialYear" 
    WHERE CURRENT_TIMESTAMP BETWEEN "IVRM_Master_FinancialYear"."IMFY_fromdate" AND "IVRM_Master_FinancialYear"."IMFY_Todate";
END;
$$;