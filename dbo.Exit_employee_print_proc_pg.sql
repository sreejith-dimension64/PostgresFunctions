CREATE OR REPLACE FUNCTION "dbo"."Exit_employee_print_proc"(
    p_HRME_Id INTEGER,
    p_MI_Id INTEGER
)
RETURNS TABLE(
    employeename_p TEXT,
    "HRME_EmployeeCode_p" VARCHAR,
    "HRMDES_DesignationName_p" VARCHAR,
    "HRME_DOJ_p" TIMESTAMP,
    year_p VARCHAR,
    month_p VARCHAR,
    company_Name_p VARCHAR,
    "ISMRESG_AccRejDate_p" TIMESTAMP,
    "ISMRESG_TentativeLeavingDate_p" TIMESTAMP,
    "Gdate_p" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (COALESCE("em"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("em"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("em"."HRME_EmployeeLastName", ''))::TEXT AS employeename_p,
        "em"."HRME_EmployeeCode" AS "HRME_EmployeeCode_p",
        "md"."HRMDES_DesignationName" AS "HRMDES_DesignationName_p",
        "em"."HRME_DOJ" AS "HRME_DOJ_p",
        CAST(FLOOR(EXTRACT(EPOCH FROM ("r"."ISMRESG_TentativeLeavingDate" - "r"."ISMRESG_AccRejDate")) / (86400 * 30.44) / 12) AS VARCHAR) AS year_p,
        CAST(FLOOR(EXTRACT(EPOCH FROM ("r"."ISMRESG_TentativeLeavingDate" - "r"."ISMRESG_AccRejDate")) / (86400 * 30.44)) % 12 AS VARCHAR) AS month_p,
        "mi"."MI_Name" AS company_Name_p,
        "r"."ISMRESG_AccRejDate" AS "ISMRESG_AccRejDate_p",
        "r"."ISMRESG_TentativeLeavingDate" AS "ISMRESG_TentativeLeavingDate_p",
        CURRENT_TIMESTAMP AS "Gdate_p"
    FROM "ISM_Resignation" "r"
    INNER JOIN "HR_Master_Employee" "em" ON "r"."HRME_Id" = "em"."HRME_Id"
    INNER JOIN "HR_Master_Designation" "md" ON "em"."HRMDES_Id" = "md"."HRMDES_Id"
    INNER JOIN "Master_Institution" "mi" ON "em"."MI_Id" = "mi"."MI_Id"
    WHERE "r"."HRME_Id" = p_HRME_Id 
        AND "r"."MI_Id" = p_MI_Id;
END;
$$;