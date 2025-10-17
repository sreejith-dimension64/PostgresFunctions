CREATE OR REPLACE FUNCTION "dbo"."FA_RecPay"(
    p_MI_Id bigint,
    p_IMFY_Id bigint,
    p_FAMCOMP_Id bigint,
    p_sdate varchar(10),
    p_edate varchar(10)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_l_code bigint;
    v_lname varchar(100);
    v_intTranDR double precision;
    v_intTranCr double precision;
    v_intOpenBalDR double precision;
    v_intOpenBalCR double precision;
    rec_led RECORD;
BEGIN
    DROP TABLE IF EXISTS "dbo"."tmpRecPay";

    CREATE TABLE "dbo"."tmpRecPay" (
        "l_code" bigint, 
        "LedgerName" varchar(100),
        "DRtranAmt" double precision,
        "CrtranAmt" double precision,
        "Flg" varchar(10)
    );

    FOR rec_led IN
        SELECT DISTINCT "FML"."FAMLED_Id", "FML"."FAMLED_LedgerName" 
        FROM "dbo"."FA_M_Ledger" "FML"
        INNER JOIN "dbo"."FA_T_Voucher" "FTV" ON "FML"."FAMLED_Id" = "FTV"."FAMLED_Id"  
        INNER JOIN "dbo"."FA_M_Voucher" "FMV" ON "FMV"."FAMVOU_Id" = "FMV"."FAMVOU_Id" 
        INNER JOIN "dbo"."FA_Master_Group" "FMG" ON "FMG"."FAMGRP_Id" = "FML"."FAMGRP_Id"
        WHERE ("FMG"."FAMGRP_GroupCode" <> 15) 
            AND ("FMG"."FAMGRP_GroupCode" <> 14) 
            AND ("FMG"."FAMGRP_GroupCode" <> 10) 
            AND ("FML"."FAMCOMP_Id" = p_FAMCOMP_Id) 
            AND ("FML"."IMFY_Id" <= p_IMFY_Id) 
            AND ("FMV"."FAMVOU_VoucherType" <> 'JournalVoucher') 
            AND ("FMV"."FAMVOU_VoucherType" <> 'Journal Voucher') 
        ORDER BY "FML"."FAMLED_LedgerName"
    LOOP
        v_l_code := rec_led."FAMLED_Id";
        v_lname := rec_led."FAMLED_LedgerName";

        SELECT COALESCE(sum("FA_T_Voucher"."FATVOU_Amount"), 0) INTO v_intTranDR
        FROM "dbo"."FA_T_Voucher", "dbo"."FA_M_Voucher" 
        WHERE "FA_T_Voucher"."FAMLED_Id" = v_l_code 
            AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN TO_DATE(p_sdate, 'DD/MM/YYYY') AND TO_DATE(p_edate, 'DD/MM/YYYY')
            AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
            AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
            AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'CR' 
            AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher' 
            AND ("FA_M_Voucher"."FAMVOU_VoucherType" <> 'Journal Voucher' OR "FA_M_Voucher"."FAMVOU_VoucherType" <> 'JournalVoucher');

        SELECT COALESCE(sum("FA_T_Voucher"."FATVOU_Amount"), 0) INTO v_intTranCR
        FROM "dbo"."FA_T_Voucher", "dbo"."FA_M_Voucher" 
        WHERE "FA_T_Voucher"."FAMLED_Id" = v_l_code 
            AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN TO_DATE(p_sdate, 'DD/MM/YYYY') AND TO_DATE(p_edate, 'DD/MM/YYYY')
            AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
            AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
            AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'DR' 
            AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher' 
            AND ("FA_M_Voucher"."FAMVOU_VoucherType" <> 'Journal Voucher' OR "FA_M_Voucher"."FAMVOU_VoucherType" <> 'JournalVoucher');

        IF v_intTranDr <> 0 OR v_intTranCr <> 0 THEN
            INSERT INTO "dbo"."tmpRecPay" VALUES (v_l_code, v_lname, v_intTranDr, v_intTranCr, 'NonBank');
        END IF;
    END LOOP;

    FOR rec_led IN
        SELECT "FAMLED_Id", "FAMLED_LedgerName" 
        FROM "dbo"."FA_M_Ledger" "FML"
        INNER JOIN "dbo"."FA_Master_Group" "FMG" ON "FML"."FAMGRP_Id" = "FMG"."FAMGRP_Id"   
        WHERE ("FAMGRP_GroupCode" = 15 OR "FAMGRP_GroupCode" = 14 OR "FAMGRP_GroupCode" = 10)  
            AND "FAMCOMP_Id" = p_FAMCOMP_Id 
            AND "IMFY_Id" <= p_IMFY_Id 
        ORDER BY "FAMLED_LedgerName"
    LOOP
        v_l_code := rec_led."FAMLED_Id";
        v_lname := rec_led."FAMLED_LedgerName";
        
        v_intOpenBalDR := 0;
        v_intOpenBalCR := 0;
        
        SELECT * INTO v_intOpenBalCR, v_intOpenBalDR 
        FROM "dbo"."FA_OpeningbalanceSingLeAcc"(v_l_code, p_FAMCOMP_Id, p_sdate);

        RAISE NOTICE 'Cr--: %', v_intOpenBalCR;
        RAISE NOTICE 'dr--: %', v_intOpenBalDR;

        SELECT COALESCE(sum("FA_T_Voucher"."FATVOU_Amount"), 0) INTO v_intTranDR
        FROM "dbo"."FA_M_Voucher", "dbo"."FA_T_Voucher" 
        WHERE "FA_T_Voucher"."FAMLED_Id" = v_l_code 
            AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN TO_DATE(p_sdate, 'DD/MM/YYYY') AND TO_DATE(p_edate, 'DD/MM/YYYY')
            AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
            AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'DR' 
            AND "FA_M_Voucher"."FAMVOU_Id" = "FA_T_Voucher"."FAMVOU_Id" 
            AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher' 
            AND ("FA_M_Voucher"."FAMVOU_VoucherType" <> 'Journal Voucher' OR "FA_M_Voucher"."FAMVOU_VoucherType" <> 'JournalVoucher');

        SELECT COALESCE(sum("FA_T_Voucher"."FATVOU_Amount"), 0) INTO v_intTranCR
        FROM "dbo"."FA_M_Voucher", "dbo"."FA_T_Voucher" 
        WHERE "FA_T_Voucher"."FAMLED_Id" = v_l_code 
            AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN TO_DATE(p_sdate, 'DD/MM/YYYY') AND TO_DATE(p_edate, 'DD/MM/YYYY')
            AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
            AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'CR' 
            AND "FA_M_Voucher"."FAMVOU_Id" = "FA_T_Voucher"."FAMVOU_Id" 
            AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher' 
            AND ("FA_M_Voucher"."FAMVOU_VoucherType" <> 'Journal Voucher' OR "FA_M_Voucher"."FAMVOU_VoucherType" <> 'JournalVoucher');

        INSERT INTO "dbo"."tmpRecPay" VALUES (v_l_code, v_lname, v_intOpenBalDR - v_intOpenBalCR, v_intOpenBalDR - v_intOpenBalCR + v_intTranDR - v_intTranCR, 'Bank');
    END LOOP;

    RETURN;
END;
$$;