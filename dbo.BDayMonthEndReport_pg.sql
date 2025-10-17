CREATE OR REPLACE FUNCTION "dbo"."BDayMonthEndReport"(
    p_ASMAY_Id INT,
    p_MI_Id INT,
    p_condition INT,
    p_month INT
)
RETURNS TABLE(
    "Department_Class_Name" VARCHAR,
    "BirthdayCount" BIGINT,
    "SmsCount" BIGINT,
    "EmailCount" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_SmsCount INT;
    v_EmailCount INT;
    v_smsdept INT;
    v_emaildept INT;
BEGIN

    SELECT COUNT(*) INTO v_SmsCount
    FROM "IVRM_sms_sentBox" A 
    WHERE "Module_Name" = 'Birthday' 
        AND "MI_Id" = p_MI_Id 
        AND (EXTRACT(MONTH FROM A."Datetime") = p_month) 
        AND A."To_FLag" = 'Student';

    SELECT COUNT(*) INTO v_EmailCount
    FROM "IVRM_Email_sentBox" A 
    WHERE "Module_Name" = 'Birthday' 
        AND "MI_Id" = p_MI_Id 
        AND (EXTRACT(MONTH FROM A."Datetime") = p_month) 
        AND A."To_FLag" = 'Student';

    SELECT COUNT(*) INTO v_smsdept
    FROM "IVRM_sms_sentBox" A 
    WHERE "Module_Name" = 'Birthday' 
        AND "MI_Id" = p_MI_Id 
        AND (EXTRACT(MONTH FROM A."Datetime") = p_month) 
        AND A."To_FLag" != 'Student';

    SELECT COUNT(*) INTO v_emaildept
    FROM "IVRM_Email_sentBox" A 
    WHERE "Module_Name" = 'Birthday' 
        AND "MI_Id" = p_MI_Id 
        AND (EXTRACT(MONTH FROM A."Datetime") = p_month) 
        AND A."To_FLag" != 'Student';

    IF (p_condition = 1) THEN
        RETURN QUERY
        SELECT 
            t."ASMCL_ClassName",
            COUNT(t."AMST_Id") AS birthdaycout,
            v_SmsCount::BIGINT AS SmsCount,
            v_EmailCount::BIGINT AS emailCount
        FROM (
            SELECT DISTINCT 
                c."ASMCL_ClassName",
                c."ASMCL_Order",
                a."AMST_Id"
            FROM "Adm_M_Student" AS a
            CROSS JOIN "Adm_School_Y_Student" AS b
            CROSS JOIN "Adm_School_M_Class" AS c
            CROSS JOIN "Adm_School_M_Section" AS d
            WHERE a."AMST_Id" = b."AMST_Id" 
                AND b."ASMCL_Id" = c."ASMCL_Id" 
                AND b."ASMS_Id" = d."ASMS_Id" 
                AND a."MI_Id" = p_MI_Id 
                AND a."AMST_ActiveFlag" = 1 
                AND a."AMST_SOL" = 'S' 
                AND b."AMAY_ActiveFlag" = 1 
                AND EXTRACT(MONTH FROM a."AMST_DOB") = p_month 
                AND b."ASMAY_Id" = p_ASMAY_Id
        ) AS t
        GROUP BY t."ASMCL_ClassName", t."ASMCL_Order"
        ORDER BY t."ASMCL_Order";
    END IF;

    IF (p_condition = 2) THEN
        RETURN QUERY
        SELECT 
            t."HRMD_DepartmentName",
            COUNT(t."HRME_Id") AS staffbdaycount,
            v_smsdept::BIGINT AS SmsCount,
            v_emaildept::BIGINT AS EmailCount
        FROM (
            SELECT DISTINCT 
                hd."HRMD_DepartmentName",
                a."HRME_Id"
            FROM "HR_Master_Employee" AS a
            INNER JOIN "HR_Master_Department" hd ON hd."HRMD_Id" = a."HRMD_Id"
            WHERE a."MI_Id" = p_MI_Id 
                AND a."HRME_ActiveFlag" = 1 
                AND a."HRME_LeftFlag" = 0 
                AND EXTRACT(MONTH FROM a."HRME_DOB") = p_month
        ) AS t 
        GROUP BY t."HRMD_DepartmentName" 
        ORDER BY t."HRMD_DepartmentName";
    END IF;

    RETURN;
END;
$$;