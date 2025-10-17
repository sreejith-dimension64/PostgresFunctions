CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_VACANT_GRID_REPORTLIST"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_type VARCHAR(50)
)
RETURNS TABLE(
    name TEXT,
    field2 TEXT,
    field3 TEXT,
    hostel_name TEXT,
    room_no TEXT,
    identifier TEXT,
    entity_id BIGINT,
    vacate_flag INTEGER,
    vacated_date TIMESTAMP,
    vacate_remarks TEXT,
    allotment_date TIMESTAMP,
    room_category_id BIGINT
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_type = 'student' THEN
        RETURN QUERY
        SELECT 
            COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '') AS name,
            "MC"."ASMCL_ClassName" AS field2,
            "MS"."ASMC_SectionName" AS field3,
            "MH"."HLMH_Name" AS hostel_name,
            "MR"."HRMRM_RoomNo" AS room_no,
            "AMS"."AMST_AdmNo" AS identifier,
            "HSA"."AMST_Id" AS entity_id,
            CASE WHEN "HSA"."HLHSALT_VacateFlg" THEN 1 ELSE 0 END AS vacate_flag,
            "HSA"."HLHSALT_VacatedDate" AS vacated_date,
            "HSA"."HLHSALT_VacateRemarks" AS vacate_remarks,
            "HSA"."HLHSALT_AllotmentDate" AS allotment_date,
            "HSA"."HLMRCA_Id" AS room_category_id
        FROM "HL_Hostel_Student_Allot" "HSA"
        INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = "HSA"."AMST_Id" 
            AND "YS"."ASMAY_Id" = "HSA"."ASMAY_Id" 
            AND "YS"."ASMCL_Id" = "HSA"."ASMCL_Id" 
            AND "YS"."ASMS_Id" = "HSA"."ASMS_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "YS"."AMST_Id" = "AMS"."AMST_Id" 
            AND "AMS"."AMST_SOL" = 'S'
        INNER JOIN "Adm_School_M_Class" "MC" ON "YS"."ASMCL_Id" = "MC"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "MS" ON "YS"."ASMS_Id" = "MS"."ASMS_Id"
        INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
        INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id" 
            AND "HSA"."HLMRCA_Id" = "MR"."HLMRCA_Id"
        WHERE "HSA"."MI_Id" = p_MI_Id 
            AND "YS"."ASMAY_Id" = p_ASMAY_Id 
            AND "HSA"."HLHSALT_VacateFlg" = TRUE;

    ELSIF p_type = 'staff' THEN
        RETURN QUERY
        SELECT 
            COALESCE("ME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("ME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("ME"."HRME_EmployeeLastName", '') AS name,
            "MD"."HRMD_DepartmentName" AS field2,
            "MDES"."HRMDES_DesignationName" AS field3,
            "MH"."HLMH_Name" AS hostel_name,
            "MR"."HRMRM_RoomNo" AS room_no,
            NULL::TEXT AS identifier,
            "HSA"."HRME_Id" AS entity_id,
            CASE WHEN "HSA"."HLHSTALT_VacateFlg" THEN 1 ELSE 0 END AS vacate_flag,
            "HSA"."HLHSTALT_VacatedDate" AS vacated_date,
            "HSA"."HLHSTALT_VacateRemarks" AS vacate_remarks,
            "HSA"."HLHSTALT_AllotmentDate" AS allotment_date,
            "HSA"."HLMRCA_Id" AS room_category_id
        FROM "HL_Hostel_Staff_Allot" "HSA"
        INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HSA"."HRME_Id"
        INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
        INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
        INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
        INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id" 
            AND "HSA"."HLMRCA_Id" = "MR"."HLMRCA_Id"
        WHERE "HSA"."MI_Id" = p_MI_Id 
            AND "ME"."HRME_ActiveFlag" = TRUE 
            AND "HSA"."HLHSTALT_VacateFlg" = TRUE;

    ELSIF p_type = 'guest' THEN
        RETURN QUERY
        SELECT 
            "HGA"."HLHGSTALT_GuestName" AS name,
            NULL::TEXT AS field2,
            NULL::TEXT AS field3,
            "MH"."HLMH_Name" AS hostel_name,
            "MR"."HRMRM_RoomNo" AS room_no,
            NULL::TEXT AS identifier,
            "HGA"."HLHGSTALT_Id" AS entity_id,
            1 AS vacate_flag,
            "HGA"."HLHGSTALT_VacatedDate" AS vacated_date,
            "HGA"."HLHGSTALT_VacateRemarks" AS vacate_remarks,
            "HGA"."HLHGSTALT_AllotmentDate" AS allotment_date,
            "HGA"."HLMRCA_Id" AS room_category_id
        FROM "HL_Hostel_Guest_Allot" "HGA"
        INNER JOIN "HL_Master_Hostel" "MH" ON "HGA"."HLMH_Id" = "MH"."HLMH_Id"
        INNER JOIN "HL_Master_Room" "MR" ON "HGA"."HRMRM_Id" = "MR"."HRMRM_Id" 
            AND "HGA"."HLMRCA_Id" = "MR"."HLMRCA_Id"
        WHERE "HGA"."MI_Id" = p_MI_Id 
            AND "HGA"."HLHGSTALT_VacateFlg" = TRUE;

    END IF;

END;
$$;