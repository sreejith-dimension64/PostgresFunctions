CREATE OR REPLACE FUNCTION "dbo"."gettermsstatisticdetails_online"(
    "Asmay_id" VARCHAR(100),
    "Mi_Id" VARCHAR(100),
    "amst_id" VARCHAR(100),
    "fmtids" VARCHAR(100),
    "fmgid" VARCHAR(100)
)
RETURNS TABLE(
    "FMGG_Id" BIGINT,
    "fmt_id" BIGINT,
    "paid" NUMERIC,
    "pending" NUMERIC,
    "payable" NUMERIC,
    "FMT_Name" VARCHAR,
    "FMT_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql1head" TEXT;
    "headflag" VARCHAR(100);
    "count" VARCHAR(100);
    "asmcl_id" BIGINT;
BEGIN
    
    SELECT "IVRMGC_Classwise_Payment" INTO "count" 
    FROM "IVRM_General_Cofiguration_New" 
    WHERE "MI_Id" = "Mi_Id";
    
    IF("count" != '0') THEN
        SELECT "ASMCL_Id" INTO "asmcl_id" 
        FROM "Adm_School_Y_Student" 
        WHERE "AMST_Id" = "amst_id" AND "ASMAY_Id" = "Asmay_id";
    END IF;
    
    IF("asmcl_id" IS NOT NULL AND "asmcl_id" != 0) THEN
        "headflag" := 'T';
        
        "sql1head" := 'SELECT "FMGG_Id", "Fee_OnlinePayment_Mapping"."fmt_id", 
            SUM("FSS_PaidAmount") + SUM("FSS_WaivedAmount") + SUM("FSS_AdjustedAmount") + SUM(COALESCE("FSS_RebateAmount", 0)) AS paid,
            SUM("FSS_ToBePaid") AS pending,
            ((SUM("FSS_CurrentYrCharges")) - SUM("FSS_ConcessionAmount")) AS payable,
            "Fee_Master_Terms"."FMT_Name",
            "Fee_Master_Terms"."FMT_Order"
        FROM "Fee_Master_Group_Grouping_Groups"
        INNER JOIN "Fee_OnlinePayment_Mapping" ON "Fee_OnlinePayment_Mapping"."fmg_id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id"
        INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FMG_Id" = "Fee_OnlinePayment_Mapping"."fmg_id" 
            AND "Fee_Student_Status"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id" 
            AND "Fee_Student_Status"."FTI_Id" = "Fee_OnlinePayment_Mapping"."fti_id"
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_OnlinePayment_Mapping"."fmt_id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
            AND "Fee_Master_Head"."MI_Id" = "Fee_Student_Status"."MI_Id"
        INNER JOIN "Fee_PaymentGateway_Details" ON "Fee_PaymentGateway_Details"."FPGD_Id" = "Fee_OnlinePayment_Mapping"."FPGD_Id"
        INNER JOIN "IVRM_Master_PG" ON "IVRM_Master_PG"."IMPG_Id" = "Fee_PaymentGateway_Details"."IMPG_Id"
        WHERE "Fee_Student_Status"."asmay_id" = ' || "Asmay_id" || ' 
            AND "amst_id" = ' || "amst_id" || ' 
            AND "Fee_OnlinePayment_Mapping"."MI_Id" = ' || "Mi_Id" || ' 
            AND "Fee_Student_Status"."fmg_id" IN (' || "fmgid" || ')
            AND "Fee_Master_Head"."FMH_Flag" != ''F'' 
            AND "Fee_Master_Head"."FMH_Flag" != ''E'' 
            AND "IVRM_Master_PG"."IMPG_PGName" = ''EASEBUZZ''
            AND "Fee_OnlinePayment_Mapping"."ASMCL_Id" IN (' || CAST("asmcl_id" AS VARCHAR(20)) || ')
        GROUP BY "FMGG_Id", "Fee_OnlinePayment_Mapping"."fmt_id", "Fee_Master_Terms"."FMT_Name", "Fee_Master_Terms"."FMT_Order"
        ORDER BY "FMGG_Id", "Fee_OnlinePayment_Mapping"."fmt_id"';
        
    ELSE
        "headflag" := 'T';
        
        "sql1head" := 'SELECT "FMGG_Id", "Fee_OnlinePayment_Mapping"."fmt_id", 
            SUM("FSS_PaidAmount") + SUM("FSS_WaivedAmount") + SUM("FSS_AdjustedAmount") + SUM(COALESCE("FSS_RebateAmount", 0)) AS paid,
            SUM("FSS_ToBePaid") AS pending,
            ((SUM("FSS_CurrentYrCharges")) - SUM("FSS_ConcessionAmount")) AS payable,
            "Fee_Master_Terms"."FMT_Name",
            "Fee_Master_Terms"."FMT_Order"
        FROM "Fee_Master_Group_Grouping_Groups"
        INNER JOIN "Fee_OnlinePayment_Mapping" ON "Fee_OnlinePayment_Mapping"."fmg_id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id"
        INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."FMG_Id" = "Fee_OnlinePayment_Mapping"."fmg_id" 
            AND "Fee_Student_Status"."FMH_Id" = "Fee_OnlinePayment_Mapping"."FMH_Id" 
            AND "Fee_Student_Status"."FTI_Id" = "Fee_OnlinePayment_Mapping"."fti_id"
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_OnlinePayment_Mapping"."fmt_id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
            AND "Fee_Master_Head"."MI_Id" = "Fee_Student_Status"."MI_Id"
        INNER JOIN "Fee_PaymentGateway_Details" ON "Fee_PaymentGateway_Details"."FPGD_Id" = "Fee_OnlinePayment_Mapping"."FPGD_Id"
        INNER JOIN "IVRM_Master_PG" ON "IVRM_Master_PG"."IMPG_Id" = "Fee_PaymentGateway_Details"."IMPG_Id"
        WHERE "Fee_Student_Status"."asmay_id" = ' || "Asmay_id" || ' 
            AND "amst_id" = ' || "amst_id" || ' 
            AND "Fee_OnlinePayment_Mapping"."MI_Id" = ' || "Mi_Id" || ' 
            AND "Fee_Student_Status"."fmg_id" IN (' || "fmgid" || ')
            AND "Fee_Master_Head"."FMH_Flag" != ''F'' 
            AND "Fee_Master_Head"."FMH_Flag" != ''E'' 
            AND "IVRM_Master_PG"."IMPG_PGName" = ''EASEBUZZ''
        GROUP BY "FMGG_Id", "Fee_OnlinePayment_Mapping"."fmt_id", "Fee_Master_Terms"."FMT_Name", "Fee_Master_Terms"."FMT_Order"
        ORDER BY "FMGG_Id", "Fee_OnlinePayment_Mapping"."fmt_id"';
        
    END IF;
    
    RETURN QUERY EXECUTE "sql1head";
    
END;
$$;