CREATE OR REPLACE FUNCTION "dbo"."ISM_DEPARTMENTWISE_STATUS_LIST"(
    "@MI_ID" BIGINT,
    "@ROLE" TEXT,
    "@USER_ID" BIGINT,
    "@Flag" TEXT,
    "@DEPT_Id" TEXT
)
RETURNS TABLE(
    "ISMMISTS_StatusName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@SLQDYMAIC" TEXT;
BEGIN

    IF "@Flag" = '1' THEN
        
        IF "@ROLE" = 'Admin' OR "@ROLE" = 'ADMIN' OR "@ROLE" = 'HR' THEN
            
            RETURN QUERY
            SELECT DISTINCT "A"."ISMMISTS_StatusName"::TEXT
            FROM "ISM_Master_IssueStatus" "A"
            WHERE "A"."ISMMISTS_ActiveFlag" = true;
            
        ELSE
            
            RETURN QUERY
            SELECT DISTINCT "A"."ISMMISTS_StatusName"::TEXT
            FROM "ISM_Master_IssueStatus" "A"
            INNER JOIN "MASTER_INSTITUTION" "C" ON "C"."MI_Id" = "A"."MI_Id"
            WHERE "C"."MI_ACTIVEFLAG" = 1 
                AND "A"."ISMMISTS_ActiveFlag" = true 
                AND "A"."HRMD_Id" IN (
                    SELECT DISTINCT "HRMD_Id" 
                    FROM "HR_MASTER_EMPLOYEE" 
                    WHERE "HRME_Id" IN (
                        SELECT "HRME_ID" 
                        FROM "ISM_USER_EMPLOYEES_MAPPING" 
                        WHERE "USER_ID" = "@USER_ID"
                    )
                );
            
        END IF;
        
    ELSIF "@Flag" = '2' THEN
        
        "@SLQDYMAIC" := 'SELECT DISTINCT "A"."ISMMISTS_StatusName"::TEXT
            FROM "ISM_Master_IssueStatus" "A"
            INNER JOIN "MASTER_INSTITUTION" "C" ON "C"."MI_Id" = "A"."MI_Id"
            INNER JOIN "HR_MASTER_DEPARTMENT" "D" ON "D"."HRMD_Id" = "A"."HRMD_Id"
            WHERE "C"."MI_ACTIVEFLAG" = 1 
                AND "A"."ISMMISTS_ActiveFlag" = true 
                AND "D"."HRMDC_ID" IN (' || "@DEPT_Id" || ')';
        
        RETURN QUERY EXECUTE "@SLQDYMAIC";
        
    END IF;

    RETURN;

END;
$$;