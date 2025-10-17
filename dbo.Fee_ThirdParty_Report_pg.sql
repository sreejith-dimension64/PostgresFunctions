CREATE OR REPLACE FUNCTION "dbo"."Fee_ThirdParty_Report"(
    "frmdate" TEXT,
    "todate" TEXT,
    "mid" BIGINT,
    "ayar" BIGINT,
    "flagBorC" VARCHAR(10),
    "stuORotherflag" VARCHAR(10),
    "typeofrptflag" VARCHAR(10)
)
RETURNS TABLE(
    "receiptno" VARCHAR,
    "regno" VARCHAR,
    "name" VARCHAR,
    "classname" VARCHAR,
    "fypdate" VARCHAR,
    "bankorcash" TEXT,
    "bankname" VARCHAR,
    "chequno" VARCHAR,
    "chequedate" VARCHAR,
    "paidamt" NUMERIC,
    "towords" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "typeofrptflag" = 'All' THEN
        RETURN QUERY
        SELECT 
            "Fee_Y_Payment"."FYP_Receipt_No" AS "receiptno",
            "Adm_M_Student"."AMST_RegistrationNo" AS "regno",
            "Adm_M_Student"."AMST_FirstName" AS "name",
            "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
            "Fee_Y_Payment"."FYP_Date" AS "fypdate",
            CASE WHEN "Fee_Y_Payment"."FYP_Bank_Or_Cash" = 'B' THEN 'Bank' ELSE 'Cash' END AS "bankorcash",
            "Fee_Y_Payment"."FYP_Bank_Name" AS "bankname",
            "Fee_Y_Payment"."FYP_DD_Cheque_No" AS "chequno",
            "Fee_Y_Payment"."FYP_DD_Cheque_Date" AS "chequedate",
            "Fee_T_Payment"."FTP_Paid_Amt" AS "paidamt",
            "Fee_T_Payment"."ftp_remarks" AS "towords"
        FROM "Fee_Y_Payment" 
        INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_M_Student"."ASMCL_Id"
        WHERE TO_DATE("Fee_Y_Payment"."FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("frmdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY')
        AND "Adm_M_Student"."MI_Id" = "mid" 
        AND "Adm_M_Student"."ASMAY_Id" = "ayar"
        AND "Adm_M_Student"."AMST_SOL" = "stuORotherflag"
        
        UNION ALL
        
        SELECT 
            "Fee_Y_Payment"."FYP_Receipt_No" AS "receiptno",
            "Preadmission_School_Registration"."PASR_RegistrationNo" AS "regno",
            "Preadmission_School_Registration"."PASR_FirstName" AS "name",
            "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
            "Fee_Y_Payment"."FYP_Date" AS "fypdate",
            CASE WHEN "Fee_Y_Payment"."FYP_Bank_Or_Cash" = 'B' THEN 'Bank' ELSE 'Cash' END AS "bankorcash",
            "Fee_Y_Payment"."FYP_Bank_Name" AS "bankname",
            "Fee_Y_Payment"."FYP_DD_Cheque_No" AS "chequno",
            "Fee_Y_Payment"."FYP_DD_Cheque_Date" AS "chequedate",
            "Fee_T_Payment"."FTP_Paid_Amt" AS "paidamt",
            "Fee_T_Payment"."ftp_remarks" AS "towords"
        FROM "Fee_Y_Payment" 
        INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Fee_Y_Payment_Preadmission_Registration" ON "Fee_Y_Payment_Preadmission_Registration"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Preadmission_School_Registration" ON "Preadmission_School_Registration"."PASR_Id" = "Fee_Y_Payment_Preadmission_Registration"."PASR_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Preadmission_School_Registration"."ASMCL_Id"
        WHERE TO_DATE("Fee_Y_Payment"."FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("frmdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY')
        AND "Preadmission_School_Registration"."MI_Id" = "mid" 
        AND "Preadmission_School_Registration"."ASMAY_Id" = "ayar"
        AND "Fee_Y_Payment"."FYP_Bank_Or_Cash" = "flagBorC";
        
    ELSIF "typeofrptflag" = 'Individual' THEN
        RETURN QUERY
        SELECT 
            "Fee_Y_Payment"."FYP_Receipt_No" AS "receiptno",
            "Adm_M_Student"."AMST_RegistrationNo" AS "regno",
            "Adm_M_Student"."AMST_FirstName" AS "name",
            "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
            "Fee_Y_Payment"."FYP_Date" AS "fypdate",
            CASE WHEN "Fee_Y_Payment"."FYP_Bank_Or_Cash" = 'B' THEN 'Bank' ELSE 'Cash' END AS "bankorcash",
            "Fee_Y_Payment"."FYP_Bank_Name" AS "bankname",
            "Fee_Y_Payment"."FYP_DD_Cheque_No" AS "chequno",
            "Fee_Y_Payment"."FYP_DD_Cheque_Date" AS "chequedate",
            "Fee_T_Payment"."FTP_Paid_Amt" AS "paidamt",
            "Fee_T_Payment"."ftp_remarks" AS "towords"
        FROM "Fee_Y_Payment" 
        INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_M_Student"."ASMCL_Id"
        WHERE TO_DATE("Fee_Y_Payment"."FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("frmdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY')
        AND "Adm_M_Student"."MI_Id" = "mid" 
        AND "Adm_M_Student"."ASMAY_Id" = "ayar" 
        AND "Fee_Y_Payment"."FYP_Bank_Or_Cash" = "flagBorC"
        AND "Adm_M_Student"."AMST_SOL" = "stuORotherflag"
        
        UNION ALL
        
        SELECT 
            "Fee_Y_Payment"."FYP_Receipt_No" AS "receiptno",
            "Preadmission_School_Registration"."PASR_RegistrationNo" AS "regno",
            "Preadmission_School_Registration"."PASR_FirstName" AS "name",
            "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
            "Fee_Y_Payment"."FYP_Date" AS "fypdate",
            CASE WHEN "Fee_Y_Payment"."FYP_Bank_Or_Cash" = 'B' THEN 'Bank' ELSE 'Cash' END AS "bankorcash",
            "Fee_Y_Payment"."FYP_Bank_Name" AS "bankname",
            "Fee_Y_Payment"."FYP_DD_Cheque_No" AS "chequno",
            "Fee_Y_Payment"."FYP_DD_Cheque_Date" AS "chequedate",
            "Fee_T_Payment"."FTP_Paid_Amt" AS "paidamt",
            "Fee_T_Payment"."ftp_remarks" AS "towords"
        FROM "Fee_Y_Payment" 
        INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Fee_Y_Payment_Preadmission_Registration" ON "Fee_Y_Payment_Preadmission_Registration"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        INNER JOIN "Preadmission_School_Registration" ON "Preadmission_School_Registration"."PASR_Id" = "Fee_Y_Payment_Preadmission_Registration"."PASR_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Preadmission_School_Registration"."ASMCL_Id"
        WHERE TO_DATE("Fee_Y_Payment"."FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE("frmdate", 'DD/MM/YYYY') AND TO_DATE("todate", 'DD/MM/YYYY')
        AND "Preadmission_School_Registration"."MI_Id" = "mid" 
        AND "Preadmission_School_Registration"."ASMAY_Id" = "ayar"
        AND "Fee_Y_Payment"."FYP_Bank_Or_Cash" = "flagBorC";
        
    END IF;
    
    RETURN;

END;
$$;