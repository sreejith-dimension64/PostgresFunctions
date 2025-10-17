CREATE OR REPLACE FUNCTION FinancialAccountingReport(
    p_FAMCOMP_Id bigint,
    p_Fromdate timestamp,
    p_Todate timestamp,
    p_type text
)
RETURNS TABLE (
    "FAMCOMP_Id" bigint,
    "FAMGRP_GroupName" varchar,
    "FAMLED_LedgerName" varchar,
    "FAMLED_Id" bigint,
    "FAMGRP_Id" bigint,
    "debit" numeric,
    "credit" numeric,
    "FATVOU_Id" bigint,
    "FAMVOU_Id" bigint,
    "FAMVOU_VoucherType" varchar,
    "FAMVOU_VoucherNo" varchar,
    "FAMVOU_VoucherDate" timestamp,
    "FATVOU_Amount" numeric,
    "Credit" numeric,
    "RowNumber" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_type = 'Day Book') THEN
        RETURN QUERY
        SELECT 
            x."FAMCOMP_Id",
            NULL::varchar AS "FAMGRP_GroupName",
            x."FAMLED_LedgerName",
            NULL::bigint AS "FAMLED_Id",
            NULL::bigint AS "FAMGRP_Id",
            x."debit",
            x."Credit",
            x."FATVOU_Id",
            x."FAMVOU_Id",
            x."FAMVOU_VoucherType",
            x."FAMVOU_VoucherNo",
            x."FAMVOU_VoucherDate",
            x."FATVOU_Amount",
            x."Credit",
            x."RowNumber"
        FROM (
            SELECT 
                ROW_NUMBER() OVER (PARTITION BY "FAMVOU_Id" ORDER BY "FAMVOU_Id" DESC) AS "RowNumber",
                AB.*
            FROM (
                SELECT  
                    A."FAMCOMP_Id",
                    B."FATVOU_Id",
                    A."FAMVOU_Id",
                    A."FAMVOU_VoucherType",
                    A."FAMVOU_VoucherNo",
                    A."FAMVOU_VoucherDate",
                    B."FATVOU_Amount",
                    B."FATVOU_Amount" as "Credit",
                    0 as "debit",
                    C."FAMLED_LedgerName"
                FROM "FA_M_Voucher" A
                INNER JOIN "FA_T_Voucher" B ON A."FAMVOU_Id" = B."FAMVOU_Id" AND B."FATVOU_CRDRFlg" = 'CR'
                INNER JOIN "FA_M_Ledger" C ON C."FAMLED_Id" = B."FAMLED_Id"
                
                UNION ALL
                
                SELECT  
                    A."FAMCOMP_Id",
                    B."FATVOU_Id",
                    A."FAMVOU_Id",
                    A."FAMVOU_VoucherType",
                    A."FAMVOU_VoucherNo",
                    A."FAMVOU_VoucherDate",
                    B."FATVOU_Amount",
                    0 as "Credit",
                    B."FATVOU_Amount" as "debit",
                    C."FAMLED_LedgerName"
                FROM "FA_M_Voucher" A
                INNER JOIN "FA_T_Voucher" B ON A."FAMVOU_Id" = B."FAMVOU_Id" AND B."FATVOU_CRDRFlg" = 'DR'
                INNER JOIN "FA_M_Ledger" C ON C."FAMLED_Id" = B."FAMLED_Id"
            ) as AB
        ) as x
        WHERE x."RowNumber" = 1 
            AND x."FAMCOMP_Id" = p_FAMCOMP_Id 
            AND x."FAMVOU_VoucherDate"::date BETWEEN p_Fromdate::date AND p_Todate::date;
            
    END IF;

    IF (p_type = 'Bank/Cash Book') THEN
        RETURN QUERY
        SELECT  
            A."FAMCOMP_Id",
            D."FAMGRP_GroupName",
            A."FAMLED_LedgerName",
            A."FAMLED_Id",
            D."FAMGRP_Id",
            COALESCE((SELECT SUM(COALESCE("FATVOU_Amount", 0)) FROM "FA_T_Voucher" WHERE "FATVOU_CRDRFlg" = 'CR' AND "FAMLED_Id" = A."FAMLED_Id"), 0) as "debit",
            COALESCE((SELECT SUM(COALESCE("FATVOU_Amount", 0)) FROM "FA_T_Voucher" WHERE "FATVOU_CRDRFlg" = 'DR' AND "FAMLED_Id" = A."FAMLED_Id"), 0) as "credit",
            NULL::bigint AS "FATVOU_Id",
            NULL::bigint AS "FAMVOU_Id",
            NULL::varchar AS "FAMVOU_VoucherType",
            NULL::varchar AS "FAMVOU_VoucherNo",
            NULL::timestamp AS "FAMVOU_VoucherDate",
            NULL::numeric AS "FATVOU_Amount",
            NULL::numeric AS "Credit",
            NULL::bigint AS "RowNumber"
        FROM "FA_M_Ledger" A
        INNER JOIN "FA_Master_Group" D ON A."FAMGRP_Id" = D."FAMGRP_Id"
        WHERE D."FAMGRP_GroupName" LIKE '%Advances Received%'
        
        UNION ALL
        
        SELECT  
            A."FAMCOMP_Id",
            D."FAMGRP_GroupName",
            A."FAMLED_LedgerName",
            A."FAMLED_Id",
            D."FAMGRP_Id",
            COALESCE((SELECT SUM(COALESCE("FATVOU_Amount", 0)) FROM "FA_T_Voucher" WHERE "FATVOU_CRDRFlg" = 'CR' AND "FAMLED_Id" = A."FAMLED_Id"), 0) as "debit",
            COALESCE((SELECT SUM(COALESCE("FATVOU_Amount", 0)) FROM "FA_T_Voucher" WHERE "FATVOU_CRDRFlg" = 'DR' AND "FAMLED_Id" = A."FAMLED_Id"), 0) as "credit",
            NULL::bigint AS "FATVOU_Id",
            NULL::bigint AS "FAMVOU_Id",
            NULL::varchar AS "FAMVOU_VoucherType",
            NULL::varchar AS "FAMVOU_VoucherNo",
            NULL::timestamp AS "FAMVOU_VoucherDate",
            NULL::numeric AS "FATVOU_Amount",
            NULL::numeric AS "Credit",
            NULL::bigint AS "RowNumber"
        FROM "FA_M_Ledger" A
        INNER JOIN "FA_Master_Group" D ON A."FAMGRP_Id" = D."FAMGRP_Id"
        WHERE D."FAMGRP_GroupName" LIKE '%Loans (Liability)%';
        
    END IF;

    RETURN;
END;
$$;