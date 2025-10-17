CREATE OR REPLACE FUNCTION "dbo"."CLG_FeesRecordsInsertHostel_Transport_Insert"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCST_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMG_Id bigint;
    v_Rcount int;
    v_FCMSGH_Id bigint;
    v_AMCO_Id bigint;
    v_FMH_Id bigint;
    v_GIRcount int;
    v_FCSSRcount int;
    v_AMB_Id bigint;
    v_FTI_Id bigint;
    v_AMSE_Id bigint;
    v_FCMAS_Id bigint;
    v_ACMS_Id bigint;
    v_FCMAS_Amount decimal(32,2);
    rec_instidssem RECORD;
BEGIN

    FOR v_FMG_Id IN 
        SELECT DISTINCT "FMG_Id" FROM "Fee_Master_Group" 
        WHERE "MI_Id" = p_MI_Id AND "FMG_Id" IN (6)
    LOOP

        SELECT COUNT(*) INTO v_Rcount 
        FROM "CLG"."Fee_College_Master_Student_GroupHead" 
        WHERE "FMG_Id" = v_FMG_Id 
            AND "MI_Id" = p_MI_Id 
            AND "AMCST_Id" = p_AMCST_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "FCMSGH_ActiveFlag" = 1;

        IF v_Rcount = 0 THEN
            INSERT INTO "CLG"."Fee_College_Master_Student_GroupHead"(
                "MI_Id", "AMCST_Id", "ASMAY_Id", "FMG_Id", "FCMSGH_ActiveFlag"
            ) 
            VALUES(p_MI_Id, p_AMCST_Id, p_ASMAY_Id, v_FMG_Id, 1);
        END IF;

        SELECT MAX("FCMSGH_Id") INTO v_FCMSGH_Id 
        FROM "CLG"."Fee_College_Master_Student_GroupHead" 
        WHERE "AMCST_Id" = p_AMCST_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "FMG_Id" = v_FMG_Id 
            AND "FCMSGH_ActiveFlag" = 1;

        SELECT a."AMCO_Id", a."AMB_Id", a."AMSE_Id", a."ACMS_Id" 
        INTO v_AMCO_Id, v_AMB_Id, v_AMSE_Id, v_ACMS_Id
        FROM "CLG"."Adm_College_Yearly_Student" a 
        INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" 
        WHERE a."AMCST_Id" = p_AMCST_Id AND a."ASMAY_Id" = p_ASMAY_Id;

        FOR rec_instidssem IN 
            SELECT "FMH_Id", "FTI_Id", "FCMAS_Id", "FCMAS_Amount" 
            FROM "CLG"."Fee_College_Master_Amount" FA
            INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" FS 
                ON FA."FCMA_Id" = FS."FCMA_Id" 
                AND FA."AMCO_Id" = v_AMCO_Id 
                AND FA."AMB_Id" = v_AMB_Id 
                AND FS."AMSE_Id" = v_AMSE_Id
            WHERE "FMG_Id" = v_FMG_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND FS."MI_Id" = p_MI_Id 
                AND FA."MI_Id" = p_MI_Id 
                AND FA."FMH_Id" = 6
        LOOP
            v_FMH_Id := rec_instidssem."FMH_Id";
            v_FTI_Id := rec_instidssem."FTI_Id";
            v_FCMAS_Id := rec_instidssem."FCMAS_Id";
            v_FCMAS_Amount := rec_instidssem."FCMAS_Amount";

            v_GIRcount := 0;

            SELECT COUNT(*) INTO v_GIRcount 
            FROM "CLG"."Fee_C_Master_Student_GroupHead_Installments" 
            WHERE "FCMSGH_Id" = v_FCMSGH_Id 
                AND "FMH_Id" = v_FMH_Id 
                AND "FTI_Id" = v_FTI_Id;

            RAISE NOTICE '%', v_GIRcount;
            RAISE NOTICE '@@GIRcount: %', v_GIRcount;

            IF v_GIRcount = 0 THEN
                INSERT INTO "CLG"."Fee_C_Master_Student_GroupHead_Installments"(
                    "FCMSGH_Id", "FMH_ID", "FTI_ID"
                ) 
                VALUES (v_FCMSGH_Id, v_FMH_Id, v_FTI_Id);
            END IF;

            v_FCSSRcount := 0;

            SELECT COUNT(*) INTO v_FCSSRcount 
            FROM "CLG"."Fee_College_Student_Status" 
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "AMCST_Id" = p_AMCST_Id 
                AND "FMG_Id" = v_FMG_Id 
                AND "FMH_Id" = v_FMH_Id 
                AND "FCMAS_Id" = v_FCMAS_Id 
                AND "FCSS_CurrentYrCharges" = v_FCMAS_Amount 
                AND "FCSS_NetAmount" = v_FCMAS_Amount;

            RAISE NOTICE '@FCSSRcount: %', v_FCSSRcount;

            IF v_FCSSRcount = 0 THEN
                INSERT INTO "CLG"."Fee_College_Student_Status"(
                    "MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id",
                    "FCSS_OBArrearAmount", "FCSS_OBExcessAmount", "FCSS_CurrentYrCharges", 
                    "FCSS_TotalCharges", "FCSS_ToBePaid", "FCSS_PaidAmount", 
                    "FCSS_ExcessPaidAmount", "FCSS_ExcessAmountAdjusted", 
                    "FCSS_RunningExcessAmount", "FCSS_ConcessionAmount", "FCSS_AdjustedAmount", 
                    "FCSS_WaivedAmount", "FCSS_RebateAmount", "FCSS_FineAmount", 
                    "FCSS_RefundAmount", "FCSS_RefundAmountAdjusted", "FCSS_NetAmount", 
                    "FCSS_ChequeBounceFlg", "FCSS_ArrearFlag", "FCSS_RefundOverFlag", 
                    "FCSS_ActiveFlag", "User_Id", "FCSS_RefundableAmount"
                )
                VALUES(
                    p_MI_Id, p_ASMAY_Id, p_AMCST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FCMAS_Id,
                    0, 0, v_FCMAS_Amount, v_FCMAS_Amount, v_FCMAS_Amount, 0, 0, 0, 0, 0, 0, 0, 
                    0, 0, 0, 0, v_FCMAS_Amount, 0, 0, 0, 1, 21, 0
                );
            END IF;

        END LOOP;

    END LOOP;

    RETURN;
END;
$$;