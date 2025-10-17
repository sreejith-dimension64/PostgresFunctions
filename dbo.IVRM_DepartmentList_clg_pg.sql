CREATE OR REPLACE FUNCTION "dbo"."IVRM_DepartmentList_clg"(
    p_MI_Id bigint,
    p_role text,
    p_HRMD_Id bigint
)
RETURNS TABLE(
    "HRMDC_Name" VARCHAR,
    "HRMDC_ID" bigint
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic text;
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "HRMD_DepartmentName" AS "HRMDC_Name",
        "HRMD_Id" AS "HRMDC_ID" 
    FROM "HR_Master_Department"  
    WHERE "MI_Id" = p_MI_Id;
    
    RETURN;
END;
$$;