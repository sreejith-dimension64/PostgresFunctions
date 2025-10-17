CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_VACATE_REPORT_LIST"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "type" VARCHAR(50),
    "type2" VARCHAR(50),
    "Fromdate" VARCHAR(500),
    "ToDate" VARCHAR(500),
    "HLMH_Id" VARCHAR(500),
    "AMST_Id" VARCHAR(500),
    "HRME_Id" VARCHAR(500),
    "HLHGSTALT_Id" VARCHAR(500)
)
RETURNS TABLE (
    "Id" BIGINT,
    "Name" TEXT,
    "Field1" TEXT,
    "Field2" TEXT,
    "Field3" TEXT,
    "Field4" TEXT,
    "Field5" TIMESTAMP,
    "Field6" TEXT,
    "Field7" TIMESTAMP,
    "Field8" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "content" VARCHAR(500);
    "content1" VARCHAR(500);
    "content2" VARCHAR(500);
BEGIN

    IF "Fromdate" != '' AND "ToDate" != '' THEN
        "content" := ' AND "HLHSALT_VacatedDate"::DATE BETWEEN ''' || "Fromdate" || '''::DATE AND ''' || "ToDate" || '''::DATE';
    ELSE
        "content" := '';
    END IF;

    IF "Fromdate" != '' AND "ToDate" != '' THEN
        "content1" := ' AND "HLHSTALT_VacatedDate"::DATE BETWEEN ''' || "Fromdate" || '''::DATE AND ''' || "ToDate" || '''::DATE';
    ELSE
        "content1" := '';
    END IF;

    IF "Fromdate" != '' AND "ToDate" != '' THEN
        "content2" := ' AND "HLHGSTALT_VacatedDate"::DATE BETWEEN ''' || "Fromdate" || '''::DATE AND ''' || "ToDate" || '''::DATE';
    ELSE
        "content2" := '';
    END IF;

    IF "type" = 'student' THEN
        
        IF "type2" = 'ALL' THEN
            
            RETURN QUERY EXECUTE 
            'SELECT "HSA"."AMST_Id"::BIGINT, 
                    (COALESCE("AMST_FirstName", '''') || '' '' || COALESCE("AMST_MiddleName", '''') || '' '' || COALESCE("AMST_LastName", ''''))::TEXT AS studentname,
                    "MC"."ASMCL_ClassName"::TEXT, 
                    "MS"."ASMC_SectionName"::TEXT, 
                    "MH"."HLMH_Name"::TEXT, 
                    "MR"."HRMRM_RoomNo"::TEXT,
                    "HSA"."HLHSALT_VacatedDate"::TIMESTAMP, 
                    "HSA"."HLHSALT_VacateRemarks"::TEXT, 
                    "HSA"."HLHSALT_AllotmentDate"::TIMESTAMP, 
                    "MH"."HLMH_Id"::BIGINT
             FROM "HL_Hostel_Student_Allot" "HSA" 
             INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = "HSA"."AMST_Id" AND "YS"."ASMAY_Id" = "HSA"."ASMAY_Id" 
                    AND "YS"."ASMCL_Id" = "HSA"."ASMCL_Id" AND "YS"."ASMS_Id" = "HSA"."ASMS_Id"
             INNER JOIN "Adm_M_Student" "AMS" ON "YS"."AMST_Id" = "AMS"."AMST_Id" AND "AMS"."AMST_SOL" = ''S''
             INNER JOIN "Adm_School_M_Class" "MC" ON "YS"."ASMCL_Id" = "MC"."ASMCL_Id"
             INNER JOIN "Adm_School_M_Section" "MS" ON "YS"."ASMS_Id" = "MS"."ASMS_Id"
             INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
             INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
             WHERE "HSA"."MI_Id" = ' || "MI_Id" || ' AND "HSA"."ASMAY_Id" = ' || "ASMAY_Id" || ' AND "HSA"."HLHSALT_VacateFlg" = 1 ' || "content";

        ELSIF "type2" = 'HOSTEL' THEN
            
            RETURN QUERY EXECUTE 
            'SELECT "HSA"."AMST_Id"::BIGINT, 
                    (COALESCE("AMST_FirstName", '''') || '' '' || COALESCE("AMST_MiddleName", '''') || '' '' || COALESCE("AMST_LastName", ''''))::TEXT AS studentname,
                    "MC"."ASMCL_ClassName"::TEXT, 
                    "MS"."ASMC_SectionName"::TEXT, 
                    "MH"."HLMH_Name"::TEXT, 
                    "MR"."HRMRM_RoomNo"::TEXT,
                    "HSA"."HLHSALT_VacatedDate"::TIMESTAMP, 
                    "HSA"."HLHSALT_VacateRemarks"::TEXT, 
                    "HSA"."HLHSALT_AllotmentDate"::TIMESTAMP, 
                    "MH"."HLMH_Id"::BIGINT
             FROM "HL_Hostel_Student_Allot" "HSA" 
             INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = "HSA"."AMST_Id" AND "YS"."ASMAY_Id" = "HSA"."ASMAY_Id" 
                    AND "YS"."ASMCL_Id" = "HSA"."ASMCL_Id" AND "YS"."ASMS_Id" = "HSA"."ASMS_Id"
             INNER JOIN "Adm_M_Student" "AMS" ON "YS"."AMST_Id" = "AMS"."AMST_Id" AND "AMS"."AMST_SOL" = ''S''
             INNER JOIN "Adm_School_M_Class" "MC" ON "YS"."ASMCL_Id" = "MC"."ASMCL_Id"
             INNER JOIN "Adm_School_M_Section" "MS" ON "YS"."ASMS_Id" = "MS"."ASMS_Id"
             INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
             INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id" AND "HSA"."HLMRCA_Id" = "MR"."HLMRCA_Id"
             WHERE "HSA"."MI_Id" = ' || "MI_Id" || ' AND "HSA"."ASMAY_Id" = ' || "ASMAY_Id" || ' AND "HSA"."HLHSALT_VacateFlg" = 1 
                   AND "MH"."HLMH_Id" IN (' || "HLMH_Id" || ') ' || "content";

        ELSIF "type2" = 'individual' THEN
            
            RETURN QUERY EXECUTE 
            'SELECT "HSA"."AMST_Id"::BIGINT, 
                    (COALESCE("AMST_FirstName", '''') || '' '' || COALESCE("AMST_MiddleName", '''') || '' '' || COALESCE("AMST_LastName", ''''))::TEXT AS studentname,
                    "MC"."ASMCL_ClassName"::TEXT, 
                    "MS"."ASMC_SectionName"::TEXT, 
                    "MH"."HLMH_Name"::TEXT, 
                    "MR"."HRMRM_RoomNo"::TEXT,
                    "HSA"."HLHSALT_VacatedDate"::TIMESTAMP, 
                    "HSA"."HLHSALT_VacateRemarks"::TEXT, 
                    "HSA"."HLHSALT_AllotmentDate"::TIMESTAMP, 
                    "MH"."HLMH_Id"::BIGINT
             FROM "HL_Hostel_Student_Allot" "HSA" 
             INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."AMST_Id" = "HSA"."AMST_Id" AND "YS"."ASMAY_Id" = "HSA"."ASMAY_Id" 
                    AND "YS"."ASMCL_Id" = "HSA"."ASMCL_Id" AND "YS"."ASMS_Id" = "HSA"."ASMS_Id"
             INNER JOIN "Adm_M_Student" "AMS" ON "YS"."AMST_Id" = "AMS"."AMST_Id" AND "AMS"."AMST_SOL" = ''S''
             INNER JOIN "Adm_School_M_Class" "MC" ON "YS"."ASMCL_Id" = "MC"."ASMCL_Id"
             INNER JOIN "Adm_School_M_Section" "MS" ON "YS"."ASMS_Id" = "MS"."ASMS_Id"
             INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
             INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id" AND "HSA"."HLMRCA_Id" = "MR"."HLMRCA_Id"
             WHERE "HSA"."MI_Id" = ' || "MI_Id" || ' AND "HSA"."ASMAY_Id" = ' || "ASMAY_Id" || ' AND "HSA"."HLHSALT_VacateFlg" = 1 ' 
                   || "content" || ' AND "HSA"."AMST_Id" IN (' || "AMST_Id" || ')';
        END IF;

    ELSIF "type" = 'staff' THEN

        IF "type2" = 'ALL' THEN
            
            RETURN QUERY EXECUTE 
            'SELECT "HSA"."HRME_Id"::BIGINT,
                    (COALESCE("HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HRME_EmployeeLastName", '' ''))::TEXT AS staffname,
                    "MD"."HRMD_DepartmentName"::TEXT, 
                    "MDES"."HRMDES_DesignationName"::TEXT,
                    "MH"."HLMH_Name"::TEXT, 
                    "MR"."HRMRM_RoomNo"::TEXT,
                    "HSA"."HLHSTALT_VacatedDate"::TIMESTAMP,
                    "HSA"."HLHSTALT_VacateRemarks"::TEXT,
                    "HSA"."HLHSTALT_AllotmentDate"::TIMESTAMP,
                    "HSA"."HLHSTALT_VacateFlg"::BIGINT
             FROM "HL_Hostel_Staff_Allot" "HSA"
             INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HSA"."HRME_Id" 
             INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
             INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
             INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
             INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
             WHERE "HSA"."MI_Id" = ' || "MI_Id" || ' AND "ME"."HRME_ActiveFlag" = 1 AND "HSA"."HLHSTALT_VacateFlg" = 1 ' || "content1";

        ELSIF "type2" = 'HOSTEL' THEN
            
            RETURN QUERY EXECUTE 
            'SELECT "HSA"."HRME_Id"::BIGINT,
                    (COALESCE("HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HRME_EmployeeLastName", '' ''))::TEXT AS staffname,
                    "MD"."HRMD_DepartmentName"::TEXT, 
                    "MDES"."HRMDES_DesignationName"::TEXT,
                    "MH"."HLMH_Name"::TEXT, 
                    "MR"."HRMRM_RoomNo"::TEXT,
                    "HSA"."HLHSTALT_VacatedDate"::TIMESTAMP,
                    "HSA"."HLHSTALT_VacateRemarks"::TEXT,
                    "HSA"."HLHSTALT_AllotmentDate"::TIMESTAMP,
                    "HSA"."HLHSTALT_VacateFlg"::BIGINT
             FROM "HL_Hostel_Staff_Allot" "HSA"
             INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HSA"."HRME_Id" 
             INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
             INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
             INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
             INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
             WHERE "HSA"."MI_Id" = ' || "MI_Id" || ' AND "ME"."HRME_ActiveFlag" = 1 AND "HSA"."HLHSTALT_VacateFlg" = 1 
                   AND "MH"."HLMH_Id" IN (' || "HLMH_Id" || ') ' || "content1";

        ELSIF "type2" = 'individual' THEN
            
            RETURN QUERY EXECUTE 
            'SELECT "HSA"."HRME_Id"::BIGINT,
                    (COALESCE("HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HRME_EmployeeLastName", ''''))::TEXT AS staffname,
                    "MD"."HRMD_DepartmentName"::TEXT, 
                    "MDES"."HRMDES_DesignationName"::TEXT,
                    "MH"."HLMH_Name"::TEXT, 
                    "MR"."HRMRM_RoomNo"::TEXT,
                    "HSA"."HLHSTALT_VacatedDate"::TIMESTAMP,
                    "HSA"."HLHSTALT_VacateRemarks"::TEXT,
                    "HSA"."HLHSTALT_AllotmentDate"::TIMESTAMP,
                    "HSA"."HLHSTALT_VacateFlg"::BIGINT
             FROM "HL_Hostel_Staff_Allot" "HSA"
             INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HSA"."HRME_Id" 
             INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
             INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
             INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
             INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
             WHERE "HSA"."MI_Id" = ' || "MI_Id" || ' AND "ME"."HRME_Id" IN (' || "HRME_Id" || ') 
                   AND "ME"."HRME_ActiveFlag" = 1 AND "HSA"."HLHSTALT_VacateFlg" = 1 ' || "content1";
        END IF;

    ELSIF "type" = 'guest' THEN
        
        IF "type2" = 'ALL' THEN
            
            RETURN QUERY EXECUTE 
            'SELECT "HGA"."HLHGSTALT_Id"::BIGINT,
                    "HGA"."HLHGSTALT_GuestName"::TEXT,
                    "HGA"."HLHGSTALT_GuestAddress"::TEXT,
                    "MH"."HLMH_Name"::TEXT,
                    "MR"."HRMRM_RoomNo"::TEXT,
                    "HGA"."HLHGSTALT_VacateRemarks"::TEXT,
                    "HGA"."HLHGSTALT_VacatedDate"::TIMESTAMP,
                    NULL::TEXT,
                    "HGA"."HLHGSTALT_AllotmentDate"::TIMESTAMP,
                    NULL::BIGINT
             FROM "HL_Hostel_Guest_Allot" "HGA"
             INNER JOIN "HL_Master_Hostel" "MH" ON "HGA"."HLMH_Id" = "MH"."HLMH_Id"
             INNER JOIN "HL_Master_Room" "MR" ON "HGA"."HRMRM_Id" = "MR"."HRMRM_Id"
             WHERE "HGA"."MI_Id" = ' || "MI_Id" || ' AND "HLHGSTALT_VacateFlg" = 1 ' || "content2";

        ELSIF "type2" = 'HOSTEL' THEN
            
            RETURN QUERY EXECUTE 
            'SELECT "HGA"."HLHGSTALT_Id"::BIGINT,
                    "HGA"."HLHGSTALT_GuestName"::TEXT,
                    "HGA"."HLHGSTALT_GuestAddress"::TEXT,
                    "MH"."HLMH_Name"::TEXT,
                    "MR"."HRMRM_RoomNo"::TEXT,
                    "HGA"."HLHGSTALT_VacateRemarks"::TEXT,
                    "HGA"."HLHGSTALT_VacatedDate"::TIMESTAMP,
                    NULL::TEXT,
                    "HGA"."HLHGSTALT_AllotmentDate"::TIMESTAMP,
                    NULL::BIGINT
             FROM "HL_Hostel_Guest_Allot" "HGA"
             INNER JOIN "HL_Master_Hostel" "MH" ON "HGA"."HLMH_Id" = "MH"."HLMH_Id"
             INNER JOIN "HL_Master_Room" "MR" ON "HGA"."HRMRM_Id" = "MR"."HRMRM_Id"
             WHERE "HGA"."MI_Id" = ' || "MI_Id" || ' AND "HLHGSTALT_VacateFlg" = 1 
                   AND "MH"."HLMH_Id" IN (' || "HLMH_Id" || ') ' || "content2";

        ELSIF "type2" = 'individual' THEN
            
            RETURN QUERY EXECUTE 
            'SELECT "HGA"."HLHGSTALT_Id"::BIGINT,
                    "HGA"."HLHGSTALT_GuestName"::TEXT,
                    "HGA"."HLHGSTALT_GuestAddress"::TEXT,
                    "MH"."HLMH_Name"::TEXT,
                    "MR"."HRMRM_RoomNo"::TEXT,
                    "HGA"."HLHGSTALT_VacateRemarks"::TEXT,
                    "HGA"."HLHGSTALT_VacatedDate"::TIMESTAMP,
                    NULL::TEXT,
                    "HGA"."HLHGSTALT_AllotmentDate"::TIMESTAMP,
                    NULL::BIGINT
             FROM "HL_Hostel_Guest_Allot" "HGA"
             INNER JOIN "HL_Master_Hostel" "MH" ON "HGA"."HLMH_Id" = "MH"."HLMH_Id"
             INNER JOIN "HL_Master_Room" "MR" ON "HGA"."HRMRM_Id" = "MR"."HRMRM_Id"
             WHERE "HGA"."MI_Id" = ' || "MI_Id" || ' AND "HGA"."HLHGSTALT_Id" IN (' || "HLHGSTALT_Id" || ') 
                   AND "HLHGSTALT_VacateFlg" = 1 ' || "content2";
        END IF;

    END IF;

    RETURN;

END;
$$;