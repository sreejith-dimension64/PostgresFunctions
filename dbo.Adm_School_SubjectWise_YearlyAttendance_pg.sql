CREATE OR REPLACE FUNCTION "dbo"."Adm_School_SubjectWise_YearlyAttendance"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@ISMS_Id" TEXT
)
RETURNS TABLE(
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" TEXT,
    "AMST_Id" BIGINT,
    "StuName" TEXT,
    "AMST_AdmNo" TEXT,
    "AMAY_RollNo" TEXT,
    "ASA_ClassHeld" BIGINT
) AS $$
DECLARE
    "@FromDate" DATE;
    "@ToDate" DATE;
    "@sqldynamic" TEXT;
    "@PivotColumnNames" TEXT := '';
    "@PivotSelectColumnNames" TEXT := '';
    "v_rec" RECORD;
BEGIN

    DROP TABLE IF EXISTS "Adm_School_SubjectWise_MonthNames_Temp";

    SELECT 
        CAST("ASMAY_From_Date" AS DATE),
        CAST("ASMAY_To_Date" AS DATE)
    INTO 
        "@FromDate",
        "@ToDate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = CAST("@MI_Id" AS BIGINT) 
        AND "ASMAY_Id" = CAST("@ASMAY_Id" AS BIGINT);

    CREATE TEMP TABLE "Adm_School_SubjectWise_MonthNames_Temp" AS
    WITH RECURSIVE CTE AS (
        SELECT "@FromDate" AS "ADates"
        UNION ALL
        SELECT ("ADates" + INTERVAL '1 month')::DATE 
        FROM CTE 
        WHERE ("ADates" + INTERVAL '1 month')::DATE <= "@ToDate"
    )
    SELECT "ADates" FROM CTE ORDER BY "ADates";

    SELECT STRING_AGG('"' || "AMonthName" || '"', ',' ORDER BY "MonthOrder", "YearValue")
    INTO "@PivotColumnNames"
    FROM (
        SELECT 
            SUBSTRING(TO_CHAR("ADates", 'Month'), 1, 3) || '' || CAST(EXTRACT(YEAR FROM "ADates") AS TEXT) AS "AMonthName",
            EXTRACT(MONTH FROM "ADates") AS "MonthOrder",
            EXTRACT(YEAR FROM "ADates") AS "YearValue"
        FROM "Adm_School_SubjectWise_MonthNames_Temp"
    ) AS "PVColumns";

    SELECT STRING_AGG('SUM(COALESCE("' || "AMonthName" || '", 0)) AS "' || "AMonthName" || '"', ',' ORDER BY "MonthOrder", "YearValue")
    INTO "@PivotSelectColumnNames"
    FROM (
        SELECT 
            SUBSTRING(TO_CHAR("ADates", 'Month'), 1, 3) || '' || CAST(EXTRACT(YEAR FROM "ADates") AS TEXT) AS "AMonthName",
            EXTRACT(MONTH FROM "ADates") AS "MonthOrder",
            EXTRACT(YEAR FROM "ADates") AS "YearValue"
        FROM "Adm_School_SubjectWise_MonthNames_Temp"
    ) AS "PVSelctedColumns";

    "@sqldynamic" := 
    'SELECT "ISMS_Id","ISMS_SubjectName","AMST_Id","StuName","AMST_AdmNo","AMAY_RollNo",SUM("ASA_ClassHeld") AS "ASA_ClassHeld",' || "@PivotSelectColumnNames" || ' FROM (
    SELECT DISTINCT "ASAS"."ISMS_Id","IMS"."ISMS_SubjectName",(SUBSTRING(TO_CHAR("ASA_FromDate", ''Month''),1,3)||''''||CAST(EXTRACT(YEAR FROM "ASA_FromDate") AS TEXT)) AS "ASA_FromDate","ASAST"."AMST_Id","AMS"."AMST_AdmNo","AMAY_RollNo",COALESCE("AMST_FirstName",'''')||'' ''||COALESCE("AMST_MiddleName",'''')||'' ''||COALESCE("AMST_LastName",'''') AS "StuName",
    COUNT(CASE WHEN "ASA_Class_Attended"=1.00 THEN 1 END) AS "ASA_Class_Attended",SUM("ASA_ClassHeld") AS "ASA_ClassHeld"
    FROM "Adm_Student_Attendance" "ASA"
    INNER JOIN "Adm_Student_Attendance_Periodwise" "ASAP" ON "ASA"."ASA_Id"="ASAP"."ASA_Id"
    INNER JOIN "Adm_Student_Attendance_Subjects" "ASAS" ON "ASAS"."ASA_Id"="ASA"."ASA_Id"
    INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id"="ASAS"."ISMS_Id" AND "IMS"."MI_Id" IN (' || "@MI_Id" || ')
    INNER JOIN "Adm_Student_Attendance_Students" "ASAST" ON "ASAST"."ASA_Id"="ASA"."ASA_Id"
    INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id"="ASAST"."AMST_Id" AND "AMS"."MI_Id" IN (' || "@MI_Id" || ')
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id"="AMS"."AMST_Id" 
    WHERE "ASYS"."ASMAY_Id" IN (' || "@ASMAY_Id" || ') AND "AMS"."AMST_SOL"=''S'' AND "AMS"."AMST_ActiveFlag"=1 AND "ASYS"."AMAY_ActiveFlag"=1
    AND "ASA"."MI_Id" IN (' || "@MI_Id" || ') AND "ASA"."ASMAY_Id" IN (' || "@ASMAY_Id" || ') AND "ASA"."ASMCL_Id" IN (' || "@ASMCL_Id" || ') AND "ASA"."ASMS_Id" IN (' || "@ASMS_Id" || ') AND "ASAS"."ISMS_Id" IN (' || "@ISMS_Id" || ') AND "ASA_Activeflag"=1 AND "ASA_Att_Type"=''period''  
    GROUP BY "ASAS"."ISMS_Id","IMS"."ISMS_SubjectName",(SUBSTRING(TO_CHAR("ASA_FromDate", ''Month''),1,3)||''''||CAST(EXTRACT(YEAR FROM "ASA_FromDate") AS TEXT)),"ASAST"."AMST_Id","AMS"."AMST_AdmNo","AMAY_RollNo",COALESCE("AMST_FirstName",'''')||'' ''||COALESCE("AMST_MiddleName",'''')||'' ''||COALESCE("AMST_LastName",'''') 
    ) AS "New" 
    CROSSTAB(''SELECT "ISMS_Id","ISMS_SubjectName","AMST_Id","StuName","AMST_AdmNo","AMAY_RollNo","ASA_FromDate","ASA_Class_Attended" FROM ... FOR "ASA_FromDate" IN (' || "@PivotColumnNames" || ')'')
    GROUP BY "ISMS_Id","ISMS_SubjectName","AMST_Id","StuName","AMST_AdmNo","AMAY_RollNo"';

    RETURN QUERY EXECUTE "@sqldynamic";

    DROP TABLE IF EXISTS "Adm_School_SubjectWise_MonthNames_Temp";

    RETURN;

END;
$$ LANGUAGE plpgsql;