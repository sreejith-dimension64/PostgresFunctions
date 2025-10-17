CREATE OR REPLACE FUNCTION "dbo"."AlumniDashboardClasswise"(
    "@MI_Id" VARCHAR,
    "@ASMAY_ID" VARCHAR,
    "@ASMCL_Id" VARCHAR
)
RETURNS TABLE(
    "studentname" TEXT,
    "ASMAY_Year" VARCHAR,
    "ALMST_AdmNo" VARCHAR,
    "classname" VARCHAR,
    "ALMST_MobileNo" VARCHAR,
    "ALMST_emailId" VARCHAR,
    "ALMST_DOB" DATE
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ("alu"."ALMST_FirstName" || ' ' || "alu"."ALMST_MiddleName" || ' ' || "alu"."ALMST_LastName")::TEXT AS "studentname",
        "asm"."ASMAY_Year",
        "alu"."ALMST_AdmNo",
        "cla"."ASMCL_ClassName" AS "classname",
        "alu"."ALMST_MobileNo",
        "alu"."ALMST_emailId",
        "alu"."ALMST_DOB"
    FROM "ALU"."Alumni_Master_Student" "alu"
    INNER JOIN "Adm_School_M_Class" "cla" ON "alu"."ASMCL_Id_Left" = "cla"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "asm" ON "alu"."ASMAY_Id_Left" = "asm"."ASMAY_Id"
    WHERE "alu"."MI_Id" = "@MI_Id" 
        AND "asm"."ASMAY_Id" = "@ASMAY_ID" 
        AND "cla"."ASMCL_Id" = "@ASMCL_Id";
END;
$$;