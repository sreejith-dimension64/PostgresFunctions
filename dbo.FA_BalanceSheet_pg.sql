CREATE OR REPLACE FUNCTION "dbo"."FA_BalanceSheet"(
    "p_IMFY_Id" bigint,
    "p_MI_Id" bigint,
    "p_FAMCOMP_Id" bigint,
    "p_sdate" varchar(10),
    "p_edate" varchar(10),
    "p_flgCap" varchar(3)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_mg_code" varchar(10);
    "v_mg_Name" varchar(100);
    "v_mg_type" varchar(10);
    "v_FAMGRP_Id" bigint;
    "v_L_Code" bigint;
    "v_L_Name" varchar(100);
    "v_intOpenBalDR" float;
    "v_intOpenBalCR" float;
    "v_IntTranCr" float;
    "v_IntTranDr" float;
    "rec_maingroup" RECORD;
    "rec_ledgroup" RECORD;
BEGIN
    DROP TABLE IF EXISTS "dbo"."tmpBS";

    CREATE TABLE "dbo"."tmpBS" (
        "mg_Code" varchar(10),
        "mg_Name" varchar(100),
        "mg_type" varchar(10),
        "l_code" bigint,
        "L_Name" varchar(100),
        "Amt" float
    );

    IF "p_flgCap" = 'NO' THEN
        FOR "rec_maingroup" IN
            SELECT "FAMGRP_Id", "FAMGRP_GroupCode", "FAMGRP_GroupName", "FAMGRP_CRDRFlg" 
            FROM "FA_Master_Group" 
            WHERE "FAMGRP_BSPLFlg" = 'BS' AND "MI_Id" = "p_MI_Id" 
            ORDER BY "FAMGRP_GroupCode"
        LOOP
            "v_FAMGRP_Id" := "rec_maingroup"."FAMGRP_Id";
            "v_MG_Code" := "rec_maingroup"."FAMGRP_GroupCode";
            "v_MG_Name" := "rec_maingroup"."FAMGRP_GroupName";
            "v_MG_Type" := "rec_maingroup"."FAMGRP_CRDRFlg";

            FOR "rec_ledgroup" IN
                SELECT "FAMLED_Id", "FAMLED_LedgerName" 
                FROM "FA_M_Ledger" 
                WHERE "FAMGRP_Id" = "v_FAMGRP_Id" 
                    AND "FAMCOMP_Id" = "p_FAMCOMP_Id" 
                    AND "IMFY_Id" <= "p_IMFY_Id"
            LOOP
                "v_l_code" := "rec_ledgroup"."FAMLED_Id";
                "v_L_Name" := "rec_ledgroup"."FAMLED_LedgerName";

                PERFORM "dbo"."FA_OpeningbalanceSingLeAcc"(
                    "v_l_code",
                    "p_FAMCOMP_Id",
                    "p_sdate",
                    "v_intOpenBalCR",
                    "v_intOpenBalDR"
                );

                SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0)
                INTO "v_IntTranCr"
                FROM "FA_T_Voucher"
                INNER JOIN "FA_M_Voucher" ON "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id"
                WHERE "FA_T_Voucher"."FAMLED_Id" = "v_l_code"
                    AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN CAST("p_sdate" AS date) AND CAST("p_edate" AS date)
                    AND "FA_M_Voucher"."IMFY_Id" = "p_IMFY_Id"
                    AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'CR'
                    AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher';

                "v_IntTranCr" := "v_IntTranCr" + "v_intOpenBalCR";

                SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0)
                INTO "v_IntTranDr"
                FROM "FA_T_Voucher"
                INNER JOIN "FA_M_Voucher" ON "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id"
                WHERE "FA_T_Voucher"."FAMLED_Id" = "v_l_code"
                    AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN CAST("p_sdate" AS date) AND CAST("p_edate" AS date)
                    AND "FA_M_Voucher"."IMFY_Id" = "p_IMFY_Id"
                    AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'DR'
                    AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher';

                "v_IntTranDr" := "v_IntTranDr" + "v_intOpenBalDR";

                IF "v_IntTranCr" - "v_IntTranDr" <> 0 THEN
                    IF "v_MG_Type" = 'DR' THEN
                        INSERT INTO "dbo"."tmpBS" VALUES ("v_mg_Code", "v_mg_Name", "v_mg_type", "v_l_code", "v_l_name", "v_IntTranDr" - "v_IntTranCr");
                    ELSE
                        INSERT INTO "dbo"."tmpBS" VALUES ("v_mg_Code", "v_mg_Name", "v_mg_type", "v_l_code", "v_l_name", "v_IntTranCr" - "v_IntTranDr");
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
    ELSE
        FOR "rec_maingroup" IN
            SELECT "FAMGRP_Id", "FAMGRP_GroupCode", "FAMGRP_GroupName", "FAMGRP_CRDRFlg" 
            FROM "FA_Master_Group" 
            WHERE "FAMGRP_BSPLFlg" = 'BS' 
                AND "MI_Id" = "p_MI_Id" 
                AND "FAMGRP_Id" NOT IN (7, 8, 9, 10, 31, 14, 15, 16, 17, 18, 32)
            ORDER BY "FAMGRP_GroupCode"
        LOOP
            "v_FAMGRP_Id" := "rec_maingroup"."FAMGRP_Id";
            "v_MG_Code" := "rec_maingroup"."FAMGRP_GroupCode";
            "v_MG_Name" := "rec_maingroup"."FAMGRP_GroupName";
            "v_MG_Type" := "rec_maingroup"."FAMGRP_CRDRFlg";

            FOR "rec_ledgroup" IN
                SELECT "FAMLED_Id", "FAMLED_LedgerName" 
                FROM "FA_M_Ledger" 
                WHERE "FAMGRP_Id" = "v_FAMGRP_Id" 
                    AND "FAMCOMP_Id" = "p_FAMCOMP_Id" 
                    AND "IMFY_Id" <= "p_IMFY_Id"
            LOOP
                "v_l_code" := "rec_ledgroup"."FAMLED_Id";
                "v_L_Name" := "rec_ledgroup"."FAMLED_LedgerName";

                PERFORM "dbo"."FA_OpeningbalanceSingLeAcc"(
                    "v_l_code",
                    "p_FAMCOMP_Id",
                    "p_sdate",
                    "v_intOpenBalCR",
                    "v_intOpenBalDR"
                );

                SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0)
                INTO "v_IntTranCr"
                FROM "FA_T_Voucher"
                INNER JOIN "FA_M_Voucher" ON "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id"
                WHERE "FA_T_Voucher"."FAMLED_Id" = "v_l_code"
                    AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN CAST("p_sdate" AS date) AND CAST("p_edate" AS date)
                    AND "FA_M_Voucher"."IMFY_Id" = "p_IMFY_Id"
                    AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'CR'
                    AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher';

                "v_IntTranCr" := "v_IntTranCr" + "v_intOpenBalCR";

                SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0)
                INTO "v_IntTranDr"
                FROM "FA_T_Voucher"
                INNER JOIN "FA_M_Voucher" ON "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id"
                WHERE "FA_T_Voucher"."FAMLED_Id" = "v_l_code"
                    AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN CAST("p_sdate" AS date) AND CAST("p_edate" AS date)
                    AND "FA_M_Voucher"."IMFY_Id" = "p_IMFY_Id"
                    AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'DR'
                    AND "FA_M_Voucher"."FAMVOU_VoucherType" <> 'MemoVoucher';

                "v_IntTranDr" := "v_IntTranDr" + "v_intOpenBalDR";

                IF "v_IntTranCr" - "v_IntTranDr" <> 0 THEN
                    IF "v_MG_Type" = 'DR' THEN
                        INSERT INTO "dbo"."tmpBS" VALUES ("v_mg_Code", "v_mg_Name", "v_mg_type", "v_l_code", "v_l_name", "v_IntTranDr" - "v_IntTranCr");
                    ELSE
                        INSERT INTO "dbo"."tmpBS" VALUES ("v_mg_Code", "v_mg_Name", "v_mg_type", "v_l_code", "v_l_name", "v_IntTranCr" - "v_IntTranDr");
                    END IF;
                END IF;
            END LOOP;
        END LOOP;
    END IF;

    RETURN;
END;
$$;