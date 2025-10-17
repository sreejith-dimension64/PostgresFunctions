CREATE OR REPLACE FUNCTION "dbo"."COE_Auto_Scheduler_Trigger"(
    INOUT "@MI_Id" TEXT,
    INOUT "@ASMAY_Id" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
BEGIN

    SELECT "ASMAY_Id" INTO "@ASMAY_Id"
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = "@MI_Id" 
        AND "Is_Active" = 1 
        AND (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAY_To_Date" AS DATE));

    RETURN QUERY
    SELECT "COEE_Id", 
           "COEE_ActiveFlag", 
           "MI_Id", 
           "ASMAY_Id", 
           "COEME_Id", 
           "COEE_RepeatFlag", 
           "COEE_ReminderSchedule"
    FROM "COE"."COE_Events"
    WHERE "MI_Id" = "@MI_Id" 
        AND "ASMAY_Id" = "@ASMAY_Id" 
        AND "COEE_ActiveFlag" = 1 
        AND CAST("COEE_ReminderDate" AS DATE) = CURRENT_DATE
        AND ("COEE_SMSActiveFlag" = 1 OR "COEE_MailActiveFlag" = 1);

END;
$$;