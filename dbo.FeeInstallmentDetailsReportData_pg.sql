CREATE OR REPLACE FUNCTION "dbo"."FeeInstallmentDetailsReportData"()
RETURNS TABLE(
    "Installment_Name" VARCHAR,
    "Installment_Type" VARCHAR,
    "No_of_Installments" INTEGER,
    "FTIDD_FromDate" TIMESTAMP,
    "FTIDD_ToDate" TIMESTAMP,
    "ApplicableDate" TIMESTAMP,
    "FTIDD_DueDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "ins"."FTI_Name" AS "Installment_Name",
        "inst"."FMI_Name" AS "Installment_Type",
        "inst"."FMI_No_Of_Installments" AS "No_of_Installments",
        "due"."FTIDD_FromDate" AS "FTIDD_FromDate",
        "due"."FTIDD_ToDate" AS "FTIDD_ToDate",
        "due"."FTIDD_ApplicableDate" AS "ApplicableDate",
        "due"."FTIDD_DueDate" AS "FTIDD_DueDate"
    FROM "dbo"."Fee_T_Installment" "ins"
    LEFT JOIN "dbo"."Fee_T_Installment_DueDate" "due" ON "due"."FTI_Id" = "ins"."FTI_Id"
    LEFT JOIN "dbo"."Fee_Master_Installment" "inst" ON "inst"."FMI_Id" = "ins"."FMI_Id";
END;
$$;