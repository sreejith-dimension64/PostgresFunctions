CREATE OR REPLACE FUNCTION "dbo"."HR_Email_Prametars_Replace"(
    @MI_Id bigint,
    @HRME_IDE bigint,
    @Type text
)
RETURNS TABLE (
    "[NAME]" text,
    "[USR]" text,
    "[PWD]" text,
    "[Company]" text,
    "[LOGO]" text,
    "[DATE]" date
) 
LANGUAGE plpgsql
AS $$
BEGIN

    IF @Type = 'SendAlumniCredential' THEN
        RETURN QUERY
        SELECT 
            COALESCE("a"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("a"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("a"."HRME_EmployeeLastName", '') AS "[NAME]",
            "c"."NormalizedUserName" AS "[USR]",
            'Password@123' AS "[PWD]",
            "d"."MI_Name" AS "[Company]",
            "d"."MI_Logo" AS "[LOGO]",
            CAST(CURRENT_TIMESTAMP AS date) AS "[DATE]"
        FROM "HR_Master_Employee" "a"
        INNER JOIN "IVRM_Staff_User_Login" "b" ON "a"."HRME_Id" = "b"."Emp_Code"
        INNER JOIN "ApplicationUser" "c" ON "b"."Id" = "c"."Id"
        INNER JOIN "Master_Institution" "d" ON "a"."MI_Id" = "d"."MI_Id"
        WHERE "a"."HRME_Id" = @HRME_IDE AND "a"."HRME_ActiveFlag" = true;
        
    ELSIF @Type = 'VapsTrainingRequest' THEN
        RETURN QUERY
        SELECT 
            COALESCE("a"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("a"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("a"."HRME_EmployeeLastName", '') AS "[NAME]",
            NULL::text AS "[USR]",
            NULL::text AS "[PWD]",
            "b"."MI_Name" AS "[Company]",
            "b"."MI_Logo" AS "[LOGO]",
            CAST(CURRENT_TIMESTAMP AS date) AS "[DATE]"
        FROM "HR_Master_Employee" "a"
        INNER JOIN "Master_Institution" "b" ON "a"."MI_Id" = "b"."MI_Id"
        WHERE "b"."MI_Id" = 4 AND "a"."HRME_ActiveFlag" = true;
        
    END IF;

    RETURN;

END;
$$;