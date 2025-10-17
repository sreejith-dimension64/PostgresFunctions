CREATE OR REPLACE FUNCTION "dbo"."HOD_EMP_POPUP"(
    @MI_ID bigint,
    @User_Id TEXT
)
RETURNS TABLE (
    "hrmE_Id" bigint,
    "empname" TEXT,
    "doj" TIMESTAMP,
    "mstatus" TEXT,
    "gender" TEXT,
    "mobileno" bigint,
    "email" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "HOD_staffwise_Temp";

    CREATE TEMP TABLE "HOD_staffwise_Temp" AS
    SELECT DISTINCT e."HRME_Id" as staff_id, d."IHOD_Id", a."Id"
    FROM "ApplicationUser" a 
    INNER JOIN "IVRM_Staff_User_Login" b ON a."Id" = b."Id" 
    INNER JOIN "HR_Master_Employee" c ON c."HRME_Id" = b."Emp_Code"
    INNER JOIN "IVRM_HOD" d ON d."HRME_Id" = c."HRME_Id"
    INNER JOIN "IVRM_HOD_Staff" e ON e."IHOD_Id" = d."IHOD_Id"
    WHERE a."Id" = @User_Id AND c."MI_Id" = @MI_ID AND d."IHOD_Flg" = 'HOD';

    RETURN QUERY
    SELECT DISTINCT 
        A."HRME_Id" as "hrmE_Id",
        (COALESCE(A."HRME_EmployeeFirstName", '') || '' || COALESCE(A."HRME_EmployeeMiddleName", '') || '' || COALESCE(A."HRME_EmployeeLastName", '')) as "empname",
        A."HRME_DOJ" as "doj",
        COALESCE(C."IVRMMMS_MaritalStatus", '') as "mstatus",
        COALESCE(B."IVRMMG_GenderName", '') as "gender",
        COALESCE(A."HRME_MobileNo", 0) as "mobileno",
        COALESCE(A."HRME_EmailId", '') as "email"
    FROM "HR_Master_Employee" AS A
    LEFT JOIN "IVRM_Master_Gender" AS B ON A."IVRMMG_Id" = B."IVRMMG_Id" AND A."MI_Id" = B."MI_Id"
    LEFT JOIN "IVRM_Master_Marital_Status" AS C ON A."IVRMMMS_Id" = C."IVRMMMS_Id" AND A."MI_Id" = C."MI_Id"
    WHERE A."HRME_ActiveFlag" = 1 AND A."MI_Id" = @MI_ID 
    AND A."HRME_Id" IN (SELECT DISTINCT staff_id FROM "HOD_staffwise_Temp");

    DROP TABLE IF EXISTS "HOD_staffwise_Temp";

END;
$$;