CREATE OR REPLACE FUNCTION "dbo"."Adm_Hostel_Food_Conveyance_Report"(
    "flag" TEXT,
    "yearId" BIGINT,
    "classid" BIGINT,
    "sectionid" BIGINT,
    "mi_id" BIGINT
)
RETURNS TABLE(
    "regno" VARCHAR,
    "admno" VARCHAR,
    "stuFN" VARCHAR,
    "stuMN" VARCHAR,
    "stuLN" VARCHAR,
    "class" VARCHAR,
    "section" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "flag" = 'H' THEN
    
        RETURN QUERY
        SELECT DISTINCT ON ("dbo"."Adm_M_Student"."AMST_RegistrationNo")
            "dbo"."Adm_M_Student"."AMST_RegistrationNo" AS "regno",
            "dbo"."Adm_M_Student"."AMST_AdmNo" AS "admno",
            COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') AS "stuFN",
            COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') AS "stuMN",
            COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '') AS "stuLN",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName" AS "class",
            "dbo"."Adm_School_M_Section"."ASMC_SectionName" AS "section"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "dbo"."Adm_M_Student"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        WHERE "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "classid"
            AND "dbo"."Adm_School_Y_Student"."ASMS_Id" = "sectionid"
            AND "dbo"."Adm_M_Student"."ASMAY_Id" = "yearId"
            AND "dbo"."Adm_M_Student"."AMST_HostelReqdFlag" = 1
            AND "dbo"."Adm_M_Student"."MI_Id" = "mi_id"
            AND "dbo"."Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "dbo"."Adm_School_Y_Student"."amay_activeflag" = 1
            AND "dbo"."Adm_M_Student"."AMST_SOL" = 'S';
    
    ELSIF "flag" = 'C' THEN
    
        RETURN QUERY
        SELECT DISTINCT ON ("dbo"."Adm_M_Student"."AMST_RegistrationNo")
            "dbo"."Adm_M_Student"."AMST_RegistrationNo" AS "regno",
            "dbo"."Adm_M_Student"."AMST_AdmNo" AS "admno",
            COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') AS "stuFN",
            COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') AS "stuMN",
            COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '') AS "stuLN",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName" AS "class",
            "dbo"."Adm_School_M_Section"."ASMC_SectionName" AS "section"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "dbo"."Adm_M_Student"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        WHERE "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "classid"
            AND "dbo"."Adm_School_Y_Student"."ASMS_Id" = "sectionid"
            AND "dbo"."Adm_M_Student"."ASMAY_Id" = "yearId"
            AND "dbo"."Adm_M_Student"."AMST_TransportReqdFlag" = 1
            AND "dbo"."Adm_M_Student"."MI_Id" = "mi_id"
            AND "dbo"."Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "dbo"."Adm_School_Y_Student"."amay_activeflag" = 1
            AND "dbo"."Adm_M_Student"."AMST_SOL" = 'S';
    
    ELSE
    
        RETURN QUERY
        SELECT DISTINCT ON ("dbo"."Adm_M_Student"."AMST_RegistrationNo")
            "dbo"."Adm_M_Student"."AMST_RegistrationNo" AS "regno",
            "dbo"."Adm_M_Student"."AMST_AdmNo" AS "admno",
            COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '') AS "stuFN",
            COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') AS "stuMN",
            COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '') AS "stuLN",
            "dbo"."Adm_School_M_Class"."ASMCL_ClassName" AS "class",
            "dbo"."Adm_School_M_Section"."ASMC_SectionName" AS "section"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "dbo"."Adm_School_Y_Student" 
            ON "dbo"."Adm_M_Student"."ASMAY_Id" = "dbo"."Adm_School_Y_Student"."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" 
            ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" 
            ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
        WHERE "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "classid"
            AND "dbo"."Adm_School_Y_Student"."ASMS_Id" = "sectionid"
            AND "dbo"."Adm_M_Student"."ASMAY_Id" = "yearId"
            AND "dbo"."Adm_M_Student"."MI_Id" = "mi_id"
            AND "dbo"."Adm_M_Student"."AMST_ActiveFlag" = 1
            AND "dbo"."Adm_School_Y_Student"."amay_activeflag" = 1
            AND "dbo"."Adm_M_Student"."AMST_SOL" = 'S';
    
    END IF;

    RETURN;

END;
$$;