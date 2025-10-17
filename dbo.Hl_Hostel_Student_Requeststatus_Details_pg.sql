CREATE OR REPLACE FUNCTION "Hl_Hostel_Student_Requeststatus_Details"(
    p_mi_id BIGINT,
    p_asmay_id BIGINT,
    p_type VARCHAR(200),
    p_startdate TIMESTAMP,
    p_enddate TIMESTAMP
)
RETURNS TABLE(
    id BIGINT,
    name TEXT,
    request_id BIGINT,
    hostel_name VARCHAR,
    room_id BIGINT,
    room_category VARCHAR,
    year VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_type = 'Approved' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."AMST_Id",
            CONCAT(COALESCE(b."AMST_Firstname",''),'',COALESCE(b."AMST_MiddleName",''),'',COALESCE(b."AMST_LastName",'')) AS "AMST_Firstname",
            a."HLHSREQ_Id",
            d."HLMH_Name",
            e."HRMRM_Id",
            f."HLMRCA_RoomCategory",
            h."ASMAY_Year"
        FROM "HL_Hostel_Student_Request" a 
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id" AND b."AMST_SOL" = 'S'
        INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = a."AMST_Id" AND "AMST_ActiveFlag" = 1
        INNER JOIN "HL_Master_Hostel" d ON d."HLMH_Id" = a."HLMH_Id"
        INNER JOIN "HL_Master_Room" e ON e."HLMH_Id" = a."HLMH_Id" AND e."HLMRCA_Id" = a."HLMRCA_Id"
        INNER JOIN "HL_Master_Room_Category" f ON f."HLMRCA_Id" = a."HLMRCA_Id"
        INNER JOIN "HL_Hostel_Student_Request_Confirm" g ON g."HLHSREQ_Id" = a."HLHSREQ_Id" AND g."HLHSREQC_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Academic_Year" h ON h."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" i ON i."ASMCL_Id" = c."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" j ON j."ASMS_Id" = c."ASMS_Id"
        WHERE a."MI_Id" = p_mi_id 
            AND a."HLHSREQ_ActiveFlag" = 1 
            AND a."HLHSREQ_BookingStatus" = p_type 
            AND CAST(a."HLHSREQ_RequestDate" AS DATE) BETWEEN p_startdate AND p_enddate;
    
    ELSIF p_type = 'Rejected' THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."AMCST_Id",
            CONCAT(COALESCE(b."AMCST_FirstName",''),'',COALESCE(b."AMCST_MiddleName",''),'',COALESCE(b."AMCST_LastName",'')) AS "AMCST_FirstName",
            a."HLHSREQC_Id",
            c."ACYST_Id",
            d."ASMAY_Id",
            e."AMB_BranchName",
            f."AMSE_SEMName"::VARCHAR AS room_category,
            d."ASMAY_Year"
        FROM "HL_Hostel_Student_Request_College" a 
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" AND b."AMCST_SOL" = 'S' AND b."AMCST_ActiveFlag" = 1
        INNER JOIN "clg"."Adm_College_Yearly_Student" c ON c."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" d ON d."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Branch" e ON e."AMB_Id" = c."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = c."AMSE_Id"
        INNER JOIN "clg"."Adm_Master_Course" g ON g."AMCO_Id" = c."AMCO_Id"
        INNER JOIN "HL_Master_Room" h ON h."HLMH_Id" = a."HLMH_Id" AND h."HLMRCA_Id" = a."HLMRCA_Id"
        INNER JOIN "HL_Master_Hostel" i ON i."HLMH_Id" = a."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" j ON j."HLMRCA_Id" = a."HLMRCA_Id"
        INNER JOIN "HL_Hostel_Student_Request_College_Confirm" k ON k."HLHSREQC_Id" = a."HLHSREQC_Id" AND "HLHSREQCC_ActiveFlag" = 1
        WHERE a."MI_Id" = p_mi_id 
            AND a."HLHSREQC_ActiveFlag" = 1 
            AND a."HLHSREQC_BookingStatus" = p_type 
            AND CAST(a."HLHSREQC_RequestDate" AS DATE) BETWEEN p_startdate AND p_enddate;
    
    END IF;
    
    RETURN;
END;
$$;