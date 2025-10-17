CREATE OR REPLACE FUNCTION "dbo"."CLG_Fee_Student_Waived_Off_Delete"(
    p_FSWO_ID bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_miid bigint;
    v_asmayid bigint;
    v_amstid bigint;
    v_FMG_id bigint;
    v_FMH_id bigint;
    v_FTI_id bigint;
    v_FMA_id bigint;
    v_userid bigint;
    v_Waivedamount bigint;
    v_FSS_ToBePaid bigint;
    v_FSS_ExcessPaidAmount bigint;
    v_FSS_RefundableAmount bigint;
    v_FSS_RunningExcessAmount bigint;
    v_totalval bigint;
    v_FMH_RefundFlag boolean;
BEGIN

    SELECT "MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", "FCSWO_WaivedOffAmount", "USER_Id"
    INTO v_miid, v_asmayid, v_amstid, v_FMG_id, v_FMH_id, v_FTI_id, v_FMA_id, v_Waivedamount, v_userid
    FROM "CLG"."Fee_College_Student_WaivedOff"
    WHERE "FCSWO_Id" = p_FSWO_ID;

    SELECT "FCSS_ToBePaid", "FCSS_ExcessPaidAmount", "FCSS_RefundableAmount", "FCSS_RunningExcessAmount"
    INTO v_FSS_ToBePaid, v_FSS_ExcessPaidAmount, v_FSS_RefundableAmount, v_FSS_RunningExcessAmount
    FROM "CLG"."Fee_College_Student_Status"
    WHERE "MI_Id" = v_miid 
        AND "ASMAY_Id" = v_asmayid 
        AND "AMCST_Id" = v_amstid 
        AND "FMG_Id" = v_FMG_id 
        AND "FMH_Id" = v_FMH_id 
        AND "FTI_Id" = v_FTI_id 
        AND "FCMAS_Id" = v_FMA_id 
        AND "user_id" = v_userid;

    IF (v_FSS_ExcessPaidAmount = 0) THEN
        UPDATE "CLG"."Fee_College_Student_Status"
        SET "FCSS_ToBePaid" = ("FCSS_ToBePaid" + v_Waivedamount),
            "FCSS_WaivedAmount" = ("FCSS_WaivedAmount" - v_Waivedamount)
        WHERE "MI_Id" = v_miid 
            AND "ASMAY_Id" = v_asmayid 
            AND "AMCST_Id" = v_amstid 
            AND "FMG_Id" = v_FMG_id 
            AND "FMH_Id" = v_FMH_id 
            AND "FTI_Id" = v_FTI_id 
            AND "FCMAS_Id" = v_FMA_id 
            AND "user_id" = v_userid;

        DELETE FROM "CLG"."Fee_College_Student_WaivedOff" 
        WHERE "FCSWO_ID" = p_FSWO_ID;
    ELSE
        SELECT "FMH_RefundFlag"
        INTO v_FMH_RefundFlag
        FROM "Fee_Master_Head"
        WHERE "FMH_Id" = v_FMH_id;

        IF (v_FMH_RefundFlag = true) THEN
            IF (v_FSS_ExcessPaidAmount <= v_FSS_RefundableAmount) THEN
                v_FSS_ToBePaid := v_Waivedamount - v_FSS_ExcessPaidAmount;
                v_FSS_RefundableAmount := v_FSS_RefundableAmount - v_FSS_ExcessPaidAmount;
                v_FSS_ExcessPaidAmount := 0;

                UPDATE "CLG"."Fee_College_Student_Status"
                SET "FCSS_ToBePaid" = v_FSS_ToBePaid,
                    "FCSS_ExcessPaidAmount" = v_FSS_ExcessPaidAmount,
                    "FCSS_RefundableAmount" = v_FSS_RefundableAmount,
                    "FCSS_WaivedAmount" = 0
                WHERE "MI_Id" = v_miid 
                    AND "ASMAY_Id" = v_asmayid 
                    AND "AMCST_Id" = v_amstid 
                    AND "FMG_Id" = v_FMG_id 
                    AND "FMH_Id" = v_FMH_id 
                    AND "FTI_Id" = v_FTI_id 
                    AND "FCMAS_Id" = v_FMA_id 
                    AND "user_id" = v_userid;

                DELETE FROM "CLG"."Fee_College_Student_WaivedOff" 
                WHERE "FCSWO_ID" = p_FSWO_ID;
            END IF;
        ELSE
            IF (v_FSS_ExcessPaidAmount <= v_FSS_RunningExcessAmount) THEN
                v_FSS_ToBePaid := v_Waivedamount - v_FSS_ExcessPaidAmount;
                v_FSS_RunningExcessAmount := v_FSS_RunningExcessAmount - v_FSS_ExcessPaidAmount;
                v_FSS_ExcessPaidAmount := 0;

                UPDATE "CLG"."Fee_College_Student_Status"
                SET "FCSS_ToBePaid" = v_FSS_ToBePaid,
                    "FCSS_ExcessPaidAmount" = v_FSS_ExcessPaidAmount,
                    "FCSS_RunningExcessAmount" = v_FSS_RunningExcessAmount,
                    "FCSS_WaivedAmount" = 0
                WHERE "MI_Id" = v_miid 
                    AND "ASMAY_Id" = v_asmayid 
                    AND "AMCST_Id" = v_amstid 
                    AND "FMG_Id" = v_FMG_id 
                    AND "FMH_Id" = v_FMH_id 
                    AND "FTI_Id" = v_FTI_id 
                    AND "FCMAS_Id" = v_FMA_id 
                    AND "user_id" = v_userid;

                DELETE FROM "CLG"."Fee_College_Student_WaivedOff" 
                WHERE "FCSWO_ID" = p_FSWO_ID;
            END IF;
        END IF;
    END IF;

END;
$$;