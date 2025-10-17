CREATE OR REPLACE FUNCTION "dbo"."AttendanceReport_perc_shortageAlert" (
    "@mi_id" TEXT,
    "@ASMAY_ID" TEXT,
    "@Percentage" VARCHAR(10)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@query" TEXT;
BEGIN
    
    DROP TABLE IF EXISTS "Student_Attendance_percentage_Temp";

    SET "@query" = 'CREATE TABLE "Student_Attendance_percentage_Temp" AS ' ||
    'SELECT "adm_M_student"."AMST_Id", "adm_M_student"."AMST_AdmNo", "adm_M_student"."AMST_RegistrationNo", "adm_M_student"."AMST_MobileNo", ' ||
    'COALESCE("adm_M_student"."AMST_FirstName", '' '') AS "AMST_FirstName", ' ||
    'COALESCE("adm_M_student"."AMST_MiddleName", '' '') AS "AMST_MiddleName", COALESCE("adm_M_student"."Amst_LastName", '' '') AS "Amst_LastName", ' ||
    'COALESCE("adm_M_student"."AMST_FirstName", '' '') || '' '' || COALESCE("adm_M_student"."AMST_MiddleName", '' '') || '' '' || COALESCE("adm_M_student"."Amst_LastName", '' '') AS "name", ' ||
    '"f"."ASMCL_Id", "g"."ASMS_Id", "f"."ASMCL_ClassName", "g"."ASMC_SectionName", ' ||
    'SUM("b"."ASA_Class_Attended") AS "attendance", SUM("a"."ASA_ClassHeld") AS "classes", ' ||
    '(SUM(COALESCE("b"."ASA_Class_Attended", 0)) * 100.0) / SUM(COALESCE("a"."ASA_ClassHeld", 0)) AS "per" ' ||
    'FROM "Adm_Student_Attendance" "a" ' ||
    'INNER JOIN "Adm_Student_Attendance_Students" "b" ON "a"."ASA_Id" = "b"."ASA_Id" ' ||
    'INNER JOIN "Adm_School_Y_Student" "c" ON "c"."amst_id" = "b"."AMST_Id" ' ||
    'INNER JOIN "Adm_M_Student" "adm_M_student" ON "adm_M_student"."AMST_Id" = "c"."AMST_Id" ' ||
    'INNER JOIN "Adm_School_M_Academic_Year" "e" ON "e"."ASMAY_Id" = "a"."ASMAY_Id" AND "e"."ASMAY_Id" = "c"."ASMAY_Id" ' ||
    'INNER JOIN "Adm_School_M_Class" "f" ON "f"."ASMCL_Id" = "a"."ASMCL_Id" AND "f"."ASMCL_Id" = "c"."ASMCL_Id" ' ||
    'INNER JOIN "Adm_School_M_Section" "g" ON "g"."ASMS_Id" = "a"."ASMS_Id" AND "g"."ASMS_Id" = "c"."ASMS_Id" ' ||
    'WHERE "a"."MI_Id" = ' || "@mi_id" || ' AND "a"."ASMAY_Id" = ' || "@ASMAY_ID" || ' AND "c"."ASMAY_Id" = ' || "@ASMAY_ID" || ' AND "ASA_Activeflag" = 1 ' ||
    'GROUP BY "adm_M_student"."AMST_Id", "adm_M_student"."AMST_AdmNo", "adm_M_student"."AMST_RegistrationNo", ' ||
    '"AMST_FirstName", "AMST_MiddleName", "Amst_LastName", "f"."ASMCL_ClassName", "g"."ASMC_SectionName", "adm_M_student"."AMST_MobileNo", "f"."ASMCL_Id", "g"."ASMS_Id" ' ||
    'HAVING (SUM(COALESCE("b"."ASA_Class_Attended", 0)) * 100.0) / SUM(COALESCE("a"."ASA_ClassHeld", 0)) <= ' || "@Percentage";

    EXECUTE "@query";
    
    RAISE NOTICE '%', "@query";
    
    RETURN;
END;
$$;