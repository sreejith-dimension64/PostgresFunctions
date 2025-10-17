CREATE OR REPLACE FUNCTION "dbo"."Fee_Buspass_Terms"(
    "asmayid" VARCHAR(100),
    "mi_id" VARCHAR(50),
    "amstids" TEXT
)
RETURNS TABLE(
    "OpeningBalance" NUMERIC,
    "amst_id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
    "transportflag" VARCHAR(10);
BEGIN
    "transportflag" := 'NT';

    "sql" := 'SELECT SUM("fss_tobepaid") AS "OpeningBalance", "amst_id" 
              FROM "fee_student_status" 
              INNER JOIN "fee_master_group" ON "fee_master_group"."fmg_id" = "fee_student_status"."fmg_id"
              INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "fee_student_status"."fmh_id"
              WHERE "fee_student_status"."mi_id" = ' || "mi_id" || ' 
                AND "fee_student_status"."asmay_id" = ' || "asmayid" || ' 
                AND "amst_id" IN (' || "amstids" || ') 
                AND "FMH_Flag" = ''' || "transportflag" || '''
              GROUP BY "amst_id" 
              HAVING SUM("fss_tobepaid") > 0';

    RETURN QUERY EXECUTE "sql";
END;
$$;