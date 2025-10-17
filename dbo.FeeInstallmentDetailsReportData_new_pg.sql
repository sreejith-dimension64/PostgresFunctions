CREATE OR REPLACE FUNCTION "dbo"."FeeInstallmentDetailsReportData_new"(
    p_Mi_id BIGINT,
    p_Asmay_id BIGINT
)
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
        "Fee_T_Installment"."FTI_Name" AS "Installment_Name",
        "Fee_Master_Installment"."FMI_Name" AS "Installment_Type",
        "Fee_Master_Installment"."FMI_No_Of_Installments" AS "No_of_Installments",
        "Fee_T_Installment_DueDate"."FTIDD_FromDate" AS "FTIDD_FromDate",
        "Fee_T_Installment_DueDate"."FTIDD_ToDate" AS "FTIDD_ToDate",
        "Fee_T_Installment_DueDate"."FTIDD_ApplicableDate" AS "ApplicableDate",
        "Fee_T_Installment_DueDate"."FTIDD_DueDate" AS "FTIDD_DueDate"
    FROM "Fee_T_Installment"
    INNER JOIN "Fee_T_Installment_DueDate" ON "Fee_T_Installment_DueDate"."FTI_Id" = "Fee_T_Installment"."FTI_Id"
    INNER JOIN "Fee_Master_Installment" ON "Fee_Master_Installment"."FMI_Id" = "Fee_T_Installment"."FMI_Id"
    WHERE "Fee_T_Installment_DueDate"."MI_Id" = p_Mi_id 
        AND "Fee_T_Installment_DueDate"."ASMAY_Id" = p_Asmay_id 
        AND "Fee_Master_Installment"."FMI_ActiceFlag" = 1;
END;
$$;