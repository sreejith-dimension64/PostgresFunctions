CREATE OR REPLACE FUNCTION "dbo"."CollegeOnlineFeeAccountDetailsGroupwise"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMCST_Id" TEXT,
    "FMG_Ids" TEXT,
    "GATEWAYNAME" TEXT,
    "Amount" BIGINT
)
RETURNS TABLE(
    "FCSS_ToBePaid" BIGINT,
    "FPGD_SubMerchantId" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "QUERY" TEXT;
BEGIN
    "QUERY" := 'SELECT ' || "Amount" || ' AS "FCSS_ToBePaid", "FPGD_SubMerchantId" 
    FROM "CLG"."CLG_Fee_OnlinePayment_Mapping" A
    INNER JOIN "CLG"."Fee_College_Student_Status" B ON A."fmg_id" = B."FMG_Id" AND A."FMH_Id" = B."FMH_Id" AND B."FTI_Id" = A."fti_id"
    INNER JOIN "Fee_PaymentGateway_Details" C ON A."fpgd_id" = C."FPGD_Id"
    WHERE A."MI_Id" IN (' || "MI_Id" || ') 
    AND B."AMCST_Id" IN (' || "AMCST_Id" || ') 
    AND B."ASMAY_Id" IN (' || "ASMAY_Id" || ') 
    AND A."FMG_Id" IN (' || "FMG_Ids" || ')
    AND C."FPGD_PGName" = ''' || "GATEWAYNAME" || '''
    GROUP BY "FPGD_SubMerchantId"';
    
    RAISE NOTICE '%', "QUERY";
    
    RETURN QUERY EXECUTE "QUERY";
END;
$$;