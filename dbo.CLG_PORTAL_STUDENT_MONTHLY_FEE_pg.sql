CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_STUDENT_MONTHLY_FEE"(
    "p_asmay_id" TEXT,
    "p_amcst_id" TEXT,
    "p_mi_id" TEXT
)
RETURNS TABLE(
    "fmt_id" BIGINT,
    "frommonth" VARCHAR,
    "tomonth" VARCHAR,
    "balance" NUMERIC,
    "paid" NUMERIC,
    "Total" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "Fee_Master_Terms"."fmt_id",
        "Fee_Master_Terms"."frommonth",
        "Fee_Master_Terms"."tomonth",
        SUM("Fee_College_Student_Status"."FCSS_ToBePaid") AS "balance",
        SUM("Fee_College_Student_Status"."FCSS_PaidAmount") AS "paid",
        SUM("Fee_College_Student_Status"."FCSS_TotalCharges") AS "Total"
    FROM "Fee_Master_Terms_FeeHeads"
    INNER JOIN "CLG"."Fee_College_Student_Status" 
        ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status"."fmh_id" 
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "CLG"."Fee_College_Student_Status"."fti_id"
    INNER JOIN "Fee_Master_Terms" 
        ON "Fee_Master_Terms"."fmt_id" = "Fee_Master_Terms_FeeHeads"."fmt_id"
    WHERE "Fee_Master_Terms_FeeHeads"."MI_Id" = "p_mi_id" 
        AND "Fee_College_Student_Status"."AMCST_Id" = "p_amcst_id" 
        AND "Fee_College_Student_Status"."ASMAY_Id" = "p_asmay_id"
    GROUP BY "Fee_Master_Terms"."fmt_id", "Fee_Master_Terms"."frommonth", "Fee_Master_Terms"."tomonth";

END;
$$;