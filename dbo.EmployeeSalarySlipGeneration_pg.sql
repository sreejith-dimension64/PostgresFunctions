CREATE OR REPLACE FUNCTION "dbo"."EmployeeSalarySlipGeneration"(
    p_HRME_ID BIGINT,
    p_MI_ID BIGINT,
    p_HRMLY_LeaveYear BIGINT,
    p_IVRM_Month_Name VARCHAR(20)
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "HRME_Id" BIGINT,
    "HRES_Year" BIGINT,
    "HRES_Month" VARCHAR,
    "HRMED_Id" BIGINT,
    "HRMED_EarnDedFlag" VARCHAR,
    "HRMED_AmountPercentFlag" VARCHAR,
    "HRMED_EDTypeFlag" VARCHAR,
    "HRMED_Name" VARCHAR,
    "Amount" NUMERIC,
    "HRMED_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HRES"."MI_Id",
        "HRES"."HRME_Id",
        "HRES"."HRES_Year",
        "HRES"."HRES_Month",
        "HRMED"."HRMED_Id",
        "HRMED"."HRMED_EarnDedFlag",
        "HRMED"."HRMED_AmountPercentFlag",
        "HRMED"."HRMED_EDTypeFlag",
        "HRMED"."HRMED_Name",
        ROUND(SUM("HRESD"."HRESD_Amount"),0) AS "Amount",
        "HRMED"."HRMED_Order"
    FROM 
        "HR_Employee_Salary" "HRES"
    LEFT JOIN 
        "HR_Employee_Salary_Details" "HRESD" ON "HRESD"."HRES_Id" = "HRES"."HRES_Id"
    INNER JOIN 
        "HR_Master_EarningsDeductions" "HRMED" ON "HRMED"."HRMED_Id" = "HRESD"."HRMED_Id"
    WHERE 
        "HRES"."MI_Id" = p_MI_ID 
        AND "HRES"."HRME_Id" = p_HRME_ID 
        AND "HRES"."HRES_Year" = p_HRMLY_LeaveYear 
        AND "HRES"."HRES_Month" = p_IVRM_Month_Name
        AND "HRMED"."HRMED_ActiveFlag" = 1 
        AND "HRMED"."HRMED_EarnDedFlag" != 'Gross'
    GROUP BY 
        "HRMED"."HRMED_Order",
        "HRES"."MI_Id",
        "HRES"."HRME_Id",
        "HRES"."HRES_Year",
        "HRES"."HRES_Month",
        "HRMED"."HRMED_Id",
        "HRMED"."HRMED_EarnDedFlag",
        "HRMED"."HRMED_AmountPercentFlag",
        "HRMED"."HRMED_EDTypeFlag",
        "HRMED"."HRMED_Name"
    ORDER BY 
        "HRMED"."HRMED_Order",
        "HRES"."MI_Id",
        "HRES"."HRME_Id",
        "HRES"."HRES_Year",
        "HRES"."HRES_Month",
        "HRMED"."HRMED_Id",
        "HRMED"."HRMED_EarnDedFlag",
        "HRMED"."HRMED_AmountPercentFlag",
        "HRMED"."HRMED_EDTypeFlag",
        "HRMED"."HRMED_Name";
END;
$$;