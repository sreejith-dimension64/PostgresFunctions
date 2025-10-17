CREATE OR REPLACE FUNCTION "dbo"."CHAIRMAN_LOGIN_COUNT"(
    "@USERId" BIGINT,
    "@FRMDATE" DATE,
    "@TODATE" DATE
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "MI_Name" VARCHAR,
    "IVRMRT_Id" BIGINT,
    "IVRMRT_Role" VARCHAR,
    "IVRMMALD_logintype" VARCHAR,
    "CNT" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "A"."MI_Id",
        "D"."MI_Name",
        "C"."IVRMRT_Id",
        UPPER("C"."IVRMRT_Role") AS "IVRMRT_Role",
        UPPER("A"."IVRMMALD_logintype") AS "IVRMMALD_logintype",
        COUNT("A"."IVRMMALD_Id") AS "CNT"
    FROM "IVRM_MobileApp_LoginDetails" AS "A"
    INNER JOIN "ApplicationUserRole" AS "B" ON "A"."ivrmul_id" = "B"."userid"
    INNER JOIN "IVRM_Role_Type" AS "C" ON "C"."IVRMRT_Id" = "B"."RoleTypeId"
    INNER JOIN "Master_Institution" AS "D" ON "D"."MI_Id" = "A"."MI_Id"
    WHERE "C"."IVRMRT_Role" IN ('Principal', 'Manager')
    AND "A"."MI_Id" IN (
        SELECT DISTINCT "MI_Id"
        FROM "IVRM_User_Login_Institutionwise"
        WHERE "id" IN (
            SELECT DISTINCT "UserId"
            FROM "ApplicationUserRole"
            WHERE "UserId" = "@USERId"
        )
    )
    AND CAST("A"."IVRMMALD_DateTime" AS DATE) BETWEEN "@FRMDATE" AND "@TODATE"
    GROUP BY "A"."MI_Id", "D"."MI_Name", "C"."IVRMRT_Id", "C"."IVRMRT_Role", "A"."IVRMMALD_logintype";
END;
$$;