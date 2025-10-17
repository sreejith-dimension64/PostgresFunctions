CREATE OR REPLACE FUNCTION "dbo"."Chairman_Exm_Classwise_passfail_count"(
    "@MI_Id" integer,
    "@ASMAY_Id" integer,
    "@ASMCL_Id" integer,
    "@EME_Id" integer
)
RETURNS TABLE(
    "Total_Count" bigint,
    "Pass_Count" bigint,
    "Fail_Count" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH "CTE" AS (
        SELECT DISTINCT COUNT("amst_id") AS "Total_Count" 
        FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "mi_id" = "@MI_Id" 
            AND "ASMAY_Id" = "@ASMAY_Id" 
            AND "EME_Id" = "@EME_Id" 
            AND "ASMCL_Id" = "@ASMCL_Id"
    ),
    "CTE1" AS (
        SELECT DISTINCT COUNT("amst_id") AS "Pass_Count" 
        FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "mi_id" = "@MI_Id" 
            AND "ASMAY_Id" = "@ASMAY_Id" 
            AND "ASMCL_Id" = "@ASMCL_Id" 
            AND "ESTMP_Result" = 'Pass' 
            AND "EME_Id" = "@EME_Id"
    ),
    "CTE2" AS (
        SELECT DISTINCT COUNT("amst_id") AS "Fail_Count" 
        FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "mi_id" = "@MI_Id" 
            AND "ASMAY_Id" = "@ASMAY_Id" 
            AND "ASMCL_Id" = "@ASMCL_Id" 
            AND "ESTMP_Result" = 'Fail' 
            AND "EME_Id" = "@EME_Id"
    )
    SELECT "CTE"."Total_Count", "CTE1"."Pass_Count", "CTE2"."Fail_Count" 
    FROM "CTE", "CTE1", "CTE2";
END;
$$;