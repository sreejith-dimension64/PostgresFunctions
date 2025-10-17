CREATE OR REPLACE FUNCTION "dbo"."Get_due_Current_Due_Amount"(
    p_MI_Id bigint,
    p_asmay_id bigint
)
RETURNS TABLE(
    "FMT_Id" bigint,
    "FMT_Name" varchar(70),
    "DueDate" date,
    "DueAmount" numeric(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_DueDate varchar(10);
    v_NoOfDays int;
    v_Emon int;
    v_Smon int;
    v_Syear int;
    v_Eyear int;
    v_FMA_Id bigint;
    v_FTI_Id bigint;
    v_ftdd_day float;
    v_ftdd_month float;
    v_frm_day int;
    v_fmfs_from_day int;
    v_FMH_Id bigint;
    v_fmfs_to_day int;
    v_FMH_FeeName varchar(70);
    v_FTFS_Amount float;
    v_from_day int;
    v_FMT_Name varchar(70);
    v_FMT_Id bigint;
    v_On_Date TIMESTAMP;
    v_tobepaid decimal(18,2);
    termids_rec RECORD;
    fmaids_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "FeeDueAmount";

    CREATE TEMP TABLE "FeeDueAmount"(
        "MI_Id" bigint,
        "ASMAY_Id" bigint,
        "FMT_Id" bigint,
        "FMT_Name" varchar(70),
        "DueDate" date,
        "On_Date" date,
        "DueAmount" decimal(18,2)
    );

    v_frm_day := 0;
    v_On_Date := CURRENT_TIMESTAMP;

    SELECT 
        EXTRACT(YEAR FROM "ASMAY_From_Date"),
        EXTRACT(YEAR FROM "ASMAY_To_Date"),
        EXTRACT(MONTH FROM "ASMAY_From_Date"),
        EXTRACT(MONTH FROM "ASMAY_To_Date")
    INTO v_Syear, v_Eyear, v_Smon, v_Emon
    FROM "Adm_School_M_Academic_Year" 
    WHERE "asmay_id" = p_asmay_id AND "MI_Id" = p_MI_Id;

    FOR termids_rec IN 
        SELECT DISTINCT MT."FMT_Id", "FMT_Name", "FTI_Id" 
        FROM "Fee_Master_Terms" MT 
        INNER JOIN "Fee_Master_Terms_FeeHeads" TF ON MT."FMT_Id" = TF."FMT_Id" 
        AND TF."MI_Id" = p_MI_Id 
        WHERE MT."MI_Id" = p_MI_Id
    LOOP
        v_FMT_Id := termids_rec."FMT_Id";
        v_FMT_Name := termids_rec."FMT_Name";
        v_FTI_Id := termids_rec."FTI_Id";

        FOR fmaids_rec IN 
            SELECT DISTINCT FSS."FMH_Id", "FMA_Id", "FSS_ToBePaid" 
            FROM "fee_student_status" FSS
            INNER JOIN "Fee_Master_Terms_FeeHeads" TF ON FSS."FTI_Id" = TF."FTI_Id" 
            AND TF."MI_Id" = p_MI_Id
            WHERE FSS."MI_Id" = p_MI_Id 
            AND FSS."FTI_Id" = v_FTI_Id 
            AND "ASMAY_Id" = p_ASMAY_Id 
            ORDER BY "FMA_Id"
        LOOP
            v_fmh_id := fmaids_rec."FMH_Id";
            v_fma_id := fmaids_rec."FMA_Id";
            v_tobepaid := fmaids_rec."FSS_ToBePaid";

            SELECT "ftdd_day", "ftdd_month" 
            INTO v_ftdd_day, v_ftdd_month 
            FROM "Fee_T_due_date" 
            WHERE "FMA_Id" = v_FMA_Id;

            IF (v_ftdd_day <> 0 AND v_ftdd_month <> 0) THEN

                IF v_ftdd_month < v_Emon THEN
                    v_DueDate := LPAD(v_ftdd_day::varchar, 3, '0') || '/' || 
                                 LPAD(v_ftdd_month::varchar, 3, '0') || '/' || 
                                 LPAD(v_Eyear::varchar, 4, '0');
                ELSE
                    v_DueDate := LPAD(v_ftdd_day::varchar, 3, '0') || '/' || 
                                 LPAD(v_ftdd_month::varchar, 3, '0') || '/' || 
                                 LPAD(v_Syear::varchar, 4, '0');
                END IF;

                RAISE NOTICE 'FMAID --> % DueDate --> % OnDate --> %', v_FMA_Id, v_DueDate, v_on_date;

                INSERT INTO "FeeDueAmount" 
                VALUES(
                    p_MI_Id,
                    p_asmay_id,
                    v_FMT_Id,
                    v_FMT_Name,
                    TO_DATE(v_DueDate, 'DD/MM/YYYY'),
                    v_On_Date::date,
                    v_tobepaid
                );

            END IF;

        END LOOP;

    END LOOP;

    RETURN QUERY
    SELECT 
        "FMT_Id",
        "FMT_Name",
        "DueDate",
        SUM("DueAmount")::numeric(18,2) AS "DueAmount"
    FROM "FeeDueAmount" 
    WHERE "DueDate" = CURRENT_DATE 
    GROUP BY "FMT_Id", "FMT_Name", "DueDate";

END;
$$;