
CREATE OR REPLACE FUNCTION "dbo"."CLG_Auto_Fee_Group_Mapping_Transport_LocationRequest1"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCST_Id bigint,
    p_UserId bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMCC_Id bigint;
    v_AMSE_Id bigint;
    v_AMSE_Id_Current bigint;
    v_AMSE_Id_Prev bigint;
    v_FTI_Name varchar(100);
    v_FMH_Name varchar(100);
    v_FMG_Id bigint;
    v_Rcount int;
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    v_FCMSGH_Id bigint;
    v_selectflag varchar(50);
    v_AMCO_Id bigint;
    v_AMB_Id bigint;
    v_FMG_BatchwiseFeeApplFlg boolean;
    v_FCMAS_Id bigint;
    v_GIRcount int;
    v_FTP_Concession_Amt decimal(18,2);
    v_STP int;
    v_STD int;
    v_STB int;
    v_SFS int;
    v_FCSSRcount int;
    v_previous_yearid varchar;
    v_orderid varchar;
    v_orderid_previous varchar;
    v_FCMAS_Amount decimal(18,2);
    v_previoussemorder varchar;
    v_currentorderid varchar;
    v_ACMS_Id bigint;
    v_JASMAY_Id bigint;
    v_SARcount int;
    v_FCSA_Amount decimal(32,2);
    v_FMC_CommonTransportLocationFeeFlg boolean;
    v_FMH_Flag varchar(100);
    rec_yearly_fee RECORD;
    rec_INSTIDSSEM RECORD;
BEGIN
    v_AMSE_Id := 0;
    v_AMSE_Id_Prev := 0;
    v_FMCC_Id := 0;
    v_FTI_Name := '';
    v_FMH_Name := '';
    v_FTP_Concession_Amt := 0;

    BEGIN
        SELECT "ASMAY_Order" INTO v_orderid 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;

        v_orderid_previous := CAST(CAST(v_orderid AS int) - 1 AS varchar);

        SELECT "ASMAY_Id" INTO v_previous_yearid 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Order" = v_orderid_previous;

        SELECT COUNT(*) INTO v_STB 
        FROM "TRN"."TR_Student_Route_College" 
        WHERE "ASMAY_Id" = p_ASMAY_Id 
            AND "AMCST_Id" = p_AMCST_Id 
            AND "MI_Id" = p_MI_Id 
            AND ("TRRSCO_PickUpLocation" != 0 AND "TRRSCO_DropLocation" != 0);

        IF v_STB > 0 THEN
            v_selectflag := 'Two Way';
        ELSIF v_STB = 0 THEN
            v_selectflag := 'One Way';
        END IF;

        SELECT COUNT(*) INTO v_SFS 
        FROM "CLG"."Fee_College_Student_Status" 
        WHERE "AMCST_Id" = p_AMCST_Id 
            AND "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = v_previous_yearid
            AND "FMG_Id" IN (
                SELECT "FMG_Id" 
                FROM "TRN"."TR_Location_FeeGroup_Mapping" 
                WHERE "TRLFM_WayFlag" = v_selectflag AND "MI_Id" = p_MI_Id
            ) 
            AND "FCSS_CurrentYrCharges" > 0;

        IF v_SFS = 0 OR v_SFS IS NULL THEN
            DROP TABLE IF EXISTS "TempGroupLocationRequest_College";

            CREATE TEMP TABLE "TempGroupLocationRequest_College" AS
            SELECT DISTINCT "Fee_Master_Group"."FMG_Id"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Yearly_Group_Head_Mapping" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            INNER JOIN "TRN"."TR_Location_FeeGroup_Mapping" ON "TRN"."TR_Location_FeeGroup_Mapping"."fmg_id" = "Fee_Master_Group"."FMG_Id" 
                AND "TRN"."TR_Location_FeeGroup_Mapping"."ASMAY_Id" = "Fee_Yearly_Group_Head_Mapping"."asmay_id"
            WHERE "Fee_Yearly_Group_Head_Mapping"."MI_Id" = p_MI_Id 
                AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = p_ASMAY_Id 
                AND "FMG_TransportFlg" = 1
                AND "TRML_Id" IN (
                    SELECT "TRRSCO_PickUpLocation" 
                    FROM "TRN"."TR_Student_Route_College" 
                    WHERE "ASMAY_Id" = p_ASMAY_Id 
                        AND "AMCST_Id" = p_AMCST_Id 
                        AND "MI_Id" = p_MI_Id
                );
        END IF;

        FOR rec_yearly_fee IN 
            SELECT DISTINCT "FMG_Id" FROM "TempGroupLocationRequest_College"
        LOOP
            v_FMG_Id := rec_yearly_fee."FMG_Id";

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
                ) VALUES(p_MI_Id, p_AMCST_Id, p_ASMAY_Id, v_FMG_Id, 1);
            END IF;

            SELECT MAX("FCMSGH_Id") INTO v_FCMSGH_Id 
            FROM "CLG"."Fee_College_Master_Student_GroupHead" 
            WHERE "AMCST_Id" = p_AMCST_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND "FMG_Id" = v_FMG_Id 
                AND "FCMSGH_ActiveFlag" = 1;

            SELECT a."AMCO_Id", a."AMB_Id", a."AMSE_Id", a."ACMS_Id" 
            INTO v_AMCO_Id, v_AMB_Id, v_AMSE_Id_Prev, v_ACMS_Id 
            FROM "CLG"."Adm_College_Yearly_Student" a 
            INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" 
            WHERE a."AMCST_Id" = p_AMCST_Id 
                AND a."ASMAY_Id" = v_previous_yearid;

            SELECT DISTINCT a."AMCO_Id", a."AMB_Id", a."AMSE_Id" 
            INTO v_AMCO_Id, v_AMB_Id, v_AMSE_Id 
            FROM "CLG"."Adm_College_Yearly_Student" a 
            INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" 
            WHERE a."AMCST_Id" = p_AMCST_Id 
                AND a."ASMAY_Id" = p_ASMAY_Id;

            SELECT DISTINCT "ASMAY_Id" INTO v_JASMAY_Id 
            FROM "CLG"."Adm_Master_College_Student" 
            WHERE "AMCST_Id" = p_AMCST_Id 
                AND "MI_Id" = p_MI_Id;

            IF v_AMSE_Id_Prev != 0 THEN
                SELECT "AMSE_SEMOrder" INTO v_previoussemorder 
                FROM "CLG"."Adm_Master_Semester" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "AMSE_Id" = v_AMSE_Id_Prev;

                v_currentorderid := CAST(CAST(v_previoussemorder AS int) + 1 AS varchar);

                SELECT "AMSE_Id" INTO v_AMSE_Id_Current 
                FROM "CLG"."Adm_Master_Semester" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "AMSE_SEMOrder" = v_currentorderid;

                v_AMSE_Id := v_AMSE_Id_Current;
            ELSE
                SELECT "AMSE_Id" INTO v_AMSE_Id 
                FROM "CLG"."Adm_Master_College_Student" 
                WHERE "AMCST_Id" = p_AMCST_Id 
                    AND "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id;
            END IF;

            SELECT COALESCE("FMC_CommonTransportLocationFeeFlg", FALSE) INTO v_FMC_CommonTransportLocationFeeFlg 
            FROM "Fee_Master_Configuration" 
            WHERE "MI_Id" = p_MI_Id;

            FOR rec_INSTIDSSEM IN 
                SELECT FA."FMH_Id", "FTI_Id", "FCMAS_Id", "FCMAS_Amount", "FMH_Flag" 
                FROM "CLG"."Fee_College_Master_Amount" FA
                INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" FS ON FA."FCMA_Id" = FS."FCMA_Id" 
                    AND FA."AMCO_Id" = v_AMCO_Id 
                    AND FA."AMB_Id" = v_AMB_Id 
                    AND FS."AMSE_Id" = v_AMSE_Id
                INNER JOIN "Fee_Master_Head" FMH ON FMH."FMH_Id" = FA."FMH_Id"
                INNER JOIN "Fee_Master_Group" FMG ON FMG."FMG_Id" = FA."FMG_Id" 
                    AND FMG."FMG_TransportFlg" = 1
                WHERE FA."FMG_Id" = v_FMG_Id 
                    AND FA."ASMAY_Id" = p_ASMAY_Id 
                    AND FS."MI_Id" = p_MI_Id 
                    AND FA."MI_Id" = p_MI_Id
            LOOP
                v_FMH_Id := rec_INSTIDSSEM."FMH_Id";
                v_FTI_Id := rec_INSTIDSSEM."FTI_Id";
                v_FCMAS_Id := rec_INSTIDSSEM."FCMAS_Id";
                v_FCMAS_Amount := rec_INSTIDSSEM."FCMAS_Amount";
                v_FMH_Flag := rec_INSTIDSSEM."FMH_Flag";

                IF v_selectflag = 'One Way' AND v_FMC_CommonTransportLocationFeeFlg = TRUE AND v_FMH_Flag != 'F' THEN
                    SELECT DISTINCT "TRMLAMT_OneWayAmount" INTO v_FCMAS_Amount 
                    FROM "TRN"."TR_Location_Amount" TLA
                    INNER JOIN "TRN"."TR_Location_FeeGroup_Mapping" TLFM ON TLFM."TRML_Id" = TLA."TRML_Id"
                    WHERE TLFM."ASMAY_Id" = p_ASMAY_Id 
                        AND TLFM."TRLFM_WayFlag" = v_selectflag 
                        AND TLFM."FMG_Id" = v_FMG_Id 
                        AND TLFM."TRLFM_ActiveFlag" = 1
                        AND TLA."TRMLAMT_ActiveFlg" = 1;
                ELSIF v_selectflag = 'Two Way' AND v_FMC_CommonTransportLocationFeeFlg = TRUE AND v_FMH_Flag != 'F' THEN
                    SELECT DISTINCT "TRMLAMT_TwoWayAmount" INTO v_FCMAS_Amount 
                    FROM "TRN"."TR_Location_Amount" TLA
                    INNER JOIN "TRN"."TR_Location_FeeGroup_Mapping" TLFM ON TLFM."TRML_Id" = TLA."TRML_Id"
                    WHERE TLFM."ASMAY_Id" = p_ASMAY_Id 
                        AND TLFM."TRLFM_WayFlag" = v_selectflag 
                        AND TLFM."FMG_Id" = v_FMG_Id 
                        AND TLFM."TRLFM_ActiveFlag" = 1
                        AND TLA."TRMLAMT_ActiveFlg" = 1;
                END IF;

                v_GIRcount := 0;

                SELECT COUNT(*) INTO v_GIRcount 
                FROM "CLG"."Fee_C_Master_Student_GroupHead_Installments" 
                WHERE "FCMSGH_Id" = v_FCMSGH_Id 
                    AND "FMH_Id" = v_FMH_Id 
                    AND "FTI_Id" = v_FTI_Id;

                IF v_GIRcount = 0 THEN
                    INSERT INTO "CLG"."Fee_C_Master_Student_GroupHead_Installments"(
                        "FCMSGH_Id", "FMH_ID", "FTI_ID"
                    ) VALUES (v_FCMSGH_Id, v_FMH_Id, v_FTI_Id);
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
                    AND "FTI_Id" = v_FTI_Id
                    AND "FCSS_NetAmount" = v_FCMAS_Amount;

                IF v_FCSSRcount = 0 THEN
                    INSERT INTO "CLG"."Fee_College_Student_Status"(
                        "MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", 
                        "FCSS_OBArrearAmount", "FCSS_OBExcessAmount", "FCSS_CurrentYrCharges", 
                        "FCSS_TotalCharges", "FCSS_ToBePaid", "FCSS_PaidAmount", "FCSS_ExcessPaidAmount", 
                        "FCSS_ExcessAmountAdjusted", "FCSS_RunningExcessAmount", "FCSS_ConcessionAmount", 
                        "FCSS_AdjustedAmount", "FCSS_WaivedAmount", "FCSS_RebateAmount", "FCSS_FineAmount", 
                        "FCSS_RefundAmount", "FCSS_RefundAmountAdjusted", "FCSS_NetAmount", 
                        "FCSS_ChequeBounceFlg", "FCSS_ArrearFlag", "FCSS_RefundOverFlag", "FCSS_ActiveFlag",
                        "User_Id", "FCSS_RefundableAmount"
                    )
                    VALUES(
                        p_MI_Id, p_ASMAY_Id, p_AMCST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FCMAS_Id, 
                        0, 0, v_FCMAS_Amount, v_FCMAS_Amount, v_FCMAS_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                        v_FCMAS_Amount, 0, 0, 0, 1, p_UserId, 0
                    );
                END IF;
            END LOOP;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

    RETURN;
END;
$$;