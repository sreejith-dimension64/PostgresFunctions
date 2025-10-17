CREATE OR REPLACE FUNCTION "HR_Increment_Intimation_proc"(p_MI_Id bigint)
RETURNS TABLE(
    "EmployeeName" VARCHAR(500),
    "Employeecode" VARCHAR(500),
    "Employee_DOJ" DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRC_FixedIncrmentFlg BOOLEAN;
    v_HRC_MinimumWorkingPeriod BIGINT;
    v_HRC_IncrementMonth VARCHAR(500);
    v_HRC_IncrementOnceInMonths BIGINT;
    v_HRC_IncrementPercentage BIGINT;
    v_HRC_IncrementOnFlag VARCHAR(50);
    v_HRME_ID BIGINT;
    v_HRME_DOJ DATE;
    v_Employeeworkingperiod BIGINT;
    v_HREIC_IncrementDate DATE;
    v_Incrementperiod BIGINT;
    v_currentmonth VARCHAR(20);
    emp_record RECORD;
BEGIN
    v_currentmonth := TO_CHAR(CURRENT_TIMESTAMP, 'Month');
    v_currentmonth := TRIM(v_currentmonth);

    CREATE TEMP TABLE IF NOT EXISTS "Hrme_Temp"(
        "EmployeeName" VARCHAR(500),
        "Employeecode" VARCHAR(500),
        "Employee_DOJ" DATE
    ) ON COMMIT DROP;

    DELETE FROM "Hrme_Temp";

    FOR emp_record IN 
        SELECT "HRME_ID", "HRME_DOJ" 
        FROM "HR_Master_Employee" 
        WHERE "MI_Id" = p_MI_Id 
        AND "HRME_ActiveFlag" = true 
        AND "HRME_LeftFlag" = false
    LOOP
        v_HRME_ID := emp_record."HRME_ID";
        v_HRME_DOJ := emp_record."HRME_DOJ";

        SELECT "HRC_FixedIncrmentFlg", "HRC_MinimumWorkingPeriod", "HRC_IncrementMonth",
               "HRC_IncrementOnceInMonths", "HRC_IncrementPercentage", "HRC_IncrementOnFlag"
        INTO v_HRC_FixedIncrmentFlg, v_HRC_MinimumWorkingPeriod, v_HRC_IncrementMonth,
             v_HRC_IncrementOnceInMonths, v_HRC_IncrementPercentage, v_HRC_IncrementOnFlag
        FROM "HR_Configuration" 
        WHERE "MI_Id" = p_MI_Id;

        IF (v_HRC_FixedIncrmentFlg = true) THEN
            v_Employeeworkingperiod := EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) * 12 + 
                                       EXTRACT(MONTH FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ));

            IF (v_HRC_MinimumWorkingPeriod <= v_Employeeworkingperiod AND v_currentmonth = TRIM(v_HRC_IncrementMonth)) THEN
                INSERT INTO "Hrme_Temp"
                SELECT 
                    CONCAT(COALESCE("HRME_EmployeeFirstName",''), ' ', 
                           COALESCE("HRME_EmployeeMiddleName",''), ' ', 
                           COALESCE("HRME_EmployeeLastName",'')),
                    "HRME_EmployeeCode",
                    "HRME_DOJ"
                FROM "HR_Master_Employee" 
                WHERE "HRME_Id" = v_HRME_ID;
            END IF;

        ELSIF (v_HRC_FixedIncrmentFlg = false) THEN
            SELECT "HREIC_IncrementDate"
            INTO v_HREIC_IncrementDate
            FROM "HR_Employee_Increment" 
            WHERE "MI_Id" = p_MI_Id 
            AND "HRME_Id" = v_HRME_ID
            ORDER BY "HREIC_Id" DESC
            LIMIT 1;

            IF v_HREIC_IncrementDate IS NOT NULL THEN
                v_Incrementperiod := EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, v_HREIC_IncrementDate)) * 12 + 
                                    EXTRACT(MONTH FROM AGE(CURRENT_TIMESTAMP, v_HREIC_IncrementDate));

                IF (v_Incrementperiod = v_HRC_IncrementOnceInMonths) THEN
                    INSERT INTO "Hrme_Temp"
                    SELECT 
                        CONCAT(COALESCE("HRME_EmployeeFirstName",''), ' ', 
                               COALESCE("HRME_EmployeeMiddleName",''), ' ', 
                               COALESCE("HRME_EmployeeLastName",'')),
                        "HRME_EmployeeCode",
                        "HRME_DOJ"
                    FROM "HR_Master_Employee" 
                    WHERE "HRME_Id" = v_HRME_ID;
                END IF;
            END IF;
        END IF;
    END LOOP;

    RETURN QUERY SELECT * FROM "Hrme_Temp";

END;
$$;