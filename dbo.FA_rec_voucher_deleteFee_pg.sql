CREATE OR REPLACE FUNCTION "dbo"."FA_rec_voucher_deleteFee"(
    "MI_Id" bigint,
    "FAMCOMP_Id" bigint,
    "IMFY_Id" bigint,
    "r_no" varchar(100)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "lcode" bigint;
    "Fyr_id" bigint;
    "Tno" bigint;
    "AccDel_rec" RECORD;
    "lno_rec" RECORD;
BEGIN
    "Tno" := 0;
    "Fyr_id" := 0;
    "lcode" := 0;

    FOR "AccDel_rec" IN 
        SELECT "FAMVOU_Id", "IMFY_Id" 
        FROM "FA_M_Voucher" 
        WHERE "MI_Id" = "MI_Id" 
        AND "FAMCOMP_Id" = "FAMCOMP_Id" 
        AND "IMFY_Id" = "IMFY_Id" 
        AND "FAMVOU_Description" = "r_no"
    LOOP
        "Tno" := "AccDel_rec"."FAMVOU_Id";
        "Fyr_id" := "AccDel_rec"."IMFY_Id";

        FOR "lno_rec" IN 
            SELECT "FAMLED_Id" 
            FROM "FA_T_Voucher" 
            WHERE "FAMVOU_Id" = "Tno"
        LOOP
            "lcode" := "lno_rec"."FAMLED_Id";

            DELETE FROM "FA_T_Voucher" 
            WHERE "FAMLED_Id" = "lcode" 
            AND "FAMVOU_Id" = "Tno";

            PERFORM "dbo"."FA_autoupdation"("lcode", "Fyr_id");

        END LOOP;

        DELETE FROM "FA_M_Voucher" WHERE "FAMVOU_Id" = "Tno";

    END LOOP;

    RETURN;
END;
$$;