CREATE OR REPLACE FUNCTION "dbo"."HR_Levelwise_Leave_report"(p_HRELAP_ID BIGINT)
RETURNS TABLE(
    "IVRMSTAUL_UserName" VARCHAR,
    "SanctionLevelNo" BIGINT,
    "HRELAPA_LeaveStatus" VARCHAR,
    "HRELAPA_Remarks" TEXT,
    "HRELAPA_FromDate" TIMESTAMP,
    "HRELAPA_ToDate" TIMESTAMP,
    "HRELAPA_TotalDays" NUMERIC,
    "HRELAP_FromDate" TIMESTAMP,
    "HRELAP_ToDate" TIMESTAMP,
    "HRELAP_SupportingDocument" TEXT,
    "UpdatedDate" TIMESTAMP,
    "createdDate" TIMESTAMP
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRELAP_ApplicationStatus VARCHAR(500);
    v_HRML_LeaveCode VARCHAR(50);
    v_compoffrequestcount INT;
BEGIN

    SELECT "HRELAP_ApplicationStatus" INTO v_HRELAP_ApplicationStatus 
    FROM "HR_Emp_Leave_Application" 
    WHERE "HRELAP_ID" = p_HRELAP_ID;

    DROP TABLE IF EXISTS temp_LeaveTemp;
    DROP TABLE IF EXISTS temp_LeaveTemp1;
    DROP TABLE IF EXISTS temp_LeaveTemp2;
    DROP TABLE IF EXISTS temp_LeaveTemp3;
    DROP TABLE IF EXISTS temp_LeaveTemp4;
    DROP TABLE IF EXISTS temp_LeaveTemp5;
    DROP TABLE IF EXISTS temp_LeaveTemp6;
    DROP TABLE IF EXISTS temp_LeaveTemp7;

    SELECT COUNT(*) INTO v_compoffrequestcount
    FROM "HR_Emp_Leave_Application" a
    INNER JOIN "HR_Emp_Leave_Appl_Details" b ON a."HRELAP_Id" = b."HRELAP_Id"
    INNER JOIN "HR_Master_Leave" d ON b."HRML_Id" = d."HRML_Id"
    WHERE a."HRELAP_ID" = p_HRELAP_ID AND "HRELAPD_InTime" IS NOT NULL;

    IF (v_HRELAP_ApplicationStatus = 'Applied') THEN

        CREATE TEMP TABLE temp_LeaveTemp AS
        SELECT "HRME_EmployeeFirstName", b."HRML_Id", "HRMET_Id", "HRMGT_Id", "HRMD_Id", "HRMDES_Id", "HRMG_Id", 
               a."HRME_Id", 'Pending' AS "HRELAPA_LeaveStatus", a."HRELAP_Id", a."HRELAP_FromDate", a."HRELAP_ToDate", 
               a."HRELAP_SupportingDocument", b."HRELAPD_FromDate", b."HRELAPD_ToDate", b."HRELAPD_TotalDays"
        FROM "HR_Emp_Leave_Application" a
        INNER JOIN "HR_Emp_Leave_Appl_Details" b ON a."HRELAP_Id" = b."HRELAP_Id"
        INNER JOIN "HR_Master_Employee" c ON a."HRME_Id" = c."HRME_Id"
        INNER JOIN "HR_Master_Leave" d ON b."HRML_Id" = d."HRML_Id"
        WHERE "HRELAP_ApplicationStatus" = 'Applied' AND a."HRELAP_ID" = p_HRELAP_ID;

        RETURN QUERY
        SELECT DISTINCT b."IVRMSTAUL_UserName", a."HRLAON_SanctionLevelNo", d."HRELAPA_LeaveStatus", 
               e."HRELAPA_Remarks", d."HRELAPD_FromDate" AS "HRELAPA_FromDate", d."HRELAPD_ToDate" AS "HRELAPA_ToDate", 
               d."HRELAPD_TotalDays" AS "HRELAPA_TotalDays", d."HRELAP_FromDate", d."HRELAP_ToDate", 
               d."HRELAP_SupportingDocument", NULL::TIMESTAMP AS "UpdatedDate", NULL::TIMESTAMP AS "createdDate"
        FROM "HR_Leave_Auth_OrderNo" a
        LEFT JOIN "IVRM_Staff_User_Login" b ON b."Emp_Code" = a."IVRMUL_Id"
        INNER JOIN "HR_Leave_Authorisation" c ON a."HRLA_Id" = c."HRLA_Id"
        INNER JOIN temp_LeaveTemp d ON c."HRMD_Id" = d."HRMD_Id" AND c."HRMDES_Id" = d."HRMDES_Id" 
               AND c."HRMG_Id" = d."HRMG_Id" AND c."HRMGT_Id" = d."HRMGT_Id"
               AND c."HRML_Id" = d."HRML_Id" AND d."HRME_Id" = a."HRME_Id"
        LEFT JOIN "HR_Emp_Leave_Appl_Authorisation" e ON e."HRELAP_ID" = d."HRELAP_ID"
               AND a."IVRMUL_Id" = e."HRME_ID" AND e."HRELAPA_SanctioningLevel" = a."HRLAON_SanctionLevelNo" 
               AND e."hrml_id" = d."hrml_id"
        WHERE d."HRELAP_Id" = p_HRELAP_ID
        ORDER BY a."HRLAON_SanctionLevelNo";

    ELSIF (v_HRELAP_ApplicationStatus = 'Partial Approved') THEN

        CREATE TEMP TABLE temp_LeaveTemp1 AS
        SELECT "HRML_LeaveCode", "HRME_EmployeeFirstName", b."HRML_Id", "HRMET_Id", "HRMGT_Id", "HRMD_Id", 
               "HRMDES_Id", "HRMG_Id", a."HRME_Id", 'Partial Approved' AS "HRELAPA_LeaveStatus", a."HRELAP_Id", 
               a."HRELAP_FromDate", a."HRELAP_ToDate", a."HRELAP_SupportingDocument", b."HRELAPD_FromDate", 
               b."HRELAPD_ToDate", b."HRELAPD_TotalDays"
        FROM "HR_Emp_Leave_Application" a
        INNER JOIN "HR_Emp_Leave_Appl_Details" b ON a."HRELAP_Id" = b."HRELAP_Id"
        INNER JOIN "HR_Master_Employee" c ON a."HRME_Id" = c."HRME_Id"
        INNER JOIN "HR_Master_Leave" d ON b."HRML_Id" = d."HRML_Id"
        WHERE "HRELAP_ApplicationStatus" = 'Partial Approved' AND a."HRELAP_ID" = p_HRELAP_ID;

        SELECT "HRML_LeaveCode" INTO v_HRML_LeaveCode FROM temp_LeaveTemp1;

        IF ((v_HRML_LeaveCode = 'COMPOFF' OR v_HRML_LeaveCode = 'OD') AND v_compoffrequestcount > 0) THEN

            RETURN QUERY
            SELECT DISTINCT b."IVRMSTAUL_UserName", a."HRPAON_SanctionLevelNo", 
                   COALESCE(e."HRELAPA_LeaveStatus", 'Pending') AS "HRELAPA_LeaveStatus", e."HRELAPA_Remarks", 
                   d."HRELAPD_FromDate" AS "HRELAPA_FromDate", d."HRELAPD_ToDate" AS "HRELAPA_ToDate", 
                   d."HRELAPD_TotalDays" AS "HRELAPA_TotalDays", d."HRELAP_FromDate", d."HRELAP_ToDate", 
                   d."HRELAP_SupportingDocument", e."UpdatedDate", e."CreatedDate" AS "createdDate"
            FROM "HR_Process_Auth_OrderNo" a
            LEFT JOIN "IVRM_Staff_User_Login" b ON b."Id" = a."IVRMUL_Id"
            INNER JOIN "HR_Process_Authorisation" c ON a."HRPA_Id" = c."HRPA_Id"
            INNER JOIN temp_LeaveTemp1 d ON c."HRMD_Id" = d."HRMD_Id" AND c."HRMDES_Id" = d."HRMDES_Id" 
                   AND c."HRMG_Id" = d."HRMG_Id" AND c."HRMGT_Id" = d."HRMGT_Id"
            LEFT JOIN "HR_Emp_Leave_Appl_Authorisation" e ON e."HRELAP_ID" = d."HRELAP_ID" 
                   AND e."HRME_ID" = b."Emp_Code" AND e."HRELAPA_SanctioningLevel" = a."HRPAON_SanctionLevelNo"
            WHERE d."HRELAP_Id" = p_HRELAP_ID AND "HRPA_TypeFlag" = 'compoffODApproval'
            ORDER BY a."HRPAON_SanctionLevelNo";

        ELSE

            RETURN QUERY
            SELECT b."IVRMSTAUL_UserName", a."HRLAON_SanctionLevelNo", 
                   COALESCE(e."HRELAPA_LeaveStatus", 'Pending') AS "HRELAPA_LeaveStatus", 
                   COALESCE(e."HRELAPA_Remarks", '') AS "HRELAPA_Remarks", e."HRELAPA_FromDate", e."HRELAPA_ToDate", 
                   e."HRELAPA_TotalDays", d."HRELAP_FromDate", d."HRELAP_ToDate", d."HRELAP_SupportingDocument", 
                   e."UpdatedDate", e."CreatedDate" AS "createdDate"
            FROM "HR_Leave_Auth_OrderNo" a
            LEFT JOIN "IVRM_Staff_User_Login" b ON b."Emp_Code" = a."IVRMUL_Id"
            INNER JOIN "HR_Leave_Authorisation" c ON a."HRLA_Id" = c."HRLA_Id"
            INNER JOIN temp_LeaveTemp1 d ON c."HRMD_Id" = d."HRMD_Id" AND c."HRMDES_Id" = d."HRMDES_Id" 
                   AND c."HRMG_Id" = d."HRMG_Id" AND c."HRMGT_Id" = d."HRMGT_Id" AND c."HRML_Id" = d."HRML_Id"
            LEFT JOIN "HR_Emp_Leave_Appl_Authorisation" e ON e."HRELAP_ID" = d."HRELAP_ID" 
                   AND a."IVRMUL_Id" = e."HRME_ID" AND e."HRELAPA_SanctioningLevel" = a."HRLAON_SanctionLevelNo" 
                   AND e."hrml_id" = d."hrml_id"
            WHERE d."HRELAP_Id" = p_HRELAP_ID
            ORDER BY a."HRLAON_SanctionLevelNo";

        END IF;

    ELSIF (v_HRELAP_ApplicationStatus = 'Approved') THEN

        CREATE TEMP TABLE temp_LeaveTemp2 AS
        SELECT "HRML_LeaveCode", "HRME_EmployeeFirstName", b."HRML_Id", "HRMET_Id", "HRMGT_Id", "HRMD_Id", 
               "HRMDES_Id", "HRMG_Id", a."HRME_Id", 'Approved' AS "HRELAPA_LeaveStatus", a."HRELAP_Id", 
               a."HRELAP_FromDate", a."HRELAP_ToDate", a."HRELAP_SupportingDocument", b."HRELAPD_FromDate", 
               b."HRELAPD_ToDate", b."HRELAPD_TotalDays"
        FROM "HR_Emp_Leave_Application" a
        INNER JOIN "HR_Emp_Leave_Appl_Details" b ON a."HRELAP_Id" = b."HRELAP_Id"
        INNER JOIN "HR_Master_Employee" c ON a."HRME_Id" = c."HRME_Id"
        INNER JOIN "HR_Master_Leave" d ON b."HRML_Id" = d."HRML_Id"
        WHERE "HRELAP_ApplicationStatus" = 'Approved' AND a."HRELAP_ID" = p_HRELAP_ID;

        SELECT "HRML_LeaveCode" INTO v_HRML_LeaveCode FROM temp_LeaveTemp2;

        IF ((v_HRML_LeaveCode = 'COMPOFF' OR v_HRML_LeaveCode = 'OD') AND v_compoffrequestcount > 0) THEN

            RETURN QUERY
            SELECT DISTINCT b."IVRMSTAUL_UserName", a."HRPAON_SanctionLevelNo", 
                   COALESCE(e."HRELAPA_LeaveStatus", 'Approved') AS "HRELAPA_LeaveStatus", e."HRELAPA_Remarks", 
                   d."HRELAPD_FromDate" AS "HRELAPA_FromDate", d."HRELAPD_ToDate" AS "HRELAPA_ToDate", 
                   d."HRELAPD_TotalDays" AS "HRELAPA_TotalDays", d."HRELAP_FromDate", d."HRELAP_ToDate", 
                   d."HRELAP_SupportingDocument", e."UpdatedDate", e."CreatedDate" AS "createdDate"
            FROM "HR_Process_Auth_OrderNo" a
            LEFT JOIN "IVRM_Staff_User_Login" b ON b."Id" = a."IVRMUL_Id"
            INNER JOIN "HR_Process_Authorisation" c ON a."HRPA_Id" = c."HRPA_Id"
            INNER JOIN temp_LeaveTemp2 d ON c."HRMD_Id" = d."HRMD_Id" AND c."HRMDES_Id" = d."HRMDES_Id" 
                   AND c."HRMG_Id" = d."HRMG_Id" AND c."HRMGT_Id" = d."HRMGT_Id"
            LEFT JOIN "HR_Emp_Leave_Appl_Authorisation" e ON e."HRELAP_ID" = d."HRELAP_ID" 
                   AND b."Emp_Code" = e."HRME_ID" AND e."HRELAPA_SanctioningLevel" = a."HRPAON_SanctionLevelNo" 
                   AND e."hrml_id" = d."hrml_id"
            WHERE d."HRELAP_Id" = p_HRELAP_ID AND "HRPA_TypeFlag" = 'compoffODApproval'
            ORDER BY a."HRPAON_SanctionLevelNo";

        ELSE

            RETURN QUERY
            SELECT DISTINCT b."IVRMSTAUL_UserName", a."HRLAON_SanctionLevelNo", 
                   COALESCE(e."HRELAPA_LeaveStatus", 'Approved') AS "HRELAPA_LeaveStatus", e."HRELAPA_Remarks", 
                   e."HRELAPA_FromDate", e."HRELAPA_ToDate", e."HRELAPA_TotalDays", d."HRELAP_FromDate", 
                   d."HRELAP_ToDate", d."HRELAP_SupportingDocument", e."UpdatedDate", e."CreatedDate" AS "createdDate"
            FROM "HR_Leave_Auth_OrderNo" a
            LEFT JOIN "IVRM_Staff_User_Login" b ON b."Emp_Code" = a."IVRMUL_Id"
            INNER JOIN "HR_Leave_Authorisation" c ON a."HRLA_Id" = c."HRLA_Id"
            INNER JOIN temp_LeaveTemp2 d ON c."HRMD_Id" = d."HRMD_Id" AND c."HRMDES_Id" = d."HRMDES_Id" 
                   AND c."HRMG_Id" = d."HRMG_Id" AND c."HRMGT_Id" = d."HRMGT_Id" AND c."HRML_Id" = d."HRML_Id"
            LEFT JOIN "HR_Emp_Leave_Appl_Authorisation" e ON e."HRELAP_ID" = d."HRELAP_ID" 
                   AND a."IVRMUL_Id" = e."HRME_ID" AND e."HRELAPA_SanctioningLevel" = a."HRLAON_SanctionLevelNo" 
                   AND e."hrml_id" = d."hrml_id"
            WHERE d."HRELAP_Id" = p_HRELAP_ID
            ORDER BY a."HRLAON_SanctionLevelNo";

        END IF;

    ELSIF (v_HRELAP_ApplicationStatus = 'Rejected') THEN

        RETURN QUERY
        SELECT b."IVRMSTAUL_UserName", a."HRELAPA_SanctioningLevel"::BIGINT, a."HRELAPA_LeaveStatus", 
               a."HRELAPA_Remarks", NULL::TIMESTAMP AS "HRELAPA_FromDate", NULL::TIMESTAMP AS "HRELAPA_ToDate", 
               c."HRELAPD_TotalDays", c."HRELAPD_FromDate" AS "HRELAP_FromDate", 
               c."HRELAPD_ToDate" AS "HRELAP_ToDate", NULL::TEXT AS "HRELAP_SupportingDocument", 
               a."UpdatedDate", a."CreatedDate"
        FROM "HR_Emp_Leave_Appl_Authorisation" a
        INNER JOIN "IVRM_Staff_User_Login" b ON b."Emp_Code" = a."HRME_Id"
        INNER JOIN "HR_Emp_Leave_Appl_Details" c ON a."HRELAP_Id" = c."HRELAP_Id"
        WHERE a."HRELAP_Id" = p_HRELAP_ID;

    ELSIF (v_HRELAP_ApplicationStatus = 'Requested') THEN

        CREATE TEMP TABLE temp_LeaveTemp3 AS
        SELECT "HRML_LeaveCode", "HRME_EmployeeFirstName", b."HRML_Id", "HRMET_Id", "HRMGT_Id", "HRMD_Id", 
               "HRMDES_Id", "HRMG_Id", a."HRME_Id", 'Requested' AS "HRELAPA_LeaveStatus", a."HRELAP_Id", 
               a."HRELAP_FromDate", a."HRELAP_ToDate", a."HRELAP_SupportingDocument", "HRELAPD_FromDate", 
               "HRELAPD_ToDate", "HRELAPD_TotalDays"
        FROM "HR_Emp_Leave_Application" a
        INNER JOIN "HR_Emp_Leave_Appl_Details" b ON a."HRELAP_Id" = b."HRELAP_Id"
        INNER JOIN "HR_Master_Employee" c ON a."HRME_Id" = c."HRME_Id"
        INNER JOIN "HR_Master_Leave" d ON b."HRML_Id" = d."HRML_Id"
        WHERE "HRELAP_ApplicationStatus" = 'Requested' AND a."HRELAP_ID" = p_HRELAP_ID;

        SELECT "HRML_LeaveCode" INTO v_HRML_LeaveCode FROM temp_LeaveTemp3;

        IF (v_HRML_LeaveCode = 'COMPOFF' OR v_HRML_LeaveCode = 'OD') THEN

            RETURN QUERY
            SELECT DISTINCT b."IVRMSTAUL_UserName", a."HRPAON_SanctionLevelNo", 
                   COALESCE(e."HRELAPA_LeaveStatus", 'Requested') AS "HRELAPA_LeaveStatus", e."HRELAPA_Remarks", 
                   d."HRELAPD_FromDate" AS "HRELAPA_FromDate", d."HRELAPD_ToDate" AS "HRELAPA_ToDate", 
                   d."HRELAPD_TotalDays" AS "HRELAPA_TotalDays", d."HRELAP_FromDate", d."HRELAP_ToDate", 
                   d."HRELAP_SupportingDocument", NULL::TIMESTAMP AS "UpdatedDate", e."CreatedDate" AS "createdDate"
            FROM "HR_Process_Auth_OrderNo" a
            LEFT JOIN "IVRM_Staff_User_Login" b ON b."Id" = a."IVRMUL_Id"
            INNER JOIN "HR_Process_Authorisation" c ON a."HRPA_Id" = c."HRPA_Id"
            INNER JOIN temp_LeaveTemp3 d ON c."HRMD_Id" = d."HRMD_Id" AND c."HRMDES_Id" = d."HRMDES_Id" 
                   AND c."HRMG_Id" = d."HRMG_Id" AND c."HRMGT_Id" = d."HRMGT_Id"
            LEFT JOIN "HR_Emp_Leave_Appl_Authorisation" e ON e."HRELAP_ID" = d."HRELAP_ID" 
                   AND b."Emp_Code" = e."HRME_ID" AND e."HRELAPA_SanctioningLevel" = a."HRPAON_SanctionLevelNo" 
                   AND e."hrml_id" = d."hrml_id"
            WHERE d."HRELAP_Id" = p_HRELAP_ID AND "HRPA_TypeFlag" = 'compoffODApproval'
            ORDER BY a."HRPAON_SanctionLevelNo";

        END IF;

    END IF;

    RETURN;

END;
$$;