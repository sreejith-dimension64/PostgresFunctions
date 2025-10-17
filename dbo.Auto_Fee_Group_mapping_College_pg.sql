CREATE OR REPLACE FUNCTION "dbo"."Auto_Fee_Group_mapping_College"(
    p_MI_Id bigint,
    p_ASMAY_ID bigint,
    p_AMCST_ID bigint,
    p_userid bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMCO_Id bigint;
    v_AMB_Id bigint;
    v_AMSE_Id bigint;
    v_FCMA_Id bigint;
    v_fti_name varchar(100);
    v_FCMAS_Amount decimal(18,2);
    v_fmh_name varchar(100);
    v_fmg_id bigint;
    v_fmsgid bigint;
    v_ftp_concession_amt bigint;
    v_fmh_id bigint;
    v_fti_id bigint;
    v_Rcount bigint;
    v_FCMSGH_Id bigint;
    v_FCMAS_Id bigint;
    v_AMCST_ID bigint;
    v_userid bigint;
    rec_yearly_fee RECORD;
    rec_feeinstallment RECORD;
BEGIN
    v_fti_name := '';
    v_FCMAS_Amount := 0;
    v_fmh_name := '';
    v_ftp_concession_amt := 0;

    SELECT "FMG_Id", "user_id" INTO v_fmg_id, v_userid
    FROM "Fee_Master_Group"
    WHERE "MI_Id" = p_MI_Id AND "FMG_CompulsoryFlag" = 'R';

    FOR rec_yearly_fee IN 
        SELECT DISTINCT "AMCST_Id"
        FROM "CLG"."Adm_Master_College_Student"
        WHERE "ASMAY_Id" = p_ASMAY_ID AND p_AMCST_ID = p_AMCST_ID
    LOOP
        v_AMCST_ID := rec_yearly_fee."AMCST_Id";

        SELECT COUNT(*) INTO v_Rcount
        FROM "CLG"."Fee_College_Master_Student_GroupHead"
        WHERE "FMG_Id" = v_fmg_id 
            AND "MI_Id" = p_MI_Id 
            AND "AMCST_Id" = v_AMCST_ID 
            AND "ASMAY_Id" = p_ASMAY_ID;

        IF v_Rcount = 0 THEN

            INSERT INTO "CLG"."Fee_College_Master_Student_GroupHead" 
                ("MI_Id", "AMCST_Id", "ASMAY_Id", "FMG_Id", "FCMSGH_ActiveFlag")
            VALUES 
                (p_MI_Id, v_AMCST_ID, p_ASMAY_ID, v_fmg_id, 'Y');

            SELECT MAX("FCMSGH_Id") INTO v_FCMSGH_Id
            FROM "CLG"."Fee_College_Master_Student_GroupHead"
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_ID 
                AND "FMG_Id" = v_fmg_id 
                AND "FCMSGH_ActiveFlag" = 'Y';

            SELECT "AMCO_Id", "AMB_Id", "AMSE_Id" 
            INTO v_AMCO_Id, v_AMB_Id, v_AMSE_Id
            FROM "CLG"."Adm_Master_College_Student"
            WHERE "AMCST_Id" = v_AMCST_ID AND "ASMAY_Id" = p_ASMAY_ID;

            FOR rec_feeinstallment IN
                SELECT "FMH_Id", "FTI_Id", FS."FCMAS_Id", "FCMAS_Amount"
                FROM "CLG"."Fee_College_Master_Amount" FA
                INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" FS 
                    ON FA."FCMA_Id" = FS."FCMA_Id" 
                    AND FA."AMCO_Id" = v_AMCO_Id 
                    AND FA."AMB_Id" = v_AMB_Id 
                    AND FS."AMSE_Id" = v_AMSE_Id
                WHERE "FMG_Id" = v_fmg_id 
                    AND "ASMAY_Id" = p_ASMAY_ID 
                    AND FA."MI_Id" = p_MI_Id 
                    AND FA."MI_Id" = p_MI_Id
            LOOP
                v_fmh_id := rec_feeinstallment."FMH_Id";
                v_fti_id := rec_feeinstallment."FTI_Id";
                v_FCMAS_Id := rec_feeinstallment."FCMAS_Id";
                v_FCMAS_Amount := rec_feeinstallment."FCMAS_Amount";

                INSERT INTO "CLG"."Fee_C_Master_Student_GroupHead_Installments" 
                    ("FCMSGH_Id", "FMH_ID", "FTI_ID")
                VALUES 
                    (v_FCMSGH_Id, v_fmh_id, v_fti_id);

                INSERT INTO "CLG"."Fee_College_Student_Status"
                    ("MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id",
                     "FCSS_OBArrearAmount", "FCSS_OBExcessAmount", "FCSS_CurrentYrCharges", 
                     "FCSS_TotalCharges", "FCSS_ToBePaid", "FCSS_PaidAmount", "FCSS_ExcessPaidAmount",
                     "FCSS_ExcessAmountAdjusted", "FCSS_RunningExcessAmount", "FCSS_ConcessionAmount",
                     "FCSS_AdjustedAmount", "FCSS_WaivedAmount", "FCSS_RebateAmount", "FCSS_FineAmount",
                     "FCSS_RefundAmount", "FCSS_RefundAmountAdjusted", "FCSS_NetAmount", 
                     "FCSS_ChequeBounceFlg", "FCSS_ArrearFlag", "FCSS_RefundOverFlag", 
                     "FCSS_ActiveFlag", "User_Id", "FCSS_RefundableAmount")
                VALUES
                    (p_MI_Id, p_ASMAY_ID, v_AMCST_ID, v_fmg_id, v_fmh_id, v_fti_id, v_FCMAS_Id,
                     0, 0, v_FCMAS_Amount, v_FCMAS_Amount, v_FCMAS_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                     0, 0, v_FCMAS_Amount, 0, 0, 0, 1, v_userid, 0);

            END LOOP;

        END IF;

    END LOOP;

    RETURN;
END;
$$;