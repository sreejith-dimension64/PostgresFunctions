CREATE OR REPLACE FUNCTION "dbo"."ChairmanAuditComarision_Report"(
    p_USERID bigint,
    p_FromDate date,
    p_ToDate date,
    p_TypeFlag varchar(100)
)
RETURNS TABLE (
    "MI_Name" varchar,
    "MI_Id" bigint,
    "FYPRecordsCount" bigint,
    "ITAT_TableName" varchar,
    "ITAT_Operation" varchar,
    "DeletedDate" timestamp,
    "FYP_Id" bigint,
    "IATD_ColumnName" varchar,
    "IATD_PreviousValue" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_TypeFlag = 'All') THEN
        RETURN QUERY
        SELECT 
            "MI"."MI_Name",
            "TA"."MI_Id",
            COUNT(DISTINCT "TA"."ITAT_RecordPKID") AS "FYPRecordsCount",
            NULL::varchar AS "ITAT_TableName",
            NULL::varchar AS "ITAT_Operation",
            NULL::timestamp AS "DeletedDate",
            NULL::bigint AS "FYP_Id",
            NULL::varchar AS "IATD_ColumnName",
            NULL::text AS "IATD_PreviousValue"
        FROM "IVRM_Table_AuditTrail" "TA"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "TA"."MI_Id"
        WHERE "TA"."ITAT_Operation" = 'D' 
            AND "TA"."ITAT_TableName" = 'Fee_Y_Payment' 
            AND "TA"."MI_Id" IN (
                SELECT DISTINCT "MI_Id" 
                FROM "IVRM_User_Login_Institutionwise" 
                WHERE "id" IN (
                    SELECT DISTINCT "UserId" 
                    FROM "ApplicationUserRole" 
                    WHERE "UserId" = p_USERID
                )
            ) 
            AND CAST("TA"."ITAT_Date" AS date) BETWEEN p_FromDate AND p_ToDate
        GROUP BY "MI"."MI_Name", "TA"."MI_Id";

    ELSIF (p_TypeFlag = 'Details') THEN
        RETURN QUERY
        SELECT 
            "MI"."MI_Name",
            "TA"."MI_Id",
            NULL::bigint AS "FYPRecordsCount",
            "TA"."ITAT_TableName",
            "TA"."ITAT_Operation",
            "TA"."ITAT_Date" AS "DeletedDate",
            "TA"."ITAT_RecordPKID" AS "FYP_Id",
            "AD"."IATD_ColumnName",
            "AD"."IATD_PreviousValue"
        FROM "IVRM_Table_AuditTrail" "TA"
        INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "TA"."MI_Id"
        INNER JOIN "IVRM_AuditTrail_Deatils" "AD" ON "TA"."ITAT_Id" = "AD"."ITAT_Id"
        WHERE "TA"."ITAT_Operation" = 'D' 
            AND "TA"."ITAT_TableName" = 'Fee_Y_Payment' 
            AND "TA"."MI_Id" = p_USERID 
            AND CAST("TA"."ITAT_Date" AS date) BETWEEN p_FromDate AND p_ToDate;

    END IF;

    RETURN;

END;
$$;