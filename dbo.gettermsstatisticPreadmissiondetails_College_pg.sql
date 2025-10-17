CREATE OR REPLACE FUNCTION "dbo"."gettermsstatisticPreadmissiondetails_College"(
    "@Asmay_id" bigint,
    "@Mi_Id" bigint,
    "@amst_id" varchar(100),
    "@fmgids" VARCHAR(100),
    "@flag" varchar(100)
)
RETURNS TABLE(
    "paid" numeric,
    "netamount" numeric,
    "balance" numeric,
    "FMG_Id" bigint,
    "fmt_id" bigint
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@sql1head" text;
    "@headflag" varchar;
BEGIN
    
    IF "@flag" = 'G' THEN
        
        "@sql1head" := 'SELECT sum("FTCP_PaidAmount") as paid, sum("FCMAS_Amount") as netamount, sum("FCMAS_Amount") as balance, "FMG_Id", NULL::bigint as fmt_id
        FROM "CLG"."Fee_College_Master_Amount"
        INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" ON "CLG"."Fee_College_Master_Amount"."FCMA_Id" = "CLG"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id"
        INNER JOIN "CLG"."Fee_T_College_Payment" ON "CLG"."Fee_T_College_Payment"."FCMAS_Id" = "CLG"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id"
        INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" ON "CLG"."Fee_Y_Payment_PA_Application"."FYP_Id" = "CLG"."Fee_T_College_Payment"."FYP_Id"
        WHERE "CLG"."Fee_Y_Payment_PA_Application"."PACA_Id" = ' || quote_literal("@amst_id") || ' AND "FTCP_PaidAmount" > 0 AND "FMG_Id" IN (' || "@fmgids" || ')
        GROUP BY "FMG_Id"';
        
        RETURN QUERY EXECUTE "@sql1head";
        
    ELSIF "@flag" = 'T' THEN
        
        "@sql1head" := 'SELECT sum("FTP_Paid_Amt") as paid, sum("FMA_Amount") as netamount, sum("FMA_Amount") as balance, NULL::bigint as "FMG_Id", "fmt_id"
        FROM "CLG"."Fee_College_Master_Amount"
        INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" ON "CLG"."Fee_College_Master_Amount"."FCMA_Id" = "CLG"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "Fee_Master_Amount"."fmh_id"
        AND "Fee_Master_Terms_FeeHeads"."fti_id" = "Fee_Master_Amount"."fti_id"
        INNER JOIN "fee_master_head" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "fee_master_head"."fmh_id"
        INNER JOIN "CLG"."Fee_T_College_Payment" ON "CLG"."Fee_T_College_Payment"."FCMAS_Id" = "CLG"."Fee_College_Master_Amount_Semesterwise"."FCMAS_Id"
        INNER JOIN "CLG"."Fee_Y_Payment_PA_Application" ON "CLG"."Fee_Y_Payment_PA_Application"."FYP_Id" = "CLG"."Fee_T_College_Payment"."FYP_Id"
        WHERE "CLG"."Fee_Y_Payment_PA_Application"."PASA_Id" = ' || quote_literal("@amst_id") || ' AND "fmt_id" IN (' || "@fmgids" || ') AND "FTP_Paid_Amt" > 0
        GROUP BY "fmt_id"';
        
        RETURN QUERY EXECUTE "@sql1head";
        
    END IF;
    
    RETURN;
    
END;
$$;