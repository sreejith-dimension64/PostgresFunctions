CREATE OR REPLACE FUNCTION "dbo"."Adm_View_Periodwise_Attendance_Details"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_HRME_Id TEXT,
    p_Date VARCHAR(10),
    p_att_entry_type TEXT
)
RETURNS TABLE(
    "ASA_Id" BIGINT,
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASA_FROMDATE" VARCHAR,
    "ASA_Entry_DateTime" VARCHAR,
    "ASA_fROMDATETemp" TIMESTAMP,
    "EMPLOYEENAME" TEXT,
    "ISMS_SUBJECTNAME" VARCHAR,
    "TTMP_PeriodName" VARCHAR,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "DELETE_FLAG" INTEGER,
    "TotalCount" BIGINT,
    "PresentCount" BIGINT,
    "AbsentCount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "ASA"."ASA_Id",
        "MY"."ASMAY_Year",
        "MC"."ASMCL_ClassName",
        "MS"."ASMC_SectionName",
        TO_CHAR("ASA"."ASA_fROMDATE", 'DD/MM/YYYY') AS "ASA_FROMDATE",
        TO_CHAR("ASA"."ASA_Entry_DateTime", 'DD/MM/YYYY') AS "ASA_Entry_DateTime",
        "ASA"."ASA_fROMDATE" AS "ASA_fROMDATETemp",
        COALESCE("HRME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeLastName", '') AS "EMPLOYEENAME",
        "IMS"."ISMS_SUBJECTNAME",
        "TTMP"."TTMP_PeriodName",
        "MC"."ASMCL_Order",
        "MS"."ASMC_Order",
        CASE WHEN "ASA"."HRME_Id" = p_HRME_Id THEN 1 ELSE 0 END AS "DELETE_FLAG",
        COUNT("ASAS"."ASA_Class_Attended") AS "TotalCount",
        SUM(CASE WHEN "ASAS"."ASA_Class_Attended" = 1 THEN 1 ELSE 0 END) AS "PresentCount",
        SUM(CASE WHEN "ASAS"."ASA_Class_Attended" = 0 THEN 1 ELSE 0 END) AS "AbsentCount"
    FROM "dbo"."Adm_Student_Attendance" "ASA"
    INNER JOIN "dbo"."Adm_Student_Attendance_Students" "ASAS" ON "ASA"."ASA_Id" = "ASAS"."ASA_Id"
    INNER JOIN "dbo"."Adm_Student_Attendance_Periodwise" "ASAP" ON "ASAP"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "dbo"."Adm_Student_Attendance_Subjects" "ASASU" ON "ASASU"."ASA_Id" = "ASA"."ASA_Id"
    INNER JOIN "dbo"."IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASASU"."ISMS_Id"
    INNER JOIN "dbo"."TT_Master_Period" "TTMP" ON "TTMP"."TTMP_Id" = "ASAP"."TTMP_Id"
    INNER JOIN "dbo"."HR_Master_Employee" "HRME" ON "HRME"."HRME_Id" = "ASA"."HRME_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" "MC" ON "MC"."ASMCL_Id" = "ASA"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" "MS" ON "MS"."ASMS_Id" = "ASA"."ASMS_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" "MY" ON "MY"."ASMAY_Id" = "ASA"."ASMAY_Id"
    WHERE "ASA"."MI_Id" = p_MI_Id 
        AND "ASA"."ASMAY_Id" = p_ASMAY_Id 
        AND "ASA"."ASMCL_Id" = p_ASMCL_Id 
        AND "ASA"."ASMS_Id" = p_ASMS_Id
        AND CAST("ASA"."ASA_FROMDATE" AS DATE) <= CAST(p_Date AS DATE) 
        AND "ASA"."ASA_Activeflag" = 1
    GROUP BY 
        "ASA"."ASA_Id",
        "MY"."ASMAY_Year",
        "MC"."ASMCL_ClassName",
        "MS"."ASMC_SectionName",
        "ASA"."ASA_FROMDATE",
        "ASA"."ASA_Entry_DateTime",
        COALESCE("HRME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeLastName", ''),
        "IMS"."ISMS_SUBJECTNAME",
        "TTMP"."TTMP_PeriodName",
        "MC"."ASMCL_Order",
        "MS"."ASMC_Order",
        "ASA"."HRME_Id"
    ORDER BY 
        "MC"."ASMCL_Order",
        "MS"."ASMC_Order",
        "TTMP"."TTMP_PeriodName",
        "ASA"."ASA_FROMDATE";

END;
$$;