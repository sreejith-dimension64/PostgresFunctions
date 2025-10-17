CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Achievement_Report"(
    "yearId" bigint,
    "classid" bigint,
    "sectionid" bigint,
    "studid" bigint,
    "miid" bigint
)
RETURNS TABLE (
    "regno" varchar,
    "admno" varchar,
    "stuFN" varchar,
    "stuMN" varchar,
    "stuLN" varchar,
    "achivement" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF ("yearId" != 0 AND "classid" != 0 AND "sectionid" != 0 AND "studid" != 0) THEN
        RETURN QUERY
        SELECT DISTINCT 
            ("Adm_M_Student"."AMST_RegistrationNo")::"varchar" AS "regno",
            ("Adm_M_Student"."AMST_AdmNo")::"varchar" AS "admno",
            COALESCE("Adm_M_Student"."AMST_FirstName", '')::varchar AS "stuFN",
            COALESCE("Adm_M_Student"."AMST_MiddleName", '')::varchar AS "stuMN",
            COALESCE("Adm_M_Student"."AMST_LastName", '')::varchar AS "stuLN",
            COALESCE("Adm_Master_Student_Achivements"."AMSTEC_Extracurricular", '')::varchar AS "achivement"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
            ON "Adm_M_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_Master_Student_Achivements" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_Master_Student_Achivements"."AMST_Id"
        WHERE "Adm_M_Student"."AMST_Id" = "studid"
            AND "Adm_School_Y_Student"."ASMAY_Id" = "yearId"
            AND "Adm_School_Y_Student"."ASMCL_Id" = "classid"
            AND "Adm_School_Y_Student"."ASMS_Id" = "sectionid"
            AND "Adm_M_Student"."MI_Id" = "miid"
            AND "Adm_M_Student"."AMST_SOL" = 'S'
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1;
            
    ELSIF ("yearId" != 0 AND "classid" != 0 AND "sectionid" != 0 AND "studid" = 0) THEN
        RETURN QUERY
        SELECT DISTINCT 
            ("Adm_M_Student"."AMST_RegistrationNo")::"varchar" AS "regno",
            ("Adm_M_Student"."AMST_AdmNo")::"varchar" AS "admno",
            COALESCE("Adm_M_Student"."AMST_FirstName", '')::varchar AS "stuFN",
            COALESCE("Adm_M_Student"."AMST_MiddleName", '')::varchar AS "stuMN",
            COALESCE("Adm_M_Student"."AMST_LastName", '')::varchar AS "stuLN",
            COALESCE("Adm_Master_Student_Achivements"."AMSTEC_Extracurricular", '')::varchar AS "achivement"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
            ON "Adm_M_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_Master_Student_Achivements" 
            ON "Adm_M_Student"."AMST_Id" = "Adm_Master_Student_Achivements"."AMST_Id"
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = "yearId"
            AND "Adm_School_Y_Student"."ASMCL_Id" = "classid"
            AND "Adm_School_Y_Student"."ASMS_Id" = "sectionid"
            AND "Adm_M_Student"."MI_Id" = "miid"
            AND "Adm_M_Student"."AMST_SOL" = 'S'
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "Adm_School_Y_Student"."amay_activeflag" = 1;
    END IF;
    
    RETURN;
END;
$$;