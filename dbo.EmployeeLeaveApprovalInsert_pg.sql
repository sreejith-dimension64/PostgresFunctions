CREATE OR REPLACE FUNCTION "dbo"."EmployeeLeaveApprovalInsert"(
    "p_HRELAP_ApplicationID" VARCHAR(100),
    "p_MI_Id" BIGINT,
    "p_HRELAP_Id" BIGINT,
    "p_status" VARCHAR(50),
    "p_LoginID" INT,
    "p_Remarks" TEXT,
    "p_Reason" TEXT
)
RETURNS TABLE(
    "HRELAP_ApplicationId" VARCHAR(100),
    "FullName" TEXT,
    "HRML_LeaveType" VARCHAR,
    "HRELAP_FromDate" TIMESTAMP,
    "HRELAP_ToDate" TIMESTAMP,
    "HRELAP_TotalDays" INT,
    "HRELAP_LeaveReason" VARCHAR(50),
    "HRELAPA_Remarks" TEXT,
    "HRELAP_ApplicationStatus" VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_levelNo" INT;
    "v_HRME_Id" BIGINT;
    "v_HRML_Id" BIGINT;
    "v_HRELS_Id" BIGINT;
    "v_FromYear" INT;
    "v_HRELAP_FromDate" TIMESTAMP;
    "v_HRELAP_LeaveReason" VARCHAR(50);
    "v_HRELAP_ToDate" TIMESTAMP;
    "v_HRELAP_ApplicationStatus" VARCHAR(50);
    "v_HRMLY_Id" BIGINT;
    "v_HRELAP_FinalFlag" BOOLEAN;
    "v_HRELAP_TotalDays" INT;
    "v_HRELAP_SanctioningLevel" INT;
    "v_HRELT_Id" BIGINT;
    "v_LeaveYear" INT;
BEGIN

    SELECT "Emp_Code" INTO "v_HRME_Id" 
    FROM "IVRM_Staff_User_Login" 
    WHERE "id" = "p_LoginID";

    SELECT a."HRLAON_SanctionLevelNo" INTO "v_HRELAP_SanctioningLevel"
    FROM "HR_Leave_Auth_OrderNo" a
    JOIN "HR_Leave_Authorisation" b ON a."HRLA_Id" = b."HRLA_Id"
    WHERE a."IVRMUL_Id" = "v_HRME_Id";

    SELECT a."HRLAON_FinalFlg" INTO "v_HRELAP_FinalFlag"
    FROM "HR_Leave_Auth_OrderNo" a
    JOIN "HR_Leave_Authorisation" b ON a."HRLA_Id" = b."HRLA_Id"
    WHERE a."IVRMUL_Id" = "v_HRME_Id";

    IF("p_status" = 'Rejected') THEN
        UPDATE "HR_Emp_Leave_Application" 
        SET "HRELAP_ApplicationStatus" = 'Rejected',
            "HRELAP_SanctioningLevel" = "v_HRELAP_SanctioningLevel",
            "HRELAP_FinalFlag" = TRUE 
        WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

        SELECT "HRELAP_Id" INTO "p_HRELAP_Id" 
        FROM "HR_Emp_Leave_Application" 
        WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

        UPDATE "HR_Emp_Leave_Appl_Details" 
        SET "HRELAPD_LeaveStatus" = 'Rejected' 
        WHERE "HRELAP_Id" = "p_HRELAP_Id";

        SELECT "HRELAP_Id", "HRME_Id", EXTRACT(YEAR FROM "HRELAP_ApplicationDate")::INT,
               "HRELAP_FromDate", "HRELAP_ToDate", "HRELAP_TotalDays",
               "HRELAP_LeaveReason", "HRELAP_ApplicationStatus", "HRELAP_FinalFlag"
        INTO "p_HRELAP_Id", "v_HRME_Id", "v_LeaveYear", "v_HRELAP_FromDate", 
             "v_HRELAP_ToDate", "v_HRELAP_TotalDays", "v_HRELAP_LeaveReason",
             "v_HRELAP_ApplicationStatus", "v_HRELAP_FinalFlag"
        FROM "HR_Emp_Leave_Application" 
        WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

        SELECT "HRELAP_Id", "HRME_Id", "HRELAP_FinalFlag"
        INTO "p_HRELAP_Id", "v_HRME_Id", "v_HRELAP_FinalFlag"
        FROM "HR_Emp_Leave_Application" 
        WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

        UPDATE "HR_Emp_Leave_Trans" 
        SET "HRELT_Status" = 'Rejected', "HRELT_ActiveFlag" = TRUE 
        WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_HRME_Id" 
          AND "HRELT_FromDate" = "v_HRELAP_FromDate" 
          AND "HRELT_ToDate" = "v_HRELAP_ToDate";

        SELECT "HRELT_Id" INTO "v_HRELT_Id" 
        FROM "HR_Emp_Leave_Trans" 
        WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_HRME_Id" 
          AND "HRELT_FromDate" = "v_HRELAP_FromDate" 
          AND "HRELT_ToDate" = "v_HRELAP_ToDate";

        UPDATE "HR_Emp_Leave_Trans_Details" 
        SET "HRELTD_LWPFlag" = TRUE 
        WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_HRME_Id" 
          AND "HRELTD_FromDate" = "v_HRELAP_FromDate" 
          AND "HRELTD_ToDate" = "v_HRELAP_ToDate" 
          AND "HRELT_Id" = "v_HRELT_Id";

        INSERT INTO "HR_Emp_Leave_Appl_Authorisation" 
            ("HRELAP_Id", "HRME_Id", "HRELAPA_SanctioningLevel", "HRELAPA_Remarks", 
             "HRELAPA_FinalFlag", "CreatedDate", "UpdatedDate")
        VALUES("p_HRELAP_Id", "v_HRME_Id", "v_HRELAP_SanctioningLevel", "p_Remarks", 
               "v_HRELAP_FinalFlag", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

    ELSIF("p_status" = 'Approved') THEN
        IF("v_HRELAP_FinalFlag" = FALSE) THEN
            UPDATE "HR_Emp_Leave_Application" 
            SET "HRELAP_ApplicationStatus" = 'Partial Approved',
                "HRELAP_SanctioningLevel" = "v_HRELAP_SanctioningLevel" 
            WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID" 
              AND "HRELAP_Id" = "p_HRELAP_Id";

            SELECT "HRELAP_Id" INTO "p_HRELAP_Id" 
            FROM "HR_Emp_Leave_Application" 
            WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

            UPDATE "HR_Emp_Leave_Appl_Details" 
            SET "HRELAPD_LeaveStatus" = 'Partial Approved' 
            WHERE "HRELAP_Id" = "p_HRELAP_Id";

            SELECT "HRELAP_Id", "HRME_Id", EXTRACT(YEAR FROM "HRELAP_ApplicationDate")::INT,
                   "HRELAP_FromDate", "HRELAP_ToDate", "HRELAP_TotalDays",
                   "HRELAP_LeaveReason", "HRELAP_ApplicationStatus", "HRELAP_FinalFlag"
            INTO "p_HRELAP_Id", "v_HRME_Id", "v_LeaveYear", "v_HRELAP_FromDate", 
                 "v_HRELAP_ToDate", "v_HRELAP_TotalDays", "v_HRELAP_LeaveReason",
                 "v_HRELAP_ApplicationStatus", "v_HRELAP_FinalFlag"
            FROM "HR_Emp_Leave_Application" 
            WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

            SELECT "HRELAP_Id", "HRME_Id", "HRELAP_FinalFlag"
            INTO "p_HRELAP_Id", "v_HRME_Id", "v_HRELAP_FinalFlag"
            FROM "HR_Emp_Leave_Application" 
            WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

            UPDATE "HR_Emp_Leave_Trans" 
            SET "HRELT_Status" = 'Partial Approved', "HRELT_ActiveFlag" = TRUE 
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_HRME_Id" 
              AND "HRELT_FromDate" = "v_HRELAP_FromDate" 
              AND "HRELT_ToDate" = "v_HRELAP_ToDate";

            SELECT "HRELT_Id" INTO "v_HRELT_Id" 
            FROM "HR_Emp_Leave_Trans" 
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_HRME_Id" 
              AND "HRELT_FromDate" = "v_HRELAP_FromDate" 
              AND "HRELT_ToDate" = "v_HRELAP_ToDate";

            UPDATE "HR_Emp_Leave_Trans_Details" 
            SET "HRELTD_LWPFlag" = TRUE 
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_HRME_Id" 
              AND "HRELTD_FromDate" = "v_HRELAP_FromDate" 
              AND "HRELTD_ToDate" = "v_HRELAP_ToDate" 
              AND "HRELT_Id" = "v_HRELT_Id";

            INSERT INTO "HR_Emp_Leave_Appl_Authorisation" 
                ("HRELAP_Id", "HRME_Id", "HRELAPA_SanctioningLevel", "HRELAPA_Remarks", 
                 "HRELAPA_FinalFlag", "CreatedDate", "UpdatedDate")
            VALUES("p_HRELAP_Id", "v_HRME_Id", "v_HRELAP_SanctioningLevel", "p_Remarks", 
                   "v_HRELAP_FinalFlag", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

        ELSIF ("v_HRELAP_FinalFlag" = TRUE) THEN
            UPDATE "HR_Emp_Leave_Application" 
            SET "HRELAP_ApplicationStatus" = 'Approved',
                "HRELAP_SanctioningLevel" = "v_HRELAP_SanctioningLevel",
                "HRELAP_FinalFlag" = TRUE 
            WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID" 
              AND "HRELAP_Id" = "p_HRELAP_Id";

            SELECT "HRELAP_Id" INTO "p_HRELAP_Id" 
            FROM "HR_Emp_Leave_Application" 
            WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

            UPDATE "HR_Emp_Leave_Appl_Details" 
            SET "HRELAPD_LeaveStatus" = 'Approved' 
            WHERE "HRELAP_Id" = "p_HRELAP_Id";

            SELECT "HRML_Id", EXTRACT(YEAR FROM "HRELAPD_FromDate")::INT 
            INTO "v_HRML_Id", "v_FromYear"
            FROM "HR_Emp_Leave_Appl_Details" 
            WHERE "HRELAP_ID" = "p_HRELAP_Id";

            SELECT "HMY"."HRMLY_Id" INTO "v_HRMLY_Id" 
            FROM "HR_Master_LeaveYear" "HMY" 
            WHERE "HMY"."HRMLY_LeaveYear" = "v_FromYear";

            SELECT "HRELAP_Id", "HRME_Id", EXTRACT(YEAR FROM "HRELAP_ApplicationDate")::INT,
                   "HRELAP_FromDate", "HRELAP_ToDate", "HRELAP_TotalDays",
                   "HRELAP_LeaveReason", "HRELAP_ApplicationStatus", "HRELAP_FinalFlag"
            INTO "p_HRELAP_Id", "v_HRME_Id", "v_LeaveYear", "v_HRELAP_FromDate", 
                 "v_HRELAP_ToDate", "v_HRELAP_TotalDays", "v_HRELAP_LeaveReason",
                 "v_HRELAP_ApplicationStatus", "v_HRELAP_FinalFlag"
            FROM "HR_Emp_Leave_Application" 
            WHERE "HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

            UPDATE "HR_Emp_Leave_Trans" 
            SET "HRELT_Status" = 'Approved', "HRELT_ActiveFlag" = TRUE 
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_HRME_Id" 
              AND "HRELT_FromDate" = "v_HRELAP_FromDate" 
              AND "HRELT_ToDate" = "v_HRELAP_ToDate";

            SELECT "HRELT_Id" INTO "v_HRELT_Id" 
            FROM "HR_Emp_Leave_Trans" 
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_HRME_Id" 
              AND "HRELT_FromDate" = "v_HRELAP_FromDate" 
              AND "HRELT_ToDate" = "v_HRELAP_ToDate";

            UPDATE "HR_Emp_Leave_Trans_Details" 
            SET "HRELTD_LWPFlag" = FALSE 
            WHERE "MI_Id" = "p_MI_Id" AND "HRME_Id" = "v_HRME_Id" 
              AND "HRELTD_FromDate" = "v_HRELAP_FromDate" 
              AND "HRELTD_ToDate" = "v_HRELAP_ToDate" 
              AND "HRELT_Id" = "v_HRELT_Id";

            INSERT INTO "HR_Emp_Leave_Appl_Authorisation"
                ("HRELAP_Id", "HRME_Id", "HRELAPA_SanctioningLevel", "HRELAPA_Remarks", 
                 "HRELAPA_FinalFlag", "CreatedDate", "UpdatedDate")
            VALUES("p_HRELAP_Id", "v_HRME_Id", "v_HRELAP_SanctioningLevel", "p_Remarks", 
                   "v_HRELAP_FinalFlag", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

            SELECT "HRMLY_Id" INTO "v_HRMLY_Id" 
            FROM "HR_Master_LeaveYear" 
            WHERE "MI_Id" = "p_MI_Id" AND "HRMLY_LeaveYear" = "v_LeaveYear";

            SELECT "HRML_Id" INTO "v_HRML_Id" 
            FROM "HR_Emp_Leave_Appl_Details" 
            WHERE "HRELAP_Id" = "p_HRELAP_Id";

            SELECT "HRELS_Id" INTO "v_HRELS_Id" 
            FROM "HR_Emp_Leave_Status" 
            WHERE "HRML_Id" = "v_HRML_Id" 
              AND "v_HRMLY_Id" = "v_HRMLY_Id" 
              AND "HRME_Id" = "v_HRME_Id";

            UPDATE "HR_Emp_Leave_Status" 
            SET "HRELS_CBLeaves" = "HRELS_CBLeaves" - "v_HRELAP_TotalDays", 
                "HRELS_TransLeaves" = "HRELS_TransLeaves" 
            WHERE "HRML_Id" = "v_HRML_Id" 
              AND "v_HRMLY_Id" = "v_HRMLY_Id" 
              AND "HRME_Id" = "v_HRME_Id";
        END IF;
    END IF;

    RETURN QUERY
    SELECT DISTINCT "HELA"."HRELAP_ApplicationId",
           ("HME"."HRME_EmployeeFirstName" || '' || "HME"."HRME_EmployeeMiddleName" || '' || 
            "HME"."HRME_EmployeeLastName")::TEXT AS "FullName",
           "HML"."HRML_LeaveType",
           "HELA"."HRELAP_FromDate",
           "HELA"."HRELAP_ToDate",
           "HELA"."HRELAP_TotalDays",
           "HELA"."HRELAP_LeaveReason",
           "HELAA"."HRELAPA_Remarks",
           "HELA"."HRELAP_ApplicationStatus"
    FROM "HR_Emp_Leave_Application" "HELA"
    INNER JOIN "HR_Master_Employee" "HME" ON "HELA"."HRME_Id" = "HME"."HRME_Id"
    INNER JOIN "HR_Emp_Leave_Trans_Details" "HELTD" ON "HELTD"."HRME_Id" = "HELA"."HRME_Id"
    INNER JOIN "HR_Master_Leave" "HML" ON "HML"."HRML_Id" = "HML"."HRML_Id"
    INNER JOIN "HR_Emp_Leave_Appl_Authorisation" "HELAA" ON "HELAA"."HRELAP_Id" = "HELA"."HRELAP_Id"
    WHERE "HELA"."HRELAP_ApplicationID" = "p_HRELAP_ApplicationID";

    RETURN;
END;
$$;