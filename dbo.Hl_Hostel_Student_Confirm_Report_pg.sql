CREATE OR REPLACE FUNCTION "Hl_Hostel_Student_Confirm_Report"(
    p_mi_id BIGINT,
    p_type VARCHAR(400),
    p_fromdate TIMESTAMP,
    p_todate TIMESTAMP
)
RETURNS TABLE (
    student_id BIGINT,
    student_name TEXT,
    request_id BIGINT,
    academic_year TEXT,
    detail1 TEXT,
    detail2 TEXT,
    detail3 TEXT,
    room_id BIGINT,
    room_category TEXT,
    hostel_address TEXT,
    building_status TEXT,
    rent_amount NUMERIC,
    contact_no TEXT,
    hostel_name TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_type = 'Schoolstudent' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."AMST_Id",
            CONCAT(COALESCE(b."AMST_FirstName",''), '', COALESCE(b."AMST_MiddleName",''), '', COALESCE(b."AMST_LastName",''))::TEXT AS student_name,
            a."HLHSREQ_Id",
            c."ASMAY_Year"::TEXT,
            e."ASMC_SectionName"::TEXT,
            f."ASMCL_ClassName"::TEXT,
            NULL::TEXT,
            g."HRMRM_Id",
            h."HLMRCA_RoomCategory"::TEXT,
            i."HLMH_Address"::TEXT,
            i."HLMH_Building_Status"::TEXT,
            i."HLMH_Rent_Amount",
            i."HLMH_ContactNo"::TEXT,
            i."HLMH_Name"::TEXT
        FROM "HL_Hostel_Student_Request" a
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = b."ASMAY_Id" AND c."ASMAY_ActiveFlag" = 1
        INNER JOIN "Adm_School_Y_Student" d ON d."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = d."ASMS_Id"
        INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = d."ASMCL_Id"
        INNER JOIN "HL_Master_Room" g ON g."HLMRCA_Id" = a."HLMRCA_Id"
        INNER JOIN "HL_Master_Room_Category" h ON h."HLMRCA_Id" = a."HLMRCA_Id"
        INNER JOIN "HL_Master_Hostel" i ON i."HLMH_Id" = a."HLMH_Id"
        INNER JOIN "HL_Hostel_Student_Request_Confirm" j ON j."HLHSREQ_Id" = a."HLHSREQ_Id" AND j."HLHSREQ_ActiveFlag" = 1
        WHERE a."MI_Id" = p_mi_id 
            AND a."HLHSREQ_BookingStatus" = 'Approved' 
            AND CAST(a."HLHSREQ_RequestDate" AS DATE) BETWEEN p_fromdate AND p_todate;

    ELSIF p_type = 'collegestudent' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."AMCST_Id",
            CONCAT(COALESCE(b."AMCST_FirstName",''), '', COALESCE(b."AMCST_MiddleName",''), '', COALESCE(b."AMCST_LastName",''))::TEXT AS student_name,
            a."HLHSREQC_Id",
            c."ASMAY_Year"::TEXT,
            e."AMCO_CourseName"::TEXT,
            f."AMB_BranchName"::TEXT,
            g."AMSE_SEMName"::TEXT,
            NULL::BIGINT,
            NULL::TEXT,
            j."HLMH_Address"::TEXT,
            j."HLMH_Building_Status"::TEXT,
            j."HLMH_Rent_Amount",
            j."HLMH_ContactNo"::TEXT,
            j."HLMH_Name"::TEXT
        FROM "HL_Hostel_Student_Request_College" a
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = b."ASMAY_Id" AND c."ASMAY_ActiveFlag" = 1
        INNER JOIN "clg"."Adm_College_Yearly_Student" d ON d."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = d."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = d."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = d."AMSE_Id"
        INNER JOIN "HL_Master_Room" h ON h."HLMRCA_Id" = a."HLMRCA_Id"
        INNER JOIN "HL_Master_Room_Category" i ON i."HLMRCA_Id" = a."HLMRCA_Id"
        INNER JOIN "HL_Master_Hostel" j ON j."HLMH_Id" = a."HLMH_Id"
        INNER JOIN "HL_Hostel_Student_Request_College_Confirm" k ON k."HLHSREQC_Id" = a."HLHSREQC_Id" AND k."HLHSREQC_ActiveFlag" = 1
        WHERE a."MI_Id" = p_mi_id 
            AND a."HLHSREQC_BookingStatus" = 'Approved' 
            AND CAST(a."HLHSREQC_RequestDate" AS DATE) BETWEEN p_fromdate AND p_todate;

    END IF;
END;
$$;