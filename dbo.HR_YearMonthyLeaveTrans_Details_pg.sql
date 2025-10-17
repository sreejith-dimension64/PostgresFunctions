CREATE OR REPLACE FUNCTION "dbo"."HR_YearMonthyLeaveTrans_Details"(
    "p_MI_Id" bigint,
    "p_Year" bigint,
    "p_MonthId" bigint
)
RETURNS TABLE(
    "DepartmentName" TEXT,
    "AppliedDays" DECIMAL(18,2),
    "ApprovedDays" DECIMAL(18,2),
    "RejectedDays" DECIMAL(18,2),
    "NotApprovedDays" DECIMAL(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_HRMD_Id" bigint;
    "v_HRMD_DepartmentName" TEXT;
    "v_TotalDaysApplied" DECIMAL(18,2);
    "v_TotalDaysApproved" DECIMAL(18,2);
    "v_TotalDaysRejected" DECIMAL(18,2);
    "v_TotalDaysNotApproved" DECIMAL(18,2);
    "v_Rcount" bigint;
    "dept_record" RECORD;
BEGIN
    DROP TABLE IF EXISTS "HR_MonthyLeaveTransDetails_Temp";
    
    CREATE TEMP TABLE "HR_MonthyLeaveTransDetails_Temp"(
        "DepartmentName" TEXT,
        "AppliedDays" DECIMAL(18,2),
        "ApprovedDays" DECIMAL(18,2),
        "RejectedDays" DECIMAL(18,2),
        "NotApprovedDays" DECIMAL(18,2)
    );

    FOR "dept_record" IN
        SELECT DISTINCT "HMD"."HRMD_Id", "HMD"."HRMD_DepartmentName"
        FROM "HR_Emp_leave_Application" "HELA"
        INNER JOIN "HR_Emp_Leave_Appl_Details" "HELAD" ON "HELA"."HRELAP_Id" = "HELAD"."HRELAP_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "HELA"."HRME_Id"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id"
        INNER JOIN "HR_Master_Leave" "HML" ON "HML"."HRML_Id" = "HELAD"."HRML_Id"
        WHERE "HME"."HRME_ActiveFlag" = 1 
            AND "HME"."HRME_LeftFlag" = 0 
            AND "HME"."MI_Id" = "p_MI_Id"
    LOOP
        "v_HRMD_Id" := "dept_record"."HRMD_Id";
        "v_HRMD_DepartmentName" := "dept_record"."HRMD_DepartmentName";
        
        "v_TotalDaysApplied" := 0;
        "v_TotalDaysApproved" := 0;
        "v_TotalDaysRejected" := 0;
        "v_TotalDaysNotApproved" := 0;

        SELECT COALESCE(SUM("HRELAP_TotalDays"), 0)
        INTO "v_TotalDaysApplied"
        FROM "HR_Emp_leave_Application" "HELA"
        INNER JOIN "HR_Emp_Leave_Appl_Details" "HELAD" ON "HELA"."HRELAP_Id" = "HELAD"."HRELAP_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "HELA"."HRME_Id"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id"
        INNER JOIN "HR_Master_Leave" "HML" ON "HML"."HRML_Id" = "HELAD"."HRML_Id"
        WHERE "HME"."HRME_ActiveFlag" = 1 
            AND "HME"."HRME_LeftFlag" = 0 
            AND "HME"."MI_Id" = "p_MI_Id"
            AND "HRML_LeaveCode" != 'OD' 
            AND ("HRELAP_ApplicationStatus" != 'Approved' OR "HRELAP_ApplicationStatus" != 'Rejected') 
            AND EXTRACT(YEAR FROM "HRELAPD_FromDate") = "p_Year" 
            AND EXTRACT(MONTH FROM "HRELAPD_FromDate") = "p_MonthId" 
            AND "HMD"."HRMD_Id" = "v_HRMD_Id"
        GROUP BY "HMD"."HRMD_DepartmentName", "HMD"."HRMD_Id";

        SELECT COALESCE(SUM("HRELAP_TotalDays"), 0)
        INTO "v_TotalDaysApproved"
        FROM "HR_Emp_leave_Application" "HELA"
        INNER JOIN "HR_Emp_Leave_Appl_Details" "HELAD" ON "HELA"."HRELAP_Id" = "HELAD"."HRELAP_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "HELA"."HRME_Id"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id"
        INNER JOIN "HR_Master_Leave" "HML" ON "HML"."HRML_Id" = "HELAD"."HRML_Id"
        WHERE "HME"."HRME_ActiveFlag" = 1 
            AND "HME"."HRME_LeftFlag" = 0 
            AND "HME"."MI_Id" = "p_MI_Id"
            AND "HRML_LeaveCode" != 'OD' 
            AND "HRELAP_ApplicationStatus" = 'Approved' 
            AND EXTRACT(YEAR FROM "HRELAPD_FromDate") = "p_Year" 
            AND EXTRACT(MONTH FROM "HRELAPD_FromDate") = "p_MonthId" 
            AND "HMD"."HRMD_Id" = "v_HRMD_Id"
        GROUP BY "HMD"."HRMD_DepartmentName", "HMD"."HRMD_Id";

        SELECT COALESCE(SUM("HRELAP_TotalDays"), 0)
        INTO "v_TotalDaysRejected"
        FROM "HR_Emp_leave_Application" "HELA"
        INNER JOIN "HR_Emp_Leave_Appl_Details" "HELAD" ON "HELA"."HRELAP_Id" = "HELAD"."HRELAP_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "HELA"."HRME_Id"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id"
        INNER JOIN "HR_Master_Leave" "HML" ON "HML"."HRML_Id" = "HELAD"."HRML_Id"
        WHERE "HME"."HRME_ActiveFlag" = 1 
            AND "HME"."HRME_LeftFlag" = 0 
            AND "HME"."MI_Id" = "p_MI_Id"
            AND "HRML_LeaveCode" != 'OD' 
            AND "HRELAP_ApplicationStatus" = 'Rejected' 
            AND EXTRACT(YEAR FROM "HRELAPD_FromDate") = "p_Year" 
            AND EXTRACT(MONTH FROM "HRELAPD_FromDate") = "p_MonthId" 
            AND "HMD"."HRMD_Id" = "v_HRMD_Id"
        GROUP BY "HMD"."HRMD_DepartmentName", "HMD"."HRMD_Id";

        SELECT COALESCE(SUM("HRELAP_TotalDays"), 0)
        INTO "v_TotalDaysNotApproved"
        FROM "HR_Emp_leave_Application" "HELA"
        INNER JOIN "HR_Emp_Leave_Appl_Details" "HELAD" ON "HELA"."HRELAP_Id" = "HELAD"."HRELAP_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "HELA"."HRME_Id"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id"
        INNER JOIN "HR_Master_Leave" "HML" ON "HML"."HRML_Id" = "HELAD"."HRML_Id"
        WHERE "HME"."HRME_ActiveFlag" = 1 
            AND "HME"."HRME_LeftFlag" = 0 
            AND "HME"."MI_Id" = "p_MI_Id"
            AND "HRML_LeaveCode" != 'OD' 
            AND "HRELAP_ApplicationStatus" = 'Partial Approved' 
            AND EXTRACT(YEAR FROM "HRELAPD_FromDate") = "p_Year" 
            AND EXTRACT(MONTH FROM "HRELAPD_FromDate") = "p_MonthId" 
            AND "HMD"."HRMD_Id" = "v_HRMD_Id"
        GROUP BY "HMD"."HRMD_DepartmentName", "HMD"."HRMD_Id";

        "v_Rcount" := 0;
        SELECT COUNT(*)
        INTO "v_Rcount"
        FROM "HR_MonthyLeaveTransDetails_Temp"
        WHERE "DepartmentName" = "v_HRMD_DepartmentName" 
            AND "AppliedDays" = "v_TotalDaysApplied" 
            AND "ApprovedDays" = "v_TotalDaysApproved" 
            AND "RejectedDays" = "v_TotalDaysRejected";

        IF "v_Rcount" = 0 THEN
            INSERT INTO "HR_MonthyLeaveTransDetails_Temp"("DepartmentName", "AppliedDays", "ApprovedDays", "RejectedDays", "NotApprovedDays")
            VALUES("v_HRMD_DepartmentName", "v_TotalDaysApplied", "v_TotalDaysApproved", "v_TotalDaysRejected", "v_TotalDaysNotApproved");
        END IF;

    END LOOP;

    RETURN QUERY SELECT * FROM "HR_MonthyLeaveTransDetails_Temp";
    
    DROP TABLE IF EXISTS "HR_MonthyLeaveTransDetails_Temp";
    
    RETURN;
END;
$$;