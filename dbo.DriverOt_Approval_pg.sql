CREATE OR REPLACE FUNCTION "dbo"."DriverOt_Approval"()
RETURNS TABLE(
    "VMSDT_ID" INTEGER,
    "HRME_Id" INTEGER,
    "HRME_EmployeeFirstName" TEXT,
    "VMSDT_Punchdate" TIMESTAMP,
    "VMSDT_TotalOt" NUMERIC,
    "VMSDT_PunchIn" TIMESTAMP,
    "VMSDT_PunchOut" TIMESTAMP,
    "VMSDT_Remarks" TEXT,
    "withpreviousdayflag" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        b."VMSDT_ID",
        b."HRME_Id", 
        (COALESCE(a."HRME_EmployeeFirstName", '') || ' ' || COALESCE(a."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(a."HRME_EmployeeLastName", '')) AS "HRME_EmployeeFirstName",
        b."VMSDT_Punchdate",
        b."VMSDT_TotalOt",
        b."VMSDT_PunchIn",
        b."VMSDT_PunchOut",
        b."VMSDT_Remarks",
        b."withpreviousdayflag"
    FROM "HR_Master_Employee" a
    INNER JOIN "VMS_DriverOt_Details" b ON a."HRME_Id" = b."HRME_Id" 
        AND a."HRME_ActiveFlag" = 1 
        AND a."HRME_LeftFlag" = 0
        AND (b."VMSDT_TotalOt") > '0' 
        AND b."VMSDT_ID" NOT IN (SELECT "VMSDT_ID" FROM "VMS_DriverOt_Approval");
END;
$$;