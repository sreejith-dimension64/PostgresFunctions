CREATE OR REPLACE FUNCTION "dbo"."Clg_Staff_Noticeboard_Detailsdatewise"(
    p_MI_Id TEXT,
    p_HRME_id TEXT,
    p_ASMAY_Id BIGINT,
    p_fromdate TEXT,
    p_todate TEXT
)
RETURNS TABLE(
    "INTB_Id" BIGINT,
    "INTBCSTF_Id" BIGINT,
    "HRME_Id" BIGINT,
    "HRME_EmployeeFirstName" TEXT,
    "INTB_StartDate" TIMESTAMP,
    "INTB_EndDate" TIMESTAMP,
    "MI_Id" BIGINT,
    "HRMD_DepartmentName" TEXT,
    "HRMDES_DesignationName" TEXT,
    "INTB_Description" TEXT,
    "INTB_Title" TEXT,
    "NTB_TTSylabusFlg" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_year VARCHAR(20);
    v_betweendates TEXT;
    v_fromdate TEXT;
    v_todate TEXT;
BEGIN
    v_fromdate := p_fromdate;
    v_todate := p_todate;
    
    SELECT DISTINCT "ASMAY_Year" INTO v_year
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Id" = p_ASMAY_Id AND "MI_Id" = p_MI_Id::BIGINT;
    
    SELECT "IMFY_FromDate"::TEXT INTO v_fromdate
    FROM "IVRM_Master_FinancialYear" 
    WHERE "IMFY_FinancialYear" = v_year;
    
    SELECT MAX("INTB_EndDate"::DATE)::TEXT INTO v_todate
    FROM "IVRM_NoticeBoard";
    
    v_betweendates := ' (a."INTB_StartDate"::DATE >= ''' || v_fromdate || '''::DATE AND a."INTB_EndDate"::DATE <= ''' || v_todate || '''::DATE)';
    
    v_sql := '
    SELECT DISTINCT a."INTB_Id", c."INTBCSTF_Id", d."HRME_Id",
    CONCAT(COALESCE(d."HRME_EmployeeFirstName", '' ''), '''', COALESCE(d."HRME_EmployeeMiddleName", '' ''), '''', COALESCE(d."HRME_EmployeeLastName", '' '')) AS "HRME_EmployeeFirstName",
    a."INTB_StartDate", a."INTB_EndDate", a."MI_Id", e."HRMD_DepartmentName", f."HRMDES_DesignationName", a."INTB_Description", a."INTB_Title", a."NTB_TTSylabusFlg"
    FROM "IVRM_NoticeBoard" a 
    INNER JOIN "clg"."IVRM_NoticeBoard_CoBranch" b ON a."INTB_Id" = b."INTB_Id"
    INNER JOIN "IVRM_NoticeBoard_Staff" c ON c."INTB_Id" = b."INTB_Id"
    INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."HRME_Id" AND d."HRME_ActiveFlag" = true
    INNER JOIN "HR_Master_Department" e ON e."HRMD_Id" = d."HRMD_Id"
    INNER JOIN "HR_Master_Designation" f ON f."HRMDES_Id" = d."HRMDES_Id"
    WHERE a."MI_Id"::TEXT IN (' || p_MI_id || ') AND d."HRME_Id"::TEXT = (' || p_HRME_Id || ') 
    AND a."INTB_StartDate"::DATE >= ''' || v_fromdate || '''::DATE 
    AND a."INTB_EndDate"::DATE <= ''' || v_todate || '''::DATE';
    
    RAISE NOTICE '%', v_sql;
    
    RETURN QUERY EXECUTE v_sql;
    
END;
$$;