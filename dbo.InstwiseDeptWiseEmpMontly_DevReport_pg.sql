CREATE OR REPLACE FUNCTION "dbo"."InstwiseDeptWiseEmpMontly_DevReport"(p_startDate date, p_endDate date)
RETURNS TABLE(
    "MI_Name" VARCHAR,
    "DeptName" VARCHAR,
    "HRME_Id" INTEGER,
    "EmpName" VARCHAR,
    "StartDate" DATE,
    "EndDate" DATE,
    "Total_Effort" VARCHAR,
    "Completed_Effort" VARCHAR,
    "Completed_Percentage" DECIMAL(18,2),
    "DevPer" DECIMAL(18,2),
    "EmpBonus" DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
BEGIN

DROP TABLE IF EXISTS "InstwiseDeptWiseEmpMontly_Dev_temp";
DROP TABLE IF EXISTS "EMPBonus_Temp";

CREATE TEMP TABLE "InstwiseDeptWiseEmpMontly_Dev_temp" AS
SELECT DISTINCT "MI_Name", "DeptName", "HRME_Id", "EmpName", p_startDate as "StartDate", p_endDate AS "EndDate",
(CAST(SUM("Total_Effort") as VARCHAR) || ' Hours') "Total_Effort",
(CAST((sum("Completed_Effort")) as VARCHAR) || ' Hours') "Completed_Effort",
(CAST(sum("Completed_Percentage")/count("ISMTPL_Id") AS DECIMAL(18,2))) as "Completed_Percentage",
CAST(sum("Deviation_Percentage")/count("ISMTPL_Id") AS DECIMAL(18,2)) "DevPer"
FROM (
    SELECT "MI"."MI_Name", "HRC"."HRMDC_Name" AS "DeptName", "HRC"."HRMDC_ID" "DeptId", "ITP"."HRME_Id", "ITP"."ISMTPL_Id", "ITP"."ISMTPL_PlannerName",
    (CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='' then '' else "HRME_EmployeeFirstName" end ||
     CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '' or "HRME_EmployeeMiddleName" = '0' then '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
     CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '' or "HRME_EmployeeLastName" = '0' then '' ELSE ' ' || "HRME_EmployeeLastName" END) as "EmpName",
    "ISMTPL_StartDate", "ISMTPL_EndDate",
    "ITP"."ISMTPL_TotalHrs" AS "Total_Effort",
    SUM("ITPT"."ISMTPLTA_EffortInHrs") AS "Completed_Effort",
    ("ITP"."ISMTPL_TotalHrs" - SUM("ITPT"."ISMTPLTA_EffortInHrs")) AS "NotCompleted_Effort",
    CAST((SUM("ITPT"."ISMTPLTA_EffortInHrs"))*100/(NULLIF("ITP"."ISMTPL_TotalHrs",0)) AS DECIMAL(18,2)) AS "Completed_Percentage",
    (CASE WHEN CAST((100-(SUM("ITPT"."ISMTPLTA_EffortInHrs"))*100/(NULLIF("ITP"."ISMTPL_TotalHrs",0))) AS DECIMAL(18,2))>0 
          THEN CAST((100-(SUM("ITPT"."ISMTPLTA_EffortInHrs"))*100/(NULLIF("ITP"."ISMTPL_TotalHrs",0))) AS DECIMAL(18,2)) 
          ELSE 0 END) AS "Deviation_Percentage"
    FROM "ISM_Task_Planner" "ITP"
    INNER JOIN "ISM_Task_Planner_Tasks" "ITPT" ON "ITPT"."ISMTPL_Id"="ITP"."ISMTPL_Id"
    INNER JOIN "ISM_TaskCreation" "ITC" ON "ITC"."ISMTCR_Id"="ITPT"."ISMTCR_Id"
    INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "ITP"."HRME_Id" AND "HME"."HRME_ActiveFlag"=true
    INNER JOIN "HR_Master_Department" "HD" ON "HD"."HRMD_Id"="HME"."HRMD_Id"
    LEFT OUTER JOIN "HR_Master_DepartmentCode" "HRC" on "HRC"."HRMDC_ID"="HD"."HRMDC_ID"
    INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id"="ITP"."MI_Id"
    WHERE "ITP"."HRME_Id" IN (select distinct "HRME_Id" from "HR_Master_Employee" where "HRME_LeftFlag"=0 and "HRME_ActiveFlag"=true)
    and "ITPT"."ISMTPLTA_Status"='Completed' 
    and CAST("ISMTPL_StartDate" AS DATE)>=p_startDate 
    and CAST("ISMTPL_EndDate" AS DATE)<=p_endDate
    GROUP BY "MI"."MI_Name", "ITP"."ISMTPL_Id", "ITP"."ISMTPL_TotalHrs", "ISMTPL_PlannerName", "HME"."HRME_EmployeeFirstName", 
             "ISMTPL_StartDate", "ISMTPL_EndDate", "ITP"."HRME_Id", "HRC"."HRMDC_ID",
             (CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='' then '' else "HRME_EmployeeFirstName" end ||
              CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '' or "HRME_EmployeeMiddleName" = '0' then '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
              CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '' or "HRME_EmployeeLastName" = '0' then '' ELSE ' ' || "HRME_EmployeeLastName" END),
             "HRMDC_Name", "HRC"."HRMDC_ID"
    ORDER BY "MI_Name", "DeptName", "HRME_EmployeeFirstName"
    LIMIT 100
) "New" 
GROUP BY "MI_Name", "DeptName", "EmpName", "HRME_Id";

CREATE TEMP TABLE "EMPBonus_Temp" AS
select "MI_Name", "HRMD_DepartmentName", "HRME_Id", "EmpName", SUM("BonusAmt") "BonusAmount" 
FROM (
    select "M"."MI_Name", "MD"."HRMD_DepartmentName",
    "H"."HRME_Id", 
    COALESCE("HRME_EmployeeFirstName",'') || COALESCE("HRME_EmployeeMiddleName",'') || COALESCE("HRME_EmployeeLastName",'') "EmpName",
    "ED"."HRMED_Name", "SD"."HRESD_Amount" "BonusAmt", "HRES_Month"
    FROM "HR_Master_Employee" "H"
    LEFT JOIN "HR_Employee_Salary" "ES" ON "ES"."HRME_Id"="H"."HRME_Id" and "H"."HRME_LeftFlag"=0 and "H"."HRME_ActiveFlag"=true
    LEFT JOIN "HR_Employee_Salary_Details" "SD" ON "SD"."HRES_Id"="ES"."HRES_Id"
    LEFT JOIN "HR_Master_EarningsDeductions" "ED" ON "ED"."HRMED_Id"="SD"."HRMED_Id"
    LEFT JOIN "Master_institution" "M" ON "M"."MI_Id"="H"."MI_Id"
    LEFT JOIN "HR_Master_Department" "MD" ON "MD"."HRMD_Id"="H"."HRMD_Id"
    WHERE TRIM("ES"."HRES_Year")=CAST(EXTRACT(YEAR FROM p_startDate) AS VARCHAR) 
    and TRIM("HRES_Month") = TO_CHAR(p_startDate, 'Month')
    and "HRMED_Name" IN ('Performance Bonus','Monitory Bonus')
) AS "New" 
group by "MI_Name", "HRMD_DepartmentName", "HRME_Id", "EmpName";

ALTER TABLE "InstwiseDeptWiseEmpMontly_Dev_temp" ADD COLUMN "EmpBonus" DECIMAL(18,2);

UPDATE "InstwiseDeptWiseEmpMontly_Dev_temp" "T" 
SET "EmpBonus"="S"."BonusAmount"
FROM "EMPBonus_Temp" "S" 
WHERE "T"."HRME_Id"="S"."HRME_Id";

RETURN QUERY 
SELECT 
    "T"."MI_Name",
    "T"."DeptName",
    "T"."HRME_Id",
    "T"."EmpName",
    "T"."StartDate",
    "T"."EndDate",
    "T"."Total_Effort",
    "T"."Completed_Effort",
    "T"."Completed_Percentage",
    "T"."DevPer",
    "T"."EmpBonus"
FROM "InstwiseDeptWiseEmpMontly_Dev_temp" "T";

END;
$$;