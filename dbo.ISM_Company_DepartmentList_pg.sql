CREATE OR REPLACE FUNCTION "dbo"."ISM_Company_DepartmentList"()
RETURNS TABLE(
    "MI_Id" INTEGER,
    "HRMD_Id" INTEGER,
    "HRMD_DepartmentName" VARCHAR,
    "MI_Name" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "MD"."MI_Id",
        "MD"."HRMD_Id", 
        "MD"."HRMD_DepartmentName", 
        "MI"."MI_Name"
    FROM "Master_Institution" "MI"
    INNER JOIN "HR_Master_Department" "MD" ON "MD"."MI_Id" = "MI"."MI_Id" AND "MD"."HRMD_ActiveFlag" = 1
    WHERE "MI"."MI_ActiveFlag" = 1
    ORDER BY "MI"."MI_Name";

END;
$$;