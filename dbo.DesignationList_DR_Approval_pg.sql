CREATE OR REPLACE FUNCTION "dbo"."DesignationList_DR_Approval"(
    "@MI_Id" TEXT,
    "@role" TEXT,
    "@user_Id" TEXT,
    "@departments" TEXT
)
RETURNS TABLE(
    "HRMDES_Id" INTEGER,
    "MI_Id" INTEGER,
    "HRMDES_DesignationName" VARCHAR,
    "MI_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@Slqdymaic" TEXT;
BEGIN
    IF "@role" = 'Admin' OR "@role" = 'ADMIN' OR "@role" = 'HR' THEN
        RETURN QUERY
        SELECT 
            "HR_Master_Designation"."HRMDES_Id",
            "HR_Master_Designation"."MI_Id",
            "HR_Master_Designation"."HRMDES_DesignationName",
            "Master_Institution"."MI_Subdomain" AS "MI_Name"
        FROM "HR_Master_Designation" 
        INNER JOIN "Master_Institution" ON "Master_Institution"."MI_Id" = "HR_Master_Designation"."MI_Id"
        WHERE "HR_Master_Designation"."HRMDES_ActiveFlag" = 1 
        AND "HR_Master_Designation"."MI_Id" IN (
            SELECT "MI_Id" 
            FROM "Master_Institution" 
            WHERE "MI_ActiveFlag" = 1
        )
        ORDER BY "HR_Master_Designation"."HRMDES_DesignationName";
    ELSE
        "@Slqdymaic" := 'SELECT DISTINCT a."HRMDES_Id", a."MI_Id", a."HRMDES_DesignationName", c."MI_Subdomain" AS "MI_Name"
        FROM "HR_Master_Designation" a 
        INNER JOIN "HR_Master_Employee" b ON a."HRMDES_Id" = b."HRMDES_Id"
        INNER JOIN "Master_Institution" c ON c."MI_Id" = b."MI_Id"
        WHERE a."HRMDES_ActiveFlag" = 1 
        AND b."HRME_Id" IN (SELECT "HRME_Id" FROM "ISM_User_Employees_Mapping" WHERE "User_Id" = ' || "@user_Id" || ')
        AND b."HRMDC_ID" IN (' || "@departments" || ')
        ORDER BY a."HRMDES_DesignationName"';
        
        RETURN QUERY EXECUTE "@Slqdymaic";
    END IF;
    
    RETURN;
END;
$$;