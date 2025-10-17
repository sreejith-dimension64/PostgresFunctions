CREATE OR REPLACE FUNCTION "dbo"."ISM_User_StatusList" (
    "@user_Id" VARCHAR(100),
    "@MI_Id" BIGINT
)
RETURNS TABLE (
    "ISMMISTS_StatusName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" TEXT;
BEGIN
    IF ("@user_Id" != '0') THEN
        RETURN QUERY
        SELECT DISTINCT "A"."ISMMISTS_StatusName"
        FROM "ISM_Master_IssueStatus" "A"
        INNER JOIN "HR_MASTER_DEPARTMENT" "B" ON "A"."HRMD_Id" = "B"."HRMD_Id"
        WHERE "A"."ISMMISTS_ActiveFlag" = TRUE
        AND "A"."HRMD_Id" IN (
            SELECT DISTINCT "UEM"."HRMD_Id"
            FROM "ISM_User_Employees_Mapping" "UEM"
            INNER JOIN "HR_Master_Employee" "HRE" ON "UEM"."HRME_Id" = "HRE"."HRME_Id"
            WHERE "UEM"."User_Id" = "@user_Id"
            AND "UEM"."ISMUSEMM_ActiveFlag" = TRUE
        );
    ELSE
        RETURN QUERY
        SELECT DISTINCT "ISMMISTS_StatusName"
        FROM "ISM_Master_IssueStatus"
        WHERE "ISMMISTS_ActiveFlag" = TRUE
        AND "MI_Id" = "@MI_Id";
    END IF;
    
    RETURN;
END;
$$;