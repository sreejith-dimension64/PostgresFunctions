CREATE OR REPLACE FUNCTION "dbo"."Fee_Buspass_Excess_OP_Bal"(
    "asmayid" VARCHAR(100),
    "mi_id" VARCHAR(50),
    "amstids" TEXT
)
RETURNS TABLE(
    "OBOpeningBalance" NUMERIC,
    "OBExcessAmount" NUMERIC,
    "amst_id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
    "transportflag" VARCHAR(10);
BEGIN
    "transportflag" := 'T';
    
    "sql" := 'SELECT sum("FSS_OBArrearAmount") as "OBOpeningBalance", sum("FSS_OBExcessAmount") as "OBExcessAmount", "amst_id" 
              FROM "fee_student_status" 
              INNER JOIN "fee_master_group" ON "fee_master_group"."fmg_id" = "fee_student_status"."fmg_id"
              INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "fee_student_status"."fmh_id"
              WHERE "fee_student_status"."mi_id" = ' || quote_literal("mi_id") || ' 
                AND "fee_student_status"."asmay_id" = ' || quote_literal("asmayid") || ' 
                AND "amst_id" IN (' || "amstids" || ') 
                AND "FMG_CompulsoryFlag" = ' || quote_literal("transportflag") || ' 
                AND "FMH_Flag" = ' || quote_literal("transportflag") || ' 
              GROUP BY "amst_id" 
              HAVING sum("FSS_OBArrearAmount") > 0 OR sum("FSS_OBExcessAmount") > 0';
    
    RETURN QUERY EXECUTE "sql";
END;
$$;