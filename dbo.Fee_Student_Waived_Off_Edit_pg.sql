CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Waived_Off_Edit"(
    "FSWO_ID" bigint,
    "waivedamountnew" bigint,
    "FSWO_Date" timestamp,
    "finewaivoff" int,
    "FSWO_WaivedOffRemarks" text,
    "completefinewaivedoff" boolean,
    "flepath" text,
    "flenme" text
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
    "FSS_TotalToBePaid" bigint;
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

    SELECT "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_ExcessPaidAmount", "FSS_RefundableAmount", "FSS_RunningExcessAmount"
    INTO "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_ExcessPaidAmount", "FSS_RefundableAmount", "FSS_RunningExcessAmount"
    FROM "Fee_Student_Status"
    WHERE "MI_Id" = "miid" AND "ASMAY_Id" = "asmayid" AND "AMST_Id" = "amstid" AND "FMG_Id" = "FMG_id" 
        AND "FMH_Id" = "FMH_id" AND "FTI_Id" = "FTI_id" AND "FMA_Id" = "FMA_id" AND "user_id" = "userid";

    "FSS_TotalToBePaid" := ("FSS_TotalToBePaid" + "Waivedamount") - "FSS_ExcessPaidAmount";
    "FSS_ToBePaid" := ("FSS_ToBePaid" + "Waivedamount") - "FSS_ExcessPaidAmount";
    "FSS_RefundableAmount" := "FSS_RefundableAmount" - "FSS_ExcessPaidAmount";
    "FSS_RunningExcessAmount" := "FSS_RunningExcessAmount" - "FSS_ExcessPaidAmount";
    "FSS_ExcessPaidAmount" := 0;
    "totalval" := "waivedamountnew" - "FSS_ToBePaid";

    IF ("FSS_ToBePaid" >= "waivedamountnew") THEN
        SELECT "FMH_RefundFlag" INTO "FMH_RefundFlag" FROM "Fee_Master_Head" WHERE "FMH_Id" = "FMH_id";
        
        IF ("FMH_RefundFlag" = true) THEN
            IF "finewaivoff" = 0 THEN
                UPDATE "Fee_Student_Status" 
                SET "FSS_TotalToBePaid" = ("FSS_TotalToBePaid" - "waivedamountnew"),
                    "FSS_ToBePaid" = ("FSS_ToBePaid" - "waivedamountnew"),
                    "FSS_ExcessPaidAmount" = "FSS_ExcessPaidAmount",
                    "FSS_RefundableAmount" = "FSS_RefundableAmount",
                    "FSS_WaivedAmount" = "waivedamountnew"
                WHERE "MI_Id" = "miid" AND "ASMAY_Id" = "asmayid" AND "AMST_Id" = "amstid" AND "FMG_Id" = "FMG_id" 
                    AND "FMH_Id" = "FMH_id" AND "FTI_Id" = "FTI_id" AND "FMA_Id" = "FMA_id" AND "user_id" = "userid";
            END IF;
            
            UPDATE "Fee_Student_Waived_Off" 
            SET "FSWO_WaivedOffAmount" = "waivedamountnew",
                "UpdatedDate" = CURRENT_TIMESTAMP,
                "FSWO_WaivedOffRemarks" = "FSWO_WaivedOffRemarks",
                "FSWO_WaivedOfffilepath" = "flepath",
                "FSWO_WaivedOfffilename" = "flenme"
            WHERE "FSWO_Id" = "FSWO_ID";
        ELSE
            IF "finewaivoff" = 0 THEN
                UPDATE "Fee_Student_Status" 
                SET "FSS_TotalToBePaid" = ("FSS_TotalToBePaid" - "waivedamountnew"),
                    "FSS_ToBePaid" = ("FSS_ToBePaid" - "waivedamountnew"),
                    "FSS_ExcessPaidAmount" = "FSS_ExcessPaidAmount",
                    "FSS_RunningExcessAmount" = "FSS_RunningExcessAmount",
                    "FSS_WaivedAmount" = "waivedamountnew"
                WHERE "MI_Id" = "miid" AND "ASMAY_Id" = "asmayid" AND "AMST_Id" = "amstid" AND "FMG_Id" = "FMG_id" 
                    AND "FMH_Id" = "FMH_id" AND "FTI_Id" = "FTI_id" AND "FMA_Id" = "FMA_id" AND "user_id" = "userid";
            END IF;
            
            UPDATE "Fee_Student_Waived_Off" 
            SET "FSWO_WaivedOffAmount" = "waivedamountnew",
                "UpdatedDate" = CURRENT_TIMESTAMP,
                "FSWO_WaivedOffRemarks" = "FSWO_WaivedOffRemarks",
                "FSWO_WaivedOfffilepath" = "flepath",
                "FSWO_WaivedOfffilename" = "flenme"
            WHERE "FSWO_Id" = "FSWO_ID";
        END IF;
    ELSE
        SELECT "FMH_RefundFlag" INTO "FMH_RefundFlag" FROM "Fee_Master_Head" WHERE "FMH_Id" = "FMH_id";
        
        IF ("FMH_RefundFlag" = true) THEN
            IF "finewaivoff" = 0 THEN
                UPDATE "Fee_Student_Status" 
                SET "FSS_TotalToBePaid" = 0,
                    "FSS_ToBePaid" = 0,
                    "FSS_ExcessPaidAmount" = ("FSS_ExcessPaidAmount" + "totalval"),
                    "FSS_RefundableAmount" = ("FSS_RefundableAmount" + "totalval"),
                    "FSS_WaivedAmount" = "waivedamountnew"
                WHERE "MI_Id" = "miid" AND "ASMAY_Id" = "asmayid" AND "AMST_Id" = "amstid" AND "FMG_Id" = "FMG_id" 
                    AND "FMH_Id" = "FMH_id" AND "FTI_Id" = "FTI_id" AND "FMA_Id" = "FMA_id" AND "user_id" = "userid";
            END IF;
            
            UPDATE "Fee_Student_Waived_Off" 
            SET "FSWO_WaivedOffAmount" = "waivedamountnew",
                "UpdatedDate" = CURRENT_TIMESTAMP,
                "FSWO_WaivedOffRemarks" = "FSWO_WaivedOffRemarks",
                "FSWO_WaivedOfffilepath" = "flepath",
                "FSWO_WaivedOfffilename" = "flenme"
            WHERE "FSWO_Id" = "FSWO_ID";
        ELSE
            IF "finewaivoff" = 0 THEN
                UPDATE "Fee_Student_Status" 
                SET "FSS_TotalToBePaid" = 0,
                    "FSS_ToBePaid" = 0,
                    "FSS_ExcessPaidAmount" = ("FSS_ExcessPaidAmount" + "totalval"),
                    "FSS_RunningExcessAmount" = ("FSS_RunningExcessAmount" + "totalval"),
                    "FSS_WaivedAmount" = "waivedamountnew"
                WHERE "MI_Id" = "miid" AND "ASMAY_Id" = "asmayid" AND "AMST_Id" = "amstid" AND "FMG_Id" = "FMG_id" 
                    AND "FMH_Id" = "FMH_id" AND "FTI_Id" = "FTI_id" AND "FMA_Id" = "FMA_id" AND "user_id" = "userid";
            END IF;
            
            UPDATE "Fee_Student_Waived_Off" 
            SET "FSWO_WaivedOffAmount" = "waivedamountnew",
                "UpdatedDate" = CURRENT_TIMESTAMP,
                "FSWO_WaivedOffRemarks" = "FSWO_WaivedOffRemarks",
                "FSWO_WaivedOfffilepath" = "flepath",
                "FSWO_WaivedOfffilename" = "flenme"
            WHERE "FSWO_Id" = "FSWO_ID";
        END IF;
    END IF;

    RETURN;
END;
$$;