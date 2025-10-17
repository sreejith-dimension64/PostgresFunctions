CREATE OR REPLACE FUNCTION "dbo"."HR_employeesalaryearningdeductiondetails"(
    "HRMED_Id" bigint,
    "HRES_Id" bigint,
    "approvalflg" varchar(10)
)
RETURNS TABLE(
    "hresD_Id" bigint,
    "hreS_Id" bigint,
    "hrmeD_Id" bigint,
    "hrmeD_Name" varchar,
    "hresD_Amount" numeric,
    "hrmeD_EarnDedFlag" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF("approvalflg"='1') THEN

        RETURN QUERY
        SELECT b."HRESD_Id" as "hresD_Id",
               a."HRES_Id" as "hreS_Id",
               b."HRMED_Id" as "hrmeD_Id",
               c."HRMED_Name" as "hrmeD_Name",
               b."HRESD_Amount" as "hresD_Amount",
               c."HRMED_EarnDedFlag" as "hrmeD_EarnDedFlag"
        FROM "dbo"."HR_Employee_Salary" a
        INNER JOIN "dbo"."HR_Employee_Salary_Details" b ON a."HRES_Id"=b."HRES_Id"
        INNER JOIN "dbo"."HR_Master_EarningsDeductions" c ON b."HRMED_Id"=c."HRMED_Id"
        WHERE b."HRMED_Id"="HR_employeesalaryearningdeductiondetails"."HRMED_Id" 
          AND a."HRES_Id"="HR_employeesalaryearningdeductiondetails"."HRES_Id";

    ELSE

        RETURN QUERY
        SELECT b."HRESD_Id" as "hresD_Id",
               a."HRES_Id" as "hreS_Id",
               b."HRMED_Id" as "hrmeD_Id",
               c."HRMED_Name" as "hrmeD_Name",
               b."HRESD_Amount" as "hresD_Amount",
               c."HRMED_EarnDedFlag" as "hrmeD_EarnDedFlag"
        FROM "dbo"."HR_Employee_Salary" a
        INNER JOIN "dbo"."HR_Employee_Salary_Details" b ON a."HRES_Id"=b."HRES_Id"
        INNER JOIN "dbo"."HR_Master_EarningsDeductions" c ON b."HRMED_Id"=c."HRMED_Id"
        WHERE b."HRMED_Id"="HR_employeesalaryearningdeductiondetails"."HRMED_Id" 
          AND a."HRES_Id"="HR_employeesalaryearningdeductiondetails"."HRES_Id";

    END IF;

END;
$$;