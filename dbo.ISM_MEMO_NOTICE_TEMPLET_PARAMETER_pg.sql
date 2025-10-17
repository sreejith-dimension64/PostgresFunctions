CREATE OR REPLACE FUNCTION "dbo"."ISM_MEMO_NOTICE_TEMPLET_PARAMETER"(
    "EMP_HRMEID" bigint,
    "HRME_ID" bigint,
    "TYPE" text,
    "MI_ID" bigint
)
RETURNS TABLE(
    "[EMPNAME]" text,
    "[EMPDESIGNATION]" text,
    "[NAME]" text,
    "[DESIGNATION]" text,
    "[DATE]" text,
    "[REFNO]" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_userId bigint;
    v_dept bigint;
    v_depthead bigint;
BEGIN

    SELECT "hrmd"."HRME_ID" INTO v_depthead
    FROM "HR_Master_Employee" "hre"
    INNER JOIN "HR_Master_Department" "hrd" ON "hre"."HRMD_Id" = "hrd"."HRMD_Id"
    INNER JOIN "HR_Master_DepartmentCode_Head" "hrmd" ON "hrmd"."HRMDC_ID" = "hrd"."HRMDC_ID"
    WHERE "hre"."HRME_Id" = "EMP_HRMEID"
    LIMIT 1;

    RETURN QUERY
    WITH cte0 AS (
        SELECT (
            (CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' 
             ELSE "HRME_EmployeeFirstName" END ||
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
                  OR "HRME_EmployeeMiddleName" = '0' THEN '' 
             ELSE ' ' || "HRME_EmployeeMiddleName" END ||
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
                  OR "HRME_EmployeeLastName" = '0' THEN '' 
             ELSE ' ' || "HRME_EmployeeLastName" END)
        ) AS "[EMPNAME]"
        FROM "HR_Master_Employee" "HRE"
        WHERE "HRE"."HRME_Id" = "EMP_HRMEID"
    ),
    cte1 AS (
        SELECT "HRD"."HRMDES_DesignationName" AS "[EMPDESIGNATION]"
        FROM "HR_Master_Employee" "HRE"
        INNER JOIN "HR_Master_Designation" "HRD" ON "HRE"."HRMDES_Id" = "HRD"."HRMDES_Id"
        WHERE "HRE"."HRME_Id" = "EMP_HRMEID"
    ),
    cte2 AS (
        SELECT (
            (CASE WHEN "HRE"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' 
             ELSE "HRME_EmployeeFirstName" END ||
             CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' 
                  OR "HRME_EmployeeMiddleName" = '0' THEN '' 
             ELSE ' ' || "HRME_EmployeeMiddleName" END ||
             CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' 
                  OR "HRME_EmployeeLastName" = '0' THEN '' 
             ELSE ' ' || "HRME_EmployeeLastName" END)
        ) AS "[NAME]"
        FROM "HR_Master_Employee" "HRE"
        WHERE "HRE"."HRME_Id" = v_depthead
    ),
    cte3 AS (
        SELECT "HRD"."HRMDES_DesignationName" AS "[DESIGNATION]"
        FROM "HR_Master_Employee" "HRE"
        INNER JOIN "HR_Master_Designation" "HRD" ON "HRE"."HRMDES_Id" = "HRD"."HRMDES_Id"
        WHERE "HRE"."HRME_Id" = "HRME_ID"
    ),
    cte4 AS (
        SELECT TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY') AS "[DATE]"
    ),
    cte5 AS (
        SELECT "ISMEMN_No" AS "[REFNO]"
        FROM "ISM_EMPLOYEE_MEMO_NOTICE"
        WHERE "ISMEMN_EmailSentFlag" = 0 
          AND "ISMEMN_Type" = "TYPE" 
          AND "MI_ID" = "ISM_MEMO_NOTICE_TEMPLET_PARAMETER"."MI_ID"
        ORDER BY "ISMEMN_ID" DESC
        LIMIT 1
    )
    SELECT cte0."[EMPNAME]", cte1."[EMPDESIGNATION]", cte2."[NAME]", 
           cte3."[DESIGNATION]", cte4."[DATE]", cte5."[REFNO]"
    FROM cte0, cte1, cte2, cte3, cte4, cte5;

END;
$$;