CREATE OR REPLACE FUNCTION "dbo"."Fees_TermsDuedatesmobileapp"(
    p_MI_Id bigint,
    p_asmay_id bigint,
    p_On_Date timestamp
)
RETURNS void
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
    v_Rcount bigint;
    rec_termids RECORD;
    rec_fmaids RECORD;
BEGIN

    v_frm_day := 0;
    p_On_Date := p_On_Date::date;

    SELECT EXTRACT(YEAR FROM "ASMAY_From_Date")::int,
           EXTRACT(YEAR FROM "ASMAY_To_Date")::int,
           EXTRACT(MONTH FROM "ASMAY_From_Date")::int,
           EXTRACT(MONTH FROM "ASMAY_To_Date")::int
    INTO v_Syear, v_Eyear, v_Smon, v_Emon
    FROM "Adm_School_M_Academic_Year"
    WHERE "ASMAY_Id" = p_asmay_id AND "MI_Id" = p_MI_Id;

    FOR rec_termids IN
        SELECT DISTINCT "FTI_Id", "FMT_Name", "FMT_Id"
        FROM (
            SELECT DISTINCT "FTI_Id", "FMT_Name", MT."FMT_Id", MT."FMT_Order"
            FROM "Fee_Master_Terms" MT
            INNER JOIN "Fee_Master_Terms_FeeHeads" TF ON MT."FMT_Id" = TF."FMT_Id"
                AND TF."MI_Id" = p_MI_Id
            WHERE MT."MI_Id" = p_MI_Id
            ORDER BY MT."FMT_Order"
            LIMIT 100
        ) AS "New"
    LOOP
        v_FTI_Id := rec_termids."FTI_Id";
        v_FMT_Name := rec_termids."FMT_Name";
        v_FMT_Id := rec_termids."FMT_Id";

        FOR rec_fmaids IN
            SELECT DISTINCT "FMH_Id", "FMA_Id"
            FROM "Fee_Master_Amount"
            WHERE "MI_Id" = p_MI_Id
                AND "FTI_Id" = v_FTI_Id
                AND "ASMAY_Id" = p_asmay_id
            ORDER BY "FMH_Id", "FMA_Id"
        LOOP
            v_FMH_Id := rec_fmaids."FMH_Id";
            v_FMA_Id := rec_fmaids."FMA_Id";

            SELECT "ftdd_day", "ftdd_month"
            INTO v_ftdd_day, v_ftdd_month
            FROM "fee_t_due_date"
            WHERE "FMA_Id" = v_FMA_Id;

            IF (v_ftdd_day <> 0 AND v_ftdd_month <> 0) THEN

                IF v_ftdd_month < v_Emon THEN
                    SELECT TO_CHAR("FMTFHDD_DueDate", 'DD/MM/YYYY')
                    INTO v_DueDate
                    FROM "Fee_Master_Terms_FeeHeads_DueDate" A
                    INNER JOIN "Fee_Master_Terms_FeeHeads" B ON A."FMTFH_Id" = B."FMTFH_Id"
                    WHERE A."ASMAY_Id" = p_asmay_id
                        AND B."FMT_Id" = v_FMT_Id
                        AND "FMH_Id" = v_FMH_Id
                        AND "FTI_Id" = v_FTI_Id;
                ELSE
                    SELECT TO_CHAR("FMTFHDD_DueDate", 'DD/MM/YYYY')
                    INTO v_DueDate
                    FROM "Fee_Master_Terms_FeeHeads_DueDate" A
                    INNER JOIN "Fee_Master_Terms_FeeHeads" B ON A."FMTFH_Id" = B."FMTFH_Id"
                    WHERE A."ASMAY_Id" = p_asmay_id
                        AND B."FMT_Id" = v_FMT_Id
                        AND "FMH_Id" = v_FMH_Id
                        AND "FTI_Id" = v_FTI_Id;
                END IF;

                RAISE NOTICE 'FMAID --> %', v_FMA_Id;
                RAISE NOTICE 'DueDate --> %   OnDate --> %', v_DueDate, p_On_Date;

                SELECT DISTINCT "FMT_Id"
                INTO v_FMT_Id
                FROM "Fee_Master_Terms" MT
                WHERE MT."MI_Id" = p_MI_Id AND MT."FMT_Name" = v_FMT_Name;

                SELECT "FMH_FeeName"
                INTO v_FMH_FeeName
                FROM "Fee_Master_Head"
                WHERE "MI_Id" = p_MI_Id AND "FMH_Id" = v_FMH_Id;

                v_Rcount := 0;

                SELECT COUNT(*)
                INTO v_Rcount
                FROM "FeeTermsDueDates"
                WHERE "MI_Id" = p_MI_Id
                    AND "ASMAY_Id" = p_asmay_id
                    AND "FMH_name" = v_FMH_FeeName
                    AND "FMT_Id" = v_FMT_Id
                    AND "FMT_Name" = v_FMT_Name
                    AND "FMA_Id" = v_FMA_Id
                    AND "DueDate" = TO_DATE(v_DueDate, 'DD/MM/YYYY')
                    AND "On_Date" = p_On_Date;

                IF (v_Rcount = 0) THEN
                    INSERT INTO "FeeTermsDueDates"
                    VALUES (p_MI_Id, p_asmay_id, v_FMH_FeeName, v_FMT_Id, v_FMT_Name, v_FMA_Id, TO_DATE(v_DueDate, 'DD/MM/YYYY'), p_On_Date);
                END IF;

            END IF;

        END LOOP;

    END LOOP;

END;
$$;