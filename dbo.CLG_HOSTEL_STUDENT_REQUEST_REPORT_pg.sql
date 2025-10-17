CREATE OR REPLACE FUNCTION "dbo"."CLG_HOSTEL_STUDENT_REQUEST_REPORT"(
    p_MI_Id bigint,
    p_issuertype1 varchar(20),
    p_frmdate date,
    p_todate date
)
RETURNS TABLE(
    "Name" TEXT,
    "Code" TEXT,
    "Id" bigint,
    "CourseCode" TEXT,
    "RoomCategory" TEXT,
    "CourseName" TEXT,
    "SEMCode" TEXT,
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
    -- Get academic year ID
    SELECT "ASMAY_Id" INTO v_asmay_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
    AND "MI_Id" = p_MI_Id;

    IF p_issuertype1 = 'Student' THEN
        RETURN QUERY
        SELECT 
            COALESCE(c."AMCST_FirstName", '') || '' || COALESCE(c."AMCST_MiddleName", '') || '' || COALESCE(c."AMCST_LastName", '') AS "Name",
            c."AMCST_AdmNo" AS "Code",
            c."AMCST_Id" AS "Id",
            cls."AMCO_CourseCode" AS "CourseCode",
            MR."HLMRCA_RoomCategory" AS "RoomCategory",
            cls."AMCO_CourseName" AS "CourseName",
            ms."AMSE_SEMCode" AS "SEMCode",
            a."HLHSREQC_RequestDate" AS "RequestDate",
            mh."HLMH_Name" AS "HostelName",
            a."HLHSREQC_BookingStatus" AS "BookingStatus",
            NULL::TEXT AS "DepartmentName",
            NULL::TEXT AS "DesignationName",
            NULL::TEXT AS "Remarks"
        FROM "HL_Hostel_Student_Request_College" a
        INNER JOIN "CLG"."Adm_Master_College_Student" c ON c."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" y ON y."AMCST_Id" = c."AMCST_Id" 
            AND c."AMCST_ActiveFlag" = 1 
            AND c."AMCST_SOL" = 'S' 
            AND y."ACYST_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Academic_Year" Y1 ON y."ASMAY_Id" = Y1."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Course" cls ON y."AMCO_Id" = cls."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" ms ON y."AMSE_Id" = ms."AMSE_Id"
        INNER JOIN "HL_Master_Hostel" mh ON a."HLMH_Id" = mh."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" MR ON a."HLMRCA_Id" = MR."HLMRCA_Id"
        WHERE a."MI_Id" = p_MI_Id 
        AND a."HLHSREQC_ActiveFlag" = 1 
        AND y."ASMAY_Id" = v_asmay_id 
        AND CAST(a."HLHSREQC_RequestDate" AS date) BETWEEN p_frmdate AND p_todate;

    ELSIF p_issuertype1 = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT
            COALESCE(c."HRME_EmployeeFirstName", '') || '' || COALESCE(c."HRME_EmployeeMiddleName", '') || '' || COALESCE(c."HRME_EmployeeLastName", '') AS "Name",
            c."HRME_EmployeeCode" AS "Code",
            c."HRME_Id" AS "Id",
            NULL::TEXT AS "CourseCode",
            MR."HLMRCA_RoomCategory" AS "RoomCategory",
            NULL::TEXT AS "CourseName",
            NULL::TEXT AS "SEMCode",
            a."HLHSTREQ_RequestDate" AS "RequestDate",
            mh."HLMH_Name" AS "HostelName",
            a."HLHSTREQ_BookingStatus" AS "BookingStatus",
            y."HRMD_DepartmentName" AS "DepartmentName",
            Y1."HRMDES_DesignationName" AS "DesignationName",
            a."HLHSTREQ_Remarks" AS "Remarks"
        FROM "HL_HOSTEL_Staff_Request" a
        INNER JOIN "HR_master_Employee" c ON c."HRME_Id" = a."HRME_Id" 
            AND c."HRME_Leftflag" = 0 
            AND c."HRME_Activeflag" = 1
        INNER JOIN "HR_Master_Department" y ON c."HRMD_Id" = y."HRMD_Id"
        INNER JOIN "HR_Master_Designation" Y1 ON c."HRMDES_Id" = Y1."HRMDES_Id"
        INNER JOIN "HL_Master_Hostel" mh ON mh."HLMH_Id" = a."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" MR ON MR."HLMRCA_Id" = a."HLMRCA_Id"
        WHERE c."MI_Id" = p_MI_Id 
        AND a."HLHSTREQ_ActiveFlag" = 1 
        AND CAST(a."HLHSTREQ_RequestDate" AS date) BETWEEN p_frmdate AND p_todate;

    END IF;

    RETURN;
END;
$$;