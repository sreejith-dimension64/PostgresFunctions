CREATE OR REPLACE FUNCTION "dbo"."GET_DEPUTATION_NOTIFICATION_MSG"
(
    p_MI_Id bigint,
    p_TTSD_Id bigint,
    p_TYPE varchar(10)
)
RETURNS TABLE
(
    msg TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_TYPE = 'A' THEN
        RETURN QUERY
        SELECT ('Dear ' || "AbsentStaff" || ',' || ' your ' || "TTMP_PeriodName" || ' period of ' || "ASMCL_ClassName" || '-' || "ASMC_SectionName" || ' has been deputed to ' || "DeptStaff" || ' on ' || TO_CHAR(CAST("TTSD_Date" AS date), 'YYYY-MM-DD'))::TEXT AS msg
        FROM
        (
            SELECT 
                (SELECT b."HRME_EmployeeFirstName" || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(b."HRME_EmployeeLastName", '') 
                 FROM "HR_Master_Employee" b 
                 WHERE b."HRME_Id" = A."TTSD_AbsentStaff") AS "AbsentStaff",
                (SELECT c."HRME_EmployeeFirstName" || ' ' || COALESCE(c."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(c."HRME_EmployeeLastName", '') 
                 FROM "HR_Master_Employee" c 
                 WHERE c."HRME_Id" = A."TTSD_DeputedStaff") AS "DeptStaff",
                b."ASMCL_ClassName",
                c."ASMC_SectionName",
                MD."TTMD_DayName",
                MP."TTMP_PeriodName",
                A."TTSD_Date",
                A."TTSD_Remarks"
            FROM "TT_Staff_Deputation" AS A
            INNER JOIN "Adm_School_M_Class" b ON A."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" c ON A."ASMS_Id" = c."ASMS_Id"
            INNER JOIN "TT_Master_Day" MD ON MD."TTMD_Id" = A."TTMD_Id"
            INNER JOIN "TT_Master_Period" MP ON MP."TTMP_Id" = A."TTMP_Id"
            WHERE A."MI_Id" = p_MI_Id AND A."TTSD_Id" = p_TTSD_Id
        ) AS new;
    ELSIF p_TYPE = 'P' THEN
        RETURN QUERY
        SELECT ('Dear ' || "DeptStaff" || ' you have been deputed for ' || "ASMCL_ClassName" || '-' || "ASMC_SectionName" || ' in the place of ' || "AbsentStaff" || ' on ' || TO_CHAR(CAST("TTSD_Date" AS date), 'YYYY-MM-DD') || ' period ' || "TTMP_PeriodName")::TEXT AS msg
        FROM
        (
            SELECT 
                (SELECT b."HRME_EmployeeFirstName" || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(b."HRME_EmployeeLastName", '') 
                 FROM "HR_Master_Employee" b 
                 WHERE b."HRME_Id" = A."TTSD_AbsentStaff") AS "AbsentStaff",
                (SELECT c."HRME_EmployeeFirstName" || ' ' || COALESCE(c."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(c."HRME_EmployeeLastName", '') 
                 FROM "HR_Master_Employee" c 
                 WHERE c."HRME_Id" = A."TTSD_DeputedStaff") AS "DeptStaff",
                b."ASMCL_ClassName",
                c."ASMC_SectionName",
                MD."TTMD_DayName",
                MP."TTMP_PeriodName",
                A."TTSD_Date",
                A."TTSD_Remarks"
            FROM "TT_Staff_Deputation" AS A
            INNER JOIN "Adm_School_M_Class" b ON A."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" c ON A."ASMS_Id" = c."ASMS_Id"
            INNER JOIN "TT_Master_Day" MD ON MD."TTMD_Id" = A."TTMD_Id"
            INNER JOIN "TT_Master_Period" MP ON MP."TTMP_Id" = A."TTMP_Id"
            WHERE A."MI_Id" = p_MI_Id AND A."TTSD_Id" = p_TTSD_Id
        ) AS new;
    END IF;
    
    RETURN;
END;
$$;