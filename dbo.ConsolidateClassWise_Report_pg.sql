CREATE OR REPLACE FUNCTION "dbo"."ConsolidateClassWise_Report"(
    "@ayar" bigint,
    "@clasid" bigint,
    "@mid" bigint,
    "@secid" bigint,
    "@flag" varchar(10)
)
RETURNS TABLE(
    "AMST_FirstName" varchar,
    "FYP_Receipt_No" varchar,
    "FYP_Bank_Name" varchar,
    "FYP_DD_Cheque_Date" timestamp,
    "FYP_DD_Cheque_No" varchar,
    "FYP_Date" timestamp,
    "FYP_Tot_Amount" numeric,
    "ASMC_SectionName" varchar,
    "ASMCL_ClassName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "@flag" = 'Academic' THEN
        RETURN QUERY
        SELECT DISTINCT
            "dbo"."Adm_M_Student"."AMST_FirstName",
            "dbo"."Fee_Y_Payment"."FYP_Receipt_No",
            "dbo"."Fee_Y_Payment"."FYP_Bank_Name",
            "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date",
            "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_No",
            "dbo"."Fee_Y_Payment"."FYP_Date",
            "dbo"."Fee_Y_Payment"."FYP_Tot_Amount",
            "dbo"."Adm_School_M_Section"."ASMC_SectionName",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student" 
            ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment" 
            ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "dbo"."Adm_M_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        WHERE "dbo"."Adm_M_Student"."ASMAY_Id" = "@ayar"
            AND "dbo"."Adm_M_Student"."MI_Id" = "@mid"
            AND "dbo"."Adm_School_M_Class"."ASMCL_Id" = "@clasid"
            AND "dbo"."Adm_School_M_Section"."ASMS_Id" = "@secid";
    ELSE
        RETURN QUERY
        SELECT DISTINCT
            "dbo"."Adm_M_Student"."AMST_FirstName",
            "dbo"."Fee_Y_Payment"."FYP_Receipt_No",
            "dbo"."Fee_Y_Payment"."FYP_Bank_Name",
            "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date",
            "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_No",
            "dbo"."Fee_Y_Payment"."FYP_Date",
            "dbo"."Fee_Y_Payment"."FYP_Tot_Amount",
            "dbo"."Adm_School_M_Section"."ASMC_SectionName",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student" 
            ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment" 
            ON "dbo"."Fee_Y_Payment_School_Student"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "dbo"."Adm_M_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        WHERE "dbo"."Adm_M_Student"."ASMAY_Id" = "@ayar"
            AND "dbo"."Adm_M_Student"."MI_Id" = "@mid";
    END IF;
    
    RETURN;
END;
$$;