CREATE OR REPLACE FUNCTION "dbo"."ISM_task_grou_dd_proc"(
    "@MI_Id" bigint
)
RETURNS TABLE(
    "ISMMTGRP_Id" bigint,
    "ISMMTGRP_TaskGroupName" VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT "ISM_Master_TaskGroup"."ISMMTGRP_Id", 
           "ISM_Master_TaskGroup"."ISMMTGRP_TaskGroupName" 
    FROM "ISM_Master_TaskGroup" 
    WHERE "ISM_Master_TaskGroup"."ISMMTGRP_Id" NOT IN (
        SELECT "ISM_TaskCreation"."ISMMTGRP_Id" 
        FROM "ISM_TaskCreation"
    ) 
    AND "ISM_Master_TaskGroup"."MI_Id" = "@MI_Id";

END;
$$;