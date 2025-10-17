CREATE OR REPLACE FUNCTION "dbo"."INV_ICUserDetails" (
    "MI_Id" BIGINT,
    "INVMIC_Id" BIGINT,
    "userflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMIC_Id" BIGINT,
    "INVMST_Id" BIGINT,
    "INVMIC_StuOtherFlg" VARCHAR,
    "User_Id" BIGINT,
    "username" TEXT,
    "UserCode" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "userflag" = 'Staff' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "IMC"."INVMIC_Id",
            "IMC"."INVMST_Id",
            "IMC"."INVMIC_StuOtherFlg",
            "ICS"."HRME_Id" AS "User_Id",
            (CASE WHEN "HRM"."HRME_EmployeeFirstName" IS NULL OR "HRM"."HRME_EmployeeFirstName" = '' THEN '' ELSE "HRM"."HRME_EmployeeFirstName" END || 
             CASE WHEN "HRM"."HRME_EmployeeMiddleName" IS NULL OR "HRM"."HRME_EmployeeMiddleName" = '' OR "HRM"."HRME_EmployeeMiddleName" = '0' THEN '' ELSE ' ' || "HRM"."HRME_EmployeeMiddleName" END || 
             CASE WHEN "HRM"."HRME_EmployeeLastName" IS NULL OR "HRM"."HRME_EmployeeLastName" = '' OR "HRM"."HRME_EmployeeLastName" = '0' THEN '' ELSE ' ' || "HRM"."HRME_EmployeeLastName" END) AS "username",
            "HRM"."HRME_EmployeeCode" AS "UserCode"
        FROM "INV"."INV_M_ItemConsumption" "IMC"
        INNER JOIN "INV"."INV_T_ItemConsumption" "ITC" ON "IMC"."INVMIC_Id" = "ITC"."INVMIC_Id"
        INNER JOIN "INV"."INV_M_IC_Staff" "ICS" ON "ICS"."INVMIC_Id" = "ITC"."INVMIC_Id"
        INNER JOIN "HR_Master_Employee" "HRM" ON "HRM"."HRME_Id" = "ICS"."HRME_Id"
        WHERE "IMC"."INVMIC_ActiveFlg" = 1 
            AND "IMC"."INVMIC_ActiveFlg" = 1 
            AND "ITC"."INVTIC_ActiveFlg" = 1 
            AND "IMC"."MI_Id" = "MI_Id" 
            AND "ITC"."INVMIC_Id" = "INVMIC_Id";
            
    ELSIF "userflag" = 'Department' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "IMC"."INVMIC_Id",
            "IMC"."INVMST_Id",
            "IMC"."INVMIC_StuOtherFlg",
            "ICD"."HRMD_Id" AS "User_Id",
            "HRD"."HRMD_DepartmentName" AS "username",
            CAST(NULL AS VARCHAR) AS "UserCode"
        FROM "INV"."INV_M_ItemConsumption" "IMC"
        INNER JOIN "INV"."INV_T_ItemConsumption" "ITC" ON "IMC"."INVMIC_Id" = "ITC"."INVMIC_Id"
        INNER JOIN "INV"."INV_M_IC_Department" "ICD" ON "ICD"."INVMIC_Id" = "ITC"."INVMIC_Id"
        INNER JOIN "HR_Master_Department" "HRD" ON "HRD"."HRMD_Id" = "ICD"."HRMD_Id"
        WHERE "IMC"."INVMIC_ActiveFlg" = 1 
            AND "IMC"."INVMIC_ActiveFlg" = 1 
            AND "ITC"."INVTIC_ActiveFlg" = 1 
            AND "IMC"."MI_Id" = "MI_Id" 
            AND "ITC"."INVMIC_Id" = "INVMIC_Id";
            
    ELSIF "userflag" = 'Student' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "IMC"."INVMIC_Id",
            "IMC"."INVMST_Id",
            "IMC"."INVMIC_StuOtherFlg",
            "ICS"."AMST_Id" AS "User_Id",
            (CASE WHEN "ADM"."AMST_FirstName" IS NULL OR "ADM"."AMST_FirstName" = '' THEN '' ELSE "ADM"."AMST_FirstName" END || 
             CASE WHEN "ADM"."AMST_MiddleName" IS NULL OR "ADM"."AMST_MiddleName" = '' OR "ADM"."AMST_MiddleName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_MiddleName" END || 
             CASE WHEN "ADM"."AMST_LastName" IS NULL OR "ADM"."AMST_LastName" = '' OR "ADM"."AMST_LastName" = '0' THEN '' ELSE ' ' || "ADM"."AMST_LastName" END) AS "username",
            "ADM"."AMST_AdmNo" AS "UserCode"
        FROM "INV"."INV_M_ItemConsumption" "IMC"
        INNER JOIN "INV"."INV_T_ItemConsumption" "ITC" ON "IMC"."INVMIC_Id" = "ITC"."INVMIC_Id"
        INNER JOIN "INV"."INV_M_IC_Student" "ICS" ON "ICS"."INVMIC_Id" = "ITC"."INVMIC_Id"
        INNER JOIN "Adm_M_Student" "ADM" ON "ADM"."AMST_Id" = "ICS"."AMST_Id"
        WHERE "IMC"."INVMIC_ActiveFlg" = 1 
            AND "IMC"."INVMIC_ActiveFlg" = 1 
            AND "ITC"."INVTIC_ActiveFlg" = 1 
            AND "IMC"."MI_Id" = "MI_Id" 
            AND "ITC"."INVMIC_Id" = "INVMIC_Id";
    END IF;
    
    RETURN;
    
END;
$$;