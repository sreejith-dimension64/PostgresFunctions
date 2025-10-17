CREATE OR REPLACE FUNCTION "dbo"."FA_Closingbalance"(
    p_date VARCHAR(10),
    p_MI_Id BIGINT,
    p_FAMCOMP_Id BIGINT,
    p_IMFY_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_CloseBalCr FLOAT;
    v_CloseBalDr FLOAT;
    v_Fyr_id INT;
    v_l_code INT;
    v_OCr FLOAT;
    v_sdate VARCHAR(20);
    v_ODr FLOAT;
    v_Drbal FLOAT;
    v_Crbal FLOAT;
    Led_cursor CURSOR FOR
        SELECT "FAMLED_Id" FROM "FA_M_Ledger" 
        WHERE "IMFY_Id" <= p_IMFY_Id 
        AND "FAMCOMP_Id" = p_FAMCOMP_Id  
        AND "FAMGRP_Id" IN (
            SELECT "FAMGRP_Id" FROM "FA_Master_Group" 
            WHERE UPPER(SUBSTRING("FAMGRP_GroupCode", 3, 2)) = 'BS'
        );
    Opbal_CURSOR CURSOR FOR
        SELECT 
            COALESCE((CASE WHEN "FAMLEDD_OBCRDRFlg" = 'Dr' THEN "FAMLEDD_OpeningBalance" END), 0) AS OBDrAmount,
            COALESCE((CASE WHEN "FAMLEDD_OBCRDRFlg" = 'Cr' THEN "FAMLEDD_OpeningBalance" END), 0) AS OBCrAmount 
        FROM "FA_M_Ledger_Details" 
        WHERE "FAMLED_Id" = v_l_code 
        AND "IMFY_Id" = p_IMFY_Id;
    Drbal_CURSOR CURSOR FOR
        SELECT COALESCE(SUM("FATVOU_Amount"), 0)  
        FROM "FA_M_Voucher" a, "FA_T_Voucher" b 
        WHERE a."FAMVOU_Id" = b."FAMVOU_Id" 
        AND a."FAMVOU_VoucherDate"::DATE >= v_sdate::DATE 
        AND a."FAMVOU_VoucherDate"::DATE <= p_date::DATE 
        AND b."FAMLED_Id" = v_l_code 
        AND UPPER(b."FATVOU_CRDRFlg") = 'DR' 
        AND a."IMFY_Id" = p_IMFY_Id 
        AND a."FAMVOU_VoucherType" <> 'MemoVoucher';
    Crbal_CURSOR CURSOR FOR
        SELECT COALESCE(SUM("FATVOU_Amount"), 0)  
        FROM "FA_M_Voucher" a, "FA_T_Voucher" b 
        WHERE a."FAMVOU_Id" = b."FAMVOU_Id" 
        AND a."FAMVOU_VoucherDate"::DATE >= v_sdate::DATE 
        AND a."FAMVOU_VoucherDate"::DATE <= p_date::DATE 
        AND b."FAMLED_Id" = v_l_code 
        AND UPPER(b."FATVOU_CRDRFlg") = 'CR' 
        AND a."IMFY_Id" = p_IMFY_Id 
        AND a."FAMVOU_VoucherType" <> 'MemoVoucher';
BEGIN
    v_CloseBalCr := 0;
    v_CloseBalDr := 0;

    SELECT "dbo"."FA_FindFyr"(p_date, p_FAMCOMP_Id, p_IMFY_Id) INTO v_fyr_id;

    SELECT "IMFY_FromDate" INTO v_sdate
    FROM "FA_Company_FY_Mapping" FY
    INNER JOIN "IVRM_Master_FinancialYear" MF ON FY."IMFY_Id" = MF."IMFY_Id"  
    WHERE FY."MI_Id" = p_MI_Id 
    AND "FAMCOMP_Id" = p_FAMCOMP_Id 
    AND MF."IMFY_Id" = p_IMFY_Id;

    OPEN Led_cursor;
    LOOP
        FETCH Led_cursor INTO v_l_code;
        EXIT WHEN NOT FOUND;

        OPEN Opbal_Cursor;
        FETCH Opbal_CURSOR INTO v_ODr, v_OCr;

        IF v_OCr > 0 THEN
            v_CloseBalCr := v_OCr;
        END IF;
        IF v_ODr > 0 THEN
            v_CloseBalDr := v_ODr;
        END IF;

        CLOSE Opbal_CURSOR;

        OPEN Drbal_Cursor;
        FETCH Drbal_CURSOR INTO v_Drbal;

        v_CloseBalDr := v_CloseBalDr + v_Drbal;

        CLOSE Drbal_CURSOR;

        OPEN Crbal_Cursor;
        FETCH Crbal_CURSOR INTO v_Crbal;

        v_CloseBalCr := v_CloseBalCr + v_Crbal;
        CLOSE Crbal_CURSOR;

        IF v_l_code = 3 THEN
            RAISE NOTICE '%', v_closebaldr || 'cash';
        END IF;

        IF v_CloseBalDr > v_CloseBalCr THEN
            RAISE NOTICE 'DR';
            RAISE NOTICE '%', 'CR' || v_ClosebalCr || 'DR' || v_ClosebalDr;
            UPDATE "FA_M_Ledger_Details" 
            SET "FAMLEDD_ClosingBalance" = v_ClosebalDr - v_ClosebalCr 
            WHERE "FAMLED_Id" = v_l_code 
            AND "IMFY_Id" = v_fyr_id 
            AND "FAMLEDD_CBCRDRFlg" = 'Dr';
        END IF;
        IF v_CloseBalDr < v_CloseBalCr THEN
            RAISE NOTICE 'CR';
            RAISE NOTICE '%', '@l_code ' || (v_ClosebalCr - v_ClosebalDr)::VARCHAR;
            RAISE NOTICE '%', 'CR' || v_ClosebalCr || 'DR ' || v_ClosebalDr;
            UPDATE "FA_M_Ledger_Details" 
            SET "FAMLEDD_ClosingBalance" = v_ClosebalCr - v_ClosebalDr 
            WHERE "FAMLED_Id" = v_l_code 
            AND "IMFY_Id" = v_fyr_id 
            AND "FAMLEDD_CBCRDRFlg" = 'Cr';
        END IF;

        v_closebalcr := 0;
        v_closebaldr := 0;
    END LOOP;
    CLOSE led_CURSOR;

    v_CloseBalCr := 0;
    v_CloseBalDr := 0;

    FOR v_l_code IN
        SELECT "FAMLED_Id" FROM "FA_M_Ledger" 
        WHERE "IMFY_Id" <= p_IMFY_Id 
        AND "FAMCOMP_Id" = p_FAMCOMP_Id  
        AND "FAMGRP_Id" IN (
            SELECT "FAMGRP_Id" FROM "FA_Master_Group" 
            WHERE UPPER(SUBSTRING("FAMGRP_GroupCode", 3, 2)) = 'PL'
        )
    LOOP
        v_Drbal := 0;
        v_Crbal := 0;

        SELECT COALESCE(SUM("FATVOU_Amount"), 0) INTO v_Drbal
        FROM "FA_M_Voucher" a, "FA_T_Voucher" b 
        WHERE a."FAMVOU_Id" = b."FAMVOU_Id" 
        AND a."FAMVOU_VoucherDate"::DATE >= v_sdate::DATE 
        AND a."FAMVOU_VoucherDate"::DATE <= p_date::DATE 
        AND b."FAMLED_Id" = v_l_code 
        AND UPPER(b."FATVOU_CRDRFlg") = 'DR' 
        AND a."IMFY_Id" = p_IMFY_Id  
        AND a."FAMVOU_VoucherType" <> 'MemoVoucher';

        v_CloseBalDr := v_CloseBalDr + v_Drbal;

        SELECT COALESCE(SUM("FATVOU_Amount"), 0) INTO v_Crbal
        FROM "FA_M_Voucher" a, "FA_T_Voucher" b 
        WHERE a."FAMVOU_Id" = b."FAMVOU_Id" 
        AND a."FAMVOU_VoucherDate"::DATE >= v_sdate::DATE  
        AND a."FAMVOU_VoucherDate"::DATE <= p_date::DATE 
        AND b."FAMLED_Id" = v_l_code 
        AND UPPER(b."FATVOU_CRDRFlg") = 'CR' 
        AND a."IMFY_Id" = p_IMFY_Id  
        AND a."FAMVOU_VoucherType" <> 'MemoVoucher';

        v_CloseBalCr := v_CloseBalCr + v_Crbal;

        IF v_CloseBalDr > v_CloseBalCr THEN
            UPDATE "FA_M_Ledger_Details" 
            SET "FAMLEDD_ClosingBalance" = v_ClosebalDr - v_ClosebalCr 
            WHERE "FAMLED_Id" = v_l_code 
            AND "IMFY_Id" = v_fyr_id 
            AND "FAMLEDD_CBCRDRFlg" = 'Dr';
        END IF;
        IF v_CloseBalDr < v_CloseBalCr THEN
            UPDATE "FA_M_Ledger_Details" 
            SET "FAMLEDD_ClosingBalance" = v_ClosebalCr - v_ClosebalDr 
            WHERE "FAMLED_Id" = v_l_code 
            AND "IMFY_Id" = v_fyr_id 
            AND "FAMLEDD_CBCRDRFlg" = 'Cr';
        END IF;

        v_closebalcr := 0;
        v_closebaldr := 0;
    END LOOP;

    RETURN;
END;
$$;