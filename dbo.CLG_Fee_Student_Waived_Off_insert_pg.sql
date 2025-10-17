CREATE OR REPLACE FUNCTION "dbo"."CLG_Fee_Student_Waived_Off_insert"(
    p_miid bigint,
    p_asmayid bigint,
    p_amstid bigint,
    p_FMG_id bigint,
    p_FMH_id bigint,
    p_FTI_id bigint,
    p_FMA_id bigint,
    p_Waivedamount bigint,
    p_fswodate timestamp,
    p_userid bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FSS_ToBePaid bigint;
    v_totalval bigint;
    v_FMH_RefundFlag boolean;
BEGIN
    SELECT "FCSS_ToBePaid" INTO v_FSS_ToBePaid 
    FROM "CLG"."Fee_College_Student_Status"  
    WHERE "MI_Id" = p_miid 
        AND "ASMAY_Id" = p_asmayid 
        AND "AMCST_Id" = p_amstid 
        AND "FMG_Id" = p_FMG_id 
        AND "FMH_Id" = p_FMH_id 
        AND "FTI_Id" = p_FTI_id 
        AND "FCMAS_Id" = p_FMA_id 
        AND "user_id" = p_userid;

    IF (v_FSS_ToBePaid >= p_Waivedamount) THEN
        UPDATE "CLG"."Fee_College_Student_Status" 
        SET "FCSS_ToBePaid" = ("FCSS_ToBePaid" - p_Waivedamount), 
            "FCSS_WaivedAmount" = p_Waivedamount 
        WHERE "MI_Id" = p_miid 
            AND "ASMAY_Id" = p_asmayid 
            AND "AMCST_Id" = p_amstid 
            AND "FMG_Id" = p_FMG_id 
            AND "FMH_Id" = p_FMH_id 
            AND "FTI_Id" = p_FTI_id 
            AND "FCMAS_Id" = p_FMA_id 
            AND "user_id" = p_userid;

        INSERT INTO "CLG"."Fee_College_Student_WaivedOff" 
            ("MI_Id", "ASMAY_Id", "AMCST_Id", "FCSWO_Date", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", "FCSWO_WaivedOffAmount", "FCSWO_ActiveFlag", "User_Id") 
        VALUES 
            (p_miid, p_asmayid, p_amstid, p_fswodate, p_FMG_id, p_FMH_id, p_FTI_id, p_FMA_id, p_Waivedamount, true, p_userid);
    ELSE
        v_totalval := p_Waivedamount - v_FSS_ToBePaid;
        
        SELECT "FMH_RefundFlag" INTO v_FMH_RefundFlag 
        FROM "Fee_Master_Head" 
        WHERE "FMH_Id" = p_FMH_id;

        IF (v_FMH_RefundFlag = true) THEN
            UPDATE "CLG"."Fee_College_Student_Status" 
            SET "FCSS_ToBePaid" = 0, 
                "FCSS_ExcessPaidAmount" = ("FCSS_ExcessPaidAmount" + v_totalval),
                "FCSS_RefundableAmount" = ("FCSS_RefundableAmount" + v_totalval), 
                "FCSS_WaivedAmount" = p_Waivedamount 
            WHERE "MI_Id" = p_miid 
                AND "ASMAY_Id" = p_asmayid 
                AND "AMCST_Id" = p_amstid 
                AND "FMG_Id" = p_FMG_id 
                AND "FMH_Id" = p_FMH_id 
                AND "FTI_Id" = p_FTI_id 
                AND "FCMAS_Id" = p_FMA_id 
                AND "user_id" = p_userid;

            INSERT INTO "CLG"."Fee_College_Student_WaivedOff" 
                ("MI_Id", "ASMAY_Id", "AMCST_Id", "FCSWO_Date", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", "FCSWO_WaivedOffAmount", "FCSWO_ActiveFlag", "User_Id") 
            VALUES 
                (p_miid, p_asmayid, p_amstid, p_fswodate, p_FMG_id, p_FMH_id, p_FTI_id, p_FMA_id, p_Waivedamount, true, p_userid);
        ELSE
            UPDATE "CLG"."Fee_College_Student_Status" 
            SET "FCSS_ExcessPaidAmount" = ("FCSS_ExcessPaidAmount" + v_totalval),
                "FCSS_RunningExcessAmount" = ("FCSS_RunningExcessAmount" + v_totalval), 
                "FCSS_WaivedAmount" = p_Waivedamount 
            WHERE "MI_Id" = p_miid 
                AND "ASMAY_Id" = p_asmayid 
                AND "AMCST_Id" = p_amstid 
                AND "FMG_Id" = p_FMG_id 
                AND "FMH_Id" = p_FMH_id 
                AND "FTI_Id" = p_FTI_id 
                AND "FCMAS_Id" = p_FMA_id 
                AND "user_id" = p_userid;

            INSERT INTO "CLG"."Fee_College_Student_WaivedOff" 
                ("MI_Id", "ASMAY_Id", "AMCST_Id", "FCSWO_Date", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", "FCSWO_WaivedOffAmount", "FCSWO_ActiveFlag", "User_Id") 
            VALUES 
                (p_miid, p_asmayid, p_amstid, p_fswodate, p_FMG_id, p_FMH_id, p_FTI_id, p_FMA_id, p_Waivedamount, true, p_userid);
        END IF;
    END IF;

    RETURN;
END;
$$;