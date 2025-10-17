CREATE OR REPLACE FUNCTION "dbo"."College_OverallDailyAttendance_AbsentStudents"(
    "asmay_id" BIGINT,
    "fromdate" DATE,
    "Branchname" TEXT,
    "semname" TEXT,
    "miid" BIGINT
)
RETURNS TABLE(
    "PRESENT" BIGINT,
    "ABSENT" BIGINT,
    "TOTAL" BIGINT,
    "AMB_BranchName" VARCHAR,
    "AMB_Order" INTEGER,
    "AMSE_SEMName" VARCHAR,
    "StudentId" BIGINT,
    "Name" TEXT,
    "EmployeeName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        SUM("A"."PRESENT")::BIGINT AS "PRESENT", 
        SUM("A"."ABSENT")::BIGINT AS "ABSENT", 
        SUM("A"."TOTAL")::BIGINT AS "TOTAL",
        "A"."AMB_BranchName",
        "A"."AMB_Order",
        "A"."AMSE_SEMName",
        "A"."StudentId",
        "A"."Name",
        "A"."EmployeeName"
    FROM
    (
        SELECT 
            COUNT("b"."ACSAS_ClassAttended") AS "PRESENT", 
            0::BIGINT AS "ABSENT", 
            0::BIGINT AS "TOTAL",
            "d"."AMB_BranchName",
            "d"."AMB_Order",
            "e"."AMSE_SEMName",
            "c"."AMCST_Id" AS "StudentId",
            (COALESCE("c"."AMCST_FirstName", '') || ' ' || COALESCE("c"."AMCST_MiddleName", '') || ' ' || COALESCE("c"."AMCST_LastName", '')) AS "Name",
            (COALESCE("f"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("f"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("f"."HRME_EmployeeLastName", '')) AS "EmployeeName"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "c" ON "c"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "d" ON "d"."AMB_Id" = "a"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "e" ON "a"."AMSE_Id" = "e"."AMSE_Id"
        INNER JOIN "HR_Master_Employee" "f" ON "a"."HRME_Id" = "f"."HRME_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "PW" ON "PW"."ACSA_Id" = "a"."ACSA_Id"
        INNER JOIN "TT_Master_Period" "P" ON "P"."TTMP_Id" = "PW"."TTMP_Id"
        WHERE "a"."ASMAY_Id" = "asmay_id" 
            AND "c"."MI_Id" = "miid" 
            AND "P"."TTMP_PeriodName" = 1
            AND "c"."AMCST_SOL" = 'S' 
            AND "d"."AMB_Id" = "Branchname"::BIGINT
            AND "e"."AMSE_Id" = "semname"::BIGINT
            AND "fromdate" BETWEEN "a"."ACSA_AttendanceDate"::DATE AND "a"."ACSA_AttendanceDate"::DATE
            AND "b"."ACSAS_ClassAttended" = 1 
            AND "a"."ACSA_ActiveFlag" = 1
        GROUP BY "d"."AMB_BranchName", "d"."AMB_Order", "e"."AMSE_SEMName", "c"."AMCST_Id",
            "c"."AMCST_FirstName", "c"."AMCST_MiddleName", "c"."AMCST_LastName", 
            "f"."HRME_EmployeeFirstName", "f"."HRME_EmployeeMiddleName", "f"."HRME_EmployeeLastName"

        UNION

        SELECT 
            0::BIGINT AS "PRESENT", 
            COUNT("b"."ACSAS_ClassAttended") AS "ABSENT", 
            0::BIGINT AS "TOTAL",
            "d"."AMB_BranchName",
            "d"."AMB_Order",
            "e"."AMSE_SEMName",
            "c"."AMCST_Id" AS "StudentId",
            (COALESCE("c"."AMCST_FirstName", '') || ' ' || COALESCE("c"."AMCST_MiddleName", '') || ' ' || COALESCE("c"."AMCST_LastName", '')) AS "Name",
            (COALESCE("f"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("f"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("f"."HRME_EmployeeLastName", '')) AS "EmployeeName"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "c" ON "c"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "d" ON "d"."AMB_Id" = "a"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "e" ON "a"."AMSE_Id" = "e"."AMSE_Id"
        INNER JOIN "HR_Master_Employee" "f" ON "a"."HRME_Id" = "f"."HRME_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "PW" ON "PW"."ACSA_Id" = "a"."ACSA_Id"
        INNER JOIN "TT_Master_Period" "P" ON "P"."TTMP_Id" = "PW"."TTMP_Id"
        WHERE "a"."ASMAY_Id" = "asmay_id" 
            AND "c"."MI_Id" = "miid" 
            AND "P"."TTMP_PeriodName" = 1
            AND "c"."AMCST_SOL" = 'S' 
            AND "d"."AMB_Id" = "Branchname"::BIGINT
            AND "e"."AMSE_Id" = "semname"::BIGINT
            AND "fromdate" BETWEEN "a"."ACSA_AttendanceDate"::DATE AND "a"."ACSA_AttendanceDate"::DATE
            AND "b"."ACSAS_ClassAttended" = 0 
            AND "a"."ACSA_ActiveFlag" = 1
        GROUP BY "d"."AMB_BranchName", "d"."AMB_Order", "e"."AMSE_SEMName", "c"."AMCST_Id",
            "c"."AMCST_FirstName", "c"."AMCST_MiddleName", "c"."AMCST_LastName", 
            "f"."HRME_EmployeeFirstName", "f"."HRME_EmployeeMiddleName", "f"."HRME_EmployeeLastName"

        UNION

        SELECT 
            0::BIGINT AS "PRESENT", 
            0::BIGINT AS "ABSENT", 
            COUNT("b"."ACSAS_ClassAttended") AS "TOTAL",
            "d"."AMB_BranchName",
            "d"."AMB_Order",
            "e"."AMSE_SEMName",
            "c"."AMCST_Id" AS "StudentId",
            (COALESCE("c"."AMCST_FirstName", '') || ' ' || COALESCE("c"."AMCST_MiddleName", '') || ' ' || COALESCE("c"."AMCST_LastName", '')) AS "Name",
            (COALESCE("f"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("f"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("f"."HRME_EmployeeLastName", '')) AS "EmployeeName"
        FROM "clg"."Adm_College_Student_Attendance" "a"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" "b" ON "a"."ACSA_Id" = "b"."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" "c" ON "c"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "d" ON "d"."AMB_Id" = "a"."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" "e" ON "a"."AMSE_Id" = "e"."AMSE_Id"
        INNER JOIN "HR_Master_Employee" "f" ON "a"."HRME_Id" = "f"."HRME_Id"
        INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" "PW" ON "PW"."ACSA_Id" = "a"."ACSA_Id"
        INNER JOIN "TT_Master_Period" "P" ON "P"."TTMP_Id" = "PW"."TTMP_Id"
        WHERE "a"."ASMAY_Id" = "asmay_id" 
            AND "c"."MI_Id" = "miid" 
            AND "P"."TTMP_PeriodName" = 1
            AND "c"."AMCST_SOL" = 'S' 
            AND "d"."AMB_Id" = "Branchname"::BIGINT
            AND "e"."AMSE_Id" = "semname"::BIGINT
            AND "fromdate" BETWEEN "a"."ACSA_AttendanceDate"::DATE AND "a"."ACSA_AttendanceDate"::DATE
            AND ("b"."ACSAS_ClassAttended" = 0 OR "b"."ACSAS_ClassAttended" = 1)
            AND "a"."ACSA_ActiveFlag" = 1
        GROUP BY "d"."AMB_BranchName", "d"."AMB_Order", "e"."AMSE_SEMName", "c"."AMCST_Id",
            "c"."AMCST_FirstName", "c"."AMCST_MiddleName", "c"."AMCST_LastName", 
            "f"."HRME_EmployeeFirstName", "f"."HRME_EmployeeMiddleName", "f"."HRME_EmployeeLastName"
    ) "A"
    GROUP BY "A"."AMB_BranchName", "A"."AMB_Order", "A"."AMSE_SEMName", "A"."StudentId", "A"."Name", "A"."EmployeeName";
END;
$$;