CREATE OR REPLACE FUNCTION "dbo"."Adm_Get_Toalclassheld_Attendance_Student_TC"(
    "MI_Id" TEXT, 
    "ASMAY_ID" TEXT, 
    "AMST_ID" TEXT, 
    "AMST_SOL" TEXT
)
RETURNS TABLE(
    "AMST_AdmNo" VARCHAR,
    "stdname" TEXT,
    "AMAY_RollNo" INTEGER,
    "Attendance" BIGINT,
    "Classes" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Fromdate" TEXT;
    "Todate" TEXT;
BEGIN
    SELECT TO_CHAR("ASMAY_From_Date", 'DD/MM/YYYY') INTO "Fromdate"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "mi_id" = "MI_Id" 
    AND "ASMAY_ActiveFlag" = 1 
    AND "ASMAY_Id" = "ASMAY_ID";

    SELECT TO_CHAR(MAX(a."ASA_ToDate"), 'DD/MM/YYYY') INTO "Todate"
    FROM "dbo"."Adm_Student_Attendance" a 
    INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
    WHERE "AMST_Id" = "AMST_ID" 
    AND a."ASMAY_Id" = "ASMAY_ID" 
    AND a."MI_Id" = "MI_Id";

    RETURN QUERY
    SELECT 
        "dbo"."Adm_M_Student"."AMST_AdmNo", 
        (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') || ' ' || 
         COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') || ' ' || 
         COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '')) AS "stdname", 
        "dbo"."Adm_School_Y_Student"."AMAY_RollNo", 
        SUM("dbo"."Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "Attendance",
        SUM("dbo"."Adm_Student_Attendance"."ASA_ClassHeld") AS "Classes" 
    FROM "dbo"."Adm_Student_Attendance_Students" 
    INNER JOIN "dbo"."Adm_M_Student" ON 
        "dbo"."Adm_Student_Attendance_Students"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
    INNER JOIN "dbo"."Adm_School_Y_Student" ON 
        "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
    INNER JOIN "Adm_Student_Attendance" ON 
        "Adm_Student_Attendance"."ASA_Id" = "dbo"."Adm_Student_Attendance_Students"."ASA_Id"
    WHERE TO_DATE(TO_CHAR("dbo"."Adm_Student_Attendance"."ASA_FromDate", 'DD/MM/YYYY'), 'DD/MM/YYYY') >= 
          TO_DATE("Fromdate", 'DD/MM/YYYY') 
    AND TO_DATE(TO_CHAR("dbo"."Adm_Student_Attendance"."ASA_ToDate", 'DD/MM/YYYY'), 'DD/MM/YYYY') <= 
        TO_DATE("Todate", 'DD/MM/YYYY') 
    AND "dbo"."Adm_m_Student"."Amst_Id" = "AMST_ID"
    AND "dbo"."Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_ID" 
    AND "Adm_M_Student"."MI_Id" = "MI_Id" 
    GROUP BY 
        "dbo"."Adm_M_Student"."AMST_AdmNo", 
        "dbo"."Adm_M_Student"."AMST_FirstName",
        "dbo"."Adm_M_Student"."AMST_MiddleName",
        "dbo"."Adm_M_Student"."AMST_LastName", 
        "dbo"."Adm_School_Y_Student"."AMAY_RollNo";
END;
$$;