CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_STUDENT_CONFIRM_REPORT"(
    p_MI_Id BIGINT,
    p_ctype VARCHAR(100),
    p_frmdate VARCHAR(20),
    p_todate VARCHAR(20)
)
RETURNS TABLE(
    "Name" TEXT,
    "Col2" TEXT,
    "Col3" BIGINT,
    "Col4" TEXT,
    "Col5" TEXT,
    "Col6" TEXT,
    "Col7" TEXT,
    "Col8" TEXT,
    "Col9" TEXT,
    "Col10" TEXT,
    "Col11" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_asmay_id BIGINT;
BEGIN

    SELECT "ASMAY_Id" INTO v_asmay_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
    AND "MI_Id" = p_MI_Id;

    IF p_ctype = 'Student' THEN
        RETURN QUERY
        SELECT 
            COALESCE(c."AMST_FirstName", '') || '' || COALESCE(c."AMST_MiddleName", '') || '' || COALESCE(c."AMST_LastName", '') AS "Name",
            c."AMST_AdmNo"::TEXT AS "Col2",
            c."AMST_Id" AS "Col3",
            cls."ASMCL_ClassName" AS "Col4",
            MR."HLMRCA_RoomCategory" AS "Col5",
            ms."ASMC_SectionName" AS "Col6",
            b."HLHSREQC_Date"::TEXT AS "Col7",
            b."HLHSREQC_Remarks" AS "Col8",
            HR."HRMRM_RoomNo" AS "Col9",
            mh."HLMH_Name" AS "Col10",
            b."HLHSREQC_BookingStatus" AS "Col11"
        FROM "HL_Hostel_Student_Request" a
        INNER JOIN "HL_Hostel_Student_Request_Confirm" b ON a."HLHSREQ_Id" = b."HLHSREQ_Id"
        INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = a."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" y ON y."AMST_Id" = c."AMST_Id" 
            AND "AMST_ActiveFlag" = 1 AND "AMST_SOL" = 'S' AND "AMAY_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Academic_Year" Y1 ON y."asmay_Id" = Y1."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" cls ON y."ASMCL_id" = cls."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ms ON y."ASMS_Id" = ms."ASMS_Id"
        INNER JOIN "HL_Master_Room" HR ON HR."HRMRM_Id" = b."HRMRM_Id"
        INNER JOIN "HL_Master_Hostel" mh ON mh."HLMH_Id" = b."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" MR ON MR."HLMRCA_Id" = b."HLMRCA_Id"
        WHERE a."MI_Id" = p_MI_Id 
        AND a."HLHSREQ_ActiveFlag" = 1 
        AND b."HLHSREQC_ActiveFlag" = 1 
        AND b."HLHSREQC_BookingStatus" = 'Approved' 
        AND y."ASMAY_Id" = v_asmay_id
        AND CAST(a."HLHSREQ_RequestDate" AS DATE) BETWEEN CAST(p_frmdate AS DATE) AND CAST(p_todate AS DATE);

    ELSIF p_ctype = 'Staff' THEN
        RETURN QUERY
        SELECT 
            COALESCE(c."HRME_EmployeeFirstName", '') || '' || COALESCE(c."HRME_EmployeeMiddleName", '') || '' || COALESCE(c."HRME_EmployeeLastName", '') AS "Name",
            c."HRME_Id"::TEXT AS "Col2",
            y."HRMD_DepartmentName"::TEXT AS "Col3",
            Y1."HRMDES_DesignationName" AS "Col4",
            c."HRME_EmployeeCode" AS "Col5",
            mh."HLMH_Name" AS "Col6",
            MR."HLMRCA_RoomCategory" AS "Col7",
            b."HLHSTREQC_BookingStatus" AS "Col8",
            b."HLHSTREQC_Remarks" AS "Col9",
            b."HLHSTREQC_RequestDate"::TEXT AS "Col10",
            HR."HRMRM_RoomNo" AS "Col11"
        FROM "HL_HOSTEL_Staff_Request" a
        INNER JOIN "HL_Hostel_Staff_Request_Confirm" b ON a."HLHSTREQ_Id" = b."HLHSTREQ_Id"
        INNER JOIN "HR_master_Employee" c ON c."HRME_Id" = a."HRME_Id" 
            AND c."HRME_Leftflag" = 0 AND c."HRME_Activeflag" = 1
        INNER JOIN "HR_Master_Department" y ON c."HRMD_Id" = c."HRMD_Id"
        INNER JOIN "HR_Master_Designation" Y1 ON c."HRMDES_Id" = Y1."HRMDES_Id"
        INNER JOIN "HL_Master_Hostel" mh ON mh."HLMH_Id" = b."HLMH_Id"
        INNER JOIN "HL_Master_Room" HR ON HR."HRMRM_Id" = b."HRME_Id"
        INNER JOIN "HL_Master_Room_Category" MR ON MR."HLMRCA_Id" = b."HLMRCA_Id"
        WHERE c."MI_Id" = p_MI_Id 
        AND a."HLHSTREQ_ActiveFlag" = 1 
        AND b."HLHSTREQC_ActiveFlag" = 1 
        AND b."HLHSTREQC_BookingStatus" = 'Approved'
        AND CAST(b."HLHSTREQC_RequestDate" AS DATE) BETWEEN CAST(p_frmdate AS DATE) AND CAST(p_todate AS DATE);

    END IF;

    RETURN;

END;
$$;