CREATE OR REPLACE FUNCTION "dbo"."ISM_feedback_emplist_proc"(p_HRME_Id bigint)
RETURNS TABLE(
    totalcount bigint,
    "ISMDRF_Send_HRME_Id" bigint,
    employee_name varchar(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS temp1;
    DROP TABLE IF EXISTS temp2;
    DROP TABLE IF EXISTS temp3;
    
    CREATE TEMP TABLE temp3 (
        totalcount bigint,
        "ISMDRF_Send_HRME_Id" bigint,
        employee_name varchar(50)
    );

    CREATE TEMP TABLE temp1 AS
    SELECT DISTINCT 
        COUNT(a."ISMDRF_Id") as totalcount,
        a."ISMDRF_Send_HRME_Id",
        (COALESCE(b."HRME_EmployeeFirstName", '') || COALESCE(b."HRME_EmployeeMiddleName", '') || COALESCE(b."HRME_EmployeeLastName", '')) as employee_name
    FROM "ISM_DailyReport_FeedBack" a, "HR_Master_Employee" b
    WHERE a."ISMDRF_Send_HRME_Id" = b."HRME_Id"
        AND a."ISMDRF_RCV_HRME_Id" = p_HRME_Id
        AND a."ISMDRF_OpenFeedback" = 1
    GROUP BY a."ISMDRF_Send_HRME_Id", b."HRME_EmployeeFirstName", b."HRME_EmployeeMiddleName", b."HRME_EmployeeLastName";

    CREATE TEMP TABLE temp2 AS
    SELECT DISTINCT 
        0::bigint as totalcount,
        a."ISMDRF_Send_HRME_Id",
        (COALESCE(b."HRME_EmployeeFirstName", '') || COALESCE(b."HRME_EmployeeMiddleName", '') || COALESCE(b."HRME_EmployeeLastName", '')) as employee_name
    FROM "ISM_DailyReport_FeedBack" a, "HR_Master_Employee" b
    WHERE a."ISMDRF_Send_HRME_Id" = b."HRME_Id"
        AND a."ISMDRF_RCV_HRME_Id" = p_HRME_Id
        AND a."ISMDRF_OpenFeedback" = 0
    GROUP BY a."ISMDRF_Send_HRME_Id", b."HRME_EmployeeFirstName", b."HRME_EmployeeMiddleName", b."HRME_EmployeeLastName";

    INSERT INTO temp3 
    SELECT * FROM temp1
    UNION ALL
    SELECT * FROM temp2;

    RETURN QUERY
    SELECT 
        SUM(t.totalcount) as totalcount,
        t."ISMDRF_Send_HRME_Id",
        t.employee_name
    FROM temp3 t
    GROUP BY t."ISMDRF_Send_HRME_Id", t.employee_name
    ORDER BY SUM(t.totalcount) DESC;

    DROP TABLE IF EXISTS temp1;
    DROP TABLE IF EXISTS temp2;
    DROP TABLE IF EXISTS temp3;
END;
$$;