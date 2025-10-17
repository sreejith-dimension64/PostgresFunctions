CREATE OR REPLACE FUNCTION "dbo"."ISM_DailyReport_Generation_Deviation_Calculation"(
    "@MI_Id" TEXT,
    "@HRME_Id" TEXT,
    "@Date" TEXT,
    "@Flag" TEXT
)
RETURNS TABLE(
    "ISMTPL_TotalHrs" NUMERIC,
    "per" NUMERIC(18,2),
    "deviation" NUMERIC(18,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
   
   IF "@Flag" = '1' THEN
   
      RETURN QUERY
      SELECT 
          "ITP"."ISMTPL_TotalHrs",
          CAST((SUM("ITC"."ISMTPLTA_EffortInHrs") * 100 / "ITP"."ISMTPL_TotalHrs") AS NUMERIC(18,2)) AS "per",
          CAST((100 - (SUM("ITC"."ISMTPLTA_EffortInHrs") * 100 / "ITP"."ISMTPL_TotalHrs")) AS NUMERIC(18,2)) AS "deviation"
      FROM "ISM_Task_Planner" "ITP" 
      INNER JOIN "ISM_Task_Planner_Tasks" "ITC" ON "ITC"."ISMTPL_Id" = "ITP"."ISMTPL_Id"
      INNER JOIN "ISM_TaskCreation" "ITPT" ON "ITPT"."ISMTCR_Id" = "ITC"."ISMTCR_Id"
      WHERE (CAST("@Date" AS DATE) BETWEEN "ITP"."ISMTPL_StartDate" AND "ITP"."ISMTPL_EndDate") 
          AND "ITP"."HRME_Id" = "@HRME_Id" 
          AND "ITP"."MI_Id" = "@MI_Id" 
          AND "ITC"."ISMTPLTA_Status" = 'Completed'
      GROUP BY "ITP"."ISMTPL_TotalHrs";
   
   END IF;
   
   RETURN;

END;
$$;