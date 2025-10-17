CREATE OR REPLACE FUNCTION "CollegeOnlineFeeAccountDetails"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCST_Id TEXT,
    p_FMG_Ids TEXT,
    p_FMH_Ids TEXT,
    p_GATEWAYNAME TEXT
)
RETURNS TABLE(
    amount NUMERIC,
    "FPGD_SubMerchantId" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_QUERY TEXT;
BEGIN
    v_QUERY := 'SELECT SUM("FCSS_ToBePaid") as amount, "FPGD_SubMerchantId" 
    FROM "CLG"."CLG_Fee_OnlinePayment_Mapping" A
    INNER JOIN "CLG"."Fee_College_Student_Status" B ON A."fmg_id" = B."FMG_Id" AND A."FMH_Id" = B."FMH_Id" AND B."FTI_Id" = A."fti_id"
    INNER JOIN "Fee_PaymentGateway_Details" C ON A."fpgd_id" = C."FPGD_Id"
    WHERE A."MI_Id" IN (' || p_MI_Id || ') AND B."AMCST_Id" IN (' || p_AMCST_Id || ') AND B."ASMAY_Id" IN (' || p_ASMAY_Id || ') AND 
    A."FMG_Id" IN (' || p_FMG_Ids || ') AND A."FMH_Id" IN (' || p_FMH_Ids || ')
    AND C."FPGD_PGName" = ''' || p_GATEWAYNAME || '''
    GROUP BY "FPGD_SubMerchantId"';
    
    RAISE NOTICE '%', v_QUERY;
    
    RETURN QUERY EXECUTE v_QUERY;
    
END;
$$;