CREATE OR REPLACE FUNCTION "dbo"."Adm_Admission_Attendance_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "ASA_ClassHeld" NUMERIC,
    "ASA_Class_Attended" NUMERIC,
    "Percentage" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        SUM("dbo"."Adm_Student_Attendance"."ASA_ClassHeld") AS "ASA_ClassHeld",
        SUM("dbo"."Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "ASA_Class_Attended",
        TO_CHAR(
            (SUM("dbo"."Adm_Student_Attendance_Students"."ASA_Class_Attended")::NUMERIC / 
             NULLIF(SUM("dbo"."Adm_Student_Attendance"."ASA_ClassHeld"), 0) * 100),
            'FM999999990.00'
        ) AS "Percentage"
    FROM "dbo"."Adm_M_Student"
    INNER JOIN "dbo"."Adm_Student_Attendance_Students"
        ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_Student_Attendance_Students"."AMST_Id"
    INNER JOIN "dbo"."Adm_Student_Attendance"
        ON "dbo"."Adm_Student_Attendance_Students"."ASA_Id" = "dbo"."Adm_Student_Attendance"."ASA_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student"
        ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Adm_School_Y_Student"."AMST_Id"
    WHERE "dbo"."Adm_Student_Attendance"."ASMAY_Id" = p_ASMAY_Id
        AND "dbo"."Adm_Student_Attendance_Students"."AMST_Id" = p_AMST_Id
        AND "dbo"."Adm_Student_Attendance"."MI_Id" = p_MI_Id
        AND "dbo"."Adm_M_Student"."AMST_SOL" = 'S'
        AND "dbo"."Adm_M_Student"."AMST_ActiveFlag" = 1
        AND "dbo"."Adm_School_Y_Student"."AMAY_ActiveFlag" = 1;
END;
$$;