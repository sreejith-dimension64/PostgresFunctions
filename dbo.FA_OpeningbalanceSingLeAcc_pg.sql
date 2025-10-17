CREATE OR REPLACE FUNCTION "dbo"."FA_OpeningbalanceSingLeAcc" (
    "FAMLED_Id" bigint,
    "MI_Id" bigint,
    "FAMCOMP_Id" bigint,
    "date" date,
    OUT "intOpenBalCR" float,
    OUT "intOpenBalDr" float
)
RETURNS RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "IMFY_Id" bigint;
    "l_code" bigint;
    "OCr" float;
    "ODr" float;
    "Drbal" float;
    "Crbal" float;
    "Led_rec" RECORD;
    "Opbal_rec" RECORD;
BEGIN
    "intOpenBalCR" := 0;
    "intOpenBalDr" := 0;

    SELECT * INTO "IMFY_Id" FROM "dbo"."FA_FindFyr"("date", "FAMCOMP_Id");

    FOR "Led_rec" IN 
        SELECT "FAMLED_Id" 
        FROM "FA_M_Ledger" 
        WHERE "IMFY_Id" <= "FA_OpeningbalanceSingLeAcc"."IMFY_Id" 
            AND "FAMCOMP_Id" = "FA_OpeningbalanceSingLeAcc"."FAMCOMP_Id" 
            AND "FAMLED_Id" = "FA_OpeningbalanceSingLeAcc"."FAMLED_Id" 
            AND "FAMGRP_Id" IN (
                SELECT DISTINCT "FAMGRP_Id" 
                FROM "FA_Master_Group" 
                WHERE UPPER(SUBSTRING("FAMGRP_GroupCode", 3, 2)) = 'BS' 
                    OR UPPER(SUBSTRING("FAMGRP_GroupCode", 3, 2)) = 'PL'
            )
    LOOP
        "l_code" := "Led_rec"."FAMLED_Id";

        FOR "Opbal_rec" IN
            SELECT 
                (CASE WHEN "FAMLEDD_OBCRDRFlg" = 'Dr' THEN "FAMLEDD_OpeningBalance" END) AS "DrOB",
                (CASE WHEN "FAMLEDD_OBCRDRFlg" = 'Cr' THEN "FAMLEDD_OpeningBalance" END) AS "CrOB"
            FROM "FA_M_Ledger_Details" "LD"
            INNER JOIN "FA_M_Ledger" "ML" ON "LD"."FAMLED_Id" = "LD"."FAMLED_Id"
            WHERE "MI_Id" = "FA_OpeningbalanceSingLeAcc"."MI_Id" 
                AND "FAMCOMP_Id" = "FA_OpeningbalanceSingLeAcc"."FAMCOMP_Id" 
                AND "ML"."FAMLED_Id" = "l_code" 
                AND "ML"."IMFY_Id" = "FA_OpeningbalanceSingLeAcc"."IMFY_Id"
        LOOP
            "ODr" := "Opbal_rec"."DrOB";
            "OCr" := "Opbal_rec"."CrOB";

            IF "OCr" > 0 THEN
                "intOpenBalCR" := "OCr";
            END IF;

            IF "ODr" > 0 THEN
                "intOpenBalDr" := "ODr";
            END IF;
        END LOOP;

        SELECT COALESCE(SUM("FATVOU_Amount"), 0) INTO "Drbal"
        FROM "FA_M_Voucher" "a"
        INNER JOIN "FA_T_Voucher" "b" ON "a"."FAMVOU_Id" = "b"."FAMVOU_Id"
        WHERE CAST("FAMVOU_VoucherDate" AS date) < "FA_OpeningbalanceSingLeAcc"."date" 
            AND "b"."FAMLED_Id" = "l_code" 
            AND UPPER("b"."FATVOU_CRDRFlg") = 'DR' 
            AND "a"."IMFY_Id" = "FA_OpeningbalanceSingLeAcc"."IMFY_Id" 
            AND "a"."FAMVOU_VoucherType" <> 'MemoVoucher' 
            AND "MI_Id" = "FA_OpeningbalanceSingLeAcc"."MI_Id" 
            AND "FAMCOMP_Id" = "FA_OpeningbalanceSingLeAcc"."FAMCOMP_Id";

        "intOpenBalDr" := "intOpenBalDr" + "Drbal";

        SELECT COALESCE(SUM("FATVOU_Amount"), 0) INTO "Crbal"
        FROM "FA_M_Voucher" "a"
        INNER JOIN "FA_T_Voucher" "b" ON "a"."FAMVOU_Id" = "b"."FAMVOU_Id"
        WHERE CAST("FAMVOU_VoucherDate" AS date) < "FA_OpeningbalanceSingLeAcc"."date" 
            AND "b"."FAMLED_Id" = "l_code" 
            AND UPPER("b"."FATVOU_CRDRFlg") = 'CR' 
            AND "a"."IMFY_Id" = "FA_OpeningbalanceSingLeAcc"."IMFY_Id" 
            AND "a"."FAMVOU_VoucherType" <> 'MemoVoucher';

        "intOpenBalCR" := "intOpenBalCR" + "Crbal";

    END LOOP;

    RETURN;
END;
$$;