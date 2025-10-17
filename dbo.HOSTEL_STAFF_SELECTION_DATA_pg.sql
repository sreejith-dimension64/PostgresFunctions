CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_STAFF_SELECTION_DATA"(
    p_MI_Id BIGINT,
    p_HRME_Id BIGINT
)
RETURNS TABLE(
    "HRME_Id" BIGINT,
    "staffname" TEXT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "HLMH_Name" VARCHAR,
    "HRMRM_RoomNo" VARCHAR,
    "HLHSTALT_AllotmentDate" DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "ME"."HRME_Id",
        COALESCE("ME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("ME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("ME"."HRME_EmployeeLastName", '') AS "staffname",
        "MD"."HRMD_DepartmentName",
        "MDES"."HRMDES_DesignationName",
        "MH"."HLMH_Name",
        "MR"."HRMRM_RoomNo",
        CAST("HS"."HLHSTALT_AllotmentDate" AS DATE) AS "HLHSTALT_AllotmentDate"
    FROM "HL_Hostel_Staff_Allot" "HS"
    INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HS"."HRME_Id"
    INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
    INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
    INNER JOIN "HL_Master_Hostel" "MH" ON "HS"."HLMH_Id" = "MH"."HLMH_Id"
    INNER JOIN "HL_Master_Room" "MR" ON "HS"."HRMRM_Id" = "MR"."HRMRM_Id"
    WHERE "HS"."MI_Id" = p_MI_Id 
        AND "HS"."HRME_Id" = p_HRME_Id 
        AND "ME"."HRME_ActiveFlag" = 1 
        AND "ME"."HRME_LeftFlag" = 0;
END;
$$;