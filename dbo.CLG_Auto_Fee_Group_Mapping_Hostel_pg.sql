CREATE OR REPLACE FUNCTION "dbo"."CLG_Auto_Fee_Group_Mapping_Hostel"(
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
    v_HRMRM_Id bigint;
    v_JASMAY_Id bigint;
    v_SARcount int;
    v_FCSA_Amount decimal(32,2);
    v_ACCount int;
    rec_yearly_fee RECORD;
    rec_instidssem RECORD;
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

        v_orderid_previous := (v_orderid::int - 1)::varchar;

        SELECT "ASMAY_Id" INTO v_previous_yearid 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Order" = v_orderid_previous;

        SELECT "HRMRM_Id" INTO v_HRMRM_Id 
        FROM "HL_Hostel_Student_Allot_College" 
        WHERE "AMCST_Id" = p_AMCST_Id AND "ASMAY_Id" = v_previous_yearid;

        SELECT COUNT(*) INTO v_SFS 
        FROM "CLG"."Fee_College_Student_Status" 
        WHERE "AMCST_Id" = p_AMCST_Id AND "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_previous_yearid 
        AND "FMG_Id" IN (SELECT "FMG_Id" FROM "HL_Master_Room_FeeGroup" WHERE "MI_Id" = p_MI_Id) 
        AND "FCSS_CurrentYrCharges" > 0;

        IF v_SFS = 0 OR v_SFS IS NULL THEN
            DROP TABLE IF EXISTS "TempGroupHostel_College";

            CREATE TEMP TABLE "TempGroupHostel_College" AS
            SELECT DISTINCT "Fee_Master_Group"."FMG_Id"
            FROM "Fee_Master_Group" 
            INNER JOIN "Fee_Yearly_Group_Head_Mapping" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            WHERE "Fee_Yearly_Group_Head_Mapping"."MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "FMH_RefundFlag" = '1' 
            AND "FMG_CompulsoryFlag" = 'N';
        ELSE
            DELETE FROM "TempGroupHostel_College";
        END IF;

        FOR rec_yearly_fee IN 
            SELECT "FMG_Id" FROM "TempGroupHostel_College"
            UNION 
            SELECT "FMG_Id" FROM "HL_Master_Room_FeeGroup" WHERE "MI_Id" = p_MI_Id
        LOOP
            v_FMG_Id := rec_yearly_fee."FMG_Id";

            SELECT COUNT(*) INTO v_Rcount 
            FROM "CLG"."Fee_College_Master_Student_GroupHead" 
            WHERE "FMG_Id" = v_FMG_Id 
            AND "MI_Id" = p_MI_Id 
            AND "AMCST_Id" = p_AMCST_Id 
            AND "ASMAY_Id" = p_ASMAY_ID 
            AND "FCMSGH_ActiveFlag" = true;

            IF v_Rcount = 0 THEN
                INSERT INTO "CLG"."Fee_College_Master_Student_GroupHead"("MI_Id", "AMCST_Id", "ASMAY_Id", "FMG_Id", "FCMSGH_ActiveFlag") 
                VALUES(p_MI_Id, p_AMCST_Id, p_ASMAY_ID, v_FMG_Id, true);
            END IF;

            SELECT MAX("FCMSGH_Id") INTO v_FCMSGH_Id 
            FROM "CLG"."Fee_College_Master_Student_GroupHead" 
            WHERE "AMCST_Id" = p_AMCST_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            AND "FMG_Id" = v_FMG_Id 
            AND "FCMSGH_ActiveFlag" = true;

            SELECT a."AMCO_Id", a."AMB_Id", a."AMSE_Id", a."ACMS_Id" 
            INTO v_AMCO_Id, v_AMB_Id, v_AMSE_Id_Prev, v_ACMS_Id 
            FROM "CLG"."Adm_College_Yearly_Student" a 
            INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" 
            WHERE a."AMCST_Id" = p_AMCST_Id AND a."ASMAY_Id" = v_previous_yearid;

            SELECT DISTINCT a."AMCO_Id", a."AMB_Id" 
            INTO v_AMCO_Id, v_AMB_Id 
            FROM "CLG"."Adm_College_Yearly_Student" a 
            INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" 
            WHERE a."AMCST_Id" = p_AMCST_Id;

            SELECT DISTINCT "ASMAY_Id" INTO v_JASMAY_Id 
            FROM "CLG"."Adm_Master_College_Student" 
            WHERE "AMCST_Id" = p_AMCST_Id AND "MI_Id" = p_MI_Id;

            IF v_AMSE_Id_Prev != 0 THEN
                SELECT "AMSE_SEMOrder" INTO v_previoussemorder 
                FROM "CLG"."Adm_Master_Semester" 
                WHERE "MI_Id" = p_MI_Id AND "AMSE_Id" = v_AMSE_Id_Prev;

                v_currentorderid := (v_previoussemorder::int + 1)::varchar;

                SELECT "AMSE_Id" INTO v_AMSE_Id_Current 
                FROM "CLG"."Adm_Master_Semester" 
                WHERE "MI_Id" = p_MI_Id AND "AMSE_SEMOrder" = v_currentorderid;

                v_AMSE_Id := v_AMSE_Id_Current;
            ELSE
                SELECT "AMSE_Id" INTO v_AMSE_Id 
                FROM "CLG"."Adm_Master_College_Student" 
                WHERE "AMCST_Id" = p_AMCST_Id 
                AND "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_ASMAY_Id;
            END IF;

            SELECT DISTINCT COALESCE("FMG_BatchwiseFeeApplFlg", false) INTO v_FMG_BatchwiseFeeApplFlg 
            FROM "Fee_Master_Group" 
            WHERE "MI_Id" = p_MI_Id AND "FMG_Id" = v_FMG_Id;

            DROP TABLE IF EXISTS "Fee_CollegeSemesterWiseAmount_Hostel_Temp";

            IF v_FMG_BatchwiseFeeApplFlg = true THEN
                CREATE TEMP TABLE "Fee_CollegeSemesterWiseAmount_Hostel_Temp" AS
                SELECT "FMH_Id", "FTI_Id", FS."FCMAS_Id", "FCMAS_Amount"
                FROM "CLG"."Fee_College_Master_Amount" FA
                INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" FS ON FA."FCMA_Id" = FS."FCMA_Id" 
                    AND FA."AMCO_Id" = v_AMCO_Id 
                    AND FA."AMB_Id" = v_AMB_Id 
                    AND FS."AMSE_Id" = v_AMSE_Id
                WHERE "FMG_Id" = v_FMG_Id 
                AND "ASMAY_Id" = v_JASMAY_Id 
                AND FS."MI_Id" = p_MI_Id 
                AND FA."MI_Id" = p_MI_Id;
            ELSIF v_FMG_BatchwiseFeeApplFlg = false THEN
                CREATE TEMP TABLE "Fee_CollegeSemesterWiseAmount_Hostel_Temp" AS
                SELECT "FMH_Id", "FTI_Id", FS."FCMAS_Id", "FCMAS_Amount"
                FROM "CLG"."Fee_College_Master_Amount" FA
                INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" FS ON FA."FCMA_Id" = FS."FCMA_Id" 
                    AND FA."AMCO_Id" = v_AMCO_Id 
                    AND FA."AMB_Id" = v_AMB_Id 
                    AND FS."AMSE_Id" = v_AMSE_Id
                WHERE "FMG_Id" = v_FMG_Id 
                AND "ASMAY_Id" = p_ASMAY_Id 
                AND FS."MI_Id" = p_MI_Id 
                AND FA."MI_Id" = p_MI_Id;
            END IF;

            FOR rec_instidssem IN 
                SELECT "FMH_Id", "FTI_Id", "FCMAS_Id", "FCMAS_Amount" 
                FROM "Fee_CollegeSemesterWiseAmount_Hostel_Temp"
            LOOP
                v_FMH_Id := rec_instidssem."FMH_Id";
                v_FTI_Id := rec_instidssem."FTI_Id";
                v_FCMAS_Id := rec_instidssem."FCMAS_Id";
                v_FCMAS_Amount := rec_instidssem."FCMAS_Amount";

                v_SARcount := 0;

                SELECT COUNT(*) INTO v_SARcount 
                FROM "CLG"."Fee_College_Studentwise_Amount" 
                WHERE "MI_Id" = p_MI_Id 
                AND "AMCO_Id" = v_AMCO_Id 
                AND "AMB_Id" = v_AMB_Id 
                AND "AMSE_Id" = v_AMSE_Id 
                AND "FCMAS_Id" = v_FCMAS_Id 
                AND "AMCST_Id" = p_AMCST_Id 
                AND "FCSA_ActiveFlg" = true;

                IF v_SARcount <> 0 THEN
                    SELECT "FCSA_Amount" INTO v_FCSA_Amount 
                    FROM "CLG"."Fee_College_Studentwise_Amount" 
                    WHERE "MI_Id" = p_MI_Id 
                    AND "AMCO_Id" = v_AMCO_Id 
                    AND "AMB_Id" = v_AMB_Id 
                    AND "AMSE_Id" = v_AMSE_Id 
                    AND "FCMAS_Id" = v_FCMAS_Id 
                    AND "AMCST_Id" = p_AMCST_Id 
                    AND "FCSA_ActiveFlg" = true;
                    v_FCMAS_Amount := v_FCSA_Amount;
                END IF;

                v_GIRcount := 0;

                SELECT COUNT(*) INTO v_GIRcount 
                FROM "CLG"."Fee_C_Master_Student_GroupHead_Installments" 
                WHERE "FCMSGH_Id" = v_FCMSGH_Id 
                AND "FMH_Id" = v_FMH_Id 
                AND "FTI_Id" = v_FTI_Id;

                IF v_GIRcount = 0 THEN
                    INSERT INTO "CLG"."Fee_C_Master_Student_GroupHead_Installments"("FCMSGH_Id", "FMH_ID", "FTI_ID") 
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

                IF v_FCSSRcount = 0 THEN
                    INSERT INTO "CLG"."Fee_College_Student_Status"(
                        "MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", 
                        "FCSS_OBArrearAmount", "FCSS_OBExcessAmount", "FCSS_CurrentYrCharges", 
                        "FCSS_TotalCharges", "FCSS_ToBePaid", "FCSS_PaidAmount", "FCSS_ExcessPaidAmount", 
                        "FCSS_ExcessAmountAdjusted", "FCSS_RunningExcessAmount", "FCSS_ConcessionAmount", 
                        "FCSS_AdjustedAmount", "FCSS_WaivedAmount", "FCSS_RebateAmount", "FCSS_FineAmount", 
                        "FCSS_RefundAmount", "FCSS_RefundAmountAdjusted", "FCSS_NetAmount", 
                        "FCSS_ChequeBounceFlg", "FCSS_ArrearFlag", "FCSS_RefundOverFlag", 
                        "FCSS_ActiveFlag", "User_Id", "FCSS_RefundableAmount"
                    )   
                    VALUES(
                        p_MI_Id, p_ASMAY_Id, p_AMCST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FCMAS_Id, 
                        0, 0, v_FCMAS_Amount, v_FCMAS_Amount, v_FCMAS_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                        v_FCMAS_Amount, false, false, false, true, p_UserId, 0
                    );
                END IF;
            END LOOP;
        END LOOP;

        DROP TABLE IF EXISTS "TempGroupHostel_College";
        DROP TABLE IF EXISTS "Fee_CollegeSemesterWiseAmount_Hostel_Temp";

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error occurred: %', SQLERRM;
            RAISE;
    END;

    RETURN;
END;
$$;