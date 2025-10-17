CREATE OR REPLACE FUNCTION "dbo"."FeeItReceipt_studentsNames_Get"(
    "yearid" bigint,
    "miid" bigint,
    "amstid" bigint
)
RETURNS TABLE(
    "stuname" text,
    "AMST_RegistrationNo" varchar,
    "AMST_AdmNo" varchar,
    "AMST_DOB" timestamp,
    "fathername" varchar,
    "mothername" varchar,
    "ASMAY_Year" varchar,
    "classname" varchar,
    "sectionname" varchar,
    "clientname" varchar,
    "insaddress" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        ("Adm_M_Student"."AMST_FirstName" || "Adm_M_Student"."AMST_MiddleName" || "Adm_M_Student"."AMST_LastName")::text AS "stuname",
        "Adm_M_Student"."AMST_RegistrationNo",
        "Adm_M_Student"."AMST_AdmNo",
        "Adm_M_Student"."AMST_DOB",
        "Adm_M_Student"."AMST_FatherName" AS "fathername",
        "Adm_M_Student"."AMST_MotherName" AS "mothername",
        "Adm_School_M_Academic_Year"."ASMAY_Year",
        "Adm_School_M_Class"."ASMCL_ClassName" AS "classname",
        "Adm_School_M_Section"."ASMC_SectionName" AS "sectionname",
        "Master_Institution"."MI_Name" AS "clientname",
        "Master_Institution"."MI_Address1" AS "insaddress"
    FROM "dbo"."Adm_School_Y_Student"
    INNER JOIN "dbo"."Adm_School_M_Section" 
        ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
    INNER JOIN "dbo"."Adm_M_Student" 
        ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" 
        ON "Adm_M_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" 
        ON "Adm_M_Student"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
    INNER JOIN "dbo"."Master_Institution" 
        ON "Adm_M_Student"."MI_Id" = "Master_Institution"."MI_Id"
    WHERE "Adm_M_Student"."amst_id" = "amstid" 
        AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "yearid" 
        AND "Adm_M_Student"."MI_Id" = "miid";
END;
$$;