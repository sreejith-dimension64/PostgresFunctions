CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_STUDENT_ALLOTMENT_REPORT"(
    p_MI_Id bigint,
    p_type varchar(20),
    p_frmdate date,
    p_todate date,
    p_asmay_id varchar,
    p_HLMH_Id varchar
)
RETURNS TABLE (
    "Column1" text,
    "Column2" text,
    "Column3" text,
    "Column4" bigint,
    "Column5" text,
    "Column6" text,
    "Column7" timestamp,
    "Column8" text,
    "Column9" text,
    "Column10" text,
    "Column11" text
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_asmay_id bigint;
BEGIN

    SELECT "ASMAY_Id" INTO v_asmay_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
    AND "MI_Id" = p_MI_Id;

    IF p_type = 'Student' THEN
        RETURN QUERY
        SELECT 
            COALESCE(c."AMST_FirstName", '') || '' || COALESCE(c."AMST_MiddleName", '') || '' || COALESCE(c."AMST_LastName", '') AS "Column1",
            y1."ASMAY_Year"::text AS "Column2",
            c."AMST_AdmNo"::text AS "Column3",
            c."AMST_Id" AS "Column4",
            cls."ASMCL_ClassName"::text AS "Column5",
            ms."ASMC_SectionName"::text AS "Column6",
            a."HLHSALT_AllotmentDate" AS "Column7",
            mh."HLMH_Name"::text AS "Column8",
            MR."HLMRCA_RoomCategory"::text AS "Column9",
            HR."HRMRM_RoomNo"::text AS "Column10",
            a."HLHSALT_AllotRemarks"::text AS "Column11"
        FROM "HL_Hostel_Student_Allot" a
        INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = a."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" y ON y."AMST_Id" = c."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" y1 ON y."asmay_Id" = y1."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" cls ON y."ASMCL_id" = cls."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ms ON y."ASMS_Id" = ms."ASMS_Id"
        INNER JOIN "HL_Master_Hostel" mh ON mh."HLMH_Id" = a."HLMH_Id"
        INNER JOIN "HL_Master_Room" HR ON HR."HRMRM_Id" = a."HRMRM_Id"
        INNER JOIN "HL_Master_Room_Category" MR ON MR."HLMRCA_Id" = a."HLMRCA_Id"
        WHERE a."MI_Id" = p_MI_Id 
        AND a."HLHSALT_ActiveFlag" = 1 
        AND y."ASMAY_Id" = v_asmay_id 
        AND CAST(a."HLHSALT_AllotmentDate" AS date) BETWEEN p_frmdate AND p_todate 
        AND a."HLMH_Id" = p_HLMH_Id::bigint;

    ELSIF p_type = 'Staff' THEN
        RETURN QUERY
        SELECT 
            COALESCE(c."HRME_EmployeeFirstName", '') || '' || COALESCE(c."HRME_EmployeeMiddleName", '') || '' || COALESCE(c."HRME_EmployeeLastName", '') AS "Column1",
            c."HRME_Id"::text AS "Column2",
            y."HRMD_DepartmentName"::text AS "Column3",
            y1."HRMDES_DesignationName"::bigint AS "Column4",
            c."HRME_EmployeeCode"::text AS "Column5",
            mh."HLMH_Name"::text AS "Column6",
            a."HLHSTALT_AllotmentDate" AS "Column7",
            MR."HLMRCA_RoomCategory"::text AS "Column8",
            a."HLHSTALT_AllotRemarks"::text AS "Column9",
            HR."HRMRM_RoomNo"::text AS "Column10",
            NULL::text AS "Column11"
        FROM "HL_Hostel_staff_Allot" a
        INNER JOIN "HR_master_Employee" c ON c."HRME_Id" = a."HRME_Id" AND c."HRME_Leftflag" = 0 AND c."HRME_Activeflag" = 1
        INNER JOIN "HR_Master_Department" y ON c."HRMD_Id" = y."HRMD_Id"
        INNER JOIN "HR_Master_Designation" y1 ON c."HRMDES_Id" = y1."HRMDES_Id"
        INNER JOIN "HL_Master_Hostel" mh ON mh."HLMH_Id" = a."HLMH_Id"
        INNER JOIN "HL_Master_Room" HR ON HR."HRMRM_Id" = a."HRMRM_Id"
        INNER JOIN "HL_Master_Room_Category" MR ON MR."HLMRCA_Id" = a."HLMRCA_Id"
        WHERE c."MI_Id" = p_MI_Id 
        AND a."HLHSTALT_ActiveFlag" = 1 
        AND CAST(a."HLHSTALT_AllotmentDate" AS date) BETWEEN p_frmdate AND p_todate;

    ELSIF p_type = 'Guest' THEN
        RETURN QUERY
        SELECT 
            a."HLHGSTALT_GuestName"::text AS "Column1",
            mh."HLMH_Name"::text AS "Column2",
            MR."HLMRCA_RoomCategory"::text AS "Column3",
            NULL::bigint AS "Column4",
            NULL::text AS "Column5",
            NULL::text AS "Column6",
            a."HLHGSTALT_AllotmentDate" AS "Column7",
            HR."HRMRM_RoomNo"::text AS "Column8",
            a."HLHGSTALT_GuestPhoneNo"::text AS "Column9",
            a."HLHGSTALT_GuestEmailId"::text AS "Column10",
            (a."HLHGSTALT_GuestAddress"::text || ' ' || a."HLHGSTALT_AllotRemarks"::text) AS "Column11"
        FROM "HL_Hostel_Guest_Allot" a
        INNER JOIN "HL_Master_Room" HR ON HR."HRMRM_Id" = a."HRMRM_Id"
        INNER JOIN "HL_Master_Hostel" mh ON mh."HLMH_Id" = a."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" MR ON MR."HLMRCA_Id" = a."HLMRCA_Id"
        WHERE a."MI_Id" = p_MI_Id 
        AND a."HLHGSTALT_ActiveFlag" = 1 
        AND CAST(a."HLHGSTALT_AllotmentDate" AS date) BETWEEN p_frmdate AND p_todate;

    END IF;

    RETURN;

END;
$$;