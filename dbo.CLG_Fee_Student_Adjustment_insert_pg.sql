CREATE OR REPLACE FUNCTION "dbo"."CLG_Fee_Student_Adjustment_insert"(
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
    v_from_record RECORD;
    v_to_record RECORD;
    v_temp_fromtable TEMP TABLE (
        "From_FMG_id" BIGINT,
        "From_FMH_id" BIGINT,
        "From_FTI_id" BIGINT,
        "From_FMA_id" BIGINT,
        "RunningExcessAmount" BIGINT,
        "FSS_RunningExcessAmount" BIGINT,
        "FSS_RefundableAmount" BIGINT
    );
    v_temp_totable TEMP TABLE (
        "To_FMG_id" BIGINT,
        "To_FMH_id" BIGINT,
        "To_FTI_id" BIGINT,
        "To_FMA_id" BIGINT,
        "adjustedamount" BIGINT
    );
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
    SELECT DISTINCT 
        f."From_FMG_id",
        f."From_FMH_id",
        f."From_FTI_id",
        f."From_FMA_id",
        f."RunningExcessAmount",
        s."FCSS_RunningExcessAmount",
        s."FCSS_RefundableAmount"
    FROM UNNEST(p_INFO_ARRAYF) AS f
    INNER JOIN "CLG"."Fee_College_Student_Status" s
        ON s."MI_Id" = p_miid 
        AND s."ASMAY_Id" = p_asmayid 
        AND s."AMCST_Id" = p_amstid 
        AND f."From_FMG_id" = s."FMG_Id"
        AND f."From_FMH_id" = s."FMH_Id" 
        AND f."From_FTI_id" = s."FTI_Id" 
        AND f."From_FMA_id" = s."FCMAS_Id" 
        AND s."USER_ID" = p_userid
    WHERE f."RunningExcessAmount" > 0;

    RAISE NOTICE 'From table contents';
    FOR v_from_record IN SELECT * FROM temp_fromtable LOOP
        RAISE NOTICE '%', v_from_record;
    END LOOP;

    INSERT INTO temp_totable
    SELECT DISTINCT 
        t."To_FMG_id",
        t."To_FMH_id",
        t."To_FTI_id",
        t."To_FMA_id",
        t."adjustedamount"
    FROM UNNEST(p_INFO_ARRAYT) AS t
    INNER JOIN "CLG"."Fee_College_Student_Status" ss
        ON ss."MI_Id" = p_miid 
        AND ss."ASMAY_Id" = p_asmayid 
        AND ss."AMCST_Id" = p_amstid 
        AND t."To_FMG_id" = ss."FMG_Id"
        AND t."To_FMH_id" = ss."FMH_Id" 
        AND t."To_FTI_id" = ss."FTI_Id" 
        AND t."To_FMA_id" = ss."FCMAS_Id" 
        AND ss."USER_ID" = p_userid;

    RAISE NOTICE 'To table contents';
    FOR v_to_record IN SELECT * FROM temp_totable LOOP
        RAISE NOTICE '%', v_to_record;
    END LOOP;

    FOR v_from_record IN 
        SELECT * FROM temp_fromtable WHERE "RunningExcessAmount" > 0
    LOOP
        v_FROM_FMG_id := v_from_record."From_FMG_id";
        v_FROM_FMH_id := v_from_record."From_FMH_id";
        v_FROM_FTI_id := v_from_record."From_FTI_id";
        v_FROM_FMA_id := v_from_record."From_FMA_id";
        v_RunningexcessAmount := v_from_record."RunningExcessAmount";
        v_FSS_RunningExcessAmount := v_from_record."FSS_RunningExcessAmount";
        v_FSS_RefundableAmount := v_from_record."FSS_RefundableAmount";

        RAISE NOTICE '%', v_FROM_FMG_id;
        RAISE NOTICE '%', v_FROM_FMH_id;
        RAISE NOTICE '%', v_FROM_FTI_id;
        RAISE NOTICE '%', v_FROM_FMA_id;
        RAISE NOTICE 'RunningexcessAmount : %', v_RunningexcessAmount;
        RAISE NOTICE 'FSS_RunningExcessAmount : %', v_FSS_RunningExcessAmount;
        RAISE NOTICE 'FSS_RefundableAmount : %', v_FSS_RefundableAmount;

        FOR v_to_record IN 
            SELECT * FROM temp_totable WHERE "adjustedamount" > 0
        LOOP
            v_TO_FMG_id := v_to_record."To_FMG_id";
            v_TO_FMH_id := v_to_record."To_FMH_id";
            v_TO_FTI_id := v_to_record."To_FTI_id";
            v_TO_FMA_id := v_to_record."To_FMA_id";
            v_adjamount := v_to_record."adjustedamount";

            RAISE NOTICE '%', v_TO_FMG_id;
            RAISE NOTICE '%', v_TO_FMH_id;
            RAISE NOTICE '%', v_TO_FTI_id;
            RAISE NOTICE '%', v_TO_FMA_id;
            RAISE NOTICE 'adjamount : %', v_adjamount;

            IF v_adjamount >= v_RunningexcessAmount THEN
                UPDATE temp_fromtable 
                SET "RunningExcessAmount" = 0 
                WHERE "From_FMG_id" = v_FROM_FMG_id 
                    AND "From_FMH_id" = v_FROM_FMH_id 
                    AND "From_FTI_id" = v_FROM_FTI_id 
                    AND "From_FMA_id" = v_FROM_FMA_id;

                UPDATE temp_totable 
                SET "adjustedamount" = (v_adjamount - v_RunningexcessAmount)
                WHERE "To_FMG_id" = v_TO_FMG_id 
                    AND "To_FMH_id" = v_TO_FMH_id 
                    AND "To_FTI_id" = v_TO_FTI_id 
                    AND "To_FMA_id" = v_TO_FMA_id;

                SELECT COUNT(*) INTO v_rowcount 
                FROM "Fee_Master_Head" 
                WHERE "FMH_Id" = v_FROM_FMH_id AND "FMH_RefundFlag" = TRUE;

                IF v_rowcount = 1 THEN
                    IF v_FSS_RefundableAmount > 0 THEN
                        UPDATE "CLG"."Fee_College_Student_Status"
                        SET "FCSS_RefundableAmount" = ("FCSS_RefundableAmount" - v_RunningexcessAmount),
                            "FCSS_ExcessAmountAdjusted" = ("FCSS_ExcessAmountAdjusted" + v_RunningexcessAmount)
                        WHERE "MI_Id" = p_miid 
                            AND "ASMAY_Id" = p_asmayid 
                            AND "AMCST_Id" = p_amstid 
                            AND "FMG_Id" = v_FROM_FMG_id
                            AND "FMH_Id" = v_FROM_FMH_id 
                            AND "FTI_Id" = v_FROM_FTI_id 
                            AND "FCMAS_Id" = v_FROM_FMA_id 
                            AND "USER_ID" = p_userid;

                        UPDATE "CLG"."Fee_College_Student_Status"
                        SET "FCSS_ToBePaid" = ("FCSS_ToBePaid" - v_RunningexcessAmount),
                            "FCSS_AdjustedAmount" = ("FCSS_AdjustedAmount" + v_RunningexcessAmount)
                        WHERE "MI_Id" = p_miid 
                            AND "ASMAY_Id" = p_asmayid 
                            AND "AMCST_Id" = p_amstid 
                            AND "FMG_Id" = v_TO_FMG_id
                            AND "FMH_Id" = v_TO_FMH_id 
                            AND "FTI_Id" = v_TO_FTI_id 
                            AND "FCMAS_Id" = v_TO_FMA_id 
                            AND "USER_ID" = p_userid;

                        INSERT INTO "CLG"."Fee_College_Student_Adjustment"(
                            "MI_Id", "ASMAY_Id", "AMCST_Id", "FCSA_From_FMG_Id", "FCSA_From_FMH_Id",
                            "FCSA_FromFTI_Id", "FCSA_FromFMA_Id", "FCSA_AdjustedAmount", 
                            "FCSA_To_FMG_Id", "FCSA_To_FMH_Id", "FCSA_ToFTI_Id", "FCSA_ToFMA_Id",
                            "FCSA_Date", "FCSA_ActiveFlag", "User_Id"
                        ) VALUES (
                            p_miid, p_asmayid, p_amstid, v_FROM_FMG_id, v_FROM_FMH_id,
                            v_FROM_FTI_id, v_FROM_FMA_id, v_RunningexcessAmount,
                            v_TO_FMG_id, v_TO_FMH_id, v_TO_FTI_id, v_TO_FMA_id,
                            p_fsa_date, p_fsa_flag, p_userid
                        );
                    END IF;
                ELSE
                    IF v_FSS_RunningExcessAmount > 0 THEN
                        UPDATE "CLG"."Fee_College_Student_Status"
                        SET "FCSS_RunningExcessAmount" = ("FCSS_RunningExcessAmount" - v_RunningexcessAmount),
                            "FCSS_ExcessAmountAdjusted" = ("FCSS_ExcessAmountAdjusted" + v_RunningexcessAmount)
                        WHERE "MI_Id" = p_miid 
                            AND "ASMAY_Id" = p_asmayid 
                            AND "AMCST_Id" = p_amstid 
                            AND "FMG_Id" = v_FROM_FMG_id
                            AND "FMH_Id" = v_FROM_FMH_id 
                            AND "FTI_Id" = v_FROM_FTI_id 
                            AND "FCMAS_Id" = v_FROM_FMA_id 
                            AND "USER_ID" = p_userid;

                        UPDATE "CLG"."Fee_College_Student_Status"
                        SET "FCSS_ToBePaid" = ("FCSS_ToBePaid" - v_RunningexcessAmount),
                            "FCSS_AdjustedAmount" = ("FCSS_AdjustedAmount" + v_RunningexcessAmount)
                        WHERE "MI_Id" = p_miid 
                            AND "ASMAY_Id" = p_asmayid 
                            AND "AMCST_Id" = p_amstid 
                            AND "FMG_Id" = v_TO_FMG_id
                            AND "FMH_Id" = v_TO_FMH_id 
                            AND "FTI_Id" = v_TO_FTI_id 
                            AND "FCMAS_Id" = v_TO_FMA_id 
                            AND "USER_ID" = p_userid;

                        INSERT INTO "CLG"."Fee_College_Student_Adjustment"(
                            "MI_Id", "ASMAY_Id", "AMCST_Id", "FCSA_From_FMG_Id", "FCSA_From_FMH_Id",
                            "FCSA_FromFTI_Id", "FCSA_FromFMA_Id", "FCSA_AdjustedAmount",
                            "FCSA_To_FMG_Id", "FCSA_To_FMH_Id", "FCSA_ToFTI_Id", "FCSA_ToFMA_Id",
                            "FCSA_Date", "FCSA_ActiveFlag", "User_Id"
                        ) VALUES (
                            p_miid, p_asmayid, p_amstid, v_FROM_FMG_id, v_FROM_FMH_id,
                            v_FROM_FTI_id, v_FROM_FMA_id, v_FSS_RunningExcessAmount,
                            v_TO_FMG_id, v_TO_FMH_id, v_TO_FTI_id, v_TO_FMA_id,
                            p_fsa_date, p_fsa_flag, p_userid
                        );
                    END IF;
                END IF;
                EXIT;
            ELSE
                UPDATE temp_fromtable 
                SET "RunningExcessAmount" = v_RunningexcessAmount - v_adjamount
                WHERE "From_FMG_id" = v_FROM_FMG_id 
                    AND "From_FMH_id" = v_FROM_FMH_id 
                    AND "From_FTI_id" = v_FROM_FTI_id 
                    AND "From_FMA_id" = v_FROM_FMA_id;

                FOR v_from_record IN SELECT * FROM temp_fromtable LOOP
                    RAISE NOTICE '%', v_from_record;
                END LOOP;

                UPDATE temp_totable 
                SET "adjustedamount" = 0
                WHERE "To_FMG_id" = v_TO_FMG_id 
                    AND "To_FMH_id" = v_TO_FMH_id 
                    AND "To_FTI_id" = v_TO_FTI_id 
                    AND "To_FMA_id" = v_TO_FMA_id;

                FOR v_to_record IN SELECT * FROM temp_totable LOOP
                    RAISE NOTICE '%', v_to_record;
                END LOOP;

                SELECT COUNT(*) INTO v_rowcount 
                FROM "Fee_Master_Head" 
                WHERE "FMH_Id" = v_FROM_FMH_id AND "FMH_RefundFlag" = TRUE;

                IF v_rowcount = 1 THEN
                    RAISE NOTICE '%', v_FSS_RunningExcessAmount;
                    RAISE NOTICE '%', p_miid;
                    RAISE NOTICE '%', p_asmayid;
                    RAISE NOTICE '%', p_amstid;
                    RAISE NOTICE '%', v_FROM_FMG_id;
                    RAISE NOTICE '%', v_FROM_FMH_id;
                    RAISE NOTICE '%', v_FROM_FTI_id;
                    RAISE NOTICE '%', v_FROM_FMA_id;
                    RAISE NOTICE '%', v_adjamount;
                    RAISE NOTICE '%', v_TO_FMG_id;
                    RAISE NOTICE '%', v_TO_FMH_id;
                    RAISE NOTICE '%', v_TO_FTI_id;
                    RAISE NOTICE '%', v_TO_FMA_id;
                    RAISE NOTICE '%', p_fsa_date;
                    RAISE NOTICE '%', p_fsa_flag;
                    RAISE NOTICE '%', p_userid;

                    IF v_FSS_RefundableAmount > 0 THEN
                        UPDATE "CLG"."Fee_College_Student_Status"
                        SET "FCSS_RefundableAmount" = ("FCSS_RefundableAmount" - v_adjamount),
                            "FCSS_ExcessAmountAdjusted" = ("FCSS_ExcessAmountAdjusted" + v_adjamount)
                        WHERE "MI_Id" = p_miid 
                            AND "ASMAY_Id" = p_asmayid 
                            AND "AMCST_Id" = p_amstid 
                            AND "FMG_Id" = v_FROM_FMG_id
                            AND "FMH_Id" = v_FROM_FMH_id 
                            AND "FTI_Id" = v_FROM_FTI_id 
                            AND "FCMAS_Id" = v_FROM_FMA_id 
                            AND "USER_ID" = p_userid;

                        UPDATE "CLG"."Fee_College_Student_Status"
                        SET "FCSS_ToBePaid" = ("FCSS_ToBePaid" - v_adjamount),
                            "FCSS_AdjustedAmount" = ("FCSS_AdjustedAmount" + v_adjamount)
                        WHERE "MI_Id" = p_miid 
                            AND "ASMAY_Id" = p_asmayid 
                            AND "AMCST_Id" = p_amstid 
                            AND "FMG_Id" = v_TO_FMG_id
                            AND "FMH_Id" = v_TO_FMH_id 
                            AND "FTI_Id" = v_TO_FTI_id 
                            AND "FCMAS_Id" = v_TO_FMA_id 
                            AND "USER_ID" = p_userid;

                        INSERT INTO "CLG"."Fee_College_Student_Adjustment"(
                            "MI_Id", "ASMAY_Id", "AMCST_Id", "FCSA_From_FMG_Id", "FCSA_From_FMH_Id",
                            "FCSA_FromFTI_Id", "FCSA_FromFMA_Id", "FCSA_AdjustedAmount",
                            "FCSA_To_FMG_Id", "FCSA_To_FMH_Id", "FCSA_ToFTI_Id", "FCSA_ToFMA_Id",
                            "FCSA_Date", "FCSA_ActiveFlag", "User_Id"
                        ) VALUES (
                            p_miid, p_asmayid, p_amstid, v_FROM_FMG_id, v_FROM_FMH_id,
                            v_FROM_FTI_id, v_FROM_FMA_id, v_adjamount,
                            v_TO_FMG_id, v_TO_FMH_id, v_TO_FTI_id, v_TO_FMA_id,
                            p_fsa_date, p_fsa_flag, p_userid
                        );
                    END IF;
                ELSE
                    IF v_FSS_RunningExcessAmount > 0 THEN
                        UPDATE "CLG"."Fee_College_Student_Status"
                        SET "FCSS_RunningExcessAmount" = ("FCSS_RunningExcessAmount" - v_adjamount),
                            "FCSS_ExcessAmountAdjusted" = ("FCSS_ExcessAmountAdjusted" + v_adjamount)
                        WHERE "MI_Id" = p_miid 
                            AND "ASMAY_Id" = p_asmayid 
                            AND "AMCST_Id" = p_amstid 
                            AND "FMG_Id" = v_FROM_FMG_id
                            AND "FMH_Id" = v_FROM_FMH_id 
                            AND "FTI_Id" = v_FROM_FTI_id 
                            AND "FCMAS_Id" = v_FROM_FMA_id 
                            AND "USER_ID" = p_userid;

                        UPDATE "CLG"."Fee_College_Student_Status"
                        SET "FCSS_ToBePaid" = ("FCSS_ToBePaid" - v_adjamount),
                            "FCSS_AdjustedAmount" = ("FCSS_AdjustedAmount" + v_adjamount)
                        WHERE "MI_Id" = p_miid 
                            AND "ASMAY_Id" = p_asmayid 
                            AND "AMCST_Id" = p_amstid 
                            AND "FMG_Id" = v_TO_FMG_id
                            AND "FMH_Id" = v_TO_FMH_id 
                            AND "FTI_Id" = v_TO_FTI_id 
                            AND "FCMAS_Id" = v_TO_FMA_id 
                            AND "USER_ID" = p_userid;

                        INSERT INTO "CLG"."Fee_College_Student_Adjustment"(
                            "MI_Id", "ASMAY_Id", "AMCST_Id", "FCSA_From_FMG_Id", "FCSA_From_FMH_Id",
                            "FCSA_FromFTI_Id", "FCSA_FromFMA_Id", "FCSA_AdjustedAmount",
                            "FCSA_To_FMG_Id", "FCSA_To_FMH_Id", "FCSA_ToFTI_Id", "FCSA_ToFMA_Id",
                            "FCSA_Date", "FCSA_ActiveFlag", "User_Id"
                        ) VALUES (
                            p_miid, p_asmayid, p_amstid, v_FROM_FMG_id, v_FROM_FMH_id,
                            v_FROM_FTI_id, v_FROM_FMA_id, v_adjamount,
                            v_TO_FMG_id, v_TO_FMH_id, v_TO_FTI_id, v_TO_FMA_id,
                            p_fsa_date, p_fsa_flag, p_userid
                        );
                    END IF;
                END IF;
                v_RunningexcessAmount := v_RunningexcessAmount - v_adjamount;
            END IF;
        END LOOP;
    END LOOP;

    DROP TABLE IF EXISTS temp_fromtable;
    DROP TABLE IF EXISTS temp_totable;
END;
$$;