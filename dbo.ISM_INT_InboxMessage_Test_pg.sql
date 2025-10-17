CREATE OR REPLACE FUNCTION "dbo"."ISM_INT_InboxMessage_Test"(
    "MI_Id" VARCHAR(100),
    "HRME_Id" VARCHAR(100),
    "ISMINTR_Id" VARCHAR(100),
    "Type_Id" VARCHAR(50)
)
RETURNS TABLE(
    "ISMINTR_Id" BIGINT,
    "ISMINTR_InteractionId" VARCHAR,
    "ISMINTR_ComposedByHRME_Id" BIGINT,
    "ISMINTR_GroupOrIndFlg" VARCHAR,
    "ISMINTR_Subject" VARCHAR,
    "ISMINTR_DateTime" TIMESTAMP,
    "ISMINTR_Interaction" TEXT,
    "ISMINTRD_ToId" BIGINT,
    "employeename" TEXT,
    "user_name_or_sender" TEXT,
    "Receiver" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic1" TEXT;
    "Slqdymaic2" TEXT;
BEGIN
    DROP TABLE IF EXISTS "Interaction_Temp1";
    DROP TABLE IF EXISTS "Interaction_Temp2";

    IF "Type_Id" = '1' THEN
        "Slqdymaic1" := '
        CREATE TEMP TABLE "Interaction_Temp1" AS
        SELECT DISTINCT "INTRD"."ISMINTR_Id", "INTR"."ISMINTR_InteractionId", "INTR"."ISMINTR_ComposedByHRME_Id", 
        "INTR"."ISMINTR_GroupOrIndFlg", "INTR"."ISMINTR_Subject", "INTR"."ISMINTR_DateTime", "INTR"."ISMINTR_Interaction",
        NULL::BIGINT AS "ISMINTRD_ToId",
        (SELECT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
        OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = ' || "HRME_Id" || ') AS employeename,

        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
        OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS user_name,
        NULL::TEXT AS "Receiver"

        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id" = "INTRD"."ISMINTR_Id" AND "INTRD"."ISMINTRD_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_InteractionOrder" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "INTR"."ISMINTR_ComposedByHRME_Id" AND "HRME_ActiveFlag" = 1 
        WHERE "INTR"."MI_Id" = ' || "MI_Id" || ' AND "INTR"."ISMINTR_ActiveFlag" = 1 AND "INTR"."ISMINTR_ComposedByHRME_Id" = ' || "HRME_Id";

        "Slqdymaic2" := '
        CREATE TEMP TABLE "Interaction_Temp2" AS
        SELECT DISTINCT "INTRD"."ISMINTR_Id", "INTR"."ISMINTR_InteractionId", "INTR"."ISMINTR_ComposedByHRME_Id", 
        "INTR"."ISMINTR_GroupOrIndFlg", "INTR"."ISMINTR_Subject", "INTR"."ISMINTR_DateTime", "INTR"."ISMINTR_Interaction",
        NULL::BIGINT AS "ISMINTRD_ToId",
        (SELECT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
        OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = ' || "HRME_Id" || ') AS employeename,

        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
        OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS user_name,
        NULL::TEXT AS "Receiver"

        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id" = "INTRD"."ISMINTR_Id" AND "INTRD"."ISMINTRD_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_InteractionOrder" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "INTR"."ISMINTR_ComposedByHRME_Id" AND "HRME_ActiveFlag" = 1 
        WHERE "INTR"."MI_Id" = ' || "MI_Id" || ' AND "INTR"."ISMINTR_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_ToId" = ' || "HRME_Id";

        EXECUTE "Slqdymaic1";
        EXECUTE "Slqdymaic2";

        RETURN QUERY
        SELECT * FROM "Interaction_Temp1"
        UNION ALL
        SELECT * FROM "Interaction_Temp2" 
        ORDER BY "ISMINTR_DateTime" DESC;

    ELSE
        "Slqdymaic1" := '
        CREATE TEMP TABLE "Interaction_Temp1" AS
        SELECT DISTINCT "INTRD"."ISMINTR_Id", "INTR"."ISMINTR_InteractionId", "INTR"."ISMINTR_ComposedByHRME_Id", 
        "INTR"."ISMINTR_GroupOrIndFlg", "INTR"."ISMINTR_Subject", "INTR"."ISMINTR_DateTime", "INTR"."ISMINTR_Interaction",
        "INTRD"."ISMINTRD_ToId",
        (SELECT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
        OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = ' || "HRME_Id" || ') AS employeename,

        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
        OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "Sender",
        
        (SELECT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
        OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" interc WHERE interc."HRME_Id" = "INTRD"."ISMINTRD_ToId") AS "Receiver"

        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id" = "INTRD"."ISMINTR_Id" AND "INTRD"."ISMINTRD_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_InteractionOrder" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "INTR"."ISMINTR_ComposedByHRME_Id" AND "HRME_ActiveFlag" = 1 
        WHERE "INTR"."MI_Id" = ' || "MI_Id" || ' AND "INTR"."ISMINTR_ActiveFlag" = 1 AND "INTR"."ISMINTR_ComposedByHRME_Id" = ' || "HRME_Id" || ' AND "INTRD"."ISMINTR_Id" = ' || "ISMINTR_Id";

        "Slqdymaic2" := '
        CREATE TEMP TABLE "Interaction_Temp2" AS
        SELECT DISTINCT "INTRD"."ISMINTR_Id", "INTR"."ISMINTR_InteractionId", "INTR"."ISMINTR_ComposedByHRME_Id", 
        "INTR"."ISMINTR_GroupOrIndFlg", "INTR"."ISMINTR_Subject", "INTR"."ISMINTR_DateTime", "INTR"."ISMINTR_Interaction",
        "INTRD"."ISMINTRD_ToId",
        (SELECT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
        OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = ' || "HRME_Id" || ') AS employeename,

        (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = '''' 
        OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "Sender",
        
        (SELECT (CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '''' THEN '''' ELSE 
        "HRME_EmployeeFirstName" END || CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '''' 
        OR "HRME_EmployeeMiddleName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" IS NULL
        OR "HRME_EmployeeLastName" = '''' OR "HRME_EmployeeLastName" = ''0'' THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" interc WHERE interc."HRME_Id" = "INTRD"."ISMINTRD_ToId") AS "Receiver"

        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id" = "INTRD"."ISMINTR_Id" AND "INTRD"."ISMINTRD_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_InteractionOrder" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "INTR"."ISMINTR_ComposedByHRME_Id" AND "HRME_ActiveFlag" = 1 
        WHERE "INTR"."MI_Id" = ' || "MI_Id" || ' AND "INTR"."ISMINTR_ActiveFlag" = 1 AND "INTRD"."ISMINTR_Id" = ' || "ISMINTR_Id";

        EXECUTE "Slqdymaic1";
        EXECUTE "Slqdymaic2";

        RETURN QUERY
        SELECT * FROM "Interaction_Temp1"
        UNION ALL
        SELECT * FROM "Interaction_Temp2" 
        ORDER BY "ISMINTR_DateTime" DESC;

    END IF;

    RETURN;
END;
$$;