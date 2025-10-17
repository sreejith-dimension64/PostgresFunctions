CREATE OR REPLACE FUNCTION "dbo"."getClassSectiondata"(
    "MI_ID" integer
)
RETURNS TABLE(
    "name" text,
    "ASMCL_Id" integer,
    "ASMC_Id" integer,
    "classsection" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "class"."ASMCL_ClassName" || ' - ' || "section"."ASMC_SectionName" as "name",
        "class"."ASMCL_Id",
        "section"."ASMS_Id" as "ASMC_Id",
        CAST("class"."ASMCL_Id" AS text) || '-' || CAST("section"."ASMS_Id" AS text) as "classsection"
    FROM "Adm_School_M_Class" as "class",
         "Adm_School_M_Section" as "section"
    WHERE "class"."MI_Id" = "MI_ID" 
      AND "class"."ASMCL_ActiveFlag" = 1 
      AND "section"."MI_Id" = "MI_ID" 
      AND "section"."ASMC_ActiveFlag" = 1
    ORDER BY "class"."ASMCL_Id", "section"."ASMS_Id";
END;
$$;