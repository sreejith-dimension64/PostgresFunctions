CREATE OR REPLACE FUNCTION "dbo"."HR_Leave_Authorization_Get_Details"(
    p_MI_Id VARCHAR
)
RETURNS TABLE(
    "hrlA_Id" INTEGER,
    "hrmG_GradeName" VARCHAR,
    "hrmL_LeaveType" VARCHAR,
    "hrmE_EmployeeFirstName" VARCHAR,
    "hrlaoN_SanctionLevelNo" INTEGER,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "HRMGT_EmployeeGroupType" VARCHAR,
    "IVRMUL_Id" INTEGER,
    "HRLAON_FinalFlg" BOOLEAN,
    "HRLAON_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."HRLA_Id" AS "hrlA_Id",
        f."HRMG_GradeName" AS "hrmG_GradeName",
        h."HRML_LeaveName" AS "hrmL_LeaveType",
        c."UserName" AS "hrmE_EmployeeFirstName",
        b."hrlaoN_SanctionLevelNo",
        d."HRMD_DepartmentName",
        e."HRMDES_DesignationName",
        g."HRMGT_EmployeeGroupType",
        b."IVRMUL_Id",
        b."HRLAON_FinalFlg",
        b."HRLAON_Id"
    FROM "HR_Leave_Authorisation" a
    INNER JOIN "HR_Leave_Auth_OrderNo" b ON a."HRLA_Id" = b."HRLA_Id"
    INNER JOIN "ApplicationUser" c ON c."id" = b."IVRMUL_Id"
    INNER JOIN "HR_Master_Department" d ON d."HRMD_Id" = a."HRMD_Id"
    INNER JOIN "HR_Master_Designation" e ON e."HRMDES_Id" = a."HRMDES_Id"
    INNER JOIN "HR_Master_Grade" f ON f."HRMG_Id" = a."HRMG_Id"
    INNER JOIN "HR_Master_GroupType" g ON g."HRMGT_Id" = a."HRMGT_Id"
    INNER JOIN "HR_Master_Leave" h ON h."HRML_Id" = a."HRML_Id"
    WHERE a."MI_Id" = p_MI_Id
    ORDER BY c."UserName";
END;
$$;