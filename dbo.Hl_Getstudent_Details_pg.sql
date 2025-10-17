CREATE OR REPLACE FUNCTION "Hl_Getstudent_Details"(
    p_mi_id BIGINT,
    p_ASMAY_Id BIGINT,
    p_type VARCHAR(500)
)
RETURNS TABLE (
    id BIGINT,
    name TEXT,
    col3 BIGINT,
    col4 BIGINT,
    col5 BIGINT,
    col6 BIGINT,
    col7 BIGINT,
    col8 BIGINT
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_type = 'Schoolstudents') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."AMST_Id",
            CONCAT(COALESCE(a."AMST_FirstName",''), ' ', COALESCE(a."AMST_MiddleName",''), ' ', COALESCE(a."AMST_LastName",'')) AS "AMST_FirstName",
            b."ASMCL_Id",
            b."ASMS_Id",
            d."HLMH_Id",
            e."HRMRM_Id",
            NULL::BIGINT,
            NULL::BIGINT
        FROM "Adm_M_Student" a 
        INNER JOIN "adm_school_y_student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "HL_Hostel_Student_Request" c ON c."AMST_Id" = b."AMST_Id"
        INNER JOIN "HL_Master_Hostel" d ON d."HLMH_Id" = c."HLMH_Id"
        INNER JOIN "HL_Master_Room" e ON e."HLMH_Id" = c."HLMH_Id"
        WHERE a."MI_Id" = p_mi_id 
            AND a."AMST_ActiveFlag" = 1 
            AND a."AMST_SOL" = 'S' 
            AND b."ASMAY_Id" = p_ASMAY_Id;

    ELSIF (p_type = 'collegestudents') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."AMCST_Id",
            CONCAT(COALESCE(a."AMCST_FirstName",''), '', COALESCE(a."AMCST_MiddleName",''), '', COALESCE(a."AMCST_LastName",'')) AS "AMCST_FirstName",
            b."AMB_Id",
            b."AMSE_Id",
            c."HLHSREQC_Id",
            d."HLMH_Id",
            e."HLMRCA_Id",
            f."HRMRM_Id"
        FROM "clg"."Adm_Master_College_Student" a 
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "HL_Hostel_Student_Request_College" c ON c."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "HL_Master_Hostel" d ON d."HLMH_Id" = c."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" e ON e."HLMRCA_Id" = c."HLMRCA_Id"
        INNER JOIN "HL_Master_Room" f ON f."HLMH_Id" = c."HLMH_Id"
        WHERE a."MI_Id" = p_mi_id 
            AND a."AMCST_ActiveFlag" = 1 
            AND a."AMCST_SOL" = 's' 
            AND b."ASMAY_Id" = p_ASMAY_Id;

    END IF;

END;
$$;