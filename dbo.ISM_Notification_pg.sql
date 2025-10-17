CREATE OR REPLACE FUNCTION "dbo"."ISM_Notification"(
    "@MI_Id" BIGINT,
    "@HRME_Id" BIGINT
)
RETURNS TABLE(
    "ISMPN_Id" BIGINT,
    "HRME_Id" BIGINT,
    "ISM_CommonId" BIGINT,
    "ISM_CreatedDate" TIMESTAMP,
    "ISMPN_Notification" TEXT,
    "tasktype" TEXT,
    "ISMPN_Type" TEXT,
    "ISMPN_Date" DATE,
    "ISMPN_Time" TIME,
    "ISMPN_ActiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "IPN"."ISMPN_Id",
        "IPN"."HRME_Id",
        "IPN"."ISM_CommonId",
        "IPN"."ISM_CreatedDate",
        "IPN"."ISMPN_Notification",
        (CASE 
            WHEN "IPN"."ISMPN_Type" = 'DR' THEN 'Daily Report'
            WHEN "IPN"."ISMPN_Type" = 'PL' THEN 'Planner'
            ELSE "IPN"."ISMPN_Type" 
        END)::TEXT AS "tasktype",
        "IPN"."ISMPN_Type",
        "IPN"."ISMPN_Date",
        "IPN"."ISMPN_Time",
        "IPN"."ISMPN_ActiveFlg"
    FROM "ISM_PushNotification" "IPN"
    LEFT JOIN "HR_Master_Employee" "EMP" ON "IPN"."HRME_Id" = "EMP"."HRME_Id"
    WHERE "IPN"."MI_Id" = "@MI_Id" AND "IPN"."HRME_Id" = "@HRME_Id";
END;
$$;