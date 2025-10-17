CREATE OR REPLACE FUNCTION "dbo"."Fee_Month_year_headbinding_old"(
    "fromdate" TEXT,
    "todate" TEXT,
    "mi_id" BIGINT,
    "asmay_id" BIGINT
)
RETURNS TABLE(
    "monthyear" TEXT,
    "ddd" DOUBLE PRECISION,
    "rr" TEXT,
    "vv" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        (TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'Month') || TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'YYYY'))::TEXT AS "monthyear",
        EXTRACT(MONTH FROM "dbo"."Fee_Y_Payment"."FYP_Date") AS "ddd",
        TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'Month')::TEXT AS "rr",
        TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'YYYY')::TEXT AS "vv"
    FROM "dbo"."Adm_School_Y_Student" 
    INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_Y_Payment_School_Student"."AMST_Id"
    INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
    WHERE TO_DATE("dbo"."Fee_Y_Payment"."fyp_date"::TEXT, 'DD/MM/YYYY') 
        BETWEEN TO_DATE("fromdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY')
    AND ("dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> 'BO')
    AND "dbo"."Fee_Y_Payment"."mi_id" = "mi_id"
    AND "dbo"."Fee_Y_Payment"."asmay_id" = "asmay_id"
    ORDER BY EXTRACT(MONTH FROM "dbo"."Fee_Y_Payment"."FYP_Date"),
             TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'Month'),
             TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'YYYY');

END;
$$;