CREATE OR REPLACE FUNCTION "HR_Employee_Medical_Report"(
    p_flag BIGINT,
    p_MI_Id BIGINT,
    p_HREMR_Id BIGINT
)
RETURNS TABLE (
    "HRME_Id" BIGINT,
    "EmployeeName" TEXT,
    "HREMR_TestDate" TIMESTAMP,
    "HREMR_TestName" TEXT,
    "HREMR_Id" BIGINT,
    "HREMR_Remarks" TEXT,
    "HREMR_CreatedDate" TIMESTAMP,
    "HREMR_UpdatedDate" TIMESTAMP,
    "HREMR_ActiveFlag" BOOLEAN,
    "HREMR_CreatedBy" BIGINT,
    "HREMR_UpdatedBy" BIGINT,
    "CountofRecords" BIGINT,
    "CountofRecordFiles" BIGINT,
    "HREMRF_FileName" TEXT,
    "HREMRF_FilePath" TEXT,
    "HREMRF_CreatedDate" TIMESTAMP,
    "HREMRF_UpdatedDate" TIMESTAMP,
    "HREMRF_CreatedBy" BIGINT,
    "HREMRF_UpdatedBy" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_flag = 1 THEN
        RETURN QUERY
        SELECT DISTINCT 
            b."HRME_Id",
            CONCAT(COALESCE(b."HRME_EmployeeFirstName", ''), ' ', COALESCE(b."HRME_EmployeeMiddleName", ''), ' ', COALESCE(b."HRME_EmployeeLastName", '')) AS "EmployeeName",
            a."HREMR_TestDate",
            a."HREMR_TestName",
            a."HREMR_Id",
            a."HREMR_Remarks",
            a."HREMR_CreatedDate",
            a."HREMR_UpdatedDate",
            a."HREMR_ActiveFlag",
            a."HREMR_CreatedBy",
            a."HREMR_UpdatedBy",
            (SELECT COUNT(R."HREMR_Id") FROM "HR_Employee_MedicalRecord_File" R WHERE R."HREMR_Id" = a."HREMR_Id") AS "CountofRecords",
            NULL::BIGINT AS "CountofRecordFiles",
            NULL::TEXT AS "HREMRF_FileName",
            NULL::TEXT AS "HREMRF_FilePath",
            NULL::TIMESTAMP AS "HREMRF_CreatedDate",
            NULL::TIMESTAMP AS "HREMRF_UpdatedDate",
            NULL::BIGINT AS "HREMRF_CreatedBy",
            NULL::BIGINT AS "HREMRF_UpdatedBy"
        FROM "HR_Employee_MedicalRecord" a
        INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id" 
            AND b."HRME_ActiveFlag" = TRUE 
            AND b."HRME_LeftFlag" = FALSE
        WHERE a."MI_Id" = p_MI_Id;
    ELSIF p_flag = 2 THEN
        RETURN QUERY
        SELECT DISTINCT 
            c."HRME_Id",
            CONCAT(COALESCE(c."HRME_EmployeeFirstName", ''), ' ', COALESCE(c."HRME_EmployeeMiddleName", ''), ' ', COALESCE(c."HRME_EmployeeLastName", '')) AS "EmployeeName",
            NULL::TIMESTAMP AS "HREMR_TestDate",
            NULL::TEXT AS "HREMR_TestName",
            NULL::BIGINT AS "HREMR_Id",
            NULL::TEXT AS "HREMR_Remarks",
            NULL::TIMESTAMP AS "HREMR_CreatedDate",
            NULL::TIMESTAMP AS "HREMR_UpdatedDate",
            NULL::BOOLEAN AS "HREMR_ActiveFlag",
            NULL::BIGINT AS "HREMR_CreatedBy",
            NULL::BIGINT AS "HREMR_UpdatedBy",
            NULL::BIGINT AS "CountofRecords",
            COUNT(b."HREMRF_Id") AS "CountofRecordFiles",
            b."HREMRF_FileName",
            b."HREMRF_FilePath",
            b."HREMRF_CreatedDate",
            b."HREMRF_UpdatedDate",
            b."HREMRF_CreatedBy",
            b."HREMRF_UpdatedBy"
        FROM "HR_Employee_MedicalRecord" a 
        INNER JOIN "HR_Employee_MedicalRecord_File" b ON a."HREMR_Id" = b."HREMR_Id" 
            AND b."HREMRF_ActiveFlag" = TRUE
            AND a."HREMR_ActiveFlag" = TRUE 
        INNER JOIN "HR_Master_Employee" c ON c."HRME_Id" = a."HRME_Id" 
        WHERE a."MI_Id" = p_MI_Id 
            AND b."HREMR_Id" = p_HREMR_Id 
        GROUP BY c."HRME_Id",
            c."HRME_EmployeeFirstName",
            c."HRME_EmployeeMiddleName",
            c."HRME_EmployeeLastName", 
            b."HREMRF_FileName",
            b."HREMRF_FilePath",
            b."HREMRF_ActiveFlag",
            b."HREMRF_CreatedDate",
            b."HREMRF_UpdatedDate",
            b."HREMRF_CreatedBy",
            b."HREMRF_UpdatedBy";
    ELSIF p_flag = 3 THEN
        RETURN QUERY
        SELECT 
            NULL::BIGINT AS "HRME_Id",
            NULL::TEXT AS "EmployeeName",
            NULL::TIMESTAMP AS "HREMR_TestDate",
            NULL::TEXT AS "HREMR_TestName",
            NULL::BIGINT AS "HREMR_Id",
            NULL::TEXT AS "HREMR_Remarks",
            NULL::TIMESTAMP AS "HREMR_CreatedDate",
            NULL::TIMESTAMP AS "HREMR_UpdatedDate",
            NULL::BOOLEAN AS "HREMR_ActiveFlag",
            NULL::BIGINT AS "HREMR_CreatedBy",
            NULL::BIGINT AS "HREMR_UpdatedBy",
            NULL::BIGINT AS "CountofRecords",
            COUNT(b."HREMRF_Id") AS "CountofRecordFiles",
            NULL::TEXT AS "HREMRF_FileName",
            NULL::TEXT AS "HREMRF_FilePath",
            NULL::TIMESTAMP AS "HREMRF_CreatedDate",
            NULL::TIMESTAMP AS "HREMRF_UpdatedDate",
            NULL::BIGINT AS "HREMRF_CreatedBy",
            NULL::BIGINT AS "HREMRF_UpdatedBy"
        FROM "HR_Employee_MedicalRecord" a 
        INNER JOIN "HR_Employee_MedicalRecord_File" b ON a."HREMR_Id" = b."HREMR_Id" 
            AND b."HREMRF_ActiveFlag" = TRUE
            AND a."HREMR_ActiveFlag" = TRUE 
        INNER JOIN "HR_Master_Employee" c ON c."HRME_Id" = a."HRME_Id" 
        WHERE a."MI_Id" = p_MI_Id 
            AND a."HRME_Id" = p_HREMR_Id;
    END IF;
    
    RETURN;
END;
$$;