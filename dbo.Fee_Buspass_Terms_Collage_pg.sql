CREATE OR REPLACE FUNCTION "dbo"."Fee_Buspass_Terms_Collage"(
    "asmayid" VARCHAR(100),
    "mi_id" VARCHAR(50),
    "amcstids" TEXT
)
RETURNS TABLE(
    "OpeningBalance" NUMERIC,
    "amcst_id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
    "transportflag" VARCHAR(10);
BEGIN
    "transportflag" := 'T';

    "sql" := 'SELECT sum("FCSS_ToBePaid") as "OpeningBalance", "amcst_id" 
FROM "CLG"."Fee_College_Student_Status" "CFSS"
INNER JOIN "fee_master_group" ON "fee_master_group"."fmg_id" = "CFSS"."fmg_id"
INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "CFSS"."fmh_id"
WHERE "CFSS"."mi_id" = ' || quote_literal("mi_id") || ' 
AND "CFSS"."asmay_id" = ' || quote_literal("asmayid") || ' 
AND "amcst_id" IN (' || "amcstids" || ') 
AND "FMG_CompulsoryFlag" != ' || quote_literal("transportflag") || ' 
AND "FMH_Flag" = ' || quote_literal("transportflag") || ' 
GROUP BY "AMCST_Id" 
HAVING sum("FCSS_ToBePaid") > 0';

    RETURN QUERY EXECUTE "sql";
END;
$$;