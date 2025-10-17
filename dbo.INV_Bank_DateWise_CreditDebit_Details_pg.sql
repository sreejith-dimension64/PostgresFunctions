CREATE OR REPLACE FUNCTION "dbo"."INV_Bank_DateWise_CreditDebit_Details"(
    p_MI_Id BIGINT,
    p_MONTH VARCHAR(20),
    p_YEAR VARCHAR(20)
)
RETURNS TABLE(
    "PaymentDate" DATE,
    "Particular" TEXT,
    "Voucher" TEXT,
    "TotalCredit" NUMERIC,
    "TotalDebit" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS "#INVDEBIT" (
        "PaymentDate" DATE,
        "Particular" TEXT,
        "Voucher" TEXT,
        "TotalDebit" NUMERIC
    ) ON COMMIT DROP;

    CREATE TEMP TABLE IF NOT EXISTS "#INVCREDIT" (
        "FYP_Id" BIGINT,
        "PaymentDate" DATE,
        "Particular" TEXT,
        "Voucher" TEXT,
        "TotalCredit" NUMERIC
    ) ON COMMIT DROP;

    INSERT INTO "#INVDEBIT"
    SELECT 
        CAST(a."INVSPT_PaymentDate" AS DATE) AS "PaymentDate",
        a."INVSPT_Remarks" AS "Particular",
        'Vendor_Payment' AS "Voucher",
        a."INVSPT_Amount" AS "TotalDebit"
    FROM "INV"."INV_Supplier_Payment" a
    WHERE a."MI_Id" = p_MI_Id 
        AND EXTRACT(MONTH FROM a."INVSPT_PaymentDate") = p_MONTH::INTEGER 
        AND EXTRACT(YEAR FROM a."INVSPT_PaymentDate")::TEXT = p_YEAR
        AND a."INVSPT_ActiveFlg" = 1
        AND a."INVSPT_ModeOfPayment" <> 'Cash';

    INSERT INTO "#INVCREDIT"
    SELECT 
        A."FYP_Id",
        CAST(A."FYP_Date" AS DATE) AS "PaymentDate",
        COALESCE(d."AMST_FirstName", '') || ' ' || COALESCE(d."AMST_MiddleName", '') || '' || COALESCE(d."AMST_LastName", '') || '/' || COALESCE(f."ASMCL_ClassName", '') || ' ' || COALESCE(g."ASMC_SectionName", '') AS "Particular",
        'Student_Fee' AS "Voucher",
        A."FYP_Tot_Amount" AS "TotalCredit"
    FROM "Fee_Y_Payment" A
    INNER JOIN "Fee_Y_Payment_School_Student" b ON A."FYP_Id" = b."FYP_Id"
    INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = b."AMST_Id" 
        AND d."AMST_ActiveFlag" = 1 
        AND d."AMST_SOL" = 'S'
    INNER JOIN "Adm_School_Y_Student" e ON e."AMST_Id" = b."AMST_Id" 
        AND e."ASMAY_Id" = b."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = e."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = e."ASMS_Id"
    WHERE A."MI_Id" = p_MI_Id 
        AND EXTRACT(MONTH FROM A."FYP_Date") = p_MONTH::INTEGER 
        AND EXTRACT(YEAR FROM A."FYP_Date")::TEXT = p_YEAR
        AND A."FYP_Bank_Or_Cash" <> 'C';

    RETURN QUERY
    SELECT 
        d."PaymentDate", 
        d."Particular", 
        d."Voucher", 
        0::NUMERIC AS "TotalCredit", 
        d."TotalDebit"
    FROM "#INVDEBIT" d
    UNION ALL
    SELECT 
        c."PaymentDate", 
        c."Particular", 
        c."Voucher", 
        c."TotalCredit", 
        0::NUMERIC AS "TotalDebit"
    FROM "#INVCREDIT" c
    ORDER BY 1, 3, 2;

    DROP TABLE IF EXISTS "#INVDEBIT";
    DROP TABLE IF EXISTS "#INVCREDIT";

    RETURN;
END;
$$;