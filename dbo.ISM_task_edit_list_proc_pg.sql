CREATE OR REPLACE FUNCTION "dbo"."ISM_task_edit_list_proc"(
    p_MI_Id bigint,
    p_ISMMTGRP_Id bigint
)
RETURNS TABLE(
    "ISMTCR_Id" bigint,
    "HRMD_Id" bigint,
    "HRMD_DepartmentName" VARCHAR,
    "ISMTCR_Title" VARCHAR,
    "ISMTCR_TaskNo" VARCHAR,
    "ISMTCR_Desc" TEXT,
    "ISMTCR_TGOrder" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        a."ISMTCR_Id",
        b."HRMD_Id",
        b."HRMD_DepartmentName",
        a."ISMTCR_Title",
        a."ISMTCR_TaskNo",
        a."ISMTCR_Desc",
        a."ISMTCR_TGOrder"
    FROM 
        "dbo"."ISM_TaskCreation" a,
        "dbo"."HR_Master_Department" b
    WHERE 
        a."HRMD_Id" = b."HRMD_Id"
        AND a."ISMTCR_ActiveFlg" = 1
        AND a."MI_Id" = b."MI_Id"
        AND a."ISMMTGRP_Id" = p_ISMMTGRP_Id;

END;
$$;