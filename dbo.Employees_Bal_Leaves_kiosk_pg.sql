CREATE OR REPLACE FUNCTION "dbo"."Employees_Bal_Leaves_kiosk"(
    p_MI_Id bigint,
    p_Fromdate varchar(10),
    p_ToDate varchar(10),
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
    "HRELAP_ApplicationID" text,
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
    v_HRELAP_ApplicationID text;
    v_Fromdate_New date;
    v_ToDate_New date;
    rec_EmpBalance RECORD;
BEGIN

    DROP TABLE IF EXISTS "Emp_RunningLeaves_Tempp";
    DROP TABLE IF EXISTS "Emp_balance_Leaves_Tempp";

    v_Fromdate_New := TO_DATE(p_Fromdate, 'DD-MM-YYYY');
    v_ToDate_New := TO_DATE(p_ToDate, 'DD-MM-YYYY');

    CREATE TEMP TABLE "Emp_balance_Leaves_Tempp" (
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
        "HRELAP_ApplicationID" text,
        "RunningBalLeaves" bigint
    );

    SELECT "HRMLY_Id" INTO v_HRMLY_Id 
    FROM "HR_Master_LeaveYear" 
    WHERE "MI_Id" = p_MI_Id 
        AND v_Fromdate_New >= CAST("HRMLY_FromDate" AS date)
        AND v_ToDate_New <= CAST("HRMLY_ToDate" AS date)
    LIMIT 1;

    v_QUERY := 'CREATE TEMP TABLE "Emp_RunningLeaves_Tempp" AS
    SELECT AB."HRME_Id", AD."HRMLY_LeaveYear", AC."HRML_LeaveName", AB."HRELS_CreditedLeaves",
    AE."HRELT_FromDate", AE."HRELT_ToDate", AE."HRELT_TotDays", AE."HRELT_Status",
    (COALESCE(AF."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(AF."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(AF."HRME_EmployeeLastName", '''')) AS "ENAME",
    AF."HRME_EmployeeCode", LA."HRELAP_ApplicationID"
    FROM "HR_Emp_Leave_Status" AB 
    INNER JOIN "HR_Master_Leave" AC ON AB."HRML_Id" = AC."HRML_Id" AND AB."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "HR_Master_LeaveYear" AD ON AB."HRMLY_Id" = AD."HRMLY_Id" AND AD."HRMLY_Id" = ' || v_HRMLY_Id || ' AND AD."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "HR_Emp_Leave_Trans" AE ON AE."HRMLY_Id" = AD."HRMLY_Id" AND AE."HRELT_LeaveId" = AC."HRML_Id" AND AE."HRELT_Status" = ''Approved'' AND AE."MI_Id" = ' || p_MI_Id || '
    INNER JOIN "HR_Emp_Leave_Application" LA ON LA."HRME_Id" = AE."HRME_Id" AND LA."MI_Id" = ' || p_MI_Id || ' AND LA."HRELAP_FromDate" = AE."HRELT_FromDate" AND LA."HRELAP_ToDate" = AE."HRELT_ToDate"
    INNER JOIN "HR_Master_Employee" AF ON AF."HRME_Id" = AE."HRME_Id" AND AF."MI_Id" = ' || p_MI_Id || ' AND AF."HRME_ActiveFlag" = 1 AND AF."HRME_Id" IN (' || p_EmployeeId || ')
    WHERE AC."MI_Id" = ' || p_MI_Id || ' AND AB."HRME_Id" IN (' || p_EmployeeId || ') AND AB."HRME_Id" = AE."HRME_Id"';

    EXECUTE v_QUERY;

    FOR v_HRME_Id IN 
        SELECT DISTINCT "HRME_Id" FROM "Emp_RunningLeaves_Tempp"
    LOOP
        FOR rec_EmpBalance IN
            SELECT *,
                "HRELS_CreditedLeaves" - SUM("HRELT_TotDays") OVER(ORDER BY "HRME_Id", "HRML_LeaveName", "HRELT_FromDate", "HRELT_ToDate" ROWS UNBOUNDED PRECEDING) AS "RunningBalLeaves"
            FROM "Emp_RunningLeaves_Tempp" 
            WHERE "HRELT_FromDate" >= v_Fromdate_New 
                AND "HRELT_ToDate" <= v_ToDate_New 
                AND "HRML_LeaveName" != 'Comp off' 
                AND "HRME_Id" = v_HRME_Id
        LOOP
            INSERT INTO "Emp_balance_Leaves_Tempp" (
                "HRME_Id", "HRMLY_LeaveYear", "HRML_LeaveName", "HRELS_CreditedLeaves",
                "HRELT_FromDate", "HRELT_ToDate", "HRELT_TotDays", "HRELT_Status",
                "ENAME", "HRME_EmployeeCode", "HRELAP_ApplicationID", "RunningBalLeaves"
            ) VALUES (
                rec_EmpBalance."HRME_Id", rec_EmpBalance."HRMLY_LeaveYear", 
                rec_EmpBalance."HRML_LeaveName", rec_EmpBalance."HRELS_CreditedLeaves",
                rec_EmpBalance."HRELT_FromDate", rec_EmpBalance."HRELT_ToDate", 
                rec_EmpBalance."HRELT_TotDays", rec_EmpBalance."HRELT_Status",
                rec_EmpBalance."ENAME", rec_EmpBalance."HRME_EmployeeCode", 
                rec_EmpBalance."HRELAP_ApplicationID", rec_EmpBalance."RunningBalLeaves"
            );
        END LOOP;
    END LOOP;

    RETURN QUERY 
    SELECT * FROM "Emp_balance_Leaves_Tempp" ORDER BY "HRME_Id";

END;
$$;