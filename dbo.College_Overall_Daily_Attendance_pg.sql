CREATE OR REPLACE FUNCTION "dbo"."College_Overall_Daily_Attendance"(
    "Asmay_Id" TEXT,
    "FromDate" TEXT,
    "Mi_Id" TEXT
)
RETURNS TABLE(
    "PRESENT" BIGINT,
    "ABSENT" BIGINT,
    "TOTAL" BIGINT,
    "AMB_BranchName" VARCHAR,
    "AMB_Order" INTEGER,
    "AMSE_SEMName" VARCHAR,
    "AMB_Id" INTEGER,
    "AMSE_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        SUM("A"."PRESENT") AS "PRESENT",
        SUM("A"."ABSENT") AS "ABSENT",
        SUM("A"."TOTAL") AS "TOTAL",
        "A"."AMB_BranchName",
        "A"."AMB_Order",
        "A"."AMSE_SEMName",
        "A"."AMB_Id",
        "A"."AMSE_Id"
    FROM (
        SELECT 
            COUNT("b"."ACSAS_ClassAttended") AS "PRESENT",
            0 AS "ABSENT",
            0 AS "TOTAL",
            "d"."AMB_BranchName",
            "d"."AMB_Order",
            "e"."AMSE_SEMName",
            "a"."AMB_Id",
            "a"."AMSE_Id"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "c" ON "b"."AMCST_Id" = "c"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "d" ON "d"."AMB_Id" = "a"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "e" ON "a"."AMSE_Id" = "e"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "f" ON "f"."ACSA_Id" = "a"."ACSA_Id"
        INNER JOIN "TT_Master_Period" "g" ON "g"."TTMP_Id" = "f"."TTMP_Id"
        WHERE ("a"."ASMAY_Id" = "Asmay_Id") 
            AND "a"."ACSA_ActiveFlag" = 1 
            AND ("c"."AMCST_SOL" = 'S') 
            AND "b"."ACSAS_ClassAttended" = 1 
            AND "a"."MI_Id" = "Mi_Id"
            AND (CAST("FromDate" AS DATE) BETWEEN CAST("a"."ACSA_AttendanceDate" AS DATE) AND CAST("a"."ACSA_AttendanceDate" AS DATE))
            AND "g"."TTMP_PeriodName" = '1'
        GROUP BY "d"."AMB_BranchName", "d"."AMB_Order", "e"."AMSE_SEMName", "a"."AMB_Id", "a"."AMSE_Id"

        UNION

        SELECT 
            0 AS "PRESENT",
            COUNT("b"."ACSAS_ClassAttended") AS "ABSENT",
            0 AS "TOTAL",
            "d"."AMB_BranchName",
            "d"."AMB_Order",
            "e"."AMSE_SEMName",
            "a"."AMB_Id",
            "a"."AMSE_Id"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "c" ON "b"."AMCST_Id" = "c"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "d" ON "d"."AMB_Id" = "a"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "e" ON "a"."AMSE_Id" = "e"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "f" ON "f"."ACSA_Id" = "a"."ACSA_Id"
        INNER JOIN "TT_Master_Period" "g" ON "g"."TTMP_Id" = "f"."TTMP_Id"
        WHERE ("a"."ASMAY_Id" = "Asmay_Id") 
            AND "a"."ACSA_ActiveFlag" = 1 
            AND ("c"."AMCST_SOL" = 'S') 
            AND "g"."TTMP_PeriodName" = '1'
            AND "b"."ACSAS_ClassAttended" = 0
            AND (CAST("FromDate" AS DATE) BETWEEN CAST("a"."ACSA_AttendanceDate" AS DATE) AND CAST("a"."ACSA_AttendanceDate" AS DATE))
            AND "a"."MI_Id" = "Mi_Id"
        GROUP BY "d"."AMB_BranchName", "d"."AMB_Order", "e"."AMSE_SEMName", "a"."AMB_Id", "a"."AMSE_Id"

        UNION

        SELECT 
            0 AS "PRESENT",
            0 AS "ABSENT",
            COUNT("b"."ACSAS_ClassAttended") AS "TOTAL",
            "d"."AMB_BranchName",
            "d"."AMB_Order",
            "e"."AMSE_SEMName",
            "a"."AMB_Id",
            "a"."AMSE_Id"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "c" ON "b"."AMCST_Id" = "c"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "d" ON "d"."AMB_Id" = "a"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "e" ON "a"."AMSE_Id" = "e"."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "f" ON "f"."ACSA_Id" = "a"."ACSA_Id"
        INNER JOIN "TT_Master_Period" "g" ON "g"."TTMP_Id" = "f"."TTMP_Id"
        WHERE ("a"."ASMAY_Id" = "Asmay_Id") 
            AND "a"."ACSA_ActiveFlag" = 1 
            AND ("c"."AMCST_SOL" = 'S')
            AND (("b"."ACSAS_ClassAttended" = 0) OR ("b"."ACSAS_ClassAttended" = 1))
            AND "a"."MI_Id" = "Mi_Id"
            AND "g"."TTMP_PeriodName" = '1'
            AND (CAST("FromDate" AS DATE) BETWEEN CAST("a"."ACSA_AttendanceDate" AS DATE) AND CAST("a"."ACSA_AttendanceDate" AS DATE))
        GROUP BY "d"."AMB_BranchName", "d"."AMB_Order", "e"."AMSE_SEMName", "a"."AMB_Id", "a"."AMSE_Id"
    ) "A"
    GROUP BY "A"."AMB_BranchName", "A"."AMB_Order", "A"."AMSE_SEMName", "A"."AMB_Id", "A"."AMSE_Id";
END;
$$;