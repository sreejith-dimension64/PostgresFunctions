CREATE OR REPLACE FUNCTION "Fa_Ledgerwisedaybook"(
    p_FAMLED_Id bigint,
    p_Monthid bigint
)
RETURNS TABLE(
    "RowNumber" bigint,
    "FAMLED_Id" bigint,
    "FAMCOMP_Id" bigint,
    "FATVOU_Id" bigint,
    "FAMVOU_Id" bigint,
    "FATVOU_CRDRFlg" varchar,
    "FAMLED_LedgerName" varchar,
    "FAMVOU_VoucherType" varchar,
    "FAMVOU_VoucherNo" varchar,
    "FAMVOU_VoucherDate" timestamp,
    "FATVOU_Amount" numeric,
    "Credit" numeric,
    "debit" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        SELECT 
            ROW_NUMBER() OVER (PARTITION BY "FAMVOU_Id" ORDER BY "FAMVOU_Id" DESC) AS "RowNumber",
            "AB".*
        FROM (
            SELECT 
                "C"."FAMLED_Id",
                "A"."FAMCOMP_Id",
                "B"."FATVOU_Id",
                "A"."FAMVOU_Id",
                "FATVOU_CRDRFlg",
                "FAMLED_LedgerName",
                "FAMVOU_VoucherType",
                "FAMVOU_VoucherNo",
                "FAMVOU_VoucherDate",
                "FATVOU_Amount",
                "FATVOU_Amount" as "Credit",
                0::numeric as "debit"
            FROM "FA_M_Voucher" "A"
            INNER JOIN "FA_T_Voucher" "B" ON "A"."FAMVOU_Id" = "B"."FAMVOU_Id" AND "FATVOU_CRDRFlg" = 'CR'
            INNER JOIN "FA_M_Ledger" "C" ON "C"."FAMLED_Id" = "B"."FAMLED_Id"
            
            UNION ALL
            
            SELECT 
                "C"."FAMLED_Id",
                "A"."FAMCOMP_Id",
                "B"."FATVOU_Id",
                "A"."FAMVOU_Id",
                "FATVOU_CRDRFlg",
                "FAMLED_LedgerName",
                "FAMVOU_VoucherType",
                "FAMVOU_VoucherNo",
                "FAMVOU_VoucherDate",
                "FATVOU_Amount",
                0::numeric as "Credit",
                "FATVOU_Amount" as "debit"
            FROM "FA_M_Voucher" "A"
            INNER JOIN "FA_T_Voucher" "B" ON "A"."FAMVOU_Id" = "B"."FAMVOU_Id" AND "FATVOU_CRDRFlg" = 'DR'
            INNER JOIN "FA_M_Ledger" "C" ON "C"."FAMLED_Id" = "B"."FAMLED_Id"
        ) as "AB"
        GROUP BY "FAMLED_Id", "FAMCOMP_Id", "FATVOU_Id", "FAMVOU_Id", "FATVOU_CRDRFlg", "FAMLED_LedgerName", 
                 "FAMVOU_VoucherType", "FAMVOU_VoucherNo", "FAMVOU_VoucherDate", "FATVOU_Amount", "Credit", "debit"
    ) as x
    WHERE x."FAMLED_Id" = p_FAMLED_Id 
    AND EXTRACT(MONTH FROM x."FAMVOU_VoucherDate") = p_Monthid;
END;
$$;