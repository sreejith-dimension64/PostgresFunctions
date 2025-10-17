CREATE OR REPLACE FUNCTION "dbo"."DUE_DATE_CALCULATION"(
    p_ASMAY_ID TEXT,
    p_FMT_Id TEXT,
    p_asmcl_id TEXT
)
RETURNS TABLE(duedate DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ftdd_day BIGINT;
    v_ftdd_month BIGINT;
    v_endyr BIGINT;
    v_startyr BIGINT;
    v_duedate TEXT;
    v_duedate1 TEXT;
    v_fromdate DATE;
    v_todate DATE;
    v_fmg_id TEXT;
    v_days VARCHAR(50);
    v_months VARCHAR(50);
    v_str1 TEXT;
    v_mi_new TEXT;
    v_mi TEXT;
    v_dt BIGINT;
    v_mt BIGINT;
    v_date1 DATE;
    v_rec RECORD;
BEGIN
    v_date1 := CURRENT_DATE;
    v_ftdd_day := 0;
    v_ftdd_month := 0;
    v_endyr := 0;
    v_startyr := 0;
    v_days := '0';
    v_months := '0';
    v_dt := 0;
    v_mt := 0;

    SELECT "MI_Id" INTO v_mi 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Id" = p_ASMAY_ID;

    DELETE FROM "v_duedate";

    FOR v_rec IN
        SELECT "Fee_T_Due_Date"."FTDD_Day", 
               "Fee_T_Due_Date"."FTDD_Month", 
               EXTRACT(YEAR FROM "Adm_School_M_Academic_Year"."ASMAY_From_Date")::BIGINT AS startyr,
               EXTRACT(YEAR FROM "Adm_School_M_Academic_Year"."ASMAY_To_Date")::BIGINT AS endyr, 
               "Adm_School_M_Academic_Year"."ASMAY_From_Date", 
               "Adm_School_M_Academic_Year"."ASMAY_To_Date"
        FROM "Fee_Master_Head" 
        INNER JOIN "Fee_Master_Amount" 
            INNER JOIN "Fee_Master_Group" 
                ON "Fee_Master_Amount"."FMG_Id" = "Fee_Master_Group"."FMG_Id" 
            INNER JOIN "Fee_Student_Status" 
                ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id" 
            ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Amount"."FMH_Id" 
        INNER JOIN "Fee_T_Due_Date" 
            ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Due_Date"."FMA_Id" 
        INNER JOIN "Adm_School_M_Academic_Year" 
            ON "Fee_Master_Amount"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        WHERE ("Fee_Master_Group"."FMG_Id" IN (
                SELECT DISTINCT "FMG_Id" 
                FROM "Fee_Student_Status" 
                WHERE "User_Id" = p_FMT_Id AND "MI_Id" = v_mi
            )) 
            AND ("Adm_School_M_Academic_Year"."ASMAY_Id" = p_ASMAY_ID) 
            AND ("Adm_School_M_Academic_Year"."MI_Id" = v_mi)
            AND "Fee_Master_Amount"."FMCC_Id" IN (
                SELECT DISTINCT "FMCC_Id" 
                FROM "Fee_Yearly_Class_Category" 
                WHERE "FYCC_Id" IN (
                    SELECT "FYCC_Id" 
                    FROM "Fee_Yearly_Class_Category_Classes" 
                    WHERE "ASMCL_Id" = p_asmcl_id
                )
            )
        GROUP BY "Fee_T_Due_Date"."FTDD_Day", 
                 "Fee_T_Due_Date"."FTDD_Month", 
                 "Adm_School_M_Academic_Year"."ASMAY_From_Date",
                 "Adm_School_M_Academic_Year"."ASMAY_To_Date", 
                 "Fee_Student_Status"."User_Id"
    LOOP
        v_ftdd_day := v_rec."FTDD_Day";
        v_ftdd_month := v_rec."FTDD_Month";
        v_startyr := v_rec.startyr;
        v_endyr := v_rec.endyr;
        v_fromdate := v_rec."ASMAY_From_Date";
        v_todate := v_rec."ASMAY_To_Date";

        IF v_ftdd_day = 0 OR v_ftdd_month = 0 THEN
            v_duedate := '';
            RETURN;
        ELSE
            v_duedate := v_startyr::TEXT || '-' || LPAD(v_ftdd_month::TEXT, 2, '0') || '-' || LPAD(v_ftdd_day::TEXT, 2, '0');
            v_duedate1 := v_endyr::TEXT || '-' || LPAD(v_ftdd_month::TEXT, 2, '0') || '-' || LPAD(v_ftdd_day::TEXT, 2, '0');
        END IF;

        IF v_duedate::DATE >= v_fromdate AND v_duedate::DATE <= v_todate THEN
            INSERT INTO "V_DueDate"("Duedate") VALUES(TO_CHAR(v_duedate::DATE, 'DD/MM/YYYY'));
        ELSIF v_duedate1::DATE >= v_fromdate AND v_duedate1::DATE <= v_todate THEN
            INSERT INTO "V_DueDate"("Duedate") VALUES(TO_CHAR(v_duedate1::DATE, 'DD/MM/YYYY'));
        END IF;
    END LOOP;

    RETURN QUERY
    SELECT DISTINCT TO_DATE("v_duedate"."Duedate", 'DD/MM/YYYY') AS duedate 
    FROM "v_duedate" 
    WHERE TO_DATE("v_duedate"."Duedate", 'DD/MM/YYYY') >= CURRENT_DATE;
END;
$$;