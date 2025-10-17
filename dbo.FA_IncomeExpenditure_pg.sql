CREATE OR REPLACE FUNCTION "dbo"."FA_IncomeExpenditure"(
    p_IMFY_Id bigint,
    p_MI_Id bigint,
    p_FAMCOMP_Id bigint,
    p_sdate varchar(10),
    p_edate varchar(10)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_mg_code varchar(10);
    v_mg_Name varchar(100);
    v_mg_type varchar(10);
    v_FAMGRP_Id bigint;
    v_L_Code bigint;
    v_L_Name varchar(100);
    v_IntTranCr FLOAT;
    v_IntTranDr FLOAT;
    rec_MainGroup RECORD;
    rec_LedGroup RECORD;
BEGIN
    DROP TABLE IF EXISTS "dbo"."tmpIncExp";
    
    CREATE TABLE "dbo"."tmpIncExp" (
        "mg_Code" varchar(10),
        "mg_Name" varchar(100),
        "mg_type" varchar(10),
        "l_code" bigint,
        "L_Name" varchar(100),
        "Amt" float
    );

    FOR rec_MainGroup IN 
        SELECT "FAMGRP_Id", "FAMGRP_GroupCode", "FAMGRP_GroupName", "FAMGRP_BSPLFlg" 
        FROM "FA_Master_Group" 
        WHERE "FAMGRP_BSPLFlg" = 'PL' AND "MI_Id" = p_MI_Id 
        ORDER BY "FAMGRP_GroupCode"
    LOOP
        v_FAMGRP_Id := rec_MainGroup."FAMGRP_Id";
        v_MG_Code := rec_MainGroup."FAMGRP_GroupCode";
        v_MG_Name := rec_MainGroup."FAMGRP_GroupName";
        v_MG_Type := rec_MainGroup."FAMGRP_BSPLFlg";
        
        FOR rec_LedGroup IN 
            SELECT "FAMLED_Id", "FAMLED_LedgerName" 
            FROM "FA_M_Ledger" 
            WHERE "FAMGRP_Id" = v_FAMGRP_Id 
                AND "FAMCOMP_Id" = p_FAMCOMP_Id 
                AND "IMFY_Id" <= p_IMFY_Id
        LOOP
            v_L_Code := rec_LedGroup."FAMLED_Id";
            v_L_Name := rec_LedGroup."FAMLED_LedgerName";
            
            SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0) INTO v_IntTranCr
            FROM "FA_T_Voucher", "FA_M_Voucher" 
            WHERE "MI_Id" = p_MI_Id 
                AND "FAMCOMP_Id" = p_FAMCOMP_Id 
                AND "FA_T_Voucher"."FAMLED_Id" = v_L_Code 
                AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN TO_DATE(p_sdate, 'DD-MM-YYYY') AND TO_DATE(p_edate, 'DD-MM-YYYY')
                AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
                AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
                AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'DR' 
                AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher';
            
            SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0) INTO v_IntTranDr
            FROM "FA_T_Voucher", "FA_M_Voucher" 
            WHERE "MI_Id" = p_MI_Id 
                AND "FAMCOMP_Id" = p_FAMCOMP_Id 
                AND "FA_T_Voucher"."FAMLED_Id" = v_L_Code 
                AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN TO_DATE(p_sdate, 'DD-MM-YYYY') AND TO_DATE(p_edate, 'DD-MM-YYYY')
                AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
                AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
                AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'CR' 
                AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher';
            
            IF v_IntTranCr - v_IntTranDr <> 0 THEN
                IF v_MG_Type = 'DR' THEN
                    INSERT INTO "dbo"."tmpIncExp" VALUES (v_mg_Code, v_mg_Name, v_mg_type, v_l_code, v_l_name, v_IntTranCr - v_IntTranDr);
                ELSE
                    INSERT INTO "dbo"."tmpIncExp" VALUES (v_mg_Code, v_mg_Name, v_mg_type, v_l_code, v_l_name, v_IntTranDr - v_IntTranCr);
                END IF;
            END IF;
            
        END LOOP;
        
    END LOOP;
    
    RETURN;
END;
$$;