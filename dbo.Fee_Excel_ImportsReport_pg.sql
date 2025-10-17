CREATE OR REPLACE FUNCTION "Fee_Excel_ImportsReport"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_Fromdate timestamp,
    p_Todate timestamp
)
RETURNS TABLE (
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "FEIPST_Id" bigint,
    "FEIPST_Date" timestamp,
    "FEIPST_ActiveFlg" boolean,
    "FEIPST_StudentName" text,
    "FEIPST_ClassName" text,
    "FEIPST_SectionName" text,
    "FEIPST_AdmNo" text,
    "FEIPST_FeeName" text,
    "FEIPST_FeeAmount" numeric,
    "FEIPST_PaidAmount" numeric,
    "FEIPST_ConcessionAmount" numeric,
    "FEIPST_FineAmount" numeric,
    "FEIPST_ReceiptNo" text,
    "FEIPST_ReceiptDate" timestamp,
    "FEIPST_PaymentMode" text,
    "FEIPST_ChequeDDNo" text,
    "FEIPST_ChequeDDDate" timestamp,
    "FEIPST_BankName" text,
    "FEIPST_Narration" text,
    "FEIPST_CreatedBy" bigint,
    "FEIPST_CreatedDate" timestamp,
    "FEIPST_UpdatedBy" bigint,
    "FEIPST_UpdatedDate" timestamp,
    "ASMAY_Year" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        A."MI_Id",
        A."ASMAY_Id",
        A."FEIPST_Id",
        A."FEIPST_Date",
        A."FEIPST_ActiveFlg",
        A."FEIPST_StudentName",
        A."FEIPST_ClassName",
        A."FEIPST_SectionName",
        A."FEIPST_AdmNo",
        A."FEIPST_FeeName",
        A."FEIPST_FeeAmount",
        A."FEIPST_PaidAmount",
        A."FEIPST_ConcessionAmount",
        A."FEIPST_FineAmount",
        A."FEIPST_ReceiptNo",
        A."FEIPST_ReceiptDate",
        A."FEIPST_PaymentMode",
        A."FEIPST_ChequeDDNo",
        A."FEIPST_ChequeDDDate",
        A."FEIPST_BankName",
        A."FEIPST_Narration",
        A."FEIPST_CreatedBy",
        A."FEIPST_CreatedDate",
        A."FEIPST_UpdatedBy",
        A."FEIPST_UpdatedDate",
        B."ASMAY_Year"
    FROM "Fee_Excel_Imports_Pending_Students" A
    INNER JOIN "Adm_School_M_Academic_Year" B ON A."ASMAY_Id" = B."ASMAY_Id"
    WHERE A."MI_Id" = p_MI_Id 
        AND A."ASMAY_Id" = p_ASMAY_Id 
        AND CAST(A."FEIPST_Date" AS date) BETWEEN CAST(p_Fromdate AS date) AND CAST(p_Todate AS date)
        AND A."FEIPST_ActiveFlg" = true;
END;
$$;