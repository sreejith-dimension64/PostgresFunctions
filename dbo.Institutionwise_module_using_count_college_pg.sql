CREATE OR REPLACE FUNCTION "dbo"."Institutionwise_module_using_count_college"()
RETURNS TABLE(
    "MI_Name" VARCHAR,
    "mi_id" BIGINT,
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
    INNER JOIN "hr_employee_salary" "P" ON "P"."HRME_ID" = "E"."HRME_ID" AND "HRES_Year" = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    WHERE "E"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
    AND "HRME_Activeflag" = 1 AND "HRME_LeftFlag" = 0
    GROUP BY "E"."MI_ID";

    DROP TABLE IF EXISTS "temp_ONLINEFee";
    
    CREATE TEMP TABLE "temp_ONLINEFee" AS
    SELECT "MI_ID",
    CASE WHEN "FYP_TransactionTypeFlag" = 'O' THEN COUNT("AMCST_Id") ELSE 0 END AS "ONLINEPAYMENTCOUNT",
    'ONLINEFees' AS "Flag"
    FROM "clg"."Fee_Y_Payment" "FYP"
    INNER JOIN "clg"."Fee_Y_Payment_College_Student" "FYPSS" ON "FYPSS"."FYP_Id" = "FYP"."FYP_Id"
    WHERE "MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1)
    AND EXTRACT(YEAR FROM "FYP_ReceiptDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    AND "FYP"."ASMAY_Id" IN (
        SELECT "ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
        AND CURRENT_TIMESTAMP BETWEEN "ASMAY_FROM_Date" AND "ASMAY_To_Date"
    )
    AND "FYP_TransactionTypeFlag" = 'O'
    GROUP BY "MI_ID", "FYP_TransactionTypeFlag";

    DROP TABLE IF EXISTS "temp_OFFLINEFee";
    
    CREATE TEMP TABLE "temp_OFFLINEFee" AS
    SELECT "MI_ID",
    CASE WHEN "FYP_TransactionTypeFlag" != 'O' THEN COUNT("AMCST_Id") ELSE 0 END AS "OFFLINEPAYMENTCOUNT",
    'OFFLINEFees' AS "Flag"
    FROM "clg"."Fee_Y_Payment" "FYP"
    INNER JOIN "clg"."Fee_Y_Payment_College_Student" "FYPSS" ON "FYPSS"."FYP_Id" = "FYP"."FYP_Id"
    WHERE "MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1)
    AND EXTRACT(YEAR FROM "FYP_ReceiptDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    AND "FYP"."ASMAY_Id" IN (
        SELECT "ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
        AND CURRENT_TIMESTAMP BETWEEN "ASMAY_FROM_Date" AND "ASMAY_To_Date"
    )
    AND "FYP_TransactionTypeFlag" != 'O'
    GROUP BY "MI_ID", "FYP_TransactionTypeFlag";

    DROP TABLE IF EXISTS "temp_OFFLINEFee1";
    
    CREATE TEMP TABLE "temp_OFFLINEFee1" AS
    SELECT "MI_ID", SUM("OFFLINEPAYMENTCOUNT") AS "OFFLINEPAYMENTCOUNT", "Flag"
    FROM "temp_OFFLINEFee"
    GROUP BY "MI_ID", "Flag";

    DROP TABLE IF EXISTS "temp_LIB";
    
    CREATE TEMP TABLE "temp_LIB" AS
    SELECT "MI_ID", COUNT("LBTR_Status") AS "LIB_Count", 'Library' AS "Flag"
    FROM "LIB"."LIB_Book_Transaction"
    WHERE "MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
    AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    GROUP BY "MI_ID";

    DROP TABLE IF EXISTS "temp_ADM";
    
    CREATE TEMP TABLE "temp_ADM" AS
    SELECT "MI_ID", COUNT("AMCST_ID") AS "ADMISSION", 'Admission' AS "Flag"
    FROM "clg"."Adm_Master_College_Student"
    WHERE "MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
        AND CURRENT_TIMESTAMP BETWEEN "ASMAY_FROM_Date" AND "ASMAY_To_Date"
    )
    AND "AMCST_Activeflag" = 1
    GROUP BY "MI_ID";

    DROP TABLE IF EXISTS "temp_PRE";
    
    CREATE TEMP TABLE "temp_PRE" AS
    SELECT "MI_ID", COUNT("PACA_Id") AS "PREADMISSION", 'PREAdmission' AS "Flag"
    FROM "clg"."PA_College_Application"
    WHERE "MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
        AND CURRENT_TIMESTAMP BETWEEN "ASMAY_FROM_Date" AND "ASMAY_To_Date"
    )
    AND "PACA_Statusremark" = 'confirm'
    GROUP BY "MI_Id";

    DROP TABLE IF EXISTS "temp_INVENTORY";
    
    CREATE TEMP TABLE "temp_INVENTORY" AS
    SELECT "MI_Id", COUNT("INVMSL_Id") AS "INVENTORYCOUNT", 'INVENTORY' AS "FLAG"
    FROM "INV"."INV_M_Sales"
    WHERE "MI_Id" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
    AND EXTRACT(YEAR FROM "INVMSL_SalesDate") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    GROUP BY "MI_Id";

    DROP TABLE IF EXISTS "temp_MOBILEAPP";
    
    CREATE TEMP TABLE "temp_MOBILEAPP" AS
    SELECT "a"."MI_Id", COUNT(DISTINCT "a"."IVRMUL_Id") AS "MOBILEAPPCOUNT", 'MOBILEAPPUSERCOUNT' AS "FLAG"
    FROM "IVRM_MobileApp_LoginDetails" "a"
    INNER JOIN "Master_Institution" "b" ON "b"."MI_Id" = "a"."MI_Id"
    WHERE "IVRMMALD_logintype" = 'Mobile' AND EXTRACT(YEAR FROM "IVRMMALD_DateTime") = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
    AND "MI_SchoolCollegeFlag" = 'C'
    GROUP BY "a"."MI_Id";

    DROP TABLE IF EXISTS "temp_Exam";
    
    CREATE TEMP TABLE "temp_Exam" AS
    SELECT "MI_Id", COUNT("AMCST_Id") AS "Examcount", 'examStudentCount' AS "Flag"
    FROM "clg"."Exm_Col_Student_Marks"
    WHERE "MI_Id" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id"
        FROM "Adm_School_M_Academic_Year" "AY"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "AY"."MI_Id"
        WHERE "AY"."MI_ID" IN (SELECT "MI_ID" FROM "Master_Institution" WHERE "MI_ActiveFlag" = 1 AND "MI_SchoolCollegeFlag" = 'C')
        AND CURRENT_TIMESTAMP BETWEEN "ASMAY_FROM_Date" AND "ASMAY_To_Date"
    )
    GROUP BY "MI_Id";

    DROP TABLE IF EXISTS "temp_Totalcount";
    
    CREATE TEMP TABLE "temp_Totalcount" AS
    SELECT 
        "mi_id",
        COALESCE(MAX(CASE WHEN "FLAG" = 'HRMS_Salary' THEN "Count" END), 0) AS "HRMS",
        COALESCE(MAX(CASE WHEN "FLAG" = 'Library' THEN "Count" END), 0) AS "Library",
        COALESCE(MAX(CASE WHEN "FLAG" = 'Admission' THEN "Count" END), 0) AS "Admission",
        COALESCE(MAX(CASE WHEN "FLAG" = 'ONLINEFees' THEN "Count" END), 0) AS "ONLINEPAYMENTCOUNT",
        COALESCE(MAX(CASE WHEN "FLAG" = 'OFFLINEFees' THEN "Count" END), 0) AS "OFFLINEPAYMENTCOUNT",
        COALESCE(MAX(CASE WHEN "FLAG" = 'PREAdmission' THEN "Count" END), 0) AS "PREAdmission",
        COALESCE(MAX(CASE WHEN "FLAG" = 'INVENTORY' THEN "Count" END), 0) AS "INVENTORY",
        COALESCE(MAX(CASE WHEN "FLAG" = 'MOBILEAPPUSERCOUNT' THEN "Count" END), 0) AS "MOBILEAPPUSERCOUNT",
        COALESCE(MAX(CASE WHEN "FLAG" = 'examStudentCount' THEN "Count" END), 0) AS "examStudentCount"
    FROM (
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
    ) "CombinedData"
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
    WHERE "MI_SchoolCollegeFlag" = 'C';

END;
$$;