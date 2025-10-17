CREATE OR REPLACE FUNCTION "dbo"."FA_ClosingbalanceSingLeAcc" (
    p_FAMLED_Id bigint,
    p_IMFY_Id bigint,
    p_MI_Id bigint,
    p_FAMCOMP_Id bigint,
    p_date date
) 
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_CloseBalCr double precision;
    v_CloseBalDr double precision;
    v_fyr_id bigint;
    v_l_code bigint;
    v_OCr double precision;
    v_ODr double precision;
    v_AOBR_C_CR double precision;
    v_AOBR_C_DR double precision;
    v_opt int;
    v_OBCR double precision;
    v_OBDR double precision;
    v_Drbal double precision;
    v_Crbal double precision;
    v_FAMLED_Id bigint;
    v_row_count int;
    v_table_exists int;
BEGIN
    v_CloseBalCr := 0;
    v_CloseBalDR := 0;
    v_AOBR_C_CR := 0;
    v_AOBR_C_DR := 0;
    v_OBCR := 0;
    v_OBDR := 0;
    v_opt := 1;

    SELECT "FA_FindFyr"(p_date, p_MI_Id, p_IMFY_Id) INTO v_fyr_id;

    FOR v_FAMLED_Id IN 
        SELECT DISTINCT "FAMLED_Id" 
        FROM "FA_M_Ledger" 
        WHERE "IMFY_Id" <= p_IMFY_Id 
            AND "MI_Id" = p_MI_Id 
            AND "FAMLED_Id" = p_FAMLED_Id 
            AND "FAMCOMP_Id" = p_FAMCOMP_Id 
            AND "FAMGRP_Id" IN (
                SELECT DISTINCT "FAMGRP_Id" 
                FROM "FA_Master_Group" 
                WHERE upper(substring("FAMGRP_GroupCode", 3, 2)) = 'BS'
            )
    LOOP
        FOR v_ODr, v_OCr IN
            SELECT 
                COALESCE((CASE WHEN "FAMLEDD_OBCRDRFlg" = 'Dr' THEN "FAMLEDD_OpeningBalance" END), 0) AS OBDrAmount,
                COALESCE((CASE WHEN "FAMLEDD_OBCRDRFlg" = 'Cr' THEN "FAMLEDD_OpeningBalance" END), 0) AS OBCrAmount 
            FROM "FA_M_Ledger_Details" 
            WHERE "FAMLEDD_OBCRDRFlg" = 'Cr' 
                AND "FAMLED_Id" = v_FAMLED_Id 
                AND "IMFY_Id" = p_IMFY_Id
        LOOP
            IF v_OCr > 0 THEN
                v_CloseBalCr := v_OCr;
            END IF;
            IF v_ODr > 0 THEN
                v_CloseBalDr := v_ODr;
            END IF;
            RAISE NOTICE 'DR %', v_CloseBalDr;
        END LOOP;

        RAISE NOTICE 'FYR %', v_FYR_ID;
        RAISE NOTICE 'LCODE-FAMLED_Id : %', v_L_CODE;

        SELECT COALESCE(sum("FATVOU_Amount"), 0) INTO v_Drbal
        FROM "FA_M_Voucher" a, "FA_T_Voucher" b 
        WHERE a."FAMVOU_Id" = b."FAMVOU_Id" 
            AND CAST(a."FAMVOU_VoucherDate" AS date) <= p_date 
            AND b."FAMLED_Id" = v_FAMLED_Id 
            AND upper(b."FATVOU_CRDRFlg") = 'DR' 
            AND a."IMFY_Id" = p_IMFY_Id 
            AND a."FAMVOU_VoucherType" <> 'MemoVoucher';

        v_CloseBalDr := v_CloseBalDr + v_Drbal;
        RAISE NOTICE 'DR %', v_CloseBalDr;

        SELECT COALESCE(sum("FATVOU_Amount"), 0) INTO v_Crbal
        FROM "FA_M_Voucher" a, "FA_T_Voucher" b 
        WHERE a."FAMVOU_Id" = b."FAMVOU_Id" 
            AND CAST(a."FAMVOU_VoucherDate" AS date) <= p_date 
            AND b."FAMLED_Id" = v_FAMLED_Id 
            AND upper(b."FATVOU_CRDRFlg") = 'CR' 
            AND a."IMFY_Id" = p_IMFY_Id 
            AND a."FAMVOU_VoucherType" <> 'MemoVoucher';

        v_CloseBalCr := v_CloseBalCr + v_Crbal;

        SELECT COUNT(*) INTO v_table_exists
        FROM pg_tables 
        WHERE tablename = 'FA_OB_Record_Temp';

        IF v_table_exists > 0 THEN
            SELECT "FAOBRT_CCR", "FAOBRT_CDR" INTO v_AOBR_C_CR, v_AOBR_C_DR
            FROM "FA_OB_Record_Temp" 
            WHERE "IMFY_Id" = p_IMFY_Id 
                AND "MI_Id" = p_MI_Id 
                AND "FAMLED_Id" = v_FAMLED_Id;
            
            GET DIAGNOSTICS v_row_count = ROW_COUNT;
            
            IF v_row_count > 0 THEN
                RAISE NOTICE 'CDR %', v_AOBR_C_DR;
                RAISE NOTICE 'CCR %', v_AOBR_C_CR;

                IF v_AOBR_C_CR = v_CloseBalCr AND v_AOBR_C_DR = v_CloseBalDr THEN
                    SELECT "FAOBRT_OCR", "FAOBRT_ODR" INTO v_OBCR, v_OBDR
                    FROM "FA_OB_Record_Temp" 
                    WHERE "FAMLED_Id" = v_FAMLED_Id 
                        AND "IMFY_Id" = p_IMFY_Id;
                    
                    GET DIAGNOSTICS v_row_count = ROW_COUNT;
                    
                    IF v_row_count > 0 THEN
                        v_AOBR_C_CR := v_AOBR_C_CR + v_OBCR;
                        v_AOBR_C_DR := v_AOBR_C_DR + v_OBDR;
                    END IF;
                    
                    UPDATE "FA_M_Ledger_Details" 
                    SET "FAMLEDD_OpeningBalance" = v_AOBR_C_CR - v_CloseBalCr 
                    WHERE "FAMLED_Id" = v_FAMLED_Id 
                        AND "IMFY_Id" = p_IMFY_Id 
                        AND "FAMLEDD_CBCRDRFlg" = 'CR';
                    
                    UPDATE "FA_M_Ledger_Details" 
                    SET "FAMLEDD_OpeningBalance" = v_AOBR_C_DR - v_CloseBalDr 
                    WHERE "FAMLED_Id" = v_FAMLED_Id 
                        AND "IMFY_Id" = p_IMFY_Id 
                        AND "FAMLEDD_CBCRDRFlg" = 'DR';
                    
                    v_opt := 0;
                ELSE
                    IF v_AOBR_C_CR <> v_CloseBalCr THEN
                        SELECT "FAOBRT_OCR" INTO v_OBCR
                        FROM "FA_OB_Record_Temp" 
                        WHERE "FAMLED_Id" = v_FAMLED_Id 
                            AND "IMFY_Id" = p_IMFY_Id;
                        
                        v_AOBR_C_CR := v_AOBR_C_CR + v_OBCR;

                        IF v_AOBR_C_CR > v_CloseBalCr THEN
                            UPDATE "FA_M_Ledger_Details" 
                            SET "FAMLEDD_OpeningBalance" = v_AOBR_C_CR - v_CloseBalCr
                            WHERE "FAMLED_Id" = v_FAMLED_Id 
                                AND "IMFY_Id" = p_IMFY_Id 
                                AND "FAMLEDD_CBCRDRFlg" = 'CR';
                        ELSE
                            UPDATE "FA_M_Ledger_Details" 
                            SET "FAMLEDD_OpeningBalance" = v_CloseBalCr - v_AOBR_C_CR
                            WHERE "FAMLED_Id" = v_FAMLED_Id 
                                AND "IMFY_Id" = p_IMFY_Id 
                                AND "FAMLEDD_CBCRDRFlg" = 'DR';
                        END IF;
                    END IF;
                    
                    IF v_AOBR_C_DR <> v_CloseBalDr THEN
                        SELECT "FAOBRT_ODR" INTO v_OBDR
                        FROM "FA_OB_Record_Temp" 
                        WHERE "FAMLED_Id" = v_FAMLED_Id 
                            AND "IMFY_Id" = p_IMFY_Id;
                        
                        v_AOBR_C_DR := v_AOBR_C_DR + v_OBDR;
                        
                        IF v_AOBR_C_DR > v_CloseBalDr THEN
                            UPDATE "FA_M_Ledger_Details" 
                            SET "FAMLEDD_OpeningBalance" = v_AOBR_C_DR - v_CloseBalDr
                            WHERE "FAMLED_Id" = v_FAMLED_Id 
                                AND "IMFY_Id" = p_IMFY_Id 
                                AND "FAMLEDD_CBCRDRFlg" = 'CR';
                        ELSE
                            UPDATE "FA_M_Ledger_Details" 
                            SET "FAMLEDD_OpeningBalance" = v_CloseBalDr - v_AOBR_C_DR
                            WHERE "FAMLED_Id" = v_FAMLED_Id 
                                AND "IMFY_Id" = p_IMFY_Id 
                                AND "FAMLEDD_CBCRDRFlg" = 'DR';
                        END IF;
                    END IF;
                    
                    v_opt := 0;
                END IF;
            END IF;
        END IF;

        IF v_opt = 1 THEN
            IF v_CloseBalDr > v_CloseBalCr THEN
                UPDATE "FA_M_Ledger_Details" 
                SET "FAMLEDD_OpeningBalance" = v_ClosebalDr - v_ClosebalCr,
                    "FAMLEDD_OBCRDRFlg" = 'Dr'
                WHERE "FAMLED_Id" = v_FAMLED_Id 
                    AND "IMFY_Id" = p_IMFY_Id;
                
                GET DIAGNOSTICS v_row_count = ROW_COUNT;
                
                IF v_row_count = 0 THEN
                    INSERT INTO "FA_M_Ledger_Details"("FAMLED_Id", "FAMLEDD_OpeningBalance", "FAMLEDD_OBCRDRFlg", "IMFY_Id", "FAMLEDD_OBDate") 
                    VALUES(v_FAMLED_Id, v_ClosebalDr - v_ClosebalCr, 'Dr', p_IMFY_Id, p_date + INTERVAL '1 day');
                END IF;
            END IF;
            
            IF v_CloseBalDr < v_CloseBalCr THEN
                UPDATE "FA_M_Ledger_Details" 
                SET "FAMLEDD_OpeningBalance" = v_ClosebalCr - v_ClosebalDr,
                    "FAMLEDD_OBCRDRFlg" = 'Cr'
                WHERE "FAMLED_Id" = v_FAMLED_Id 
                    AND "IMFY_Id" = p_IMFY_Id;
                
                GET DIAGNOSTICS v_row_count = ROW_COUNT;
                
                IF v_row_count = 0 THEN
                    INSERT INTO "FA_M_Ledger_Details"("FAMLED_Id", "FAMLEDD_OpeningBalance", "FAMLEDD_OBCRDRFlg", "IMFY_Id", "FAMLEDD_OBDate") 
                    VALUES(v_FAMLED_Id, v_ClosebalCr - v_ClosebalDr, 'Cr', p_IMFY_Id, p_date + INTERVAL '1 day');
                END IF;
            END IF;
        END IF;
        
        v_closebalcr := 0;
        v_closebaldr := 0;
    END LOOP;

    v_l_code := 0;
    
    FOR v_l_code IN 
        SELECT "FAMLED_Id" 
        FROM "FA_M_Ledger" 
        WHERE "MI_Id" = p_MI_Id 
            AND "IMFY_Id" <= p_IMFY_Id 
            AND "FAMCOMP_Id" = p_FAMCOMP_Id 
            AND "IMFY_Id" = p_IMFY_Id 
            AND "FAMLED_Id" IN (
                SELECT "FAMLED_Id" 
                FROM "FA_Master_Group" 
                WHERE upper(substring("FAMGRP_GroupCode", 3, 2)) = 'PL'
            )
    LOOP
        UPDATE "FA_M_Ledger_Details" 
        SET "FAMLEDD_OpeningBalance" = 0 
        WHERE "IMFY_Id" = p_IMFY_Id 
            AND "FAMLED_Id" = v_l_code;
        
        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        
        IF v_row_count = 0 THEN
            INSERT INTO "FA_M_Ledger_Details" ("FAMLED_Id", "FAMLEDD_OpeningBalance", "IMFY_Id", "FAMLEDD_OBDate") 
            VALUES(v_l_code, 0, p_IMFY_Id, p_date + INTERVAL '1 day');
        END IF;
    END LOOP;

    RETURN;
END;
$$;