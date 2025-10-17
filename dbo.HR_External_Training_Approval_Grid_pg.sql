CREATE OR REPLACE FUNCTION "dbo"."HR_External_Training_Approval_Grid"(
    p_MI_Id bigint
)
RETURNS TABLE(
    "EmployeeName" TEXT,
    "HRMETRCEN_TrainingCenterName" VARCHAR,
    "HREXTTRN_TrainingTopic" VARCHAR,
    "HREXTTRN_StartDate" TIMESTAMP,
    "ApproverName" TEXT,
    "HREXTTRNAPP_ApproverRemarks" VARCHAR,
    "HREXTTRNAPP_ApprovedHrs" NUMERIC,
    "HREXTTRNAPP_ApprovalFlg" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        COALESCE(j."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE(j."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE(j."HRME_EmployeeLastName", ' ') AS "EmployeeName",
        c."HRMETRCEN_TrainingCenterName",
        a."HREXTTRN_TrainingTopic",
        a."HREXTTRN_StartDate",
        COALESCE(k."HRME_EmployeeFirstName", ' ') || ' ' || COALESCE(k."HRME_EmployeeMiddleName", ' ') || ' ' || COALESCE(k."HRME_EmployeeLastName", ' ') AS "ApproverName",
        d."HREXTTRNAPP_ApproverRemarks",
        d."HREXTTRNAPP_ApprovedHrs",
        d."HREXTTRNAPP_ApprovalFlg"
    FROM "HR_External_Training" a
    INNER JOIN "HR_Master_External_TrainingType" b ON a."HRMETRTY_Id" = b."HRMETRTY_Id" AND b."MI_Id" = a."MI_Id"
    INNER JOIN "HR_Master_External_TrainingCenters" c ON a."HRMETRCEN_Id" = c."HRMETRCEN_Id"
    INNER JOIN "HR_External_Training_Approval" d ON d."HREXTTRN_Id" = a."HREXTTRN_Id"
    INNER JOIN "HR_Master_Employee" j ON j."HRME_Id" = a."HRME_Id"
    INNER JOIN "IVRM_Staff_User_Login" g ON g."Emp_Code" = d."HRME_Id"
    INNER JOIN "HR_Master_Employee" k ON k."HRME_Id" = d."HRME_Id"
    INNER JOIN "HR_Process_Authorisation" e ON e."MI_Id" = c."MI_Id"
    INNER JOIN "HR_Process_Auth_OrderNo" f ON f."HRPA_Id" = e."HRPA_Id"
    INNER JOIN "ApplicationUser" h ON h."Id" = f."IVRMUL_Id"
    WHERE a."HREXTTRN_ActiveFlag" = 1 
        AND e."HRPA_TypeFlag" = 'Training' 
        AND d."HREXTTRNAPP_ApprovalFlg" IN ('Approved', 'Rejected')
    ORDER BY a."HREXTTRN_StartDate" DESC;
END;
$$;