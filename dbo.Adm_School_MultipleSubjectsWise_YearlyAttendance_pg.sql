CREATE OR REPLACE FUNCTION "dbo"."Adm_School_MultipleSubjectsWise_YearlyAttendance"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@ISMS_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "StuName" TEXT,
    "AMST_AdmNo" TEXT,
    "AMAY_RollNo" TEXT,
    "ASA_FromDate" TEXT,
    "ASA_ClassHeld" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@FromDate" DATE;
    "@ToDate" DATE;
    "@sqldynamic" TEXT;
    "@PivotColumnNames" TEXT := '';
    "@PivotSelectColumnNames" TEXT := '';
BEGIN

    SELECT STRING_AGG('"' || "ISMS_SubjectName" || '"', ',') INTO "@PivotColumnNames"
    FROM (
        SELECT DISTINCT "ISMS_SubjectName" 
        FROM "IVRM_Master_Subjects" 
        WHERE "MI_Id" = "@MI_Id"::BIGINT
    ) AS PVColumns;

    SELECT STRING_AGG(
        'SUM(COALESCE("' || "ISMS_SubjectName" || '", 0)) AS "' || "ISMS_SubjectName" || '"', 
        ','
    ) INTO "@PivotSelectColumnNames"
    FROM (
        SELECT DISTINCT A."ISMS_SubjectName"
        FROM "IVRM_Master_Subjects" A
        INNER JOIN "Exm"."Exm_Studentwise_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
        WHERE A."MI_Id" = "@MI_Id"::BIGINT 
        AND B."MI_Id" = "@MI_Id"::BIGINT 
        AND B."ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND B."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND B."ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND B."AMST_Id" = "@AMST_Id"::BIGINT
    ) AS PVSelctedColumns;

    "@sqldynamic" := '
    SELECT "AMST_Id", "StuName", "AMST_AdmNo", "AMAY_RollNo", "ASA_FromDate", SUM("ASA_ClassHeld") AS "ASA_ClassHeld",' || "@PivotSelectColumnNames" || ' 
    FROM (
        SELECT DISTINCT ASAS."ISMS_Id", IMS."ISMS_SubjectName",
        (SUBSTRING(TO_CHAR(ASA."ASA_FromDate", ''Month''), 1, 3) || ''/'' || SUBSTRING(CAST(EXTRACT(YEAR FROM ASA."ASA_FromDate") AS TEXT), 3, 4)) AS "ASA_FromDate",
        ASAST."AMST_Id", AMS."AMST_AdmNo", ASYS."AMAY_RollNo",
        COALESCE(AMS."AMST_FirstName", '''') || '' '' || COALESCE(AMS."AMST_MiddleName", '''') || '' '' || COALESCE(AMS."AMST_LastName", '''') AS "StuName",
        COUNT(CASE WHEN ASA."ASA_Class_Attended" = 1.00 THEN 1 END) AS "ASA_Class_Attended",
        SUM(ASA."ASA_ClassHeld") AS "ASA_ClassHeld"
        FROM "Adm_Student_Attendance" ASA
        INNER JOIN "Adm_Student_Attendance_Periodwise" ASAP ON ASA."ASA_Id" = ASAP."ASA_Id"
        INNER JOIN "Adm_Student_Attendance_Subjects" ASAS ON ASAS."ASA_Id" = ASA."ASA_Id"
        INNER JOIN "IVRM_Master_Subjects" IMS ON IMS."ISMS_Id" = ASAS."ISMS_Id" 
            AND IMS."MI_Id" IN (' || "@MI_Id" || ')
        INNER JOIN "Adm_Student_Attendance_Students" ASAST ON ASAST."ASA_Id" = ASA."ASA_Id"
        INNER JOIN "Adm_M_Student" AMS ON AMS."AMST_Id" = ASAST."AMST_Id" 
            AND AMS."MI_Id" IN (' || "@MI_Id" || ')
        INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id"
        WHERE ASYS."ASMAY_Id" IN (' || "@ASMAY_Id" || ') 
        AND AMS."AMST_SOL" = ''S'' 
        AND AMS."AMST_ActiveFlag" = 1 
        AND ASYS."AMAY_ActiveFlag" = 1
        AND ASA."MI_Id" IN (' || "@MI_Id" || ') 
        AND ASA."ASMAY_Id" IN (' || "@ASMAY_Id" || ') 
        AND ASA."ASMCL_Id" IN (' || "@ASMCL_Id" || ') 
        AND ASA."ASMS_Id" IN (' || "@ASMS_Id" || ')
        AND ASA."ASA_Activeflag" = 1 
        AND ASA."ASA_Att_Type" = ''period'' 
        AND ASAST."AMST_Id" IN (' || "@AMST_Id" || ')
        GROUP BY ASAS."ISMS_Id", IMS."ISMS_SubjectName", 
        (SUBSTRING(TO_CHAR(ASA."ASA_FromDate", ''Month''), 1, 3) || ''/'' || SUBSTRING(CAST(EXTRACT(YEAR FROM ASA."ASA_FromDate") AS TEXT), 3, 4)),
        ASAST."AMST_Id", AMS."AMST_AdmNo", ASYS."AMAY_RollNo", AMS."AMST_FirstName", AMS."AMST_MiddleName", AMS."AMST_LastName"
    ) AS New
    CROSS JOIN LATERAL (
        SELECT ' || REPLACE("@PivotColumnNames", '"', '''') || '
    ) AS pivot_data
    GROUP BY "AMST_Id", "StuName", "AMST_AdmNo", "AMAY_RollNo", "ASA_FromDate"';

    RETURN QUERY EXECUTE "@sqldynamic";

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in Adm_School_MultipleSubjectsWise_YearlyAttendance: %', SQLERRM;
END;
$$;