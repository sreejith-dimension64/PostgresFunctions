CREATE OR REPLACE FUNCTION "dbo"."FAMasterGroupList"(
    "MI_Id" bigint
)
RETURNS TABLE(
    "FAMGRP_ParentId" bigint,
    "FAMGRP_GroupName" VARCHAR,
    "FAMGRP_Id" bigint,
    "FAMGRP_GroupCode" VARCHAR,
    "FAMGRP_Description" VARCHAR,
    "FAMGRP_BSPLFlg" VARCHAR,
    "FAMGRP_CRDRFlg" VARCHAR,
    "FAMGRP_Position" VARCHAR,
    "FAMGRP_ActiveFlg" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        d."FAMGRP_ParentId",
        MAX(d."FAMGRP_GroupName") as "FAMGRP_GroupName",
        MAX(d."FAMGRP_Id") as "FAMGRP_Id",
        MAX(d."FAMGRP_GroupCode") as "FAMGRP_GroupCode",
        MAX(d."FAMGRP_Description") as "FAMGRP_Description",
        MAX(d."FAMGRP_BSPLFlg") as "FAMGRP_BSPLFlg",
        MAX(d."FAMGRP_CRDRFlg") as "FAMGRP_CRDRFlg",
        MAX(d."FAMGRP_Position") as "FAMGRP_Position",
        MIN(d."FAMGRP_ActiveFlg") as "FAMGRP_ActiveFlg"
    FROM (
        SELECT 
            "FAMGRP_ParentId",
            "FAMGRP_GroupName",
            "FAMGRP_Id",
            "FAMGRP_GroupCode",
            "FAMGRP_Description",
            "FAMGRP_BSPLFlg",
            "FAMGRP_CRDRFlg",
            "FAMGRP_Position",
            CASE WHEN "FAMGRP_ActiveFlg" = 1 THEN '1' ELSE '0' END as "FAMGRP_ActiveFlg"
        FROM "FA_Master_Group"
        WHERE "MI_Id" = "MI_Id"
        GROUP BY 
            "FAMGRP_ParentId",
            "FAMGRP_Id",
            "FAMGRP_GroupName",
            "FAMGRP_GroupCode",
            "FAMGRP_Description",
            "FAMGRP_BSPLFlg",
            "FAMGRP_CRDRFlg",
            "FAMGRP_Position",
            "FAMGRP_ActiveFlg"
    ) as d
    GROUP BY d."FAMGRP_ParentId";
END;
$$;