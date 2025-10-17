CREATE OR REPLACE FUNCTION "dbo"."Fee_Buspass_Excess_OP_Bal_Collage"(
    "asmayid" VARCHAR(100),
    "mi_id" VARCHAR(50),
    "amcstids" TEXT
)
RETURNS TABLE(
    "OBOpeningBalance" NUMERIC,
    "OBExcessAmount" NUMERIC,
    "amcst_id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
    "transportflag" VARCHAR(10);
BEGIN
    "transportflag" := 'T';

    "sql" := 'SELECT sum("FCSS_OBArrearAmount") as "OBOpeningBalance", 
                     sum("FCSS_OBExcessAmount") as "OBExcessAmount", 
                     "amcst_id" 
              FROM "CLG"."Fee_College_Student_Status" "CFSS"
              INNER JOIN "fee_master_group" ON "fee_master_group"."fmg_id" = "CFSS"."fmg_id"
              INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "CFSS"."fmh_id"
              WHERE "CFSS"."mi_id" = ' || quote_literal("mi_id") || ' 
                AND "CFSS"."asmay_id" = ' || quote_literal("asmayid") || ' 
                AND "amcst_id" IN (' || "amcstids" || ') 
                AND "FMG_CompulsoryFlag" = ' || quote_literal("transportflag") || ' 
                AND "FMH_Flag" = ' || quote_literal("transportflag") || ' 
              GROUP BY "amcst_id" 
              HAVING sum("FCSS_OBArrearAmount") > 0 OR sum("FCSS_OBExcessAmount") > 0';

    RETURN QUERY EXECUTE "sql";

    RETURN;
END;
$$;