CREATE OR REPLACE FUNCTION "dbo"."IVRM_BirthDay_YearlyMonthlyCount"(
    p_MI_Id bigint,
    p_Type varchar(200),
    p_Flag varchar(200)
)
RETURNS TABLE (
    "CYear" bigint,
    "MonthName" varchar,
    "BirthCount" bigint,
    "SMSSentCount" bigint,
    "EmailSentCount" bigint
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
        AND CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAY_To_Date" AS date);

    IF (p_Type = 'Monthly') THEN
    
        IF (p_Flag = 'Student') THEN
        
            RETURN QUERY
            WITH "StudentBTH" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    "IM"."IVRM_Month_Name",
                    COUNT(*) AS "STUBCount"
                FROM "Adm_M_Student" "AMS"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("AMS"."AMST_DOB", 'Month')
                WHERE "AMS"."MI_Id" = p_MI_Id 
                    AND "ASYS"."ASMAY_Id" = v_ASMAY_Id 
                    AND "AMS"."AMST_SOL" = 'S' 
                    AND "AMS"."AMST_ActiveFlag" = 1 
                    AND "ASYS"."Amay_ActiveFlag" = 1
                GROUP BY "IM"."IVRM_Month_Name", "IM"."IVRM_Month_Id"
            ),
            "STUSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STUSMSSentCount"
                FROM "IVRM_sms_sentBox"
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date
                    AND "Module_Name" = 'BIRTHDAY' 
                    AND "To_FLag" = 'Student'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IM"."IVRM_Month_Id"
            ),
            "STUEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STUEmailSentCount"
                FROM "IVRM_Email_sentBox"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date
                    AND "Module_Name" = 'BIRTHDAY' 
                    AND "To_FLag" = 'Student'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IM"."IVRM_Month_Id"
            )
            SELECT 
                "A"."CYear",
                "A"."IVRM_Month_Name",
                "A"."STUBCount",
                COALESCE("B"."STUSMSSentCount", 0),
                COALESCE("C"."STUEmailSentCount", 0)
            FROM "StudentBTH" "A"
            LEFT JOIN "STUSMSSent" "B" ON "A"."IVRM_Month_Id" = "B"."IVRM_Month_Id"
            LEFT JOIN "STUEmailSent" "C" ON "A"."IVRM_Month_Id" = "C"."IVRM_Month_Id"
            ORDER BY "A"."IVRM_Month_Id";
            
        ELSIF (p_Flag = 'Staff') THEN
        
            RETURN QUERY
            WITH "StaffBTH" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    "IM"."IVRM_Month_Name",
                    COUNT(*) AS "EMPBCount"
                FROM "HR_Master_Employee" "HM"
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("HM"."HRME_DOB", 'Month')
                WHERE "HM"."MI_Id" = p_MI_Id 
                    AND "HM"."HRME_ActiveFlag" = 1 
                    AND "HM"."HRME_LeftFlag" = 0
                GROUP BY "IM"."IVRM_Month_Name", "IM"."IVRM_Month_Id"
            ),
            "StaffSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STSMSSentCount"
                FROM "IVRM_sms_sentBox"
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date
                    AND "Module_Name" = 'BIRTHDAY' 
                    AND "To_FLag" = 'Staff'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IM"."IVRM_Month_Id"
            ),
            "StaffEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STEmailSentCount"
                FROM "IVRM_Email_sentBox"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date
                    AND "Module_Name" = 'BIRTHDAY' 
                    AND "To_FLag" = 'Staff'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IM"."IVRM_Month_Id"
            )
            SELECT 
                "A"."CYear",
                "A"."IVRM_Month_Name",
                "A"."EMPBCount",
                COALESCE("B"."STSMSSentCount", 0),
                COALESCE("C"."STEmailSentCount", 0)
            FROM "StaffBTH" "A"
            LEFT JOIN "StaffSMSSent" "B" ON "A"."IVRM_Month_Id" = "B"."IVRM_Month_Id"
            LEFT JOIN "StaffEmailSent" "C" ON "A"."IVRM_Month_Id" = "C"."IVRM_Month_Id"
            ORDER BY "A"."IVRM_Month_Id";
            
        END IF;
        
    ELSIF (p_Type = 'Yearly') THEN
    
        IF (p_Flag = 'Student') THEN
        
            RETURN QUERY
            WITH "StudentBTH" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS bigint) AS "CYear",
                    COUNT(*) AS "STUBCount"
                FROM "Adm_M_Student" "AMS"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                WHERE "AMS"."MI_Id" = p_MI_Id 
                    AND "ASYS"."ASMAY_Id" = v_ASMAY_Id 
                    AND "AMS"."AMST_SOL" = 'S' 
                    AND "AMS"."AMST_ActiveFlag" = 1 
                    AND "ASYS"."Amay_ActiveFlag" = 1
            ),
            "STUSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STUSMSSentCount"
                FROM "IVRM_sms_sentBox"
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date
                    AND "Module_Name" = 'BIRTHDAY' 
                    AND "To_FLag" = 'Student'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
            ),
            "STUEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STUEmailSentCount"
                FROM "IVRM_Email_sentBox"
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date
                    AND "Module_Name" = 'BIRTHDAY' 
                    AND "To_FLag" = 'Student'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
            )
            SELECT 
                "A"."CYear",
                NULL::varchar AS "MonthName",
                "A"."STUBCount",
                COALESCE("B"."STUSMSSentCount", 0),
                COALESCE("C"."STUEmailSentCount", 0)
            FROM "StudentBTH" "A"
            LEFT JOIN "STUSMSSent" "B" ON "A"."CYear" = "B"."CYear"
            LEFT JOIN "STUEmailSent" "C" ON "A"."CYear" = "C"."CYear"
            ORDER BY "A"."CYear";
            
        ELSIF (p_Flag = 'Staff') THEN
        
            RETURN QUERY
            WITH "StaffBTH" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_DATE) AS bigint) AS "CYear",
                    COUNT(*) AS "EMPBCount"
                FROM "HR_Master_Employee" "HM"
                WHERE "HM"."MI_Id" = p_MI_Id 
                    AND "HM"."HRME_ActiveFlag" = 1 
                    AND "HM"."HRME_LeftFlag" = 0
            ),
            "StaffSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STSMSSentCount"
                FROM "IVRM_sms_sentBox"
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date
                    AND "Module_Name" = 'BIRTHDAY' 
                    AND "To_FLag" = 'Staff'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
            ),
            "StaffEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STEmailSentCount"
                FROM "IVRM_Email_sentBox"
                WHERE "MI_Id" = p_MI_Id 
                    AND CAST("Datetime" AS date) BETWEEN v_From_Date AND v_To_Date
                    AND "Module_Name" = 'BIRTHDAY' 
                    AND "To_FLag" = 'Staff'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
            )
            SELECT 
                "A"."CYear",
                NULL::varchar AS "MonthName",
                "A"."EMPBCount",
                COALESCE("B"."STSMSSentCount", 0),
                COALESCE("C"."STEmailSentCount", 0)
            FROM "StaffBTH" "A"
            LEFT JOIN "StaffSMSSent" "B" ON "A"."CYear" = "B"."CYear"
            LEFT JOIN "StaffEmailSent" "C" ON "A"."CYear" = "C"."CYear"
            ORDER BY "A"."CYear";
            
        END IF;
        
    END IF;
    
    RETURN;
    
END;
$$;