CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_HOUSE_WISE_STAFF_LIST"(
    "p_MI_Id" BIGINT,
    "p_HLMH_Id" BIGINT
)
RETURNS TABLE(
    "HLHSTREQC_BookingStatus" VARCHAR,
    "staffname" TEXT,
    "HRME_Id" BIGINT,
    "HRMD_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_Id" BIGINT,
    "HRMDES_DesignationName" VARCHAR,
    "HRME_EmployeeCode" VARCHAR,
    "HLHSTREQC_ACRoomFlg" BOOLEAN,
    "HLHSTREQC_SingleRoomFlg" BOOLEAN,
    "HLHSTREQC_VegMessFlg" BOOLEAN,
    "HLHSTREQC_NonVegMessFlg" BOOLEAN,
    "HLMRCA_Id" BIGINT,
    "HLMRCA_RoomCategory" VARCHAR,
    "HRMRM_RoomNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "HSRC"."HLHSTREQC_BookingStatus",
        COALESCE("A"."HRME_EmployeeFirstName",'') || ' ' || COALESCE("A"."HRME_EmployeeMiddleName",'') || ' ' || COALESCE("A"."HRME_EmployeeLastName",'') AS "staffname",
        "A"."HRME_Id",
        "B"."HRMD_Id",
        "B"."HRMD_DepartmentName",
        "C"."HRMDES_Id",
        "C"."HRMDES_DesignationName",
        "A"."HRME_EmployeeCode",
        "HSRC"."HLHSTREQC_ACRoomFlg",
        "HSRC"."HLHSTREQC_SingleRoomFlg",
        "HSRC"."HLHSTREQC_VegMessFlg",
        "HSRC"."HLHSTREQC_NonVegMessFlg",
        "HSRC"."HLMRCA_Id",
        "MRC"."HLMRCA_RoomCategory",
        "MR"."HRMRM_RoomNo"
    FROM "HL_Master_Hostel" "MH"
    INNER JOIN "HL_Hostel_Staff_Request_Confirm" "HSRC" ON "HSRC"."HLMH_Id" = "MH"."HLMH_Id"
    INNER JOIN "HL_Hostel_Staff_Request" "HSR" ON "HSR"."HLHSTREQ_Id" = "HSRC"."HLHSTREQ_Id"
    INNER JOIN "HR_Master_Employee" "A" ON "A"."HRME_Id" = "HSR"."HRME_Id"
    INNER JOIN "HR_Master_Department" "B" ON "B"."HRMD_Id" = "A"."HRMD_Id" AND "B"."MI_Id" = "HSRC"."MI_Id"
    INNER JOIN "HR_Master_Designation" "C" ON "C"."HRMDES_Id" = "A"."HRMDES_Id"
    INNER JOIN "HL_Master_Room" "MR" ON "HSRC"."HRMRM_Id" = "MR"."HRMRM_Id"
    INNER JOIN "HL_Master_Room_Category" "MRC" ON "HSRC"."HLMRCA_Id" = "MRC"."HLMRCA_Id"
    WHERE "MH"."MI_Id" = "p_MI_Id" 
        AND "MH"."HLMH_Id" = "p_HLMH_Id" 
        AND "MH"."HLMH_ActiveFlag" = true 
        AND "HSRC"."HLHSTREQC_ActiveFlag" = true 
        AND "A"."HRME_LeftFlag" = false 
        AND "A"."MI_Id" = "p_MI_Id" 
        AND "A"."MI_Id" = "B"."MI_Id" 
        AND "A"."HRME_ActiveFlag" = true 
        AND "HSRC"."HLHSTREQC_BookingStatus" = 'Approved';
END;
$$;