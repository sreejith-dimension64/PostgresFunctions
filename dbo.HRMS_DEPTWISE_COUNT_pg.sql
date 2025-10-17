CREATE OR REPLACE FUNCTION "dbo"."HRMS_DEPTWISE_COUNT"(
    "p_MI_Id" VARCHAR(10),
    "p_dept_id" TEXT
)
RETURNS TABLE(
    "dept_name" VARCHAR,
    "dept_count" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Sqldynamic" TEXT;
BEGIN
    "v_Sqldynamic" := '
    SELECT "d"."HRMD_DepartmentName" AS "dept_name", COUNT("d"."HRME_Id") AS "dept_count" 
    FROM (
        SELECT "hd"."HRMD_DepartmentName", "he"."HRME_Id" 
        FROM "HR_Master_Department" "hd"
        INNER JOIN "HR_Master_Employee" "he" ON "he"."HRMD_Id" = "hd"."HRMD_Id" 
        WHERE "hd"."HRMD_ActiveFlag" = 1 
        AND "he"."HRME_ActiveFlag" = 1 
        AND "he"."HRME_LeftFlag" = 0 
        AND "hd"."MI_Id" = ' || "p_MI_Id" || ' 
        AND "he"."MI_Id" = ' || "p_MI_Id" || ' 
        AND "he"."HRMD_Id" IN (' || "p_dept_id" || ')
    ) AS "d"
    GROUP BY "d"."HRMD_DepartmentName"';
    
    RETURN QUERY EXECUTE "v_Sqldynamic";
END;
$$;