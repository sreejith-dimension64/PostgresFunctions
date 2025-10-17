CREATE OR REPLACE FUNCTION "dbo"."ISM_SalesLeadDemoDates_InstWise"(
    "@MI_Id" TEXT,
    "@FromDate" VARCHAR(10),
    "@ToDate" VARCHAR(10),
    "@ISMSLE_Id" TEXT
)
RETURNS TABLE(
    "ISMSLE_Id" BIGINT,
    "ISMSLEDM_DemoType" VARCHAR,
    "ISMSLEDM_DemoDate" TIMESTAMP,
    "ISMSLEDM_ContactPerson" VARCHAR,
    "EmpName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
BEGIN

    v_sqldynamic := '
    SELECT SL."ISMSLE_Id",
           SLD."ISMSLEDM_DemoType",
           SLD."ISMSLEDM_DemoDate",
           SLD."ISMSLEDM_ContactPerson",
           (COALESCE(HR."HRME_EmployeeFirstName",'''') || '' '' || COALESCE(HR."HRME_EmployeeMiddleName",'''') || '' '' || COALESCE(HR."HRME_EmployeeLastName",'''')) AS "EmpName"
    FROM "ISM_Sales_Lead" SL
    INNER JOIN "ISM_Sales_Lead_Demo" SLD ON SL."ISMSLE_Id" = SLD."ISMSLE_Id"
    INNER JOIN "HR_Master_Employee" HR ON HR."HRME_Id" = SLD."HRME_Id"
    WHERE CAST(SLD."ISMSLEDM_DemoDate" AS DATE) BETWEEN ''' || "@FromDate" || ''' AND ''' || "@ToDate" || '''
    AND SL."MI_Id" IN (' || "@MI_Id" || ')
    AND SL."ISMSLE_Id" IN (' || "@ISMSLE_Id" || ')';

    RETURN QUERY EXECUTE v_sqldynamic;

END;
$$;