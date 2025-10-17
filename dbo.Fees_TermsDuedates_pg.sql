CREATE OR REPLACE FUNCTION "dbo"."Fees_TermsDuedates"(
    p_MI_Id bigint,
    p_asmay_id bigint,
    p_On_Date timestamp
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_DueDate varchar(10);
    v_DueDate_N date;
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
    v_ftdd_month_N varchar(20);
    v_ftdd_day_N varchar(20);
    
    rec_termids RECORD;
    rec_fmaids RECORD;
BEGIN

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'feetermduedates' AND table_schema = 'dbo') THEN
        TRUNCATE TABLE "dbo"."FeeTermsDueDates";
    END IF;

    v_frm_day := 0;
    p_On_Date := p_On_Date::date;

    SELECT EXTRACT(YEAR FROM "ASMAY_From_Date")::int, 
           EXTRACT(YEAR FROM "ASMAY_To_Date")::int, 
           EXTRACT(MONTH FROM "ASMAY_From_Date")::int,
           EXTRACT(MONTH FROM "ASMAY_To_Date")::int
    INTO v_Syear, v_Eyear, v_Smon, v_Emon
    FROM "dbo"."Adm_School_M_Academic_Year" 
    WHERE "asmay_id" = p_asmay_id AND "MI_Id" = p_MI_Id;

    FOR rec_termids IN 
        SELECT DISTINCT "FTI_Id", "FMT_Name" 
        FROM "dbo"."Fee_Master_Terms" MT
        INNER JOIN "dbo"."Fee_Master_Terms_FeeHeads" TF ON MT."FMT_Id" = TF."FMT_Id"
        AND TF."MI_Id" = p_MI_Id 
        WHERE MT."MI_Id" = p_MI_Id
    LOOP
        v_FTI_Id := rec_termids."FTI_Id";
        v_FMT_Name := rec_termids."FMT_Name";

        FOR rec_fmaids IN 
            SELECT DISTINCT "fmh_id", "FMA_Id" 
            FROM "dbo"."fee_student_status" 
            WHERE "MI_Id" = p_MI_Id
            AND "FTI_Id" = v_FTI_Id 
            AND "asmay_id" = p_asmay_id 
            ORDER BY "FMA_Id"
        LOOP
            v_fmh_id := rec_fmaids."fmh_id";
            v_FMA_Id := rec_fmaids."FMA_Id";

            SELECT "ftdd_day", "ftdd_month" 
            INTO v_ftdd_day, v_ftdd_month
            FROM "dbo"."fee_t_due_date" 
            WHERE "FMA_Id" = v_FMA_Id;

            IF (v_ftdd_day <> 0 AND v_ftdd_month <> 0) THEN

                IF v_ftdd_month < v_Emon THEN

                    v_ftdd_month_N := CASE 
                        WHEN v_ftdd_month BETWEEN 0 AND 9 
                        THEN '0' || v_ftdd_month::varchar(3) 
                        ELSE v_ftdd_month::varchar(3) 
                    END;
                    
                    v_ftdd_day_N := CASE 
                        WHEN v_ftdd_day BETWEEN 0 AND 9 
                        THEN '0' || v_ftdd_day::varchar(3) 
                        ELSE v_ftdd_day::varchar(3) 
                    END;

                    v_DueDate := v_Eyear::varchar(4) || '-' || v_ftdd_month_N || '-' || v_ftdd_day_N;

                ELSE

                    v_ftdd_month_N := CASE 
                        WHEN v_ftdd_month BETWEEN 0 AND 9 
                        THEN '0' || v_ftdd_month::varchar(3) 
                        ELSE v_ftdd_month::varchar(3) 
                    END;
                    
                    v_ftdd_day_N := CASE 
                        WHEN v_ftdd_day BETWEEN 0 AND 9 
                        THEN '0' || v_ftdd_day::varchar(3) 
                        ELSE v_ftdd_day::varchar(3) 
                    END;

                    v_DueDate := v_Syear::varchar(4) || '-' || v_ftdd_month_N || '-' || v_ftdd_day_N;

                END IF;

                SELECT DISTINCT "FMT_Id" 
                INTO v_FMT_Id
                FROM "dbo"."Fee_Master_Terms" MT  
                WHERE MT."MI_Id" = p_MI_Id AND MT."FMT_Name" = v_FMT_Name;

                SELECT "FMH_FeeName" 
                INTO v_FMH_FeeName
                FROM "dbo"."Fee_Master_Head" 
                WHERE "MI_Id" = p_MI_Id AND "FMH_Id" = v_FMH_Id;

                INSERT INTO "dbo"."FeeTermsDueDates"(
                    "MI_Id", "asmay_id", "FMH_name", "FMT_Id", "FMT_Name", "FMA_Id", "DueDate", "On_Date"
                )
                VALUES(
                    p_MI_Id, p_asmay_id, v_FMH_FeeName, v_FMT_Id, v_FMT_Name, v_FMA_Id, v_DueDate, p_On_Date
                );

            END IF;

        END LOOP;

    END LOOP;

    RETURN;

END;
$$;