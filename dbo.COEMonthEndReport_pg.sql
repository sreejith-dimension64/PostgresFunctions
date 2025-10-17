CREATE OR REPLACE FUNCTION "dbo"."COEMonthEndReport"(
    "p_ASMAY_Id" TEXT,
    "p_MI_Id" VARCHAR(10),
    "p_condition" VARCHAR(50),
    "p_month" VARCHAR(10)
)
RETURNS TABLE(
    "EventName" TEXT,
    "EventDate" TIMESTAMP,
    "EventAttendedCount" BIGINT,
    "smsCount" BIGINT,
    "emailCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Sqldynamic" TEXT;
    "v_Sqldynamicstaff" TEXT;
    "v_SqldynamicSS" TEXT;
BEGIN

    IF("p_condition" = 'student') THEN
        "v_Sqldynamic" := 
'SELECT "t"."eventName" as "EventName", "t"."COEE_EStartDate" as "EventDate", "t"."EventAttendedCount", "t"."smsCount", "t"."emailCount"
FROM (
    SELECT DISTINCT "m"."COEME_EventName" AS "eventName", "m"."COEME_EventDesc" AS "eventDesc", "n"."COEE_EStartDate", "n"."COEE_EEndDate", COUNT("o"."COEEO_MobileNo") AS "EventAttendedCount",
  
    (SELECT COUNT(*)  
     FROM "IVRM_sms_sentBox" AS "w" 
     WHERE ("w"."Datetime" = "n"."COEE_EStartDate") 
       AND ("w"."MI_Id" = ' || "p_MI_Id" || ') 
       AND ("w"."Module_Name" = ''Calendar of Event'')
       AND ("w"."To_FLag" = ''Student'')) AS "smsCount",
  
    (SELECT COUNT(*)  
     FROM "ivrm_email_sentbox" AS "q"  
     WHERE ("q"."MI_Id" = ' || "p_MI_Id" || ') 
       AND ("q"."Datetime" = "n"."COEE_EStartDate") 
       AND ("q"."Module_Name" = ''Calendar of Event'') 
       AND ("q"."To_FLag" = ''Student'')) AS "emailCount"
     
    FROM "COE"."COE_Master_Events" AS "m"
    CROSS JOIN "COE"."COE_Events" AS "n"
    CROSS JOIN "COE"."COE_Events_Others" AS "o"
    WHERE ("m"."COEME_Id" = "n"."COEME_Id") 
      AND ("n"."MI_Id" = ' || "p_MI_Id" || ') 
      AND ("n"."ASMAY_Id" = ' || "p_ASMAY_Id" || ') 
      AND ("o"."COEE_Id" = "n"."COEE_Id")  
      AND (EXTRACT(MONTH FROM "n"."COEE_EStartDate") = ' || "p_month" || ') 
      AND ("m"."COEME_ActiveFlag" = 1) 
      AND ("n"."COEE_ActiveFlag" = 1)
    GROUP BY "m"."COEME_EventName", "m"."COEME_EventDesc", "n"."COEE_EStartDate", "n"."COEE_EEndDate"
) AS "t"
ORDER BY "t"."COEE_EStartDate"';
        
        RETURN QUERY EXECUTE "v_Sqldynamic";
    END IF;

    IF("p_condition" = 'staff') THEN
        "v_Sqldynamicstaff" := 
'SELECT "t"."eventName" as "EventName", "t"."COEE_EStartDate" as "EventDate", "t"."EventAttendedCount", "t"."smsCount", "t"."emailCount"
FROM (
    SELECT DISTINCT "m"."COEME_EventName" AS "eventName", "m"."COEME_EventDesc" AS "eventDesc", "n"."COEE_EStartDate", "n"."COEE_EEndDate", COUNT("o"."COEEO_MobileNo") AS "EventAttendedCount",
 
    (SELECT COUNT(*)  
     FROM "IVRM_sms_sentBox" AS "w" 
     WHERE ("w"."Datetime" = "n"."COEE_EStartDate") 
       AND ("w"."MI_Id" = ' || "p_MI_Id" || ') 
       AND ("w"."Module_Name" = ''Calendar of Event'')
       AND ("w"."To_FLag" = ''Staff'')) AS "smsCount",
  
    (SELECT COUNT(*)  
     FROM "ivrm_email_sentbox" AS "q"  
     WHERE ("q"."MI_Id" = ' || "p_MI_Id" || ') 
       AND ("q"."Datetime" = "n"."COEE_EStartDate") 
       AND ("q"."Module_Name" = ''Calendar of Event'') 
       AND ("q"."To_FLag" = ''Staff'')) AS "emailCount"
     
    FROM "COE"."COE_Master_Events" AS "m"
    CROSS JOIN "COE"."COE_Events" AS "n"
    CROSS JOIN "COE"."COE_Events_Others" AS "o"
    WHERE ("m"."COEME_Id" = "n"."COEME_Id") 
      AND ("n"."MI_Id" = ' || "p_MI_Id" || ') 
      AND ("n"."ASMAY_Id" = ' || "p_ASMAY_Id" || ') 
      AND ("o"."COEE_Id" = "n"."COEE_Id")  
      AND (EXTRACT(MONTH FROM "n"."COEE_EStartDate") = ' || "p_month" || ') 
      AND ("m"."COEME_ActiveFlag" = 1) 
      AND ("n"."COEE_ActiveFlag" = 1)
    GROUP BY "m"."COEME_EventName", "m"."COEME_EventDesc", "n"."COEE_EStartDate", "n"."COEE_EEndDate"
) AS "t"
ORDER BY "t"."COEE_EStartDate"';
        
        RETURN QUERY EXECUTE "v_Sqldynamicstaff";
    END IF;

    IF("p_condition" = 'studentstaff') THEN
        "v_SqldynamicSS" := 
'SELECT "t"."eventName" as "EventName", "t"."COEE_EStartDate" as "EventDate", "t"."EventAttendedCount", "t"."smsCount", "t"."emailCount"
FROM (
    SELECT DISTINCT "m"."COEME_EventName" AS "eventName", "m"."COEME_EventDesc" AS "eventDesc", "n"."COEE_EStartDate", "n"."COEE_EEndDate", COUNT("o"."COEEO_MobileNo") AS "EventAttendedCount",
  
    (SELECT COUNT(*)  
     FROM "IVRM_sms_sentBox" AS "w" 
     WHERE ("w"."Datetime" = "n"."COEE_EStartDate") 
       AND ("w"."MI_Id" = ' || "p_MI_Id" || ') 
       AND ("w"."Module_Name" = ''Calendar of Event'')
       AND (("w"."To_FLag" = ''Student'') OR ("w"."To_FLag" = ''Staff''))) AS "smsCount",
  
    (SELECT COUNT(*)  
     FROM "ivrm_email_sentbox" AS "q"  
     WHERE ("q"."MI_Id" = ' || "p_MI_Id" || ') 
       AND ("q"."Datetime" = "n"."COEE_EStartDate") 
       AND ("q"."Module_Name" = ''Calendar of Event'') 
       AND (("q"."To_FLag" = ''Student'') OR ("q"."To_FLag" = ''Staff''))) AS "emailCount"
     
    FROM "COE"."COE_Master_Events" AS "m"
    CROSS JOIN "COE"."COE_Events" AS "n"
    CROSS JOIN "COE"."COE_Events_Others" AS "o"
    WHERE ("m"."COEME_Id" = "n"."COEME_Id") 
      AND ("n"."MI_Id" = ' || "p_MI_Id" || ') 
      AND ("n"."ASMAY_Id" = ' || "p_ASMAY_Id" || ') 
      AND ("o"."COEE_Id" = "n"."COEE_Id")  
      AND (EXTRACT(MONTH FROM "n"."COEE_EStartDate") = ' || "p_month" || ') 
      AND ("m"."COEME_ActiveFlag" = 1) 
      AND ("n"."COEE_ActiveFlag" = 1)
    GROUP BY "m"."COEME_EventName", "m"."COEME_EventDesc", "n"."COEE_EStartDate", "n"."COEE_EEndDate"
) AS "t"
ORDER BY "t"."COEE_EStartDate"';
        
        RETURN QUERY EXECUTE "v_SqldynamicSS";
    END IF;

END;
$$;