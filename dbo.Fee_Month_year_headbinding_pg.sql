CREATE OR REPLACE FUNCTION "dbo"."Fee_Month_year_headbinding"(
    p_fromdate TEXT,
    p_todate TEXT,
    p_mi_id VARCHAR(10),
    p_asmay_id VARCHAR(10),
    p_chequedate BIGINT
)
RETURNS TABLE(
    monthyear TEXT,
    ddd INTEGER,
    rr TEXT,
    vv TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_chequedate = 0 THEN
        RETURN QUERY
        SELECT DISTINCT 
            (TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'Month') || TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'YYYY'))::TEXT AS monthyear,
            EXTRACT(MONTH FROM "dbo"."Fee_Y_Payment"."FYP_Date")::INTEGER AS ddd,
            TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'Month')::TEXT AS rr,
            TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'YYYY')::TEXT AS vv
        FROM "dbo"."Adm_School_Y_Student" 
        INNER JOIN "dbo"."Adm_M_Student" 
            ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student" 
            ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment"
            ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
        WHERE "dbo"."Fee_Y_Payment"."fyp_date"::DATE 
            BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
            AND "dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> 'BO'
            AND "dbo"."Fee_Y_Payment"."mi_id" = p_mi_id
            AND "dbo"."Fee_Y_Payment"."asmay_id" = p_asmay_id
        ORDER BY 
            EXTRACT(MONTH FROM "dbo"."Fee_Y_Payment"."FYP_Date"),
            TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'Month'),
            TO_CHAR("dbo"."Fee_Y_Payment"."FYP_Date", 'YYYY');
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            (TO_CHAR("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date", 'Month') || TO_CHAR("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date", 'YYYY'))::TEXT AS monthyear,
            EXTRACT(MONTH FROM "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date")::INTEGER AS ddd,
            TO_CHAR("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date", 'Month')::TEXT AS rr,
            TO_CHAR("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date", 'YYYY')::TEXT AS vv
        FROM "dbo"."Adm_School_Y_Student" 
        INNER JOIN "dbo"."Adm_M_Student" 
            ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student" 
            ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment"
            ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
        WHERE "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date"::DATE 
            BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
            AND "dbo"."Fee_Y_Payment"."FYP_Chq_Bounce" <> 'BO'
            AND "dbo"."Fee_Y_Payment"."mi_id" = p_mi_id
            AND "dbo"."Fee_Y_Payment"."asmay_id" = p_asmay_id
        ORDER BY 
            EXTRACT(MONTH FROM "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date"),
            TO_CHAR("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date", 'Month'),
            TO_CHAR("dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date", 'YYYY');
    END IF;

END;
$$;