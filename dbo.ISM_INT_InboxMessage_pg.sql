CREATE OR REPLACE FUNCTION "dbo"."ISM_INT_InboxMessage"(
    "p_MI_Id" VARCHAR(100),
    "p_HRME_Id" VARCHAR(100),
    "p_ISMINTR_Id" VARCHAR(100),
    "p_Type_Id" VARCHAR(50)
)
RETURNS TABLE(
    "ISMINTR_Id" BIGINT,
    "ISMINTR_InteractionId" VARCHAR,
    "ISMINTR_ComposedByHRME_Id" BIGINT,
    "ISMINTR_GroupOrIndFlg" VARCHAR,
    "ISMINTR_Subject" TEXT,
    "ISMINTR_DateTime" TIMESTAMP,
    "ISMINTR_Interaction" TEXT,
    "messageflg" VARCHAR,
    "ISMINTRD_ToId" BIGINT,
    "employeename" TEXT,
    "user_name_or_sender" TEXT,
    "Receiver" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic1" TEXT;
    "v_Slqdymaic2" TEXT;
BEGIN
    DROP TABLE IF EXISTS "Interaction_Temp1";
    DROP TABLE IF EXISTS "Interaction_Temp2";

    IF "p_Type_Id" = '1' THEN
        "v_Slqdymaic1" := '
        CREATE TEMP TABLE "Interaction_Temp1" AS
        SELECT DISTINCT "INTRD"."ISMINTR_Id", "INTR"."ISMINTR_InteractionId", "ISMINTR_ComposedByHRME_Id", "ISMINTR_GroupOrIndFlg", 
               "ISMINTR_Subject", "ISMINTR_DateTime", "ISMINTR_Interaction",
               ''S''::VARCHAR AS messageflg,
               NULL::BIGINT AS "ISMINTRD_ToId",
               (SELECT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                       CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                       CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = ' || "p_HRME_Id" || ') AS employeename,
               (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                     THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                     THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS user_name,
               NULL::TEXT AS "Receiver"
        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id" = "INTRD"."ISMINTR_Id" 
               AND "INTRD"."ISMINTRD_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_InteractionOrder" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "INTR"."ISMINTR_ComposedByHRME_Id" AND "HRME_ActiveFlag" = 1
        WHERE "INTR"."ISMINTR_ActiveFlag" = 1 AND "INTR"."ISMINTR_ComposedByHRME_Id" = ' || "p_HRME_Id";

        "v_Slqdymaic2" := '
        CREATE TEMP TABLE "Interaction_Temp2" AS
        SELECT DISTINCT "INTRD"."ISMINTR_Id", "INTR"."ISMINTR_InteractionId", "ISMINTR_ComposedByHRME_Id", "ISMINTR_GroupOrIndFlg", 
               "ISMINTR_Subject", "ISMINTR_DateTime", "ISMINTR_Interaction",
               ''R''::VARCHAR AS messageflg,
               NULL::BIGINT AS "ISMINTRD_ToId",
               (SELECT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                       CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                       CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = ' || "p_HRME_Id" || ') AS employeename,
               (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                     THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                     THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS user_name,
               NULL::TEXT AS "Receiver"
        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id" = "INTRD"."ISMINTR_Id" 
               AND "INTRD"."ISMINTRD_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_InteractionOrder" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "INTR"."ISMINTR_ComposedByHRME_Id" AND "HRME_ActiveFlag" = 1
        WHERE "INTR"."ISMINTR_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_ToId" = ' || "p_HRME_Id";

        EXECUTE "v_Slqdymaic1";
        EXECUTE "v_Slqdymaic2";

        RETURN QUERY
        SELECT * FROM "Interaction_Temp1"
        UNION ALL
        SELECT * FROM "Interaction_Temp2"
        ORDER BY "ISMINTR_DateTime"::TIMESTAMP DESC;

    ELSE
        "v_Slqdymaic1" := '
        CREATE TEMP TABLE "Interaction_Temp1" AS
        SELECT DISTINCT "INTRD"."ISMINTR_Id", "INTR"."ISMINTR_InteractionId", "ISMINTR_ComposedByHRME_Id", "ISMINTR_GroupOrIndFlg", 
               "ISMINTR_Subject", "ISMINTR_DateTime", "ISMINTR_Interaction",
               ''S''::VARCHAR AS messageflg,
               "INTRD"."ISMINTRD_ToId",
               (SELECT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                       CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                       CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = ' || "p_HRME_Id" || ') AS employeename,
               (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                     THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                     THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "Sender",
               (SELECT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                       CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                       CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" interc WHERE interc."HRME_Id" = "INTRD"."ISMINTRD_ToId") AS "Receiver"
        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id" = "INTRD"."ISMINTR_Id" 
               AND "INTRD"."ISMINTRD_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_InteractionOrder" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "INTR"."ISMINTR_ComposedByHRME_Id" AND "HRME_ActiveFlag" = 1
        WHERE "INTR"."ISMINTR_ActiveFlag" = 1 AND "INTR"."ISMINTR_ComposedByHRME_Id" = ' || "p_HRME_Id" || 
               ' AND "INTRD"."ISMINTR_Id" = ' || "p_ISMINTR_Id";

        "v_Slqdymaic2" := '
        CREATE TEMP TABLE "Interaction_Temp2" AS
        SELECT DISTINCT "INTRD"."ISMINTR_Id", "INTR"."ISMINTR_InteractionId", "ISMINTR_ComposedByHRME_Id", "ISMINTR_GroupOrIndFlg", 
               "ISMINTR_Subject", "ISMINTR_DateTime", "ISMINTR_Interaction",
               ''R''::VARCHAR AS messageflg,
               "INTRD"."ISMINTRD_ToId",
               (SELECT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                       CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                       CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" assi WHERE assi."HRME_Id" = ' || "p_HRME_Id" || ') AS employeename,
               (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                     THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                     THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "Sender",
               (SELECT (COALESCE("HME"."HRME_EmployeeFirstName", '''') || 
                       CASE WHEN COALESCE("HRME_EmployeeMiddleName", '''') = '''' OR "HRME_EmployeeMiddleName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || 
                       CASE WHEN COALESCE("HRME_EmployeeLastName", '''') = '''' OR "HRME_EmployeeLastName" = ''0'' 
                            THEN '''' ELSE '' '' || "HRME_EmployeeLastName" END)
                FROM "HR_Master_Employee" interc WHERE interc."HRME_Id" = "INTRD"."ISMINTRD_ToId") AS "Receiver"
        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id" = "INTRD"."ISMINTR_Id" 
               AND "INTRD"."ISMINTRD_ActiveFlag" = 1 AND "INTRD"."ISMINTRD_InteractionOrder" = 1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "INTR"."ISMINTR_ComposedByHRME_Id" AND "HRME_ActiveFlag" = 1 
               AND "ISMINTR_ComposedByHRME_Id" <> ' || "p_HRME_Id" || '
        WHERE "INTR"."ISMINTR_ActiveFlag" = 1 AND "INTRD"."ISMINTR_Id" = ' || "p_ISMINTR_Id";

        EXECUTE "v_Slqdymaic1";
        EXECUTE "v_Slqdymaic2";

        RETURN QUERY
        SELECT * FROM "Interaction_Temp1"
        UNION ALL
        SELECT * FROM "Interaction_Temp2"
        ORDER BY "ISMINTR_DateTime"::TIMESTAMP DESC;

    END IF;

    RETURN;
END;
$$;