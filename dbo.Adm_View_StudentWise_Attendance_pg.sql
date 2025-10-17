CREATE OR REPLACE FUNCTION "dbo"."Adm_View_StudentWise_Attendance"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMST_Id" TEXT
)
RETURNS TABLE(
    "ASMAY_Year" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "ASMAY_Order" INTEGER,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "AMST_Id" BIGINT,
    "WORKINGDAYS" BIGINT,
    "PRESENTDAYS" BIGINT,
    "PERCENTAGE" NUMERIC(18,2),
    "STATUS_FLAG" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@ASMAY_Year" TEXT;
BEGIN

    SELECT "ASMAY_Year" INTO "@ASMAY_Year" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "@MI_Id" AND "ASMAY_Id" = "@ASMAY_Id";

    RETURN QUERY
    SELECT 
        D."ASMAY_Year",
        D."ASMCL_ClassName",
        D."ASMC_SectionName",
        D."ASMAY_Order",
        D."ASMAY_Id",
        D."ASMCL_Id",
        D."ASMS_Id",
        D."AMST_Id",
        D."WORKINGDAYS",
        D."PRESENTDAYS",
        D."PERCENTAGE",
        CASE WHEN "@ASMAY_Year" = D."ASMAY_Year" THEN 'Current Year' ELSE '' END AS "STATUS_FLAG"
    FROM (
        SELECT 
            E."ASMAY_Year",
            F."ASMCL_ClassName",
            G."ASMC_SectionName",
            E."ASMAY_Order",
            A."ASMAY_Id",
            A."ASMCL_Id",
            A."ASMS_Id",
            B."AMST_Id",
            SUM(A."ASA_ClassHeld") AS "WORKINGDAYS",
            SUM(B."ASA_Class_Attended") AS "PRESENTDAYS",
            CAST((SUM(B."ASA_Class_Attended") * 100.0 / SUM(A."ASA_ClassHeld")) AS NUMERIC(18,2)) AS "PERCENTAGE"
        FROM "Adm_Student_Attendance" A 
        INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id" = B."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = A."ASMAY_Id" AND C."ASMAY_Id" = E."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = A."ASMCL_Id" AND C."ASMCL_Id" = F."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = A."ASMS_Id" AND C."ASMS_Id" = G."ASMS_Id"
        WHERE B."AMST_Id" = "@AMST_Id" 
            AND C."AMST_Id" = "@AMST_Id" 
            AND A."ASA_Activeflag" = 1 
            AND A."MI_Id" = "@MI_Id"
        GROUP BY E."ASMAY_Year", F."ASMCL_ClassName", G."ASMC_SectionName", E."ASMAY_Order", 
                 A."ASMAY_Id", A."ASMCL_Id", A."ASMS_Id", B."AMST_Id"
    ) AS D 
    ORDER BY D."ASMAY_Order" DESC;

END;
$$;