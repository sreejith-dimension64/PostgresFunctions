CREATE OR REPLACE FUNCTION "dbo"."AllEmployeesOpenIssuesDevReport"()
RETURNS TABLE(
    "ISMTCR_TaskNo" TEXT,
    "ISMTCR_Title" TEXT,
    "ISMTCR_Status" TEXT,
    "EmpName" TEXT,
    "ISMTCR_BugOREnhancementFlg" TEXT,
    "AssignedBy" TEXT,
    "TransBy" TEXT,
    "StartDate" TEXT,
    "EndDate" TEXT,
    "EndDate1" DATE,
    "DiffDays" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_Id BIGINT;
    v_ISMTCR_TaskNo TEXT;
    v_ISMTCR_Title TEXT;
    v_ISMTCR_Status TEXT;
    v_EmpName TEXT;
    v_ISMTCR_BugOREnhancementFlg TEXT;
    v_AssignedBy TEXT;
    v_TransBy TEXT;
    v_StartDate TEXT;
    v_EndDate TEXT;
    v_EndDate1 DATE;
    v_DiffDays BIGINT;
    rec_emp RECORD;
BEGIN

    DROP TABLE IF EXISTS "AllEmpsOpenIssuesDevReprt_Temp";

    CREATE TEMP TABLE "AllEmpsOpenIssuesDevReprt_Temp"(
        "ISMTCR_TaskNo" TEXT,
        "ISMTCR_Title" TEXT,
        "ISMTCR_Status" TEXT,
        "EmpName" TEXT,
        "ISMTCR_BugOREnhancementFlg" TEXT,
        "AssignedBy" TEXT,
        "TransBy" TEXT,
        "StartDate" TEXT,
        "EndDate" TEXT,
        "EndDate1" DATE,
        "DiffDays" BIGINT
    );

    FOR v_HRME_Id IN 
        SELECT DISTINCT "HRME_Id" 
        FROM "HR_Master_Employee" 
        WHERE "HRME_ActiveFlag" = 1 AND "HRME_LeftFlag" = 0
    LOOP

        DROP TABLE IF EXISTS "AllEmprecords_temp";

        CREATE TEMP TABLE "AllEmprecords_temp" AS
        SELECT * FROM (
            SELECT DISTINCT "ISMTCR_TaskNo", "ISMTCR_Title", "ISMTCR_Status",
            (SELECT DISTINCT (
                (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
            ) FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = v_HRME_Id) AS "EmpName",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' 
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
                  ELSE 'Others' END) AS "ISMTCR_BugOREnhancementFlg",
            (SELECT DISTINCT (
                (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
            ) FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = "TCAT"."ISMTCRASTO_AssignedBy") AS "AssignedBy",
            '' AS "TransBy",
            TO_CHAR("TCAT"."ISMTCRASTO_AssignedDate", 'DD/MM/YYYY') AS "StartDate",
            TO_CHAR("TCAT"."ISMTCRASTO_EndDate", 'DD/MM/YYYY') AS "EndDate",
            "TCAT"."ISMTCRASTO_EndDate" AS "EndDate1",
            (CURRENT_DATE - "ISMTCRASTO_EndDate"::DATE) AS "DiffDays"
            FROM "ISM_TaskCreation" "TC"
            INNER JOIN "ISM_TaskCreation_AssignedTo" "TCAT" ON "TCAT"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" "HME" ON "TCAT"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND "TCAT"."HRME_Id" = v_HRME_Id
            AND "TC"."ISMTCR_Id" NOT IN (
                SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" 
                WHERE "ISMTCRTRTO_TransferredBy" = v_HRME_Id
            )
            AND "TC"."ISMTCR_Status" IN ('Inprogress','Open','ReOpen') 
            AND "TCAT"."ISMTCRASTO_EndDate"::DATE <= CURRENT_DATE 
            AND "ISMTCRASTO_EndDate"::DATE > "ISMTCRASTO_AssignedDate"::DATE

            UNION ALL

            SELECT DISTINCT "ISMTCR_TaskNo", "ISMTCR_Title", "ISMTCR_Status",
            (SELECT DISTINCT (
                (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
            ) FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = v_HRME_Id) AS "EmpName",
            (CASE WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'B' THEN 'Bug/Complaints' 
                  WHEN "TC"."ISMTCR_BugOREnhancementFlg" = 'E' THEN 'Enhancement' 
                  ELSE 'Others' END) AS "ISMTCR_BugOREnhancementFlg",
            '' AS "AssignedBy",
            (SELECT DISTINCT (
                (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||
                CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' OR "HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName" END ||
                CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '' OR "HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
            ) FROM "HR_Master_Employee" "MME" WHERE "MME"."HRME_Id" = "TR"."ISMTCRTRTO_TransferredBy") AS "TransBy",
            TO_CHAR("TR"."ISMTCRTRTO_StartDate", 'DD/MM/YYYY') AS "StartDate",
            TO_CHAR("TR"."ISMTCRTRTO_EndDate", 'DD/MM/YYYY') AS "EndDate",
            "TR"."ISMTCRTRTO_EndDate" AS "EndDate1",
            (CURRENT_DATE - "ISMTCRTRTO_EndDate"::DATE) AS "DiffDays"
            FROM "ISM_TaskCreation" "TC"
            LEFT JOIN "ISM_TaskCreation_TransferredTo" "TR" ON "TR"."ISMTCR_Id" = "TC"."ISMTCR_Id"
            LEFT JOIN "ISM_TaskCreation_Client" "ac" ON "TC"."ISMTCR_Id" = "ac"."ISMTCR_Id"
            LEFT JOIN "ISM_Master_Client" "cl" ON "ac"."ISMMCLT_Id" = "cl"."ISMMCLT_Id" AND "cl"."ISMMCLT_ActiveFlag" = 1
            INNER JOIN "HR_Master_Priority" "MP" ON "TC"."HRMPR_Id" = "MP"."HRMPR_Id" AND "MP"."HRMP_ActiveFlag" = 1
            INNER JOIN "HR_Master_Employee" "HME" ON "TR"."HRME_Id" = "HME"."HRME_Id" AND "HME"."HRME_ActiveFlag" = 1 AND "HME"."HRME_LeftFlag" = 0
            WHERE "TC"."ISMTCR_ActiveFlg" = 1 AND "TR"."HRME_Id" = v_HRME_Id
            AND "TC"."ISMTCR_Id" NOT IN (
                SELECT DISTINCT "ISMTCR_Id" FROM "ISM_TaskCreation_TransferredTo" 
                WHERE "ISMTCRTRTO_TransferredBy" = v_HRME_Id
            )
            AND "TC"."ISMTCR_Status" IN ('Inprogress','Open','ReOpen') 
            AND "TR"."ISMTCRTRTO_EndDate"::DATE <= CURRENT_DATE 
            AND "ISMTCRTRTO_EndDate"::DATE > "ISMTCRTRTO_StartDate"::DATE
        ) AS "New" ORDER BY "EndDate1";

        FOR rec_emp IN SELECT * FROM "AllEmprecords_temp"
        LOOP
            INSERT INTO "AllEmpsOpenIssuesDevReprt_Temp" (
                "ISMTCR_TaskNo", "ISMTCR_Title", "ISMTCR_Status", "EmpName", 
                "ISMTCR_BugOREnhancementFlg", "AssignedBy", "TransBy", "StartDate", 
                "EndDate", "EndDate1", "DiffDays"
            )
            VALUES(
                rec_emp."ISMTCR_TaskNo", rec_emp."ISMTCR_Title", rec_emp."ISMTCR_Status", 
                rec_emp."EmpName", rec_emp."ISMTCR_BugOREnhancementFlg", rec_emp."AssignedBy", 
                rec_emp."TransBy", rec_emp."StartDate", rec_emp."EndDate", 
                rec_emp."EndDate1", rec_emp."DiffDays"
            );
        END LOOP;

    END LOOP;

    RETURN QUERY 
    SELECT * FROM "AllEmpsOpenIssuesDevReprt_Temp" ORDER BY "EmpName";

END;
$$;