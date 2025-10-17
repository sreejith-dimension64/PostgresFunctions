CREATE OR REPLACE FUNCTION "dbo"."ISM_DEPARTMENTWISE_MODULE_LIST"(
    "@MI_ID" BIGINT,
    "@ROLE" TEXT,
    "@USER_ID" BIGINT,
    "@Flag" TEXT,
    "@DEPT_Id" TEXT
)
RETURNS TABLE(
    "IVRMM_Id" BIGINT,
    "IVRMM_ModuleName" VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@SLQDYMAIC" TEXT;
BEGIN

    IF "@Flag" = '1' THEN
    
        IF "@ROLE" = 'Admin' OR "@ROLE" = 'ADMIN' OR "@ROLE" = 'HR' THEN
        
            RETURN QUERY
            SELECT DISTINCT B."IVRMM_Id", B."IVRMM_ModuleName" 
            FROM "ISM_Master_Module" A 
            INNER JOIN "IVRM_Module" B ON A."IVRMM_Id" = B."IVRMM_Id"
            INNER JOIN "MASTER_INSTITUTION" C ON C."MI_Id" = A."MI_Id"
            INNER JOIN "ISM_Master_Project" D ON D."ISMMPR_Id" = A."ISMMPR_Id"
            WHERE C."MI_ACTIVEFLAG" = 1 
                AND A."ISMMMD_ActiveFlag" = 1 
                AND B."Module_ActiveFlag" = 1;
        
        ELSE
        
            RETURN QUERY
            SELECT DISTINCT B."IVRMM_Id", B."IVRMM_ModuleName" 
            FROM "ISM_Master_Module" A 
            INNER JOIN "IVRM_Module" B ON A."IVRMM_Id" = B."IVRMM_Id"
            INNER JOIN "MASTER_INSTITUTION" C ON C."MI_Id" = A."MI_Id"
            INNER JOIN "ISM_Master_Project" D ON D."ISMMPR_Id" = A."ISMMPR_Id"
            WHERE C."MI_ACTIVEFLAG" = 1 
                AND A."ISMMMD_ActiveFlag" = 1 
                AND B."Module_ActiveFlag" = 1 
                AND A."HRMD_Id" IN (
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
    
        "@SLQDYMAIC" := 'SELECT DISTINCT B."IVRMM_Id", B."IVRMM_ModuleName" 
            FROM "ISM_Master_Module" A 
            INNER JOIN "IVRM_Module" B ON A."IVRMM_Id" = B."IVRMM_Id"
            INNER JOIN "MASTER_INSTITUTION" C ON C."MI_Id" = A."MI_Id"
            INNER JOIN "ISM_Master_Project" D ON D."ISMMPR_Id" = A."ISMMPR_Id"
            INNER JOIN "HR_MASTER_DEPARTMENT" E ON E."HRMD_Id" = A."HRMD_Id"
            WHERE C."MI_ACTIVEFLAG" = 1 
                AND A."ISMMMD_ActiveFlag" = 1 
                AND B."Module_ActiveFlag" = 1 
                AND E."HRMDC_ID" IN (' || "@DEPT_Id" || ')';
        
        RETURN QUERY EXECUTE "@SLQDYMAIC";
    
    END IF;

    RETURN;

END;
$$;