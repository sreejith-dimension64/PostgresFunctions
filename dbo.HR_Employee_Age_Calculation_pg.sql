CREATE OR REPLACE FUNCTION "dbo"."HR_Employee_Age_Calculation"(
    p_year VARCHAR,
    p_month VARCHAR,
    p_MI_ID VARCHAR,
    p_HRME_ID BIGINT
)
RETURNS TABLE (
    "Age" BIGINT,
    "HRES_WorkingDays" BIGINT,
    "HRME_ID" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_SUMAMOUNT DECIMAL(18,2);
    v_PENSIONAMOUNT DECIMAL(18,2);
    v_HRME_ID_CUR1 BIGINT;
    v_HRES_ID_CUR1 BIGINT;
    v_BASICPAY DECIMAL(18,2);
    v_DA DECIMAL(18,2);
    v_PERSONALPAY DECIMAL(18,2);
    v_CLAMT DECIMAL(18,2);
    v_AGE INT;
    v_HRES_WorkingDays INT;
    v_HRME_FPFNotApplicableFlg BOOLEAN;
    v_RETIREDATE DATE;
    v_MONTHID BIGINT;
    v_flag BOOLEAN;
    v_WorkingDay BIGINT;
    v_REFDATE DATE;
    v_WorkedDays BIGINT;
    v_PFAMOUNT DECIMAL(18,2);
    v_SCHOOLPF DECIMAL(18,2);
    v_PFSAL DECIMAL(18,2);
    v_EDLISAL DECIMAL(18,2);
    v_PENSIONSAL DECIMAL(18,2);
BEGIN

    DROP TABLE IF EXISTS "AgeWorkingday";
    
    CREATE TEMP TABLE "AgeWorkingday" (
        "Age" BIGINT,
        "HRES_WorkingDays" BIGINT,
        "HRME_ID" BIGINT
    );

    SELECT "HRES_WorkingDays" INTO v_WorkedDays 
    FROM "HR_Employee_Salary" 
    WHERE "HRME_Id" = p_HRME_Id 
        AND "HRES_Year" = p_YEAR 
        AND "HRES_Month" = p_month;

    SELECT "IVRM_Month_Id" INTO v_MONTHID 
    FROM "IVRM_Month" 
    WHERE "IVRM_Month_Name" = p_month;

    SELECT ("HRME_DOB" + INTERVAL '58 years' - INTERVAL '1 day')::DATE INTO v_RETIREDATE 
    FROM "HR_Master_Employee" 
    WHERE "HRME_ID" = p_HRME_Id 
        AND "HRME_ActiveFlag" = TRUE;

    IF (DATE_TRUNC('month', (p_year || '-' || v_MONTHID || '-01')::DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE = v_RETIREDATE THEN
        
        RAISE NOTICE '1 condition';
        
        v_REFDATE := v_RETIREDATE;
        v_HRES_WorkingDays := EXTRACT(DAY FROM v_RETIREDATE)::INT;

        IF v_HRES_WorkingDays > 30 THEN
            v_HRES_WorkingDays := 30;
        END IF;

    ELSIF v_RETIREDATE < (DATE_TRUNC('month', (p_year || '-' || v_MONTHID || '-01')::DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE THEN

        v_Flag := FALSE;
        
        IF EXTRACT(MONTH FROM v_RETIREDATE) = v_MONTHID AND EXTRACT(YEAR FROM v_RETIREDATE)::INT = p_year::INT THEN
            v_HRES_WorkingDays := EXTRACT(DAY FROM v_RETIREDATE)::INT;
            v_Flag := FALSE;
        ELSE
            v_HRES_WorkingDays := 0;
            v_Flag := TRUE;
        END IF;

        IF v_HRES_WorkingDays <= 30 THEN
            
            IF v_Flag = FALSE THEN
                v_HRES_WorkingDays := EXTRACT(DAY FROM v_RETIREDATE)::INT;
                SELECT ("HRME_DOB" + INTERVAL '58 years')::DATE INTO v_REFDATE 
                FROM "HR_Master_Employee" 
                WHERE "HRME_ID" = p_HRME_Id 
                    AND "HRME_ActiveFlag" = TRUE;
            ELSE
                v_HRES_WorkingDays := 0;
                v_REFDATE := (DATE_TRUNC('month', (p_year || '-' || v_MONTHID || '-01')::DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE;
            END IF;

        ELSIF v_HRES_WorkingDays > 30 THEN
            v_HRES_WorkingDays := 30;
            v_REFDATE := (DATE_TRUNC('month', (p_year || '-' || v_MONTHID || '-01')::DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE;
        ELSE
            v_HRES_WorkingDays := 0;
            v_REFDATE := (DATE_TRUNC('month', (p_year || '-' || v_MONTHID || '-01')::DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE;
        END IF;

        RAISE NOTICE '2 condition';

    ELSIF v_RETIREDATE > (DATE_TRUNC('month', (p_year || '-' || v_MONTHID || '-01')::DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE THEN

        RAISE NOTICE '3 condition';

        v_HRES_WorkingDays := v_WorkedDays;
        
        IF v_HRES_WorkingDays > 30 THEN
            v_HRES_WorkingDays := 30;
        END IF;

        v_REFDATE := (DATE_TRUNC('month', (p_year || '-' || v_MONTHID || '-01')::DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE;

    END IF;

    RAISE NOTICE '%', v_REFDATE;

    SELECT 
        (EXTRACT(YEAR FROM AGE(v_REFDATE, "HRME_DOB"))::NUMERIC 
        + CASE 
            WHEN v_REFDATE >= MAKE_DATE(EXTRACT(YEAR FROM v_REFDATE)::INT, EXTRACT(MONTH FROM "HRME_DOB")::INT, EXTRACT(DAY FROM "HRME_DOB")::INT) THEN
                (EXTRACT(DAY FROM (v_REFDATE - MAKE_DATE(EXTRACT(YEAR FROM v_REFDATE)::INT, EXTRACT(MONTH FROM "HRME_DOB")::INT, EXTRACT(DAY FROM "HRME_DOB")::INT)))::NUMERIC
                / EXTRACT(DAY FROM ((MAKE_DATE(EXTRACT(YEAR FROM v_REFDATE)::INT + 1, 1, 1) - MAKE_DATE(EXTRACT(YEAR FROM v_REFDATE)::INT, 1, 1))))::NUMERIC)
            ELSE
                -1 * (-1.0 * EXTRACT(DAY FROM (v_REFDATE - MAKE_DATE(EXTRACT(YEAR FROM v_REFDATE)::INT, EXTRACT(MONTH FROM "HRME_DOB")::INT, EXTRACT(DAY FROM "HRME_DOB")::INT)))::NUMERIC
                / EXTRACT(DAY FROM ((MAKE_DATE(EXTRACT(YEAR FROM v_REFDATE)::INT + 1, 1, 1) - MAKE_DATE(EXTRACT(YEAR FROM v_REFDATE)::INT, 1, 1))))::NUMERIC)
        END)::INT,
        "HRME_FPFNotApplicableFlg"
    INTO v_AGE, v_HRME_FPFNotApplicableFlg
    FROM "HR_Master_Employee" 
    WHERE "HRME_Id" = p_HRME_Id;

    INSERT INTO "AgeWorkingday" VALUES(v_AGE, v_HRES_WorkingDays, p_HRME_ID);

    RETURN QUERY SELECT * FROM "AgeWorkingday";

END;
$$;