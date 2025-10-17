CREATE OR REPLACE FUNCTION "dbo"."Fee_ObandExcessTr_Old"(
    p_mi_id bigint,
    p_Lasmay_id bigint,
    p_Nasmay_id bigint,
    p_amst_id1 bigint
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
    v_FMH_IdE bigint;
    v_FFTI_Id bigint;
    v_FMG_IdN bigint;
    v_FMH_IdN bigint;
    v_FMA_IdN bigint;
    v_FTI_IdN bigint;
    rec_feenames RECORD;
    rec_obamt RECORD;
    rec_runningex RECORD;
BEGIN

    FOR rec_feenames IN 
        SELECT DISTINCT "FMH_Id", "FMH_FeeName" 
        FROM "fee_master_head" 
        WHERE "mi_id" = p_mi_id AND "FMH_FeeName" NOT LIKE '%Excess%'
    LOOP
        v_FMH_Id := rec_feenames."FMH_Id";
        v_FMH_FeeName := rec_feenames."FMH_FeeName";

        FOR rec_obamt IN
            SELECT "Fee_Student_Status"."AMST_Id", "Fee_Master_Head"."FMH_Id", SUM("FSS_ToBePaid") AS ToBePaid
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
                AND "Fee_Master_Group"."MI_Id" = p_mi_id
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                AND "Fee_Master_Head"."MI_Id" = p_mi_id
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
                AND "Adm_M_Student"."MI_Id" = p_mi_id
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
                AND "Adm_School_Y_Student"."ASMAY_Id" = p_Lasmay_id
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_Lasmay_id 
                AND "fee_student_status"."MI_Id" = p_mi_id 
                AND "fee_student_status"."ASMAY_Id" = p_Lasmay_id 
                AND "fee_student_status"."AMST_Id" = p_amst_id1
                AND "Fee_Master_Head"."FMH_Id" = v_FMH_Id 
                AND "Fee_Student_Status"."FMH_Id" = v_FMH_Id
            GROUP BY "Fee_Student_Status"."AMST_Id", "Fee_Master_Head"."FMH_Id"
            HAVING SUM("FSS_ToBePaid") > 0
        LOOP
            v_AMST_Id := rec_obamt."AMST_Id";
            v_SFMH_Id := rec_obamt."FMH_Id";
            v_ToBePaid := rec_obamt.ToBePaid;

            SELECT "FSS_Id" INTO v_FSS_Id
            FROM "fee_student_status"
            WHERE "MI_Id" = p_MI_Id 
                AND "AMST_Id" = v_AMST_Id 
                AND "FMH_Id" = v_FMH_Id 
                AND "ASMAY_Id" = p_Lasmay_id
            ORDER BY "FTI_Id"
            LIMIT 1;

            UPDATE "Fee_Student_Status" 
            SET "FSS_OBTransferred" = v_ToBePaid 
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = p_Lasmay_id 
                AND "AMST_Id" = v_AMST_Id 
                AND "FMH_Id" = v_FMH_Id 
                AND "FSS_Id" = v_FSS_Id;

            v_FSS_IdNew := 0;
            SELECT "FSS_Id", "FTI_Id" INTO v_FSS_IdNew, v_FTI_Id
            FROM "fee_student_status"
            WHERE "MI_Id" = p_MI_Id 
                AND "AMST_Id" = v_AMST_Id 
                AND "FMH_Id" = v_FMH_Id 
                AND "ASMAY_Id" = p_Nasmay_id
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
                    AND "FTI_Id" = v_FTI_Id;
            ELSE
                SELECT MG."FMG_Id", HM."FMH_Id", MG."FMA_Id" 
                INTO v_FMG_IdN, v_FMH_IdN, v_FMA_IdN
                FROM "Fee_Yearly_Group_Head_Mapping" HM
                INNER JOIN "Fee_Master_Amount" MG ON HM."ASMAY_Id" = MG."ASMAY_Id" 
                    AND HM."MI_Id" = MG."MI_Id"
                WHERE HM."MI_Id" = p_MI_Id 
                    AND HM."ASMAY_Id" = p_Nasmay_id 
                    AND HM."FYGHM_ActiveFlag" = 1
                LIMIT 1;

                INSERT INTO "Fee_Student_Status"("MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBArrearAmount","FSS_TotalToBePaid","FSS_ToBePaid","FSS_OBExcessAmount","FSS_CurrentYrCharges","FSS_PaidAmount","FSS_ExcessPaidAmount","FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id","FSS_RefundableAmount","FSS_OBTransferred","FSS_ExcessTransferred")
                VALUES(p_MI_Id,p_Nasmay_id,v_AMST_Id,v_FMG_IdN,v_FMH_IdN,v_FTI_IdN,v_FMA_IdN,v_ToBePaid,v_ToBePaid,v_ToBePaid,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
            END IF;

            SELECT "FMH_Id" INTO v_FMH_IdE
            FROM "fee_Master_Head"
            WHERE "MI_Id" = p_MI_Id 
                AND "FMH_FeeName" LIKE '%Excess%';

            FOR rec_runningex IN
                SELECT "AMST_Id", "FSS_PaidAmount" + "FSS_RunningExcessAmount" AS RunningExcess
                FROM "fee_student_status"
                WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_Lasmay_id 
                    AND "FMH_Id" = v_FMH_IdE
                    AND ("FSS_RunningExcessAmount" > 0 OR "FSS_PaidAmount" > 0)
            LOOP
                v_RAMST_Id := rec_runningex."AMST_Id";
                v_FSS_RunningExcessAmount := rec_runningex.RunningExcess;

                UPDATE "fee_student_status" 
                SET "FSS_ExcessTransferred" = v_FSS_RunningExcessAmount 
                WHERE "FSS_Id" = v_FSS_Id 
                    AND "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_Lasmay_id 
                    AND "FMH_Id" = v_FMH_IdE 
                    AND "AMST_Id" = v_RAMST_Id;

                v_FSS_IdNew := 0;
                SELECT "FSS_Id", "FTI_Id" INTO v_FSS_IdNew, v_FTI_Id
                FROM "fee_student_status"
                WHERE "MI_Id" = p_MI_Id 
                    AND "AMST_Id" = v_RAMST_Id 
                    AND "FMH_Id" = v_FMH_IdE 
                    AND "ASMAY_Id" = p_Nasmay_id
                LIMIT 1;

                IF (COALESCE(v_FSS_IdNew, 0) <> 0) THEN
                    UPDATE "Fee_Student_Status" 
                    SET "FSS_OBExcessAmount" = v_FSS_RunningExcessAmount,
                        "FSS_ExcessPaidAmount" = v_FSS_RunningExcessAmount,
                        "FSS_RunningExcessAmount" = v_FSS_RunningExcessAmount
                    WHERE "FSS_Id" = v_FSS_IdNew 
                        AND "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_Nasmay_id 
                        AND "AMST_Id" = v_RAMST_Id 
                        AND "FMH_Id" = v_FMH_IdE;
                ELSE
                    SELECT MG."FMG_Id", HM."FMH_Id", MG."FMA_Id" 
                    INTO v_FMG_IdN, v_FMH_IdN, v_FMA_IdN
                    FROM "Fee_Yearly_Group_Head_Mapping" HM
                    INNER JOIN "Fee_Master_Amount" MG ON HM."ASMAY_Id" = MG."ASMAY_Id" 
                        AND HM."MI_Id" = MG."MI_Id"
                    WHERE HM."MI_Id" = p_MI_Id 
                        AND HM."ASMAY_Id" = p_Nasmay_id 
                        AND HM."FYGHM_ActiveFlag" = 1
                    LIMIT 1;

                    INSERT INTO "Fee_Student_Status"("MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBExcessAmount","FSS_ExcessPaidAmount","FSS_RunningExcessAmount","FSS_OBArrearAmount","FSS_CurrentYrCharges","FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessAdjustedAmount","FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount","FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag","User_Id","FSS_RefundableAmount","FSS_OBTransferred","FSS_ExcessTransferred")
                    VALUES(p_MI_Id,p_Nasmay_id,v_AMST_Id,v_FMG_IdN,v_FMH_IdN,v_FTI_IdN,v_FMA_IdN,v_FSS_RunningExcessAmount,v_FSS_RunningExcessAmount,v_FSS_RunningExcessAmount,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;

    RETURN;
END;
$$;