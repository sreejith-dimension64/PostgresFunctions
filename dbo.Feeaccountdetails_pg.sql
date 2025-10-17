CREATE OR REPLACE FUNCTION "dbo"."Feeaccountdetails"(
    "AMST_id" VARCHAR(100),
    "ASMAYID" VARCHAR(100),
    "FMTID" TEXT,
    "FMGGID" TEXT,
    "MI_Id" VARCHAR(100)
)
RETURNS TABLE(
    "FSS_Tobepaid" NUMERIC,
    "FPGD_SubMerchantId" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "QUERY" TEXT;
    "IVRMGC_Classwise_Payment" TEXT;
    "ASMCL_Id" VARCHAR(50);
    "AMST_Stdid" BIGINT;
    "ASMAY_AcademiciD" BIGINT;
BEGIN
    
    "AMST_Stdid" := "AMST_id"::BIGINT;
    
    "ASMAY_AcademiciD" := "ASMAYID"::BIGINT;
    
    SELECT "ASMCL_Id" INTO "ASMCL_Id" 
    FROM "Adm_School_Y_Student" 
    WHERE "AMST_Id" = "AMST_Stdid" AND "ASMAY_Id" = "ASMAY_AcademiciD";
    
    SELECT "IVRMGC_Classwise_Payment" INTO "IVRMGC_Classwise_Payment" 
    FROM "IVRM_General_Cofiguration_New" 
    WHERE "MI_Id" = "MI_Id";
    
    IF "IVRMGC_Classwise_Payment" = '1' THEN
        
        "QUERY" := 'SELECT SUM("FSS_Tobepaid") as "FSS_Tobepaid", "FPGD_SubMerchantId" 
        FROM "Fee_OnlinePayment_Mapping" A
        INNER JOIN "Fee_Student_Status" B ON B."FMG_Id" = A."FMG_Id" AND B."FMH_Id" = A."FMH_Id" AND A."fti_id" = B."FTI_Id"
        INNER JOIN "Fee_PaymentGateway_Details" C ON C."FPGD_Id" = A."fpgd_id"
        WHERE A."fmg_id" IN (' || "FMGGID" || ') AND
        B."AMST_Id" IN (' || "AMST_id" || ') AND B."ASMAY_Id" IN (' || "ASMAYID" || ') AND "FPGD_PGName" = ''EASEBUZZ'' AND A."MI_Id" IN (' || "MI_Id" || ')
        AND "fmt_id" IN (' || "FMTID" || ') AND A."ASMCL_Id" IN (' || "ASMCL_Id" || ')
        GROUP BY "FPGD_SubMerchantId"';
        
    ELSE
        
        "QUERY" := 'SELECT SUM("FSS_Tobepaid") as "FSS_Tobepaid", "FPGD_SubMerchantId" 
        FROM "Fee_OnlinePayment_Mapping" A
        INNER JOIN "Fee_Student_Status" B ON B."FMG_Id" = A."FMG_Id" AND B."FMH_Id" = A."FMH_Id" AND A."fti_id" = B."FTI_Id"
        INNER JOIN "Fee_PaymentGateway_Details" C ON C."FPGD_Id" = A."fpgd_id"
        WHERE A."fmg_id" IN (' || "FMGGID" || ') AND
        B."AMST_Id" IN (' || "AMST_id" || ') AND B."ASMAY_Id" IN (' || "ASMAYID" || ') AND "FPGD_PGName" = ''EASEBUZZ'' AND A."MI_Id" IN (' || "MI_Id" || ')
        AND "fmt_id" IN (' || "FMTID" || ')
        GROUP BY "FPGD_SubMerchantId"';
        
    END IF;
    
    RETURN QUERY EXECUTE "QUERY";
    
END;
$$;