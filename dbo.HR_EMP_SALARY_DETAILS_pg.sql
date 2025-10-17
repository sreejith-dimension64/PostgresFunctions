CREATE OR REPLACE FUNCTION "HR_EMP_SALARY_DETAILS"(
    "@MI_ID" BIGINT,
    "@HRMES_YEAR" VARCHAR(200)
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT,
    "HRES_Month" VARCHAR,
    "HRES_WorkingDays" NUMERIC,
    "HRES_DailyRates" NUMERIC,
    "2017" NUMERIC,
    "2018" NUMERIC,
    "2019" NUMERIC,
    "2020" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@SQL" TEXT;
BEGIN
    "@SQL" := '
    SELECT * FROM CROSSTAB(
        ''SELECT "MI_Id", "HRME_Id", "HRES_Month", "HRES_WorkingDays", "HRES_DailyRates", "HRES_Year", "HRES_EPF"
          FROM "HR_Employee_Salary"
          ORDER BY 1, 2, 3, 4, 5, 6'',
        ''SELECT UNNEST(ARRAY[''''2017'''', ''''2018'''', ''''2019'''', ''''2020''''])''
    ) AS ct(
        "MI_Id" BIGINT,
        "HRME_Id" BIGINT,
        "HRES_Month" VARCHAR,
        "HRES_WorkingDays" NUMERIC,
        "HRES_DailyRates" NUMERIC,
        "2017" NUMERIC,
        "2018" NUMERIC,
        "2019" NUMERIC,
        "2020" NUMERIC
    )';
    
    RETURN QUERY EXECUTE "@SQL";
END;
$$;