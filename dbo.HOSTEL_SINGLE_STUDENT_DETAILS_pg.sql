CREATE OR REPLACE FUNCTION "dbo"."HOSTEL_SINGLE_STUDENT_DETAILS"(
    "@MI_Id" BIGINT,
    "@ASMAY_Id" BIGINT,
    "@AMST_Id" BIGINT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentName" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "ASMAY_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "AMS"."AMST_Id",
        COALESCE("AMST_FirstName", '') || ' ' || COALESCE("AMST_MiddleName", '') || ' ' || COALESCE("AMST_LastName", '') as "studentName",
        "ASMCL_ClassName",
        "AMST_RegistrationNo",
        "AMST_AdmNo",
        "AYS"."ASMAY_Id"
    FROM "Adm_M_Student" "AMS"
    INNER JOIN "Adm_School_Y_Student" "AYS" ON "AYS"."AMST_Id" = "AMS"."AMST_Id" 
        AND "AMST_ActiveFlag" = 1 
        AND "AMST_SOL" = 'S' 
        AND "AMAY_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Class" "MC" ON "AYS"."ASMCL_Id" = "MC"."ASMCL_Id"
    WHERE "AMS"."MI_Id" = "@MI_Id" 
        AND "AYS"."ASMAY_Id" = "@ASMAY_Id" 
        AND "AYS"."AMST_Id" = "@AMST_Id";

END;
$$;