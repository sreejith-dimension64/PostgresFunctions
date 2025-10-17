CREATE OR REPLACE FUNCTION "dbo"."Institutionwise_module_using_count"()
RETURNS TABLE (
    "MI_Name" VARCHAR,
    "mi_id" INTEGER,
    "HRMS" BIGINT,
    "Library" BIGINT,
    "Admission" BIGINT,
    "ONLINEPAYMENTCOUNT" BIGINT,
    "OFFLINEPAYMENTCOUNT" BIGINT,
    "PREAdmission" BIGINT,
    "INVENTORY" BIGINT,
    "MOBILEAPPUSERCOUNT" BIGINT,
    "examStudentCount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "temp_HRMS";
    
    CREATE TEMP TABLE "temp_HRMS" AS
    SELECT "E"."mi_id", COUNT(DISTINCT "P"."HRME_Id") AS "TotalEmp", 'HRMS_Salary' AS "FLAG"
    FROM "HR_Master_Employee" "E"
    INNER JOIN "hr_employee_salary" "P" ON "P"."HRME_ID" = "E"."HRME_ID" AND "P"."HRES_Year" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    WHERE "E"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
    AND "E"."HRME_Activeflag" = 1 AND "E"."HRME_LeftFlag" = 0
    GROUP BY "E"."MI_ID";

    DROP TABLE IF EXISTS "temp_ONLINEFee";
    
    CREATE TEMP TABLE "temp_ONLINEFee" AS
    SELECT "FYP"."MI_ID",
    CASE WHEN "FYP"."FYP_Bank_Or_Cash" = 'O' THEN COUNT("FYPSS"."AMST_Id") ELSE 0 END AS "ONLINEPAYMENTCOUNT",
    'ONLINEFees' AS "Flag"
    FROM "Fee_Y_Payment" "FYP"
    INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYPSS"."FYP_Id" = "FYP"."FYP_Id"
    WHERE "FYP"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1)
    AND EXTRACT(YEAR FROM "FYP"."FYP_Date") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    AND "FYP"."ASMAY_Id" IN (
        SELECT "AY"."ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
        AND CURRENT_TIMESTAMP BETWEEN "AY"."ASMAY_FROM_Date" AND "AY"."ASMAY_To_Date"
    )
    AND "FYP"."FYP_Bank_Or_Cash" = 'O'
    GROUP BY "FYP"."MI_ID", "FYP"."FYP_Bank_Or_Cash";

    DROP TABLE IF EXISTS "temp_OFFLINEFee";
    
    CREATE TEMP TABLE "temp_OFFLINEFee" AS
    SELECT "FYP"."MI_ID",
    CASE WHEN "FYP"."FYP_Bank_Or_Cash" != 'O' THEN COUNT("FYPSS"."AMST_Id") ELSE 0 END AS "OFFLINEPAYMENTCOUNT",
    'OFFLINEFees' AS "Flag"
    FROM "Fee_Y_Payment" "FYP"
    INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYPSS"."FYP_Id" = "FYP"."FYP_Id"
    WHERE "FYP"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1)
    AND EXTRACT(YEAR FROM "FYP"."FYP_Date") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    AND "FYP"."ASMAY_Id" IN (
        SELECT "AY"."ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
        AND CURRENT_TIMESTAMP BETWEEN "AY"."ASMAY_FROM_Date" AND "AY"."ASMAY_To_Date"
    )
    AND "FYP"."FYP_Bank_Or_Cash" != 'O'
    GROUP BY "FYP"."MI_ID", "FYP"."FYP_Bank_Or_Cash";

    DROP TABLE IF EXISTS "temp_OFFLINEFee1";
    
    CREATE TEMP TABLE "temp_OFFLINEFee1" AS
    SELECT "MI_ID", SUM("OFFLINEPAYMENTCOUNT") AS "OFFLINEPAYMENTCOUNT", "Flag"
    FROM "temp_OFFLINEFee"
    GROUP BY "MI_ID", "Flag";

    DROP TABLE IF EXISTS "temp_LIB";
    
    CREATE TEMP TABLE "temp_LIB" AS
    SELECT "MI_ID", COUNT("LBTR_Status") AS "LIB_Count", 'Library' AS "Flag"
    FROM "LIB"."LIB_Book_Transaction"
    WHERE "MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
    AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    GROUP BY "MI_ID";

    DROP TABLE IF EXISTS "temp_ADM";
    
    CREATE TEMP TABLE "temp_ADM" AS
    SELECT "MI_ID", COUNT("AMST_ID") AS "ADMISSION", 'Admission' AS "Flag"
    FROM "Adm_M_Student"
    WHERE "MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1)
    AND "ASMAY_Id" IN (
        SELECT "AY"."ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
        AND CURRENT_TIMESTAMP BETWEEN "AY"."ASMAY_FROM_Date" AND "AY"."ASMAY_To_Date"
    )
    AND "AMST_Activeflag" = 1
    GROUP BY "MI_ID";

    DROP TABLE IF EXISTS "temp_PRE";
    
    CREATE TEMP TABLE "temp_PRE" AS
    SELECT "MI_ID", COUNT("PASR_ID") AS "PREADMISSION", 'PREAdmission' AS "Flag"
    FROM "Preadmission_School_Registration"
    WHERE "MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
    AND "ASMAY_Id" IN (
        SELECT "AY"."ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
        AND CURRENT_TIMESTAMP BETWEEN "AY"."ASMAY_FROM_Date" AND "AY"."ASMAY_To_Date"
    )
    AND "PASR_Adm_Confirm_Flag" != 1
    GROUP BY "MI_Id";

    DROP TABLE IF EXISTS "temp_INVENTORY";
    
    CREATE TEMP TABLE "temp_INVENTORY" AS
    SELECT "MI_Id", COUNT("INVMSL_Id") AS "INVENTORYCOUNT", 'INVENTORY' AS "FLAG"
    FROM "INV"."INV_M_Sales"
    WHERE "MI_Id" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
    AND EXTRACT(YEAR FROM "INVMSL_SalesDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    GROUP BY "MI_Id";

    DROP TABLE IF EXISTS "temp_MOBILEAPP";
    
    CREATE TEMP TABLE "temp_MOBILEAPP" AS
    SELECT "MI_Id", COUNT(DISTINCT "IVRMUL_Id") AS "MOBILEAPPCOUNT", 'MOBILEAPPUSERCOUNT' AS "FLAG"
    FROM "IVRM_MobileApp_LoginDetails"
    WHERE "IVRMMALD_logintype" = 'Mobile'
    AND EXTRACT(YEAR FROM "IVRMMALD_DateTime") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    GROUP BY "MI_Id";

    DROP TABLE IF EXISTS "temp_Exam";
    
    CREATE TEMP TABLE "temp_Exam" AS
    SELECT "MI_Id", COUNT("AMST_Id") AS "Examcount", 'examStudentCount' AS "Flag"
    FROM "Exm"."exm_student_marks"
    WHERE "MI_Id" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
    AND "ASMAY_Id" IN (
        SELECT "AY"."ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'S')
        AND CURRENT_TIMESTAMP BETWEEN "AY"."ASMAY_FROM_Date" AND "AY"."ASMAY_To_Date"
    )
    GROUP BY "MI_Id";

    DROP TABLE IF EXISTS "temp_Totalcount";
    
    CREATE TEMP TABLE "temp_Totalcount" AS
    WITH "CombinedData" AS (
        SELECT "mi_id", "TotalEmp" AS "Count", "FLAG" FROM "temp_HRMS"
        UNION ALL
        SELECT "MI_ID", "LIB_Count", "Flag" FROM "temp_LIB"
        UNION ALL
        SELECT "MI_ID", "ADMISSION", "Flag" FROM "temp_ADM"
        UNION ALL
        SELECT "MI_ID", "ONLINEPAYMENTCOUNT", "Flag" FROM "temp_ONLINEFee"
        UNION ALL
        SELECT "MI_ID", "OFFLINEPAYMENTCOUNT", "Flag" FROM "temp_OFFLINEFee1"
        UNION ALL
        SELECT "MI_ID", "PREADMISSION", "Flag" FROM "temp_PRE"
        UNION ALL
        SELECT "MI_Id", "INVENTORYCOUNT", "FLAG" FROM "temp_INVENTORY"
        UNION ALL
        SELECT "MI_Id", "MOBILEAPPCOUNT", "FLAG" FROM "temp_MOBILEAPP"
        UNION ALL
        SELECT "MI_Id", "Examcount", "Flag" FROM "temp_Exam"
    )
    SELECT 
        "mi_id",
        COALESCE(SUM(CASE WHEN "FLAG" = 'HRMS_Salary' THEN "Count" ELSE 0 END), 0) AS "HRMS",
        COALESCE(SUM(CASE WHEN "FLAG" = 'Library' THEN "Count" ELSE 0 END), 0) AS "Library",
        COALESCE(SUM(CASE WHEN "FLAG" = 'Admission' THEN "Count" ELSE 0 END), 0) AS "Admission",
        COALESCE(SUM(CASE WHEN "FLAG" = 'ONLINEFees' THEN "Count" ELSE 0 END), 0) AS "ONLINEPAYMENTCOUNT",
        COALESCE(SUM(CASE WHEN "FLAG" = 'OFFLINEFees' THEN "Count" ELSE 0 END), 0) AS "OFFLINEPAYMENTCOUNT",
        COALESCE(SUM(CASE WHEN "FLAG" = 'PREAdmission' THEN "Count" ELSE 0 END), 0) AS "PREAdmission",
        COALESCE(SUM(CASE WHEN "FLAG" = 'INVENTORY' THEN "Count" ELSE 0 END), 0) AS "INVENTORY",
        COALESCE(SUM(CASE WHEN "FLAG" = 'MOBILEAPPUSERCOUNT' THEN "Count" ELSE 0 END), 0) AS "MOBILEAPPUSERCOUNT",
        COALESCE(SUM(CASE WHEN "FLAG" = 'examStudentCount' THEN "Count" ELSE 0 END), 0) AS "examStudentCount"
    FROM "CombinedData"
    GROUP BY "mi_id"
    ORDER BY "mi_id";

    RETURN QUERY
    SELECT 
        "mi"."MI_Name",
        "a"."mi_id",
        "a"."HRMS",
        "a"."Library",
        "a"."Admission",
        "a"."ONLINEPAYMENTCOUNT",
        "a"."OFFLINEPAYMENTCOUNT",
        "a"."PREAdmission",
        "a"."INVENTORY",
        "a"."MOBILEAPPUSERCOUNT",
        "a"."examStudentCount"
    FROM "temp_Totalcount" "a"
    INNER JOIN "Master_Institution" "mi" ON "mi"."MI_Id" = "a"."mi_id"
    WHERE "mi"."MI_SchoolCollegeFlag" = 'S';

END;
$$;