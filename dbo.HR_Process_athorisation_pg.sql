CREATE OR REPLACE FUNCTION "dbo"."HR_Process_athorisation"(
    "MI_Id" bigint
)
RETURNS TABLE(
    "hrpA_Id" bigint,
    "hrmgT_Id" bigint,
    "hrmD_Id" bigint,
    "hrmdeS_Id" bigint,
    "hrmG_Id" bigint,
    "hrlP_EmailTo" text,
    "hrlP_EmailCC" text,
    "hrpA_TypeFlag" text,
    "hrmgT_NAME" text,
    "hrmD_NAME" text,
    "hrmdeS_NAME" text,
    "hrpaoN_Id" bigint,
    "ivrmuL_Id" bigint,
    "hrpaoN_SanctionLevelNo" integer,
    "hrpaoN_FinalFlg" boolean,
    "ivrmstauL_UserName" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."HRPA_Id" AS "hrpA_Id",
        a."HRMGT_Id" AS "hrmgT_Id",
        a."HRMD_Id" AS "hrmD_Id",
        a."HRMDES_Id" AS "hrmdeS_Id",
        a."HRMG_Id" AS "hrmG_Id",
        a."HRLP_EmailTo" AS "hrlP_EmailTo",
        a."HRLP_EmailCC" AS "hrlP_EmailCC",
        a."HRPA_TypeFlag" AS "hrpA_TypeFlag",
        d."HRMGT_EmployeeGroupType" AS "hrmgT_NAME",
        e."HRMD_DepartmentName" AS "hrmD_NAME",
        f."HRMDES_DesignationName" AS "hrmdeS_NAME",
        b."HRPAON_Id" AS "hrpaoN_Id",
        b."IVRMUL_Id" AS "ivrmuL_Id",
        b."HRPAON_SanctionLevelNo" AS "hrpaoN_SanctionLevelNo",
        b."HRPAON_FinalFlg" AS "hrpaoN_FinalFlg",
        c."IVRMSTAUL_UserName" AS "ivrmstauL_UserName"
    FROM "HR_Process_Authorisation" a
    INNER JOIN "HR_Process_Auth_OrderNo" b ON a."HRPA_Id" = b."HRPA_Id"
    INNER JOIN "IVRM_Staff_user_login" c ON b."IVRMUL_Id" = c."id"
    INNER JOIN "HR_Master_GroupType" d ON a."HRMGT_Id" = d."HRMGT_Id"
    INNER JOIN "HR_Master_Department" e ON a."HRMD_Id" = e."HRMD_Id"
    INNER JOIN "HR_Master_Designation" f ON a."HRMDES_Id" = f."HRMDES_Id"
    WHERE a."MI_Id" = "MI_Id";
END;
$$;