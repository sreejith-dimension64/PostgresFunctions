CREATE OR REPLACE FUNCTION "dbo"."CLG_HOSTEL_VACATE_REPORT_LIST"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "type" VARCHAR(50),
    "type2" VARCHAR(50),
    "Fromdate" VARCHAR(500),
    "ToDate" VARCHAR(500),
    "HLMH_Id" VARCHAR(500),
    "AMCST_Id" TEXT,
    "HRME_Id" VARCHAR(500),
    "HLHGSTALT_Id" VARCHAR(500)
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "HRME_Id" BIGINT,
    "HLHGSTALT_Id" BIGINT,
    "studentname" TEXT,
    "staffname" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "ACMS_SectionName" TEXT,
    "HLMH_Name" TEXT,
    "HRMRM_RoomNo" TEXT,
    "HLHSALTC_VacatedDate" TIMESTAMP,
    "HLHSTALT_VacatedDate" TIMESTAMP,
    "HLHGSTALT_VacatedDate" TIMESTAMP,
    "HLHSALTC_VacateRemarks" TEXT,
    "HLHSTALT_VacateRemarks" TEXT,
    "HLHGSTALT_VacateRemarks" TEXT,
    "HLHSALTC_AllotmentDate" TIMESTAMP,
    "HLHSTALT_AllotmentDate" TIMESTAMP,
    "HLHGSTALT_AllotmentDate" TIMESTAMP,
    "HLMH_Id" BIGINT,
    "HLHSTALT_VacateFlg" BOOLEAN,
    "HRMD_DepartmentName" TEXT,
    "HRMDES_DesignationName" TEXT,
    "HLHGSTALT_GuestName" TEXT,
    "HLHGSTALT_GuestAddress" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
    v_content TEXT;
    v_content1 TEXT;
    v_content2 TEXT;
BEGIN

    IF "Fromdate" != '' AND "ToDate" != '' THEN
        v_content := ' and "HSAC"."HLHSALTC_VacatedDate"::date between ''' || "Fromdate" || '''::date and ''' || "ToDate" || '''::date';
    ELSE
        v_content := '';
    END IF;

    IF "Fromdate" != '' AND "ToDate" != '' THEN
        v_content1 := ' and "HSA"."HLHSTALT_VacatedDate"::date between ''' || "Fromdate" || '''::date and ''' || "ToDate" || '''::date';
    ELSE
        v_content1 := '';
    END IF;

    IF "Fromdate" != '' AND "ToDate" != '' THEN
        v_content2 := ' and "HGA"."HLHGSTALT_VacatedDate"::date between ''' || "Fromdate" || '''::date and ''' || "ToDate" || '''::date';
    ELSE
        v_content2 := '';
    END IF;

    IF "type" = 'student' THEN

        IF "type2" = 'ALL' THEN

            v_query := '
            SELECT "HSAC"."AMCST_Id", NULL::BIGINT as "HRME_Id", NULL::BIGINT as "HLHGSTALT_Id",
            COALESCE("AMS"."AMCST_FirstName",'''') || '' '' || COALESCE("AMS"."AMCST_MiddleName",'''') || '' '' || COALESCE("AMS"."AMCST_LastName",'''') as studentname,
            NULL::TEXT as staffname,
            "MC"."AMCO_CourseName", "MB"."AMB_BranchName", "AMSE"."AMSE_SEMName", "MS"."ACMS_SectionName",
            "MH"."HLMH_Name", "MR"."HRMRM_RoomNo",
            "HSAC"."HLHSALTC_VacatedDate", NULL::TIMESTAMP as "HLHSTALT_VacatedDate", NULL::TIMESTAMP as "HLHGSTALT_VacatedDate",
            "HSAC"."HLHSALTC_VacateRemarks", NULL::TEXT as "HLHSTALT_VacateRemarks", NULL::TEXT as "HLHGSTALT_VacateRemarks",
            "HSAC"."HLHSALTC_AllotmentDate", NULL::TIMESTAMP as "HLHSTALT_AllotmentDate", NULL::TIMESTAMP as "HLHGSTALT_AllotmentDate",
            "MH"."HLMH_Id", NULL::BOOLEAN as "HLHSTALT_VacateFlg",
            NULL::TEXT as "HRMD_DepartmentName", NULL::TEXT as "HRMDES_DesignationName",
            NULL::TEXT as "HLHGSTALT_GuestName", NULL::TEXT as "HLHGSTALT_GuestAddress"
            FROM "HL_Hostel_Student_Allot_college" "HSAC"
            INNER JOIN "CLG"."Adm_College_Yearly_Student" "YS" ON "YS"."AMCST_Id" = "HSAC"."AMCST_Id" 
                AND "YS"."ASMAY_Id" = "HSAC"."ASMAY_Id" AND "YS"."AMCO_Id" = "HSAC"."AMCO_Id" 
                AND "YS"."AMB_Id" = "HSAC"."AMB_Id" AND "YS"."AMSE_Id" = "HSAC"."AMSE_Id" 
                AND "YS"."ACMS_Id" = "HSAC"."ACMS_Id"
            INNER JOIN "CLG"."Adm_Master_College_Student" "AMS" ON "YS"."AMCST_Id" = "AMS"."AMCST_Id" 
                AND "AMS"."AMCST_SOL" = ''S''
            INNER JOIN "clg"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
            INNER JOIN "clg"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
            INNER JOIN "clg"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
            INNER JOIN "HL_Master_Hostel" "MH" ON "HSAC"."HLMH_Id" = "MH"."HLMH_Id"
            INNER JOIN "HL_Master_Room" "MR" ON "HSAC"."HRMRM_Id" = "MR"."HRMRM_Id"
            WHERE "HSAC"."MI_Id" = ' || "MI_Id"::TEXT || ' AND "HSAC"."ASMAY_Id" = ' || "ASMAY_Id"::TEXT || 
            ' AND "HSAC"."HLHSALTC_VacateFlg" = true ' || v_content;

        ELSIF "type2" = 'HOSTEL' THEN

            v_query := '
            SELECT "HSAC"."AMCST_Id", NULL::BIGINT as "HRME_Id", NULL::BIGINT as "HLHGSTALT_Id",
            COALESCE("AMS"."AMCST_FirstName",'''') || '' '' || COALESCE("AMS"."AMCST_MiddleName",'''') || '' '' || COALESCE("AMS"."AMCST_LastName",'''') as studentname,
            NULL::TEXT as staffname,
            "MC"."AMCO_CourseName", "MB"."AMB_BranchName", "AMSE"."AMSE_SEMName", "MS"."ACMS_SectionName",
            "MH"."HLMH_Name", "MR"."HRMRM_RoomNo",
            "HSAC"."HLHSALTC_VacatedDate", NULL::TIMESTAMP as "HLHSTALT_VacatedDate", NULL::TIMESTAMP as "HLHGSTALT_VacatedDate",
            "HSAC"."HLHSALTC_VacateRemarks", NULL::TEXT as "HLHSTALT_VacateRemarks", NULL::TEXT as "HLHGSTALT_VacateRemarks",
            "HSAC"."HLHSALTC_AllotmentDate", NULL::TIMESTAMP as "HLHSTALT_AllotmentDate", NULL::TIMESTAMP as "HLHGSTALT_AllotmentDate",
            "MH"."HLMH_Id", NULL::BOOLEAN as "HLHSTALT_VacateFlg",
            NULL::TEXT as "HRMD_DepartmentName", NULL::TEXT as "HRMDES_DesignationName",
            NULL::TEXT as "HLHGSTALT_GuestName", NULL::TEXT as "HLHGSTALT_GuestAddress"
            FROM "HL_Hostel_Student_Allot_College" "HSAC"
            INNER JOIN "CLG"."Adm_College_Yearly_Student" "YS" ON "YS"."AMCST_Id" = "HSAC"."AMCST_Id" 
                AND "YS"."ASMAY_Id" = "HSAC"."ASMAY_Id" AND "YS"."AMCO_Id" = "HSAC"."AMCO_Id" 
                AND "YS"."AMB_Id" = "HSAC"."AMB_Id" AND "YS"."AMSE_Id" = "HSAC"."AMSE_Id" 
                AND "YS"."ACMS_Id" = "HSAC"."ACMS_Id"
            INNER JOIN "CLG"."Adm_Master_College_Student" "AMS" ON "YS"."AMCST_Id" = "AMS"."AMCST_Id" 
                AND "AMS"."AMCST_SOL" = ''S''
            INNER JOIN "clg"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
            INNER JOIN "clg"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
            INNER JOIN "clg"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
            INNER JOIN "HL_Master_Hostel" "MH" ON "HSAC"."HLMH_Id" = "MH"."HLMH_Id"
            INNER JOIN "HL_Master_Room" "MR" ON "HSAC"."HRMRM_Id" = "MR"."HRMRM_Id" 
                AND "HSAC"."HLMRCA_Id" = "MR"."HLMRCA_Id"
            WHERE "HSAC"."MI_Id" = ' || "MI_Id"::TEXT || ' AND "HSAC"."ASMAY_Id" = ' || "ASMAY_Id"::TEXT || 
            ' AND "HSAC"."HLHSALTC_VacateFlg" = true AND "MH"."HLMH_Id" IN (' || "HLMH_Id" || ') ' || v_content;

        ELSIF "type2" = 'individual' THEN

            v_query := '
            SELECT "HSAC"."AMCST_Id", NULL::BIGINT as "HRME_Id", NULL::BIGINT as "HLHGSTALT_Id",
            COALESCE("AMS"."AMCST_FirstName",'''') || '' '' || COALESCE("AMS"."AMCST_MiddleName",'''') || '' '' || COALESCE("AMS"."AMCST_LastName",'''') as studentname,
            NULL::TEXT as staffname,
            "MC"."AMCO_CourseName", "MB"."AMB_BranchName", "AMSE"."AMSE_SEMName", "MS"."ACMS_SectionName",
            "MH"."HLMH_Name", "MR"."HRMRM_RoomNo",
            "HSAC"."HLHSALTC_VacatedDate", NULL::TIMESTAMP as "HLHSTALT_VacatedDate", NULL::TIMESTAMP as "HLHGSTALT_VacatedDate",
            "HSAC"."HLHSALTC_VacateRemarks", NULL::TEXT as "HLHSTALT_VacateRemarks", NULL::TEXT as "HLHGSTALT_VacateRemarks",
            "HSAC"."HLHSALTC_AllotmentDate", NULL::TIMESTAMP as "HLHSTALT_AllotmentDate", NULL::TIMESTAMP as "HLHGSTALT_AllotmentDate",
            "MH"."HLMH_Id", NULL::BOOLEAN as "HLHSTALT_VacateFlg",
            NULL::TEXT as "HRMD_DepartmentName", NULL::TEXT as "HRMDES_DesignationName",
            NULL::TEXT as "HLHGSTALT_GuestName", NULL::TEXT as "HLHGSTALT_GuestAddress"
            FROM "HL_Hostel_Student_Allot_College" "HSAC"
            INNER JOIN "CLG"."Adm_College_Yearly_Student" "YS" ON "YS"."AMCST_Id" = "HSAC"."AMCST_Id" 
                AND "YS"."ASMAY_Id" = "HSAC"."ASMAY_Id" AND "YS"."AMCO_Id" = "HSAC"."AMCO_Id" 
                AND "YS"."AMB_Id" = "HSAC"."AMB_Id" AND "YS"."AMSE_Id" = "HSAC"."AMSE_Id" 
                AND "YS"."ACMS_Id" = "HSAC"."ACMS_Id"
            INNER JOIN "CLG"."Adm_Master_College_Student" "AMS" ON "YS"."AMCST_Id" = "AMS"."AMCST_Id" 
                AND "AMS"."AMCST_SOL" = ''S''
            INNER JOIN "clg"."Adm_Master_Course" "MC" ON "YS"."AMCO_Id" = "MC"."AMCO_Id"
            INNER JOIN "clg"."Adm_Master_Branch" "MB" ON "MB"."AMB_Id" = "YS"."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" "AMSE" ON "AMSE"."AMSE_Id" = "YS"."AMSE_Id"
            INNER JOIN "clg"."Adm_College_Master_Section" "MS" ON "YS"."ACMS_Id" = "MS"."ACMS_Id"
            INNER JOIN "HL_Master_Hostel" "MH" ON "HSAC"."HLMH_Id" = "MH"."HLMH_Id"
            INNER JOIN "HL_Master_Room" "MR" ON "HSAC"."HRMRM_Id" = "MR"."HRMRM_Id" 
                AND "HSAC"."HLMRCA_Id" = "MR"."HLMRCA_Id"
            WHERE "HSAC"."MI_Id" = ' || "MI_Id"::TEXT || ' AND "HSAC"."ASMAY_Id" = ' || "ASMAY_Id"::TEXT || 
            ' AND "HSAC"."HLHSALTC_VacateFlg" = true ' || v_content || ' AND "HSAC"."AMCST_Id" IN (' || "AMCST_Id" || ')';

        END IF;

        RETURN QUERY EXECUTE v_query;

    ELSIF "type" = 'staff' THEN

        IF "type2" = 'ALL' THEN

            v_query := '
            SELECT NULL::BIGINT as "AMCST_Id", "HSA"."HRME_Id", NULL::BIGINT as "HLHGSTALT_Id",
            NULL::TEXT as studentname,
            COALESCE("ME"."HRME_EmployeeFirstName",'''') || '' '' || COALESCE("ME"."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE("ME"."HRME_EmployeeLastName",'' '') as staffname,
            NULL::TEXT as "AMCO_CourseName", NULL::TEXT as "AMB_BranchName", NULL::TEXT as "AMSE_SEMName", NULL::TEXT as "ACMS_SectionName",
            "MH"."HLMH_Name", "MR"."HRMRM_RoomNo",
            NULL::TIMESTAMP as "HLHSALTC_VacatedDate", "HSA"."HLHSTALT_VacatedDate", NULL::TIMESTAMP as "HLHGSTALT_VacatedDate",
            NULL::TEXT as "HLHSALTC_VacateRemarks", "HSA"."HLHSTALT_VacateRemarks", NULL::TEXT as "HLHGSTALT_VacateRemarks",
            NULL::TIMESTAMP as "HLHSALTC_AllotmentDate", "HSA"."HLHSTALT_AllotmentDate", NULL::TIMESTAMP as "HLHGSTALT_AllotmentDate",
            "MH"."HLMH_Id", "HSA"."HLHSTALT_VacateFlg",
            "MD"."HRMD_DepartmentName", "MDES"."HRMDES_DesignationName",
            NULL::TEXT as "HLHGSTALT_GuestName", NULL::TEXT as "HLHGSTALT_GuestAddress"
            FROM "HL_Hostel_Staff_Allot" "HSA"
            INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HSA"."HRME_Id"
            INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
            INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
            INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
            INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
            WHERE "HSA"."MI_Id" = ' || "MI_Id"::TEXT || ' AND "ME"."HRME_ActiveFlag" = true 
                AND "HSA"."HLHSTALT_VacateFlg" = true ' || v_content1;

        ELSIF "type2" = 'HOSTEL' THEN

            v_query := '
            SELECT NULL::BIGINT as "AMCST_Id", "HSA"."HRME_Id", NULL::BIGINT as "HLHGSTALT_Id",
            NULL::TEXT as studentname,
            COALESCE("ME"."HRME_EmployeeFirstName",'''') || '' '' || COALESCE("ME"."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE("ME"."HRME_EmployeeLastName",'' '') as staffname,
            NULL::TEXT as "AMCO_CourseName", NULL::TEXT as "AMB_BranchName", NULL::TEXT as "AMSE_SEMName", NULL::TEXT as "ACMS_SectionName",
            "MH"."HLMH_Name", "MR"."HRMRM_RoomNo",
            NULL::TIMESTAMP as "HLHSALTC_VacatedDate", "HSA"."HLHSTALT_VacatedDate", NULL::TIMESTAMP as "HLHGSTALT_VacatedDate",
            NULL::TEXT as "HLHSALTC_VacateRemarks", "HSA"."HLHSTALT_VacateRemarks", NULL::TEXT as "HLHGSTALT_VacateRemarks",
            NULL::TIMESTAMP as "HLHSALTC_AllotmentDate", "HSA"."HLHSTALT_AllotmentDate", NULL::TIMESTAMP as "HLHGSTALT_AllotmentDate",
            "MH"."HLMH_Id", "HSA"."HLHSTALT_VacateFlg",
            "MD"."HRMD_DepartmentName", "MDES"."HRMDES_DesignationName",
            NULL::TEXT as "HLHGSTALT_GuestName", NULL::TEXT as "HLHGSTALT_GuestAddress"
            FROM "HL_Hostel_Staff_Allot" "HSA"
            INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HSA"."HRME_Id"
            INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
            INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
            INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
            INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
            WHERE "HSA"."MI_Id" = ' || "MI_Id"::TEXT || ' AND "ME"."HRME_ActiveFlag" = true 
                AND "HSA"."HLHSTALT_VacateFlg" = true AND "MH"."HLMH_Id" IN (' || "HLMH_Id" || ') ' || v_content1;

        ELSIF "type2" = 'individual' THEN

            v_query := '
            SELECT NULL::BIGINT as "AMCST_Id", "HSA"."HRME_Id", NULL::BIGINT as "HLHGSTALT_Id",
            NULL::TEXT as studentname,
            COALESCE("ME"."HRME_EmployeeFirstName",'''') || '' '' || COALESCE("ME"."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE("ME"."HRME_EmployeeLastName",'''') as staffname,
            NULL::TEXT as "AMCO_CourseName", NULL::TEXT as "AMB_BranchName", NULL::TEXT as "AMSE_SEMName", NULL::TEXT as "ACMS_SectionName",
            "MH"."HLMH_Name", "MR"."HRMRM_RoomNo",
            NULL::TIMESTAMP as "HLHSALTC_VacatedDate", "HSA"."HLHSTALT_VacatedDate", NULL::TIMESTAMP as "HLHGSTALT_VacatedDate",
            NULL::TEXT as "HLHSALTC_VacateRemarks", "HSA"."HLHSTALT_VacateRemarks", NULL::TEXT as "HLHGSTALT_VacateRemarks",
            NULL::TIMESTAMP as "HLHSALTC_AllotmentDate", "HSA"."HLHSTALT_AllotmentDate", NULL::TIMESTAMP as "HLHGSTALT_AllotmentDate",
            "MH"."HLMH_Id", "HSA"."HLHSTALT_VacateFlg",
            "MD"."HRMD_DepartmentName", "MDES"."HRMDES_DesignationName",
            NULL::TEXT as "HLHGSTALT_GuestName", NULL::TEXT as "HLHGSTALT_GuestAddress"
            FROM "HL_Hostel_Staff_Allot" "HSA"
            INNER JOIN "HR_Master_Employee" "ME" ON "ME"."HRME_Id" = "HSA"."HRME_Id"
            INNER JOIN "HR_Master_Department" "MD" ON "ME"."HRMD_Id" = "MD"."HRMD_Id"
            INNER JOIN "HR_Master_Designation" "MDES" ON "ME"."HRMDES_Id" = "MDES"."HRMDES_Id"
            INNER JOIN "HL_Master_Hostel" "MH" ON "HSA"."HLMH_Id" = "MH"."HLMH_Id"
            INNER JOIN "HL_Master_Room" "MR" ON "HSA"."HRMRM_Id" = "MR"."HRMRM_Id"
            WHERE "HSA"."MI_Id" = ' || "MI_Id"::TEXT || ' AND "ME"."HRME_Id" IN (' || "HRME_Id" || ') 
                AND "ME"."HRME_ActiveFlag" = true AND "HSA"."HLHSTALT_VacateFlg" = true ' || v_content1;

        END IF;

        RETURN QUERY EXECUTE v_query;

    ELSIF "type" = 'guest' THEN

        IF "type2" = 'ALL' THEN

            v_query := '
            SELECT NULL::BIGINT as "AMCST_Id", NULL::BIGINT as "HRME_Id", "HGA"."HLHGSTALT_Id",
            NULL::TEXT as studentname, NULL::TEXT as staffname,
            NULL::TEXT as "AMCO_CourseName", NULL::TEXT as "AMB_BranchName", NULL::TEXT as "AMSE_SEMName", NULL::TEXT as "ACMS_SectionName",
            "MH"."HLMH_Name", "MR"."HRMRM_RoomNo",
            NULL::TIMESTAMP as "HLHSALTC_VacatedDate", NULL::TIMESTAMP as "HLHSTALT_VacatedDate", "HGA"."HLHGSTALT_VacatedDate",
            NULL::TEXT as "HLHSALTC_VacateRemarks", NULL::TEXT as "HLHSTALT_VacateRemarks", "HGA"."HLHGSTALT_VacateRemarks",
            NULL::TIMESTAMP as "HLHSALTC_AllotmentDate", NULL::TIMESTAMP as "HLHSTALT_AllotmentDate", "HGA"."HLHGSTALT_AllotmentDate",
            "MH"."HLMH_Id", NULL::BOOLEAN as "HLHSTALT_VacateFlg",
            NULL::TEXT as "HRMD_DepartmentName", NULL::TEXT as "HRMDES_DesignationName",
            "HGA"."HLHGSTALT_GuestName", "HGA"."HLHGSTALT_GuestAddress"
            FROM "HL_Hostel_Guest_Allot" "HGA"
            INNER JOIN "HL_Master_Hostel" "MH" ON "HGA"."HLMH_Id" = "MH"."HLMH_Id"
            INNER JOIN "HL_Master_Room" "MR" ON "HGA"."HRMRM_Id" = "MR"."HRMRM_Id"
            WHERE "HGA"."MI_Id" = ' || "MI_Id"::TEXT || ' AND "HGA"."HLHGSTALT_VacateFlg" = true ' || v_content2;

        ELSIF "type2" = 'HOSTEL' THEN

            v_query := '
            SELECT NULL::BIGINT as "AMCST_Id", NULL::BIGINT as "HRME_Id", "HGA"."HLHGSTALT_Id",
            NULL::TEXT as studentname, NULL::TEXT as staffname,
            NULL::TEXT as "AMCO_CourseName", NULL::TEXT as "AMB_BranchName", NULL::TEXT as "AMSE_SEMName", NULL::TEXT as "ACMS_SectionName",
            "MH"."HLMH_Name", "MR"."HRMRM_RoomNo",
            NULL::TIMESTAMP as "HLHSALTC_VacatedDate", NULL::TIMESTAMP as "HLHSTALT_VacatedDate", "HGA"."HLHGSTALT_VacatedDate",
            NULL::TEXT as "HLHSALTC_VacateRemarks", NULL::TEXT as "HLHSTALT_VacateRemarks", "HGA"."HLHGSTALT_VacateRemarks",
            NULL::TIMESTAMP as "HLHSALTC_AllotmentDate", NULL::TIMESTAMP as "HLHSTALT_AllotmentDate", "HGA"."HLHGSTALT_AllotmentDate",
            "MH"."HLMH_Id", NULL::BOOLEAN as "HLHSTALT_VacateFlg",
            NULL::TEXT as "HRMD_DepartmentName", NULL::TEXT as "HRMDES_DesignationName",
            "HGA"."HLHGSTALT_GuestName", "HGA"."HLHGSTALT_GuestAddress"
            FROM "HL_Hostel_Guest_Allot" "HGA"
            INNER JOIN "HL_Master_Hostel" "MH" ON "HGA"."HLMH_Id" = "MH"."HLMH_Id"
            INNER JOIN "HL_Master_Room" "MR" ON "HGA"."HRMRM_Id" = "MR"."HRMRM_Id"
            WHERE "HGA"."MI_Id" = ' || "MI_Id"::TEXT || ' AND "HGA"."HLHGSTALT_VacateFlg" = true 
                AND "MH"."HLMH_Id" IN (' || "HLMH_Id" || ') ' || v_content2;

        ELSIF "type2" = 'individual' THEN

            v_query := '
            SELECT NULL::BIGINT as "AMCST_Id", NULL::BIGINT as "HRME_Id", "HGA"."HLHGSTALT_Id",
            NULL::TEXT as studentname, NULL::TEXT as staffname,
            NULL::TEXT as "AM