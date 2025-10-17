CREATE OR REPLACE FUNCTION "dbo"."fee_refund_report"(
    "@asmay_id" TEXT,
    "@asmcl_id" TEXT,
    "@asmc_id" TEXT,
    "@mi_id" BIGINT,
    "@fmh_id" BIGINT,
    "@from_date" TIMESTAMP,
    "@to_date" TIMESTAMP
)
RETURNS TABLE(
    "Name" TEXT,
    "FR_RefundNo" TEXT,
    "AMST_ID" BIGINT,
    "FR_RefundAmount" NUMERIC,
    "balance" NUMERIC,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "Date" TEXT,
    "FR_RefundRemarks" TEXT,
    "FMH_FeeName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        COALESCE("AMST_FirstName", '') || ' ' || COALESCE("AMST_MiddleName", ' ') || ' ' || COALESCE("AMST_LastName", ' ') AS "Name",
        "Fee_Refund"."FR_RefundNo",
        "Fee_Refund"."AMST_ID",
        "Fee_Refund"."FR_RefundAmount",
        "Fee_Student_Status"."FSS_RunningExcessAmount" AS "balance",
        "Adm_School_M_Class"."ASMCL_ClassName",
        "Adm_School_M_Section"."ASMC_SectionName",
        TO_CHAR("Fee_Refund"."FR_Date", 'DD/MM/YYYY') AS "Date",
        "Fee_Refund"."FR_RefundRemarks",
        "Fee_Master_Head"."FMH_FeeName"
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    INNER JOIN "Fee_Refund" ON "Fee_Refund"."AMST_ID" = "Adm_School_Y_Student"."AMST_Id"
        AND "Fee_Refund"."ASMAY_ID" = "Adm_School_Y_Student"."ASMAY_ID"
    INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        AND "Fee_Student_Status"."FMH_Id" = "Fee_Refund"."FMH_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Refund"."FMH_ID"
    WHERE "Adm_M_Student"."MI_Id" = "@mi_id" 
        AND "Fee_Student_Status"."ASMAY_Id" = "@asmay_id" 
        AND "Fee_Refund"."FR_RefundFlag" = 'true';
END;
$$;