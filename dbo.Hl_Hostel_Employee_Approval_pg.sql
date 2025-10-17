CREATE OR REPLACE FUNCTION "Hl_Hostel_Employee_Approval"(p_mi_id bigint)
RETURNS TABLE(
    "HRME_Id" bigint,
    "HRME_EmployeeFirstName" text,
    "HLHSTREQ_Id" bigint,
    "HRMD_DepartmentName" text,
    "HRMDES_DesignationName" text,
    "HRMRM_Id" bigint,
    "HLMH_Name" text,
    "HLMRCA_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        b."HRME_Id",
        CONCAT(COALESCE(b."HRME_EmployeeFirstName",''),'',COALESCE(b."HRME_EmployeeMiddleName",''),'',COALESCE(b."HRME_EmployeeLastName",'')) as "HRME_EmployeeFirstName",
        a."HLHSTREQ_Id",
        c."HRMD_DepartmentName",
        d."HRMDES_DesignationName",
        e."HRMRM_Id",
        f."HLMH_Name",
        g."HLMRCA_Id"
    FROM "HL_Hostel_Staff_Request" a 
    INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id" AND b."HRME_ActiveFlag" = 1
    INNER JOIN "HR_Master_Department" c ON c."HRMD_Id" = b."HRMD_Id"
    INNER JOIN "HR_Master_Designation" d ON d."HRMDES_Id" = b."HRMDES_Id"
    INNER JOIN "HL_Master_Room" e ON e."HLMH_Id" = a."HLMH_Id" AND e."HLMRCA_Id" = a."HLMRCA_Id"
    INNER JOIN "HL_Master_Hostel" f ON f."HLMH_Id" = a."HLMH_Id"
    INNER JOIN "HL_Master_Room_Category" g ON g."HLMRCA_Id" = a."HLMRCA_Id"
    INNER JOIN "HL_Hostel_Staff_Request_Confirm" h ON h."HLHSTREQ_Id" = a."HLHSTREQ_Id" AND h."HLHSTREQC_ActiveFlag" = 1
    WHERE a."MI_Id" = p_mi_id 
        AND a."HLHSTREQ_ActiveFlag" = 1 
        AND a."HLHSTREQ_BookingStatus" = 'Approved';
    
    RETURN;
END;
$$;