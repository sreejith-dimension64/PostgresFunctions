CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Adjustment_insert"(
    p_miid BIGINT,
    p_asmayid BIGINT,
    p_amstid BIGINT,
    p_fsa_date TIMESTAMP,
    p_fsa_flag BOOLEAN,
    p_INFO_ARRAYF "dbo"."FromadjustArray"[],
    p_INFO_ARRAYT "dbo"."ToadjustArray"[],
    p_userid BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FROM_FMG_id BIGINT;
    v_FROM_FMH_id BIGINT;
    v_FROM_FTI_id BIGINT;
    v_FROM_FMA_id BIGINT;
    v_TO_FMG_id BIGINT;
    v_TO_FMH_id BIGINT;
    v_TO_FTI_id BIGINT;
    v_TO_FMA_id BIGINT;
    v_adjamount BIGINT;
    v_RunningexcessAmount BIGINT;
    v_FSS_RefundableAmount BIGINT;
    v_FSS_RunningExcessAmount BIGINT;
    v_totalvalue BIGINT;
    v_rowcount INTEGER;
    fromtable_rec RECORD;
    totable_rec RECORD;
BEGIN
    CREATE TEMP TABLE IF NOT EXISTS temp_fromtable (
        "From_FMG_id" BIGINT,
        "From_FMH_id" BIGINT,
        "From_FTI_id" BIGINT,
        "From_FMA_id" BIGINT,
        "RunningExcessAmount" BIGINT,
        "FSS_RunningExcessAmount" BIGINT,
        "FSS_RefundableAmount" BIGINT
    ) ON COMMIT DROP;

    CREATE TEMP TABLE IF NOT EXISTS temp_totable (
        "To_FMG_id" BIGINT,
        "To_FMH_id" BIGINT,
        "To_FTI_id" BIGINT,
        "To_FMA_id" BIGINT,
        "adjustedamount" BIGINT
    ) ON COMMIT DROP;

    INSERT INTO temp_fromtable 
    SELECT DISTINCT f."From_FMG_id", f."From_FMH_id", f."From_FTI_id", f."From_FMA_id", f."RunningExcessAmount",
        s."FSS_RunningExcessAmount", s."FSS_RefundableAmount" 
    FROM unnest(p_INFO_ARRAYF) f
    INNER JOIN "dbo"."Fee_Student_Status" s
        ON s."MI_Id" = p_miid AND s."ASMAY_Id" = p_asmayid AND s."AMST_Id" = p_amstid 
        AND f."From_FMG_id" = s."FMG_Id" 
        AND f."From_FMH_id" = s."FMH_Id" AND f."From_FTI_id" = s."FTI_Id" 
        AND f."From_FMA_id" = s."FMA_Id" AND s."USER_ID" = p_userid
    WHERE f."RunningExcessAmount" > 0;

    INSERT INTO temp_totable 
    SELECT DISTINCT t."To_FMG_id", t."To_FMH_id", t."To_FTI_id", t."To_FMA_id", t."adjustedamount" 
    FROM unnest(p_INFO_ARRAYT) t
    INNER JOIN "dbo"."Fee_Student_Status" ss
        ON ss."MI_Id" = p_miid AND ss."ASMAY_Id" = p_asmayid AND ss."AMST_Id" = p_amstid 
        AND t."To_FMG_id" = ss."FMG_Id" 
        AND t."To_FMH_id" = ss."FMH_Id" AND t."To_FTI_id" = ss."FTI_Id" 
        AND t."To_FMA_id" = ss."FMA_Id" AND ss."USER_ID" = p_userid;

    FOR fromtable_rec IN 
        SELECT * FROM temp_fromtable WHERE "RunningExcessAmount" > 0
    LOOP
        v_FROM_FMG_id := fromtable_rec."From_FMG_id";
        v_FROM_FMH_id := fromtable_rec."From_FMH_id";
        v_FROM_FTI_id := fromtable_rec."From_FTI_id";
        v_FROM_FMA_id := fromtable_rec."From_FMA_id";
        v_RunningexcessAmount := fromtable_rec."RunningExcessAmount";
        v_FSS_RunningExcessAmount := fromtable_rec."FSS_RunningExcessAmount";
        v_FSS_RefundableAmount := fromtable_rec."FSS_RefundableAmount";

        RAISE NOTICE '%', v_FROM_FMG_id;
        RAISE NOTICE '%', v_FROM_FMH_id;
        RAISE NOTICE '%', v_FROM_FTI_id;
        RAISE NOTICE '%', v_FROM_FMA_id;
        RAISE NOTICE 'RunningexcessAmount : %', v_RunningexcessAmount;
        RAISE NOTICE 'FSS_RunningExcessAmount : %', v_FSS_RunningExcessAmount;
        RAISE NOTICE 'FSS_RefundableAmount :%', v_FSS_RefundableAmount;

        FOR totable_rec IN 
            SELECT * FROM temp_totable WHERE "adjustedamount" > 0
        LOOP
            v_TO_FMG_id := totable_rec."To_FMG_id";
            v_TO_FMH_id := totable_rec."To_FMH_id";
            v_TO_FTI_id := totable_rec."To_FTI_id";
            v_TO_FMA_id := totable_rec."To_FMA_id";
            v_adjamount := totable_rec."adjustedamount";

            RAISE NOTICE '%', v_TO_FMG_id;
            RAISE NOTICE '%', v_TO_FMH_id;
            RAISE NOTICE '%', v_TO_FTI_id;
            RAISE NOTICE '%', v_TO_FMA_id;
            RAISE NOTICE 'adjustedamount: %', v_adjamount;
            RAISE NOTICE 'RunningexcessAmount : %', v_RunningexcessAmount;
            RAISE NOTICE '------------Testing-------------';

            IF (v_adjamount >= v_RunningexcessAmount) THEN

                UPDATE temp_fromtable SET "RunningExcessAmount" = 0 
                WHERE "From_FMG_id" = v_FROM_FMG_id AND "From_FMH_id" = v_FROM_FMH_id 
                    AND "From_FTI_id" = v_FROM_FTI_id AND "From_FMA_id" = v_FROM_FMA_id;

                UPDATE temp_totable SET "adjustedamount" = (v_adjamount - v_RunningexcessAmount) 
                WHERE "To_FMG_id" = v_TO_FMG_id AND "To_FMH_id" = v_TO_FMH_id 
                    AND "To_FTI_id" = v_TO_FTI_id AND "To_FMA_id" = v_TO_FMA_id;

                SELECT COUNT(*) INTO v_rowcount 
                FROM "dbo"."Fee_Master_Head" 
                WHERE "FMH_Id" = v_FROM_FMH_id AND "FMH_RefundFlag" = TRUE;

                IF (v_rowcount = 1) THEN
                    IF (v_FSS_RefundableAmount > 0) THEN
                        UPDATE "dbo"."Fee_Student_Status" SET 
                            "FSS_RefundableAmount" = ("FSS_RefundableAmount" - v_RunningexcessAmount), 
                            "FSS_ExcessAdjustedAmount" = ("FSS_ExcessAdjustedAmount" + v_RunningexcessAmount) 
                        WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid AND "AMST_Id" = p_amstid 
                            AND "FMG_Id" = v_FROM_FMG_id 
                            AND "FMH_Id" = v_FROM_FMH_id AND "FTI_Id" = v_FROM_FTI_id 
                            AND "FMA_Id" = v_FROM_FMA_id AND "USER_ID" = p_userid;

                        UPDATE "dbo"."Fee_Student_Status" SET 
                            "FSS_ToBePaid" = ("FSS_ToBePaid" - v_RunningexcessAmount), 
                            "FSS_AdjustedAmount" = ("FSS_AdjustedAmount" + v_RunningexcessAmount) 
                        WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid AND "AMST_Id" = p_amstid 
                            AND "FMG_Id" = v_TO_FMG_id 
                            AND "FMH_Id" = v_TO_FMH_id AND "FTI_Id" = v_TO_FTI_id 
                            AND "FMA_Id" = v_TO_FMA_id AND "USER_ID" = p_userid;

                        RAISE NOTICE 'RunningexcessAmount : %', v_RunningexcessAmount;

                        INSERT INTO "dbo"."Fee_Student_Adjustment"(
                            "MI_Id", "ASMAY_Id", "AMST_Id", "FSA_From_FMG_Id", "FSA_From_FMH_Id", 
                            "FSA_From_FTI_Id", "FSA_From_FMA_Id", "FSA_AdjustedAmount", "FSA_To_FMG_Id", 
                            "FSA_To_FMH_Id", "FSA_To_FTI_Id", "FSA_To_FMA_Id", "FSA_Date", "FSA_ActiveFlag", 
                            "CreatedDate", "UpdatedDate", "User_Id"
                        ) VALUES (
                            p_miid, p_asmayid, p_amstid, v_FROM_FMG_id, v_FROM_FMH_id, v_FROM_FTI_id, 
                            v_FROM_FMA_id, v_RunningexcessAmount, v_TO_FMG_id, v_TO_FMH_id, v_TO_FTI_id, 
                            v_TO_FMA_id, p_fsa_date, p_fsa_flag, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid
                        );
                    END IF;
                ELSE
                    IF (v_FSS_RunningExcessAmount > 0) THEN
                        UPDATE "dbo"."Fee_Student_Status" SET 
                            "FSS_RunningExcessAmount" = ("FSS_RunningExcessAmount" - v_RunningexcessAmount), 
                            "FSS_ExcessAdjustedAmount" = ("FSS_ExcessAdjustedAmount" + v_RunningexcessAmount) 
                        WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid AND "AMST_Id" = p_amstid 
                            AND "FMG_Id" = v_FROM_FMG_id 
                            AND "FMH_Id" = v_FROM_FMH_id AND "FTI_Id" = v_FROM_FTI_id 
                            AND "FMA_Id" = v_FROM_FMA_id AND "USER_ID" = p_userid;

                        UPDATE "dbo"."Fee_Student_Status" SET 
                            "FSS_ToBePaid" = ("FSS_ToBePaid" - v_RunningexcessAmount), 
                            "FSS_AdjustedAmount" = ("FSS_AdjustedAmount" + v_RunningexcessAmount) 
                        WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid AND "AMST_Id" = p_amstid 
                            AND "FMG_Id" = v_TO_FMG_id 
                            AND "FMH_Id" = v_TO_FMH_id AND "FTI_Id" = v_TO_FTI_id 
                            AND "FMA_Id" = v_TO_FMA_id AND "USER_ID" = p_userid;

                        RAISE NOTICE 'RunningexcessAmount : %', v_RunningexcessAmount;

                        INSERT INTO "dbo"."Fee_Student_Adjustment"(
                            "MI_Id", "ASMAY_Id", "AMST_Id", "FSA_From_FMG_Id", "FSA_From_FMH_Id", 
                            "FSA_From_FTI_Id", "FSA_From_FMA_Id", "FSA_AdjustedAmount", "FSA_To_FMG_Id", 
                            "FSA_To_FMH_Id", "FSA_To_FTI_Id", "FSA_To_FMA_Id", "FSA_Date", "FSA_ActiveFlag", 
                            "CreatedDate", "UpdatedDate", "User_Id"
                        ) VALUES (
                            p_miid, p_asmayid, p_amstid, v_FROM_FMG_id, v_FROM_FMH_id, v_FROM_FTI_id, 
                            v_FROM_FMA_id, v_RunningexcessAmount, v_TO_FMG_id, v_TO_FMH_id, v_TO_FTI_id, 
                            v_TO_FMA_id, p_fsa_date, p_fsa_flag, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid
                        );
                    END IF;
                END IF;
                EXIT;
            ELSE
                RAISE NOTICE 'step1 started-----';
                RAISE NOTICE '%', v_FSS_RunningExcessAmount;
                RAISE NOTICE '%', p_miid;
                RAISE NOTICE '%', p_asmayid;
                RAISE NOTICE '%', p_amstid;
                RAISE NOTICE '%', v_FROM_FMG_id;
                RAISE NOTICE '%', v_FROM_FMH_id;
                RAISE NOTICE '%', v_FROM_FTI_id;
                RAISE NOTICE '%', v_FROM_FMA_id;
                RAISE NOTICE 'adjamount : %', v_adjamount;
                RAISE NOTICE '%', v_TO_FMG_id;
                RAISE NOTICE '%', v_TO_FMH_id;
                RAISE NOTICE '%', v_TO_FTI_id;
                RAISE NOTICE '%', v_TO_FMA_id;
                RAISE NOTICE '%', p_fsa_date;
                RAISE NOTICE '%', p_fsa_flag;
                RAISE NOTICE '%', p_userid;
                RAISE NOTICE '_______________________1 end';

                UPDATE temp_fromtable SET "RunningExcessAmount" = v_RunningexcessAmount - v_adjamount 
                WHERE "From_FMG_id" = v_FROM_FMG_id AND "From_FMH_id" = v_FROM_FMH_id 
                    AND "From_FTI_id" = v_FROM_FTI_id AND "From_FMA_id" = v_FROM_FMA_id;

                UPDATE temp_totable SET "adjustedamount" = 0 
                WHERE "To_FMG_id" = v_TO_FMG_id AND "To_FMH_id" = v_TO_FMH_id 
                    AND "To_FTI_id" = v_TO_FTI_id AND "To_FMA_id" = v_TO_FMA_id;

                SELECT COUNT(*) INTO v_rowcount 
                FROM "dbo"."Fee_Master_Head" 
                WHERE "FMH_Id" = v_FROM_FMH_id AND "FMH_RefundFlag" = TRUE;

                IF (v_rowcount = 1) THEN
                    IF (v_FSS_RefundableAmount > 0) THEN
                        UPDATE "dbo"."Fee_Student_Status" SET 
                            "FSS_RefundableAmount" = ("FSS_RefundableAmount" - v_adjamount), 
                            "FSS_ExcessAdjustedAmount" = ("FSS_ExcessAdjustedAmount" + v_adjamount)
                        WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid AND "AMST_Id" = p_amstid 
                            AND "FMG_Id" = v_FROM_FMG_id 
                            AND "FMH_Id" = v_FROM_FMH_id AND "FTI_Id" = v_FROM_FTI_id 
                            AND "FMA_Id" = v_FROM_FMA_id AND "USER_ID" = p_userid;

                        UPDATE "dbo"."Fee_Student_Status" SET 
                            "FSS_ToBePaid" = ("FSS_ToBePaid" - v_adjamount), 
                            "FSS_AdjustedAmount" = ("FSS_AdjustedAmount" + v_adjamount)
                        WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid AND "AMST_Id" = p_amstid 
                            AND "FMG_Id" = v_TO_FMG_id 
                            AND "FMH_Id" = v_TO_FMH_id AND "FTI_Id" = v_TO_FTI_id 
                            AND "FMA_Id" = v_TO_FMA_id AND "USER_ID" = p_userid;

                        INSERT INTO "dbo"."Fee_Student_Adjustment"(
                            "MI_Id", "ASMAY_Id", "AMST_Id", "FSA_From_FMG_Id", "FSA_From_FMH_Id", 
                            "FSA_From_FTI_Id", "FSA_From_FMA_Id", "FSA_AdjustedAmount", "FSA_To_FMG_Id", 
                            "FSA_To_FMH_Id", "FSA_To_FTI_Id", "FSA_To_FMA_Id", "FSA_Date", "FSA_ActiveFlag", 
                            "CreatedDate", "UpdatedDate", "User_Id"
                        ) VALUES (
                            p_miid, p_asmayid, p_amstid, v_FROM_FMG_id, v_FROM_FMH_id, v_FROM_FTI_id, 
                            v_FROM_FMA_id, v_adjamount, v_TO_FMG_id, v_TO_FMH_id, v_TO_FTI_id, 
                            v_TO_FMA_id, p_fsa_date, p_fsa_flag, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid
                        );
                    END IF;
                ELSE
                    RAISE NOTICE '------------------------step2';
                    RAISE NOTICE '%', v_FSS_RunningExcessAmount;
                    RAISE NOTICE '%', p_miid;
                    RAISE NOTICE '%', p_asmayid;
                    RAISE NOTICE '%', p_amstid;
                    RAISE NOTICE '%', v_FROM_FMG_id;
                    RAISE NOTICE '%', v_FROM_FMH_id;
                    RAISE NOTICE '%', v_FROM_FTI_id;
                    RAISE NOTICE '%', v_FROM_FMA_id;
                    RAISE NOTICE '%', v_adjamount;
                    RAISE NOTICE '--------------------to data';
                    RAISE NOTICE '%', v_TO_FMG_id;
                    RAISE NOTICE '%', v_TO_FMH_id;
                    RAISE NOTICE '%', v_TO_FTI_id;
                    RAISE NOTICE '%', v_TO_FMA_id;
                    RAISE NOTICE '%', p_fsa_date;
                    RAISE NOTICE '%', p_fsa_flag;
                    RAISE NOTICE '%', p_userid;
                    RAISE NOTICE '---------------------2end';

                    IF (v_FSS_RunningExcessAmount > 0) THEN
                        RAISE NOTICE 'adjamount: %', v_adjamount;

                        UPDATE "dbo"."Fee_Student_Status" SET 
                            "FSS_RunningExcessAmount" = ("FSS_RunningExcessAmount" - v_adjamount), 
                            "FSS_ExcessAdjustedAmount" = ("FSS_ExcessAdjustedAmount" + v_adjamount)
                        WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid AND "AMST_Id" = p_amstid 
                            AND "FMG_Id" = v_FROM_FMG_id 
                            AND "FMH_Id" = v_FROM_FMH_id AND "FTI_Id" = v_FROM_FTI_id 
                            AND "FMA_Id" = v_FROM_FMA_id AND "USER_ID" = p_userid;

                        UPDATE "dbo"."Fee_Student_Status" SET 
                            "FSS_ToBePaid" = ("FSS_ToBePaid" - v_adjamount), 
                            "FSS_AdjustedAmount" = ("FSS_AdjustedAmount" + v_adjamount) 
                        WHERE "MI_Id" = p_miid AND "ASMAY_Id" = p_asmayid AND "AMST_Id" = p_amstid 
                            AND "FMG_Id" = v_TO_FMG_id 
                            AND "FMH_Id" = v_TO_FMH_id AND "FTI_Id" = v_TO_FTI_id 
                            AND "FMA_Id" = v_TO_FMA_id AND "USER_ID" = p_userid;

                        INSERT INTO "dbo"."Fee_Student_Adjustment"(
                            "MI_Id", "ASMAY_Id", "AMST_Id", "FSA_From_FMG_Id", "FSA_From_FMH_Id", 
                            "FSA_From_FTI_Id", "FSA_From_FMA_Id", "FSA_AdjustedAmount", "FSA_To_FMG_Id", 
                            "FSA_To_FMH_Id", "FSA_To_FTI_Id", "FSA_To_FMA_Id", "FSA_Date", "FSA_ActiveFlag", 
                            "CreatedDate", "UpdatedDate", "User_Id"
                        ) VALUES (
                            p_miid, p_asmayid, p_amstid, v_FROM_FMG_id, v_FROM_FMH_id, v_FROM_FTI_id, 
                            v_FROM_FMA_id, v_adjamount, v_TO_FMG_id, v_TO_FMH_id, v_TO_FTI_id, 
                            v_TO_FMA_id, p_fsa_date, p_fsa_flag, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid
                        );
                    END IF;
                END IF;

                v_RunningexcessAmount := v_RunningexcessAmount - v_adjamount;

                RAISE NOTICE 'adjamount : %', v_adjamount;
                RAISE NOTICE 'RunningexcessAmount : %', v_RunningexcessAmount;
                RAISE NOTICE 'adjamount : %', v_adjamount;
                RAISE NOTICE '------------------------step5';
                RAISE NOTICE '%', v_FSS_RunningExcessAmount;
                RAISE NOTICE '%', p_miid;
                RAISE NOTICE '%', p_asmayid;
                RAISE NOTICE '%', p_amstid;
                RAISE NOTICE '%', v_FROM_FMG_id;
                RAISE NOTICE '%', v_FROM_FMH_id;
                RAISE NOTICE '%', v_FROM_FTI_id;
                RAISE NOTICE '%', v_FROM_FMA_id;
                RAISE NOTICE '%', v_adjamount;
                RAISE NOTICE '--------------------to data';
                RAISE NOTICE '%', v_TO_FMG_id;
                RAISE NOTICE '%', v_TO_FMH_id;
                RAISE NOTICE '%', v_TO_FTI_id;
                RAISE NOTICE '%', v_TO_FMA_id;
                RAISE NOTICE '%', p_fsa_date;
                RAISE NOTICE '%', p_fsa_flag;
                RAISE NOTICE '%', p_userid;
                RAISE NOTICE '---------------------5end';
            END IF;
        END LOOP;
    END LOOP;

    DROP TABLE IF EXISTS temp_fromtable;
    DROP TABLE IF EXISTS temp_totable;

    RETURN;
END;
$$;