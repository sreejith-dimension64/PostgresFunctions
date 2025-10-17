CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_ALLOT_FOR_STAFF"(p_MI_Id BIGINT)
RETURNS TABLE(
    "staffName" TEXT,
    "HRMD_DepartmentName" VARCHAR,
    "HLMH_Name" VARCHAR,
    "HLMRCA_RoomCategory" VARCHAR,
    "HLHSTALT_AllotmentDate" TIMESTAMP,
    "HRMRM_RoomNo" VARCHAR,
    "HLHSTALT_ActiveFlag" BOOLEAN,
    "HLMH_Id" BIGINT,
    "HRMDES_DesignationName" VARCHAR,
    "HLHSTREQ_RequestDate" TIMESTAMP,
    "HLHSTREQ_BookingStatus" VARCHAR,
    "HLHSTALT_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        COALESCE("A"."HRME_EmployeeFirstName",'') || ' ' || COALESCE("A"."HRME_EmployeeMiddleName",'') || ' ' || COALESCE("A"."HRME_EmployeeLastName",'') as "staffName",
        "B"."HRMD_DepartmentName",
        "MH"."HLMH_Name",
        "MRC"."HLMRCA_RoomCategory",
        "HSA"."HLHSTALT_AllotmentDate",
        "MR"."HRMRM_RoomNo",
        "HSA"."HLHSTALT_ActiveFlag",
        "MH"."HLMH_Id",
        "C"."HRMDES_DesignationName",
        "HSRC"."HLHSTREQ_RequestDate",
        "HSRC"."HLHSTREQ_BookingStatus",
        "HSA"."HLHSTALT_Id"
    FROM "HL_Hostel_Staff_Allot" "HSA"
    INNER JOIN "HL_Hostel_Staff_Request" "HSRC" ON "HSRC"."HRME_Id" = "HSA"."HRME_Id"
    INNER JOIN "HL_Hostel_Staff_Request_Confirm" "HSR" ON "HSR"."HLHSTREQ_Id" = "HSR"."HLHSTREQ_Id"
    INNER JOIN "HL_Master_Hostel" "MH" ON "HSRC"."HLMH_Id" = "MH"."HLMH_Id"
    INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
    INNER JOIN "HL_Master_Room_Category" "MRC" ON "HSRC"."HLMRCA_Id" = "MRC"."HLMRCA_Id"
    INNER JOIN "HR_Master_Employee" "A" ON "A"."HRME_Id" = "HSA"."HRME_Id"
    INNER JOIN "HR_Master_Department" "B" ON "A"."HRMD_Id" = "B"."HRMD_Id"
    INNER JOIN "HR_Master_Designation" "C" ON "A"."HRMDES_Id" = "C"."HRMDES_Id"
    WHERE "HSRC"."MI_Id" = p_MI_Id 
        AND "HSRC"."HLHSTREQ_BookingStatus" = 'Approved' 
        AND "A"."HRME_LeftFlag" = 0 
        AND "A"."HRME_ActiveFlag" = 1;
END;
$$;