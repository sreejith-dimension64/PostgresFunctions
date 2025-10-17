CREATE OR REPLACE FUNCTION "dbo"."FA_Exec"(
    "caseint" integer,
    "FAMVOU_Id" bigint,
    "IMFY_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    SET datestyle = 'DMY';

    IF "caseint" = 1 THEN
        INSERT INTO "tmpledger"
        SELECT 
            b."FAMVOU_Id",
            b."FAMVOU_VoucherDate",
            a."FAMLED_LedgerName",
            b."FAMVOU_VoucherType",
            b."FAMVOU_VoucherNo",
            b."FAMVOU_Narration",
            c."FATVOU_Amount",
            c."FATVOU_CRDRFlg",
            'F1'
        FROM "FA_M_Ledger" a, "FA_M_Voucher" b, "FA_T_Voucher" c
        WHERE b."FAMVOU_Id" = c."FAMVOU_Id" 
            AND a."FAMLED_Id" = c."FAMLED_Id" 
            AND c."FATVOU_CRDRFlg" = 'CR' 
            AND c."FAMVOU_Id" = "FAMVOU_Id";
    END IF;

    IF "caseint" = 2 THEN
        INSERT INTO "tmpledger"
        SELECT 
            b."FAMVOU_Id",
            b."FAMVOU_VoucherDate",
            a."FAMLED_LedgerName",
            b."FAMVOU_VoucherType",
            b."FAMVOU_VoucherNo",
            b."FAMVOU_Narration",
            c."FATVOU_Amount",
            c."FATVOU_CRDRFlg",
            'F2'
        FROM "FA_M_Ledger" a, "FA_M_Voucher" b, "FA_T_Voucher" c
        WHERE b."FAMVOU_Id" = c."FAMVOU_Id" 
            AND a."FAMLED_Id" = c."FAMLED_Id" 
            AND c."FATVOU_CRDRFlg" = 'CR' 
            AND c."FAMVOU_Id" = "FAMVOU_Id";
    END IF;

    IF "caseint" = 12 THEN
        INSERT INTO "tmpledger"
        SELECT 
            b."FAMVOU_Id",
            b."FAMVOU_VoucherDate",
            a."FAMLED_LedgerName",
            b."FAMVOU_VoucherType",
            b."FAMVOU_VoucherNo",
            b."FAMVOU_Narration",
            c."FATVOU_Amount",
            c."FATVOU_CRDRFlg",
            'F2'
        FROM "FA_M_Ledger" a, "FA_M_Voucher" b, "FA_T_Voucher" c
        WHERE b."FAMVOU_Id" = c."FAMVOU_Id" 
            AND a."FAMLED_Id" = c."FAMLED_Id" 
            AND c."FATVOU_CRDRFlg" = 'DR' 
            AND c."FAMVOU_Id" = "FAMVOU_Id";
    END IF;

    IF "caseint" = 11 THEN
        INSERT INTO "tmpledger"
        SELECT 
            b."FAMVOU_Id",
            b."FAMVOU_VoucherDate",
            a."FAMLED_LedgerName",
            b."FAMVOU_VoucherType",
            b."FAMVOU_VoucherNo",
            b."FAMVOU_Narration",
            c."FATVOU_Amount",
            c."FATVOU_CRDRFlg",
            'F1'
        FROM "FA_M_Ledger" a, "FA_M_Voucher" b, "FA_T_Voucher" c
        WHERE b."FAMVOU_Id" = c."FAMVOU_Id" 
            AND a."FAMLED_Id" = c."FAMLED_Id" 
            AND c."FATVOU_CRDRFlg" = 'DR' 
            AND c."FAMVOU_Id" = "FAMVOU_Id";
    END IF;

    RETURN;
END;
$$;