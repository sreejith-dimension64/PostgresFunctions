CREATE OR REPLACE FUNCTION "dbo"."AttendanceReport"(
    "ASMAY_ID" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "type" bigint,
    "mi_id" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_AdmNo" varchar,
    "AMST_RegistrationNo" varchar,
    "AMST_FirstName" varchar,
    "AMST_MiddleName" varchar,
    "Amst_LastName" varchar,
    "classes" bigint,
    "attendance" bigint,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "ASMAY_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "type" = 1 THEN
        RETURN QUERY
        SELECT "Adm_M_Student"."AMST_Id", 
               "Adm_M_Student"."AMST_AdmNo", 
               "Adm_M_Student"."AMST_RegistrationNo", 
               COALESCE("Adm_M_Student"."AMST_FirstName", '')::varchar AS "AMST_FirstName",
               COALESCE("Adm_M_Student"."AMST_MiddleName", '')::varchar AS "AMST_MiddleName",
               COALESCE("Adm_M_Student"."Amst_LastName", '')::varchar AS "Amst_LastName",
               SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS classes,
               SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS attendance,
               "Adm_School_M_Class"."ASMCL_ClassName",
               "Adm_School_M_Section"."ASMC_SectionName",
               "Adm_School_Y_Student"."ASMAY_Id"
        FROM "dbo"."Adm_School_Y_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "Adm_Student_Attendance_Students"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
            ON "Adm_Student_Attendance"."ASA_Id" = "Adm_Student_Attendance_Students"."ASA_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "Adm_Student_Attendance"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "Adm_Student_Attendance"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_M_Student" 
            ON "Adm_Student_Attendance"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
        WHERE "Adm_M_Student"."AMST_SOL" = 'S'
          AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_ID"
          AND "Adm_M_Student"."AMST_ActiveFlag" = 1
          AND "Adm_School_Y_Student"."amay_activeflag" = 1
          AND "Adm_M_Student"."MI_Id" = "mi_id"
        GROUP BY "Adm_M_Student"."AMST_Id",
                 "Adm_M_Student"."AMST_AdmNo",
                 "Adm_M_Student"."AMST_RegistrationNo",
                 "Adm_M_Student"."AMST_FirstName",
                 "Adm_M_Student"."AMST_MiddleName",
                 "Adm_M_Student"."Amst_LastName",
                 "Adm_School_M_Class"."ASMCL_ClassName",
                 "Adm_School_M_Section"."ASMC_SectionName",
                 "Adm_School_Y_Student"."ASMAY_Id"
        HAVING SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") = SUM("Adm_Student_Attendance"."ASA_ClassHeld");
    
    ELSIF "type" = 2 THEN
        RETURN QUERY
        SELECT "Adm_M_Student"."AMST_Id", 
               "Adm_M_Student"."AMST_AdmNo", 
               "Adm_M_Student"."AMST_RegistrationNo", 
               COALESCE("Adm_M_Student"."AMST_FirstName", '')::varchar AS "AMST_FirstName",
               COALESCE("Adm_M_Student"."AMST_MiddleName", '')::varchar AS "AMST_MiddleName",
               COALESCE("Adm_M_Student"."Amst_LastName", '')::varchar AS "Amst_LastName",
               SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS classes,
               SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS attendance,
               "Adm_School_M_Class"."ASMCL_ClassName",
               "Adm_School_M_Section"."ASMC_SectionName",
               "Adm_School_Y_Student"."ASMAY_Id"
        FROM "dbo"."Adm_School_Y_Student"
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "Adm_Student_Attendance_Students"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_Student_Attendance" 
            ON "Adm_Student_Attendance"."ASA_Id" = "Adm_Student_Attendance_Students"."ASA_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "Adm_Student_Attendance"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "Adm_Student_Attendance"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_M_Student" 
            ON "Adm_Student_Attendance"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
        WHERE "Adm_M_Student"."AMST_SOL" = 'S'
          AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_ID"
          AND "Adm_School_Y_Student"."ASMCL_Id" = "ASMCL_Id"
          AND "Adm_School_Y_Student"."ASMS_Id" = "ASMS_Id"
          AND "Adm_M_Student"."AMST_ActiveFlag" = 1
          AND "Adm_School_Y_Student"."amay_activeflag" = 1
          AND "Adm_M_Student"."MI_Id" = "mi_id"
        GROUP BY "Adm_M_Student"."AMST_Id",
                 "Adm_M_Student"."AMST_AdmNo",
                 "Adm_M_Student"."AMST_RegistrationNo",
                 "Adm_M_Student"."AMST_FirstName",
                 "Adm_M_Student"."AMST_MiddleName",
                 "Adm_M_Student"."Amst_LastName",
                 "Adm_School_M_Class"."ASMCL_ClassName",
                 "Adm_School_M_Section"."ASMC_SectionName",
                 "Adm_School_Y_Student"."ASMAY_Id"
        HAVING SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") = SUM("Adm_Student_Attendance"."ASA_ClassHeld");
    END IF;
    
    RETURN;
END;
$$;