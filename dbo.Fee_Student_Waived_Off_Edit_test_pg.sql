CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Waived_Off_Edit_test"(
    "FSWO_ID" bigint,
    "waivedamountnew" bigint,
    "waivedoffdate" timestamp
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "miid" bigint;
    "asmayid" bigint;
    "amstid" bigint;
    "FMG_id" bigint;
    "FMH_id" bigint;
    "FTI_id" bigint;
    "FMA_id" bigint;
    "userid" bigint;
    "Waivedamount" bigint;
    "FSS_ToBePaid" bigint;
    "FSS_ExcessPaidAmount" bigint;
    "FSS_RefundableAmount" bigint;
    "FSS_RunningExcessAmount" bigint;
    "totalval" bigint;
    "FMH_RefundFlag" boolean;
BEGIN
    SELECT "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSWO_WaivedOffAmount", "USER_ID"
    INTO "miid", "asmayid", "amstid", "FMG_id", "FMH_id", "FTI_id", "FMA_id", "Waivedamount", "userid"
    FROM "Fee_Student_Waived_Off"
    WHERE "FSWO_Id" = "FSWO_ID";

    SELECT "FSS_ToBePaid", "FSS_ExcessPaidAmount", "FSS_RefundableAmount", "FSS_RunningExcessAmount"
    INTO "FSS_ToBePaid", "FSS_ExcessPaidAmount", "FSS_RefundableAmount", "FSS_RunningExcessAmount"
    FROM "Fee_Student_Status"
    WHERE "MI_Id" = "miid" 
        AND "ASMAY_Id" = "asmayid" 
        AND "AMST_Id" = "amstid" 
        AND "FMG_Id" = "FMG_id" 
        AND "FMH_Id" = "FMH_id" 
        AND "FTI_Id" = "FTI_id" 
        AND "FMA_Id" = "FMA_id" 
        AND "user_id" = "userid";

    "FSS_ToBePaid" := ("FSS_ToBePaid" + "Waivedamount") - "FSS_ExcessPaidAmount";
    "FSS_RefundableAmount" := "FSS_RefundableAmount" - "FSS_ExcessPaidAmount";
    "FSS_RunningExcessAmount" := "FSS_RunningExcessAmount" - "FSS_ExcessPaidAmount";
    "FSS_ExcessPaidAmount" := 0;
    "totalval" := "waivedamountnew" - "FSS_ToBePaid";

    IF ("FSS_ToBePaid" >= "waivedamountnew") THEN
        SELECT "FMH_RefundFlag"
        INTO "FMH_RefundFlag"
        FROM "Fee_Master_Head"
        WHERE "FMH_Id" = "FMH_id";

        IF ("FMH_RefundFlag" = true) THEN
            UPDATE "Fee_Student_Status" 
            SET "FSS_ToBePaid" = ("FSS_ToBePaid" - "waivedamountnew"), 
                "FSS_ExcessPaidAmount" = "FSS_ExcessPaidAmount",
                "FSS_RefundableAmount" = "FSS_RefundableAmount", 
                "FSS_WaivedAmount" = "waivedamountnew"
            WHERE "MI_Id" = "miid" 
                AND "ASMAY_Id" = "asmayid" 
                AND "AMST_Id" = "amstid" 
                AND "FMG_Id" = "FMG_id" 
                AND "FMH_Id" = "FMH_id" 
                AND "FTI_Id" = "FTI_id" 
                AND "FMA_Id" = "FMA_id" 
                AND "user_id" = "userid";

            UPDATE "Fee_Student_Waived_Off" 
            SET "FSWO_WaivedOffAmount" = "waivedamountnew",
                "UpdatedDate" = CURRENT_TIMESTAMP
            WHERE "FSWO_Id" = "FSWO_ID";
        ELSE
            UPDATE "Fee_Student_Status" 
            SET "FSS_ToBePaid" = ("FSS_ToBePaid" - "waivedamountnew"), 
                "FSS_ExcessPaidAmount" = "FSS_ExcessPaidAmount",
                "FSS_RunningExcessAmount" = "FSS_RunningExcessAmount", 
                "FSS_WaivedAmount" = "waivedamountnew"
            WHERE "MI_Id" = "miid" 
                AND "ASMAY_Id" = "asmayid" 
                AND "AMST_Id" = "amstid" 
                AND "FMG_Id" = "FMG_id" 
                AND "FMH_Id" = "FMH_id" 
                AND "FTI_Id" = "FTI_id" 
                AND "FMA_Id" = "FMA_id" 
                AND "user_id" = "userid";

            UPDATE "Fee_Student_Waived_Off" 
            SET "FSWO_WaivedOffAmount" = "waivedamountnew",
                "UpdatedDate" = CURRENT_TIMESTAMP
            WHERE "FSWO_Id" = "FSWO_ID";
        END IF;
    ELSE
        SELECT "FMH_RefundFlag"
        INTO "FMH_RefundFlag"
        FROM "Fee_Master_Head"
        WHERE "FMH_Id" = "FMH_id";

        IF ("FMH_RefundFlag" = true) THEN
            UPDATE "Fee_Student_Status" 
            SET "FSS_ToBePaid" = 0, 
                "FSS_ExcessPaidAmount" = ("FSS_ExcessPaidAmount" + "totalval"),
                "FSS_RefundableAmount" = ("FSS_RefundableAmount" + "totalval"), 
                "FSS_WaivedAmount" = "waivedamountnew"
            WHERE "MI_Id" = "miid" 
                AND "ASMAY_Id" = "asmayid" 
                AND "AMST_Id" = "amstid" 
                AND "FMG_Id" = "FMG_id" 
                AND "FMH_Id" = "FMH_id" 
                AND "FTI_Id" = "FTI_id" 
                AND "FMA_Id" = "FMA_id" 
                AND "user_id" = "userid";

            UPDATE "Fee_Student_Waived_Off" 
            SET "FSWO_WaivedOffAmount" = "waivedamountnew",
                "UpdatedDate" = CURRENT_TIMESTAMP
            WHERE "FSWO_Id" = "FSWO_ID";
        ELSE
            UPDATE "Fee_Student_Status" 
            SET "FSS_ToBePaid" = 0, 
                "FSS_ExcessPaidAmount" = ("FSS_ExcessPaidAmount" - "FSS_WaivedAmount" + "totalval"),
                "FSS_RunningExcessAmount" = ("FSS_RunningExcessAmount" - "FSS_WaivedAmount" + "totalval"), 
                "FSS_WaivedAmount" = "waivedamountnew"
            WHERE "MI_Id" = "miid" 
                AND "ASMAY_Id" = "asmayid" 
                AND "AMST_Id" = "amstid" 
                AND "FMG_Id" = "FMG_id" 
                AND "FMH_Id" = "FMH_id" 
                AND "FTI_Id" = "FTI_id" 
                AND "FMA_Id" = "FMA_id" 
                AND "user_id" = "userid";

            UPDATE "Fee_Student_Waived_Off" 
            SET "FSWO_WaivedOffAmount" = "waivedamountnew",
                "UpdatedDate" = CURRENT_TIMESTAMP
            WHERE "FSWO_Id" = "FSWO_ID";
        END IF;
    END IF;

    UPDATE "Fee_Student_Waived_Off" 
    SET "FSWO_Date" = "waivedoffdate"
    WHERE "FSWO_Id" = "FSWO_ID";

    RETURN;
END;
$$;