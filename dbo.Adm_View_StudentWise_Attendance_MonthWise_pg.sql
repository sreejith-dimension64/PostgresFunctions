CREATE OR REPLACE FUNCTION "dbo"."Adm_View_StudentWise_Attendance_MonthWise"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "Months" TEXT,
    "Years" TEXT,
    "monthid" DOUBLE PRECISION,
    "yearid" DOUBLE PRECISION,
    "PresentCount" BIGINT,
    "WorkingCount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        B."AMST_Id",
        TO_CHAR(A."ASA_fromDate", 'Month') AS "Months",
        TO_CHAR(A."ASA_fromDate", 'YYYY') AS "Years",
        EXTRACT(MONTH FROM A."ASA_fromDate") AS "monthid",
        EXTRACT(YEAR FROM A."ASA_fromDate") AS "yearid",
        SUM(B."ASA_Class_Attended") AS "PresentCount",
        SUM(A."ASA_ClassHeld") AS "WorkingCount"
    FROM "Adm_Student_Attendance" A
    INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id" = B."ASA_Id" AND A."ASA_Activeflag" = 1
    INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = B."AMST_Id" AND C."ASMAY_Id" = A."ASMAY_Id"
    INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
    WHERE A."ASMAY_Id" = "@ASMAY_Id" AND A."MI_Id" = "@MI_Id" AND B."AMST_Id" = "@AMST_Id"
    GROUP BY B."AMST_Id", TO_CHAR(A."ASA_fromDate", 'Month'), TO_CHAR(A."ASA_fromDate", 'YYYY'), 
             EXTRACT(MONTH FROM A."ASA_fromDate"), EXTRACT(YEAR FROM A."ASA_fromDate")
    ORDER BY EXTRACT(YEAR FROM A."ASA_fromDate"), EXTRACT(MONTH FROM A."ASA_fromDate");

END;
$$;