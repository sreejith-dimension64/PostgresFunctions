CREATE OR REPLACE FUNCTION "dbo"."gettermsstatisticdetails"(
    "Asmay_id" VARCHAR(100),
    "Mi_Id" BIGINT,
    "amst_id" VARCHAR(100),
    "fmtids" VARCHAR(100),
    "userid" VARCHAR(100)
)
RETURNS TABLE(
    "paid" NUMERIC,
    "netamount" NUMERIC,
    "balance" NUMERIC,
    "FMT_Id" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "sql1head" TEXT;
    "headflag" VARCHAR(100);
BEGIN
    "headflag" := 'T';
    
    "sql1head" := 'SELECT SUM("fss_paidamount") + SUM("FSS_ConcessionAmount") + SUM("FSS_AdjustedAmount") + SUM("FSS_WaivedAmount") AS paid, 
                          SUM("fss_netamount") + SUM("FSS_OBArrearAmount") AS netamount, 
                          SUM("fss_tobepaid") AS balance, 
                          "FMT_Id" 
                   FROM "fee_student_status"
                   INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "fee_student_status"."fmh_id"
                   AND "Fee_Master_Terms_FeeHeads"."fti_id" = "fee_student_status"."fti_id"
                   INNER JOIN "fee_master_head" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "fee_master_head"."fmh_id"
                   WHERE "fee_student_status"."amst_id" = ' || quote_literal("amst_id") || ' 
                   AND "fmt_id" IN (' || "fmtids" || ') 
                   AND "fss_netamount" > 0 
                   AND "fee_student_status"."user_id" = ' || quote_literal("userid") || ' 
                   AND "fee_student_status"."asmay_id" = ' || quote_literal("Asmay_id") || '
                   GROUP BY "fmt_id"';
    
    RETURN QUERY EXECUTE "sql1head";
    
    RETURN;
END;
$$;