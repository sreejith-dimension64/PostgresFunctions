CREATE OR REPLACE FUNCTION "dbo"."Admission_TC_Fee_LastDate_Paid"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE(
    "FMT_Name" VARCHAR,
    "FMTFHDD_ToDate" VARCHAR,
    "FMT_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT "Fee_Master_Terms"."FMT_Name",
           TO_CHAR("Fee_Master_Terms_FeeHeads_DueDate"."FMTFHDD_ToDate", 'DD/MM/YYYY') AS "FMTFHDD_ToDate",
           "Fee_Master_Terms"."FMT_Order"
    FROM "Fee_Y_Payment"
    INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
    INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
    INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        AND "Fee_Student_Status"."FMA_Id" = "Fee_T_Payment"."FMA_Id" 
        AND "Fee_Student_Status"."ASMAY_Id" = "Fee_Y_Payment"."ASMAY_ID"
    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
    INNER JOIN "Fee_Master_Terms_FeeHeads_DueDate" ON "Fee_Master_Terms_FeeHeads"."FMTFH_Id" = "Fee_Master_Terms_FeeHeads_DueDate"."FMTFH_Id"
        AND "Fee_Master_Terms_FeeHeads_DueDate"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
    INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
    WHERE "Fee_Student_Status"."AMST_Id" = "@AMST_Id"
        AND "Fee_Student_Status"."MI_Id" = "@MI_Id"
        AND "Fee_Student_Status"."ASMAY_Id" = "@ASMAY_Id"
    ORDER BY "Fee_Master_Terms"."FMT_Order" DESC
    LIMIT 1;

END;
$$;