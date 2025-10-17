CREATE OR REPLACE FUNCTION "dbo"."ISM_task_list_proc"(
    p_MI_Id bigint,
    p_HRMD_Id text,
    p_flg bigint
)
RETURNS TABLE(
    "ISMTCR_Id" bigint,
    "HRMD_Id" bigint,
    "HRMD_DepartmentName" text,
    "ISMTCR_Title" text,
    "ISMTCR_TaskNo" text,
    "ISMTCR_Desc" text,
    "ISMTCR_TGOrder" integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlText text;
BEGIN
    IF p_flg = 0 THEN
        v_sqlText := 'SELECT a."ISMTCR_Id", b."HRMD_Id", b."HRMD_DepartmentName", a."ISMTCR_Title", a."ISMTCR_TaskNo", a."ISMTCR_Desc", NULL::integer as "ISMTCR_TGOrder" 
                      FROM "ISM_TaskCreation" a, "HR_Master_Department" b 
                      WHERE a."HRMD_Id" = b."HRMD_Id" 
                      AND a."ISMTCR_ActiveFlg" = 1 
                      AND a."MI_Id" = b."MI_Id" 
                      AND a."HRMD_Id" IN (' || p_HRMD_Id || ') 
                      AND a."ISMMTGRP_Id" = 0';
        RETURN QUERY EXECUTE v_sqlText;
    ELSE
        v_sqlText := 'SELECT a."ISMTCR_Id", b."HRMD_Id", b."HRMD_DepartmentName", a."ISMTCR_Title", a."ISMTCR_TaskNo", a."ISMTCR_Desc", a."ISMTCR_TGOrder" 
                      FROM "ISM_TaskCreation" a, "HR_Master_Department" b 
                      WHERE a."HRMD_Id" = b."HRMD_Id" 
                      AND a."ISMTCR_ActiveFlg" = 1 
                      AND a."MI_Id" = b."MI_Id" 
                      AND a."HRMD_Id" IN (' || p_HRMD_Id || ')';
        RETURN QUERY EXECUTE v_sqlText;
    END IF;
END;
$$;