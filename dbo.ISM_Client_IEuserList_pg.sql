CREATE OR REPLACE FUNCTION "dbo"."ISM_Client_IEuserList" (
    "p_MI_Id" BIGINT,
    "p_ISMMCLT_Id" BIGINT
)
RETURNS TABLE (
    "ISMMCLT_Id" BIGINT,
    "ISMCIM_IEList" BIGINT,
    "employeeName" TEXT,
    "HRME_EmployeeCode" TEXT,
    "HRMDES_Id" BIGINT,
    "HRMDES_DesignationName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Slqdymaic" TEXT;
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "IMC"."ISMMCLT_Id",
        "IMCIE"."ISMCIM_IEList",
        ((CASE WHEN "HME"."HRME_EmployeeFirstName" IS NULL OR "HME"."HRME_EmployeeFirstName" = '' THEN '' 
              ELSE "HME"."HRME_EmployeeFirstName" END ||
         CASE WHEN "HME"."HRME_EmployeeMiddleName" IS NULL OR "HME"."HRME_EmployeeMiddleName" = '' 
              OR "HME"."HRME_EmployeeMiddleName" = '0' THEN '' 
              ELSE ' ' || "HME"."HRME_EmployeeMiddleName" END ||
         CASE WHEN "HME"."HRME_EmployeeLastName" IS NULL OR "HME"."HRME_EmployeeLastName" = '' 
              OR "HME"."HRME_EmployeeLastName" = '0' THEN '' 
              ELSE ' ' || "HME"."HRME_EmployeeLastName" END))::TEXT AS "employeeName",
        "HME"."HRME_EmployeeCode"::TEXT,
        "HME"."HRMDES_Id",
        "HMD"."HRMDES_DesignationName"::TEXT
    FROM "ISM_Master_Client" "IMC"
    INNER JOIN "ISM_Master_Client_IEMapping" "IMCIE" 
        ON "IMC"."ISMMCLT_Id" = "IMCIE"."ISMMCLT_Id" 
        AND "IMCIE"."ISMMCLTIE_ActiveFlag" = 1
    INNER JOIN "HR_Master_Employee" "HME" 
        ON "HME"."HRME_Id" = "IMCIE"."ISMCIM_IEList" 
        AND "HME"."HRME_ActiveFlag" = 1 
        AND "HME"."HRME_LeftFlag" = 0
    INNER JOIN "HR_Master_Designation" "HMD" 
        ON "HMD"."HRMDES_Id" = "HME"."HRMDES_Id" 
        AND "HMD"."HRMDES_ActiveFlag" = 1
    WHERE "IMC"."MI_Id" = "p_MI_Id" 
        AND "IMC"."ISMMCLT_Id" = "p_ISMMCLT_Id"
    ORDER BY "employeeName";

END;
$$;