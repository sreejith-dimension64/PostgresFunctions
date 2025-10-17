CREATE OR REPLACE FUNCTION "dbo"."Headwise_Salary_test"(
    "p_MI_Id" BIGINT,
    "p_HRME_Id" BIGINT DEFAULT 0,
    "p_year" VARCHAR(50),
    "p_month" TEXT
)
RETURNS TABLE(
    "HRMED_Name" VARCHAR,
    "Headwise_Amount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_SqlQuery" TEXT;
BEGIN
    "v_SqlQuery" := 
        'SELECT   
            H."HRMED_Name",  
            SUM(SD."HRESD_Amount") AS "Headwise_Amount"  
        FROM "HR_Employee_Salary" AS S
        INNER JOIN "HR_Employee_Salary_Details" AS SD ON S."HRES_Id" = SD."HRES_Id"  
        INNER JOIN "HR_Master_EarningsDeductions" AS H ON SD."HRMED_Id" = H."HRMED_Id"  
        WHERE S."MI_Id" = $1  
            AND S."HRME_Id" = $2  
            AND S."HRES_Year" = $3   
            AND H."HRMED_ActiveFlag" = true
            AND H."HRMED_Name" IN (' || "p_month" || ')
        GROUP BY H."HRMED_Name"';

    RETURN QUERY EXECUTE "v_SqlQuery" USING "p_MI_Id", "p_HRME_Id", "p_year";
END;
$$;