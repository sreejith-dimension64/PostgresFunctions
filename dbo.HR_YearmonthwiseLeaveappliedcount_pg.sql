CREATE OR REPLACE FUNCTION "HR_YearmonthwiseLeaveappliedcount"(
    p_MI_Id TEXT,
    p_HRMLY_Id TEXT,
    p_IVRM_Month_Id TEXT
)
RETURNS TABLE(
    "MI_id" BIGINT,
    "HRMLY_Id" BIGINT,
    "HRMLY_LeaveYear" VARCHAR,
    "IVRM_Month_Id" BIGINT,
    "IVRM_Month_Name" VARCHAR,
    "count" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic TEXT;
BEGIN
    v_dynamic := 'SELECT A."MI_id",F."HRMLY_Id",F."HRMLY_LeaveYear",g."IVRM_Month_Id",g."IVRM_Month_Name",Count(distinct a."HRME_Id") as count
FROM "HR_Master_Employee" a
INNER JOIN "HR_Emp_Leave_Application" b ON a."HRME_Id"=b."HRME_Id" AND a."MI_Id"=b."MI_Id"
INNER JOIN "HR_Emp_Leave_Appl_Details" c ON b."HRELAP_Id"=c."HRELAP_Id" 
INNER JOIN "HR_Master_Leave" d ON d."HRML_Id"=c."HRML_Id"
INNER JOIN "HR_Master_Leave_Details" e ON a."MI_Id"=e."MI_Id" AND a."HRMD_Id"=e."HRMD_Id" AND a."HRMDES_Id"=e."HRMDES_Id" AND 
a."HRMG_Id"=e."HRMG_Id" AND a."HRMGT_Id"=e."HRMGT_Id" 
INNER JOIN "HR_Master_LeaveYear" f ON a."MI_Id"=f."MI_Id" 
INNER JOIN "IVRM_Month" g ON g."IVRM_Month_Id"=EXTRACT(MONTH FROM b."HRELAP_ApplicationDate"::DATE) 
WHERE A."MI_Id"=' || p_MI_Id || ' AND F."HRMLY_Id" IN (' || p_HRMLY_Id || ') AND g."IVRM_Month_Id" IN (' || p_IVRM_Month_Id || ') AND "HRME_ActiveFlag"=true AND "HRELAP_ActiveFlag"=true
AND "HRELAPD_ActiveFlag"=true AND "Is_Active"=true
GROUP BY A."MI_id",F."HRMLY_Id",F."HRMLY_LeaveYear",g."IVRM_Month_Id",g."IVRM_Month_Name"
ORDER BY F."HRMLY_Id",g."IVRM_Month_Id"';

    RETURN QUERY EXECUTE v_dynamic;
END;
$$;