CREATE OR REPLACE FUNCTION "dbo"."Exit_Releiving_APPROVALEMPLIST"(
    "User_Id" bigint
)
RETURNS TABLE(
    "ismresG_Id" text,
    "ismresG_ResignationDate" text,
    "hrmE_Id" text,
    "employeename1" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SanctionLevelNo" bigint;
    "Rcount" bigint;
    "Rcount1" bigint;
    "MaxSanctionLevelNo" bigint;
    "MaxSanctionLevelNo_New" bigint;
    "ApprCount" bigint;
    "ISMRESG_Id" bigint;
    "Preuserid" bigint;
    "hrmeid" bigint;
    "HRME_IdRApply" text;
    "ISMRESG_Id2" text;
    "HRME_IdRApply2" text;
    empids_rec RECORD;
    empids1_rec RECORD;
BEGIN

    SELECT "Emp_Code" INTO "hrmeid" 
    FROM "IVRM_Staff_User_Login" 
    WHERE "Id" = "User_Id";

    DROP TABLE IF EXISTS "Exit_resignation_approval_temp";

    CREATE TEMP TABLE "Exit_resignation_approval_temp" (
        "ismresG_Id" text,
        "ismresG_ResignationDate" text,
        "hrmE_Id" text,
        "HRME_EmployeeFirstname" text,
        "HRME_EmployeeMiddlename" text,
        "HRME_EmployeeLastname" text
    );

    "Rcount1" := 0;

    SELECT COUNT(*) INTO "Rcount1"
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'ExitRelieving' AND "IVRMUL_Id" = "User_Id";

    "SanctionLevelNo" := 0;
    "MaxSanctionLevelNo" := 0;
    "Preuserid" := 0;

    SELECT MAX("HRPAON_SanctionLevelNo") INTO "MaxSanctionLevelNo"
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'ExitRelieving';

    SELECT "HRPAON_SanctionLevelNo" INTO "SanctionLevelNo"
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'ExitRelieving' AND "IVRMUL_Id" = "User_Id";

    FOR empids_rec IN 
        SELECT DISTINCT "HRME_ID", "ISMRESG_Id" 
        FROM "ISM_Resignation" 
        WHERE "ISMRESG_MgmtApprRejFlg" = 'Pending' 
            AND "ISMRESG_Flg" = 'Relieving' 
            AND "ISMRESG_ActiveFlag" = 1
    LOOP
        "HRME_IdRApply" := empids_rec."HRME_ID"::text;
        "ISMRESG_Id" := empids_rec."ISMRESG_Id";

        IF ("SanctionLevelNo" = 1) THEN

            "Rcount" := 0;

            SELECT COUNT(*) INTO "Rcount"
            FROM "ISM_Resignation_ApprovedBy"
            WHERE "ISMRESGAB_CreatedBy" = "User_Id" AND "ISMRESG_Id" = "ISMRESG_Id";

            RAISE NOTICE '%', "Rcount";

            IF ("Rcount" = 0) THEN

                INSERT INTO "Exit_resignation_approval_temp" (
                    "ismresG_Id",
                    "ismresG_ResignationDate",
                    "hrmE_Id",
                    "HRME_EmployeeFirstname",
                    "HRME_EmployeeMiddlename",
                    "HRME_EmployeeLastname"
                )
                SELECT 
                    "IR"."ISMRESG_Id"::text,
                    "IR"."ISMRESG_ResignationDate"::text,
                    "IR"."HRME_Id"::text,
                    "HME"."HRME_EmployeeFirstname",
                    "HME"."HRME_EmployeeMiddlename",
                    "HME"."HRME_EmployeeLastname"
                FROM "ISM_Resignation" "IR"
                INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "IR"."HRME_Id"
                WHERE "IR"."ISMRESG_ActiveFlag" = 1 
                    AND "HME"."HRME_ActiveFlag" = 1 
                    AND "IR"."ISMRESG_MgmtApprRejFlg" = 'Pending' 
                    AND "ISMRESG_Flg" = 'Relieving' 
                    AND "IR"."HRME_ID"::text = "HRME_IdRApply" 
                    AND "HME"."HRME_Id" NOT IN (
                        SELECT DISTINCT COALESCE("HRME_Id", 0) AS "HRME_Id" 
                        FROM "ISM_Resignation_ApprovedBy" 
                        WHERE "ISMRESGAB_CreatedBy" = "User_Id" 
                            AND "ISMRESGAB_ActiveFlag" = 1
                    );

            END IF;

        END IF;

    END LOOP;

    IF ("SanctionLevelNo" > 1) THEN

        FOR empids1_rec IN 
            SELECT DISTINCT "ISMRESG_Id" 
            FROM "ISM_Resignation_ApprovedBy" 
            WHERE "HRME_Id" != "hrmeid" 
                AND "ISMRESGAB_AppRejFlg" = 'Approved' 
                AND "ISMRESG_Id" = "ISMRESG_Id" 
                AND "ISMRESGAB_ActiveFlag" = 1
        LOOP
            "ISMRESG_Id2" := empids1_rec."ISMRESG_Id"::text;

            SELECT COUNT(*) INTO "Rcount"
            FROM "ISM_Resignation_ApprovedBy"
            WHERE "ISMRESG_Id"::text = "ISMRESG_Id2";

            IF ("Rcount" > 0) AND ("MaxSanctionLevelNo" > "SanctionLevelNo") THEN

                SELECT DISTINCT "IVRMUL_Id" INTO "Preuserid"
                FROM "HR_Process_Authorisation" "PA"
                INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                WHERE "HRPA_TypeFlag" = 'ExitRelieving' 
                    AND "IVRMUL_Id" IN (
                        SELECT DISTINCT "IVRMUL_Id"
                        FROM "HR_Process_Authorisation" "PA"
                        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                        WHERE "HRPA_TypeFlag" = 'ExitRelieving' 
                            AND "HRPAON_SanctionLevelNo" = "SanctionLevelNo" - 1
                    );

                INSERT INTO "Exit_resignation_approval_temp"(
                    "ismresG_Id",
                    "ismresG_ResignationDate",
                    "hrmE_Id",
                    "HRME_EmployeeFirstname",
                    "HRME_EmployeeMiddlename",
                    "HRME_EmployeeLastname"
                )
                SELECT 
                    "IR"."ISMRESG_Id"::text,
                    "IR"."ISMRESG_ResignationDate"::text,
                    "IR"."HRME_Id"::text,
                    "HME"."HRME_EmployeeFirstname",
                    "HME"."HRME_EmployeeMiddlename",
                    "HME"."HRME_EmployeeLastname"
                FROM "ISM_Resignation" "IR"
                INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "IR"."HRME_Id"
                INNER JOIN "ISM_Resignation_ApprovedBy" "IRA" ON "IR"."ISMRESG_Id" = "IRA"."ISMRESG_Id"
                WHERE "IR"."ISMRESG_ActiveFlag" = 1 
                    AND "ISMRESG_Flg" = 'Relieving' 
                    AND "HME"."HRME_ActiveFlag" = 1 
                    AND "IRA"."ISMRESGAB_CreatedBy" = "Preuserid" 
                    AND "IRA"."ISMRESGAB_CreatedBy" != "User_Id";

            END IF;

            "ApprCount" := 0;
            SELECT COUNT(*) INTO "ApprCount"
            FROM "ISM_Resignation_ApprovedBy"
            WHERE "ISMRESG_Id"::text = "ISMRESG_Id2";

            "MaxSanctionLevelNo_New" := "MaxSanctionLevelNo" - 1;

        END LOOP;

    END IF;

    RETURN QUERY
    SELECT 
        "Exit_resignation_approval_temp"."ismresG_Id",
        "Exit_resignation_approval_temp"."ismresG_ResignationDate",
        "Exit_resignation_approval_temp"."hrmE_Id",
        CONCAT("HRME_EmployeeFirstname", ' ', "HRME_EmployeeMiddlename", ' ', "HRME_EmployeeLastname") AS "employeename1"
    FROM "Exit_resignation_approval_temp";

END;
$$;