CREATE OR REPLACE FUNCTION "dbo"."ALLSTUDENT_MONTHLY_ATTENDANCE_PORTAL"(
    "asmay_id" TEXT,
    "mi_id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "name" TEXT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "month_id" DOUBLE PRECISION,
    "MONTH_NAME" TEXT,
    "TOTAL_PRESENT" NUMERIC,
    "CLASS_HELD" TEXT,
    "per" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "cols" TEXT;
    "query" TEXT;
    "monthyearsd" TEXT;
    "monthids" TEXT;
    "monthids1" TEXT;
    "monthyearsd1" TEXT;
BEGIN

    RETURN QUERY
    SELECT 
        b."AMST_Id",
        (COALESCE(d."AMST_FirstName",'') || ' ' || COALESCE(d."AMST_MiddleName",'') || ' ' || COALESCE(d."AMST_MiddleName",'')) AS "name",
        c."ASMCL_Id",
        c."ASMS_Id",
        EXTRACT(MONTH FROM a."asa_fromdate") AS "month_id",
        TO_CHAR(a."asa_fromdate", 'Month') AS "MONTH_NAME",
        SUM(b."ASA_Class_Attended") AS "TOTAL_PRESENT",
        CAST(CAST(ROUND(SUM(a."ASA_ClassHeld"), 0) AS INTEGER) AS TEXT) AS "CLASS_HELD",
        CAST((SUM(b."ASA_Class_Attended") / CAST(ROUND(SUM(a."ASA_ClassHeld"), 0) AS INTEGER) * 100) AS NUMERIC(18,2)) AS "per"
    FROM "Adm_Student_Attendance" a
    INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
    INNER JOIN "adm_school_Y_student" c ON c."amst_id" = b."AMST_Id" AND c."asmay_id" = a."asmay_id"
    INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
    WHERE a."MI_Id" = "ALLSTUDENT_MONTHLY_ATTENDANCE_PORTAL"."mi_id" 
        AND c."ASMAY_Id" = "ALLSTUDENT_MONTHLY_ATTENDANCE_PORTAL"."asmay_id"
        AND c."ASMS_Id" = "ALLSTUDENT_MONTHLY_ATTENDANCE_PORTAL"."ASMS_Id" 
        AND c."ASMCL_Id" = "ALLSTUDENT_MONTHLY_ATTENDANCE_PORTAL"."ASMCL_Id"
    GROUP BY b."AMST_Id", c."ASMCL_Id", c."ASMS_Id", EXTRACT(MONTH FROM a."ASA_FromDate"), 
             TO_CHAR(a."asa_fromdate", 'Month'), TO_CHAR(a."asa_fromdate", 'Year'),
             d."AMST_FirstName", d."AMST_LastName", d."AMST_MiddleName"
    ORDER BY b."AMST_Id";

END;
$$;