CREATE OR REPLACE FUNCTION "dbo"."HR_DepartmentWiseEmployeeAgeSlab"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT,
    p_HRMD_ID TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "Ageslab" TEXT,
    "EmpCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
    v_sqldynamic1 TEXT;
    v_sqldynamic2 TEXT;
BEGIN
    -- Drop temporary tables if they exist
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp1";
    DROP TABLE IF EXISTS "ExamStudentMarks_Temp2";
    
    -- Build first dynamic SQL
    v_sqldynamic := '
    CREATE TEMP TABLE "ExamStudentMarks_Temp" AS
    SELECT "ASMAY_Year", "HRMD_DepartmentName", ''46>60'' as "Ageslab", "EmpCount" FROM (
        SELECT "ASMAY"."ASMAY_Year", "HMD"."HRMD_Id", "HMD"."HRMD_DepartmentName", COUNT(DISTINCT "HRME_Id") as "EmpCount"
        FROM "HR_Master_Employee" "HME"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id" AND "HME"."MI_Id" = "HMD"."MI_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."MI_Id" = "HMD"."MI_Id"
        WHERE "HME"."MI_Id" = ' || p_MI_ID || ' 
            AND "ASMAY"."ASMAY_ID" = ' || p_ASMAY_ID || ' 
            AND "HMD"."HRMD_Id" IN (' || p_HRMD_ID || ') 
            AND "HME"."HRME_ActiveFlag" = 1 
            AND "HMD"."HRMD_ActiveFlag" = 1
            AND "ASMAY_ActiveFlag" = 1 
            AND EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, "HME"."HRME_DOB")) BETWEEN 46 AND 60
        GROUP BY "ASMAY_ID", "ASMAY"."ASMAY_Year", "HMD"."HRMD_Id", "HMD"."HRMD_DepartmentName"
    ) A 
    ORDER BY "HRMD_DepartmentName"';
    
    -- Build second dynamic SQL
    v_sqldynamic1 := '
    CREATE TEMP TABLE "ExamStudentMarks_Temp1" AS
    SELECT "ASMAY_Year", "HRMD_DepartmentName", ''31>45'' as "Ageslab", "EmpCount" FROM (
        SELECT "ASMAY"."ASMAY_Year", "HMD"."HRMD_Id", "HMD"."HRMD_DepartmentName", COUNT(DISTINCT "HRME_Id") as "EmpCount"
        FROM "HR_Master_Employee" "HME"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id" AND "HME"."MI_Id" = "HMD"."MI_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."MI_Id" = "HMD"."MI_Id"
        WHERE "HME"."MI_Id" = ' || p_MI_ID || ' 
            AND "ASMAY"."ASMAY_ID" = ' || p_ASMAY_ID || ' 
            AND "HMD"."HRMD_Id" IN (' || p_HRMD_ID || ') 
            AND "HME"."HRME_ActiveFlag" = 1 
            AND "HMD"."HRMD_ActiveFlag" = 1
            AND "ASMAY_ActiveFlag" = 1 
            AND EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, "HME"."HRME_DOB")) BETWEEN 31 AND 45
        GROUP BY "ASMAY_ID", "ASMAY"."ASMAY_Year", "HMD"."HRMD_Id", "HMD"."HRMD_DepartmentName"
    ) A 
    ORDER BY "HRMD_DepartmentName"';
    
    -- Build third dynamic SQL
    v_sqldynamic2 := '
    CREATE TEMP TABLE "ExamStudentMarks_Temp2" AS
    SELECT "ASMAY_Year", "HRMD_DepartmentName", ''18>30'' as "Ageslab", "EmpCount" FROM (
        SELECT "ASMAY"."ASMAY_Year", "HMD"."HRMD_Id", "HMD"."HRMD_DepartmentName", COUNT(DISTINCT "HRME_Id") as "EmpCount"
        FROM "HR_Master_Employee" "HME"
        INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "HME"."HRMD_Id" AND "HME"."MI_Id" = "HMD"."MI_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."MI_Id" = "HMD"."MI_Id"
        WHERE "HME"."MI_Id" = ' || p_MI_ID || ' 
            AND "ASMAY"."ASMAY_ID" = ' || p_ASMAY_ID || ' 
            AND "HMD"."HRMD_Id" IN (' || p_HRMD_ID || ') 
            AND "HME"."HRME_ActiveFlag" = 1 
            AND "HMD"."HRMD_ActiveFlag" = 1
            AND "ASMAY_ActiveFlag" = 1 
            AND EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, "HME"."HRME_DOB")) BETWEEN 18 AND 30
        GROUP BY "ASMAY_ID", "ASMAY"."ASMAY_Year", "HMD"."HRMD_Id", "HMD"."HRMD_DepartmentName"
    ) A 
    ORDER BY "HRMD_DepartmentName"';
    
    -- Execute dynamic SQL statements
    EXECUTE v_sqldynamic;
    EXECUTE v_sqldynamic1;
    EXECUTE v_sqldynamic2;
    
    -- Return combined results
    RETURN QUERY
    SELECT * FROM "ExamStudentMarks_Temp"
    UNION ALL
    SELECT * FROM "ExamStudentMarks_Temp1"
    UNION ALL
    SELECT * FROM "ExamStudentMarks_Temp2";
    
END;
$$;