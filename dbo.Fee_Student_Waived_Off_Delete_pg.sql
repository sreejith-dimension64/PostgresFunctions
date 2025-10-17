CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Waived_Off_Delete"(
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
    v_FSS_TotalToBePaid bigint;
BEGIN

    SELECT "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSWO_WaivedOffAmount", "USER_ID"
    INTO v_miid, v_asmayid, v_amstid, v_FMG_id, v_FMH_id, v_FTI_id, v_FMA_id, v_Waivedamount, v_userid
    FROM "dbo"."Fee_Student_Waived_Off"
    WHERE "FSWO_Id" = p_FSWO_ID;

    SELECT "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_ExcessPaidAmount", "FSS_RefundableAmount", "FSS_RunningExcessAmount"
    INTO v_FSS_TotalToBePaid, v_FSS_ToBePaid, v_FSS_ExcessPaidAmount, v_FSS_RefundableAmount, v_FSS_RunningExcessAmount
    FROM "dbo"."Fee_Student_Status"
    WHERE "MI_Id" = v_miid 
        AND "ASMAY_Id" = v_asmayid 
        AND "AMST_Id" = v_amstid 
        AND "FMG_Id" = v_FMG_id 
        AND "FMH_Id" = v_FMH_id 
        AND "FTI_Id" = v_FTI_id 
        AND "FMA_Id" = v_FMA_id 
        AND "user_id" = v_userid;

    IF (v_FSS_ExcessPaidAmount = 0) THEN
        UPDATE "dbo"."Fee_Student_Status" 
        SET "FSS_TotalToBePaid" = ("FSS_TotalToBePaid" + v_Waivedamount),
            "FSS_ToBePaid" = ("FSS_ToBePaid" + v_Waivedamount),
            "FSS_WaivedAmount" = ("FSS_WaivedAmount" - v_Waivedamount)
        WHERE "MI_Id" = v_miid 
            AND "ASMAY_Id" = v_asmayid 
            AND "AMST_Id" = v_amstid 
            AND "FMG_Id" = v_FMG_id 
            AND "FMH_Id" = v_FMH_id 
            AND "FTI_Id" = v_FTI_id 
            AND "FMA_Id" = v_FMA_id 
            AND "user_id" = v_userid;

        DELETE FROM "dbo"."Fee_Student_Waived_Off" WHERE "FSWO_ID" = p_FSWO_ID;
    ELSE
        SELECT "FMH_RefundFlag" 
        INTO v_FMH_RefundFlag 
        FROM "dbo"."Fee_Master_Head" 
        WHERE "FMH_Id" = v_FMH_id;

        IF (v_FMH_RefundFlag = true) THEN
            IF (v_FSS_ExcessPaidAmount <= v_FSS_RefundableAmount) THEN
                v_FSS_ToBePaid := v_Waivedamount - v_FSS_ExcessPaidAmount;
                v_FSS_RefundableAmount := v_FSS_RefundableAmount - v_FSS_ExcessPaidAmount;
                v_FSS_ExcessPaidAmount := 0;

                UPDATE "dbo"."Fee_Student_Status" 
                SET "FSS_TotalToBePaid" = v_FSS_TotalToBePaid,
                    "FSS_ToBePaid" = v_FSS_ToBePaid,
                    "FSS_ExcessPaidAmount" = v_FSS_ExcessPaidAmount,
                    "FSS_RefundableAmount" = v_FSS_RefundableAmount,
                    "FSS_WaivedAmount" = 0
                WHERE "MI_Id" = v_miid 
                    AND "ASMAY_Id" = v_asmayid 
                    AND "AMST_Id" = v_amstid 
                    AND "FMG_Id" = v_FMG_id 
                    AND "FMH_Id" = v_FMH_id 
                    AND "FTI_Id" = v_FTI_id 
                    AND "FMA_Id" = v_FMA_id 
                    AND "user_id" = v_userid;

                DELETE FROM "dbo"."Fee_Student_Waived_Off" WHERE "FSWO_ID" = p_FSWO_ID;
            END IF;
        ELSE
            IF (v_FSS_ExcessPaidAmount <= v_FSS_RunningExcessAmount) THEN
                v_FSS_ToBePaid := v_Waivedamount - v_FSS_ExcessPaidAmount;
                v_FSS_RunningExcessAmount := v_FSS_RunningExcessAmount - v_FSS_ExcessPaidAmount;
                v_FSS_ExcessPaidAmount := 0;

                UPDATE "dbo"."Fee_Student_Status" 
                SET "FSS_TotalToBePaid" = v_FSS_TotalToBePaid,
                    "FSS_ToBePaid" = v_FSS_ToBePaid,
                    "FSS_ExcessPaidAmount" = v_FSS_ExcessPaidAmount,
                    "FSS_RunningExcessAmount" = v_FSS_RunningExcessAmount,
                    "FSS_WaivedAmount" = 0
                WHERE "MI_Id" = v_miid 
                    AND "ASMAY_Id" = v_asmayid 
                    AND "AMST_Id" = v_amstid 
                    AND "FMG_Id" = v_FMG_id 
                    AND "FMH_Id" = v_FMH_id 
                    AND "FTI_Id" = v_FTI_id 
                    AND "FMA_Id" = v_FMA_id 
                    AND "user_id" = v_userid;

                DELETE FROM "dbo"."Fee_Student_Waived_Off" WHERE "FSWO_ID" = p_FSWO_ID;
            END IF;
        END IF;
    END IF;

    RETURN;
END;
$$;