CREATE OR REPLACE FUNCTION "dbo"."Get_Section_DatewiseFeecollection_Portal"(
    "@MI_Id" integer,
    "@ASMAY_Id" integer,
    "@fromdate" timestamp,
    "@todate" timestamp,
    "@ASMCL_Id" integer
)
RETURNS TABLE(
    "recept" bigint,
    "classid" integer,
    "classname" varchar,
    "sectionname" varchar,
    "amount" numeric,
    "ASMCL_Order" integer,
    "SOrder" integer,
    "sectionid" integer
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        COUNT("repct") AS "recept",
        "classid",
        "classname",
        "sectionname",
        SUM("paid") AS "amount",
        "ASMCL_Order",
        "SOrder",
        "sectionid" 
    FROM (
        SELECT DISTINCT 
            "Fee_Y_Payment"."FYP_Receipt_No" AS "repct",
            "Fee_Y_Payment"."FYP_Date",
            "Adm_School_M_Class"."ASMCL_Id" AS "classid",
            "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
            "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname",
            "Adm_School_M_Section"."ASMC_Order" AS "SOrder",
            "Adm_School_Y_Student"."ASMS_Id" AS "sectionid",
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
        WHERE "Fee_Y_Payment_School_Student"."ASMAY_Id" = "@ASMAY_Id" 
            AND "Adm_School_M_Section"."MI_Id" = "@MI_Id" 
            AND CAST("Fee_Y_Payment"."FYP_Date" AS date) BETWEEN CAST("@fromdate" AS date) AND CAST("@todate" AS date) 
            AND "Adm_School_M_Class"."ASMCL_Id" = "@ASMCL_Id"
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
    GROUP BY "classid", "classname", "ASMCL_Order", "sectionname", "SOrder", "sectionid";

END;
$$;