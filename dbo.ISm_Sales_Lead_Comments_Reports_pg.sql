CREATE OR REPLACE FUNCTION "dbo"."ISm_Sales_Lead_Comments_Reports"(
    p_MI_Id BIGINT,
    p_ISMSLE_Id TEXT,
    p_fromdate VARCHAR(50),
    p_todate VARCHAR(50)
)
RETURNS TABLE(
    "ISMSLE_Id" BIGINT,
    "ISMSLE_LeadName" TEXT,
    "ISMSLECOM_Comments" TEXT,
    "ISMSLECOM_CreatedDate" TIMESTAMP,
    "employeename" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlexec TEXT;
BEGIN
    IF p_fromdate IS NULL OR p_fromdate = '' OR p_ISMSLE_Id != '' AND p_todate IS NULL OR p_todate = '' AND p_ISMSLE_Id IS NOT NULL THEN
        
        RETURN QUERY EXECUTE 
        'SELECT a."ISMSLE_Id", "ISMSLE_LeadName", "ISMSLECOM_Comments", "ISMSLECOM_CreatedDate", 
        (COALESCE(d."HRME_EmployeeFirstName",'''')||COALESCE(d."HRME_EmployeeMiddleName",'''')||COALESCE(d."HRME_EmployeeLastName",'''')) as employeename
        FROM "ISM_Sales_Lead_Comments" a
        LEFT JOIN "ISM_Sales_Lead" b ON a."ISMSLE_Id"=b."ISMSLE_Id"
        LEFT JOIN "IVRM_Staff_User_Login" c ON c."id"=a."ISMSLECOM_CreatedBy"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id"=c."Emp_Code"
        WHERE a."MI_Id"=b."MI_Id" AND a."MI_Id"=' || p_MI_Id || ' AND a."ISMSLE_Id" IN (' || p_ISMSLE_Id || ')';
    
    ELSIF p_fromdate IS NOT NULL OR p_fromdate != '' OR p_ISMSLE_Id = '0' AND p_todate IS NOT NULL OR p_todate != '' AND p_ISMSLE_Id IS NULL THEN
        
        RETURN QUERY EXECUTE 
        'SELECT a."ISMSLE_Id", "ISMSLE_LeadName", "ISMSLECOM_Comments", "ISMSLECOM_CreatedDate", 
        (COALESCE(d."HRME_EmployeeFirstName",'''')||COALESCE(d."HRME_EmployeeMiddleName",'''')||COALESCE(d."HRME_EmployeeLastName",'''')) as employeename
        FROM "ISM_Sales_Lead_Comments" a
        LEFT JOIN "ISM_Sales_Lead" b ON a."ISMSLE_Id"=b."ISMSLE_Id"
        LEFT JOIN "IVRM_Staff_User_Login" c ON c."id"=a."ISMSLECOM_CreatedBy"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id"=c."Emp_Code"
        WHERE a."MI_Id"=b."MI_Id" AND a."MI_Id"=' || p_MI_Id || '  
        AND a."ISMSLECOM_CreatedDate" BETWEEN ''' || p_fromdate || ''' AND ''' || p_todate || '''';
    
    ELSE
        
        RETURN QUERY EXECUTE 
        'SELECT a."ISMSLE_Id", "ISMSLE_LeadName", "ISMSLECOM_Comments", "ISMSLECOM_CreatedDate",
        (COALESCE(d."HRME_EmployeeFirstName",'''')||COALESCE(d."HRME_EmployeeMiddleName",'''')||COALESCE(d."HRME_EmployeeLastName",'''')) as employeename 
        FROM "ISM_Sales_Lead_Comments" a
        LEFT JOIN "ISM_Sales_Lead" b ON a."ISMSLE_Id"=b."ISMSLE_Id"
        LEFT JOIN "IVRM_Staff_User_Login" c ON c."id"=a."ISMSLECOM_CreatedBy"
        INNER JOIN "HR_Master_Employee" d ON d."HRME_Id"=c."Emp_Code"
        WHERE a."MI_Id"=b."MI_Id" AND a."MI_Id"=' || p_MI_Id || ' AND a."ISMSLE_Id" IN (' || p_ISMSLE_Id || ')
        AND a."ISMSLECOM_CreatedDate" BETWEEN ''' || p_fromdate || ''' AND ''' || p_todate || '''';
    
    END IF;
    
    RETURN;
END;
$$;