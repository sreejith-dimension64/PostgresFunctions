CREATE OR REPLACE FUNCTION "dbo"."GatewayRateDetails"(
    "p_MI_Id" bigint,
    "p_Type" varchar(50)
)
RETURNS TABLE (
    "MI_Id" bigint,
    "IMPG_Id" bigint,
    "FPGR_Id" bigint,
    "FPGR_RatePercent" numeric,
    "FPGR_Date" timestamp,
    "FPGR_ActiveFlg" boolean
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_IMPG_Id" BIGINT;
BEGIN
    
    SELECT "IMPG_Id" INTO "v_IMPG_Id" 
    FROM "IVRM_Master_PG" 
    WHERE "IMPG_PGFlag" = "p_Type";
    
    RETURN QUERY
    SELECT * 
    FROM "Fee_PaymentGateway_Rate" 
    WHERE "MI_Id" = "p_MI_Id" 
    AND "IMPG_Id" = "v_IMPG_Id";
    
END;
$$;