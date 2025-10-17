CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Waived_Off_insert"(
    p_miid bigint,
    p_asmayid bigint,
    p_amstid bigint,
    p_FMG_id bigint,
    p_FMH_id bigint,
    p_FTI_id bigint,
    p_FMA_id bigint,
    p_Waivedamount bigint,
    p_fswodate timestamp,
    p_userid bigint,
    p_finewaivedoff boolean,
    p_FSWO_WaivedOffRemarks text,
    p_completefinewaivedoff boolean,
    p_flepath text,
    p_flenme text
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FSS_ToBePaid bigint;
    v_totalval bigint;
    v_FMH_RefundFlag boolean;
BEGIN
    SELECT "FSS_ToBePaid" INTO v_FSS_ToBePaid 
    FROM "Fee_Student_Status"  
    WHERE "MI_Id" = p_miid 
        AND "ASMAY_Id" = p_asmayid 
        AND "AMST_Id" = p_amstid 
        AND "FMG_Id" = p_FMG_id 
        AND "FMH_Id" = p_FMH_id 
        AND "FTI_Id" = p_FTI_id 
        AND "FMA_Id" = p_FMA_id 
        AND "user_id" = p_userid;
    
    IF (v_FSS_ToBePaid >= p_Waivedamount) THEN
        IF p_finewaivedoff = false THEN
            UPDATE "Fee_Student_Status" 
            SET "FSS_TotalToBePaid" = ("FSS_TotalToBePaid" - p_Waivedamount),
                "FSS_ToBePaid" = ("FSS_ToBePaid" - p_Waivedamount),
                "FSS_WaivedAmount" = p_Waivedamount 
            WHERE "MI_Id" = p_miid 
                AND "ASMAY_Id" = p_asmayid 
                AND "AMST_Id" = p_amstid 
                AND "FMG_Id" = p_FMG_id 
                AND "FMH_Id" = p_FMH_id 
                AND "FTI_Id" = p_FTI_id 
                AND "FMA_Id" = p_FMA_id 
                AND "user_id" = p_userid;
        END IF;
        
        INSERT INTO "Fee_Student_Waived_Off" (
            "MI_Id", "ASMAY_Id", "AMST_Id", "FSWO_Date", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
            "FSWO_WaivedOffAmount", "FSWO_ActiveFlag", "CreatedDate", "UpdatedDate", "User_id",
            "FSWO_FineFlg", "FSWO_WaivedOffRemarks", "FSWO_FullFineWaiveOffFlg",
            "FSWO_WaivedOfffilename", "FSWO_WaivedOfffilepath"
        ) VALUES (
            p_miid, p_asmayid, p_amstid, p_fswodate, p_FMG_id, p_FMH_id, p_FTI_id, p_FMA_id,
            p_Waivedamount, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid,
            p_finewaivedoff, p_FSWO_WaivedOffRemarks, p_completefinewaivedoff, p_flenme, p_flepath
        );
    ELSE
        v_totalval := p_Waivedamount - v_FSS_ToBePaid;
        
        SELECT "FMH_RefundFlag" INTO v_FMH_RefundFlag 
        FROM "Fee_Master_Head" 
        WHERE "FMH_Id" = p_FMH_id;
        
        IF (v_FMH_RefundFlag = true) THEN
            IF p_finewaivedoff = false THEN
                UPDATE "Fee_Student_Status" 
                SET "FSS_ToBePaid" = 0,
                    "FSS_ExcessPaidAmount" = ("FSS_ExcessPaidAmount" + v_totalval),
                    "FSS_RefundableAmount" = ("FSS_RefundableAmount" + v_totalval),
                    "FSS_WaivedAmount" = p_Waivedamount 
                WHERE "MI_Id" = p_miid 
                    AND "ASMAY_Id" = p_asmayid 
                    AND "AMST_Id" = p_amstid 
                    AND "FMG_Id" = p_FMG_id 
                    AND "FMH_Id" = p_FMH_id 
                    AND "FTI_Id" = p_FTI_id 
                    AND "FMA_Id" = p_FMA_id 
                    AND "user_id" = p_userid;
            END IF;
            
            INSERT INTO "Fee_Student_Waived_Off" (
                "MI_Id", "ASMAY_Id", "AMST_Id", "FSWO_Date", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
                "FSWO_WaivedOffAmount", "FSWO_ActiveFlag", "CreatedDate", "UpdatedDate", "User_id",
                "FSWO_FineFlg", "FSWO_WaivedOffRemarks", "FSWO_FullFineWaiveOffFlg",
                "FSWO_WaivedOfffilename", "FSWO_WaivedOfffilepath"
            ) VALUES (
                p_miid, p_asmayid, p_amstid, p_fswodate, p_FMG_id, p_FMH_id, p_FTI_id, p_FMA_id,
                p_Waivedamount, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid,
                p_finewaivedoff, p_FSWO_WaivedOffRemarks, p_completefinewaivedoff, p_flenme, p_flepath
            );
        ELSE
            IF p_finewaivedoff = false THEN
                UPDATE "Fee_Student_Status" 
                SET "FSS_ExcessPaidAmount" = ("FSS_ExcessPaidAmount" + v_totalval),
                    "FSS_RunningExcessAmount" = ("FSS_RunningExcessAmount" + v_totalval),
                    "FSS_WaivedAmount" = p_Waivedamount 
                WHERE "MI_Id" = p_miid 
                    AND "ASMAY_Id" = p_asmayid 
                    AND "AMST_Id" = p_amstid 
                    AND "FMG_Id" = p_FMG_id 
                    AND "FMH_Id" = p_FMH_id 
                    AND "FTI_Id" = p_FTI_id 
                    AND "FMA_Id" = p_FMA_id 
                    AND "user_id" = p_userid;
            END IF;
            
            INSERT INTO "Fee_Student_Waived_Off" (
                "MI_Id", "ASMAY_Id", "AMST_Id", "FSWO_Date", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
                "FSWO_WaivedOffAmount", "FSWO_ActiveFlag", "CreatedDate", "UpdatedDate", "User_id",
                "FSWO_FineFlg", "FSWO_WaivedOffRemarks", "FSWO_FullFineWaiveOffFlg",
                "FSWO_WaivedOfffilename", "FSWO_WaivedOfffilepath"
            ) VALUES (
                p_miid, p_asmayid, p_amstid, p_fswodate, p_FMG_id, p_FMH_id, p_FTI_id, p_FMA_id,
                p_Waivedamount, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid,
                p_finewaivedoff, p_FSWO_WaivedOffRemarks, p_completefinewaivedoff, p_flenme, p_flepath
            );
        END IF;
    END IF;
    
    RETURN;
END;
$$;