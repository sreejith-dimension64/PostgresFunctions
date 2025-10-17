CREATE OR REPLACE FUNCTION "dbo"."alumni_student_details"(
    "MI_Id" bigint,
    "flag" varchar(50)
)
RETURNS TABLE(
    "studentname" text,
    "ALMST_AdmNo" varchar,
    "ALMST_DOB" timestamp,
    "ALMST_FatherName" varchar,
    "ALMST_MobileNo" varchar,
    "ALMST_ConCity" varchar,
    "ALMST_emailId" varchar,
    "ALMST_BloodGroup" varchar,
    "city" text,
    "CreatedDate" timestamp,
    "ALMST_ActiveFlag" boolean,
    "ALMST_Id" bigint,
    "ASMAY_Id_Left" bigint,
    "LeftYear" varchar,
    "JoinYear" varchar,
    "Leftclass" varchar,
    "Joinclass" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "flag" = 'Alumni' THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN a."ALMST_FirstName" IS NULL OR a."ALMST_FirstName" = '' THEN '' ELSE a."ALMST_FirstName" END ||
             CASE WHEN a."ALMST_MiddleName" IS NULL OR a."ALMST_MiddleName" = '' OR a."ALMST_MiddleName" = '0' THEN '' ELSE ' ' || a."ALMST_MiddleName" END ||
             CASE WHEN a."ALMST_LastName" IS NULL OR a."ALMST_LastName" = '' OR a."ALMST_LastName" = '0' THEN '' ELSE ' ' || a."ALMST_LastName" END)::text AS "studentname",
            a."ALMST_AdmNo",
            a."ALMST_DOB",
            a."ALMST_FatherName",
            a."ALMST_MobileNo",
            a."ALMST_ConCity",
            a."ALMST_emailId",
            a."ALMST_BloodGroup",
            (b."IVRMMS_Name" || ':' || a."ALMST_ConCity")::text AS "city",
            a."CreatedDate",
            a."ALMST_ActiveFlag",
            a."ALMST_Id",
            a."ASMAY_Id_Left",
            (SELECT "AY"."ASMAY_Year" FROM "Adm_School_M_Academic_Year" "AY" WHERE "AY"."ASMAY_Id" = a."ASMAY_Id_Left") AS "LeftYear",
            (SELECT "AY"."ASMAY_Year" FROM "Adm_School_M_Academic_Year" "AY" WHERE "AY"."ASMAY_Id" = a."ASMAY_Id_Join") AS "JoinYear",
            (SELECT "AC"."ASMCL_ClassName" FROM "Adm_School_M_Class" "AC" WHERE "AC"."ASMCL_Id" = a."ASMCL_Id_Left") AS "Leftclass",
            (SELECT "AC"."ASMCL_ClassName" FROM "Adm_School_M_Class" "AC" WHERE "AC"."ASMCL_Id" = a."ASMCL_Id_Join") AS "Joinclass"
        FROM "ALU"."Alumni_Master_Student" a, "IVRM_Master_State" b
        WHERE a."MI_Id" = "MI_Id" 
          AND a."ALMST_ConState" = b."IVRMMS_Id"
        ORDER BY a."ALMST_Id" DESC;
        
    ELSIF "flag" = 'AlumniNew' THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN a."ALMST_FirstName" IS NULL OR a."ALMST_FirstName" = '' THEN '' ELSE a."ALMST_FirstName" END ||
             CASE WHEN a."ALMST_MiddleName" IS NULL OR a."ALMST_MiddleName" = '' OR a."ALMST_MiddleName" = '0' THEN '' ELSE ' ' || a."ALMST_MiddleName" END ||
             CASE WHEN a."ALMST_LastName" IS NULL OR a."ALMST_LastName" = '' OR a."ALMST_LastName" = '0' THEN '' ELSE ' ' || a."ALMST_LastName" END)::text AS "studentname",
            a."ALMST_AdmNo",
            a."ALMST_DOB",
            a."ALMST_FatherName",
            a."ALMST_MobileNo",
            a."ALMST_ConCity",
            a."ALMST_emailId",
            a."ALMST_BloodGroup",
            (b."IVRMMS_Name" || ':' || a."ALMST_ConCity")::text AS "city",
            a."CreatedDate",
            a."ALMST_ActiveFlag",
            a."ALMST_Id",
            a."ASMAY_Id_Left",
            (SELECT "AY"."ASMAY_Year" FROM "Adm_School_M_Academic_Year" "AY" WHERE "AY"."ASMAY_Id" = a."ASMAY_Id_Left") AS "LeftYear",
            (SELECT "AY"."ASMAY_Year" FROM "Adm_School_M_Academic_Year" "AY" WHERE "AY"."ASMAY_Id" = a."ASMAY_Id_Join") AS "JoinYear",
            (SELECT "AC"."ASMCL_ClassName" FROM "Adm_School_M_Class" "AC" WHERE "AC"."ASMCL_Id" = a."ASMCL_Id_Left") AS "Leftclass",
            (SELECT "AC"."ASMCL_ClassName" FROM "Adm_School_M_Class" "AC" WHERE "AC"."ASMCL_Id" = a."ASMCL_Id_Join") AS "Joinclass"
        FROM "ALU"."Alumni_Master_Student" a, "IVRM_Master_State" b
        WHERE a."MI_Id" = "MI_Id" 
          AND a."ALMST_ConState" = b."IVRMMS_Id"
        ORDER BY a."ALMST_Id" DESC;
    END IF;
    
    RETURN;
END;
$$;