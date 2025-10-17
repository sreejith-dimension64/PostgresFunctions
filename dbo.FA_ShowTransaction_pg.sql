CREATE OR REPLACE FUNCTION "dbo"."FA_ShowTransaction"(
    "aCode" INTEGER,
    "sDate" VARCHAR(10),
    "eDate" VARCHAR(10),
    "IMFY_Id" INTEGER,
    "sortcond" VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "StrQuery" VARCHAR(300);
    "FAMVOU_Id" BIGINT;
    "prilist" VARCHAR(7999);
    "flg" VARCHAR(2);
    "CntCr" BIGINT;
    "CntDr" BIGINT;
    "T_no" BIGINT;
    "Tdetail_rec" RECORD;
BEGIN
    FOR "Tdetail_rec" IN
        SELECT a."FAMVOU_Id" 
        FROM "FA_M_Voucher" a, "FA_M_Ledger" b, "FA_T_Voucher" c 
        WHERE a."FAMVOU_Id" = c."FAMVOU_Id" 
            AND b."FAMLED_Id" = c."FAMLED_Id" 
            AND c."FAMLED_Id" <> "aCode"  
            AND c."FAMVOU_Id" IN (
                SELECT DISTINCT("FA_M_Voucher"."FAMVOU_VoucherDate") 
                FROM "FA_M_Voucher", "FA_T_Voucher" 
                WHERE "FA_T_Voucher"."FAMLED_Id" = "aCode" 
                    AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS DATE) BETWEEN CAST("sDate" AS DATE) AND CAST("eDate" AS DATE)  
                    AND "FA_M_Voucher"."IMFY_Id" = "IMFY_Id"  
                    AND "FA_M_Voucher"."FAMVOU_Id" = "FA_T_Voucher"."FAMVOU_Id"
            ) 
            AND a."FAMVOU_VoucherType" <> 'MemoVoucher' 
        ORDER BY b."FAMLED_LedgerName"
    LOOP
        "FAMVOU_Id" := "Tdetail_rec"."FAMVOU_Id";
        
        SELECT COUNT("FAMVOU_Id") INTO "CntCr"
        FROM "FA_T_Voucher" 
        WHERE "FAMVOU_Id" = "FAMVOU_Id" 
            AND "FATVOU_CRDRFlg" = 'CR';
        
        SELECT COUNT("FAMVOU_Id") INTO "CntDr"
        FROM "FA_T_Voucher" 
        WHERE "FAMVOU_Id" = "FAMVOU_Id" 
            AND "FATVOU_CRDRFlg" = 'DR';
        
        SELECT "FA_T_Voucher"."FATVOU_CRDRFlg" INTO "flg"
        FROM "FA_M_Voucher", "FA_T_Voucher" 
        WHERE "FA_T_Voucher"."FAMLED_Id" = "aCode"  
            AND "FA_T_Voucher"."FAMVOU_Id" = "FAMVOU_Id"
        LIMIT 1;
        
        IF "flg" = 'Dr' THEN
            IF "CntDr" = "CntCr" AND "CntDr" = 1 THEN
                PERFORM "dbo"."FA_Exec"(1, "FAMVOU_Id", "IMFY_Id");
            END IF;
        ELSE
            PERFORM "dbo"."FA_Exec"(1, "FAMVOU_Id", "IMFY_Id");
        END IF;
        
    END LOOP;
    
    RETURN;
END;
$$;