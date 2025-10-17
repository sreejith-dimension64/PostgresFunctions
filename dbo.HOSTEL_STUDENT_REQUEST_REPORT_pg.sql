CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_STUDENT_REQUEST_REPORT"(
    p_MI_Id bigint,
    p_issuertype1 varchar(20),
    p_frmdate date,
    p_todate date
)
RETURNS TABLE (
    "Name" TEXT,
    "Code" TEXT,
    "Id" bigint,
    "ClassName" TEXT,
    "RoomCategory" TEXT,
    "SectionName" TEXT,
    "RequestDate" TIMESTAMP,
    "HostelName" TEXT,
    "BookingStatus" TEXT,
    "DepartmentName" TEXT,
    "DesignationName" TEXT,
    "Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_asmay_id bigint;
BEGIN

    SELECT "ASMAY_Id" INTO v_asmay_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
    AND "MI_Id" = p_MI_Id;

    IF p_issuertype1 = 'Student' THEN
        RETURN QUERY
        SELECT 
            COALESCE("c"."AMST_FirstName", '') || '' || COALESCE("c"."AMST_MiddleName", '') || '' || COALESCE("c"."AMST_LastName", '') AS "Name",
            "c"."AMST_AdmNo" AS "Code",
            "c"."AMST_Id" AS "Id",
            "cls"."ASMCL_ClassName" AS "ClassName",
            "MR"."HLMRCA_RoomCategory" AS "RoomCategory",
            "ms"."ASMC_SectionName" AS "SectionName",
            "a"."HLHSREQ_RequestDate" AS "RequestDate",
            "mh"."HLMH_Name" AS "HostelName",
            "a"."HLHSREQ_BookingStatus" AS "BookingStatus",
            NULL::TEXT AS "DepartmentName",
            NULL::TEXT AS "DesignationName",
            NULL::TEXT AS "Remarks"
        FROM "HL_Hostel_Student_Request" "a"
        INNER JOIN "Adm_M_Student" "c" ON "c"."AMST_Id" = "a"."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" "y" ON "y"."AMST_Id" = "c"."AMST_Id" 
            AND "AMST_ActiveFlag" = 1 
            AND "AMST_SOL" = 'S' 
            AND "AMAY_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Academic_Year" "Y1" ON "y"."asmay_Id" = "y1"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "cls" ON "y"."ASMCL_id" = "CLS"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "ms" ON "y"."ASMS_Id" = "ms"."ASMS_Id"
        INNER JOIN "HL_Master_Hostel" "mh" ON "a"."HLMH_Id" = "mh"."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" "MR" ON "a"."HLMRCA_Id" = "MR"."HLMRCA_Id"
        WHERE "a"."MI_Id" = p_MI_Id 
        AND "a"."HLHSREQ_ActiveFlag" = 1 
        AND "y"."ASMAY_Id" = v_asmay_id  
        AND CAST("a"."HLHSREQ_RequestDate" AS date) BETWEEN p_frmdate AND p_todate;

    ELSIF p_issuertype1 = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT
            COALESCE("c"."HRME_EmployeeFirstName", '') || '' || COALESCE("c"."HRME_EmployeeMiddleName", '') || '' || COALESCE("c"."HRME_EmployeeLastName", '') AS "Name",
            "c"."HRME_EmployeeCode" AS "Code",
            "c"."HRME_Id" AS "Id",
            NULL::TEXT AS "ClassName",
            "MR"."HLMRCA_RoomCategory" AS "RoomCategory",
            NULL::TEXT AS "SectionName",
            "a"."HLHSTREQ_RequestDate" AS "RequestDate",
            "mh"."HLMH_Name" AS "HostelName",
            "a"."HLHSTREQ_BookingStatus" AS "BookingStatus",
            "HRMD_DepartmentName" AS "DepartmentName",
            "HRMDES_DesignationName" AS "DesignationName",
            "a"."HLHSTREQ_Remarks" AS "Remarks"
        FROM "HL_HOSTEL_Staff_Request" "a"
        INNER JOIN "HR_master_Employee" "c" ON "c"."HRME_Id" = "a"."HRME_Id" 
            AND "c"."HRME_Leftflag" = 0 
            AND "c"."HRME_Activeflag" = 1
        INNER JOIN "HR_Master_Department" "y" ON "c"."HRMD_Id" = "y"."HRMD_Id"
        INNER JOIN "HR_Master_Designation" "Y1" ON "c"."HRMDES_Id" = "y1"."HRMDES_Id"
        INNER JOIN "HL_Master_Hostel" "mh" ON "mh"."HLMH_Id" = "a"."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" "MR" ON "MR"."HLMRCA_Id" = "a"."HLMRCA_Id"
        WHERE "c"."MI_Id" = p_MI_Id 
        AND "a"."HLHSTREQ_ActiveFlag" = 1 
        AND CAST("a"."HLHSTREQ_RequestDate" AS date) BETWEEN p_frmdate AND p_todate;

    END IF;

    RETURN;
END;
$$;