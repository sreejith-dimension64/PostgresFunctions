CREATE OR REPLACE FUNCTION "dbo"."General_SMS_Attendance_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@from" TEXT,
    "@to" TEXT,
    "@AMST_Id" TEXT,
    "@date" TEXT,
    "@flag" TEXT
)
RETURNS TABLE(
    "DATE" TEXT,
    "NAME" TEXT,
    "TOTALCLASSHELD" NUMERIC,
    "TOTALCLASSATTENDED" NUMERIC,
    "PERCENTAGE" NUMERIC,
    "AMST_Id" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "@flag" = 'between' THEN
    
        RETURN QUERY
        SELECT 
            ('From Date :' || TO_CHAR(a."ASA_FromDate", 'DD/MM/YYYY') || 'To Date :' || TO_CHAR(a."ASA_ToDate", 'DD/MM/YYYY')) AS "DATE",
            (COALESCE(d."AMST_FIRSTNAME", '') || ' ' || COALESCE(d."AMST_MIDDLENAME", '') || ' ' || COALESCE(d."AMST_LASTNAME", '')) AS "NAME",
            SUM(a."ASA_ClassHeld") AS "TOTALCLASSHELD",
            SUM(b."ASA_Class_Attended") AS "TOTALCLASSATTENDED",
            CAST(ROUND(((SUM(b."ASA_Class_Attended") / SUM(a."ASA_ClassHeld")) * 100), 2) AS NUMERIC(36,2)) AS "PERCENTAGE",
            b."AMST_Id"
        FROM "Adm_Student_Attendance" a 
        INNER JOIN "Adm_Student_Attendance_Students" b ON a."asa_id" = b."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = c."ASMAY_Id" AND a."ASMAY_Id" = e."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = c."ASMCL_Id" AND a."ASMCL_Id" = f."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = c."ASMS_Id" AND a."ASMS_Id" = g."ASMS_Id"
        WHERE a."MI_Id" = "@MI_Id" 
            AND d."MI_Id" = "@MI_Id" 
            AND a."ASMAY_Id" = "@ASMAY_Id" 
            AND c."ASMAY_Id" = "@ASMAY_Id" 
            AND a."ASMCL_Id" = "@ASMCL_Id" 
            AND c."ASMCL_Id" = "@ASMCL_Id" 
            AND a."ASMS_Id" = "@ASMS_Id" 
            AND c."ASMS_Id" = "@ASMS_Id" 
            AND d."AMST_SOL" = 'S' 
            AND d."AMST_ActiveFlag" = 1 
            AND c."AMAY_ActiveFlag" = 1
            AND (a."ASA_FromDate" BETWEEN "@from"::DATE AND "@to"::DATE) 
            AND (a."ASA_ToDate" BETWEEN "@from"::DATE AND "@to"::DATE)
            AND b."AMST_Id" = "@AMST_Id" 
            AND c."AMST_Id" = "@AMST_Id"
        GROUP BY b."AMST_Id", a."ASA_FromDate", a."ASA_ToDate", d."AMST_FIRSTNAME", d."AMST_MIDDLENAME", d."AMST_LASTNAME";
    
    ELSE
    
        RETURN QUERY
        SELECT 
            ('From Date :' || TO_CHAR(a."ASA_FromDate", 'DD/MM/YYYY')) AS "DATE",
            (COALESCE(d."AMST_FIRSTNAME", '') || ' ' || COALESCE(d."AMST_MIDDLENAME", '') || ' ' || COALESCE(d."AMST_LASTNAME", '')) AS "NAME",
            SUM(a."ASA_ClassHeld") AS "TOTALCLASSHELD",
            SUM(b."ASA_Class_Attended") AS "TOTALCLASSATTENDED",
            CAST(ROUND(((SUM(b."ASA_Class_Attended") / SUM(a."ASA_ClassHeld")) * 100), 2) AS NUMERIC(36,2)) AS "PERCENTAGE",
            b."AMST_Id"
        FROM "Adm_Student_Attendance" a 
        INNER JOIN "Adm_Student_Attendance_Students" b ON a."asa_id" = b."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = c."ASMAY_Id" AND a."ASMAY_Id" = e."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = c."ASMCL_Id" AND a."ASMCL_Id" = f."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = c."ASMS_Id" AND a."ASMS_Id" = g."ASMS_Id"
        WHERE a."MI_Id" = "@MI_Id" 
            AND d."MI_Id" = "@MI_Id" 
            AND a."ASMAY_Id" = "@ASMAY_Id" 
            AND c."ASMAY_Id" = "@ASMAY_Id" 
            AND a."ASMCL_Id" = "@ASMCL_Id" 
            AND c."ASMCL_Id" = "@ASMCL_Id" 
            AND a."ASMS_Id" = "@ASMS_Id" 
            AND c."ASMS_Id" = "@ASMS_Id" 
            AND d."AMST_SOL" = 'S' 
            AND d."AMST_ActiveFlag" = 1 
            AND c."AMAY_ActiveFlag" = 1
            AND (a."ASA_FromDate" BETWEEN "@date"::DATE AND "@date"::DATE) 
            AND (a."ASA_ToDate" BETWEEN "@date"::DATE AND "@date"::DATE)
            AND b."AMST_Id" = "@AMST_Id" 
            AND c."AMST_Id" = "@AMST_Id"
        GROUP BY b."AMST_Id", a."ASA_FromDate", d."AMST_FIRSTNAME", d."AMST_MIDDLENAME", d."AMST_LASTNAME";
    
    END IF;

    RETURN;

END;
$$;