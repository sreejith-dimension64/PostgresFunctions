CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_T_Paymentnew"(
    "listparam" TEXT,
    "mi_id" VARCHAR(10),
    "asmay_id" BIGINT,
    "amst_id" BIGINT,
    "ftp_remarks" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "FYP_Id" BIGINT;
    "FMA_Id" BIGINT;
    "FTP_Paid_Amt" BIGINT;
    "FTP_Fine_Amt" BIGINT;
    "FTP_Concession_Amt" BIGINT;
    "FTP_Waived_Amt" BIGINT;
    "ftptobepaidamt" DECIMAL;
    "paidamt" DECIMAL;
    "concessionamt" DECIMAL;
    "waivedamt" DECIMAL;
    "fineamt" DECIMAL;
    "netamount" DECIMAL;
    "fmg_id" BIGINT;
    "fmh_id" BIGINT;
    "fti_id" BIGINT;
    "excess" BIGINT;
    "previousexcess" BIGINT;
    "query" TEXT;
    "dropquery" TEXT;
    "createquery" TEXT;
    "tablenme" TEXT;
    "rowcount_var" INTEGER;
    "rec" RECORD;
BEGIN

    SELECT 'temp' || CAST(FLOOR(RANDOM() * 999 + 1)::INTEGER AS TEXT) INTO "tablenme";

    "createquery" := 'CREATE TEMP TABLE ' || "tablenme" || ' (
        "MI_Id" BIGINT NULL,
        "FYP_Id" BIGINT NULL,
        "FMA_Id" BIGINT NULL,
        "FTP_Paid_Amt" DECIMAL(18, 0) NULL,
        "FTP_Fine_Amt" DECIMAL(18, 0) NULL,
        "FTP_Concession_Amt" DECIMAL(18, 0) NULL,
        "FTP_Waived_Amt" DECIMAL(18, 0) NULL
    )';

    EXECUTE "createquery";

    "query" := 'INSERT INTO ' || "tablenme" || ' VALUES ' || "listparam";

    EXECUTE "query";

    FOR "rec" IN EXECUTE 'SELECT "FYP_Id", "FMA_Id", "FTP_Paid_Amt", "FTP_Fine_Amt", "FTP_Concession_Amt", "FTP_Waived_Amt" FROM ' || "tablenme" || ' WHERE "MI_Id" = ' || "mi_id"
    LOOP
        "FYP_Id" := "rec"."FYP_Id";
        "FMA_Id" := "rec"."FMA_Id";
        "FTP_Paid_Amt" := "rec"."FTP_Paid_Amt";
        "FTP_Fine_Amt" := "rec"."FTP_Fine_Amt";
        "FTP_Concession_Amt" := "rec"."FTP_Concession_Amt";
        "FTP_Waived_Amt" := "rec"."FTP_Waived_Amt";

        SELECT "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ConcessionAmount", "FSS_WaivedAmount", "FSS_FineAmount", "FSS_NetAmount", "FSS_ExcessPaidAmount"
        INTO "ftptobepaidamt", "paidamt", "concessionamt", "waivedamt", "fineamt", "netamount", "previousexcess"
        FROM "Fee_Student_Status"
        WHERE "Amst_Id" = "amst_id" AND "asmay_id" = "asmay_id" AND "fma_id" = "FMA_Id" AND "MI_Id" = "mi_id";

        SELECT "FMG_Id", "FMH_Id", "FTI_Id"
        INTO "fmg_id", "fmh_id", "fti_id"
        FROM "Fee_Student_Status"
        WHERE "AMST_Id" = "amst_id" AND "ASMAY_Id" = "asmay_id" AND "MI_Id" = "mi_id" AND "FMA_Id" = "FMA_Id";

        SELECT "FSCI_ConcessionAmount"
        INTO "concessionamt"
        FROM "Fee_Student_Concession"
        INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id"
        WHERE "AMST_Id" = "amst_id" AND "MI_Id" = "mi_id" AND "ASMAY_ID" = "asmay_id" AND "FMG_Id" = "fmg_id" AND "FMH_Id" = "fmh_id" AND "FTI_Id" = "fti_id";

        GET DIAGNOSTICS "rowcount_var" = ROW_COUNT;

        IF "rowcount_var" <= 0 THEN

            IF ("netamount" >= "paidamt" + "FTP_Paid_Amt" + "FTP_Concession_Amt") THEN

                UPDATE "Fee_Student_Status"
                SET "FSS_ToBePaid" = "ftptobepaidamt" - "FTP_Paid_Amt",
                    "FSS_PaidAmount" = "paidamt" + "FTP_Paid_Amt",
                    "FSS_ConcessionAmount" = "FTP_Concession_Amt",
                    "FSS_WaivedAmount" = "FTP_Waived_Amt",
                    "FSS_FineAmount" = "fineamt" + "FTP_Fine_Amt"
                WHERE "Amst_Id" = "amst_id" AND "asmay_id" = "asmay_id" AND "fma_id" = "FMA_Id" AND "MI_Id" = "mi_id";

            ELSE

                "excess" := "FTP_Paid_Amt" + "previousexcess" - "ftptobepaidamt";
                UPDATE "Fee_Student_Status"
                SET "FSS_ToBePaid" = 0,
                    "FSS_PaidAmount" = "paidamt" + "FTP_Paid_Amt",
                    "FSS_WaivedAmount" = "FTP_Waived_Amt",
                    "FSS_FineAmount" = "fineamt" + "FTP_Fine_Amt",
                    "FSS_ExcessPaidAmount" = "excess",
                    "FSS_RunningExcessAmount" = "excess"
                WHERE "Amst_Id" = "amst_id" AND "asmay_id" = "asmay_id" AND "fma_id" = "FMA_Id" AND "MI_Id" = "mi_id";

            END IF;

        ELSE

            IF ("netamount" >= "paidamt" + "FTP_Paid_Amt" + "FTP_Concession_Amt") THEN

                UPDATE "Fee_Student_Status"
                SET "FSS_ToBePaid" = "ftptobepaidamt" - "FTP_Paid_Amt",
                    "FSS_PaidAmount" = "paidamt" + "FTP_Paid_Amt",
                    "FSS_ConcessionAmount" = "FTP_Concession_Amt",
                    "FSS_WaivedAmount" = "FTP_Waived_Amt",
                    "FSS_FineAmount" = "fineamt" + "FTP_Fine_Amt"
                WHERE "Amst_Id" = "amst_id" AND "asmay_id" = "asmay_id" AND "fma_id" = "FMA_Id" AND "MI_Id" = "mi_id";

            ELSE

                "excess" := "FTP_Paid_Amt" + "previousexcess" - "ftptobepaidamt";
                UPDATE "Fee_Student_Status"
                SET "FSS_ToBePaid" = 0,
                    "FSS_PaidAmount" = "paidamt" + "FTP_Paid_Amt",
                    "FSS_ConcessionAmount" = "concessionamt",
                    "FSS_WaivedAmount" = "FTP_Waived_Amt",
                    "FSS_FineAmount" = "fineamt" + "FTP_Fine_Amt",
                    "FSS_ExcessPaidAmount" = "excess",
                    "FSS_RunningExcessAmount" = "excess"
                WHERE "Amst_Id" = "amst_id" AND "asmay_id" = "asmay_id" AND "fma_id" = "FMA_Id" AND "MI_Id" = "mi_id";

            END IF;

        END IF;

    END LOOP;

    "dropquery" := 'DROP TABLE ' || "tablenme";

    EXECUTE "dropquery";

END;
$$;