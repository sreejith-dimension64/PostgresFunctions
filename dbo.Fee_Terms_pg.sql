CREATE OR REPLACE FUNCTION "dbo"."Fee_Terms"(
    "@mi_id" BIGINT,
    "@Asmay_Id" BIGINT
)
RETURNS TABLE(
    "FMT_Id" BIGINT,
    "fmT_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."fmT_Name"
    FROM "dbo"."fee_student_status"
    INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" 
        ON "fee_student_status"."fmh_id" = "Fee_Master_Terms_FeeHeads"."fmh_id"
    INNER JOIN "dbo"."Fee_Master_Terms" 
        ON "Fee_Master_Terms"."fmt_id" = "Fee_Master_Terms_FeeHeads"."fmt_id"
    WHERE "fee_student_status"."mi_id" = "@mi_id" 
        AND "fee_student_status"."ASMAY_Id" = "@Asmay_Id" 
        AND "fee_student_status"."FSS_CurrentYrCharges" > 0;
END;
$$;