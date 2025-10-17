CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_VACANT"(
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
    id BIGINT
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
            "HSA"."AMST_Id" AS id
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
        WHERE "HSA"."MI_Id" = p_MI_Id AND "YS"."ASMAY_Id" = p_ASMAY_Id;

    ELSIF p_type = 'staff' THEN
        RETURN QUERY
        SELECT 
            COALESCE("ME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("ME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("ME"."HRME_EmployeeLastName", '') AS name,
            "MD"."HRMD_DepartmentName" AS field2,
            "MDES"."HRMDES_DesignationName" AS field3,
            "MH"."HLMH_Name" AS hostel_name,
            "MR"."HRMRM_RoomNo" AS room_no,
            ''::TEXT AS identifier,
            "HSA"."HRME_Id" AS id
        FROM "HL_Hostel_Staff_Allot" "HSA"
        INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HSA"."HRME_Id"
        INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
        INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
        INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
        INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
        WHERE "HSA"."MI_Id" = p_MI_Id 
            AND "ME"."HRME_ActiveFlag" = 1 
            AND "ME"."HRME_LeftFlag" = 0;

    END IF;

    RETURN;

END;
$$;