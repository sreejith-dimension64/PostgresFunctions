CREATE OR REPLACE FUNCTION "dbo"."HL_Request_Report"(
    p_MI_Id bigint,
    p_frmdate date,
    p_todate date,
    p_issuertype1 varchar(20)
)
RETURNS TABLE (
    person_name text,
    person_code text,
    "HLMRCA_Id" bigint,
    class_or_dept text,
    section_or_designation text,
    "HLMH_Name" text,
    booking_status text,
    remarks text,
    request_date timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_issuertype1 = 'Student' THEN
        RETURN QUERY
        SELECT DISTINCT 
            (COALESCE("A"."AMST_FirstName", '') || ' ' || COALESCE("A"."AMST_MiddleName", '') || ' ' || COALESCE("A"."AMST_LastName", ''))::text AS person_name,
            "A"."AMST_AdmNo"::text AS person_code,
            "B"."HLMRCA_Id",
            "C"."ASMCL_ClassName"::text AS class_or_dept,
            "D"."ASMC_SectionName"::text AS section_or_designation,
            "E"."HLMH_Name"::text,
            "B"."HLHSREQ_BookingStatus"::text AS booking_status,
            NULL::text AS remarks,
            "B"."HLHSREQ_RequestDate"::timestamp AS request_date
        FROM "HL_Hostel_Student_Request" "B"
        INNER JOIN "Adm_M_Student" "A" ON "B"."AMST_Id" = "A"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" "C" ON "C"."ASMCL_Id" = "A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_section" "D" ON "A"."MI_Id" = "D"."MI_Id"
        INNER JOIN "HL_Master_Hostel" "E" ON "B"."HLMH_Id" = "E"."HLMH_Id"
        WHERE "A"."MI_Id" = "B"."MI_Id" 
          AND "E"."MI_Id" = "B"."MI_Id" 
          AND "B"."MI_Id" = p_MI_Id;
    
    ELSIF p_issuertype1 = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT 
            (COALESCE("A"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("A"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("A"."HRME_EmployeeLastName", ''))::text AS person_name,
            "A"."HRME_EmployeeCode"::text AS person_code,
            "STR"."HLMRCA_Id",
            "B"."HRMD_DepartmentName"::text AS class_or_dept,
            "C"."HRMDES_DesignationName"::text AS section_or_designation,
            "D"."HLMH_Name"::text,
            "STR"."HLHSTREQ_BookingStatus"::text AS booking_status,
            "STR"."HLHSTREQ_Remarks"::text AS remarks,
            "STR"."HLHSTREQ_RequestDate"::timestamp AS request_date
        FROM "HL_Hostel_STaff_Request" "STR"
        INNER JOIN "HR_Master_Employee" "A" ON "A"."HRME_Id" = "STR"."HRME_Id"
        INNER JOIN "Hr_master_Department" "B" ON "B"."HRMD_Id" = "A"."HRMD_Id"
        INNER JOIN "Hr_master_Designation" "C" ON "C"."HRMDES_Id" = "A"."HRMDES_Id"
        INNER JOIN "HL_Master_Hostel" "D" ON "D"."HLMH_Id" = "STR"."HLMH_Id"
        WHERE "A"."MI_Id" = "STR"."MI_Id" 
          AND "B"."MI_Id" = "A"."MI_ID" 
          AND "C"."MI_Id" = "A"."MI_Id" 
          AND "D"."MI_Id" = "STR"."MI_Id";
    END IF;
    
    RETURN;
END;
$$;