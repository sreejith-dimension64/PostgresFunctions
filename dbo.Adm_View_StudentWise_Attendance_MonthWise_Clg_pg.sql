CREATE OR REPLACE FUNCTION "dbo"."Adm_View_StudentWise_Attendance_MonthWise_Clg"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMST_Id" TEXT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
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
        "B"."AMCST_Id",
        TO_CHAR("A"."CreatedDate", 'Month') AS "Months",
        TO_CHAR("A"."CreatedDate", 'YYYY') AS "Years",
        EXTRACT(MONTH FROM "A"."CreatedDate") AS "monthid",
        EXTRACT(YEAR FROM "A"."CreatedDate") AS "yearid",
        SUM("B"."ACSAS_ClassAttended") AS "PresentCount",
        SUM("A"."ACSA_ClassHeld") AS "WorkingCount"
    FROM "Clg"."Adm_College_Student_Attendance" "A"
    INNER JOIN "Clg"."Adm_College_Student_Attendance_Students" "B" 
        ON "A"."ACSA_Id" = "B"."ACSA_Id" AND "A"."ACSA_Activeflag" = 1
    INNER JOIN "Clg"."Adm_College_Yearly_Student" "C" 
        ON "C"."AMCST_Id" = "B"."AMCST_Id" AND "C"."ASMAY_Id" = "A"."ASMAY_Id"
    INNER JOIN "clg"."Adm_Master_College_Student" "D" 
        ON "D"."AMCST_Id" = "C"."AMCST_Id"
    WHERE "A"."ASMAY_Id" = "Adm_View_StudentWise_Attendance_MonthWise_Clg"."ASMAY_Id" 
        AND "A"."MI_Id" = "Adm_View_StudentWise_Attendance_MonthWise_Clg"."MI_Id" 
        AND "B"."AMCST_Id" = "Adm_View_StudentWise_Attendance_MonthWise_Clg"."AMST_Id"
    GROUP BY "B"."AMCST_Id", 
        TO_CHAR("A"."CreatedDate", 'Month'), 
        TO_CHAR("A"."CreatedDate", 'YYYY'),
        EXTRACT(MONTH FROM "A"."CreatedDate"),
        EXTRACT(YEAR FROM "A"."CreatedDate")
    ORDER BY EXTRACT(YEAR FROM "A"."CreatedDate"), 
        EXTRACT(MONTH FROM "A"."CreatedDate");
END;
$$;