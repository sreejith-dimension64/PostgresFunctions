CREATE OR REPLACE FUNCTION "dbo"."ALUMNI_BirthdayList_Day" (
    "MI_Id" bigint
)
RETURNS TABLE (
    "studentName" TEXT,
    "ASMAY_Year" VARCHAR,
    "ALMST_AdmNo" VARCHAR,
    "asmcL_ClassName" VARCHAR,
    "amsT_MobileNo" VARCHAR,
    "amsT_emailId" VARCHAR,
    "amst_dob" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ("alu"."ALMST_FirstName" || ' ' || "alu"."ALMST_MiddleName" || ' ' || "alu"."ALMST_LastName") as "studentName",
        "asm"."ASMAY_Year",
        "alu"."ALMST_AdmNo",
        "cla"."asmcL_ClassName",
        "alu"."almsT_MobileNo" as "amsT_MobileNo",
        "alu"."almsT_emailId" as "amsT_emailId",
        "alu"."almsT_DOB" as "amst_dob"
    FROM "ALU"."Alumni_Master_Student" "alu"
    INNER JOIN "Adm_School_M_Class" "cla" ON "alu"."ASMCL_Id_Left" = "cla"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "asm" ON "alu"."ASMAY_Id_Left" = "asm"."ASMAY_Id"
    WHERE "alu"."MI_Id" = "MI_Id"
        AND (EXTRACT(DAY FROM "alu"."ALMST_DOB") = EXTRACT(DAY FROM CURRENT_TIMESTAMP)
        AND EXTRACT(MONTH FROM "alu"."ALMST_DOB") = EXTRACT(MONTH FROM CURRENT_TIMESTAMP))
    GROUP BY "asm"."ASMAY_Year", "cla"."ASMCL_ClassName", "alu"."ALMST_FirstName", 
             "alu"."ALMST_MiddleName", "alu"."ALMST_LastName", "alu"."ALMST_AdmNo", 
             "alu"."ALMST_MobileNo", "alu"."ALMST_emailId", "alu"."ALMST_DOB"
    ORDER BY "asm"."ASMAY_Year" DESC;
END;
$$;