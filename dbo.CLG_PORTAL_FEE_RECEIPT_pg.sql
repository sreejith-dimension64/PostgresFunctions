CREATE OR REPLACE FUNCTION "dbo"."CLG_PORTAL_FEE_RECEIPT" (
    "@mi_id" bigint,
    "@amcstid" bigint,
    "@asmayid" bigint,
    "@recpno" TEXT
)
RETURNS TABLE (
    "AMCST_Id" bigint,
    "stuname" TEXT,
    "stuadmno" TEXT,
    "classnaem" TEXT,
    "sectionname" TEXT,
    "repno" TEXT,
    "transcaction_id" TEXT,
    "paidAmt" numeric,
    "fineAmt" numeric,
    "concessionAmt" numeric,
    "particulars" TEXT,
    "netAmount" numeric,
    "totalAmount" numeric,
    "dateofcheck" TIMESTAMP,
    "typeonmode" TEXT,
    "acayyername" TEXT,
    "bankname" TEXT,
    "chequeno" TEXT,
    "chequedate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b."AMCST_Id",
        b."AMCST_FirstName" as stuname, 
        b."AMCST_AdmNo" as stuadmno, 
        e."AMSE_SEMName" as classnaem,
        m."ACMS_SectionName" as sectionname,
        h."FYP_ReceiptNo" as repno,
        h."fyp_transaction_id" as transcaction_id, 
        i."FTCP_PaidAmount" as paidAmt, 
        i."FTCP_FineAmount" as fineAmt, 
        i."FTCP_ConcessionAmount" as concessionAmt,
        l."FMH_FeeName" as particulars, 
        j."FCMAS_Amount" as netAmount,
        (i."FTCP_PaidAmount" - i."FTCP_ConcessionAmount" + i."FTCP_FineAmount") as totalAmount,
        n."FYPPM_DDChequeDate" as dateofcheck,
        (CASE 
            WHEN h."FYP_PayModeType" = 'B' THEN 'Bank' 
            WHEN h."FYP_PayModeType" = 'C' THEN 'Cash' 
            WHEN h."FYP_PayModeType" = 'O' THEN 'Online' 
        END) as typeonmode, 
        f."ASMAY_Year" as acayyername, 
        n."FYPPM_BankName" as bankname,
        n."FYPPM_DDChequeNo" as chequeno,
        n."FYPPM_DDChequeDate" as chequedate
    FROM "clg"."Adm_College_Yearly_Student" a 
    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "clg"."Adm_College_Master_Section" m ON m."ACMS_Id" = a."ACMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
    INNER JOIN "clg"."Fee_Y_Payment_College_Student" g ON g."AMCST_Id" = a."AMCST_Id"
    INNER JOIN "clg"."Fee_Y_Payment" h ON h."FYP_Id" = g."FYP_Id"
    INNER JOIN "clg"."Fee_T_College_Payment" i ON i."FYP_Id" = h."FYP_Id"
    INNER JOIN "clg"."Fee_Y_Payment_PaymentMode" n ON n."FYP_Id" = h."FYP_Id"
    INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" j ON j."FCMAS_Id" = i."FCMAS_Id"
    INNER JOIN "clg"."Fee_College_Master_Amount" k ON k."FCMA_Id" = j."FCMA_Id"
    INNER JOIN "Fee_Master_Head" l ON l."FMH_Id" = k."FMH_Id"
    WHERE h."FYP_ReceiptNo" = "@recpno" 
        AND h."ASMAY_Id" = "@asmayid" 
        AND b."MI_Id" = "@mi_id" 
        AND b."AMCST_Id" = "@amcstid";
END;
$$;