CREATE OR REPLACE FUNCTION "dbo"."Exam_Month_End_Report" (
    "p_mi_id" bigint, 
    "p_asmay_id" bigint, 
    "p_eme_id" bigint
)
RETURNS TABLE (
    "class" character varying,
    "Pass" bigint,
    "Fail" bigint,
    "ASMCL_Order" integer
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        "mailf"."ASMCL_ClassName" AS "class", 
        SUM("mailf"."Pass") AS "Pass",      
        SUM("mailf"."Fail") AS "Fail",
        "mailf"."ASMCL_Order"
    FROM (
        SELECT 
            "b"."ASMCL_ClassName", 
            "b"."ASMCL_Order", 
            COUNT("a"."ESTMP_Result") AS "Pass", 
            0::bigint AS "Fail" 
        FROM "exm"."Exm_Student_Marks_Process" "a" 
        INNER JOIN "Adm_School_M_Class" "b" ON "a"."ASMCL_Id" = "b"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "c" ON "c"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "exm"."Exm_Master_Exam" "d" ON "d"."EME_Id" = "a"."EME_Id"
        WHERE "a"."mi_id" = "p_mi_id" 
            AND "a"."ASMAY_Id" = "p_asmay_id" 
            AND "a"."EME_Id" = "p_eme_id" 
            AND "a"."ESTMP_Result" = 'PASS'
        GROUP BY "b"."ASMCL_ClassName", "b"."ASMCL_Order"
        LIMIT 100

        UNION ALL

        SELECT 
            "b"."ASMCL_ClassName", 
            "b"."ASMCL_Order", 
            0::bigint AS "Pass",
            COUNT("a"."ESTMP_Result") AS "Fail"  
        FROM "exm"."Exm_Student_Marks_Process" "a"
        INNER JOIN "Adm_School_M_Class" "b" ON "b"."ASMCL_Id" = "a"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "c" ON "c"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "exm"."Exm_Master_Exam" "d" ON "d"."EME_Id" = "a"."EME_Id"
        WHERE "a"."mi_id" = "p_mi_id" 
            AND "a"."ASMAY_Id" = "p_asmay_id" 
            AND "a"."EME_Id" = "p_eme_id" 
            AND "a"."ESTMP_Result" = 'Fail'
        GROUP BY "b"."ASMCL_ClassName", "b"."ASMCL_Order"
        LIMIT 100
    ) "mailf" 
    GROUP BY "mailf"."ASMCL_ClassName", "mailf"."ASMCL_Order"
    ORDER BY "mailf"."ASMCL_Order";

END;
$$;