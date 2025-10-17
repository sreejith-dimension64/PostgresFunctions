CREATE OR REPLACE FUNCTION "dbo"."Get_DatewiseFeecollection_Portal"(
    p_MI_Id INTEGER,
    p_ASMAY_Id INTEGER,
    p_fromdate TIMESTAMP,
    p_todate TIMESTAMP
)
RETURNS TABLE(
    recept BIGINT,
    classid INTEGER,
    classname VARCHAR,
    amount NUMERIC,
    "ASMCL_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        COUNT("repct") AS recept,
        "classid",
        "classname",
        SUM("paid") AS amount,
        "ASMCL_Order"
    FROM (
        SELECT DISTINCT 
            "Fee_Y_Payment"."FYP_Receipt_No" AS "repct",
            "Fee_Y_Payment"."FYP_Date",
            "Adm_School_M_Class"."ASMCL_Id" AS "classid",
            "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
            "Fee_Y_Payment"."FYP_Tot_Amount" AS "paid",
            "Adm_School_M_Class"."ASMCL_Order"
        FROM "dbo"."Fee_Y_Payment_School_Student" 
        INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" 
        INNER JOIN "dbo"."Adm_M_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
            AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Y_Payment_School_Student"."ASMAY_Id" 
        INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
        INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_T_Payment"."FYP_Id" 
        INNER JOIN "dbo"."Fee_Master_Amount" ON "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id" 
        INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
        INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
        INNER JOIN "dbo"."fee_student_status" ON "fee_student_status"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" 
            AND "fee_student_status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
            AND "fee_student_status"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        WHERE "Fee_Y_Payment_School_Student"."ASMAY_Id" = p_ASMAY_Id 
            AND "Adm_School_M_Section"."MI_Id" = p_MI_Id 
            AND CAST("Fee_Y_Payment"."FYP_Date" AS DATE) BETWEEN CAST(p_fromdate AS DATE) AND CAST(p_todate AS DATE)
        GROUP BY 
            "Fee_Y_Payment"."FYP_Receipt_No",
            "Fee_Y_Payment"."FYP_Date",
            "Adm_School_M_Class"."ASMCL_Id",
            "Adm_School_M_Class"."ASMCL_ClassName",
            "Fee_Y_Payment"."FYP_Tot_Amount",
            "Adm_School_M_Class"."ASMCL_Order"
    ) AS "New" 
    GROUP BY "classid", "classname", "ASMCL_Order";

END;
$$;