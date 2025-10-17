CREATE OR REPLACE FUNCTION "dbo"."DepartmentList"(p_MI_Id bigint)
RETURNS TABLE(
    "HRMD_DepartmentCode" VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
BEGIN
    RETURN QUERY
    SELECT DISTINCT hmd."HRMD_DepartmentCode"
    FROM "HR_Master_Department" hmd
    WHERE hmd."HRMD_ActiveFlag" = 1 
        AND hmd."MI_Id" IN (
            SELECT mi."MI_Id" 
            FROM "Master_Institution" mi 
            WHERE mi."MI_ActiveFlag" = 1
        )
        AND hmd."HRMD_DepartmentCode" IS NOT NULL;
END;
$$;