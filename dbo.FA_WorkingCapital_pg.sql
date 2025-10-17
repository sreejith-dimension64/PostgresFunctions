CREATE OR REPLACE FUNCTION "dbo"."FA_WorkingCapital"(
    "p_MI_Id" bigint,
    "p_IMFY_Id" bigint,
    "p_FAMCOMP_Id" bigint,
    "p_sdate" varchar(10),
    "p_edate" varchar(10)
)
RETURNS TABLE("Balance" double precision) AS $$
DECLARE
    "v_mg_code" varchar(10);
    "v_mg_Name" varchar(100);
    "v_mg_type" varchar(10);
    "v_totCr" double precision;
    "v_totDr" double precision;
    "v_L_Code" bigint;
    "v_L_Name" varchar(100);
    "v_intOpenBalDR" double precision;
    "v_intOpenBalCR" double precision;
    "v_IntTranCr" double precision;
    "v_IntTranDr" double precision;
    "rec_maingroup" RECORD;
    "rec_ledgroup" RECORD;
    "rec_sumdrch" RECORD;
BEGIN
    "v_totCr" := 0;
    "v_totDr" := 0;

    FOR "rec_maingroup" IN
        SELECT "FAMGRP_GroupCode", "FAMGRP_GroupName", "FAMGRP_CRDRFlg" 
        FROM "FA_Master_Group" 
        WHERE "FAMGRP_BSPLFlg" = 'BS' 
        AND "FAMGRP_GroupCode" IN (7, 8, 9, 10, 31, 14, 15, 16, 17, 18, 32) 
        ORDER BY "FAMGRP_GroupCode"
    LOOP
        "v_mg_code" := "rec_maingroup"."FAMGRP_GroupCode";
        "v_mg_Name" := "rec_maingroup"."FAMGRP_GroupName";
        "v_mg_type" := "rec_maingroup"."FAMGRP_CRDRFlg";

        FOR "rec_ledgroup" IN
            SELECT "FAMLED_Id", "FAMLED_LedgerName" 
            FROM "FA_M_Ledger" 
            WHERE "FAMGRP_Id" = substring("v_mg_code", 5, 2)::bigint 
            AND "FAMCOMP_Id" = "p_FAMCOMP_Id" 
            AND "IMFY_Id" <= "p_IMFY_Id" 
            AND "MI_Id" = "p_MI_Id"
        LOOP
            "v_L_Code" := "rec_ledgroup"."FAMLED_Id";
            "v_L_Name" := "rec_ledgroup"."FAMLED_LedgerName";

            SELECT * INTO "v_intOpenBalCR", "v_intOpenBalDR"
            FROM "dbo"."FA_OpeningbalanceSingLeAcc"(
                "v_L_Code", 
                "p_FAMCOMP_Id", 
                "p_sdate"
            );

            SELECT COALESCE(sum("FA_T_Voucher"."FATVOU_Amount"), 0) INTO "v_IntTranCr"
            FROM "FA_T_Voucher", "FA_M_Voucher" 
            WHERE "FA_T_Voucher"."FAMLED_Id" = "v_L_Code" 
            AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) 
                BETWEEN CAST("p_sdate" AS date) AND CAST("p_edate" AS date) 
            AND "FA_M_Voucher"."IMFY_Id" = "p_IMFY_Id" 
            AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
            AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'CR' 
            AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher';

            "v_IntTranCr" := "v_IntTranCr" + "v_intOpenBalCR";

            SELECT COALESCE(sum("FA_T_Voucher"."FATVOU_Amount"), 0) INTO "v_IntTranDr"
            FROM "FA_T_Voucher", "FA_M_Voucher" 
            WHERE "FA_T_Voucher"."FAMLED_Id" = "v_L_Code" 
            AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) 
                BETWEEN CAST("p_sdate" AS date) AND CAST("p_edate" AS date) 
            AND "FA_M_Voucher"."IMFY_Id" = "p_IMFY_Id" 
            AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
            AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'DR' 
            AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher';

            "v_IntTranDr" := "v_IntTranDr" + "v_intOpenBalDR";

            IF "v_IntTranDr" > "v_IntTranCr" THEN
                "v_TotDr" := "v_TotDr" + ("v_IntTranDr" - "v_IntTranCr");
            ELSE
                IF "v_IntTranCr" > "v_IntTranDr" THEN
                    "v_TotCr" := "v_TotCr" + ("v_IntTranCr" - "v_IntTranDr");
                END IF;
            END IF;

        END LOOP;

    END LOOP;

    RETURN QUERY SELECT "v_TotDr" - "v_TotCr" AS "Balance";
END;
$$ LANGUAGE plpgsql;