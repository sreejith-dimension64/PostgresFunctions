CREATE OR REPLACE FUNCTION "dbo"."CLG_Fee_Student_Waived_Off_Edit"(
    "p_FSWO_ID" bigint,
    "p_waivedamountnew" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_miid" bigint;
    "v_asmayid" bigint;
    "v_amstid" bigint;
    "v_FMG_id" bigint;
    "v_FMH_id" bigint;
    "v_FTI_id" bigint;
    "v_FMA_id" bigint;
    "v_userid" bigint;
    "v_Waivedamount" bigint;
    "v_FSS_ToBePaid" bigint;
    "v_FSS_ExcessPaidAmount" bigint;
    "v_FSS_RefundableAmount" bigint;
    "v_FSS_RunningExcessAmount" bigint;
    "v_totalval" bigint;
    "v_FMH_RefundFlag" boolean;
BEGIN
    SELECT "MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", "FCSWO_WaivedOffAmount", "USER_Id"
    INTO "v_miid", "v_asmayid", "v_amstid", "v_FMG_id", "v_FMH_id", "v_FTI_id", "v_FMA_id", "v_Waivedamount", "v_userid"
    FROM "CLG"."Fee_College_Student_WaivedOff"
    WHERE "FCSWO_Id" = "p_FSWO_ID";

    SELECT "FCSS_ToBePaid", "FCSS_ExcessPaidAmount", "FCSS_RefundableAmount", "FCSS_RunningExcessAmount"
    INTO "v_FSS_ToBePaid", "v_FSS_ExcessPaidAmount", "v_FSS_RefundableAmount", "v_FSS_RunningExcessAmount"
    FROM "CLG"."Fee_College_Student_Status"
    WHERE "MI_Id" = "v_miid" 
        AND "ASMAY_Id" = "v_asmayid" 
        AND "AMCST_Id" = "v_amstid" 
        AND "FMG_Id" = "v_FMG_id" 
        AND "FMH_Id" = "v_FMH_id" 
        AND "FTI_Id" = "v_FTI_id" 
        AND "FCMAS_Id" = "v_FMA_id" 
        AND "user_id" = "v_userid";

    "v_FSS_ToBePaid" := ("v_FSS_ToBePaid" + "v_Waivedamount") - "v_FSS_ExcessPaidAmount";
    "v_FSS_RefundableAmount" := "v_FSS_RefundableAmount" - "v_FSS_ExcessPaidAmount";
    "v_FSS_RunningExcessAmount" := "v_FSS_RunningExcessAmount" - "v_FSS_ExcessPaidAmount";
    "v_FSS_ExcessPaidAmount" := 0;
    "v_totalval" := "p_waivedamountnew" - "v_FSS_ToBePaid";

    IF ("v_FSS_ToBePaid" >= "p_waivedamountnew") THEN
        SELECT "FMH_RefundFlag"
        INTO "v_FMH_RefundFlag"
        FROM "Fee_Master_Head"
        WHERE "FMH_Id" = "v_FMH_id";

        IF ("v_FMH_RefundFlag" = true) THEN
            UPDATE "CLG"."Fee_College_Student_Status"
            SET "FCSS_ToBePaid" = ("v_FSS_ToBePaid" - "p_waivedamountnew"),
                "FCSS_ExcessPaidAmount" = "v_FSS_ExcessPaidAmount",
                "FCSS_RefundableAmount" = "v_FSS_RefundableAmount",
                "FCSS_WaivedAmount" = "p_waivedamountnew"
            WHERE "MI_Id" = "v_miid" 
                AND "ASMAY_Id" = "v_asmayid" 
                AND "AMCST_Id" = "v_amstid" 
                AND "FMG_Id" = "v_FMG_id" 
                AND "FMH_Id" = "v_FMH_id" 
                AND "FTI_Id" = "v_FTI_id" 
                AND "FCMAS_Id" = "v_FMA_id" 
                AND "user_id" = "v_userid";

            UPDATE "CLG"."Fee_College_Student_WaivedOff"
            SET "FCSWO_WaivedOffAmount" = "p_waivedamountnew"
            WHERE "FCSWO_Id" = "p_FSWO_ID";
        ELSE
            UPDATE "CLG"."Fee_College_Student_Status"
            SET "FCSS_ToBePaid" = ("v_FSS_ToBePaid" - "p_waivedamountnew"),
                "FCSS_ExcessPaidAmount" = "v_FSS_ExcessPaidAmount",
                "FCSS_RunningExcessAmount" = "v_FSS_RunningExcessAmount",
                "FCSS_WaivedAmount" = "p_waivedamountnew"
            WHERE "MI_Id" = "v_miid" 
                AND "ASMAY_Id" = "v_asmayid" 
                AND "AMCST_Id" = "v_amstid" 
                AND "FMG_Id" = "v_FMG_id" 
                AND "FMH_Id" = "v_FMH_id" 
                AND "FTI_Id" = "v_FTI_id" 
                AND "FCMAS_Id" = "v_FMA_id" 
                AND "user_id" = "v_userid";

            UPDATE "CLG"."Fee_College_Student_WaivedOff"
            SET "FCSWO_WaivedOffAmount" = "p_waivedamountnew"
            WHERE "FCSWO_Id" = "p_FSWO_ID";
        END IF;
    ELSE
        SELECT "FMH_RefundFlag"
        INTO "v_FMH_RefundFlag"
        FROM "Fee_Master_Head"
        WHERE "FMH_Id" = "v_FMH_id";

        IF ("v_FMH_RefundFlag" = true) THEN
            UPDATE "CLG"."Fee_College_Student_Status"
            SET "FCSS_ToBePaid" = 0,
                "FCSS_ExcessPaidAmount" = ("FCSS_ExcessPaidAmount" - "v_Waivedamount" + "v_totalval"),
                "FCSS_RefundableAmount" = ("FCSS_RefundableAmount" - "v_Waivedamount" + "v_totalval"),
                "FCSS_WaivedAmount" = "p_waivedamountnew"
            WHERE "MI_Id" = "v_miid" 
                AND "ASMAY_Id" = "v_asmayid" 
                AND "AMCST_Id" = "v_amstid" 
                AND "FMG_Id" = "v_FMG_id" 
                AND "FMH_Id" = "v_FMH_id" 
                AND "FTI_Id" = "v_FTI_id" 
                AND "FCMAS_Id" = "v_FMA_id" 
                AND "user_id" = "v_userid";

            UPDATE "CLG"."Fee_College_Student_WaivedOff"
            SET "FCSWO_WaivedOffAmount" = "p_waivedamountnew"
            WHERE "FCSWO_Id" = "p_FSWO_ID";
        ELSE
            UPDATE "CLG"."Fee_College_Student_Status"
            SET "FCSS_ToBePaid" = 0,
                "FCSS_ExcessPaidAmount" = ("FCSS_ExcessPaidAmount" - "v_Waivedamount" + "v_totalval"),
                "FCSS_RunningExcessAmount" = ("FCSS_RunningExcessAmount" - "v_Waivedamount" + "v_totalval"),
                "FCSS_WaivedAmount" = "p_waivedamountnew"
            WHERE "MI_Id" = "v_miid" 
                AND "ASMAY_Id" = "v_asmayid" 
                AND "AMCST_Id" = "v_amstid" 
                AND "FMG_Id" = "v_FMG_id" 
                AND "FMH_Id" = "v_FMH_id" 
                AND "FTI_Id" = "v_FTI_id" 
                AND "FCMAS_Id" = "v_FMA_id" 
                AND "user_id" = "v_userid";

            UPDATE "CLG"."Fee_College_Student_WaivedOff"
            SET "FCSWO_WaivedOffAmount" = "p_waivedamountnew"
            WHERE "FCSWO_Id" = "p_FSWO_ID";
        END IF;
    END IF;

    RETURN;
END;
$$;