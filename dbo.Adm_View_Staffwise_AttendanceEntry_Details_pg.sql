CREATE OR REPLACE FUNCTION "dbo"."Adm_View_Staffwise_AttendanceEntry_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@HRME_Id" TEXT,
    "@Date" VARCHAR(10),
    "@att_entry_type" TEXT
)
RETURNS TABLE(
    "ASA_Id" INTEGER,
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASA_FROMDATE" VARCHAR,
    "ASA_Entry_DateTime" VARCHAR,
    "EMPLOYEENAME" TEXT,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "ASA_fROMDATETemp" TIMESTAMP,
    "DELETE_FLAG" INTEGER
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
        COALESCE("HRME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRME"."HRME_EmployeeLastName", '') AS "EMPLOYEENAME",
        "MC"."ASMCL_Order",
        "MS"."ASMC_Order",
        "ASA"."ASA_fROMDATE" AS "ASA_fROMDATETemp",
        CASE WHEN "ASA"."HRME_Id" = "@HRME_Id" THEN 1 ELSE 0 END AS "DELETE_FLAG"
    FROM "Adm_Student_Attendance" "ASA"
    INNER JOIN "Adm_Student_Attendance_Students" "ASAS" ON "ASA"."ASA_Id" = "ASAS"."ASA_Id"
    INNER JOIN "HR_Master_Employee" "HRME" ON "HRME"."HRME_Id" = "ASA"."HRME_Id"
    INNER JOIN "Adm_School_M_Class" "MC" ON "MC"."ASMCL_Id" = "ASA"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" "MS" ON "MS"."ASMS_Id" = "ASA"."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "MY" ON "MY"."ASMAY_Id" = "ASA"."ASMAY_Id"
    WHERE "ASA"."MI_Id" = "@MI_Id" 
        AND "ASA"."ASMAY_Id" = "@ASMAY_Id" 
        AND "ASA"."ASMCL_Id" = "@ASMCL_Id" 
        AND "ASA"."ASMS_Id" = "@ASMS_Id"
        AND CAST("ASA"."ASA_FROMDATE" AS DATE) <= CAST("@Date" AS DATE)
        AND "ASA"."ASA_Activeflag" = 1 
        AND "ASA"."ASA_Att_Type" != 'period'
    ORDER BY "MC"."ASMCL_Order", "MS"."ASMC_Order", "ASA"."ASA_fROMDATE";
END;
$$;