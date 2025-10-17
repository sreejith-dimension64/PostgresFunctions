CREATE OR REPLACE FUNCTION "dbo"."ATTENDANCE_MONTH_NAME_FROM_START_AND_END_DATE"(
    "ASMAY_Id" TEXT,
    "ASMCL_ID" TEXT,
    "ASMS_Id" TEXT,
    "mi_id" TEXT,
    "allindiflag" TEXT
)
RETURNS TABLE(
    "MONTH_NAME" TEXT,
    "YEAR_NAME" DOUBLE PRECISION,
    "MONTH_ID" DOUBLE PRECISION,
    "MONTH_YEAR" TEXT,
    "TOTAL_classheld" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF ("allindiflag" = 'all') THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."MONTH_NAME" AS "MONTH_NAME",
            A."YEAR_NAME",
            A."MONTH_ID",
            CAST(A."YEAR_NAME" AS VARCHAR(20)) + ' : ' + CAST(A."MONTH_ID" AS VARCHAR(20)) AS "MONTH_YEAR",
            A."TOTAL_classheld"
        FROM (
            SELECT 
                SUM("ASA_ClassHeld") AS "TOTAL_classheld",
                TO_CHAR("ASA_FromDate", 'Month') AS "MONTH_NAME",
                EXTRACT(YEAR FROM "ASA_FromDate") AS "YEAR_NAME",
                SUM("asa_class_attended") AS "classattended",
                EXTRACT(MONTH FROM "ASA_FromDate") AS "MONTH_ID"
            FROM "Adm_Student_Attendance"
            INNER JOIN "Adm_Student_Attendance_Students" 
                ON "Adm_Student_Attendance_Students"."asa_id" = "Adm_Student_Attendance"."asa_id"
            WHERE "Adm_Student_Attendance"."ASMAY_Id" = "ASMAY_Id"
                AND "Adm_Student_Attendance"."MI_Id" = "mi_id"
            GROUP BY TO_CHAR("ASA_FromDate", 'Month'), EXTRACT(YEAR FROM "ASA_FromDate"), EXTRACT(MONTH FROM "ASA_FromDate")
        ) A
        GROUP BY A."MONTH_NAME", A."YEAR_NAME", A."MONTH_ID", A."TOTAL_classheld"
        ORDER BY A."YEAR_NAME", A."MONTH_ID" ASC;
        
    ELSIF ("allindiflag" = 'indi') THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."MONTH_NAME" AS "MONTH_NAME",
            A."YEAR_NAME",
            A."MONTH_ID",
            CAST(A."YEAR_NAME" AS VARCHAR(20)) + ' : ' + CAST(A."MONTH_ID" AS VARCHAR(20)) AS "MONTH_YEAR",
            A."TOTAL_classheld"
        FROM (
            SELECT 
                SUM("ASA_ClassHeld") AS "TOTAL_classheld",
                TO_CHAR("ASA_FromDate", 'Month') AS "MONTH_NAME",
                EXTRACT(YEAR FROM "ASA_FromDate") AS "YEAR_NAME",
                SUM("asa_class_attended") AS "classattended",
                EXTRACT(MONTH FROM "ASA_FromDate") AS "MONTH_ID"
            FROM "Adm_Student_Attendance"
            INNER JOIN "Adm_Student_Attendance_Students" 
                ON "Adm_Student_Attendance_Students"."asa_id" = "Adm_Student_Attendance"."asa_id"
            WHERE "Adm_Student_Attendance"."ASMAY_Id" = "ASMAY_Id"
                AND "Adm_Student_Attendance"."ASMCL_Id" = "ASMCL_ID"
                AND "Adm_Student_Attendance"."ASMS_Id" = "ASMS_Id"
                AND "Adm_Student_Attendance"."MI_Id" = "mi_id"
            GROUP BY TO_CHAR("ASA_FromDate", 'Month'), EXTRACT(YEAR FROM "ASA_FromDate"), EXTRACT(MONTH FROM "ASA_FromDate")
        ) A
        GROUP BY A."MONTH_NAME", A."YEAR_NAME", A."MONTH_ID", A."TOTAL_classheld"
        ORDER BY A."YEAR_NAME", A."MONTH_ID" ASC;
        
    END IF;
    
    RETURN;
END;
$$;