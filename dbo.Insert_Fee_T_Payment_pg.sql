CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_T_Payment"(
    "MI_ID" bigint,
    "FYP_Id" bigint,
    "FMA_Id" bigint,
    "FTP_Paid_Amt" decimal,
    "FTP_Fine_Amt" decimal,
    "FTP_Concession_Amt" decimal,
    "FTP_Waived_Amt" decimal,
    "ftp_remarks" varchar(10),
    "amst_id" bigint,
    "asmay_id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "ftptobepaidamt" decimal;
    "paidamt" decimal;
    "concessionamt" decimal;
    "waivedamt" decimal;
    "fineamt" decimal;
    "netamount" decimal;
    "fmg_id" bigint;
    "fmh_id" bigint;
    "fti_id" bigint;
    "v_rowcount" integer;
BEGIN
    RAISE NOTICE 'sucess';

    SELECT "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ConcessionAmount", "FSS_WaivedAmount", "FSS_FineAmount", "FSS_NetAmount"
    INTO "ftptobepaidamt", "paidamt", "concessionamt", "waivedamt", "fineamt", "netamount"
    FROM "Fee_Student_Status"
    WHERE "Amst_Id" = "amst_id" 
        AND "asmay_id" = "asmay_id" 
        AND "fma_id" = "FMA_Id" 
        AND "MI_Id" = "MI_ID";

    SELECT "FMG_Id", "FMH_Id", "FTI_Id"
    INTO "fmg_id", "fmh_id", "fti_id"
    FROM "Fee_Student_Status"
    WHERE "AMST_Id" = "amst_id" 
        AND "ASMAY_Id" = "asmay_id" 
        AND "MI_Id" = "MI_ID" 
        AND "FMA_Id" = "FMA_Id";

    SELECT "FSCI_ConcessionAmount"
    INTO "concessionamt"
    FROM "Fee_Student_Concession"
    INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id"
    WHERE "AMST_Id" = "amst_id" 
        AND "MI_Id" = "MI_ID" 
        AND "ASMAY_ID" = "asmay_id" 
        AND "FMG_Id" = "fmg_id" 
        AND "FMH_Id" = "fmh_id" 
        AND "FTI_Id" = "fti_id";

    GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;

    IF "v_rowcount" <= 0 THEN
        IF ("netamount" >= "paidamt" + "FTP_Paid_Amt" + "FTP_Concession_Amt") THEN
            UPDATE "Fee_Student_Status"
            SET "FSS_ToBePaid" = "ftptobepaidamt" - "FTP_Paid_Amt" - "FTP_Concession_Amt",
                "FSS_PaidAmount" = "paidamt" + "FTP_Paid_Amt",
                "FSS_ConcessionAmount" = "concessionamt" + "FTP_Concession_Amt",
                "FSS_WaivedAmount" = "FTP_Waived_Amt",
                "FSS_FineAmount" = "fineamt" + "FTP_Fine_Amt"
            WHERE "Amst_Id" = "amst_id" 
                AND "asmay_id" = "asmay_id" 
                AND "fma_id" = "FMA_Id" 
                AND "MI_Id" = "MI_ID";
        END IF;
    ELSE
        UPDATE "Fee_Student_Status"
        SET "FSS_ToBePaid" = "ftptobepaidamt" - "FTP_Paid_Amt",
            "FSS_PaidAmount" = "paidamt" + "FTP_Paid_Amt",
            "FSS_ConcessionAmount" = "concessionamt",
            "FSS_WaivedAmount" = "FTP_Waived_Amt",
            "FSS_FineAmount" = "fineamt" + "FTP_Fine_Amt"
        WHERE "Amst_Id" = "amst_id" 
            AND "asmay_id" = "asmay_id" 
            AND "fma_id" = "FMA_Id" 
            AND "MI_Id" = "MI_ID";
    END IF;

    RETURN;
END;
$$;