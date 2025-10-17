CREATE OR REPLACE FUNCTION "dbo"."FO_EMPLOYEEINOUT"(
    "@MI_Id" TEXT,
    "@HRME_ID" TEXT,
    "@fromdate" VARCHAR(10),
    "@todate" VARCHAR(10)
)
RETURNS TABLE(
    "ecode" VARCHAR,
    "hrmE_Id" BIGINT,
    "ename" VARCHAR,
    "foeP_PunchDate" DATE,
    "foepD_PunchTime" TEXT,
    "foepD_InOutFlg" TEXT,
    "hrmdeS_DesignationName" VARCHAR,
    "HRME_EmployeeOrder" INTEGER,
    "HRMGT_EmployeeGroupType" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH "Dates" AS (
        SELECT CAST("@fromdate" AS DATE) AS "DateValue"
        UNION ALL
        SELECT "DateValue" + INTERVAL '1 day' 
        FROM "Dates" 
        WHERE "DateValue" < CAST("@todate" AS DATE)
    )
    SELECT 
        c."HRME_EmployeeCode" AS "ecode",
        c."HRME_Id" AS "hrmE_Id",
        c."HRME_EmployeeFirstName" AS "ename", 
        dates."DateValue" AS "foeP_PunchDate",
        COALESCE(a."FOEPD_PunchTime", 'L') AS "foepD_PunchTime",
        COALESCE(a."FOEPD_InOutFlg", 'I') AS "foepD_InOutFlg",
        d."HRMDES_DesignationName" AS "hrmdeS_DesignationName",
        c."HRME_EmployeeOrder",
        E."HRMGT_EmployeeGroupType"  
    FROM 
        "Dates" dates
    CROSS JOIN "HR_Master_Employee" C
    LEFT JOIN "fo"."FO_Emp_Punch" B ON B."HRME_Id" = c."HRME_Id" AND dates."DateValue" = CAST(B."FOEP_PunchDate" AS DATE)
    LEFT JOIN "fo"."FO_Emp_Punch_Details" A ON B."FOEP_Id" = A."FOEP_Id"  
    INNER JOIN "HR_Master_Designation" D ON D."HRMDES_Id" = C."HRMDES_Id"   
    INNER JOIN "HR_Master_GroupType" E ON E."HRMGT_Id" = C."HRMGT_Id" 
    WHERE c."MI_Id" = "@MI_Id"  
    AND c."HRME_Id"::TEXT IN (SELECT UNNEST(STRING_TO_ARRAY("@HRME_ID", ',')))
    AND c."MI_Id" = "@MI_Id" 
    AND c."HRME_ActiveFlag" = 1 
    AND c."HRME_LeftFlag" = 0 
    AND (c."HRME_BiometricCode" IS NOT NULL AND c."HRME_BiometricCode" != '')
    ORDER BY C."HRMGT_Id", C."HRME_EmployeeFirstName", dates."DateValue";
    
    RETURN;
END;
$$;