
CREATE OR REPLACE FUNCTION "dbo"."ADMIN_ISM_DepartmentList"(
    p_MI_Id bigint
)
RETURNS TABLE (
    "HRMD_Id" bigint,
    "HRMD_DepartmentName" varchar,
    "HRMD_DepartmentCode" varchar,
    "HRMD_Order" int,
    "HRMD_ActiveFlag" boolean,
    "CreatedDate" timestamp,
    "UpdatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic text;
BEGIN
    RETURN QUERY
    SELECT * FROM "HR_Master_DepartmentCode";
    
END;
$$;