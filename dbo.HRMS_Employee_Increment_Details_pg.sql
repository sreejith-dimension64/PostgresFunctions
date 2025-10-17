CREATE OR REPLACE FUNCTION "dbo"."HRMS_Employee_Increment_Details"(
    "@MI_Id" TEXT
)
RETURNS TABLE(
    "hrmE_EmployeeFirstName" TEXT,
    "hrmE_EmployeeCode" VARCHAR,
    "hrmE_DOC" TIMESTAMP,
    "hrmE_DOJ" TIMESTAMP,
    "nextincrement" TIMESTAMP,
    "lastincrement" TIMESTAMP,
    "DateDiff" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (COALESCE("b"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("b"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("b"."HRME_EmployeeLastName", ''))::TEXT AS "hrmE_EmployeeFirstName",
        "b"."HRME_EmployeeCode" AS "hrmE_EmployeeCode",
        "b"."HRME_DOC" AS "hrmE_DOC",
        "b"."HRME_DOJ" AS "hrmE_DOJ",
        "a"."HREIC_IncrementDueDate" AS "nextincrement",
        "a"."HREIC_IncrementDate" AS "lastincrement",
        DATE_PART('day', "a"."HREIC_IncrementDueDate" - CURRENT_TIMESTAMP)::INTEGER AS "DateDiff"
    FROM "HR_Master_Employee" "b"
    LEFT JOIN "HR_Employee_Increment" "a" ON "a"."HRME_Id" = "b"."HRME_Id"
    WHERE DATE_PART('day', "a"."HREIC_IncrementDueDate" - CURRENT_TIMESTAMP) <= 100
        AND "b"."HRME_doc" IS NOT NULL
        AND "a"."MI_Id" = "@MI_Id"
        AND "b"."MI_Id" = "@MI_Id"
        AND "b"."HRME_LeftFlag" = 0
        AND "b"."HRME_ActiveFlag" = 1;
END;
$$;