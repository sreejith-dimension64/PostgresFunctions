CREATE OR REPLACE FUNCTION "dbo"."College_Overall_Daily_Attendance_Hod"(
    "Asmay_Id" TEXT,
    "FromDate" TEXT,
    "Mi_Id" TEXT,
    "AMB_Id" TEXT
)
RETURNS TABLE(
    "PRESENT" BIGINT,
    "ABSENT" BIGINT,
    "TOTAL" BIGINT,
    "AMB_BranchName" VARCHAR,
    "AMB_Order" INTEGER,
    "AMSE_SEMName" VARCHAR,
    "AMB_Id" BIGINT,
    "AMSE_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        SUM(A."PRESENT") AS "PRESENT",
        SUM(A."ABSENT") AS "ABSENT",
        SUM(A."TOTAL") AS "TOTAL",
        A."AMB_BranchName",
        A."AMB_Order",
        A."AMSE_SEMName",
        A."AMB_Id",
        A."AMSE_Id"
    FROM (
        -- present
        SELECT 
            COUNT(b."ACSAS_ClassAttended")::BIGINT AS "PRESENT",
            0::BIGINT AS "ABSENT",
            0::BIGINT AS "TOTAL",
            d."AMB_BranchName",
            d."AMB_Order",
            e."AMSE_SEMName",
            a."AMB_Id",
            a."AMSE_Id"
        FROM "clg"."Adm_College_Student_Attendance" a
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" c ON b."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON a."AMSE_Id" = e."AMSE_Id"
        WHERE a."ASMAY_Id" = "Asmay_Id"
            AND a."ACSA_ActiveFlag" = 1
            AND c."AMCST_SOL" = 'S'
            AND b."ACSAS_ClassAttended" = 1
            AND a."MI_Id" = "Mi_Id"
            AND TO_DATE("FromDate", 'DD/MM/YYYY') BETWEEN TO_DATE(a."ACSA_AttendanceDate"::TEXT, 'DD/MM/YYYY') 
                AND TO_DATE(a."ACSA_AttendanceDate"::TEXT, 'DD/MM/YYYY')
            AND d."AMB_Id"::TEXT = ANY(STRING_TO_ARRAY("AMB_Id", ','))
        GROUP BY d."AMB_BranchName", d."AMB_Order", e."AMSE_SEMName", a."AMB_Id", a."AMSE_Id"

        UNION

        -- absent
        SELECT 
            0::BIGINT AS "PRESENT",
            COUNT(b."ACSAS_ClassAttended")::BIGINT AS "ABSENT",
            0::BIGINT AS "TOTAL",
            d."AMB_BranchName",
            d."AMB_Order",
            e."AMSE_SEMName",
            a."AMB_Id",
            a."AMSE_Id"
        FROM "clg"."Adm_College_Student_Attendance" a
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" c ON b."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON a."AMSE_Id" = e."AMSE_Id"
        WHERE a."ASMAY_Id" = "Asmay_Id"
            AND a."ACSA_ActiveFlag" = 1
            AND c."AMCST_SOL" = 'S'
            AND b."ACSAS_ClassAttended" = 0
            AND TO_DATE("FromDate", 'DD/MM/YYYY') BETWEEN TO_DATE(a."ACSA_AttendanceDate"::TEXT, 'DD/MM/YYYY') 
                AND TO_DATE(a."ACSA_AttendanceDate"::TEXT, 'DD/MM/YYYY')
            AND a."MI_Id" = "Mi_Id"
            AND d."AMB_Id"::TEXT = ANY(STRING_TO_ARRAY("AMB_Id", ','))
        GROUP BY d."AMB_BranchName", d."AMB_Order", e."AMSE_SEMName", a."AMB_Id", a."AMSE_Id"

        UNION

        -- TOTAL
        SELECT 
            0::BIGINT AS "PRESENT",
            0::BIGINT AS "ABSENT",
            COUNT(b."ACSAS_ClassAttended")::BIGINT AS "TOTAL",
            d."AMB_BranchName",
            d."AMB_Order",
            e."AMSE_SEMName",
            a."AMB_Id",
            a."AMSE_Id"
        FROM "clg"."Adm_College_Student_Attendance" a
        INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
        INNER JOIN "clg"."Adm_Master_College_Student" c ON b."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON a."AMSE_Id" = e."AMSE_Id"
        WHERE a."ASMAY_Id" = "Asmay_Id"
            AND a."ACSA_ActiveFlag" = 1
            AND c."AMCST_SOL" = 'S'
            AND (b."ACSAS_ClassAttended" = 0 OR b."ACSAS_ClassAttended" = 1)
            AND a."MI_Id" = "Mi_Id"
            AND TO_DATE("FromDate", 'DD/MM/YYYY') BETWEEN TO_DATE(a."ACSA_AttendanceDate"::TEXT, 'DD/MM/YYYY') 
                AND TO_DATE(a."ACSA_AttendanceDate"::TEXT, 'DD/MM/YYYY')
            AND d."AMB_Id"::TEXT = ANY(STRING_TO_ARRAY("AMB_Id", ','))
        GROUP BY d."AMB_BranchName", d."AMB_Order", e."AMSE_SEMName", a."AMB_Id", a."AMSE_Id"
    ) A
    GROUP BY A."AMB_BranchName", A."AMB_Order", A."AMSE_SEMName", A."AMB_Id", A."AMSE_Id";
END;
$$;