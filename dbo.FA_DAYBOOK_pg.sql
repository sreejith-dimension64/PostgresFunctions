CREATE OR REPLACE FUNCTION "FA_DAYBOOK" (p_FAMVOU_Id bigint)
RETURNS TABLE (
    "RowNumber" bigint,
    "FAMCOMP_Id" bigint,
    "FATVOU_Id" bigint,
    "FAMVOU_Id" bigint,
    "FATVOU_CRDRFlg" VARCHAR,
    "FAMLED_LedgerName" VARCHAR,
    "FAMVOU_VoucherType" VARCHAR,
    "FAMVOU_VoucherNo" VARCHAR,
    "FAMVOU_VoucherDate" TIMESTAMP,
    "FATVOU_Amount" NUMERIC,
    "Credit" NUMERIC,
    "debit" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        SELECT 
            ROW_NUMBER() OVER (PARTITION BY "AB"."FAMVOU_Id" ORDER BY "AB"."FAMVOU_Id" DESC) AS "RowNumber",
            "AB"."FAMCOMP_Id",
            "AB"."FATVOU_Id",
            "AB"."FAMVOU_Id",
            "AB"."FATVOU_CRDRFlg",
            "AB"."FAMLED_LedgerName",
            "AB"."FAMVOU_VoucherType",
            "AB"."FAMVOU_VoucherNo",
            "AB"."FAMVOU_VoucherDate",
            "AB"."FATVOU_Amount",
            "AB"."Credit",
            "AB"."debit"
        FROM (
            SELECT 
                "A"."FAMCOMP_Id",
                "B"."FATVOU_Id",
                "A"."FAMVOU_Id",
                "B"."FATVOU_CRDRFlg",
                "C"."FAMLED_LedgerName",
                "A"."FAMVOU_VoucherType",
                "A"."FAMVOU_VoucherNo",
                "A"."FAMVOU_VoucherDate",
                "B"."FATVOU_Amount",
                "B"."FATVOU_Amount" as "Credit",
                0::NUMERIC as "debit"
            FROM "FA_M_Voucher" "A"
            INNER JOIN "FA_T_Voucher" "B" ON "A"."FAMVOU_Id" = "B"."FAMVOU_Id" AND "B"."FATVOU_CRDRFlg" = 'CR'
            INNER JOIN "FA_M_Ledger" "C" ON "C"."FAMLED_Id" = "B"."FAMLED_Id"
            
            UNION ALL
            
            SELECT 
                "A"."FAMCOMP_Id",
                "B"."FATVOU_Id",
                "A"."FAMVOU_Id",
                "B"."FATVOU_CRDRFlg",
                "C"."FAMLED_LedgerName",
                "A"."FAMVOU_VoucherType",
                "A"."FAMVOU_VoucherNo",
                "A"."FAMVOU_VoucherDate",
                "B"."FATVOU_Amount",
                0::NUMERIC as "Credit",
                "B"."FATVOU_Amount" as "debit"
            FROM "FA_M_Voucher" "A"
            INNER JOIN "FA_T_Voucher" "B" ON "A"."FAMVOU_Id" = "B"."FAMVOU_Id" AND "B"."FATVOU_CRDRFlg" = 'DR'
            INNER JOIN "FA_M_Ledger" "C" ON "C"."FAMLED_Id" = "B"."FAMLED_Id"
        ) as "AB"
        GROUP BY 
            "AB"."FAMCOMP_Id",
            "AB"."FATVOU_Id",
            "AB"."FAMVOU_Id",
            "AB"."FATVOU_CRDRFlg",
            "AB"."FAMLED_LedgerName",
            "AB"."FAMVOU_VoucherType",
            "AB"."FAMVOU_VoucherNo",
            "AB"."FAMVOU_VoucherDate",
            "AB"."FATVOU_Amount",
            "AB"."Credit",
            "AB"."debit"
    ) as "x"
    WHERE "x"."FAMVOU_Id" = p_FAMVOU_Id;
END;
$$;