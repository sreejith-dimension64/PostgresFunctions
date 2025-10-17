CREATE OR REPLACE FUNCTION "HR_Emp_ShiftTimings_Details"(p_MI_Id bigint)
RETURNS TABLE(
    "HRME_EmployeeFirstName" text,
    "FOHTWD_HolidayWDType" text,
    "FOMS_ShiftName" text,
    "FOEST_FDWHrMin" text,
    "FOEST_HDWHrMin" text,
    "FOEST_IHalfLoginTime" text,
    "FOEST_IHalfLogoutTime" text,
    "FOEST_IIHalfLoginTime" text,
    "FOEST_IIHalfLogoutTime" text,
    "FOEST_DelayPerShiftHrMin" text,
    "FOEST_EarlyPerShiftHrMin" text,
    "FOEST_LunchHoursDuration" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(b."HRME_EmployeeFirstName", '') || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(b."HRME_EmployeeLastName", '') AS "HRME_EmployeeFirstName",
        e."FOHTWD_HolidayWDType",
        c."FOMS_ShiftName",
        a."FOEST_FDWHrMin",
        a."FOEST_HDWHrMin",
        a."FOEST_IHalfLoginTime",
        a."FOEST_IHalfLogoutTime",
        a."FOEST_IIHalfLoginTime",
        a."FOEST_IIHalfLogoutTime",
        a."FOEST_DelayPerShiftHrMin",
        a."FOEST_EarlyPerShiftHrMin",
        a."FOEST_LunchHoursDuration"
    FROM "fo"."FO_Emp_Shifts_Timings" a 
    INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
    INNER JOIN "fo"."FO_Master_Shifts" c ON c."FOMS_Id" = a."FOMS_Id"
    INNER JOIN "fo"."FO_HolidayWorkingDay_Type" e ON e."FOHWDT_Id" = a."FOHWDT_Id"
    WHERE a."MI_Id" = p_MI_Id;
END;
$$;