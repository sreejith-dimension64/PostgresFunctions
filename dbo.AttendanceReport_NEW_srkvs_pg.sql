CREATE OR REPLACE FUNCTION "dbo"."AttendanceReport_NEW_srkvs"(
    "ASMAY_ID" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "type" TEXT,
    "mi_id" TEXT,
    "flag" TEXT,
    "AMC_Id" VARCHAR(10)
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "AMST_AdmNo" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_FirstName" VARCHAR,
    "AMST_MiddleName" VARCHAR,
    "Amst_LastName" VARCHAR,
    "attendance" BIGINT,
    "classes" BIGINT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMAY_Id" INTEGER,
    "namme" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "category" TEXT;
BEGIN

    IF ("AMC_Id" IS NOT NULL AND "AMC_Id" != '0' AND "AMC_Id" != '') THEN
        "category" := 'and "adm_M_student"."AMC_Id"=' || "AMC_Id" || '';
    ELSE
        "category" := '';
    END IF;

    IF "flag" = '1' THEN  ------------if staff login
        
        IF "type" = '1' THEN
            
            "query" := 'SELECT "AMST_Id", "AMST_AdmNo", "AMST_RegistrationNo", "AMST_FirstName", "AMST_MiddleName", "Amst_LastName", 
            sum("ASA_Class_Attended") as attendance, 
            SUM("ASA_ClassHeld") as classes, 
            "ASMCL_ClassName", "ASMC_SectionName", "ASMAY_Id", 
            COALESCE("AMST_FirstName", '''') || '' '' || COALESCE("AMST_MiddleName", '''') || '' '' || COALESCE("Amst_LastName", '''') as namme 
            FROM (SELECT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", 
            COALESCE("Adm_M_Student"."AMST_FirstName", '''') as "AMST_FirstName",
            COALESCE("Adm_M_Student"."AMST_MiddleName", '''') as "AMST_MiddleName", 
            COALESCE("Adm_M_Student"."Amst_LastName", '''') as "Amst_LastName", 
            
            (SELECT sum("ASA_Class_Attended") FROM "Adm_Student_Attendance_Students" a 
            INNER JOIN "Adm_Student_Attendance" b ON a."asa_id" = b."asa_id" 
            WHERE "AMST_Id" = "Adm_School_Y_Student"."AMST_Id" AND "ASA_Activeflag" = 1) AS "ASA_Class_Attended",
            
            (SELECT sum("ASA_Class_Attended") FROM "Adm_Student_Attendance" "ASA" 
            INNER JOIN "Adm_Student_Attendance_Students" "ASAS" ON "ASA"."ASA_Id" = "ASAS"."ASA_Id" 
            WHERE "ASAS"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" AND "ASA_Activeflag" = 1 
            AND "ASMAY_Id" = ' || "ASMAY_ID" || ' 
            AND "ASMCL_Id" IN (' || "ASMCL_Id" || ') AND "ASMS_Id" IN (' || "ASMS_Id" || ')) AS "ASA_ClassHeld",
            
            "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", 
            "Adm_School_Y_Student"."ASMAY_Id"      
            FROM "Adm_School_Y_Student" 
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "adm_M_student" ON "adm_M_student"."amst_id" = "Adm_School_Y_Student"."AMST_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || '   
            AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || ' 
            AND "Adm_School_Y_Student"."ASMCL_Id" IN (' || "ASMCL_Id" || ')
            AND "Adm_School_Y_Student"."ASMS_Id" IN (' || "ASMS_Id" || ')
            ) AS "NEW" 
            GROUP BY "AMST_Id", "AMST_AdmNo", "AMST_RegistrationNo", "AMST_FirstName", "AMST_MiddleName", 
            "Amst_LastName", "ASMCL_ClassName", "ASMC_SectionName", "ASMAY_Id" 
            HAVING sum("ASA_Class_Attended") = sum("ASA_ClassHeld")';
            
        ELSIF "type" = '2' THEN
            
            "query" := 'SELECT "AMST_Id", "AMST_AdmNo", "AMST_RegistrationNo", "AMST_FirstName", "AMST_MiddleName", "Amst_LastName", 
            sum("ASA_Class_Attended") as attendance, 
            SUM("ASA_ClassHeld") as classes, "ASMCL_ClassName", "ASMC_SectionName", "ASMAY_Id",
            COALESCE("AMST_FirstName", '' '') || '' '' || COALESCE("AMST_MiddleName", '' '') || '' '' || COALESCE("Amst_LastName", '' '') as namme 
            FROM
            (SELECT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_RegistrationNo", 
            COALESCE("Adm_M_Student"."AMST_FirstName", '''') as "AMST_FirstName",
            COALESCE("Adm_M_Student"."AMST_MiddleName", '''') as "AMST_MiddleName", 
            COALESCE("Adm_M_Student"."Amst_LastName", '''') as "Amst_LastName",     
            
            (SELECT sum("ASA_Class_Attended") FROM "Adm_Student_Attendance_Students" a 
            INNER JOIN "Adm_Student_Attendance" b ON a."asa_id" = b."asa_id" 
            WHERE "AMST_Id" = "Adm_School_Y_Student"."AMST_Id" AND "ASA_Activeflag" = 1) AS "ASA_Class_Attended",
            
            (SELECT sum("ASA_ClassHeld") FROM "Adm_Student_Attendance" "ASA" 
            INNER JOIN "Adm_Student_Attendance_Students" "ASAS" ON "ASA"."ASA_Id" = "ASAS"."ASA_Id" 
            WHERE "ASAS"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" AND "ASA_Activeflag" = 1) AS "ASA_ClassHeld",
            
            "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", 
            "Adm_School_Y_Student"."ASMAY_Id"      
            FROM "Adm_School_Y_Student" 
            INNER JOIN "Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
            INNER JOIN "Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" 
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
            INNER JOIN "adm_M_student" ON "adm_M_student"."amst_id" = "Adm_School_Y_Student"."AMST_Id"
            LEFT JOIN "Adm_M_Category" "AMC" ON "adm_M_student"."AMC_Id" = "adm_M_student"."AMC_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ' 
            AND "Adm_M_Student"."MI_Id" = ' || "mi_id" || ' ' || "category" || '
            ) AS "NEW" 
            GROUP BY "AMST_Id", "AMST_AdmNo", "AMST_RegistrationNo", "AMST_FirstName", "AMST_MiddleName", 
            "Amst_LastName", "ASMCL_ClassName", "ASMC_SectionName", "ASMAY_Id" 
            HAVING sum("ASA_Class_Attended") = sum("ASA_ClassHeld")';
            
        END IF;
        
    ELSE  -----------if admin and others
        
        IF "type" = '1' THEN
            
            "query" := 'SELECT "adm_M_student"."AMST_Id", "adm_M_student"."AMST_AdmNo", "adm_M_student"."AMST_RegistrationNo", 
            COALESCE("adm_M_student"."AMST_FirstName", '' '') as "AMST_FirstName",
            COALESCE("adm_M_student"."AMST_MiddleName", '' '') as "AMST_MiddleName", 
            COALESCE("adm_M_student"."Amst_LastName", '' '') as "Amst_LastName",  
            COALESCE("adm_M_student"."AMST_FirstName", '' '') || '' '' || COALESCE("adm_M_student"."AMST_MiddleName", '' '') || '' '' || COALESCE("adm_M_student"."Amst_LastName", '' '') as namme,
            f."ASMCL_ClassName", g."ASMC_SectionName", sum("ASA_Class_Attended") as attendance, sum("ASA_ClassHeld") as classes, 0::integer as "ASMAY_Id"
            FROM "Adm_Student_Attendance" a 
            INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
            INNER JOIN "Adm_School_Y_Student" c ON c."amst_id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" "adm_M_student" ON "adm_M_student"."AMST_Id" = c."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id" AND e."ASMAY_Id" = c."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = a."ASMCL_Id" AND f."ASMCL_Id" = c."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = a."ASMS_Id" AND g."ASMS_Id" = c."ASMS_Id"
            LEFT JOIN "Adm_M_Category" "AMC" ON "adm_M_student"."AMC_Id" = "adm_M_student"."AMC_Id"
            WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" = ' || "ASMAY_ID" || ' 
            AND c."ASMAY_Id" = ' || "ASMAY_ID" || ' AND "ASA_Activeflag" = 1 ' || "category" || '
            GROUP BY "adm_M_student"."AMST_Id", "adm_M_student"."AMST_AdmNo", "adm_M_student"."AMST_RegistrationNo", 
            "AMST_FirstName", "AMST_MiddleName", "Amst_LastName", f."ASMCL_ClassName", g."ASMC_SectionName"
            HAVING sum("ASA_Class_Attended") = sum("ASA_ClassHeld")';
            
        ELSIF "type" = '2' THEN
            
            "query" := 'SELECT "adm_M_student"."AMST_Id", "adm_M_student"."AMST_AdmNo", "adm_M_student"."AMST_RegistrationNo", 
            COALESCE("adm_M_student"."AMST_FirstName", '''') as "AMST_FirstName",
            COALESCE("adm_M_student"."AMST_MiddleName", '''') as "AMST_MiddleName", 
            COALESCE("adm_M_student"."Amst_LastName", '''') as "Amst_LastName",  
            f."ASMCL_ClassName", g."ASMC_SectionName", sum("ASA_Class_Attended") as attendance, sum("ASA_ClassHeld") as classes, 
            COALESCE("adm_M_student"."AMST_FirstName", '''') || '' '' || COALESCE("adm_M_student"."AMST_MiddleName", '''') || '' '' || COALESCE("adm_M_student"."Amst_LastName", '''') as namme, 0::integer as "ASMAY_Id"
            FROM "Adm_Student_Attendance" a 
            INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id"
            INNER JOIN "Adm_School_Y_Student" c ON c."amst_id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" ON "adm_M_student"."AMST_Id" = c."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id" AND e."ASMAY_Id" = c."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = a."ASMCL_Id" AND f."ASMCL_Id" = c."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = a."ASMS_Id" AND g."ASMS_Id" = c."ASMS_Id"
            LEFT JOIN "Adm_M_Category" "AMC" ON "adm_M_student"."AMC_Id" = "adm_M_student"."AMC_Id"
            WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" = ' || "ASMAY_ID" || ' 
            AND c."ASMAY_Id" = ' || "ASMAY_ID" || ' AND "ASA_Activeflag" = 1
            AND a."asmcl_id" IN (' || "ASMCL_Id" || ') AND c."asmcl_id" IN (' || "ASMCL_Id" || ') 
            AND a."asms_id" IN (' || "ASMS_Id" || ') AND c."asms_id" IN (' || "ASMS_Id" || ')
            ' || "category" || '
            GROUP BY "adm_M_student"."AMST_Id", "adm_M_student"."AMST_AdmNo", "adm_M_student"."AMST_RegistrationNo", 
            "AMST_FirstName", "AMST_MiddleName", "Amst_LastName", f."ASMCL_ClassName", g."ASMC_SectionName"
            HAVING sum("ASA_Class_Attended") = sum("ASA_ClassHeld")';
            
        END IF;
        
    END IF;
    
    RAISE NOTICE '%', "query";
    
    RETURN QUERY EXECUTE "query";
    
END;
$$;