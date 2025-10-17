CREATE OR REPLACE FUNCTION "dbo"."FeeItReceipt_Report"(
    "yearid" bigint,
    "miid" bigint,
    "amstid" bigint
)
RETURNS TABLE (
    "recpno" VARCHAR,
    "dateofrecp" TIMESTAMP,
    "remarks" TEXT,
    "tot" NUMERIC,
    "AMST_Id" BIGINT,
    "AMST_FirstName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "dbo"."Fee_Y_Payment"."FYP_Receipt_No" as "recpno", 
        "dbo"."Fee_Y_Payment"."FYP_Date" as "dateofrecp",
        "dbo"."Fee_T_Payment"."ftp_remarks" as "remarks",
        "dbo"."Fee_T_Payment"."FTP_Paid_Amt" as "tot", 
        "dbo"."Fee_Y_Payment_School_Student"."AMST_Id", 
        "dbo"."Adm_M_Student"."AMST_FirstName"
    FROM "dbo"."Fee_T_Payment"
    INNER JOIN "dbo"."Fee_Y_Payment" 
        ON "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id"
    INNER JOIN "dbo"."Fee_Y_Payment_School_Student" 
        ON "dbo"."Fee_Y_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment_School_Student"."FYP_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student" 
        ON "dbo"."Fee_Y_Payment_School_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_M_Student" 
        ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
    WHERE "dbo"."Adm_M_Student"."amst_id" = "amstid" 
        AND "dbo"."Adm_M_Student"."ASMAY_Id" = "yearid" 
        AND "dbo"."Adm_M_Student"."MI_Id" = "miid";
END;
$$;