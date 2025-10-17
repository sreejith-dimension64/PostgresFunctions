
CREATE OR REPLACE FUNCTION "dbo"."AttendanceDashboard_perc"(
    "mi_id" TEXT,
    "ASMAY_ID" TEXT,
    "AMST_Id" VARCHAR(50)
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "AMST_AdmNo" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_MobileNo" VARCHAR,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "Amst_LastName" VARCHAR,
    "name" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "attendance" NUMERIC,
    "classes" NUMERIC,
    "per" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN
    "query" := 'SELECT 
        "adm_M_student"."AMST_Id", 
        "adm_M_student"."AMST_AdmNo", 
        "adm_M_student"."AMST_RegistrationNo",  
        "adm_M_student"."AMST_MobileNo",
        COALESCE("adm_M_student"."AMST_FirstName", '' '') AS "AMST_FirstName",     
        COALESCE("adm_M_student"."AMST_MiddleName", '' '') AS "AMST_MiddleName",
        COALESCE("adm_M_student"."Amst_LastName", '' '') AS "Amst_LastName",          
        COALESCE("adm_M_student"."AMST_FirstName", '' '') || '' '' || COALESCE("adm_M_student"."AMST_MiddleName", '' '') || '' '' || COALESCE("adm_M_student"."Amst_LastName", '' '') AS "name",        
        "f"."ASMCL_ClassName",
        "g"."ASMC_SectionName",
        SUM("b"."ASA_Class_Attended") AS "attendance",
        SUM("a"."ASA_ClassHeld") AS "classes",
        (SUM(COALESCE("b"."ASA_Class_Attended", 0)) * 100.0) / SUM(COALESCE("a"."ASA_ClassHeld", 0)) AS "per"
    FROM "Adm_Student_Attendance" "a"         
    INNER JOIN "Adm_Student_Attendance_Students" "b" ON "a"."ASA_Id" = "b"."ASA_Id"        
    INNER JOIN "Adm_School_Y_Student" "c" ON "c"."amst_id" = "b"."AMST_Id"        
    INNER JOIN "Adm_M_Student" "adm_M_student" ON "adm_M_student"."AMST_Id" = "c"."AMST_Id"        
    INNER JOIN "Adm_School_M_Academic_Year" "e" ON "e"."ASMAY_Id" = "a"."ASMAY_Id" AND "e"."ASMAY_Id" = "c"."ASMAY_Id"        
    INNER JOIN "Adm_School_M_Class" "f" ON "f"."ASMCL_Id" = "a"."ASMCL_Id" AND "f"."ASMCL_Id" = "c"."ASMCL_Id"        
    INNER JOIN "Adm_School_M_Section" "g" ON "g"."ASMS_Id" = "b"."ASMS_Id" AND "g"."ASMS_Id" = "c"."ASMS_Id"               
    WHERE "a"."MI_Id" = ' || "mi_id" || ' 
        AND "a"."ASMAY_Id" = ' || "ASMAY_ID" || ' 
        AND "c"."ASMAY_Id" = ' || "ASMAY_ID" || ' 
        AND "a"."AMST_Id" = ' || "AMST_Id" || ' 
        AND "ASA_Activeflag" = 1       
    GROUP BY 
        "adm_M_student"."AMST_Id", 
        "adm_M_student"."AMST_AdmNo", 
        "adm_M_student"."AMST_RegistrationNo",         
        "AMST_FirstName",        
        "AMST_MiddleName",
        "Amst_LastName",
        "f"."ASMCL_ClassName",
        "g"."ASMC_SectionName",
        "adm_M_student"."AMST_MobileNo"';

    RAISE NOTICE '%', "query";
    
    RETURN QUERY EXECUTE "query";
END;
$$;