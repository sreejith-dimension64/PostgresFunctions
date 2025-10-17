CREATE OR REPLACE FUNCTION "dbo"."FA_Trialbal"(
    p_MI_Id bigint,
    p_IMFY_Id bigint,
    p_FAMCOMP_Id bigint,
    p_sdate timestamp,
    p_edate timestamp
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_intOpenBalDR double precision;
    v_intOpenBalCR double precision;
    v_mg_code varchar(10);
    v_mg_name varchar(50);
    v_mg_type varchar(10);
    v_FAMGRP_Id bigint;
    v_l_name varchar(50);
    v_l_code bigint;
    v_l_type varchar(10);
    v_intTranDR double precision;
    v_intTranCR double precision;
    rec_group RECORD;
    rec_ledger RECORD;
BEGIN
    TRUNCATE TABLE "temptrialbalance";
    
    FOR rec_group IN 
        SELECT DISTINCT "FAMGRP_Id", "FAMGRP_GroupCode", "FAMGRP_GroupName", "FAMGRP_CRDRFlg" 
        FROM "FA_Master_group"  
        WHERE "MI_Id" = p_MI_Id
    LOOP
        v_FAMGRP_Id := rec_group."FAMGRP_Id";
        v_mg_code := rec_group."FAMGRP_GroupCode";
        v_mg_name := rec_group."FAMGRP_GroupName";
        v_mg_type := rec_group."FAMGRP_CRDRFlg";
        
        FOR rec_ledger IN 
            SELECT "FAMLED_LedgerName", "FAMLED_Id", "FAMLED_Type" 
            FROM "FA_M_Ledger" 
            WHERE "FA_M_Ledger"."FAMCOMP_Id" = p_FAMCOMP_Id 
                AND "IMFY_Id" <= p_IMFY_Id 
                AND "FAMGRP_Id" = v_FAMGRP_Id 
            ORDER BY "FAMLED_LedgerName"
        LOOP
            v_l_name := rec_ledger."FAMLED_LedgerName";
            v_l_code := rec_ledger."FAMLED_Id";
            v_l_type := rec_ledger."FAMLED_Type";
            
            v_intOpenBalCR := 0;
            v_intOpenBalDR := 0;
            
            SELECT * FROM "dbo"."FA_OpeningbalanceSingLeAcc"(
                v_l_code, 
                p_FAMCOMP_Id, 
                p_sdate
            ) INTO v_intOpenBalCR, v_intOpenBalDR;
            
            IF v_mg_code = 'CRPL28' THEN
                RAISE NOTICE '@mg_code--% @l_code---%', v_mg_code, v_l_code;
            END IF;
            
            RAISE NOTICE 'Cr--%', v_intOpenBalCR;
            RAISE NOTICE 'dr--%', v_intOpenBalDR;
            
            SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0) 
            INTO v_intTranDR
            FROM "FA_T_Voucher", "FA_M_Voucher" 
            WHERE "FA_T_Voucher"."FAMLED_Id" = v_l_code 
                AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN CAST(p_sdate AS date) AND CAST(p_edate AS date)
                AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
                AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
                AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'DR';
            
            SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0) 
            INTO v_intTranCR
            FROM "FA_T_Voucher", "FA_M_Voucher" 
            WHERE "FA_T_Voucher"."FAMLED_Id" = v_l_code 
                AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN CAST(p_sdate AS date) AND CAST(p_edate AS date)
                AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
                AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
                AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'CR';
            
            INSERT INTO "TempTrialBalance"(
                "openbaldr", 
                "openbalcr", 
                "trandr", 
                "trancr", 
                "closebal", 
                "l_name", 
                "mg_codeint", 
                "mg_name", 
                "l_code"
            ) 
            VALUES(
                v_intOpenBalDR, 
                v_intOpenBalCR, 
                v_intTranDR, 
                v_intTranCR, 
                v_intOpenBalDR - v_intOpenBalCR + v_intTranDR - v_intTranCR, 
                v_l_name, 
                substring(v_mg_code, 5, 2), 
                v_mg_name, 
                v_l_code
            );
            
        END LOOP;
        
    END LOOP;
    
    RETURN;
END;
$$;