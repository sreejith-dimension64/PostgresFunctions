CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_STAFF_DETAILS_FOR_GRID"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_HRME_Id BIGINT
)
RETURNS TABLE(
    "HLHSTREQ_Id" BIGINT,
    "HLHSTREQC_Id" BIGINT,
    "empName" TEXT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "HRME_EmployeeCode" VARCHAR,
    "HLMH_Name" VARCHAR,
    "HLMH_Id" BIGINT,
    "HLMRCA_RoomCategory" VARCHAR,
    "HLHSTREQ_RequestDate" TIMESTAMP,
    "HLHSTREQ_Remarks" TEXT,
    "HLHSTREQ_BookingStatus" VARCHAR,
    "HLMRCA_Id" BIGINT,
    "HLHSTREQ_ACRoomReqdFlg" BOOLEAN,
    "HLHSTREQ_EntireRoomReqdFlg" BOOLEAN,
    "HLHSTREQ_VegMessReqdFlg" BOOLEAN,
    "HLHSTREQ_NonVegMessReqdFlg" BOOLEAN,
    "HLHSTREQ_ActiveFlag" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        HSR."HLHSTREQ_Id",
        "HLHSTREQC_Id",
        COALESCE(HME."HRME_EmployeeFirstName", '') || ' ' || COALESCE(HME."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(HME."HRME_EmployeeLastName", '') as "empName",
        HMD."HRMD_DepartmentName",
        HMDES."HRMDES_DesignationName",
        HME."HRME_EmployeeCode",
        MH."HLMH_Name",
        HSR."HLMH_Id",
        MRC."HLMRCA_RoomCategory",
        HSR."HLHSTREQ_RequestDate",
        HSR."HLHSTREQ_Remarks",
        HSR."HLHSTREQ_BookingStatus",
        HSR."HLMRCA_Id",
        HSR."HLHSTREQ_ACRoomReqdFlg",
        HSR."HLHSTREQ_EntireRoomReqdFlg",
        HSR."HLHSTREQ_VegMessReqdFlg",
        HSR."HLHSTREQ_NonVegMessReqdFlg",
        HSR."HLHSTREQ_ActiveFlag"
    FROM "HL_Hostel_Staff_Request" HSR
    INNER JOIN "HL_Hostel_Staff_Request_Confirm" HSRC ON HSRC."HLHSTREQ_Id" = HSR."HLHSTREQ_Id"
    INNER JOIN "HL_Master_Hostel" MH ON HSR."HLMH_Id" = MH."HLMH_Id"
    INNER JOIN "HL_Master_Room_Category" MRC ON HSR."HLMRCA_Id" = MRC."HLMRCA_Id"
    INNER JOIN "HR_Master_Employee" HME ON HME."HRME_Id" = HSR."HRME_Id" AND HME."HRME_ActiveFlag" = TRUE AND HME."HRME_LeftFlag" = FALSE
    INNER JOIN "HR_Master_Department" HMD ON HME."HRMD_Id" = HMD."HRMD_Id"
    INNER JOIN "HR_Master_Designation" HMDES ON HME."HRMDES_Id" = HMDES."HRMDES_Id"
    WHERE HSR."MI_Id" = p_MI_Id AND HSR."HRME_Id" = p_HRME_Id;

END;
$$;