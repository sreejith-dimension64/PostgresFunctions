CREATE OR REPLACE FUNCTION "dbo"."HR_TRAINING_APPLY_APPROVAL"(p_User_Id bigint)
RETURNS TABLE(
    "MI_Id" bigint,
    "MI_Name" text,
    "HREXTTRN_Id" bigint,
    "HRME_Id" bigint,
    "HRMETRTY_Id" bigint,
    "HREXTTRN_TrainingTopic" text,
    "HREXTTRN_StartDate" timestamp,
    "HREXTTRN_EndDate" timestamp,
    "HREXTTRN_StartTime" text,
    "HREXTTRN_EndTime" text,
    "HREXTTRN_TotalHrs" decimal(18,2),
    "HREXTTRNAPP_ApproverRemarks" text,
    "HREXTTRNAPP_ApprovedHrs" decimal(18,2),
    "HREXTTRNAPP_ApprovalFlg" text,
    "User_Id" bigint,
    "SanctionLevelNo" bigint,
    "EmpName" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SanctionLevelNo bigint;
    v_Rcount bigint;
    v_Rcount1 bigint;
    v_MaxSanctionLevelNo bigint;
    v_MaxSanctionLevelNo_New bigint;
    v_ApprCount bigint;
    v_HREXTTRN_Id bigint;
    v_MI_Id bigint;
    v_Preuserid bigint;
    rec RECORD;
BEGIN
    DROP TABLE IF EXISTS "HR_Training_Apply_Approval_Temp";
    
    CREATE TEMP TABLE "HR_Training_Apply_Approval_Temp" (
        "MI_Id" bigint,
        "MI_Name" text,
        "HREXTTRN_Id" bigint,
        "HRME_Id" bigint,
        "HRMETRTY_Id" bigint,
        "HREXTTRN_TrainingTopic" text,
        "HREXTTRN_StartDate" timestamp,
        "HREXTTRN_EndDate" timestamp,
        "HREXTTRN_StartTime" text,
        "HREXTTRN_EndTime" text,
        "HREXTTRN_TotalHrs" decimal(18,2),
        "HREXTTRNAPP_ApproverRemarks" text,
        "HREXTTRNAPP_ApprovedHrs" decimal(18,2),
        "HREXTTRNAPP_ApprovalFlg" text,
        "User_Id" bigint,
        "SanctionLevelNo" bigint,
        "EmpName" text
    );

    v_Rcount1 := 0;

    SELECT COUNT(*) INTO v_Rcount1
    FROM "HR_Process_Authorisation" "PA"
    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
    WHERE "HRPA_TypeFlag" = 'Training' AND "IVRMUL_Id" = p_User_Id;

    IF v_Rcount1 > 0 THEN
        v_SanctionLevelNo := 0;
        v_MaxSanctionLevelNo := 0;
        v_Preuserid := 0;

        SELECT MAX("HRPAON_SanctionLevelNo") INTO v_MaxSanctionLevelNo
        FROM "HR_Process_Authorisation" "PA"
        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
        WHERE "HRPA_TypeFlag" = 'Training';

        SELECT "HRPAON_SanctionLevelNo" INTO v_SanctionLevelNo
        FROM "HR_Process_Authorisation" "PA"
        INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
        WHERE "HRPA_TypeFlag" = 'Training' AND "IVRMUL_Id" = p_User_Id;

        FOR rec IN 
            SELECT DISTINCT "HREXTTRN_Id", "MI_Id" 
            FROM "HR_External_Training" 
            WHERE "HREXTTRN_ActiveFlag" = 1 
            AND ("HREXTTRN_ApprovedFlg" = 'Pending' OR "HREXTTRN_ApprovedFlg" = '0') 
            AND "HREXTTRN_Id" = 59
        LOOP
            v_HREXTTRN_Id := rec."HREXTTRN_Id";
            v_MI_Id := rec."MI_Id";

            IF (v_SanctionLevelNo = 1) THEN
                v_Rcount := 0;
                SELECT COUNT(*) INTO v_Rcount
                FROM "HR_External_Training_Approval"
                WHERE "HREXTTRNAPP_CreatedBy" = p_User_Id 
                AND "HREXTTRN_Id" = v_HREXTTRN_Id;

                IF (v_Rcount = 0) THEN
                    INSERT INTO "HR_Training_Apply_Approval_Temp"(
                        "MI_Id", "MI_Name", "HREXTTRN_Id", "HRME_Id", "HRMETRTY_Id", 
                        "HREXTTRN_TrainingTopic", "HREXTTRN_StartDate", "HREXTTRN_EndDate", 
                        "HREXTTRN_StartTime", "HREXTTRN_EndTime", "HREXTTRN_TotalHrs", 
                        "HREXTTRNAPP_ApprovedHrs", "HREXTTRNAPP_ApprovalFlg", "User_Id", 
                        "SanctionLevelNo", "EmpName"
                    )
                    SELECT 
                        "MI"."MI_Id", "MI_Name", "HREXTTRN_Id", "ET"."HRME_Id", "HRMETRTY_Id", 
                        "HREXTTRN_TrainingTopic", "HREXTTRN_StartDate", "HREXTTRN_EndDate", 
                        "HREXTTRN_StartTime", "HREXTTRN_EndTime", "HREXTTRN_TotalHrs", 
                        "HREXTTRN_TotalHrs", "HREXTTRN_ApprovedFlg", p_User_Id, v_SanctionLevelNo,
                        COALESCE("HRME_EmployeeFirstName", ' ') || ' ' || 
                        COALESCE("HRME_EmployeeMiddleName", ' ') || ' ' || 
                        COALESCE("HRME_EmployeeLastName", ' ') AS "EmpName"
                    FROM "HR_External_Training" "ET"
                    INNER JOIN "HR_Master_Employee" AS "EMP" ON "EMP"."HRME_Id" = "ET"."HRME_Id"
                    INNER JOIN "Master_Institution" "MI" ON "ET"."MI_Id" = "MI"."MI_Id"
                    WHERE ("HREXTTRN_ApprovedFlg" = 'Pending' OR "HREXTTRN_ApprovedFlg" = '0') 
                    AND "HREXTTRN_ActiveFlag" = 1 
                    AND "ET"."HREXTTRN_Id" = v_HREXTTRN_Id 
                    AND "ET"."MI_Id" = v_MI_Id 
                    AND "ET"."HREXTTRN_Id" NOT IN (
                        SELECT DISTINCT COALESCE("HREXTTRN_Id", 0) "HREXTTRN_Id" 
                        FROM "HR_External_Training_Approval" 
                        WHERE "HREXTTRNAPP_CreatedBy" = p_User_Id
                    );
                END IF;
            END IF;

            SELECT COUNT(*) INTO v_Rcount
            FROM "HR_External_Training_Approval"
            WHERE "HREXTTRN_Id" = v_HREXTTRN_Id;

            IF (v_Rcount > 0) THEN
                SELECT DISTINCT "IVRMUL_Id" INTO v_Preuserid
                FROM "HR_Process_Authorisation" "PA"
                INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                WHERE "HRPA_TypeFlag" = 'Training' 
                AND "IVRMUL_Id" IN (
                    SELECT DISTINCT "IVRMUL_Id"
                    FROM "HR_Process_Authorisation" "PA"
                    INNER JOIN "HR_Process_Auth_OrderNo" "AO" ON "PA"."HRPA_Id" = "AO"."HRPA_Id"
                    WHERE "HRPA_TypeFlag" = 'Training' 
                    AND "HRPAON_SanctionLevelNo" = v_SanctionLevelNo - 1
                )
                LIMIT 1;

                INSERT INTO "HR_Training_Apply_Approval_Temp"(
                    "MI_Id", "MI_Name", "HREXTTRN_Id", "HRME_Id", "HRMETRTY_Id", 
                    "HREXTTRN_TrainingTopic", "HREXTTRN_StartDate", "HREXTTRN_EndDate", 
                    "HREXTTRN_StartTime", "HREXTTRN_EndTime", "HREXTTRN_TotalHrs", 
                    "HREXTTRNAPP_ApproverRemarks", "HREXTTRNAPP_ApprovedHrs", 
                    "HREXTTRNAPP_ApprovalFlg", "User_Id", "SanctionLevelNo", "EmpName"
                )
                SELECT 
                    "MI"."MI_Id", "MI_Name", "ETA"."HREXTTRN_Id", "ET"."HRME_Id", "HRMETRTY_Id", 
                    "HREXTTRN_TrainingTopic", "HREXTTRN_StartDate", "HREXTTRN_EndDate", 
                    "HREXTTRN_StartTime", "HREXTTRN_EndTime", "HREXTTRN_TotalHrs", 
                    "HREXTTRNAPP_ApproverRemarks", "HREXTTRNAPP_ApprovedHrs", 
                    "HREXTTRNAPP_ApprovalFlg" AS "HREXTTRNAPP_ApprovalFlg", 
                    p_User_Id AS "User_Id", v_SanctionLevelNo AS "SanctionLevelNo",
                    COALESCE("HRME_EmployeeFirstName", ' ') || ' ' || 
                    COALESCE("HRME_EmployeeMiddleName", ' ') || ' ' || 
                    COALESCE("HRME_EmployeeLastName", ' ') AS "EmpName"
                FROM "HR_External_Training_Approval" "ETA"
                INNER JOIN "HR_External_Training" "ET" ON "ET"."HREXTTRN_Id" = "ETA"."HREXTTRN_Id" 
                    AND "HREXTTRNAPP_ActiveFlag" = 1
                INNER JOIN "Master_Institution" "MI" ON "ET"."MI_Id" = "MI"."MI_Id"
                INNER JOIN "HR_Master_Employee" AS "EMP" ON "EMP"."HRME_Id" = "ET"."HRME_Id"
                WHERE "ETA"."HREXTTRN_Id" = v_HREXTTRN_Id 
                AND "ET"."MI_Id" = v_MI_Id 
                AND "ET"."HREXTTRN_Id" NOT IN (
                    SELECT DISTINCT "HREXTTRN_Id" 
                    FROM "HR_External_Training_Approval" 
                    WHERE "HREXTTRNAPP_CreatedBy" = p_User_Id
                ) 
                AND "ETA"."HREXTTRNAPP_CreatedBy" = v_Preuserid;
            END IF;

            v_ApprCount := 0;
            SELECT COUNT(*) INTO v_ApprCount
            FROM "HR_External_Training_Approval"
            WHERE "HREXTTRN_Id" = v_HREXTTRN_Id;

            v_MaxSanctionLevelNo_New := v_MaxSanctionLevelNo - 1;
        END LOOP;

        RETURN QUERY
        SELECT DISTINCT "A".*
        FROM "HR_Training_Apply_Approval_Temp" "A";
    END IF;

    RETURN;
END;
$$;