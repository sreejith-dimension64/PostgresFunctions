CREATE OR REPLACE FUNCTION "dbo"."Exam_Month_End_Report_Proc" (
    "p_mi_id" bigint, 
    "p_asmay_id" bigint, 
    "p_eme_id" bigint
)
RETURNS TABLE (
    "class" VARCHAR,
    "TotalStrength" BIGINT,
    "ExamAttended" BIGINT,
    "Pass" BIGINT,
    "Fail" BIGINT,
    "ExamNotAttended" BIGINT,
    "ASMCL_Order" INTEGER,
    "TotalPercentage" NUMERIC(18,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "mailf"."ASMCL_ClassName" AS "class", 
        SUM("mailf"."Totalcount") AS "TotalStrength",
        SUM("mailf"."TotalExamAttendedcount") AS "ExamAttended", 
        SUM("mailf"."Pass") AS "Pass",
        SUM("mailf"."Fail") AS "Fail", 
        SUM("mailf"."Absent") AS "ExamNotAttended",
        "mailf"."ASMCL_Order",
        CAST(
            CASE 
                WHEN SUM("mailf"."Pass") > 0 
                THEN (SUM("mailf"."Pass") * 100.0 / SUM("mailf"."TotalExamAttendedcount")) 
                ELSE 0 
            END AS NUMERIC(18,2)
        ) AS "TotalPercentage"
    FROM (
        SELECT 
            "b"."ASMCL_ClassName", 
            "b"."ASMCL_Order", 
            COUNT(*) AS "Totalcount", 
            0 AS "TotalExamAttendedcount", 
            0 AS "Pass", 
            0 AS "Fail",
            0 AS "Absent"
        FROM "Adm_School_Y_Student" "a"
        INNER JOIN "Adm_School_M_Class" "b" ON "a"."ASMCL_Id" = "b"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "c" ON "c"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "Adm_M_Student" "d" ON "d"."AMST_Id" = "a"."AMST_Id"
        WHERE "d"."mi_id" = "p_mi_id" 
            AND "a"."ASMAY_Id" = "p_asmay_id" 
            AND "a"."AMAY_ActiveFlag" = 1
        GROUP BY "b"."ASMCL_ClassName", "b"."ASMCL_Order"

        UNION ALL

        SELECT 
            "b"."ASMCL_ClassName", 
            "b"."ASMCL_Order", 
            0 AS "Totalcount", 
            COUNT(*) AS "TotalExamAttendedcount", 
            0 AS "Pass", 
            0 AS "Fail",
            0 AS "Absent"
        FROM "exm"."Exm_Student_Marks_Process" "a"
        INNER JOIN "Adm_School_M_Class" "b" ON "a"."ASMCL_Id" = "b"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "c" ON "c"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "exm"."Exm_Master_Exam" "d" ON "d"."EME_Id" = "a"."EME_Id"
        WHERE "a"."mi_id" = "p_mi_id" 
            AND "a"."ASMAY_Id" = "p_asmay_id" 
            AND "a"."EME_Id" = "p_eme_id"
        GROUP BY "b"."ASMCL_ClassName", "b"."ASMCL_Order"

        UNION ALL

        SELECT 
            "b"."ASMCL_ClassName", 
            "b"."ASMCL_Order", 
            0 AS "Totalcount", 
            0 AS "TotalExamAttendedcount", 
            COUNT("a"."ESTMP_Result") AS "Pass", 
            0 AS "Fail",
            0 AS "Absent"
        FROM "exm"."Exm_Student_Marks_Process" "a"
        INNER JOIN "Adm_School_M_Class" "b" ON "a"."ASMCL_Id" = "b"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "c" ON "c"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "exm"."Exm_Master_Exam" "d" ON "d"."EME_Id" = "a"."EME_Id"
        WHERE "a"."mi_id" = "p_mi_id" 
            AND "a"."ASMAY_Id" = "p_asmay_id" 
            AND "a"."EME_Id" = "p_eme_id" 
            AND "a"."ESTMP_Result" = 'PASS'
        GROUP BY "b"."ASMCL_ClassName", "b"."ASMCL_Order"

        UNION ALL

        SELECT 
            "b"."ASMCL_ClassName", 
            "b"."ASMCL_Order", 
            0 AS "Totalcount", 
            0 AS "TotalExamAttendedcount", 
            0 AS "Pass", 
            COUNT("a"."ESTMP_Result") AS "Fail",
            0 AS "Absent"
        FROM "exm"."Exm_Student_Marks_Process" "a"
        INNER JOIN "Adm_School_M_Class" "b" ON "b"."ASMCL_Id" = "a"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "c" ON "c"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "exm"."Exm_Master_Exam" "d" ON "d"."EME_Id" = "a"."EME_Id"
        WHERE "a"."mi_id" = "p_mi_id" 
            AND "a"."ASMAY_Id" = "p_asmay_id" 
            AND "a"."EME_Id" = "p_eme_id" 
            AND "a"."ESTMP_Result" = 'Fail'
        GROUP BY "b"."ASMCL_ClassName", "b"."ASMCL_Order"

        UNION ALL

        SELECT 
            "b"."ASMCL_ClassName", 
            "b"."ASMCL_Order", 
            0 AS "Totalcount", 
            0 AS "TotalExamAttendedcount", 
            0 AS "Pass", 
            COUNT("a"."ESTMP_Result") AS "Fail",
            COUNT("a"."ESTMP_Result") AS "Absent"
        FROM "exm"."Exm_Student_Marks_Process" "a"
        INNER JOIN "Adm_School_M_Class" "b" ON "b"."ASMCL_Id" = "a"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "c" ON "c"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "exm"."Exm_Master_Exam" "d" ON "d"."EME_Id" = "a"."EME_Id"
        WHERE "a"."mi_id" = "p_mi_id" 
            AND "a"."ASMAY_Id" = "p_asmay_id" 
            AND "a"."EME_Id" = "p_eme_id" 
            AND "a"."ESTMP_Result" = 'AB'
        GROUP BY "b"."ASMCL_ClassName", "b"."ASMCL_Order"
    ) "mailf"
    GROUP BY "mailf"."ASMCL_ClassName", "mailf"."ASMCL_Order"
    ORDER BY "mailf"."ASMCL_Order";

    RETURN;
END;
$$;