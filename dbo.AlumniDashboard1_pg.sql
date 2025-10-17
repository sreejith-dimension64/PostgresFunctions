CREATE OR REPLACE FUNCTION "dbo"."AlumniDashboard1"(
    p_MI_Id TEXT
)
RETURNS TABLE(
    "BATCHES" VARCHAR,
    "NOofstudents" BIGINT,
    "ASMAY_From_Date" TIMESTAMP,
    "ASMAY_To_Date" TIMESTAMP,
    "ASMAY_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "asm"."ASMAY_Year" AS "BATCHES",
        COUNT("alu"."ALMST_Id") AS "NOofstudents",
        "asm"."ASMAY_From_Date",
        "asm"."ASMAY_To_Date",
        "asm"."ASMAY_Id"
    FROM "ALU"."Alumni_Master_Student" "alu"
    INNER JOIN "Adm_School_M_Class" "cla" ON "alu"."ASMCL_Id_Left" = "cla"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "asm" ON "alu"."ASMAY_Id_Left" = "asm"."ASMAY_Id"
    WHERE "alu"."MI_Id" = p_MI_Id
    GROUP BY "asm"."ASMAY_Year", "asm"."ASMAY_From_Date", "asm"."ASMAY_To_Date", "asm"."ASMAY_Id"
    ORDER BY "asm"."ASMAY_Year" DESC;
END;
$$;