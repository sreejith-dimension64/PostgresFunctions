CREATE OR REPLACE FUNCTION "dbo"."Headwise_Salary"(
    p_MI_Id BIGINT,
    p_HRME_Id BIGINT DEFAULT 0,
    p_year VARCHAR(50),
    p_month TEXT
)
RETURNS TABLE(
    "HRMED_Name" VARCHAR,
    "Headwise_Amount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        "H"."HRMED_Name",
        SUM("SD"."HRESD_Amount") AS "Headwise_Amount"
    FROM "dbo"."HR_Employee_Salary" AS "S"
    INNER JOIN "dbo"."HR_Employee_Salary_Details" AS "SD" ON "S"."HRES_Id" = "SD"."HRES_Id"
    INNER JOIN "dbo"."HR_Master_EarningsDeductions" AS "H" ON "SD"."HRMED_Id" = "H"."HRMED_Id"
    INNER JOIN "dbo"."IVRM_Month" "M" ON "M"."IVRM_Month_Name" = "S"."HRES_Month"
    WHERE "S"."MI_Id" = p_MI_Id
        AND (p_HRME_Id = 0 OR "S"."HRME_Id" = p_HRME_Id)
        AND "S"."HRES_Year" = p_year
        AND "H"."HRMED_ActiveFlag" = 1
        AND "M"."IVRM_Month_Id" IN (
            SELECT CAST("Value" AS INTEGER)
            FROM "dbo"."Splitmonth"(p_month, ',')
        )
    GROUP BY "H"."HRMED_Name";

END;
$$;