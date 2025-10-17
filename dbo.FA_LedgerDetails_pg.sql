CREATE OR REPLACE FUNCTION "FA_LedgerDetails"(
    "@FAMGRP_Id" bigint,
    "@IMFY_Id" bigint,
    "@Fromdate" timestamp,
    "@Todate" timestamp
)
RETURNS TABLE(
    "FAMGRP_Id" bigint,
    "FAMLED_Id" bigint,
    "FAMLED_LedgerName" text,
    "FATVOU_CRDRFlg" text,
    "Debit" numeric,
    "Credit" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n."FAMGRP_Id",
        m."FAMLED_Id",
        n."FAMLED_LedgerName",
        m."FATVOU_CRDRFlg",
        (SELECT sum(a."FATVOU_Amount") 
         FROM "FA_T_Voucher" a
         INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"
         WHERE a."FATVOU_CRDRFlg" = 'CR' AND a."FATVOU_Id" = m."FATVOU_Id") AS "Debit",
        (SELECT sum(a."FATVOU_Amount")
         FROM "FA_T_Voucher" a
         INNER JOIN "FA_M_Ledger" b ON a."FAMLED_Id" = b."FAMLED_Id"
         WHERE a."FATVOU_CRDRFlg" = 'DR' AND a."FATVOU_Id" = m."FATVOU_Id") AS "Credit"
    FROM "FA_T_Voucher" m
    INNER JOIN "FA_M_Ledger" n ON m."FAMLED_Id" = n."FAMLED_Id"
    INNER JOIN "FA_M_Voucher" o ON m."FAMVOU_Id" = o."FAMVOU_Id"
    WHERE n."FAMGRP_Id" = "@FAMGRP_Id" 
      AND o."IMFY_Id" = "@IMFY_Id" 
      AND CAST(o."FAMVOU_VoucherDate" AS date) BETWEEN CAST("@Fromdate" AS date) AND CAST("@Todate" AS date)
    GROUP BY m."FATVOU_Id", n."FAMGRP_Id", m."FAMLED_Id", n."FAMLED_LedgerName", m."FATVOU_CRDRFlg", m."FATVOU_Amount";
END;
$$;