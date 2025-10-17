CREATE OR REPLACE FUNCTION "dbo"."Fee_OBTransferFeeHeadWise21-22OB"(
    p_mi_id bigint,
    p_Lasmay_id bigint,
    p_Nasmay_id bigint,
    p_amst_id1 bigint,
    p_fmhids bigint,
    p_fttiids bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASMAY_From_Date date;
    v_ASMAY_To_Date date;
    v_FMH_Id bigint;
    v_FMH_FeeName varchar(150);
    v_AMST_Id bigint;
    v_SFMH_Id bigint;
    v_ToBePaid bigint;
    v_FTI_ids bigint;
    v_ASMAY_Id_New bigint;
    v_FMA_Amount bigint;
    v_RAMST_Id bigint;
    v_FSS_RunningExcessAmount bigint;
    v_FTI_Id bigint;
    v_SFTI_Id bigint;
    v_PAMST_Id bigint;
    v_PFMH_Id bigint;
    v_PFTI_Id bigint;
    v_SToBePaid bigint;
    v_FSS_Id bigint;
    v_FSS_IdNew bigint;
    v_user_Id bigint;
    v_FMH_IdE bigint;
    v_ASMCL_Id bigint;
    v_FFTI_Id bigint;
    v_FMCC_Id bigint;
    v_FMH_Idold bigint;
    v_OBFMH_Id bigint;
    v_Totaltobepaid bigint;
    v_FMG_IdN bigint;
    v_FMH_IdN bigint;
    v_FMA_IdN bigint;
    v_FTI_IdN bigint;
    v_ACT_AMST_Id bigint;
    rec_studentslist RECORD;
    rec_CursorfeeNames RECORD;
    rec_Cursorobamt RECORD;
    rec_obupdate RECORD;
BEGIN

    FOR rec_studentslist IN
        SELECT "YS"."AMST_Id", "FMH_ID" 
        FROM "Adm_M_Student" "AMS"
        INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = "AMS"."AMST_Id"
        INNER JOIN "Fee_Student_Status" "SS" ON "SS"."AMST_Id" = "YS"."AMST_Id" AND "SS"."MI_Id" = "AMS"."MI_Id"
        WHERE "AMS"."MI_Id" = p_mi_id 
            AND "YS"."ASMAY_Id" = p_Lasmay_id 
            AND "AMST_SOL" = 'S' 
            AND "AMST_ActiveFlag" = 1 
            AND "AMAY_ActiveFlag" = 1
            AND "SS"."MI_Id" = p_mi_id 
            AND "SS"."ASMAY_Id" = p_Lasmay_id 
            AND "SS"."FSS_ToBePaid" > 0 
            AND "SS"."FSS_OBArrearAmount" = 0
        GROUP BY "FMH_ID", "YS"."AMST_Id"
    LOOP
        v_ACT_AMST_Id := rec_studentslist."AMST_Id";
        v_FMH_Idold := rec_studentslist."FMH_ID";

        FOR rec_CursorfeeNames IN
            SELECT DISTINCT "fee_master_head"."FMH_Id", "FMH_FeeName"
            FROM "Fee_Student_Status"
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."fmh_id" = "Fee_Master_Head"."fmh_id"
            WHERE "Fee_Student_Status"."MI_Id" = p_mi_id 
                AND "Fee_Student_Status"."ASMAY_Id" = p_Lasmay_id 
                AND "Fee_Student_Status"."FSS_ToBePaid" > 0 
                AND "Fee_Student_Status"."AMST_Id" = v_ACT_AMST_Id
                AND "Fee_Master_Head"."FMH_Id" = v_FMH_Idold 
                AND "Fee_Student_Status"."FSS_OBArrearAmount" = 0
        LOOP
            v_FMH_Id := rec_CursorfeeNames."FMH_Id";
            v_FMH_FeeName := rec_CursorfeeNames."FMH_FeeName";

            FOR rec_Cursorobamt IN
                SELECT "Fee_Student_Status"."AMST_Id", "Fee_Master_Head"."FMH_Id", SUM("FSS_ToBePaid") AS "ToBePaid", "Fee_Student_Status"."FTI_Id"
                FROM "Fee_Master_Group"
                INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = p_mi_id
                INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = p_mi_id
                INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = p_mi_id
                INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = p_Lasmay_id AND "AMAY_ActiveFlag" = 1
                WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_Lasmay_id 
                    AND "fee_student_status"."MI_Id" = p_mi_id 
                    AND "fee_student_status"."ASMAY_Id" = p_Lasmay_id 
                    AND "fee_student_status"."AMST_Id" = v_ACT_AMST_Id
                    AND "Fee_Master_Head"."FMH_Id" = v_FMH_Id 
                    AND "Fee_Student_Status"."FMH_Id" = v_FMH_Id 
                    AND "Fee_Student_Status"."FSS_OBArrearAmount" = 0
                GROUP BY "Fee_Student_Status"."AMST_Id", "Fee_Master_Head"."FMH_Id", "Fee_Student_Status"."FTI_Id"
                HAVING SUM("FSS_ToBePaid") > 0
            LOOP
                v_AMST_Id := rec_Cursorobamt."AMST_Id";
                v_SFMH_Id := rec_Cursorobamt."FMH_Id";
                v_ToBePaid := rec_Cursorobamt."ToBePaid";
                v_FTI_ids := rec_Cursorobamt."FTI_Id";

                SELECT "FSS_Id" INTO v_FSS_Id 
                FROM "fee_student_status" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "AMST_Id" = v_AMST_Id 
                    AND "FMH_Id" = v_FMH_Id 
                    AND "ASMAY_Id" = p_Lasmay_id 
                    AND "FTI_Id" = v_FTI_ids 
                ORDER BY "FTI_Id" 
                LIMIT 1;

                UPDATE "Fee_Student_Status" 
                SET "FSS_OBTransferred" = v_ToBePaid, 
                    "FSS_ToBePaid" = 0, 
                    "FSS_OBAsPerFY" = v_ToBePaid 
                WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_Lasmay_id 
                    AND "AMST_Id" = v_AMST_Id 
                    AND "FMH_Id" = v_SFMH_Id 
                    AND "FSS_Id" = v_FSS_Id 
                    AND "FTI_Id" = v_FTI_ids;

                v_FSS_IdNew := 0;
                SELECT "FSS_Id", "FTI_Id" INTO v_FSS_IdNew, v_FTI_Id 
                FROM "fee_student_status" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "AMST_Id" = v_AMST_Id 
                    AND "FMH_Id" = v_FMH_Id 
                    AND "ASMAY_Id" = p_Nasmay_id 
                    AND "FTI_Id" = v_FTI_ids 
                LIMIT 1;

                IF (COALESCE(v_FSS_IdNew, 0) <> 0) THEN
                    UPDATE "Fee_Student_Status" 
                    SET "FSS_OBArrearAmount" = v_ToBePaid,
                        "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + v_ToBePaid,
                        "FSS_ToBePaid" = "FSS_ToBePaid" + v_ToBePaid 
                    WHERE "FSS_Id" = v_FSS_IdNew 
                        AND "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_Nasmay_id 
                        AND "AMST_Id" = v_AMST_Id 
                        AND "FMH_Id" = v_FMH_Id 
                        AND "FTI_Id" = v_FTI_ids;
                ELSE
                    IF (COALESCE(v_FSS_IdNew, 0) = 0) THEN
                        FOR rec_obupdate IN
                            SELECT "Fee_Student_Status"."AMST_Id", "Fee_Master_Head"."FMH_Id", SUM("FSS_ToBePaid") AS "ToBePaid"
                            FROM "Fee_Master_Group"
                            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" AND "Fee_Master_Group"."MI_Id" = p_mi_id
                            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" AND "Fee_Master_Head"."MI_Id" = p_mi_id
                            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = p_mi_id
                            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = p_Lasmay_id AND "AMAY_ActiveFlag" = 1
                            WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_Lasmay_id 
                                AND "fee_student_status"."MI_Id" = p_mi_id 
                                AND "fee_student_status"."ASMAY_Id" = p_Lasmay_id 
                                AND "fee_student_status"."AMST_Id" = v_ACT_AMST_Id
                                AND "Fee_Master_Head"."FMH_Id" = v_FMH_Id 
                                AND "Fee_Student_Status"."FMH_Id" = v_FMH_Id
                            GROUP BY "Fee_Student_Status"."AMST_Id", "Fee_Master_Head"."FMH_Id"
                            HAVING SUM("FSS_ToBePaid") > 0
                        LOOP
                            v_AMST_Id := rec_obupdate."AMST_Id";
                            v_OBFMH_Id := rec_obupdate."FMH_Id";
                            v_Totaltobepaid := rec_obupdate."ToBePaid";

                            SELECT "FMG_Id" INTO v_FMG_IdN 
                            FROM "Fee_Master_Group" 
                            WHERE "FMG_GroupName" = 'Pending School Fee(21-22)' 
                                AND "MI_Id" = p_mi_id;

                            IF (v_FMH_FeeName = 'Tuition Fee') THEN
                                SELECT "FMH_Id" INTO v_FMH_IdN 
                                FROM "Fee_Master_Head" 
                                WHERE "FMH_FeeName" = 'Tuition Fee(OB)(21-22)' 
                                    AND "MI_Id" = p_mi_id;
                            END IF;

                            IF (v_FMH_FeeName = 'Term Fee') THEN
                                SELECT "FMH_Id" INTO v_FMH_IdN 
                                FROM "Fee_Master_Head" 
                                WHERE "FMH_FeeName" = 'Term Fee(OB)(21-22)' 
                                    AND "MI_Id" = p_mi_id;
                            END IF;

                            IF (v_FMH_FeeName = 'Special Dev Fee') THEN
                                SELECT "FMH_Id" INTO v_FMH_IdN 
                                FROM "Fee_Master_Head" 
                                WHERE "FMH_FeeName" = 'Special Dev Fee(OB)(21-22)' 
                                    AND "MI_Id" = p_mi_id;
                            END IF;

                            IF (v_FMH_FeeName = 'Caution Deposit') THEN
                                SELECT "FMH_Id" INTO v_FMH_IdN 
                                FROM "Fee_Master_Head" 
                                WHERE "FMH_FeeName" = 'Caution Deposit(OB)(21-22)' 
                                    AND "MI_Id" = p_mi_id;
                            END IF;

                            IF (v_FMH_FeeName = 'Language Fee') THEN
                                SELECT "FMH_Id" INTO v_FMH_IdN 
                                FROM "Fee_Master_Head" 
                                WHERE "FMH_FeeName" = 'Language Fee(OB)(21-22)' 
                                    AND "MI_Id" = p_mi_id;
                            END IF;

                            IF (v_FMH_FeeName = 'Readmission Fee') THEN
                                SELECT "FMH_Id" INTO v_FMH_IdN 
                                FROM "Fee_Master_Head" 
                                WHERE "FMH_FeeName" = 'Readmission Fee(OB)(21-22)' 
                                    AND "MI_Id" = p_mi_id;
                            END IF;

                            SELECT "ASMCL_Id" INTO v_ASMCL_Id 
                            FROM "Adm_School_Y_Student" 
                            WHERE "AMST_Id" = v_AMST_Id 
                                AND "ASMAY_Id" = p_Nasmay_id;

                            SELECT DISTINCT "FMCC"."FMCC_Id" INTO v_FMCC_Id
                            FROM "Fee_Yearly_Class_Category_Classes" "Cclass"
                            INNER JOIN "Fee_Yearly_Class_Category" "YCC" ON "YCC"."FYCC_Id" = "Cclass"."FYCC_Id"
                            INNER JOIN "Fee_Master_Class_Category" "FMCC" ON "FMCC"."FMCC_Id" = "YCC"."FMCC_Id"
                            WHERE "ASMCL_Id" = v_ASMCL_Id 
                                AND "ASMAY_Id" = p_Nasmay_id;

                            SELECT "FMA_Id", "FTI_Id" INTO v_FMA_IdN, v_FTI_IdN 
                            FROM "Fee_Master_Amount"
                            WHERE "MI_Id" = p_mi_id 
                                AND "FMG_Id" = v_FMG_IdN 
                                AND "FMH_Id" = v_FMH_IdN 
                                AND "ASMAY_Id" = p_Nasmay_id 
                                AND "FMCC_Id" = v_FMCC_Id 
                                AND "FTI_Id" = 22;

                            INSERT INTO "Fee_Student_Status"(
                                "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", 
                                "FSS_OBExcessAmount", "FSS_ExcessPaidAmount", "FSS_RunningExcessAmount", 
                                "FSS_OBArrearAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid",
                                "FSS_PaidAmount", "FSS_ExcessAdjustedAmount", "FSS_ConcessionAmount", 
                                "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", 
                                "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", 
                                "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", 
                                "User_Id", "FSS_RefundableAmount", "FSS_OBTransferred", "FSS_ExcessTransferred"
                            )
                            VALUES(
                                p_MI_Id, p_Nasmay_id, v_AMST_Id, v_FMG_IdN, v_FMH_IdN, v_FTI_IdN, v_FMA_IdN,
                                0, 0, 0, v_Totaltobepaid, 0, v_Totaltobepaid, v_Totaltobepaid, 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, v_Totaltobepaid, 
                                0, 0, 0, 1, 0, 0, 0, 0
                            );

                        END LOOP;
                    END IF;
                END IF;

            END LOOP;

        END LOOP;

    END LOOP;

END;
$$;