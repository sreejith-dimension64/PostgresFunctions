```sql
CREATE OR REPLACE FUNCTION "HRME_DETAILS"()
RETURNS TABLE(
    "HRME_EmployeeFirstName" VARCHAR,
    "HRME_EmployeeMiddleName" VARCHAR,
    "HRME_EmployeeLastName" VARCHAR,
    "HRME_Id" INTEGER,
    "FOBVIEM_BiometricId" VARCHAR,
    "ISMMCLT_ClientName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "b"."HRME_EmployeeFirstName",
        "b"."HRME_EmployeeMiddleName",
        "b"."HRME_EmployeeLastName",
        "b"."HRME_Id",
        "a"."FOBVIEM_BiometricId",
        "d"."ISMMCLT_ClientName"
    FROM "FO"."FO_Biometric_VAPS_IEMapping" AS "a"
    INNER JOIN "HR_Master_Employee" AS "b" ON "a"."FOBVIEM_HRMEId" = "b"."HRME_Id"
    INNER JOIN "ISM_Master_Client" AS "d" ON "a"."FOBVIEM_Insert_MI_Id" = "d"."IVRM_MI_Id";
END;
$$;
```