CREATE OR REPLACE FUNCTION "dbo"."CHAIRMAN_LOGIN_COUNT_STAFF_MOBILE"(
    "USERId" BIGINT,
    "FRMDATE" DATE,
    "TODATE" DATE,
    "TYPE" TEXT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "MI_Name" TEXT,
    "IVRMRT_Id" BIGINT,
    "IVRMRT_Role" TEXT,
    "IVRMMALD_logintype" TEXT,
    "CNT" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "TYPE" = 'L' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."MI_Id",
            D."MI_Name",
            C."IVRMRT_Id",
            UPPER(C."IVRMRT_Role")::"text" AS "IVRMRT_Role",
            UPPER(A."IVRMMALD_logintype")::"text" AS "IVRMMALD_logintype",
            COUNT(A."IVRMMALD_Id") AS "CNT"
        FROM "IVRM_MobileApp_LoginDetails" AS A
        INNER JOIN "ApplicationUserRole" AS B ON A."ivrmul_id" = B."userid"
        INNER JOIN "IVRM_Role_Type" AS C ON C."IVRMRT_Id" = B."RoleTypeId"
        INNER JOIN "Master_Institution" AS D ON D."MI_Id" = A."MI_Id"
        WHERE C."IVRMRT_Role" IN ('staff') 
            AND A."IVRMMALD_logintype" = 'Mobile'
            AND A."MI_Id" IN (
                SELECT DISTINCT "MI_Id"
                FROM "IVRM_User_Login_Institutionwise"
                WHERE "id" IN (
                    SELECT DISTINCT "UserId"
                    FROM "ApplicationUserRole"
                    WHERE "UserId" = "USERId"
                )
            )
            AND CAST(A."IVRMMALD_DateTime" AS DATE) BETWEEN "FRMDATE" AND "TODATE"
        GROUP BY A."MI_Id", D."MI_Name", C."IVRMRT_Id", C."IVRMRT_Role", A."IVRMMALD_logintype";

    ELSIF "TYPE" = 'D' THEN
        RETURN QUERY
        SELECT 
            A."MI_Id",
            B."MI_Name",
            NULL::BIGINT AS "IVRMRT_Id",
            NULL::TEXT AS "IVRMRT_Role",
            NULL::TEXT AS "IVRMMALD_logintype",
            COUNT(A."HRME_Id") AS "CNT"
        FROM "HR_Master_Employee" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        WHERE A."MI_Id" IN (
                SELECT DISTINCT "MI_Id"
                FROM "IVRM_User_Login_Institutionwise"
                WHERE "id" IN (
                    SELECT DISTINCT "UserId"
                    FROM "ApplicationUserRole"
                    WHERE "UserId" = "USERId"
                )
            )
            AND A."HRME_AppDownloadedDeviceId" <> '0'
            AND A."HRME_AppDownloadedDeviceId" IS NOT NULL
            AND A."HRME_AppDownloadedDeviceId" <> ''
            AND A."HRME_ActiveFlag" = 1
            AND A."HRME_LeftFlag" = 0
        GROUP BY A."MI_Id", B."MI_Name";

    ELSIF "TYPE" = 'R' THEN
        RETURN QUERY
        SELECT 
            A."MI_Id",
            B."MI_Name",
            NULL::BIGINT AS "IVRMRT_Id",
            NULL::TEXT AS "IVRMRT_Role",
            NULL::TEXT AS "IVRMMALD_logintype",
            COUNT(A."HRME_Id") AS "CNT"
        FROM "HR_Master_Employee" AS A
        INNER JOIN "Master_Institution" AS B ON B."MI_Id" = A."MI_Id"
        WHERE A."MI_Id" IN (
                SELECT DISTINCT "MI_Id"
                FROM "IVRM_User_Login_Institutionwise"
                WHERE "id" IN (
                    SELECT DISTINCT "UserId"
                    FROM "ApplicationUserRole"
                    WHERE "UserId" = "USERId"
                )
            )
            AND A."HRME_ActiveFlag" = 1
            AND A."HRME_LeftFlag" = 0
            AND (
                A."HRME_AppDownloadedDeviceId" = '0'
                OR A."HRME_AppDownloadedDeviceId" IS NULL
                OR A."HRME_AppDownloadedDeviceId" = ''
            )
        GROUP BY A."MI_Id", B."MI_Name";

    END IF;

    RETURN;

END;
$$;