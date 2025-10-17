CREATE OR REPLACE FUNCTION "dbo"."Get_staff_tt_workload" (@mi_id bigint)
RETURNS TABLE (
    "EmployeeName" varchar,
    "ClassName" varchar,
    "SectionName" varchar,
    "SubjectName" varchar,
    "TotalPeriods" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        (h."HRME_EmployeeFirstName") as "EmployeeName",
        c."ASMCL_ClassName" as "ClassName",
        g."ASMC_SectionName" as "SectionName",
        i."ISMS_SubjectName" as "SubjectName",
        SUM(b."TTFPD_TotalPeriods") as "TotalPeriods"
    FROM "HR_Master_Employee" h 
    INNER JOIN "TT_Final_Period_Distribution" a ON h."HRME_Id" = a."HRME_Id" 
    INNER JOIN "TT_Final_Period_Distribution_Detailed" b ON a."TTFPD_Id" = b."TTFPD_Id"
    INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = b."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = b."ASMS_Id"
    INNER JOIN "IVRM_Master_Subjects" i ON i."ISMS_Id" = b."ISMS_Id"
    WHERE h."MI_Id" = @mi_id 
    GROUP BY h."HRME_EmployeeFirstName", c."ASMCL_ClassName", g."ASMC_SectionName", i."ISMS_SubjectName";
END;
$$;