CREATE OR REPLACE FUNCTION "dbo"."IVRM_Library_YearlyMonthlyCount"(
    "p_MI_Id" bigint,
    "p_Type" varchar(200),
    "p_Flag" varchar(200)
)
RETURNS TABLE(
    "CYear" bigint,
    "IVRM_Month_Name" varchar,
    "STUBooksCount" bigint,
    "Count2" bigint,
    "SMSSentCount" bigint,
    "EmailSentCount" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_From_Date" date;
    "v_To_Date" date;
    "v_ASMAY_Id" bigint;
BEGIN

    SELECT 
        CAST("ASMAY_From_Date" AS date),
        CAST("ASMAY_To_Date" AS date),
        "ASMAY_Id"
    INTO 
        "v_From_Date",
        "v_To_Date",
        "v_ASMAY_Id"
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = "p_MI_Id" 
        AND CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAY_To_Date" AS date);

    IF "p_Type" = 'Monthly' THEN
        
        IF "p_Flag" = 'Student' THEN
            
            RETURN QUERY
            WITH "STUBooks" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP) AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    "IM"."IVRM_Month_Name",
                    COUNT(*) AS "STUBooksCount"
                FROM "LIB"."Lib_Master_Book" "LB"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("LB"."LMB_EntryDate", 'Month')
                WHERE "LB"."MI_Id" = "p_MI_Id"
                GROUP BY "IM"."IVRM_Month_Name", "IM"."IVRM_Month_Id"
            ), "STUSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STUSMSSentCount"
                FROM "IVRM_sms_sentBox"
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = "p_MI_Id" 
                    AND CAST("Datetime" AS date) BETWEEN "v_From_Date" AND "v_To_Date" 
                    AND "Module_Name" = 'Library' 
                    AND "To_FLag" = 'Student'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IM"."IVRM_Month_Id"
            ), "STUEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STUEmailSentCount"
                FROM "IVRM_Email_sentBox"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = "p_MI_Id" 
                    AND CAST("Datetime" AS date) BETWEEN "v_From_Date" AND "v_To_Date" 
                    AND "Module_Name" = 'Library' 
                    AND "To_FLag" = 'Student'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IM"."IVRM_Month_Id"
            ), "StudentsCount" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP) AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    "IM"."IVRM_Month_Name",
                    COUNT(*) AS "STUCount"
                FROM "Adm_M_Student" "AMS"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("ASYS"."AMAY_DateTime", 'Month')
                WHERE "AMS"."MI_Id" = "p_MI_Id" 
                    AND "ASYS"."ASMAY_Id" = "v_ASMAY_Id" 
                    AND "AMS"."AMST_SOL" = 'S' 
                    AND "AMS"."AMST_ActiveFlag" = 1 
                    AND "ASYS"."Amay_ActiveFlag" = 1
                GROUP BY "IM"."IVRM_Month_Name", "IM"."IVRM_Month_Id"
            )
            SELECT 
                "A"."CYear",
                "A"."IVRM_Month_Name",
                "A"."STUBooksCount",
                "D"."STUCount",
                "B"."STUSMSSentCount",
                "C"."STUEmailSentCount"
            FROM "STUBooks" "A"
            INNER JOIN "STUSMSSent" "B" ON "A"."IVRM_Month_Id" = "B"."IVRM_Month_Id"
            INNER JOIN "STUEmailSent" "C" ON "A"."IVRM_Month_Id" = "C"."IVRM_Month_Id"
            INNER JOIN "StudentsCount" "D" ON "A"."IVRM_Month_Id" = "D"."IVRM_Month_Id"
            ORDER BY "A"."IVRM_Month_Id";

        ELSIF "p_Flag" = 'Staff' THEN
            
            RETURN QUERY
            WITH "StaffBooks" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP) AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    "IM"."IVRM_Month_Name",
                    COUNT(*) AS "STUBooksCount"
                FROM "LIB"."Lib_Master_Book" "LB"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("LB"."LMB_EntryDate", 'Month')
                WHERE "LB"."MI_Id" = "p_MI_Id"
                GROUP BY "IM"."IVRM_Month_Name", "IM"."IVRM_Month_Id"
            ), "StaffSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STSMSSentCount"
                FROM "IVRM_sms_sentBox"
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = "p_MI_Id" 
                    AND CAST("Datetime" AS date) BETWEEN "v_From_Date" AND "v_To_Date" 
                    AND "Module_Name" = 'Library' 
                    AND "To_FLag" = 'Staff'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IM"."IVRM_Month_Id"
            ), "StaffEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    TO_CHAR("Datetime", 'Month') AS "CMonthName",
                    "Module_Name",
                    COUNT(*) AS "STEmailSentCount"
                FROM "IVRM_Email_sentBox"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = "p_MI_Id" 
                    AND CAST("Datetime" AS date) BETWEEN "v_From_Date" AND "v_To_Date" 
                    AND "Module_Name" = 'Library' 
                    AND "To_FLag" = 'Staff'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), TO_CHAR("Datetime", 'Month'), "Module_Name", "IM"."IVRM_Month_Id"
            ), "StaffCount" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP) AS bigint) AS "CYear",
                    "IM"."IVRM_Month_Id",
                    "IM"."IVRM_Month_Name",
                    COUNT(*) AS "EMPCount"
                FROM "HR_Master_Employee" "HM"
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("HM"."HRME_DOJ", 'Month')
                WHERE "HM"."MI_Id" = "p_MI_Id" 
                    AND "HM"."HRME_ActiveFlag" = 1 
                    AND "HM"."HRME_LeftFlag" = 0
                GROUP BY "IM"."IVRM_Month_Name", "IM"."IVRM_Month_Id"
            )
            SELECT 
                "A"."CYear",
                "A"."IVRM_Month_Name",
                "A"."STUBooksCount",
                "D"."EMPCount",
                "B"."STSMSSentCount",
                "C"."STEmailSentCount"
            FROM "StaffBooks" "A"
            INNER JOIN "StaffSMSSent" "B" ON "A"."IVRM_Month_Id" = "B"."IVRM_Month_Id"
            INNER JOIN "StaffEmailSent" "C" ON "A"."IVRM_Month_Id" = "C"."IVRM_Month_Id"
            INNER JOIN "StaffCount" "D" ON "A"."IVRM_Month_Id" = "D"."IVRM_Month_Id"
            ORDER BY "A"."IVRM_Month_Id";

        END IF;

    ELSIF "p_Type" = 'Yearly' THEN

        IF "p_Flag" = 'Student' THEN
            
            RETURN QUERY
            WITH "StudentBooks" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "LMB_EntryDate") AS bigint) AS "CYear",
                    COUNT(*) AS "STUBooksCount"
                FROM "LIB"."Lib_Master_Book" "LB"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("LB"."LMB_EntryDate", 'Month')
                WHERE "LB"."MI_Id" = "p_MI_Id"
                GROUP BY CAST(EXTRACT(YEAR FROM "LMB_EntryDate") AS bigint)
            ), "STUSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STUSMSSentCount"
                FROM "IVRM_sms_sentBox"
                WHERE "MI_Id" = "p_MI_Id" 
                    AND CAST("Datetime" AS date) BETWEEN "v_From_Date" AND "v_To_Date" 
                    AND "Module_Name" = 'Library' 
                    AND "To_FLag" = 'Student'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
            ), "STUEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STUEmailSentCount"
                FROM "IVRM_Email_sentBox"
                WHERE "MI_Id" = "p_MI_Id" 
                    AND CAST("Datetime" AS date) BETWEEN "v_From_Date" AND "v_To_Date" 
                    AND "Module_Name" = 'Library' 
                    AND "To_FLag" = 'Student'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
            ), "StudentsCount" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "ASYS"."AMAY_DateTime") AS bigint) AS "CYear",
                    COUNT(*) AS "STUCount"
                FROM "Adm_M_Student" "AMS"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                WHERE "AMS"."MI_Id" = "p_MI_Id" 
                    AND "ASYS"."ASMAY_Id" = "v_ASMAY_Id" 
                    AND "AMS"."AMST_SOL" = 'S' 
                    AND "AMS"."AMST_ActiveFlag" = 1 
                    AND "ASYS"."Amay_ActiveFlag" = 1
                GROUP BY CAST(EXTRACT(YEAR FROM "ASYS"."AMAY_DateTime") AS bigint)
            )
            SELECT 
                "B"."CYear",
                NULL::varchar AS "IVRM_Month_Name",
                "A"."STUBooksCount",
                "D"."STUCount",
                "B"."STUSMSSentCount",
                "C"."STUEmailSentCount"
            FROM "StudentBooks" "A"
            INNER JOIN "STUSMSSent" "B" ON "A"."CYear" = "B"."CYear"
            INNER JOIN "STUEmailSent" "C" ON "A"."CYear" = "C"."CYear"
            INNER JOIN "StudentsCount" "D" ON "A"."CYear" = "D"."CYear"
            ORDER BY "A"."CYear";

        ELSIF "p_Flag" = 'Staff' THEN
            
            RETURN QUERY
            WITH "StaffBooks" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "LMB_EntryDate") AS bigint) AS "CYear",
                    COUNT(*) AS "STUBooksCount"
                FROM "LIB"."Lib_Master_Book" "LB"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("LB"."LMB_EntryDate", 'Month')
                WHERE "LB"."MI_Id" = "p_MI_Id"
                GROUP BY CAST(EXTRACT(YEAR FROM "LMB_EntryDate") AS bigint)
            ), "StaffSMSSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STSMSSentCount"
                FROM "IVRM_sms_sentBox"
                INNER JOIN "IVRM_Month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = "p_MI_Id" 
                    AND CAST("Datetime" AS date) BETWEEN "v_From_Date" AND "v_To_Date" 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Staff'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
            ), "StaffEmailSent" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM "Datetime") AS bigint) AS "CYear",
                    "Module_Name",
                    COUNT(*) AS "STEmailSentCount"
                FROM "IVRM_Email_sentBox"
                INNER JOIN "ivrm_month" "IM" ON "IM"."IVRM_Month_Name" = TO_CHAR("Datetime", 'Month')
                WHERE "MI_Id" = "p_MI_Id" 
                    AND CAST("Datetime" AS date) BETWEEN "v_From_Date" AND "v_To_Date" 
                    AND "Module_Name" = 'Calendar of Event' 
                    AND "To_FLag" = 'Staff'
                GROUP BY EXTRACT(YEAR FROM "Datetime"), "Module_Name"
            ), "StaffCount" AS (
                SELECT 
                    CAST(EXTRACT(YEAR FROM CURRENT_TIMESTAMP) AS bigint) AS "CYear",
                    COUNT(*) AS "EMPCount"
                FROM "HR_Master_Employee" "HM"
                WHERE "HM"."MI_Id" = "p_MI_Id" 
                    AND "HM"."HRME_ActiveFlag" = 1 
                    AND "HM"."HRME_LeftFlag" = 0
            )
            SELECT 
                "B"."CYear",
                NULL::varchar AS "IVRM_Month_Name",
                "A"."STUBooksCount",
                "D"."EMPCount",
                "B"."STSMSSentCount",
                "C"."STEmailSentCount"
            FROM "StaffBooks" "A"
            INNER JOIN "StaffSMSSent" "B" ON "A"."CYear" = "B"."CYear"
            INNER JOIN "StaffEmailSent" "C" ON "A"."CYear" = "C"."CYear"
            INNER JOIN "StaffCount" "D" ON "A"."CYear" = "D"."CYear"
            ORDER BY "A"."CYear";

        END IF;

    END IF;

    RETURN;

END;
$$;