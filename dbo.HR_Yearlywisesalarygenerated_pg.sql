CREATE OR REPLACE FUNCTION "dbo"."HR_Yearlywisesalarygenerated"(
    "@MI_ID" TEXT,
    "@ASMAY_ID" TEXT,
    "@HRMD_Id" TEXT
)
RETURNS TABLE(
    "HRMD_DepartmentName" VARCHAR,
    result_columns JSONB
) 
LANGUAGE plpgsql
AS $$
DECLARE 
    "sqldynamic" TEXT;
    "PivotColumnNames" TEXT;
    "monthyearsd" TEXT;
BEGIN
    -- Drop temp table if exists
    DROP TABLE IF EXISTS "AdmissionAccYear_Temp";
    
    -- Create and populate temp table
    "PivotColumnNames" := 'CREATE TEMP TABLE "AdmissionAccYear_Temp" AS 
        SELECT "ASMAY_Year" 
        FROM "dbo"."Adm_School_M_Academic_Year" 
        WHERE "ASMAY_ID" IN (' || "@ASMAY_ID" || ') 
        AND "MI_Id" = ' || "@MI_ID";
    
    EXECUTE "PivotColumnNames";
    
    -- Build pivot column names
    SELECT STRING_AGG(DISTINCT '"' || "ASMAY_Year" || '"', ',') 
    INTO "monthyearsd"
    FROM "AdmissionAccYear_Temp";
    
    -- Build and execute dynamic SQL
    "sqldynamic" := '
    SELECT "HRMD_DepartmentName", ' || "monthyearsd" || ' 
    FROM (
        SELECT "HMD"."HRMD_DepartmentName", "ASMAY_Year", SUM("HRESD_Amount") AS "HRESD_Amount"
        FROM "dbo"."HR_Master_Employee" "HME"
        INNER JOIN "dbo"."HR_Master_Department" "HMD" 
            ON "HMD"."HRMD_Id" = "HME"."HRMD_Id" 
            AND "HME"."MI_Id" = "HMD"."MI_Id"
        INNER JOIN "dbo"."HR_Employee_Salary" "ES" 
            ON "HME"."HRME_Id" = "ES"."HRME_Id" 
            AND "HMD"."HRMD_Id" = "ES"."HRMD_Id" 
            AND "HME"."MI_Id" = "ES"."MI_Id"
        INNER JOIN "dbo"."HR_Employee_Salary_Details" "SD" 
            ON "ES"."HRES_Id" = "SD"."HRES_Id"
        INNER JOIN "dbo"."HR_Master_EarningsDeductions" "MED" 
            ON "MED"."HRMED_Id" = "SD"."HRMED_Id" 
            AND "HME"."MI_Id" = "MED"."MI_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" "ASMAY" 
            ON "ASMAY"."MI_Id" = "MED"."MI_Id" 
            AND "ES"."HRES_Year" BETWEEN EXTRACT(YEAR FROM "ASMAY"."ASMAY_From_Date"::DATE) 
                AND EXTRACT(YEAR FROM "ASMAY"."ASMAY_To_Date"::DATE)
        WHERE "HMD"."HRMD_Id" IN (' || "@HRMD_Id" || ') 
            AND "ASMAY"."ASMAY_ID" IN (' || "@ASMAY_ID" || ') 
            AND "ES"."MI_Id" = ' || "@MI_ID" || ' 
            AND "HME"."HRME_ActiveFlag" = TRUE
            AND "HMD"."HRMD_ActiveFlag" = TRUE 
            AND "MED"."HRMED_ActiveFlag" = TRUE
        GROUP BY "HMD"."HRMD_DepartmentName", "ASMAY_Year"
    ) "A"
    PIVOT (
        SUM("HRESD_Amount") 
        FOR "ASMAY_Year" IN (' || "monthyearsd" || ')
    ) AS "PVT"
    ORDER BY "HRMD_DepartmentName"
    LIMIT 100';
    
    RETURN QUERY EXECUTE "sqldynamic";
    
    -- Cleanup temp table
    DROP TABLE IF EXISTS "AdmissionAccYear_Temp";
    
END;
$$;