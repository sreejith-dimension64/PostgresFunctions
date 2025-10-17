CREATE OR REPLACE FUNCTION "dbo"."Feebuspass"(
    "@mi_id" VARCHAR(50),
    "@asmayid" VARCHAR(100),
    "@amstid" TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    "@sql" TEXT;
    "@transportflag" VARCHAR(10);
BEGIN
    "@transportflag" := 'T';

    "@sql" := 'SELECT SUM("fss_tobepaid"), "amst_id" FROM "fee_student_status" ' ||
              'INNER JOIN "fee_master_group" ON "fee_master_group"."fmg_id" = "fee_student_status"."fmg_id" ' ||
              'INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "fee_student_status"."fmh_id" ' ||
              'WHERE "fee_student_status"."mi_id" = ''' || "@mi_id" || ''' ' ||
              'AND "fee_student_status"."asmay_id" = ''' || "@asmayid" || ''' ' ||
              'AND "amst_id" IN (' || "@amstid" || ') ' ||
              'AND "FMG_CompulsoryFlag" != ''' || "@transportflag" || ''' ' ||
              'AND "FMH_Flag" = ''' || "@transportflag" || ''' ' ||
              'GROUP BY "amst_id"';

    RETURN "@sql";
END;
$$;