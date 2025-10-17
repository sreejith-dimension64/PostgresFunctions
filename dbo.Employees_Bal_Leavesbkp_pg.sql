CREATE OR REPLACE FUNCTION "dbo"."Employees_Bal_Leavesbkp"(
    "p_MI_Id" bigint,
    "p_Fromdate" varchar(10),
    "p_ToDate" varchar(10),
    "p_Leaveid" text,
    "p_EmployeeId" text
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "HRMLY_LeaveYear" bigint,
    "HRML_LeaveName" text,
    "HRELS_CreditedLeaves" decimal(18,2),
    "HRELT_FromDate" timestamp,
    "HRELT_ToDate" timestamp,
    "HRELT_TotDays" decimal(18,2),
    "HRELT_Status" varchar(50),
    "ENAME" text,
    "HRME_EmployeeCode" text,
    "HRML_Id" bigint,
    "RunningBalLeaves" decimal(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_QUERY" text;
    "v_HRMLY_Id" bigint;
    "v_HRME_Id" bigint;
    "v_HRML_Id" bigint;
    "v_HRME_Id_N" bigint;
    "v_HRMLY_LeaveYear" bigint;
    "v_HRML_LeaveName" text;
    "v_HRELS_CreditedLeaves" decimal(18,2);
    "v_HRELT_FromDate" timestamp;
    "v_HRELT_ToDate" timestamp;
    "v_HRELT_TotDays" decimal(18,2);
    "v_HRELT_Status" varchar(50);
    "v_RunningBalLeaves" decimal(18,2);
    "v_ENAME" text;
    "v_HRME_EmployeeCode" text;
    "v_Fromdate1" date;
    "v_ToDate1" date;
    "emp_leaves_rec" RECORD;
    "emp_balance_rec" RECORD;
BEGIN

    DROP TABLE IF EXISTS "Emp_RunningLeaves_Temp";
    DROP TABLE IF EXISTS "Emp_balance_Leaves_Temp";

    CREATE TEMP TABLE "Emp_RunningLeaves_Temp" (
        "HRME_Id" bigint,
        "HRMLY_LeaveYear" bigint,
        "HRML_LeaveName" text,
        "HRELS_CreditedLeaves" decimal(18,2),
        "HRELT_FromDate" timestamp,
        "HRELT_ToDate" timestamp,
        "HRELT_TotDays" decimal(18,2),
        "HRELT_Status" text,
        "ENAME" text,
        "HRME_EmployeeCode" varchar(10),
        "HRML_Id" bigint
    );

    CREATE TEMP TABLE "Emp_balance_Leaves_Temp" (
        "HRME_Id" bigint,
        "HRMLY_LeaveYear" bigint,
        "HRML_LeaveName" text,
        "HRELS_CreditedLeaves" decimal(18,2),
        "HRELT_FromDate" timestamp,
        "HRELT_ToDate" timestamp,
        "HRELT_TotDays" decimal(18,2),
        "HRELT_Status" varchar(50),
        "ENAME" text,
        "HRME_EmployeeCode" text,
        "HRML_Id" bigint,
        "RunningBalLeaves" decimal(18,2)
    );

    "v_Fromdate1" := TO_DATE("p_Fromdate", 'DD-MM-YYYY');
    "v_ToDate1" := TO_DATE("p_ToDate", 'DD-MM-YYYY');

    RAISE NOTICE '%', "v_Fromdate1";
    RAISE NOTICE '%', "v_ToDate1";

    SELECT "HRMLY_Id" INTO "v_HRMLY_Id"
    FROM "HR_Master_LeaveYear"
    WHERE "MI_Id" = "p_MI_Id"
    AND ("v_Fromdate1" >= "HRMLY_FromDate"::date AND "v_ToDate1" <= "HRMLY_ToDate"::date);

    "v_QUERY" := 'INSERT INTO "Emp_RunningLeaves_Temp" ' ||
                 'SELECT DISTINCT AE."HRME_Id", AD."HRMLY_LeaveYear", AC."HRML_LeaveName", AB."HRELS_CreditedLeaves", ' ||
                 'AE."HRELT_FromDate", AE."HRELT_ToDate", AE."HRELT_TotDays", AE."HRELT_Status", ' ||
                 '(COALESCE(AF."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(AF."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(AF."HRME_EmployeeLastName",'''')), ' ||
                 'AF."HRME_EmployeeCode", AC."HRML_Id" ' ||
                 'FROM "HR_Emp_Leave_Status" AB ' ||
                 'INNER JOIN "HR_Master_Leave" AC ON AB."HRML_Id" = AC."HRML_Id" AND AB."MI_Id" = ' || "p_MI_Id" || ' ' ||
                 'INNER JOIN "HR_Master_LeaveYear" AD ON AB."HRMLY_Id" = AD."HRMLY_Id" AND AD."MI_Id" = ' || "p_MI_Id" || ' ' ||
                 'INNER JOIN "HR_Emp_Leave_Trans" AE ON AE."HRMLY_Id" = AD."HRMLY_Id" AND AE."HRELT_LeaveId" = AC."HRML_Id" AND AE."MI_Id" = ' || "p_MI_Id" || ' ' ||
                 'INNER JOIN "HR_Master_Employee" AF ON AF."HRME_Id" = AE."HRME_Id" AND AF."HRME_Id" = AB."HRME_Id" AND AF."MI_Id" = ' || "p_MI_Id" || 
                 ' AND AF."HRME_ActiveFlag" = true AND AF."HRME_LeftFlag" = false ' ||
                 'WHERE AC."MI_Id" = ' || "p_MI_Id" || ' AND AB."HRME_Id" IN (' || "p_EmployeeId" || ') AND AC."HRML_Id" IN (' || "p_Leaveid" || ') ' ||
                 'AND AE."HRELT_Status" = ''Approved'' AND AD."HRMLY_Id" = ' || "v_HRMLY_Id" || ' AND AF."HRME_Id" IN (' || "p_EmployeeId" || ')';

    EXECUTE "v_QUERY";
    RAISE NOTICE '%', "v_QUERY";

    FOR "emp_leaves_rec" IN 
        SELECT DISTINCT "HRME_Id", "HRML_Id" FROM "Emp_RunningLeaves_Temp"
    LOOP
        "v_HRME_Id" := "emp_leaves_rec"."HRME_Id";
        "v_HRML_Id" := "emp_leaves_rec"."HRML_Id";

        FOR "emp_balance_rec" IN
            SELECT *,
                   "HRELS_CreditedLeaves" - SUM("HRELT_TotDays") OVER(
                       ORDER BY "HRME_Id", "HRML_LeaveName", "HRELT_FromDate", "HRELT_ToDate" 
                       ROWS UNBOUNDED PRECEDING
                   ) AS "RunningBalLeaves"
            FROM "Emp_RunningLeaves_Temp"
            WHERE "HRELT_FromDate" >= "v_Fromdate1"
            AND "HRELT_ToDate" <= "v_ToDate1"
            AND "HRML_LeaveName" != 'Comp off'
            AND "HRME_Id" = "v_HRME_Id"
            AND "HRML_Id" = "v_HRML_Id"
        LOOP
            "v_HRME_Id_N" := "emp_balance_rec"."HRME_Id";
            "v_HRMLY_LeaveYear" := "emp_balance_rec"."HRMLY_LeaveYear";
            "v_HRML_LeaveName" := "emp_balance_rec"."HRML_LeaveName";
            "v_HRELS_CreditedLeaves" := "emp_balance_rec"."HRELS_CreditedLeaves";
            "v_HRELT_FromDate" := "emp_balance_rec"."HRELT_FromDate";
            "v_HRELT_ToDate" := "emp_balance_rec"."HRELT_ToDate";
            "v_HRELT_TotDays" := "emp_balance_rec"."HRELT_TotDays";
            "v_HRELT_Status" := "emp_balance_rec"."HRELT_Status";
            "v_ENAME" := "emp_balance_rec"."ENAME";
            "v_HRME_EmployeeCode" := "emp_balance_rec"."HRME_EmployeeCode";
            "v_RunningBalLeaves" := "emp_balance_rec"."RunningBalLeaves";

            INSERT INTO "Emp_balance_Leaves_Temp" (
                "HRME_Id", "HRMLY_LeaveYear", "HRML_LeaveName", "HRELS_CreditedLeaves",
                "HRELT_FromDate", "HRELT_ToDate", "HRELT_TotDays", "HRELT_Status",
                "ENAME", "HRME_EmployeeCode", "HRML_Id", "RunningBalLeaves"
            )
            VALUES (
                "v_HRME_Id_N", "v_HRMLY_LeaveYear", "v_HRML_LeaveName", "v_HRELS_CreditedLeaves",
                "v_HRELT_FromDate", "v_HRELT_ToDate", "v_HRELT_TotDays", "v_HRELT_Status",
                "v_ENAME", "v_HRME_EmployeeCode", "v_HRML_Id", "v_RunningBalLeaves"
            );
        END LOOP;
    END LOOP;

    RETURN QUERY
    SELECT * FROM "Emp_balance_Leaves_Temp" ORDER BY "Emp_balance_Leaves_Temp"."HRME_Id";

END;
$$;