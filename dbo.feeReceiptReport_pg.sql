CREATE OR REPLACE FUNCTION "dbo"."feeReceiptReport" (
    "@mi_id" BIGINT,
    "@asmyid" BIGINT,
    "@recpno" BIGINT
)
RETURNS TABLE (
    "stuname" VARCHAR,
    "stuadmno" VARCHAR,
    "classnaem" VARCHAR,
    "repno" BIGINT,
    "paidAmt" NUMERIC,
    "fineAmt" NUMERIC,
    "concessionAmt" NUMERIC,
    "particulars" VARCHAR,
    "dateofcheck" TIMESTAMP,
    "typeonmode" TEXT,
    "acayyername" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "Adm_M_Student"."AMST_FirstName" AS "stuname",
        "Adm_M_Student"."AMST_AdmNo" AS "stuadmno",
        "Adm_School_M_Class"."ASMCL_ClassName" AS "classnaem",
        "Fee_Y_Payment"."FYP_Receipt_No" AS "repno",
        "Fee_T_Payment"."FTP_Paid_Amt" AS "paidAmt",
        "Fee_T_Payment"."FTP_Fine_Amt" AS "fineAmt",
        "Fee_T_Payment"."FTP_Concession_Amt" AS "concessionAmt",
        "Fee_Master_Head"."FMH_FeeName" AS "particulars",
        "Fee_Y_Payment"."FYP_DD_Cheque_Date" AS "dateofcheck",
        CASE 
            WHEN "Fee_Y_Payment"."FYP_Bank_Or_Cash" = 'B' THEN 'Bank'
            ELSE 'Cash'
        END AS "typeonmode",
        "Adm_School_M_Academic_Year"."ASMAY_Year" AS "acayyername"
    FROM 
        "dbo"."Adm_School_M_Class"
        INNER JOIN "dbo"."Adm_M_Student" 
            ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_M_Student"."ASMCL_Id"
        INNER JOIN "dbo"."Fee_Y_Payment_School_Student"
        INNER JOIN "dbo"."Fee_Y_Payment"
        INNER JOIN "dbo"."Fee_T_Payment" 
            ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
            ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            ON "Adm_M_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
            ON "Adm_M_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        INNER JOIN "dbo"."Fee_Master_Amount" 
            ON "Fee_T_Payment"."FMA_Id" = "Fee_Master_Amount"."FMA_Id"
        INNER JOIN "dbo"."Fee_Master_Head" 
            ON "Fee_Master_Amount"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    WHERE 
        "Fee_Y_Payment"."FYP_Receipt_No" = "@recpno"
        AND "Adm_M_Student"."ASMAY_Id" = "@asmyid"
        AND "Adm_M_Student"."MI_Id" = "@mi_id";
END;
$$;