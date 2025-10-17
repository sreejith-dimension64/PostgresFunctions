CREATE OR REPLACE FUNCTION "dbo"."AcademicWiseFeesManagerDashboard" (
    "MI_Id" bigint,
    "ASMAY_Id" bigint
)
RETURNS TABLE (
    "ASMCL_ClassName" VARCHAR,
    "ASMCL_Id" bigint,
    "FSS_PaidAmount" NUMERIC,
    "balance" NUMERIC,
    "concession" NUMERIC,
    "FSS_CurrentYrCharges" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "Adm_School_M_Class"."ASMCL_ClassName" as "ASMCL_ClassName",
        "Adm_School_M_Class"."ASMCL_Id" as "ASMCL_Id",
        (SUM("fee_student_status"."FSS_PaidAmount") - SUM("fee_student_status"."FSS_FineAmount")) AS "FSS_PaidAmount",
        SUM("fee_student_status"."FSS_ToBePaid") AS "balance",
        SUM("fee_student_status"."FSS_ConcessionAmount") AS "concession",
        SUM("fee_student_status"."FSS_CurrentYrCharges") AS "FSS_CurrentYrCharges"
    FROM "dbo"."fee_student_status"
    INNER JOIN "dbo"."Adm_School_Y_Student" 
        ON "fee_student_status"."Amst_Id" = "Adm_School_Y_Student"."AMST_Id" 
        AND "Adm_School_Y_Student"."ASMAY_Id" = "fee_student_status"."ASMAY_Id"
    INNER JOIN "dbo"."Adm_M_Student" 
        ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" 
        ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    WHERE "fee_student_status"."MI_Id" = "MI_Id"
        AND "Adm_M_Student"."MI_Id" = "MI_Id"
        AND "Adm_School_M_Class"."MI_Id" = "MI_Id"
        AND "Adm_School_Y_Student"."ASMAY_Id" = "ASMAY_Id"
        AND "fee_student_status"."ASMAY_Id" = "ASMAY_Id"
    GROUP BY "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Class"."ASMCL_Id";
END;
$$;