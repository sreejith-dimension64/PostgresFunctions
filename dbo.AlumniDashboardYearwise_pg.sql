CREATE OR REPLACE FUNCTION "dbo"."AlumniDashboardYearwise" (
    "@MI_Id" TEXT,
    "@ASMAY_ID" TEXT
)
RETURNS TABLE (
    "BATCHES" VARCHAR,
    "NOofstudents" BIGINT,
    "classname" VARCHAR,
    "ASMCL_Id" INTEGER,
    "ASMAY_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN 

    RETURN QUERY
    SELECT 
        "asm"."ASMAY_Year" AS "BATCHES", 
        COUNT("alu"."ALMST_Id") AS "NOofstudents",
        "cla"."ASMCL_ClassName" AS "classname",
        "cla"."ASMCL_Id",
        "asm"."ASMAY_Id"  
    FROM "ALU"."Alumni_Master_Student" "alu" 
    INNER JOIN "Adm_School_M_Class" "cla" ON "alu"."ASMCL_Id_Left" = "cla"."ASMCL_Id" 
    INNER JOIN "Adm_School_M_Academic_Year" "asm" ON "alu"."ASMAY_Id_Left" = "asm"."ASMAY_Id" 
    WHERE "alu"."MI_Id" = "@MI_Id" 
        AND "asm"."ASMAY_Id"::TEXT = "@ASMAY_ID" 
    GROUP BY "asm"."ASMAY_Year", "cla"."ASMCL_ClassName", "cla"."ASMCL_Id", "asm"."ASMAY_Id" 
    ORDER BY "asm"."ASMAY_Year" DESC;

END;
$$;