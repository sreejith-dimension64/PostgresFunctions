
CREATE OR REPLACE FUNCTION "dbo"."AutoFeeGroupmappingLocationWise"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_Userid BIGINT;
    v_flag TEXT;
    v_count BIGINT;
    v_TRSR_PickUpLocation BIGINT;
    v_TRSR_DropLocation BIGINT;
    v_TRMR_Id BIGINT;
    v_TRML_Id BIGINT;
    v_FMG_Id BIGINT;
    v_FMH_Id BIGINT;
    v_FTI_Id BIGINT;
    v_FMA_Id BIGINT;
    v_FMA_Amount DECIMAL(18,2);
    v_FMSG_Id BIGINT;
    v_AMCL_Id1 BIGINT;
    v_amcl_id BIGINT;
    v_fmcc_id BIGINT;
    v_term1 BIGINT;
    v_term2 BIGINT;
    v_term3 BIGINT;
    v_fsscount BIGINT;
    v_row_count INT;
    rec_yearly_fee RECORD;
    rec_feeinstallment RECORD;
BEGIN

    IF(p_MI_Id = 30) THEN
        PERFORM "dbo"."Fee_Installmentwise_RouteLocation"(p_MI_Id, p_ASMAY_Id, p_AMST_Id);
    ELSE

        DROP TABLE IF EXISTS overalltempgroup;
        DROP TABLE IF EXISTS "TempGroup";
        DROP TABLE IF EXISTS "TempGroup1";
        DROP TABLE IF EXISTS "TempGroup2";

        SELECT COUNT(*) INTO v_count 
        FROM "TRN"."TR_Student_Route" 
        WHERE "AMST_Id" = p_AMST_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "TRSR_PickUpLocation" != '' 
        AND "TRSR_DropLocation" != '';

        SELECT "TRSR_PickUpLocation", "TRMR_Id" INTO v_TRSR_PickUpLocation, v_TRMR_Id
        FROM "TRN"."TR_Student_Route" 
        WHERE "AMST_Id" = p_AMST_Id 
        AND "ASMAY_Id" = p_ASMAY_Id;

        SELECT "TRSR_DropLocation", "TRMR_Id" INTO v_TRSR_DropLocation, v_TRMR_Id
        FROM "TRN"."TR_Student_Route" 
        WHERE "AMST_Id" = p_AMST_Id 
        AND "ASMAY_Id" = p_ASMAY_Id;

        SELECT "FMG_Id" INTO v_FMG_Id
        FROM "TRN"."TR_Location_FeeGroup_Mapping" 
        WHERE "TRML_Id" = v_TRSR_PickUpLocation;

        PERFORM "dbo"."transportfeemapping_Deletelocationwise"(p_MI_Id, p_ASMAY_Id, p_AMST_Id, v_FMG_Id);

        IF v_count > 0 THEN
            v_flag := 'Twoway';
            SELECT "TRMLAMT_TwoWayAmount" INTO v_FMA_Amount
            FROM "TRN"."TR_Location_Amount" 
            WHERE "ASMAY_Id" = p_ASMAY_Id 
            AND "TRML_Id" = v_TRSR_PickUpLocation 
            AND "TRMR_Id" = v_TRMR_Id;
        ELSE
            v_flag := 'Oneway';
            SELECT "TRMLAMT_OneWayAmount" INTO v_FMA_Amount
            FROM "TRN"."TR_Location_Amount" 
            WHERE "ASMAY_Id" = p_ASMAY_Id 
            AND "TRML_Id" = v_TRSR_PickUpLocation 
            AND "TRMR_Id" = v_TRMR_Id;
        END IF;

        SELECT COUNT(*) INTO v_fsscount
        FROM "Fee_Student_Status" 
        WHERE "FMG_Id" = v_FMG_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "AMST_ID" = p_AMST_Id 
        AND "MI_Id" = p_MI_Id;

        IF(v_fsscount = 0) THEN

            IF v_flag = 'Twoway' THEN

                IF v_TRSR_PickUpLocation = v_TRSR_DropLocation THEN

                    SELECT "FMG_Id" INTO v_FMG_Id
                    FROM "TRN"."TR_Location_FeeGroup_Mapping" 
                    WHERE "TRML_Id" = v_TRSR_PickUpLocation 
                    AND "TRLFM_WayFlag" = 'Twoway';

                    CREATE TEMP TABLE "TempGroup" AS
                    SELECT DISTINCT "fee_master_group"."fmg_id"
                    FROM "fee_master_group" 
                    INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                        ON "Fee_Yearly_Group_Head_Mapping"."fmg_id" = "fee_master_group"."fmg_id" 
                        AND "fee_master_group"."MI_Id" = "Fee_Yearly_Group_Head_Mapping"."MI_Id"
                    INNER JOIN "fee_master_head" 
                        ON "fee_master_head"."fmh_id" = "Fee_Yearly_Group_Head_Mapping"."fmh_id" 
                        AND "fee_master_head"."MI_Id" = "Fee_Yearly_Group_Head_Mapping"."MI_Id"
                    WHERE "Fee_Yearly_Group_Head_Mapping"."mi_id" = p_MI_Id 
                    AND "asmay_id" = p_ASMAY_Id 
                    AND "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = v_FMG_Id;

                    FOR rec_yearly_fee IN 
                        SELECT "FMG_Id" FROM "TempGroup"
                    LOOP
                        v_FMG_Id := rec_yearly_fee."FMG_Id";

                        SELECT COUNT(*) INTO v_row_count
                        FROM "Fee_Student_Status" 
                        WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "AMST_Id" = p_AMST_Id 
                        AND "FMG_Id" = v_FMG_Id 
                        AND "FMH_Id" NOT IN (
                            SELECT "FMH_Id" 
                            FROM "Fee_Master_Head" 
                            WHERE "MI_Id" = p_MI_Id 
                            AND ("FMH_Flag" = 'F' OR "FMH_Flag" = 'E')
                        );

                        IF v_row_count = 0 THEN
                            INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
                            VALUES (p_MI_Id, p_AMST_Id, p_ASMAY_Id, v_FMG_Id, 'Y');

                            SELECT "FMSG_Id" INTO v_FMSG_Id
                            FROM "Fee_Master_Student_Group" 
                            WHERE "AMST_Id" = p_AMST_Id 
                            AND "ASMAY_Id" = p_ASMAY_Id;

                            SELECT a."ASMCL_Id" INTO v_AMCL_Id1
                            FROM "Adm_School_Y_Student" a
                            INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" 
                            WHERE a."AMST_Id" = p_AMST_Id 
                            AND a."ASMAY_Id" = p_ASMAY_Id;

                            SELECT "FMCC_Id" INTO v_fmcc_id
                            FROM "Fee_Yearly_Class_Category" 
                            WHERE "ASMAY_Id" = p_ASMAY_Id 
                            AND "MI_Id" = p_MI_Id 
                            AND "FYCC_Id" IN (
                                SELECT "FYCC_Id" 
                                FROM "Fee_Yearly_Class_Category_Classes" 
                                WHERE "ASMCL_Id" = v_AMCL_Id1
                            );

                            FOR rec_feeinstallment IN 
                                SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_CreatedBy" 
                                FROM "Fee_Master_Amount" 
                                WHERE "FMG_Id" = v_FMG_Id 
                                AND "ASMAY_Id" = p_ASMAY_Id 
                                AND "MI_Id" = p_MI_Id 
                                AND "FMCC_Id" = v_FMCC_Id
                            LOOP
                                v_FMH_Id := rec_feeinstallment."FMH_Id";
                                v_FTI_Id := rec_feeinstallment."FTI_Id";
                                v_FMA_Id := rec_feeinstallment."FMA_Id";
                                v_Userid := rec_feeinstallment."FMA_CreatedBy";

                                INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
                                VALUES (v_FMSG_Id, v_FMH_Id, v_FTI_Id);

                                INSERT INTO "Fee_Student_Status"("MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount",
                                    "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount")
                                VALUES(p_MI_Id, p_ASMAY_Id, p_AMST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id, 0, 0, v_FMA_Amount, v_FMA_Amount, v_FMA_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, v_FMA_Amount, 0, 0, 0, 1, v_Userid, 0);
                            END LOOP;
                        END IF;
                    END LOOP;

                ELSIF v_TRSR_PickUpLocation != v_TRSR_DropLocation THEN

                    SELECT "FMG_Id" INTO v_FMG_Id
                    FROM "TRN"."TR_Location_FeeGroup_Mapping" 
                    WHERE "TRML_Id" = v_TRSR_PickUpLocation 
                    AND "TRLFM_WayFlag" = 'Twoway';

                    CREATE TEMP TABLE "TempGroup1" AS
                    SELECT DISTINCT "fee_master_group"."fmg_id"
                    FROM "fee_master_group" 
                    INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                        ON "Fee_Yearly_Group_Head_Mapping"."fmg_id" = "fee_master_group"."fmg_id" 
                        AND "fee_master_group"."MI_Id" = "Fee_Yearly_Group_Head_Mapping"."MI_Id"
                    INNER JOIN "fee_master_head" 
                        ON "fee_master_head"."fmh_id" = "Fee_Yearly_Group_Head_Mapping"."fmh_id" 
                        AND "fee_master_head"."MI_Id" = "Fee_Yearly_Group_Head_Mapping"."MI_Id"
                    WHERE "Fee_Yearly_Group_Head_Mapping"."mi_id" = p_MI_Id 
                    AND "asmay_id" = p_ASMAY_Id 
                    AND "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = v_FMG_Id;

                    FOR rec_yearly_fee IN 
                        SELECT "FMG_Id" FROM "TempGroup1"
                    LOOP
                        v_FMG_Id := rec_yearly_fee."FMG_Id";

                        SELECT COUNT(*) INTO v_row_count
                        FROM "Fee_Student_Status" 
                        WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "AMST_Id" = p_AMST_Id 
                        AND "FMG_Id" = v_FMG_Id 
                        AND "FMH_Id" NOT IN (
                            SELECT "FMH_Id" 
                            FROM "Fee_Master_Head" 
                            WHERE "MI_Id" = p_MI_Id 
                            AND ("FMH_Flag" = 'F' OR "FMH_Flag" = 'E')
                        );

                        IF v_row_count = 0 THEN
                            INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
                            VALUES (p_MI_Id, p_AMST_Id, p_ASMAY_Id, v_FMG_Id, 'Y');

                            SELECT "FMSG_Id" INTO v_FMSG_Id
                            FROM "Fee_Master_Student_Group" 
                            WHERE "AMST_Id" = p_AMST_Id 
                            AND "ASMAY_Id" = p_ASMAY_Id;

                            SELECT a."ASMCL_Id" INTO v_AMCL_Id1
                            FROM "Adm_School_Y_Student" a
                            INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" 
                            WHERE a."AMST_Id" = p_AMST_Id 
                            AND a."ASMAY_Id" = p_ASMAY_Id;

                            SELECT "FMCC_Id" INTO v_fmcc_id
                            FROM "Fee_Yearly_Class_Category" 
                            WHERE "ASMAY_Id" = p_ASMAY_Id 
                            AND "MI_Id" = p_MI_Id 
                            AND "FYCC_Id" IN (
                                SELECT "FYCC_Id" 
                                FROM "Fee_Yearly_Class_Category_Classes" 
                                WHERE "ASMCL_Id" = v_AMCL_Id1
                            );

                            FOR rec_feeinstallment IN 
                                SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount", "FMA_CreatedBy" 
                                FROM "Fee_Master_Amount" 
                                WHERE "FMG_Id" = v_FMG_Id 
                                AND "ASMAY_Id" = p_ASMAY_Id 
                                AND "MI_Id" = p_MI_Id 
                                AND "FMCC_Id" = v_FMCC_Id
                            LOOP
                                v_FMH_Id := rec_feeinstallment."FMH_Id";
                                v_FTI_Id := rec_feeinstallment."FTI_Id";
                                v_FMA_Id := rec_feeinstallment."FMA_Id";
                                v_FMA_Amount := rec_feeinstallment."FMA_Amount";
                                v_Userid := rec_feeinstallment."FMA_CreatedBy";

                                INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
                                VALUES (v_FMSG_Id, v_FMH_Id, v_FTI_Id);

                                INSERT INTO "Fee_Student_Status"("MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount",
                                    "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount")
                                VALUES(p_MI_Id, p_ASMAY_Id, p_AMST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id, 0, 0, v_FMA_Amount, v_FMA_Amount, v_FMA_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, v_FMA_Amount, 0, 0, 0, 1, v_Userid, 0);
                            END LOOP;
                        END IF;
                    END LOOP;
                END IF;

            ELSIF v_flag = 'OneWay' THEN

                SELECT "FMG_Id" INTO v_FMG_Id
                FROM "TRN"."TR_Location_FeeGroup_Mapping" 
                WHERE "TRML_Id" = v_TRSR_PickUpLocation 
                AND "TRLFM_WayFlag" = 'OneWay';

                IF (v_FMG_Id = 0 OR v_FMG_Id IS NULL) THEN
                    SELECT "FMG_Id" INTO v_FMG_Id
                    FROM "TRN"."TR_Location_FeeGroup_Mapping" 
                    WHERE "TRML_Id" = v_TRSR_DropLocation 
                    AND "TRLFM_WayFlag" = 'OneWay';
                END IF;

                CREATE TEMP TABLE "TempGroup2" AS
                SELECT DISTINCT "fee_master_group"."fmg_id"
                FROM "fee_master_group" 
                INNER JOIN "Fee_Yearly_Group_Head_Mapping" 
                    ON "Fee_Yearly_Group_Head_Mapping"."fmg_id" = "fee_master_group"."fmg_id" 
                    AND "fee_master_group"."MI_Id" = "Fee_Yearly_Group_Head_Mapping"."MI_Id"
                INNER JOIN "fee_master_head" 
                    ON "fee_master_head"."fmh_id" = "Fee_Yearly_Group_Head_Mapping"."fmh_id" 
                    AND "fee_master_head"."MI_Id" = "Fee_Yearly_Group_Head_Mapping"."MI_Id"
                WHERE "Fee_Yearly_Group_Head_Mapping"."mi_id" = p_MI_Id 
                AND "asmay_id" = p_ASMAY_Id 
                AND "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = v_FMG_Id;

                FOR rec_yearly_fee IN 
                    SELECT "FMG_Id" FROM "TempGroup2"
                LOOP
                    v_FMG_Id := rec_yearly_fee."FMG_Id";

                    SELECT COUNT(*) INTO v_row_count
                    FROM "Fee_Student_Status" 
                    WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "AMST_Id" = p_AMST_Id 
                    AND "FMG_Id" = v_FMG_Id 
                    AND "FMH_Id" NOT IN (
                        SELECT "FMH_Id" 
                        FROM "Fee_Master_Head" 
                        WHERE "MI_Id" = p_MI_Id 
                        AND ("FMH_Flag" = 'F' OR "FMH_Flag" = 'E')
                    );

                    IF v_row_count = 0 THEN
                        INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
                        VALUES (p_MI_Id, p_AMST_Id, p_ASMAY_Id, v_FMG_Id, 'Y');

                        SELECT "FMSG_Id" INTO v_FMSG_Id
                        FROM "Fee_Master_Student_Group" 
                        WHERE "AMST_Id" = p_AMST_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id;

                        SELECT a."ASMCL_Id" INTO v_AMCL_Id1
                        FROM "Adm_School_Y_Student" a
                        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" 
                        WHERE a."AMST_Id" = p_AMST_Id 
                        AND a."ASMAY_Id" = p_ASMAY_Id;

                        SELECT "FMCC_Id" INTO v_fmcc_id
                        FROM "Fee_Yearly_Class_Category" 
                        WHERE "ASMAY_Id" = p_ASMAY_Id 
                        AND "MI_Id" = p_MI_Id 
                        AND "FYCC_Id" IN (
                            SELECT "FYCC_Id" 
                            FROM "Fee_Yearly_Class_Category_Classes" 
                            WHERE "ASMCL_Id" = v_AMCL_Id1
                        );

                        FOR rec_feeinstallment IN 
                            SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_CreatedBy" 
                            FROM "Fee_Master_Amount" 
                            WHERE "FMG_Id" = v_FMG_Id 
                            AND "ASMAY_Id" = p_ASMAY_Id 
                            AND "MI_Id" = p_MI_Id 
                            AND "FMCC_Id" = v_FMCC_Id
                        LOOP
                            v_FMH_Id := rec_feeinstallment."FMH_Id";
                            v_FTI_Id := rec_feeinstallment."FTI_Id";
                            v_FMA_Id := rec_feeinstallment."FMA_Id";
                            v_Userid := rec_feeinstallment."FMA_CreatedBy";

                            INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
                            VALUES (v_FMSG_Id, v_FMH_Id, v_FTI_Id);

                            INSERT INTO "Fee_Student_Status"("MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount",
                                "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount")
                            VALUES(p_MI_Id, p_ASMAY_Id, p_AMST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id, 0, 0, v_FMA_Amount, v_FMA_Amount, v_FMA_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, v_FMA_Amount, 0, 0, 0, 1, v_Userid, 0);
                        END LOOP;
                    END IF;
                END LOOP;
            END IF;
        END IF;
    END IF;

    RETURN;
END;
$$;