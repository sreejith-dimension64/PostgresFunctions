CREATE OR REPLACE FUNCTION "dbo"."Employees_Bal_Leaves"(
    "p_MI_Id" bigint,
    "p_Fromdate" date,
    "p_ToDate" date,
    "p_Leaveid" text,
    "p_EmployeeId" text
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "HRMLY_LeaveYear" bigint,
    "HRML_LeaveName" text,
    "HRELS_CreditedLeaves" bigint,
    "HRELT_FromDate" timestamp,
    "HRELT_ToDate" timestamp,
    "HRELT_TotDays" bigint,
    "HRELT_Status" varchar(50),
    "ENAME" text,
    "HRME_EmployeeCode" text,
    "RunningBalLeaves" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_QUERY" text;
    "v_HRMLY_Id" bigint;
    "v_HRME_Id" bigint;
    "v_HRME_Id_N" bigint;
    "v_HRMLY_LeaveYear" bigint;
    "v_HRML_LeaveName" text;
    "v_HRELS_CreditedLeaves" bigint;
    "v_HRELT_FromDate" timestamp;
    "v_HRELT_ToDate" timestamp;
    "v_HRELT_TotDays" bigint;
    "v_HRELT_Status" varchar(50);
    "v_RunningBalLeaves" bigint;
    "v_ENAME" text;
    "v_HRME_EmployeeCode" text;
    "emp_rec" RECORD;
    "bal_rec" RECORD;
BEGIN
    DROP TABLE IF EXISTS "Emp_RunningLeaves_Temp";
    DROP TABLE IF EXISTS "Emp_balance_Leaves_Temp";

    CREATE TEMP TABLE "Emp_balance_Leaves_Temp" (
        "HRME_Id" bigint,
        "HRMLY_LeaveYear" bigint,
        "HRML_LeaveName" text,
        "HRELS_CreditedLeaves" bigint,
        "HRELT_FromDate" timestamp,
        "HRELT_ToDate" timestamp,
        "HRELT_TotDays" bigint,
        "HRELT_Status" varchar(50),
        "ENAME" text,
        "HRME_EmployeeCode" text,
        "RunningBalLeaves" bigint
    );

    SELECT "HRMLY_Id" INTO "v_HRMLY_Id"
    FROM "HR_Master_LeaveYear"
    WHERE "MI_Id" = "p_MI_Id"
      AND "p_Fromdate" >= CAST("HRMLY_FromDate" AS date)
      AND "p_ToDate" <= CAST("HRMLY_ToDate" AS date)
    LIMIT 1;

    "v_QUERY" := 'CREATE TEMP TABLE "Emp_RunningLeaves_Temp" AS 
    SELECT AB."HRME_Id", AD."HRMLY_LeaveYear", AC."HRML_LeaveName", AB."HRELS_CreditedLeaves",
    COALESCE(AE."HRELT_FromDate", NULL) as "HRELT_FromDate",
    COALESCE(AE."HRELT_ToDate", NULL) as "HRELT_ToDate",
    COALESCE(AE."HRELT_TotDays", 0) AS "HRELT_TotDays",
    COALESCE(AE."HRELT_Status", '''') as "HRELT_Status",
    (COALESCE(AF."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(AF."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(AF."HRME_EmployeeLastName", '''')) AS "ENAME",
    AF."HRME_EmployeeCode"
    FROM "HR_Emp_Leave_Status" AB
    INNER JOIN "HR_Master_Leave" AC ON AB."HRML_Id" = AC."HRML_Id" 
        AND AB."MI_Id" = ' || "p_MI_Id" || ' AND AC."HRML_Id" IN (' || "p_Leaveid" || ')
    INNER JOIN "HR_Master_LeaveYear" AD ON AB."HRMLY_Id" = AD."HRMLY_Id" 
        AND AD."HRMLY_Id" = ' || "v_HRMLY_Id" || ' AND AD."MI_Id" = ' || "p_MI_Id" || '
    LEFT JOIN "HR_Emp_Leave_Trans" AE ON AE."HRMLY_Id" = AD."HRMLY_Id" 
        AND AE."HRELT_LeaveId" = AC."HRML_Id" AND AE."HRME_Id" = AB."HRME_Id"
        AND AE."HRELT_Status" = ''Approved'' AND AE."MI_Id" = ' || "p_MI_Id" || '
    INNER JOIN "HR_Master_Employee" AF ON AF."HRME_Id" = AB."HRME_Id" 
        AND AF."MI_Id" = ' || "p_MI_Id" || ' AND AF."HRME_ActiveFlag" = true 
        AND AF."HRME_Id" IN (' || "p_EmployeeId" || ')
    WHERE AC."MI_Id" = ' || "p_MI_Id" || ' AND AB."HRME_Id" IN (' || "p_EmployeeId" || ')';

    EXECUTE "v_QUERY";

    FOR "emp_rec" IN 
        SELECT DISTINCT "HRME_Id" FROM "Emp_RunningLeaves_Temp"
    LOOP
        "v_HRME_Id" := "emp_rec"."HRME_Id";

        FOR "bal_rec" IN
            SELECT *,
            "HRELS_CreditedLeaves" - SUM("HRELT_TotDays")
            OVER(ORDER BY "HRME_Id", "HRML_LeaveName", "HRELT_FromDate", "HRELT_ToDate" ROWS UNBOUNDED PRECEDING) AS "RunningBalLeaves"
            FROM "Emp_RunningLeaves_Temp"
            WHERE "HRELT_FromDate" >= "p_Fromdate"
              AND "HRELT_ToDate" <= "p_ToDate"
              AND "HRML_LeaveName" != 'Comp off'
              AND "HRME_Id" = "v_HRME_Id"
        LOOP
            INSERT INTO "Emp_balance_Leaves_Temp" (
                "HRME_Id", "HRMLY_LeaveYear", "HRML_LeaveName", "HRELS_CreditedLeaves",
                "HRELT_FromDate", "HRELT_ToDate", "HRELT_TotDays", "HRELT_Status",
                "ENAME", "HRME_EmployeeCode", "RunningBalLeaves"
            ) VALUES (
                "bal_rec"."HRME_Id", "bal_rec"."HRMLY_LeaveYear", "bal_rec"."HRML_LeaveName",
                "bal_rec"."HRELS_CreditedLeaves", "bal_rec"."HRELT_FromDate", "bal_rec"."HRELT_ToDate",
                "bal_rec"."HRELT_TotDays", "bal_rec"."HRELT_Status", "bal_rec"."ENAME",
                "bal_rec"."HRME_EmployeeCode", "bal_rec"."RunningBalLeaves"
            );
        END LOOP;
    END LOOP;

    RETURN QUERY
    SELECT * FROM "Emp_balance_Leaves_Temp"
    ORDER BY "Emp_balance_Leaves_Temp"."HRME_Id";

END;
$$;