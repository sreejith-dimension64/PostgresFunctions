CREATE OR REPLACE FUNCTION "dbo"."AlumniDashboard2"(
    "MI_Id" TEXT
)
RETURNS TABLE(
    "Name" TEXT,
    "ASMAY_Year" VARCHAR,
    "ALMST_AdmNo" VARCHAR,
    "classname" VARCHAR,
    "ALMST_MobileNo" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ("alu"."ALMST_FirstName" || ' ' || "alu"."ALMST_MiddleName" || ' ' || "alu"."ALMST_LastName") AS "Name",
        "asm"."ASMAY_Year",
        "alu"."ALMST_AdmNo",
        "cla"."ASMCL_ClassName" AS "classname",
        "alu"."ALMST_MobileNo"
    FROM "ALU"."Alumni_Master_Student" "alu"
    INNER JOIN "Adm_School_M_Class" "cla" ON "alu"."ASMCL_Id_Left" = "cla"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "asm" ON "alu"."ASMAY_Id_Left" = "asm"."ASMAY_Id"
    WHERE "alu"."MI_Id" = "MI_Id"
    GROUP BY "asm"."ASMAY_Year", "cla"."ASMCL_ClassName", "alu"."ALMST_FirstName", 
             "alu"."ALMST_MiddleName", "alu"."ALMST_LastName", "alu"."ALMST_AdmNo", 
             "alu"."ALMST_MobileNo"
    ORDER BY "asm"."ASMAY_Year" DESC;
END;
$$;