CREATE OR REPLACE FUNCTION "dbo"."Employeestatewisecount"(
    "MI_Id" VARCHAR(50),
    "IVRMMS_Id" TEXT
)
RETURNS TABLE(
    "IVRMMC_CountryName" VARCHAR,
    "IVRMMS_Name" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "Count" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN
    
    "query" := 'SELECT "IMC"."IVRMMC_CountryName", "IMS"."IVRMMS_Name", "HMD"."HRMD_DepartmentName", COUNT(DISTINCT "HME"."HRME_Id") AS "Count"
    FROM "HR_Master_Employee" "HME"
    INNER JOIN "IVRM_Master_Country" "IMC" ON "IMC"."IVRMMC_Id" = "HME"."HRME_PerCountryId"
    INNER JOIN "IVRM_Master_State" "IMS" ON "IMS"."IVRMMS_Id" = "HME"."HRME_PerStateId" AND "IMS"."IVRMMC_Id" = "IMC"."IVRMMC_Id"
    INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id" AND "HMD"."MI_Id" = "HME"."MI_Id"
    WHERE "HME"."MI_ID" = ' || "MI_Id" || ' AND "IMS"."IVRMMS_Id" IN (' || "IVRMMS_Id" || ') AND "HME"."HRME_Activeflag" = 1 AND "HMD"."HRMD_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
    GROUP BY "IMC"."IVRMMC_CountryName", "IMS"."IVRMMS_Name", "HMD"."HRMD_DepartmentName"';
    
    RETURN QUERY EXECUTE "query";
    
END;
$$;