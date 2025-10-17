CREATE OR REPLACE FUNCTION "dbo"."DepartmentDesigWiseTaskEffort_Report"(
    "p_HRMD_Id" TEXT,
    "p_HRMDES_Id" TEXT
)
RETURNS TABLE(
    "EmployeeName" TEXT,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "ISMTCRASTO_StartDate" TIMESTAMP,
    "ISMTCRASTO_EndDate" TIMESTAMP,
    "AssignedByEmpName" TEXT,
    "ISMTCRASTO_EffortInHrs" NUMERIC,
    "ActualEffortInMins" NUMERIC,
    "ISMDRPT_Date" TIMESTAMP,
    "ISMDRPT_TimeTakenInHrs" NUMERIC,
    "CompletedEffortsInMins" NUMERIC,
    "ISMTCR_Status" TEXT,
    "ExceedMins" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Dynamicsql" TEXT;
BEGIN
    "v_Dynamicsql" := '
    SELECT "EmployeeName","ISMTCR_Title","ISMTCR_Desc","ISMTCR_BugOREnhancementFlg","ISMTCRASTO_StartDate","ISMTCRASTO_EndDate","AssignedByEmpName",
    "ISMTCRASTO_EffortInHrs","ISMTCRASTO_EffortInMins" AS "ActualEffortInMins","ISMDRPT_Date","ISMDRPT_TimeTakenInHrs","ISMDRPT_TimeTakenInMins" AS "CompletedEffortsInMins","ISMTCR_Status", 
    (CASE WHEN "ISMDRPT_TimeTakenInMins">"ISMTCRASTO_EffortInMins" THEN "ISMDRPT_TimeTakenInMins"-"ISMTCRASTO_EffortInMins" ELSE 0 END) AS "ExceedMins"
    FROM (
        SELECT (SELECT COALESCE("HRME_EmployeeFirstName",'''')||''''||COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",'''') FROM "HR_Master_Employee" WHERE "HRME_Id"="TCA"."HRME_Id") AS "EmployeeName",
        "ISMTCR_Title","ISMTCR_Desc","ISMTCR_BugOREnhancementFlg","ISMTCR_Status",
        "ISMTCRASTO_StartDate","ISMTCRASTO_EndDate",
        (SELECT COALESCE("HRME_EmployeeFirstName",'''')||'' ''||COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",'''') FROM "HR_Master_Employee" WHERE "HRME_Id"="TCA"."ISMTCRASTO_AssignedBy") AS "AssignedByEmpName",
        "ISMTCRASTO_EffortInHrs",
        (CASE WHEN "ISMTCRASTO_EffortInHrs">=1 THEN "ISMTCRASTO_EffortInHrs"*60 WHEN "ISMTCRASTO_EffortInHrs" BETWEEN 0.1 AND 0.99 THEN "ISMTCRASTO_EffortInHrs"*60 ELSE "ISMTCRASTO_EffortInHrs" END) AS "ISMTCRASTO_EffortInMins",
        "ISMDRPT_Date","ISMDRPT_TimeTakenInHrs",
        (CASE WHEN "ISMDRPT_TimeTakenInHrs">=1 THEN "ISMDRPT_TimeTakenInHrs"*60 WHEN "ISMDRPT_TimeTakenInHrs" BETWEEN 0.1 AND 0.99 THEN "ISMDRPT_TimeTakenInHrs"*60 ELSE "ISMDRPT_TimeTakenInHrs" END) AS "ISMDRPT_TimeTakenInMins",
        "ISMDRPT_Status"
        FROM "ISM_TaskCreation_AssignedTo" "TCA"
        INNER JOIN "ISM_TaskCreation" "TC" ON "TC"."ISMTCR_Id"="TCA"."ISMTCR_Id"
        INNER JOIN "ISM_DailyReport" "DR" ON "DR"."ISMTCR_Id"="TC"."ISMTCR_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON ("HME"."HRME_Id"="TCA"."HRME_Id" OR "HME"."HRME_Id"="TCA"."ISMTCRASTO_AssignedBy")
        WHERE "ISMTCR_ActiveFlg"=1 AND "TC"."HRMD_Id" IN (' || "p_HRMD_Id" || ') AND "HME"."HRMDES_Id" IN (' || "p_HRMDES_Id" || ')
        AND "TC"."ISMTCR_Status"=''Completed'' AND "ISMDRPT_Status"=''Completed''
    ) AS "New"';

    RAISE NOTICE '%', "v_Dynamicsql";
    
    RETURN QUERY EXECUTE "v_Dynamicsql";
    
    RETURN;
END;
$$;