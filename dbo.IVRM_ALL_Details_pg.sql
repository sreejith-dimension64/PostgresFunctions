CREATE OR REPLACE FUNCTION dbo."IVRM_ALL_Details"(
    p_MICode VARCHAR(255)
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR(255),
    "MI_Name" VARCHAR,
    "TotalAdmissionThisYear" BIGINT,
    "TotalPreAdmissionThisYear" BIGINT,
    "TodayFeeCollection" NUMERIC,
    "TotalEmployee" BIGINT,
    "TodayPresentEmployee" BIGINT,
    "TodayEmployeeAbsent" BIGINT,
    "TodayIssueBook" BIGINT,
    "TodayReturnBook" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_MI_ID BIGINT;
    v_ASMAY_Id BIGINT;
    v_ASMAY_Year VARCHAR(255);
    v_Today DATE := CURRENT_DATE;
BEGIN
    
    DROP TABLE IF EXISTS temp_MI;
    DROP TABLE IF EXISTS temp_HRMS;
    DROP TABLE IF EXISTS temp_Fee;
    DROP TABLE IF EXISTS temp_LIB;
    DROP TABLE IF EXISTS temp_ADM;
    DROP TABLE IF EXISTS temp_PRE;

    -----------Master_Institution-----------
    SELECT "MI_ID" INTO v_MI_ID 
    FROM "Master_Institution" 
    WHERE "MI_Subdomain" = p_MICode 
    LIMIT 1;

    -----------Year-----------
    SELECT "ASMAY_Id", "ASMAY_Year" INTO v_ASMAY_Id, v_ASMAY_Year
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = v_MI_ID  
    AND CURRENT_TIMESTAMP BETWEEN "ASMAY_FROM_Date" AND "ASMAY_To_Date"
    LIMIT 1;

    -----------HRMS-----------
    CREATE TEMP TABLE temp_HRMS AS
    SELECT COUNT(E."HRME_Id") AS "TotalEmp", COUNT(P."FOEP_Id") AS "TodayP", E."MI_ID"
    FROM "HR_Master_Employee" E
    LEFT JOIN fo."FO_Emp_Punch" P ON P."HRME_ID" = E."HRME_ID" AND CAST(P."FOEP_PunchDate" AS DATE) = v_Today
    WHERE E."MI_ID" = v_MI_ID AND E."HRME_Activeflag" = 1 AND E."HRME_LeftFlag" = 0
    GROUP BY E."MI_ID";

    -----------Fee-----------
    CREATE TEMP TABLE temp_Fee AS
    SELECT SUM("FYP_Tot_Amount") AS "FYP_Tot_Amount", "MI_ID"
    FROM "Fee_Y_Payment"  
    WHERE "MI_ID" = v_MI_ID AND CAST("CreatedDate" AS DATE) = v_Today
    GROUP BY "MI_ID";

    -----------LIB_Book_Transaction-----------
    CREATE TEMP TABLE temp_LIB AS
    SELECT COUNT("LBTR_Status") AS "LIB_Count", "LBTR_Status", "MI_ID"
    FROM "LIB"."LIB_Book_Transaction" 
    WHERE "MI_ID" = v_MI_ID AND CAST("LBTR_IssuedDate" AS DATE) = v_Today
    GROUP BY "LBTR_Status", "MI_ID";

    -----------ADMISSION----------- 
    CREATE TEMP TABLE temp_ADM AS
    SELECT COUNT("AMST_ID") AS "ADMISSION", "MI_ID"
    FROM "Adm_M_Student"  
    WHERE "MI_ID" = v_MI_ID
    AND "ASMAY_Id" = v_ASMAY_Id
    AND "AMST_Activeflag" = 1
    GROUP BY "MI_ID";

    -----------PRE ADMISSION----------- 
    CREATE TEMP TABLE temp_PRE AS
    SELECT COUNT("PASR_ID") AS "PREADMISSION", "MI_ID"
    FROM "Preadmission_School_Registration"  
    WHERE "MI_ID" = v_MI_ID
    AND "ASMAY_Id" = v_ASMAY_Id
    AND "PASR_Adm_Confirm_Flag" <> 1
    GROUP BY "MI_ID";

    -----------ALL-----------
    RETURN QUERY
    SELECT
        v_ASMAY_Year,
        MI."MI_Name",
        COALESCE(ADM."ADMISSION", 0) AS "TotalAdmissionThisYear",
        COALESCE(PRE."PREADMISSION", 0) AS "TotalPreAdmissionThisYear",
        COALESCE(Fee."FYP_Tot_Amount", 0) AS "TodayFeeCollection",
        COALESCE(HRMS."TotalEmp", 0) AS "TotalEmployee",
        COALESCE(HRMS."TodayP", 0) AS "TodayPresentEmployee",
        COALESCE((HRMS."TotalEmp" - HRMS."TodayP"), 0) AS "TodayEmployeeAbsent",
        COALESCE(CASE WHEN LIB."LBTR_Status" = 'Issue' THEN LIB."LIB_Count" ELSE 0 END, 0) AS "TodayIssueBook",
        COALESCE(CASE WHEN LIB."LBTR_Status" = 'Return' THEN LIB."LIB_Count" ELSE 0 END, 0) AS "TodayReturnBook"
    FROM "Master_Institution" MI
    LEFT JOIN temp_ADM ADM ON ADM."MI_ID" = MI."MI_Id"
    LEFT JOIN temp_PRE PRE ON PRE."MI_ID" = MI."MI_Id"
    LEFT JOIN temp_Fee Fee ON Fee."MI_ID" = MI."MI_Id"
    LEFT JOIN temp_HRMS HRMS ON HRMS."MI_ID" = MI."MI_Id"
    LEFT JOIN temp_LIB LIB ON LIB."MI_ID" = MI."MI_Id"
    WHERE MI."MI_ID" = v_MI_ID;

    DROP TABLE IF EXISTS temp_MI;
    DROP TABLE IF EXISTS temp_HRMS;
    DROP TABLE IF EXISTS temp_Fee;
    DROP TABLE IF EXISTS temp_LIB;
    DROP TABLE IF EXISTS temp_ADM;
    DROP TABLE IF EXISTS temp_PRE;

END;
$$;