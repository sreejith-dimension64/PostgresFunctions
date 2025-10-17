CREATE OR REPLACE FUNCTION "dbo"."GET_DEPUTATION_NOTIFICATION_MSG_COLLAGE"(
    "p_MI_Id" bigint,
    "p_TTSD_Id" bigint,
    "p_TYPE" varchar(10)
)
RETURNS TABLE("msg" text)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "p_TYPE" = 'A' THEN
        RETURN QUERY
        SELECT DISTINCT 
            ('Dear ' || "AbsentStaff" || ',' || ' your ' || "TTMP_PeriodName" || ' period of ' || 
             "AMCO_CourseName" || '-' || "AMB_BranchName" || '-' || "AMSE_SEMName" || '-' || 
             "ACMS_SectionName" || ' has been deputed to ' || "DeptStaff" || ' on ' || 
             TO_CHAR(CAST("TTSDC_Date" AS date), 'YYYY-MM-DD'))::text AS "msg"
        FROM (
            SELECT  
                (SELECT b."HRME_EmployeeFirstName" || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || 
                        COALESCE(b."HRME_EmployeeLastName", '') 
                 FROM "HR_Master_Employee" b 
                 WHERE b."HRME_Id" = A."TTSDC_AbsentStaff") AS "AbsentStaff",
                (SELECT c."HRME_EmployeeFirstName" || ' ' || COALESCE(c."HRME_EmployeeMiddleName", '') || ' ' || 
                        COALESCE(c."HRME_EmployeeLastName", '') 
                 FROM "HR_Master_Employee" c 
                 WHERE c."HRME_Id" = A."TTSDC_DeputedStaff") AS "DeptStaff",
                b."AMCO_CourseName",
                c."AMB_BranchName",
                d."AMSE_SEMName",
                e."ACMS_SectionName",
                MD."TTMD_DayName",
                MP."TTMP_PeriodName",
                A."TTSDC_Date",
                A."TTSDC_Remarks"
            FROM "TT_Staff_Deputation_College" AS A
            INNER JOIN "CLG"."Adm_Master_Course" b ON A."AMCO_Id" = b."AMCO_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" c ON A."AMB_Id" = c."AMB_Id"
            INNER JOIN "CLG"."Adm_Master_Semester" d ON A."AMSE_Id" = d."AMSE_Id"
            INNER JOIN "CLG"."Adm_College_Master_Section" e ON e."ACMS_Id" = e."ACMS_Id"
            INNER JOIN "TT_Master_Day" MD ON MD."TTMD_Id" = A."TTMD_Id"
            INNER JOIN "TT_Master_Period" MP ON MP."TTMP_Id" = A."TTMP_Id"
            WHERE A."MI_Id" = "p_MI_Id" AND A."TTSDC_Id" = "p_TTSD_Id"
        ) AS "new"
        LIMIT 1;
        
    ELSIF "p_TYPE" = 'P' THEN
        RETURN QUERY
        SELECT DISTINCT 
            ('Dear ' || "DeptStaff" || ' you have been deputed for ' || "AMCO_CourseName" || '-' || 
             "AMB_BranchName" || '-' || "AMSE_SEMName" || '-' || "ACMS_SectionName" || 
             ' in the place of ' || "AbsentStaff" || ' on ' || 
             TO_CHAR(CAST("TTSDC_Date" AS date), 'YYYY-MM-DD') || ' period ' || "TTMP_PeriodName")::text AS "msg"
        FROM (
            SELECT  
                (SELECT b."HRME_EmployeeFirstName" || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || 
                        COALESCE(b."HRME_EmployeeLastName", '') 
                 FROM "HR_Master_Employee" b 
                 WHERE b."HRME_Id" = A."TTSDC_AbsentStaff") AS "AbsentStaff",
                (SELECT c."HRME_EmployeeFirstName" || ' ' || COALESCE(c."HRME_EmployeeMiddleName", '') || ' ' || 
                        COALESCE(c."HRME_EmployeeLastName", '') 
                 FROM "HR_Master_Employee" c 
                 WHERE c."HRME_Id" = A."TTSDC_DeputedStaff") AS "DeptStaff",
                b."AMCO_CourseName",
                c."AMB_BranchName",
                d."AMSE_SEMName",
                e."ACMS_SectionName",
                MD."TTMD_DayName",
                MP."TTMP_PeriodName",
                A."TTSDC_Date",
                A."TTSDC_Remarks"
            FROM "TT_Staff_Deputation_College" AS A
            INNER JOIN "CLG"."Adm_Master_Course" b ON A."AMCO_Id" = b."AMCO_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" c ON A."AMB_Id" = c."AMB_Id"
            INNER JOIN "CLG"."Adm_Master_Semester" d ON A."AMSE_Id" = d."AMSE_Id"
            INNER JOIN "CLG"."Adm_College_Master_Section" e ON e."ACMS_Id" = e."ACMS_Id"
            INNER JOIN "TT_Master_Day" MD ON MD."TTMD_Id" = A."TTMD_Id"
            INNER JOIN "TT_Master_Period" MP ON MP."TTMP_Id" = A."TTMP_Id"
            WHERE A."MI_Id" = "p_MI_Id" AND A."TTSDC_Id" = "p_TTSD_Id"
        ) AS "new"
        LIMIT 1;
    END IF;
    
    RETURN;
END;
$$;