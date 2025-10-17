CREATE OR REPLACE FUNCTION "dbo"."Fee_challan_report" (
    "p_mi_id" bigint,
    "p_Asmay_Id" bigint,
    "p_asmcl_id" bigint,
    "p_amsc_id" bigint,
    "p_fromdate" text,
    "p_todate" text,
    "p_type" text
)
RETURNS TABLE (
    "Name" text,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "FYP_Receipt_No" varchar,
    "FYP_Bank_Or_Cash" varchar,
    "FYP_Tot_Amount" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "p_type" = '1' THEN
        RETURN QUERY
        SELECT 
            COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '') AS "Name",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
            "dbo"."Adm_School_M_Section"."ASMC_SectionName",
            "dbo"."Fee_Y_Payment"."FYP_Receipt_No",
            "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash",
            "dbo"."Fee_Y_Payment"."FYP_Tot_Amount"
        FROM "dbo"."Fee_Y_Payment"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment_School_Student"."FYP_Id"
        INNER JOIN "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        WHERE "dbo"."Fee_Y_Payment"."MI_Id" = "p_mi_id"
            AND "dbo"."Fee_Y_Payment"."ASMAY_ID" = "p_Asmay_Id"
            AND "dbo"."Adm_School_M_Section"."ASMS_Id" = "p_amsc_id"
            AND "dbo"."Adm_School_M_Class"."ASMCL_Id" = "p_asmcl_id"
            AND "dbo"."Fee_Y_Payment"."FYP_Date" BETWEEN TO_DATE("p_fromdate", 'DD/MM/YYYY') AND TO_DATE("p_todate", 'DD/MM/YYYY');
    ELSE
        RETURN QUERY
        SELECT 
            COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '') AS "Name",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName",
            "dbo"."Adm_School_M_Section"."ASMC_SectionName",
            "dbo"."Fee_Y_Payment"."FYP_Receipt_No",
            "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash",
            "dbo"."Fee_Y_Payment"."FYP_Tot_Amount"
        FROM "dbo"."Fee_Y_Payment"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment_School_Student"."FYP_Id"
        INNER JOIN "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        WHERE "dbo"."Fee_Y_Payment"."MI_Id" = "p_mi_id"
            AND "dbo"."Fee_Y_Payment"."ASMAY_ID" = "p_Asmay_Id"
            AND "dbo"."Adm_School_M_Section"."ASMS_Id" = "p_amsc_id"
            AND "dbo"."Adm_School_M_Class"."ASMCL_Id" = "p_asmcl_id"
            AND "dbo"."Fee_Y_Payment"."FYP_Date" BETWEEN TO_DATE("p_fromdate", 'DD/MM/YYYY') AND TO_DATE("p_todate", 'DD/MM/YYYY');
    END IF;

    RETURN;

END;
$$;