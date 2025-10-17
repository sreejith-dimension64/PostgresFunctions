CREATE OR REPLACE FUNCTION "dbo"."Fee_OBTransferFeeHeadWise21-22OBTest"(
    p_mi_id bigint,
    p_Lasmay_id bigint,
    p_Nasmay_id bigint
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
    v_count bigint;
    v_FMSG_Id bigint;
    
    rec_studentslist RECORD;
    rec_CursorfeeNames RECORD;
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
            AND "SS"."AMST_Id" != 10720
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
                AND "Fee_Master_Head"."FMH_Id" = v_FMH_Idold 
                AND "Fee_Student_Status"."FSS_OBArrearAmount" = 0 
                AND "Fee_Student_Status"."AMST_Id" != 10720
        LOOP
            v_FMH_Id := rec_CursorfeeNames."FMH_Id";
            v_FMH_FeeName := rec_CursorfeeNames."FMH_FeeName";

            FOR rec_obupdate IN
                SELECT "Fee_Student_Status"."AMST_Id", "Fee_Master_Head"."FMH_Id", SUM("FSS_ToBePaid") AS "ToBePaid"
                FROM "Fee_Master_Group"
                INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
                    AND "Fee_Master_Group"."MI_Id" = p_mi_id
                INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                    AND "Fee_Master_Head"."MI_Id" = p_mi_id
                INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
                    AND "Adm_M_Student"."MI_Id" = p_mi_id
                INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" 
                    AND "Adm_School_Y_Student"."ASMAY_Id" = p_Lasmay_id 
                    AND "AMAY_ActiveFlag" = 1
                WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_Lasmay_id 
                    AND "fee_student_status"."MI_Id" = p_mi_id 
                    AND "fee_student_status"."ASMAY_Id" = p_Lasmay_id
                    AND "Fee_Master_Head"."FMH_Id" = v_FMH_Id 
                    AND "Fee_Student_Status"."FMH_Id" = v_FMH_Id 
                    AND "Fee_Student_Status"."AMST_Id" != 10720
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

                IF (v_FMH_Id = 132) THEN
                    SELECT "FMH_Id" INTO v_FMH_IdN 
                    FROM "Fee_Master_Head" 
                    WHERE "FMH_Id" = 356 AND "MI_Id" = p_mi_id;
                ELSIF (v_FMH_Id = 302) THEN
                    SELECT "FMH_Id" INTO v_FMH_IdN 
                    FROM "Fee_Master_Head" 
                    WHERE "FMH_Id" = 357 AND "MI_Id" = p_mi_id;
                ELSIF (v_FMH_Id = 303) THEN
                    SELECT "FMH_Id" INTO v_FMH_IdN 
                    FROM "Fee_Master_Head" 
                    WHERE "FMH_Id" = 358 AND "MI_Id" = p_mi_id;
                ELSIF (v_FMH_Id = 94) THEN
                    SELECT "FMH_Id" INTO v_FMH_IdN 
                    FROM "Fee_Master_Head" 
                    WHERE "FMH_Id" = 359 AND "MI_Id" = p_mi_id;
                ELSIF (v_FMH_Id = 110) THEN
                    SELECT "FMH_Id" INTO v_FMH_IdN 
                    FROM "Fee_Master_Head" 
                    WHERE "FMH_Id" = 360 AND "MI_Id" = p_mi_id;
                ELSIF (v_FMH_Id = 309) THEN
                    SELECT "FMH_Id" INTO v_FMH_IdN 
                    FROM "Fee_Master_Head" 
                    WHERE "FMH_Id" = 361 AND "MI_Id" = p_mi_id;
                END IF;

                SELECT "ASMCL_Id" INTO v_ASMCL_Id 
                FROM "Adm_School_Y_Student" 
                WHERE "AMST_Id" = v_AMST_Id AND "ASMAY_Id" = p_Nasmay_id;

                SELECT DISTINCT "FMCC"."FMCC_Id" INTO v_FMCC_Id
                FROM "Fee_Yearly_Class_Category_Classes" "Cclass"
                INNER JOIN "Fee_Yearly_Class_Category" "YCC" ON "YCC"."FYCC_Id" = "Cclass"."FYCC_Id"
                INNER JOIN "Fee_Master_Class_Category" "FMCC" ON "FMCC"."FMCC_Id" = "YCC"."FMCC_Id"
                WHERE "ASMCL_Id" = v_ASMCL_Id AND "ASMAY_Id" = p_Nasmay_id;

                SELECT "FMA_Id", "FTI_Id" INTO v_FMA_IdN, v_FTI_IdN 
                FROM "Fee_Master_Amount"
                WHERE "MI_Id" = p_mi_id 
                    AND "FMG_Id" = v_FMG_IdN 
                    AND "FMH_Id" = v_FMH_IdN 
                    AND "ASMAY_Id" = p_Nasmay_id 
                    AND "FMCC_Id" = v_FMCC_Id 
                    AND "FTI_Id" = 22;

                IF (v_FMA_IdN IS NOT NULL AND v_FMH_IdN IS NOT NULL) THEN
                    SELECT COUNT("FMOB_Id") INTO v_count 
                    FROM "Fee_Master_Opening_Balance"
                    WHERE "AMST_Id" = v_AMST_Id 
                        AND "ASMAY_Id" = p_Nasmay_id 
                        AND "MI_Id" = p_mi_id 
                        AND "fmg_id" = v_FMG_IdN 
                        AND "FMH_Id" = v_FMH_IdN 
                        AND "fti_id" = 22;

                    IF (v_count = 0) THEN
                        INSERT INTO "Fee_Master_Opening_Balance"(
                            "MI_Id", "AMST_Id", "ASMAY_Id", "FMH_Id", "FMOB_EntryDate", "FMOB_Student_Due", 
                            "FMOB_Institution_Due", "fmg_id", "fti_id", "User_Id", "FMOB_OBAsPerFY", 
                            "FMOB_OBDate", "FMOB_CBAsPerFY", "FMOB_CBDate"
                        ) VALUES (
                            p_MI_Id, v_AMST_Id, 83, v_FMH_IdN, CURRENT_TIMESTAMP, v_Totaltobepaid, 
                            0, 207, 22, 725, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP
                        );
                    END IF;

                    UPDATE "Fee_student_status" 
                    SET "FSS_OBArrearAmount" = v_Totaltobepaid,
                        "FSS_CurrentYrCharges" = v_Totaltobepaid,
                        "FSS_TotalToBePaid" = v_Totaltobepaid,
                        "FSS_ToBePaid" = v_Totaltobepaid,
                        "FSS_ActiveFlag" = 1
                    WHERE "MI_id" = 6 
                        AND "ASMAY_Id" = 83 
                        AND "FMG_Id" = 207 
                        AND "FMH_Id" = v_FMH_IdN 
                        AND "FTI_Id" = 22 
                        AND "FMA_Id" = v_FMA_IdN 
                        AND "AMST_Id" = v_AMST_Id;
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;

    RETURN;
END;
$$;