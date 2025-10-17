CREATE OR REPLACE FUNCTION "dbo"."ISM_INT_ReplyMessage" (
    "MI_Id" VARCHAR(100), 
    "HRME_Id" VARCHAR(100), 
    "ISMINTR_Id" VARCHAR(100)
)
RETURNS TABLE (
    "ISMINTR_Id" INTEGER,
    "ISMINTRD_Id" INTEGER,
    "ISMINTRD_ComposedById" INTEGER,
    "ISMINTRD_Interaction" TEXT,
    "ISMINTRD_DateTime" TIMESTAMP,
    "ISMINTRD_InteractionOrder" INTEGER,
    "ISMINTRD_ActiveFlag" BOOLEAN,
    "ISMINTR_InteractionId" VARCHAR,
    "ISMINTR_GroupOrIndFlg" VARCHAR,
    "ISMINTR_Subject" TEXT,
    "ISMINTR_DateTime" TIMESTAMP,
    "ISMINTR_Interaction" TEXT,
    "messageflg" VARCHAR(1),
    "employeename" TEXT,
    "Sender" TEXT,
    "Receiver" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic1" TEXT;
    "Slqdymaic2" TEXT;
BEGIN
    DROP TABLE IF EXISTS "Reply_Temp1";
    DROP TABLE IF EXISTS "Reply_Temp2";

    "Slqdymaic1" := '
        SELECT DISTINCT "INTRD"."ISMINTR_Id","ISMINTRD_Id","ISMINTRD_ComposedById","ISMINTRD_Interaction","ISMINTRD_DateTime","ISMINTRD_InteractionOrder","ISMINTRD_ActiveFlag",
        "INTR"."ISMINTR_InteractionId","ISMINTR_GroupOrIndFlg","ISMINTR_Subject","ISMINTR_DateTime","ISMINTR_Interaction",''S'' as messageflg,
        (select (CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" assi where assi."HRME_Id"=1393 ) as employeename,

        (CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
        or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "Sender",
    
        (select (CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" interc where interc."HRME_Id"="INTRD"."ISMINTRD_ToId") AS "Receiver"

        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id"="INTRD"."ISMINTR_Id" and "INTRD"."ISMINTRD_ActiveFlag"=true AND  "INTRD"."ISMINTRD_InteractionOrder"!=1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="INTRD"."ISMINTRD_ComposedById" AND "HRME_ActiveFlag"=true 
        WHERE  "INTR"."ISMINTR_ActiveFlag"=true and "INTRD"."ISMINTRD_ComposedById"=' || "HRME_Id" || ' AND "INTRD"."ISMINTR_Id"=' || "ISMINTR_Id";
        
    "Slqdymaic2" := '            
        SELECT DISTINCT "INTRD"."ISMINTR_Id","ISMINTRD_Id","ISMINTRD_ComposedById","ISMINTRD_Interaction","ISMINTRD_DateTime","ISMINTRD_InteractionOrder","ISMINTRD_ActiveFlag",
        "INTR"."ISMINTR_InteractionId","ISMINTR_GroupOrIndFlg","ISMINTR_Subject","ISMINTR_DateTime","ISMINTR_Interaction",''R'' as messageflg,
        (select (CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" assi where assi."HRME_Id"=1393 ) as employeename,

        (CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null or "HRME_EmployeeLastName" = '''' 
        or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END) AS "Sender",
    
        (select (CASE WHEN "HME"."HRME_EmployeeFirstName" is null or "HRME_EmployeeFirstName"='''' then '''' else 
        "HRME_EmployeeFirstName" end || CASE WHEN "HRME_EmployeeMiddleName" is null or "HRME_EmployeeMiddleName" = '''' 
        or "HRME_EmployeeMiddleName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeMiddleName" END || CASE WHEN "HRME_EmployeeLastName" is null
        or "HRME_EmployeeLastName" = '''' or "HRME_EmployeeLastName" = ''0'' then '''' ELSE '' '' || "HRME_EmployeeLastName" END) 
        FROM "HR_Master_Employee" interc where interc."HRME_Id"="INTRD"."ISMINTRD_ToId") as "Receiver"

        FROM "ISM_Interactions" "INTR"
        INNER JOIN "ISM_Interactions_Details" "INTRD" ON "INTR"."ISMINTR_Id"="INTRD"."ISMINTR_Id" and "INTRD"."ISMINTRD_ActiveFlag"=true AND "INTRD"."ISMINTRD_InteractionOrder"!=1
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="INTRD"."ISMINTRD_ComposedById" AND "HRME_ActiveFlag"=true  AND  "ISMINTRD_ComposedById" NOT IN (' || "HRME_Id" || ')
        WHERE "INTR"."ISMINTR_ActiveFlag"=true AND "INTRD"."ISMINTR_Id"=' || "ISMINTR_Id";
    
    EXECUTE 'CREATE TEMP TABLE "Reply_Temp1" AS ' || "Slqdymaic1";
    EXECUTE 'CREATE TEMP TABLE "Reply_Temp2" AS ' || "Slqdymaic2";
    
    RETURN QUERY
    SELECT * FROM "Reply_Temp1"
    UNION ALL
    SELECT * FROM "Reply_Temp2"
    ORDER BY "ISMINTRD_DateTime"::TIMESTAMP DESC;
    
    DROP TABLE IF EXISTS "Reply_Temp1";
    DROP TABLE IF EXISTS "Reply_Temp2";
    
    RETURN;
END;
$$;