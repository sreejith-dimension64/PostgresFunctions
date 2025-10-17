CREATE OR REPLACE FUNCTION "dbo"."CLG_BirthdayList" (
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "typeflag" varchar(10)
)
RETURNS TABLE (
    "AMCST_Id" bigint,
    "studentname" text,
    "AMCST_AdmNo" varchar,
    "AMCO_CourseName" varchar,
    "AMB_BranchName" varchar,
    "AMSE_SEMName" varchar,
    "AMCST_MobileNo" varchar,
    "AMCST_emailId" varchar,
    "AMCST_DOB" timestamp,
    "ASMAY_Year" varchar,
    "HRME_Id" bigint,
    "HRME_EmailId" varchar,
    "HRME_MobileNo" varchar,
    "employeename" text,
    "HRME_EmployeeCode" varchar,
    "HRME_DOB" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "typeflag" = 'Student' THEN
        RETURN QUERY
        SELECT DISTINCT 
            AMCS."AMCST_Id",
            (CASE WHEN AMCS."AMCST_FirstName" is null or AMCS."AMCST_FirstName" = '' then '' else AMCS."AMCST_FirstName" end ||
             CASE WHEN AMCS."AMCST_MiddleName" is null or AMCS."AMCST_MiddleName" = '' or AMCS."AMCST_MiddleName" = '0' then '' ELSE ' ' || AMCS."AMCST_MiddleName" END ||
             CASE WHEN AMCS."AMCST_LastName" is null or AMCS."AMCST_LastName" = '' or AMCS."AMCST_LastName" = '0' then '' ELSE ' ' || AMCS."AMCST_LastName" END)::text as "studentname",
            AMCS."AMCST_AdmNo"::varchar,
            AMCO."AMCO_CourseName"::varchar,
            AMB."AMB_BranchName"::varchar,
            AMSE."AMSE_SEMName"::varchar,
            AMCS."AMCST_MobileNo"::varchar,
            AMCS."AMCST_emailId"::varchar,
            AMCS."AMCST_DOB",
            NULL::varchar as "ASMAY_Year",
            NULL::bigint as "HRME_Id",
            NULL::varchar as "HRME_EmailId",
            NULL::varchar as "HRME_MobileNo",
            NULL::text as "employeename",
            NULL::varchar as "HRME_EmployeeCode",
            NULL::timestamp as "HRME_DOB"
        FROM "CLG"."Adm_Master_College_Student" AMCS
        INNER JOIN "CLG"."Adm_College_Yearly_Student" ACYS ON AMCS."AMCST_Id" = ACYS."AMCST_Id" 
            AND AMCS."AMCST_SOL" = 'S' 
            AND AMCS."AMCST_ActiveFlag" = 1 
            AND ACYS."ACYST_ActiveFlag" = 1 
            AND AMCS."MI_Id" = "MI_Id"
        INNER JOIN "CLG"."Adm_Master_Course" AMCO ON AMCO."MI_Id" = "MI_Id" AND AMCO."AMCO_Id" = ACYS."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AMB ON AMB."MI_Id" = "MI_Id" AND AMB."AMB_Id" = ACYS."AMB_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ASMAY ON ASMAY."ASMAY_Id" = ACYS."ASMAY_Id" AND ASMAY."MI_Id" = "MI_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."MI_Id" = "MI_Id" and AMSE."AMSE_Id" = ACYS."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" ACMS ON ACMS."ACMS_Id" = ACYS."ACMS_Id" and ACMS."MI_Id" = "MI_Id"
        WHERE AMCS."MI_Id" = "MI_Id" 
            AND ACYS."ASMAY_Id" = "ASMAY_Id"
            AND (EXTRACT(DAY FROM AMCS."AMCST_DOB") = EXTRACT(DAY FROM CURRENT_TIMESTAMP) 
                 AND EXTRACT(MONTH FROM AMCS."AMCST_DOB") = EXTRACT(MONTH FROM CURRENT_TIMESTAMP));

    ELSIF "typeflag" = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::bigint as "AMCST_Id",
            NULL::text as "studentname",
            NULL::varchar as "AMCST_AdmNo",
            NULL::varchar as "AMCO_CourseName",
            NULL::varchar as "AMB_BranchName",
            NULL::varchar as "AMSE_SEMName",
            NULL::varchar as "AMCST_MobileNo",
            NULL::varchar as "AMCST_emailId",
            NULL::timestamp as "AMCST_DOB",
            NULL::varchar as "ASMAY_Year",
            E."HRME_Id",
            (SELECT EM."HRMEM_EmailId" FROM "HR_Master_Employee_EmailId" EM WHERE EM."HRME_Id" = E."HRME_Id" LIMIT 1)::varchar AS "HRME_EmailId",
            (SELECT MN."HRMEMNO_MobileNo" FROM "HR_Master_Employee_MobileNo" MN WHERE MN."HRME_Id" = E."HRME_Id" LIMIT 1)::varchar AS "HRME_MobileNo",
            (CASE WHEN E."HRME_EmployeeFirstName" is null or E."HRME_EmployeeFirstName" = '' then '' else E."HRME_EmployeeFirstName" end ||
             CASE WHEN E."HRME_EmployeeMiddleName" is null or E."HRME_EmployeeMiddleName" = '' or E."HRME_EmployeeMiddleName" = '0' then '' ELSE ' ' || E."HRME_EmployeeMiddleName" END ||
             CASE WHEN E."HRME_EmployeeLastName" is null or E."HRME_EmployeeLastName" = '' or E."HRME_EmployeeLastName" = '0' then '' ELSE ' ' || E."HRME_EmployeeLastName" END)::text as "employeename",
            E."HRME_EmployeeCode"::varchar,
            E."HRME_DOB"
        FROM "HR_Master_Employee" E
        WHERE E."MI_Id" = "MI_Id" 
            AND E."HRME_ActiveFlag" = 1 
            AND E."HRME_LeftFlag" = 0 
            AND (EXTRACT(DAY FROM E."HRME_DOB") = EXTRACT(DAY FROM CURRENT_TIMESTAMP) 
                 AND EXTRACT(MONTH FROM E."HRME_DOB") = EXTRACT(MONTH FROM CURRENT_TIMESTAMP));

    ELSIF "typeflag" = 'Alumni' THEN
        RETURN QUERY
        SELECT DISTINCT 
            AMCS."AlCMST_Id" as "AMCST_Id",
            (CASE WHEN AMCS."AlCMST_FirstName" is null or AMCS."AlCMST_FirstName" = '' then '' else AMCS."AlCMST_FirstName" end ||
             CASE WHEN AMCS."AlCMST_MiddleName" is null or AMCS."AlCMST_MiddleName" = '' or AMCS."AlCMST_MiddleName" = '0' then '' ELSE ' ' || AMCS."AlCMST_MiddleName" END ||
             CASE WHEN AMCS."AlCMST_LastName" is null or AMCS."AlCMST_LastName" = '' or AMCS."AlCMST_LastName" = '0' then '' ELSE ' ' || AMCS."AlCMST_LastName" END)::text as "studentname",
            AMCS."AlCMST_AdmNo"::varchar as "AMCST_AdmNo",
            AMCO."AMCO_CourseName"::varchar,
            AMB."AMB_BranchName"::varchar,
            AMSE."AMSE_SEMName"::varchar,
            AMCS."AlCMST_MobileNo"::varchar as "AMCST_MobileNo",
            AMCS."AlCMST_emailId"::varchar as "AMCST_emailId",
            AMCS."AlCMST_DOB" as "AMCST_DOB",
            ASMAY."ASMAY_Year"::varchar,
            NULL::bigint as "HRME_Id",
            NULL::varchar as "HRME_EmailId",
            NULL::varchar as "HRME_MobileNo",
            NULL::text as "employeename",
            NULL::varchar as "HRME_EmployeeCode",
            NULL::timestamp as "HRME_DOB"
        FROM "CLG"."Alumni_College_Master_Student" AMCS
        INNER JOIN "CLG"."Adm_Master_Course" AMCO ON AMCO."MI_Id" = "MI_Id" AND AMCO."AMCO_Id" = AMCS."AMCO_Left_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" AMB ON AMB."MI_Id" = "MI_Id" AND AMB."AMB_Id" = AMCS."AMB_Id_Left"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ASMAY ON ASMAY."ASMAY_Id" = AMCS."ASMAY_Id_Left" and ASMAY."MI_Id" = "MI_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" AMSE ON AMSE."MI_Id" = "MI_Id" and AMSE."AMSE_Id" = AMCS."AMSE_Id_Left"
        WHERE AMCS."MI_Id" = "MI_Id" 
            AND (EXTRACT(DAY FROM AMCS."ALCMST_DOB") = EXTRACT(DAY FROM CURRENT_TIMESTAMP) 
                 AND EXTRACT(MONTH FROM AMCS."ALCMST_DOB") = EXTRACT(MONTH FROM CURRENT_TIMESTAMP));

    END IF;

    RETURN;

END;
$$;