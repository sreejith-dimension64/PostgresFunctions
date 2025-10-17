CREATE OR REPLACE FUNCTION "dbo"."Get_Section_DatewiseFeecollection_Portal_11"(
    p_MI_Id INT,
    p_ASMAY_Id INT,
    p_fromdate TIMESTAMP,
    p_todate TIMESTAMP,
    p_ASMCL_Id INT
)
RETURNS TABLE(
    recept BIGINT,
    classid INT,
    classname VARCHAR,
    sectionname VARCHAR,
    amount NUMERIC,
    "ASMCL_Order" INT,
    "SOrder" INT,
    sectionid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT("New"."repct") AS recept,
        "New"."classid",
        "New"."classname",
        "New"."sectionname",
        SUM("New"."paid") AS amount,
        "New"."ASMCL_Order",
        "New"."SOrder",
        "New"."sectionid"
    FROM (
        SELECT DISTINCT 
            "Fee_Y_Payment"."FYP_Receipt_No" AS repct,
            "Fee_Y_Payment"."FYP_Date",
            "Adm_School_M_Class"."ASMCL_Id" AS classid,
            "Adm_School_M_Class"."ASMCL_ClassName" AS classname,
            "Adm_School_M_Section"."ASMC_SectionName" AS sectionname,
            "Adm_School_M_Section"."ASMC_Order" AS "SOrder",
            "Adm_School_Y_Student"."ASMS_Id" AS sectionid,
            "Fee_Y_Payment"."FYP_Tot_Amount" AS paid,
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
            AND CAST("Fee_Y_Payment"."FYP_Date" AS DATE) BETWEEN p_fromdate AND p_todate 
            AND "Adm_School_M_Class"."ASMCL_Id" = p_ASMCL_Id
        GROUP BY 
            "Fee_Y_Payment"."FYP_Receipt_No",
            "Fee_Y_Payment"."FYP_Date",
            "Adm_School_M_Class"."ASMCL_Id",
            "Adm_School_M_Class"."ASMCL_ClassName",
            "Fee_Y_Payment"."FYP_Tot_Amount",
            "Adm_School_M_Class"."ASMCL_Order",
            "Adm_School_M_Section"."ASMC_SectionName",
            "Adm_School_M_Section"."ASMC_Order",
            "Adm_School_Y_Student"."ASMS_Id"
    ) AS "New"
    GROUP BY 
        "New"."classid",
        "New"."classname",
        "New"."ASMCL_Order",
        "New"."sectionname",
        "New"."SOrder",
        "New"."sectionid";
END;
$$;