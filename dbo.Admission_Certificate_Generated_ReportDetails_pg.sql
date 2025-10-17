CREATE OR REPLACE FUNCTION "dbo"."Admission_Certificate_Generated_ReportDetails"(
    "@MI_Id" VARCHAR,
    "@FromDate" VARCHAR(10),
    "@Toate" VARCHAR(10),
    "@Report_Type" VARCHAR,
    "@Report_Name" VARCHAR
)
RETURNS TABLE (
    "ReportName" VARCHAR,
    "Count" BIGINT,
    "StudnetName" TEXT,
    "Admno" VARCHAR,
    "Date" TEXT,
    "ASC_ReportType" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "@Report_Type" = 'Count' THEN
        RETURN QUERY
        SELECT 
            "ASC_ReportType" AS "ReportName",
            COUNT(*)::BIGINT AS "Count",
            NULL::TEXT AS "StudnetName",
            NULL::VARCHAR AS "Admno",
            NULL::TEXT AS "Date",
            NULL::VARCHAR AS "ASC_ReportType"
        FROM "Adm_Study_Certificate_Report"
        WHERE "MI_Id" = "@MI_Id"
        AND (CAST("ASC_Date" AS DATE) >= CAST("@FromDate" AS DATE) 
             AND CAST("ASC_Date" AS DATE) <= CAST("@Toate" AS DATE))
        GROUP BY "ASC_ReportType";
    ELSIF "@Report_Type" = 'Detailed' THEN
        RETURN QUERY
        SELECT 
            NULL::VARCHAR AS "ReportName",
            NULL::BIGINT AS "Count",
            (CASE WHEN "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||
             CASE WHEN "AMST_MiddleName" = '' OR "AMST_MiddleName" IS NULL THEN '' ELSE ' ' || "AMST_MiddleName" END ||
             CASE WHEN "AMST_LastName" = '' OR "AMST_LastName" IS NULL THEN '' ELSE ' ' || "AMST_LastName" END) AS "StudnetName",
            "AMST_AdmNo" AS "Admno",
            (TO_CHAR("ASC_Date", 'DD/MM/YYYY') || ' ' || TO_CHAR("ASC_Date", 'HH12:MI AM')) AS "Date",
            "ASC_ReportType"
        FROM "Adm_Study_Certificate_Report" "A"
        INNER JOIN "Adm_M_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id"
        WHERE "A"."MI_Id" = "@MI_Id"
        AND (CAST("ASC_Date" AS DATE) >= CAST("@FromDate" AS DATE) 
             AND CAST("ASC_Date" AS DATE) <= CAST("@Toate" AS DATE))
        AND "ASC_ReportType" = "@Report_Name";
    END IF;
END;
$$;