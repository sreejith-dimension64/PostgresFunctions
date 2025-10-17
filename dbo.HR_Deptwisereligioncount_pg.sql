CREATE OR REPLACE FUNCTION "dbo"."HR_Deptwisereligioncount"(
    p_ASMAY_ID TEXT,
    p_IVRMMR_ID TEXT,
    p_MI_ID TEXT
)
RETURNS TABLE (
    "ASMAY_Year" VARCHAR,
    "IVRMMR_Name" VARCHAR,
    "HRMD_DepartmentName" VARCHAR,
    "COUNT" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
BEGIN
    v_sqldynamic := 'SELECT ASMAY."ASMAY_Year", IMR."IVRMMR_Name", HMD."HRMD_DepartmentName", COUNT(DISTINCT "HRME_Id") AS "COUNT" ' ||
                    'FROM "HR_Master_Employee" HME ' ||
                    'INNER JOIN "HR_Master_Department" HMD ON HMD."HRMD_Id" = HME."HRMD_Id" AND HME."MI_Id" = HMD."MI_Id" ' ||
                    'INNER JOIN "Adm_School_M_Academic_Year" ASMAY ON ASMAY."MI_Id" = HMD."MI_Id" ' ||
                    'INNER JOIN "IVRM_Master_Religion" IMR ON IMR."IVRMMR_Id" = HME."ReligionId" ' ||
                    'WHERE ASMAY."ASMAY_ID" = ' || p_ASMAY_ID || ' AND IMR."IVRMMR_ID" IN (' || p_IVRMMR_ID || ') AND HME."MI_Id" = ' || p_MI_ID || ' AND HME."HRME_ActiveFlag" = 1 ' ||
                    'AND HMD."HRMD_ActiveFlag" = 1 AND "ASMAY_ActiveFlag" = 1 AND IMR."Is_Active" = 1 ' ||
                    'GROUP BY ASMAY."ASMAY_Year", IMR."IVRMMR_Name", HMD."HRMD_DepartmentName" ' ||
                    'ORDER BY IMR."IVRMMR_Name"';
    
    RETURN QUERY EXECUTE v_sqldynamic;
END;
$$;