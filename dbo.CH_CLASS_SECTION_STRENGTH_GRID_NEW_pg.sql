CREATE OR REPLACE FUNCTION "dbo"."CH_CLASS_SECTION_STRENGTH_GRID_NEW"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "withtc" boolean,
    "withdeactive" boolean
)
RETURNS TABLE(
    "asmayid" bigint,
    "classid" bigint,
    "class_Name" varchar,
    "sectionname" varchar,
    "asmS_Id" bigint,
    "ASMCL_Order" int,
    "ASMC_Order" int,
    "stud_count" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "withtc" = false AND "withdeactive" = false THEN
        RETURN QUERY
        SELECT "B"."ASMAY_Id" AS asmayid,
               "C"."ASMCL_Id" AS classid,
               "C"."ASMCL_ClassName" AS class_Name,
               "D"."ASMC_SectionName" AS sectionname,
               "D"."ASMS_Id" AS asmS_Id,
               "C"."ASMCL_Order",
               "D"."ASMC_Order",
               COUNT("B"."AMST_Id") AS stud_count
        FROM "Adm_M_Student" AS "A"
        INNER JOIN "Adm_School_Y_Student" AS "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" AS "C" ON "B"."ASMCL_Id" = "C"."ASMCL_Id" AND "C"."ASMCL_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Section" AS "D" ON "D"."ASMS_Id" = "B"."ASMS_Id" AND "D"."ASMC_ActiveFlag" = 1
        WHERE "A"."MI_Id" = "MI_Id" 
          AND "C"."MI_Id" = "MI_Id" 
          AND "A"."ASMAY_Id" = "ASMAY_Id" 
          AND "A"."AMST_SOL" = 'S' 
          AND "B"."AMAY_ActiveFlag" = 1 
          AND "A"."AMST_ActiveFlag" = 1
        GROUP BY "B"."ASMAY_Id", "C"."ASMCL_Id", "C"."ASMCL_ClassName", "D"."ASMC_SectionName", "D"."ASMS_Id", "C"."ASMCL_Order", "D"."ASMC_Order"
        ORDER BY "C"."ASMCL_Order", "D"."ASMC_Order";
        
    ELSIF "withtc" = true AND "withdeactive" = false THEN
        RETURN QUERY
        SELECT "B"."ASMAY_Id" AS asmayid,
               "C"."ASMCL_Id" AS classid,
               "C"."ASMCL_ClassName" AS class_Name,
               "D"."ASMC_SectionName" AS sectionname,
               "D"."ASMS_Id" AS asmS_Id,
               "C"."ASMCL_Order",
               "D"."ASMC_Order",
               COUNT("B"."AMST_Id") AS stud_count
        FROM "Adm_M_Student" AS "A"
        INNER JOIN "Adm_School_Y_Student" AS "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" AS "C" ON "B"."ASMCL_Id" = "C"."ASMCL_Id" AND "C"."ASMCL_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Section" AS "D" ON "D"."ASMS_Id" = "B"."ASMS_Id" AND "D"."ASMC_ActiveFlag" = 1
        WHERE "A"."MI_Id" = "MI_Id" 
          AND "C"."MI_Id" = "MI_Id" 
          AND "A"."ASMAY_Id" = "ASMAY_Id" 
          AND "A"."AMST_SOL" IN ('S', 'L') 
          AND "B"."AMAY_ActiveFlag" IN (1, 0) 
          AND "A"."AMST_ActiveFlag" IN (0, 1)
        GROUP BY "B"."ASMAY_Id", "C"."ASMCL_Id", "C"."ASMCL_ClassName", "D"."ASMC_SectionName", "D"."ASMS_Id", "C"."ASMCL_Order", "D"."ASMC_Order"
        ORDER BY "C"."ASMCL_Order", "D"."ASMC_Order";
        
    ELSIF "withtc" = false AND "withdeactive" = true THEN
        RETURN QUERY
        SELECT "B"."ASMAY_Id" AS asmayid,
               "C"."ASMCL_Id" AS classid,
               "C"."ASMCL_ClassName" AS class_Name,
               "D"."ASMC_SectionName" AS sectionname,
               "D"."ASMS_Id" AS asmS_Id,
               "C"."ASMCL_Order",
               "D"."ASMC_Order",
               COUNT("B"."AMST_Id") AS stud_count
        FROM "Adm_M_Student" AS "A"
        INNER JOIN "Adm_School_Y_Student" AS "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" AS "C" ON "B"."ASMCL_Id" = "C"."ASMCL_Id" AND "C"."ASMCL_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Section" AS "D" ON "D"."ASMS_Id" = "B"."ASMS_Id" AND "D"."ASMC_ActiveFlag" = 1
        WHERE "A"."MI_Id" = "MI_Id" 
          AND "C"."MI_Id" = "MI_Id" 
          AND "A"."ASMAY_Id" = "ASMAY_Id" 
          AND "A"."AMST_SOL" IN ('S', 'D') 
          AND "B"."AMAY_ActiveFlag" IN (1) 
          AND "A"."AMST_ActiveFlag" IN (1)
        GROUP BY "B"."ASMAY_Id", "C"."ASMCL_Id", "C"."ASMCL_ClassName", "D"."ASMC_SectionName", "D"."ASMS_Id", "C"."ASMCL_Order", "D"."ASMC_Order"
        ORDER BY "C"."ASMCL_Order", "D"."ASMC_Order";
        
    ELSIF "withtc" = true AND "withdeactive" = true THEN
        RETURN QUERY
        SELECT "B"."ASMAY_Id" AS asmayid,
               "C"."ASMCL_Id" AS classid,
               "C"."ASMCL_ClassName" AS class_Name,
               "D"."ASMC_SectionName" AS sectionname,
               "D"."ASMS_Id" AS asmS_Id,
               "C"."ASMCL_Order",
               "D"."ASMC_Order",
               COUNT("B"."AMST_Id") AS stud_count
        FROM "Adm_M_Student" AS "A"
        INNER JOIN "Adm_School_Y_Student" AS "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" AS "C" ON "B"."ASMCL_Id" = "C"."ASMCL_Id" AND "C"."ASMCL_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Section" AS "D" ON "D"."ASMS_Id" = "B"."ASMS_Id" AND "D"."ASMC_ActiveFlag" = 1
        WHERE "A"."MI_Id" = "MI_Id" 
          AND "C"."MI_Id" = "MI_Id" 
          AND "A"."ASMAY_Id" = "ASMAY_Id" 
          AND "A"."AMST_SOL" IN ('S', 'D', 'L') 
          AND "B"."AMAY_ActiveFlag" IN (1, 0) 
          AND "A"."AMST_ActiveFlag" IN (1, 0)
        GROUP BY "B"."ASMAY_Id", "C"."ASMCL_Id", "C"."ASMCL_ClassName", "D"."ASMC_SectionName", "D"."ASMS_Id", "C"."ASMCL_Order", "D"."ASMC_Order"
        ORDER BY "C"."ASMCL_Order", "D"."ASMC_Order";
    END IF;
    
    RETURN;
END;
$$;