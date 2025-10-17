CREATE OR REPLACE FUNCTION "dbo"."AttendanceReport_NEW"(
    "ASMAY_ID" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "type" TEXT,
    "mi_id" TEXT,
    "flag" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "AMST_AdmNo" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "Amst_LastName" VARCHAR,
    "classes" BIGINT,
    "attendance" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMAY_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN

    IF "flag" = '1' THEN  -- if staff login
        
        IF "type" = '1' THEN
            
            "query" := 'SELECT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", 
                COALESCE("Adm_M_Student"."AMST_FirstName", '''') as "AMST_FirstName", COALESCE("Adm_M_Student"."AMST_MiddleName", '''') as "AMST_MiddleName", COALESCE("Adm_M_Student"."Amst_LastName", '''') as "Amst_LastName",     
                SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS "classes", SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "attendance", "Adm_School_M_Class"."ASMCL_ClassName",       
                "Adm_School_M_Section"."ASMC_SectionName", "Adm_School_Y_Student"."ASMAY_Id"      
                FROM "Adm_School_Y_Student" INNER JOIN      
                "Adm_Student_Attendance_Students" ON "Adm_Student_Attendance_Students"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN      
                "Adm_Student_Attendance" ON "Adm_Student_Attendance"."ASA_Id" = "Adm_Student_Attendance_Students"."ASA_Id" AND "Adm_Student_Attendance"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" INNER JOIN      
                "Adm_School_M_Class" ON "Adm_Student_Attendance"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN      
                "Adm_School_M_Section" ON "Adm_Student_Attendance"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"      
                INNER JOIN "adm_M_student" ON "adm_M_student"."amst_id" = "Adm_School_Y_Student"."AMST_Id" 
                WHERE ("Adm_M_Student"."AMST_SOL" = ''S'' AND "ASA_Activeflag" = 1)    
                AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ' AND "Adm_M_Student"."AMST_ActiveFlag" = 1 AND "Adm_School_Y_Student"."amay_activeflag" = 1 AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || ' AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "Adm_School_Y_Student"."ASMS_Id" IN (' || "ASMS_Id" || ')
                GROUP BY "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", "Adm_M_Student"."AMST_FirstName",       
                "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."Amst_LastName", "Adm_School_M_Class"."ASMCL_ClassName",       
                "Adm_School_M_Section"."ASMC_SectionName", "Adm_School_Y_Student"."ASMAY_Id"       
                HAVING SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") = SUM("Adm_Student_Attendance"."ASA_ClassHeld")';

            RETURN QUERY EXECUTE "query";

        ELSIF "type" = '2' THEN
            
            RETURN QUERY
            SELECT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", 
                COALESCE("Adm_M_Student"."AMST_FirstName", '') as "AMST_FirstName",       
                COALESCE("Adm_M_Student"."AMST_MiddleName", '') as "AMST_MiddleName", COALESCE("Adm_M_Student"."Amst_LastName", '') as "Amst_LastName",     
                SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS "classes",       
                SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "attendance",
                "Adm_School_M_Class"."ASMCL_ClassName",       
                "Adm_School_M_Section"."ASMC_SectionName", "Adm_School_Y_Student"."ASMAY_Id"      
            FROM "Adm_School_Y_Student" INNER JOIN "Adm_Student_Attendance_Students" 
                ON "Adm_Student_Attendance_Students"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
            INNER JOIN "Adm_Student_Attendance" ON "Adm_Student_Attendance"."ASA_Id" = "Adm_Student_Attendance_Students"."ASA_Id" AND "Adm_Student_Attendance"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" ON "Adm_Student_Attendance"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN      
                "Adm_School_M_Section" ON "Adm_Student_Attendance"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
            INNER JOIN "adm_M_student" ON "adm_M_student"."amst_id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE ("Adm_M_Student"."AMST_SOL" = 'S' AND "ASA_Activeflag" = 1) AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_ID"::INTEGER AND "Adm_School_Y_Student"."ASMCL_Id" = "ASMCL_Id"::INTEGER AND "Adm_School_Y_Student"."ASMS_Id" = "ASMS_Id"::INTEGER AND "Adm_M_Student"."AMST_ActiveFlag" = 1 AND "Adm_School_Y_Student"."amay_activeflag" = 1 AND "Adm_M_Student"."MI_Id" = "mi_id"::INTEGER
            GROUP BY "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", "Adm_M_Student"."AMST_FirstName",       
                "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."Amst_LastName", "Adm_School_M_Class"."ASMCL_ClassName",       
                "Adm_School_M_Section"."ASMC_SectionName", "Adm_School_Y_Student"."ASMAY_Id"       
            HAVING SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") = SUM("Adm_Student_Attendance"."ASA_ClassHeld");

        END IF;

    ELSE  -- if admin and others
        
        IF "type" = '1' THEN
            
            RETURN QUERY
            SELECT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", COALESCE("Adm_M_Student"."AMST_FirstName", '')    
                as "AMST_FirstName",       
                COALESCE("Adm_M_Student"."AMST_MiddleName", '') as "AMST_MiddleName", COALESCE("Adm_M_Student"."Amst_LastName", '') as "Amst_LastName",     
                SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS "classes",       
                SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "attendance", "Adm_School_M_Class"."ASMCL_ClassName",       
                "Adm_School_M_Section"."ASMC_SectionName", "Adm_School_Y_Student"."ASMAY_Id"      
            FROM "Adm_School_Y_Student" INNER JOIN      
                "Adm_Student_Attendance_Students" ON "Adm_Student_Attendance_Students"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN      
                "Adm_Student_Attendance" ON "Adm_Student_Attendance"."ASA_Id" = "Adm_Student_Attendance_Students"."ASA_Id" AND "Adm_Student_Attendance"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" INNER JOIN      
                "Adm_School_M_Class" ON "Adm_Student_Attendance"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN      
                "Adm_School_M_Section" ON "Adm_Student_Attendance"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
            INNER JOIN "adm_M_student" ON "adm_M_student"."amst_id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE ("Adm_M_Student"."AMST_SOL" = 'S' AND "ASA_Activeflag" = 1)    
                AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_ID"::INTEGER AND "Adm_M_Student"."AMST_ActiveFlag" = 1 AND "Adm_School_Y_Student"."amay_activeflag" = 1 AND "Adm_M_Student"."MI_Id" = "mi_id"::INTEGER
            GROUP BY "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", "Adm_M_Student"."AMST_FirstName",       
                "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."Amst_LastName", "Adm_School_M_Class"."ASMCL_ClassName",       
                "Adm_School_M_Section"."ASMC_SectionName", "Adm_School_Y_Student"."ASMAY_Id"       
            HAVING SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") = SUM("Adm_Student_Attendance"."ASA_ClassHeld");

        ELSIF "type" = '2' THEN
            
            "query" := 'SELECT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", 
                COALESCE("Adm_M_Student"."AMST_FirstName", '''') as "AMST_FirstName",       
                COALESCE("Adm_M_Student"."AMST_MiddleName", '''') as "AMST_MiddleName", COALESCE("Adm_M_Student"."Amst_LastName", '''') as "Amst_LastName",     
                SUM("Adm_Student_Attendance"."ASA_ClassHeld") AS "classes",       
                SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") AS "attendance", "Adm_School_M_Class"."ASMCL_ClassName",       
                "Adm_School_M_Section"."ASMC_SectionName", "Adm_School_Y_Student"."ASMAY_Id"      
                FROM "Adm_School_Y_Student" INNER JOIN      
                "Adm_Student_Attendance_Students" ON "Adm_Student_Attendance_Students"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN      
                "Adm_Student_Attendance" ON "Adm_Student_Attendance"."ASA_Id" = "Adm_Student_Attendance_Students"."ASA_Id" AND "Adm_Student_Attendance"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" INNER JOIN      
                "Adm_School_M_Class" ON "Adm_Student_Attendance"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN      
                "Adm_School_M_Section" ON "Adm_Student_Attendance"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"      
                INNER JOIN "adm_M_student" ON "adm_M_student"."amst_id" = "Adm_School_Y_Student"."AMST_Id" 
                WHERE ("Adm_M_Student"."AMST_SOL" = ''S'' AND "ASA_Activeflag" = 1) AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ' AND "Adm_M_Student"."AMST_ActiveFlag" = 1 AND "Adm_School_Y_Student"."amay_activeflag" = 1 AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || ' AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "Adm_School_Y_Student"."ASMS_Id" IN (' || "ASMS_Id" || ')
                GROUP BY "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", "Adm_M_Student"."AMST_FirstName",       
                "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."Amst_LastName", "Adm_School_M_Class"."ASMCL_ClassName",       
                "Adm_School_M_Section"."ASMC_SectionName", "Adm_School_Y_Student"."ASMAY_Id"       
                HAVING SUM("Adm_Student_Attendance_Students"."ASA_Class_Attended") = SUM("Adm_Student_Attendance"."ASA_ClassHeld")';

            RETURN QUERY EXECUTE "query";

        END IF;

    END IF;

    RETURN;

END;
$$;