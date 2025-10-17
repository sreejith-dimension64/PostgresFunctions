CREATE OR REPLACE FUNCTION "dbo"."Employees_Bal_Leaves_Modify"(
    p_MI_Id bigint,
    p_Fromdate varchar(10),
    p_ToDate varchar(10),
    p_Leaveid text,
    p_EmployeeId text
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
    v_QUERY text;
    v_HRMLY_Id bigint;
    v_HRME_Id bigint;
    v_HRME_Id_N bigint;
    v_HRMLY_LeaveYear bigint;
    v_HRML_LeaveName text;
    v_HRELS_CreditedLeaves bigint;
    v_HRELT_FromDate timestamp;
    v_HRELT_ToDate timestamp;
    v_HRELT_TotDays bigint;
    v_HRELT_Status varchar(50);
    v_RunningBalLeaves bigint;
    v_ENAME text;
    v_HRME_EmployeeCode text;
    rec_balance RECORD;
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

    SELECT "HRMLY_Id" INTO v_HRMLY_Id 
    FROM "HR_Master_LeaveYear" 
    WHERE "MI_Id" = p_MI_Id
    AND (p_Fromdate::date >= "HRMLY_FromDate"::date AND p_ToDate::date <= "HRMLY_ToDate"::date);

    v_QUERY := 'CREATE TEMP TABLE "Emp_RunningLeaves_Temp" AS 
    SELECT AB."HRME_Id", AD."HRMLY_LeaveYear", AC."HRML_LeaveName", AB."HRELS_CreditedLeaves",
    AE."HRELT_FromDate", AE."HRELT_ToDate", AE."HRELT_TotDays", AE."HRELT_Status",
    (COALESCE(AF."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(AF."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(AF."HRME_EmployeeLastName",'''')) AS "ENAME",
    AF."HRME_EmployeeCode"
    FROM "HR_Emp_Leave_Status" AB 
    INNER JOIN "HR_Master_Leave" AC ON AB."HRML_Id" = AC."HRML_Id" 
        AND AB."MI_Id" = ' || p_MI_Id || ' AND AC."HRML_Id" IN (' || p_Leaveid || ')
    INNER JOIN "HR_Master_LeaveYear" AD ON AB."HRMLY_Id" = AD."HRMLY_Id" 
        AND AD."HRMLY_Id" = ' || v_HRMLY_Id || ' AND AD."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "HR_Emp_Leave_Trans" AE ON AE."HRMLY_Id" = AD."HRMLY_Id" 
        AND AE."HRELT_LeaveId" = AC."HRML_Id" 
        AND AE."HRELT_Status" = ''Approved'' AND AE."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "HR_Master_Employee" AF ON AF."HRME_Id" = AB."HRME_Id" 
        AND AF."MI_Id" = ' || p_MI_Id || ' 
        AND AF."HRME_ActiveFlag" = 1 AND AF."HRME_Id" IN (' || p_EmployeeId || ')
    WHERE AC."MI_Id" = ' || p_MI_Id || ' AND AB."HRME_Id" IN (' || p_EmployeeId || ')';

    EXECUTE v_QUERY;

    FOR v_HRME_Id IN 
        SELECT DISTINCT "HRME_Id" FROM "Emp_RunningLeaves_Temp"
    LOOP
        FOR rec_balance IN
            SELECT 
                "HRME_Id",
                "HRMLY_LeaveYear",
                "HRML_LeaveName",
                "HRELS_CreditedLeaves",
                "HRELT_FromDate",
                "HRELT_ToDate",
                "HRELT_TotDays",
                "HRELT_Status",
                "ENAME",
                "HRME_EmployeeCode",
                "HRELS_CreditedLeaves" - SUM("HRELT_TotDays") OVER(
                    ORDER BY "HRME_Id", "HRML_LeaveName", "HRELT_FromDate", "HRELT_ToDate" 
                    ROWS UNBOUNDED PRECEDING
                ) AS "RunningBalLeaves"
            FROM "Emp_RunningLeaves_Temp" 
            WHERE "HRELT_FromDate" >= p_Fromdate::date  
            AND "HRELT_ToDate" <= p_ToDate::date 
            AND "HRML_LeaveName" != 'Comp off' 
            AND "HRME_Id" = v_HRME_Id
        LOOP
            INSERT INTO "Emp_balance_Leaves_Temp" (
                "HRME_Id", "HRMLY_LeaveYear", "HRML_LeaveName", "HRELS_CreditedLeaves",
                "HRELT_FromDate", "HRELT_ToDate", "HRELT_TotDays", "HRELT_Status",
                "ENAME", "HRME_EmployeeCode", "RunningBalLeaves"
            ) VALUES (
                rec_balance."HRME_Id",
                rec_balance."HRMLY_LeaveYear",
                rec_balance."HRML_LeaveName",
                rec_balance."HRELS_CreditedLeaves",
                rec_balance."HRELT_FromDate",
                rec_balance."HRELT_ToDate",
                rec_balance."HRELT_TotDays",
                rec_balance."HRELT_Status",
                rec_balance."ENAME",
                rec_balance."HRME_EmployeeCode",
                rec_balance."RunningBalLeaves"
            );
        END LOOP;
    END LOOP;

    RETURN QUERY 
    SELECT * FROM "Emp_balance_Leaves_Temp" ORDER BY "HRME_Id";

END;
$$;