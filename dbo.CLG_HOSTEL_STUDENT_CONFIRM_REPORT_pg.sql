CREATE OR REPLACE FUNCTION "dbo"."CLG_HOSTEL_STUDENT_CONFIRM_REPORT"(
    "MI_Id" BIGINT,
    "ctype" VARCHAR(100),
    "frmdate" VARCHAR(20),
    "todate" VARCHAR(20)
)
RETURNS TABLE (
    "StudentName" TEXT,
    "AMCST_AdmNo" VARCHAR,
    "AMCST_Id" BIGINT,
    "AMCO_CourseName" VARCHAR,
    "HLMRCA_RoomCategory" VARCHAR,
    "AMSE_SEMCode" VARCHAR,
    "HLHSREQC_Date" TIMESTAMP,
    "HLHSREQCC_Remarks" TEXT,
    "HLMH_Name" VARCHAR,
    "HLHSREQCC_BookingStatus" VARCHAR,
    "StaffName" TEXT,
    "HRME_Id" BIGINT,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "HRME_EmployeeCode" VARCHAR,
    "HRMRM_RoomNo" VARCHAR,
    "HLHSTREQC_BookingStatus" VARCHAR,
    "HLHSTREQC_Remarks" TEXT,
    "HLHSTREQC_RequestDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "asmay_id" VARCHAR;
    "sqlquery" VARCHAR;
BEGIN

    SELECT "ASMAY_Id" INTO "asmay_id"
    FROM "Adm_School_M_Academic_Year"
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date"
    AND "MI_Id" = "CLG_HOSTEL_STUDENT_CONFIRM_REPORT"."MI_Id";

    IF "ctype" = 'Student' THEN
        RETURN QUERY
        SELECT 
            COALESCE(c."AMCST_FirstName", '') || '' || COALESCE(c."AMCST_MiddleName", '') || '' || COALESCE(c."AMCST_LastName", '') AS "StudentName",
            c."AMCST_AdmNo",
            c."AMCST_Id",
            cls."AMCO_CourseName",
            MR."HLMRCA_RoomCategory",
            ms."AMSE_SEMCode",
            b."HLHSREQC_Date",
            b."HLHSREQCC_Remarks",
            mh."HLMH_Name",
            b."HLHSREQCC_BookingStatus",
            NULL::TEXT AS "StaffName",
            NULL::BIGINT AS "HRME_Id",
            NULL::VARCHAR AS "HRMD_DepartmentName",
            NULL::VARCHAR AS "HRMDES_DesignationName",
            NULL::VARCHAR AS "HRME_EmployeeCode",
            NULL::VARCHAR AS "HRMRM_RoomNo",
            NULL::VARCHAR AS "HLHSTREQC_BookingStatus",
            NULL::TEXT AS "HLHSTREQC_Remarks",
            NULL::TIMESTAMP AS "HLHSTREQC_RequestDate"
        FROM "HL_Hostel_Student_Request_College" a
        INNER JOIN "HL_Hostel_Student_Request_College_Confirm" b ON a."HLHSREQC_Id" = b."HLHSREQC_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" c ON c."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" y ON y."AMCST_Id" = c."AMCST_Id" 
            AND "AMCST_ActiveFlag" = 1 
            AND "AMCST_SOL" = 'S' 
            AND "ACYST_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Academic_Year" Y1 ON y."asmay_Id" = y1."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Course" cls ON y."AMCO_Id" = CLS."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" ms ON y."AMSE_Id" = ms."AMSE_Id"
        INNER JOIN "HL_Master_Hostel" mh ON mh."HLMH_Id" = b."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" MR ON MR."HLMRCA_Id" = b."HLMRCA_Id"
        WHERE a."MI_Id" = "CLG_HOSTEL_STUDENT_CONFIRM_REPORT"."MI_Id" 
        AND a."HLHSREQC_ActiveFlag" = 1 
        AND b."HLHSREQCC_ActiveFlag" = 1 
        AND b."HLHSREQCC_BookingStatus" = 'Approved' 
        AND Y."ASMAY_Id" = "asmay_id"
        AND CAST("HLHSREQC_RequestDate" AS DATE) BETWEEN CAST("frmdate" AS DATE) AND CAST("todate" AS DATE);

    ELSIF "ctype" = 'Staff' THEN
        RETURN QUERY
        SELECT 
            NULL::TEXT AS "StudentName",
            NULL::VARCHAR AS "AMCST_AdmNo",
            NULL::BIGINT AS "AMCST_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            MR."HLMRCA_RoomCategory",
            NULL::VARCHAR AS "AMSE_SEMCode",
            NULL::TIMESTAMP AS "HLHSREQC_Date",
            NULL::TEXT AS "HLHSREQCC_Remarks",
            mh."HLMH_Name",
            NULL::VARCHAR AS "HLHSREQCC_BookingStatus",
            COALESCE(c."HRME_EmployeeFirstName", '') || '' || COALESCE(c."HRME_EmployeeMiddleName", '') || '' || COALESCE(c."HRME_EmployeeLastName", '') AS "StaffName",
            c."HRME_Id",
            "HRMD_DepartmentName",
            "HRMDES_DesignationName",
            c."HRME_EmployeeCode",
            HR."HRMRM_RoomNo",
            b."HLHSTREQC_BookingStatus",
            b."HLHSTREQC_Remarks",
            b."HLHSTREQC_RequestDate"
        FROM "HL_HOSTEL_Staff_Request" a
        INNER JOIN "HL_Hostel_Staff_Request_Confirm" b ON a."HLHSTREQ_Id" = b."HLHSTREQ_Id"
        INNER JOIN "HR_master_Employee" c ON c."HRME_Id" = a."HRME_Id" 
            AND c."HRME_Leftflag" = 0 
            AND "HRME_Activeflag" = 1
        INNER JOIN "HR_Master_Department" y ON c."HRMD_Id" = c."HRMD_Id"
        INNER JOIN "HR_Master_Designation" Y1 ON c."HRMDES_Id" = y1."HRMDES_Id"
        INNER JOIN "HL_Master_Hostel" mh ON mh."HLMH_Id" = b."HLMH_Id"
        INNER JOIN "HL_Master_Room" HR ON HR."HRMRM_Id" = b."HRME_Id"
        INNER JOIN "HL_Master_Room_Category" MR ON MR."HLMRCA_Id" = b."HLMRCA_Id"
        WHERE c."MI_Id" = "CLG_HOSTEL_STUDENT_CONFIRM_REPORT"."MI_Id" 
        AND a."HLHSTREQ_ActiveFlag" = 1 
        AND b."HLHSTREQC_ActiveFlag" = 1 
        AND b."HLHSTREQC_BookingStatus" = 'Approved'
        AND CAST("HLHSTREQC_RequestDate" AS DATE) BETWEEN CAST("frmdate" AS DATE) AND CAST("todate" AS DATE);

    END IF;

    RETURN;

END;
$$;