CREATE OR REPLACE FUNCTION "FEE_STUDENTGROUP_NAME_SEARCH_BEFORE"(
    "@Mi_Id" bigint,
    "@searchtext" text,
    "@ASMAY_ID" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FirstName" text,
    "AMST_MiddleName" text,
    "AMST_LastName" text,
    "AMST_AdmNo" text,
    "AMST_RegistrationNo" text,
    "AMAY_RollNo" text,
    "ASMCL_ClassName" text,
    "ASMC_SectionName" text,
    "AMST_MobileNo" text,
    "ASMCL_Order" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."AMST_Id",
        a."AMST_FirstName",
        a."AMST_MiddleName",
        a."AMST_LastName",
        a."AMST_AdmNo",
        a."AMST_RegistrationNo",
        a."AMAY_RollNo",
        a."ASMCL_ClassName",
        a."ASMC_SectionName",
        a."AMST_MobileNo",
        a."ASMCL_Order"
    FROM (
        SELECT DISTINCT 
            "A"."AMST_Id",
            COALESCE("A"."AMST_FirstName", '') AS "AMST_FirstName",
            COALESCE("A"."AMST_MiddleName", '') AS "AMST_MiddleName",
            COALESCE("A"."AMST_LastName", '') AS "AMST_LastName",
            (COALESCE("A"."AMST_FirstName", '') || ' ' || COALESCE("A"."AMST_MiddleName", '') || '' || COALESCE("A"."AMST_LastName", '')) AS "StudentName",
            "A"."AMST_AdmNo",
            "A"."AMST_RegistrationNo",
            "D"."AMAY_RollNo",
            "C"."ASMCL_ClassName",
            "G"."ASMC_SectionName",
            "A"."AMST_MobileNo",
            "C"."ASMCL_Order"
        FROM "Adm_M_Student" AS "A"
        INNER JOIN "Adm_School_Y_Student" AS "D" ON "D"."AMST_Id" = "A"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" AS "C" ON "C"."ASMCL_Id" = "D"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" AS "G" ON "G"."ASMS_Id" = "D"."ASMS_Id"
        WHERE "A"."MI_Id" = "@Mi_Id" 
            AND "D"."ASMAY_ID" = "@ASMAY_ID" 
            AND "C"."MI_Id" = "@Mi_Id" 
            AND "G"."MI_Id" = "@Mi_Id" 
            AND "D"."AMAY_ActiveFlag" = 1 
            AND "A"."AMST_ActiveFlag" = 1 
            AND "A"."AMST_SOL" = 'S'
    ) a 
    WHERE (
        CASE 
            WHEN POSITION(' ' IN a."StudentName") > 0 
            THEN REPLACE(a."StudentName", ' ', '') 
            ELSE NULL
        END
    ) LIKE '%' || (
        CASE 
            WHEN POSITION(' ' IN "@searchtext") > 0 
            THEN REPLACE("@searchtext", ' ', '') 
            ELSE NULL
        END
    ) || '%'
    OR (
        a."AMST_FirstName" LIKE "@searchtext" || '%' 
        OR a."AMST_MiddleName" LIKE "@searchtext" || '%' 
        OR a."AMST_LastName" LIKE "@searchtext" || '%'
    )
    ORDER BY a."ASMCL_Order";
END;
$$;