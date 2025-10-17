CREATE OR REPLACE FUNCTION "dbo"."getClassSectiondata_New" (
    "MI_ID" int,
    "EntryFlag" text,
    "ASMAY_Id" text
)
RETURNS TABLE (
    "name" text,
    "ASMCL_Id" int,
    "ASMC_Id" int,
    "classsection" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "EntryFlag" = '1' THEN
        RETURN QUERY
        SELECT 
            "class"."ASMCL_ClassName" || ' - ' || "section"."ASMC_SectionName" as "name",
            "class"."ASMCL_Id",
            "section"."ASMS_Id" as "ASMC_Id",
            "class"."ASMCL_Id"::text || '-' || "section"."ASMS_Id"::text as "classsection"
        FROM "Adm_School_M_Class" "class" 
        INNER JOIN "Adm_School_M_Section" "section" ON "class"."MI_Id" = "section"."MI_Id"
        INNER JOIN "Adm_School_Attendance_EntryType" "entrytype" ON "entrytype"."ASMCL_Id" = "class"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Class_Category" "a" ON "a"."ASMCL_Id" = "entrytype"."ASMCL_Id" 
            AND "a"."ASMCL_Id" = "class"."ASMCL_Id" 
            AND "a"."ASMAY_Id" = "entrytype"."ASMAY_Id"
        INNER JOIN "Adm_School_Master_Class_Cat_Sec" "sec" ON "sec"."ASMCC_Id" = "a"."ASMCC_Id" 
            AND "sec"."ASMS_Id" = "section"."ASMS_Id"
        WHERE "class"."MI_Id" = "MI_ID" 
            AND "section"."MI_Id" = "MI_ID" 
            AND "entrytype"."MI_Id" = "MI_ID" 
            AND "entrytype"."ASMAY_Id" = "ASMAY_Id" 
            AND "ASMCL_ActiveFlag" = 1 
            AND "ASMC_ActiveFlag" = 1 
            AND "ASAET_Att_Type" = 'P' 
            AND "a"."ASMAY_Id" = "ASMAY_Id"
        ORDER BY "class"."ASMCL_Id", "section"."ASMS_Id";
        
    ELSIF "EntryFlag" = '2' OR "EntryFlag" = '3' THEN
        RETURN QUERY
        SELECT 
            "class"."ASMCL_ClassName" || ' - ' || "section"."ASMC_SectionName" as "name",
            "class"."ASMCL_Id",
            "section"."ASMS_Id" as "ASMC_Id",
            "class"."ASMCL_Id"::text || '-' || "section"."ASMS_Id"::text as "classsection"
        FROM "Adm_School_M_Class" "class" 
        INNER JOIN "Adm_School_M_Section" "section" ON "class"."MI_Id" = "section"."MI_Id"
        INNER JOIN "Adm_School_Attendance_EntryType" "entrytype" ON "entrytype"."ASMCL_Id" = "class"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Class_Category" "a" ON "a"."ASMCL_Id" = "entrytype"."ASMCL_Id" 
            AND "a"."ASMCL_Id" = "class"."ASMCL_Id" 
            AND "a"."ASMAY_Id" = "entrytype"."ASMAY_Id"
        INNER JOIN "Adm_School_Master_Class_Cat_Sec" "sec" ON "sec"."ASMCC_Id" = "a"."ASMCC_Id" 
            AND "sec"."ASMS_Id" = "section"."ASMS_Id"
        WHERE "class"."MI_Id" = "MI_ID" 
            AND "section"."MI_Id" = "MI_ID" 
            AND "entrytype"."MI_Id" = "MI_ID" 
            AND "entrytype"."ASMAY_Id" = "ASMAY_Id" 
            AND "ASMCL_ActiveFlag" = 1 
            AND "ASMC_ActiveFlag" = 1 
            AND "ASAET_Att_Type" != 'P' 
            AND "a"."ASMAY_Id" = "ASMAY_Id"
        ORDER BY "class"."ASMCL_Id", "section"."ASMS_Id";
        
    END IF;

    RETURN;

END;
$$;