CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_VACANT_GRID_LIST"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_type VARCHAR(50)
)
RETURNS SETOF REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    result_cursor REFCURSOR := 'result_cursor';
BEGIN

    IF p_type = 'student' THEN
        OPEN result_cursor FOR
        SELECT 
            COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '') as studentname,
            "MC"."ASMCL_ClassName",
            "MS"."ASMC_SectionName",
            "MH"."HLMH_Name",
            "MR"."HRMRM_RoomNo",
            "AMS"."AMST_AdmNo",
            "HSA"."AMST_Id",
            "HSA"."HLHSALT_VacateFlg",
            "HSA"."HLHSALT_VacatedDate",
            "HSA"."HLHSALT_VacateRemarks",
            "HSA"."HLHSALT_AllotmentDate"
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
        WHERE "HSA"."MI_Id" = p_MI_Id 
            AND "YS"."ASMAY_Id" = p_ASMAY_Id 
            AND "HSA"."HLHSALT_VacateFlg" = 1;

        RETURN NEXT result_cursor;

    ELSIF p_type = 'staff' THEN
        OPEN result_cursor FOR
        SELECT 
            COALESCE("ME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("ME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("ME"."HRME_EmployeeLastName", '') as staffname,
            "MD"."HRMD_DepartmentName",
            "MDES"."HRMDES_DesignationName",
            "MH"."HLMH_Name",
            "MR"."HRMRM_RoomNo",
            "HSA"."HRME_Id",
            "HSA"."HLHSTALT_VacateFlg",
            "HSA"."HLHSTALT_VacatedDate",
            "HSA"."HLHSTALT_VacateRemarks",
            "HSA"."HLHSTALT_AllotmentDate"
        FROM "HL_Hostel_Staff_Allot" "HSA"
        INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HSA"."HRME_Id"
        INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
        INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
        INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
        INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
        WHERE "HSA"."MI_Id" = p_MI_Id 
            AND "ME"."HRME_ActiveFlag" = 1 
            AND "HSA"."HLHSTALT_VacateFlg" = 1;

        RETURN NEXT result_cursor;

    ELSIF p_type = 'guest' THEN
        OPEN result_cursor FOR
        SELECT 
            "HGA"."HLHGSTALT_GuestName",
            "MH"."HLMH_Name",
            "MR"."HRMRM_RoomNo",
            "HGA"."HLHGSTALT_VacateRemarks",
            "HGA"."HLHGSTALT_Id",
            "HGA"."HLHGSTALT_AllotmentDate",
            "HGA"."HLHGSTALT_VacatedDate"
        FROM "HL_Hostel_Guest_Allot" "HGA"
        INNER JOIN "HL_Master_Hostel" "MH" ON "HGA"."HLMH_Id" = "MH"."HLMH_Id"
        INNER JOIN "HL_Master_Room" "MR" ON "HGA"."HRMRM_Id" = "MR"."HRMRM_Id"
        WHERE "HGA"."MI_Id" = p_MI_Id 
            AND "HGA"."HLHGSTALT_VacateFlg" = 1;

        RETURN NEXT result_cursor;

    END IF;

    RETURN;

END;
$$;