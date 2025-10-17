CREATE OR REPLACE FUNCTION "dbo"."CHAIRMAN_LOGIN_DETAILS_STAFF_MOBILE"(
    "@MI_Id" bigint,
    "@USERId" bigint,
    "@FRMDATE" date,
    "@TODATE" date,
    "@TYPE" text
)
RETURNS TABLE(
    "MI_Id" bigint,
    "MI_Name" varchar,
    "IVRMRT_Id" bigint,
    "IVRMRT_Role" varchar,
    "IVRMMALD_logintype" varchar,
    "UserName" varchar,
    "EmpName" text,
    "IVRMMALD_Date" date,
    "IVRMMALD_Time" time,
    "LTIME" varchar,
    "HRME_DOJ" timestamp,
    "HRME_EmployeeCode" varchar,
    "HRMD_DepartmentName" varchar,
    "HRMDES_DesignationName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@TYPE" = 'L' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."MI_Id",
            "D"."MI_Name",
            A."IVRMRT_Id",
            UPPER(A."IVRMRT_Role")::varchar AS "IVRMRT_Role",
            UPPER(A."IVRMMALD_logintype")::varchar AS "IVRMMALD_logintype",
            (SELECT DISTINCT "L"."IVRMSTAUL_UserName" 
             FROM "IVRM_Staff_User_Login" "L" 
             WHERE "L"."Id" = A."IVRMUL_Id" AND "L"."MI_Id" = "@MI_Id")::varchar AS "UserName",
            (SELECT DISTINCT COALESCE("HME"."HRME_EmployeeFirstName", '') || ' ' || 
                    COALESCE("HME"."HRME_EmployeeMiddleName", '') || ' ' || 
                    COALESCE("HME"."HRME_EmployeeLastName", '')
             FROM "IVRM_Staff_User_Login" "L" 
             INNER JOIN "HR_Master_Employee" "HME" ON "L"."Emp_Code" = "HME"."HRME_Id"   
             WHERE "L"."Id" = A."IVRMUL_Id" AND "HME"."MI_Id" = "@MI_Id")::text AS "EmpName",
            CAST(A."IVRMMALD_DateTime" AS date) AS "IVRMMALD_Date",
            CAST(A."IVRMMALD_DateTime" AS time) AS "IVRMMALD_Time",
            TO_CHAR(A."IVRMMALD_DateTime", 'HH12:MI AM')::varchar AS "LTIME",
            NULL::timestamp AS "HRME_DOJ",
            NULL::varchar AS "HRME_EmployeeCode",
            NULL::varchar AS "HRMD_DepartmentName",
            NULL::varchar AS "HRMDES_DesignationName"
        FROM "IVRM_MobileApp_LoginDetails" AS A 
        INNER JOIN "ApplicationUserRole" AS B ON A."ivrmul_id" = B."userid"
        INNER JOIN "IVRM_Role_Type" AS C ON C."IVRMRT_Id" = B."RoleTypeId" 
        INNER JOIN "Master_Institution" AS D ON D."MI_Id" = A."MI_Id"
        WHERE C."IVRMRT_Role" IN ('staff') 
            AND A."IVRMMALD_logintype" = 'Mobile' 
            AND A."MI_Id" = "@MI_Id" 
            AND CAST(A."IVRMMALD_DateTime" AS date) BETWEEN "@FRMDATE" AND "@TODATE" 
        ORDER BY "UserName";

    ELSIF "@TYPE" = 'D' THEN
        RETURN QUERY
        SELECT 
            A."MI_Id",
            B."MI_Name",
            NULL::bigint AS "IVRMRT_Id",
            NULL::varchar AS "IVRMRT_Role",
            NULL::varchar AS "IVRMMALD_logintype",
            NULL::varchar AS "UserName",
            (COALESCE(A."HRME_EmployeeFirstName", '') || ' ' || 
             COALESCE(A."HRME_EmployeeMiddleName", '') || ' ' || 
             COALESCE(A."HRME_EmployeeLastName", ''))::text AS "EmpName",
            NULL::date AS "IVRMMALD_Date",
            NULL::time AS "IVRMMALD_Time",
            NULL::varchar AS "LTIME",
            A."HRME_DOJ",
            A."HRME_EmployeeCode",
            "HMD"."HRMD_DepartmentName",
            "HMDE"."HRMDES_DesignationName"
        FROM "HR_Master_Employee" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = A."HRMD_Id"
        INNER JOIN "HR_Master_Designation" "HMDE" ON "HMDE"."HRMDES_Id" = A."HRMDES_Id"
        WHERE A."MI_Id" = "@MI_Id" 
            AND A."HRME_AppDownloadedDeviceId" <> '0' 
            AND A."HRME_AppDownloadedDeviceId" IS NOT NULL  
            AND A."HRME_AppDownloadedDeviceId" <> '' 
            AND A."HRME_ActiveFlag" = 1 
            AND A."HRME_LeftFlag" = 0  
        ORDER BY "EmpName";

    ELSIF "@TYPE" = 'R' THEN
        RETURN QUERY
        SELECT 
            A."MI_Id",
            B."MI_Name",
            NULL::bigint AS "IVRMRT_Id",
            NULL::varchar AS "IVRMRT_Role",
            NULL::varchar AS "IVRMMALD_logintype",
            NULL::varchar AS "UserName",
            (COALESCE(A."HRME_EmployeeFirstName", '') || ' ' || 
             COALESCE(A."HRME_EmployeeMiddleName", '') || ' ' || 
             COALESCE(A."HRME_EmployeeLastName", ''))::text AS "EmpName",
            NULL::date AS "IVRMMALD_Date",
            NULL::time AS "IVRMMALD_Time",
            NULL::varchar AS "LTIME",
            A."HRME_DOJ",
            A."HRME_EmployeeCode",
            "HMD"."HRMD_DepartmentName",
            "HMDE"."HRMDES_DesignationName"
        FROM "HR_Master_Employee" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = A."HRMD_Id"
        INNER JOIN "HR_Master_Designation" "HMDE" ON "HMDE"."HRMDES_Id" = A."HRMDES_Id"
        WHERE A."MI_Id" = "@MI_Id" 
            AND A."HRME_ActiveFlag" = 1 
            AND A."HRME_LeftFlag" = 0 
            AND (A."HRME_AppDownloadedDeviceId" = '0' 
                OR A."HRME_AppDownloadedDeviceId" IS NULL  
                OR A."HRME_AppDownloadedDeviceId" = '') 
        ORDER BY "EmpName";

    END IF;

    RETURN;

END;
$$;