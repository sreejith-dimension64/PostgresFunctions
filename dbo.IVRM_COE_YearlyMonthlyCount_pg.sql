CREATE OR REPLACE FUNCTION "dbo"."IVRM_COE_YearlyMonthlyCount"(
    p_MI_Id bigint,
    p_Type varchar(200),
    p_Flag varchar(200)
)
RETURNS TABLE(
    "CYear" bigint,
    "IVRM_Month_Name" varchar,
    "STUECount" bigint,
    "STUCount" bigint,
    "STUSMSSentCount" bigint,
    "STUEmailSentCount" bigint,
    "EMPCount" bigint,
    "STSMSSentCount" bigint,
    "STEmailSentCount" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_From_Date date;
    v_To_Date date;
    v_ASMAY_Id bigint;
BEGIN

    SELECT 
        CAST("ASMAY_From_Date" AS date),
        CAST("ASMAY_To_Date" AS date),
        "ASMAY_Id"
    INTO v_From_Date, v_To_Date, v_ASMAY_Id
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_Id 
        AND CAST(CURRENT_TIMESTAMP AS date) BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAY_To_Date" AS date);

    IF (p_Type = 'Monthly') THEN
    
        IF (p_Flag = 'Student') THEN
        
            RETURN QUERY
            WITH "StudentCOE" AS (
                SELECT 
                    "IM"."IVRM_Month_Id",
                    "IM"."IVRM_Month_Name",
                    COUNT(*) AS "STUECount"
                FROM "COE"."COE_Master_Events" "ME" 
                INNER JOIN "COE"."COE_Events" "CE" ON "ME"."COEME_Id" = "CE"."COEME_Id"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("COEE_EStartDate", 'Month')
                WHERE "ME"."MI_Id" = p_MI_Id AND "CE"."ASMAY_Id" = v_ASMAY_Id  
                GROUP BY "IVRM_Month_Name", "IVRM_Month_Id"
            ),
            "STUSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STUSMSSentCount"
                FROM "IVRM_sms_sentBox" 
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Student' 
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IVRM_Month_Id"
                LIMIT 100
            ),
            "STUEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STUEmailSentCount"
                FROM "IVRM_Email_sentBox" 
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id  
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Student' 
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IVRM_Month_Id"
                LIMIT 100
            ),
            "StudentsCount" AS (
                SELECT 
                    "IVRM_Month_Id",
                    "IVRM_Month_Name",
                    COUNT(*) AS "STUCount"
                FROM "Adm_M_Student" "AMS" 
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("AMAY_DateTime", 'Month')
                WHERE "AMS"."MI_Id" = p_MI_Id 
                    AND "ASYS"."ASMAY_Id" = v_ASMAY_Id 
                    AND "AMST_SOL" = 'S' 
                    AND "AMST_ActiveFlag" = 1 
                    AND "Amay_ActiveFlag" = 1 
                GROUP BY "IVRM_Month_Name", "IVRM_Month_Id"
            )
            SELECT 
                "B"."CYear",
                "A"."IVRM_Month_Name",
                "A"."STUECount",
                "D"."STUCount",
                "B"."STUSMSSentCount",
                "C"."STUEmailSentCount",
                NULL::bigint AS "EMPCount",
                NULL::bigint AS "STSMSSentCount",
                NULL::bigint AS "STEmailSentCount"
            FROM "StudentCOE" "A" 
            INNER JOIN "STUSMSSent" "B" ON "A"."IVRM_Month_Id" = "B"."IVRM_Month_Id"
            INNER JOIN "STUEmailSent" "C" ON "A"."IVRM_Month_Id" = "C"."IVRM_Month_Id" 
            INNER JOIN "StudentsCount" "D" ON "A"."IVRM_Month_Id" = "D"."IVRM_Month_Id"
            ORDER BY "A"."IVRM_Month_Id";
            
        ELSIF (p_Flag = 'Staff') THEN
        
            RETURN QUERY
            WITH "StaffCOE" AS (
                SELECT 
                    "IVRM_Month_Id",
                    "IVRM_Month_Name",
                    COUNT(*) AS "STUECount"
                FROM "COE"."COE_Master_Events" "ME" 
                INNER JOIN "COE"."COE_Events" "CE" ON "ME"."COEME_Id" = "CE"."COEME_Id"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("COEE_EStartDate", 'Month')
                WHERE "ME"."MI_Id" = p_MI_Id AND "CE"."ASMAY_Id" = v_ASMAY_Id  
                GROUP BY "IVRM_Month_Name", "IVRM_Month_Id"
            ),
            "StaffSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STSMSSentCount"
                FROM "IVRM_sms_sentBox" 
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Staff' 
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IVRM_Month_Id"
                LIMIT 100
            ),
            "StaffEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STEmailSentCount"
                FROM "IVRM_Email_sentBox" 
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id  
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Staff' 
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IVRM_Month_Id"
                LIMIT 100
            ),
            "StaffCount" AS (
                SELECT 
                    "IVRM_Month_Id",
                    "IVRM_Month_Name",
                    COUNT(*) AS "EMPCount"
                FROM "HR_Master_Employee" "HM"
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("HM"."HRME_DOJ", 'Month')
                WHERE "MI_Id" = p_MI_Id 
                    AND "HRME_ActiveFlag" = 1 
                    AND "HRME_LeftFlag" = 0  
                GROUP BY "IVRM_Month_Name", "IVRM_Month_Id"
            )
            SELECT 
                "B"."CYear",
                "A"."IVRM_Month_Name",
                "A"."STUECount",
                NULL::bigint AS "STUCount",
                NULL::bigint AS "STUSMSSentCount",
                NULL::bigint AS "STUEmailSentCount",
                "D"."EMPCount",
                "B"."STSMSSentCount",
                "C"."STEmailSentCount"
            FROM "StaffCOE" "A" 
            INNER JOIN "StaffSMSSent" "B" ON "A"."IVRM_Month_Id" = "B"."IVRM_Month_Id"
            INNER JOIN "StaffEmailSent" "C" ON "A"."IVRM_Month_Id" = "C"."IVRM_Month_Id" 
            INNER JOIN "StaffCount" "D" ON "A"."IVRM_Month_Id" = "D"."IVRM_Month_Id"  
            ORDER BY "A"."IVRM_Month_Id";
            
        END IF;
        
    ELSIF (p_Type = 'Yearly') THEN
    
        IF (p_Flag = 'Student') THEN
        
            RETURN QUERY
            WITH "StudentCOE" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "CE"."COEE_EStartDate") AS bigint) AS "CYear",
                    COUNT(*) AS "STUECount"
                FROM "COE"."COE_Master_Events" "ME" 
                INNER JOIN "COE"."COE_Events" "CE" ON "ME"."COEME_Id" = "CE"."COEME_Id"
                WHERE "ME"."MI_Id" = p_MI_Id AND "CE"."ASMAY_Id" = v_ASMAY_Id   
                GROUP BY CAST(EXTRACT(YEAR FROM "CE"."COEE_EStartDate") AS bigint)
                LIMIT 100
            ),
            "STUSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STUSMSSentCount"
                FROM "IVRM_sms_sentBox" 
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Student' 
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
                LIMIT 100
            ),
            "STUEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STUEmailSentCount"
                FROM "IVRM_Email_sentBox" 
                WHERE "MI_Id" = p_MI_Id  
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Student' 
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
                LIMIT 100
            ),
            "StudentsCount" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "AMAY_DateTime") AS bigint) AS "CYear",
                    COUNT(*) AS "STUCount"
                FROM "Adm_M_Student" "AMS" 
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                WHERE "AMS"."MI_Id" = p_MI_Id 
                    AND "ASYS"."ASMAY_Id" = v_ASMAY_Id 
                    AND "AMST_SOL" = 'S' 
                    AND "AMST_ActiveFlag" = 1 
                    AND "Amay_ActiveFlag" = 1  
                GROUP BY CAST(EXTRACT(YEAR FROM "AMAY_DateTime") AS bigint)
                LIMIT 100
            )
            SELECT 
                "B"."CYear",
                NULL::varchar AS "IVRM_Month_Name",
                "A"."STUECount",
                "D"."STUCount",
                "B"."STUSMSSentCount",
                "C"."STUEmailSentCount",
                NULL::bigint AS "EMPCount",
                NULL::bigint AS "STSMSSentCount",
                NULL::bigint AS "STEmailSentCount"
            FROM "StudentCOE" "A" 
            INNER JOIN "STUSMSSent" "B" ON "A"."CYear" = "B"."CYear"
            INNER JOIN "STUEmailSent" "C" ON "A"."CYear" = "C"."CYear" 
            INNER JOIN "StudentsCount" "D" ON "A"."CYear" = "D"."CYear"
            ORDER BY "A"."CYear";
            
        ELSIF (p_Flag = 'Staff') THEN
        
            RETURN QUERY
            WITH "StaffCOE" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "CE"."COEE_EStartDate") AS bigint) AS "CYear",
                    COUNT(*) AS "STUECount"
                FROM "COE"."COE_Master_Events" "ME" 
                INNER JOIN "COE"."COE_Events" "CE" ON "ME"."COEME_Id" = "CE"."COEME_Id" 
                WHERE "ME"."MI_Id" = p_MI_Id AND "CE"."ASMAY_Id" = v_ASMAY_Id   
                GROUP BY CAST(EXTRACT(YEAR FROM "CE"."COEE_EStartDate") AS bigint)
                LIMIT 100
            ),
            "StaffSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STSMSSentCount"
                FROM "IVRM_sms_sentBox" 
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Staff' 
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
                LIMIT 100
            ),
            "StaffEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STEmailSentCount"
                FROM "IVRM_Email_sentBox" 
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id  
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Staff' 
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
                LIMIT 100
            ),
            "StaffCount" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP) AS bigint) AS "CYear",
                    COUNT(*) AS "EMPCount"
                FROM "HR_Master_Employee" "HM" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "HRME_ActiveFlag" = 1 
                    AND "HRME_LeftFlag" = 0
                LIMIT 100
            )
            SELECT 
                "B"."CYear",
                NULL::varchar AS "IVRM_Month_Name",
                "A"."STUECount",
                NULL::bigint AS "STUCount",
                NULL::bigint AS "STUSMSSentCount",
                NULL::bigint AS "STUEmailSentCount",
                "D"."EMPCount",
                "B"."STSMSSentCount",
                "C"."STEmailSentCount"
            FROM "StaffCOE" "A" 
            INNER JOIN "StaffSMSSent" "B" ON "A"."CYear" = "B"."CYear"
            INNER JOIN "StaffEmailSent" "C" ON "A"."CYear" = "C"."CYear" 
            INNER JOIN "StaffCount" "D" ON "A"."CYear" = "D"."CYear"  
            ORDER BY "A"."CYear";
            
        END IF;
        
    END IF;
    
    RETURN;
    
END;
$$;