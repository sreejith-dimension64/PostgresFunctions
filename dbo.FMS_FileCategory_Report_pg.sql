CREATE OR REPLACE FUNCTION "dbo"."FMS_FileCategory_Report"(
    p_MI_Id TEXT,
    p_FromDate VARCHAR(10),
    p_ToDate VARCHAR(10),
    p_HRMD_Id TEXT
)
RETURNS TABLE(
    "EmpName" TEXT,
    "HRMD_DepartmentName" TEXT,
    "FMSMFC_FileCategoryName" TEXT,
    "Catcount" BIGINT,
    "FMSMFC_Id" INTEGER,
    "FMSCOR_CreatedBy" INTEGER,
    "IMFY_FinancialYear" TEXT,
    "IMFY_Id" INTEGER,
    "MI_Id" INTEGER,
    "MI_Name" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        (COALESCE("HRE"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRE"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRE"."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
        "HMD"."HRMD_DepartmentName",
        "FDF"."FMSMFC_FileCategoryName",
        COUNT(*)::BIGINT AS "Catcount",
        "FC"."FMSMFC_Id",
        "FC"."FMSCOR_CreatedBy",
        "IMFY"."IMFY_FinancialYear",
        "FC"."IMFY_Id",
        "FC"."MI_Id",
        "MI"."MI_Name"
    FROM "FMS_Master_FileCategory" "FDF"
    INNER JOIN "FMS_Correspondence" "FC" ON "FC"."FMSMFC_Id" = "FDF"."FMSMFC_Id"
    INNER JOIN "FMS_Department_FileCategory" "DFC" ON "DFC"."FMSMFC_Id" = "FC"."FMSMFC_Id"
    INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Id" = "FC"."FMSCOR_CreatedBy"
    INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "SUL"."Emp_Code"
    INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "DFC"."HRMD_Id"
    INNER JOIN "IVRM_Master_FinancialYear" "IMFY" ON "IMFY"."IMFY_Id" = "FC"."IMFY_Id"
    INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "FC"."MI_Id"
    WHERE "FC"."FMSCOR_ActiveFlg" = 1 
        AND "FDF"."FMSMFC_ActiveFlg" = 1 
        AND (CAST("FC"."FMSCOR_Date" AS DATE) BETWEEN CAST(p_FromDate AS DATE) AND CAST(p_ToDate AS DATE))
        AND "FDF"."MI_Id"::TEXT = p_MI_Id 
        AND "FC"."MI_Id"::TEXT = p_MI_Id
        AND "DFC"."HRMD_Id"::TEXT IN (
            SELECT DISTINCT "ISMPDSDMAP_SHRMD_Id"::TEXT 
            FROM "ISM_PDpnt_SDpnt_Mapping" 
            WHERE "HRMD_Id"::TEXT = p_HRMD_Id 
                AND "MI_Id"::TEXT = p_MI_Id
        )
    GROUP BY 
        (COALESCE("HRE"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRE"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRE"."HRME_EmployeeLastName", '')),
        "HMD"."HRMD_DepartmentName",
        "FDF"."FMSMFC_FileCategoryName",
        "FC"."FMSMFC_Id",
        "FC"."FMSCOR_CreatedBy",
        "IMFY"."IMFY_FinancialYear",
        "FC"."IMFY_Id",
        "FC"."MI_Id",
        "MI"."MI_Name"

    UNION ALL

    SELECT DISTINCT 
        (COALESCE("HRE"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRE"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRE"."HRME_EmployeeLastName", ''))::TEXT AS "EmpName",
        "HMD"."HRMD_DepartmentName",
        "FDF"."FMSMFC_FileCategoryName",
        COUNT(*)::BIGINT AS "Catcount",
        "FC"."FMSMFC_Id",
        "FC"."FMSCOR_CreatedBy",
        "IMFY"."IMFY_FinancialYear",
        "FC"."IMFY_Id",
        "FC"."MI_Id",
        "MI"."MI_Name"
    FROM "FMS_Master_FileCategory" "FDF"
    INNER JOIN "FMS_Correspondence" "FC" ON "FC"."FMSMFC_Id" = "FDF"."FMSMFC_Id"
    INNER JOIN "FMS_Department_FileCategory" "DFC" ON "DFC"."FMSMFC_Id" = "FC"."FMSMFC_Id"
    INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Id" = "FC"."FMSCOR_CreatedBy"
    INNER JOIN "HR_Master_Employee" "HRE" ON "HRE"."HRME_Id" = "SUL"."Emp_Code"
    INNER JOIN "HR_Master_Department" "HMD" ON "HMD"."HRMD_Id" = "DFC"."HRMD_Id"
    INNER JOIN "IVRM_Master_FinancialYear" "IMFY" ON "IMFY"."IMFY_Id" = "FC"."IMFY_Id"
    INNER JOIN "Master_Institution" "MI" ON "MI"."MI_Id" = "FC"."MI_Id"
    WHERE "FC"."FMSCOR_ActiveFlg" = 1 
        AND "FDF"."FMSMFC_ActiveFlg" = 1 
        AND CAST("FC"."FMSCOR_Date" AS DATE) BETWEEN CAST(p_FromDate AS DATE) AND CAST(p_ToDate AS DATE)
        AND "FDF"."MI_Id"::TEXT = p_MI_Id 
        AND "FC"."MI_Id"::TEXT = p_MI_Id
        AND "DFC"."HRMD_Id"::TEXT IN (
            SELECT DISTINCT "HRMD_Id"::TEXT 
            FROM "ISM_PDpnt_SDpnt_Mapping" 
            WHERE "HRMD_Id"::TEXT = p_HRMD_Id 
                AND "MI_Id"::TEXT = p_MI_Id
        )
    GROUP BY 
        (COALESCE("HRE"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HRE"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HRE"."HRME_EmployeeLastName", '')),
        "HMD"."HRMD_DepartmentName",
        "FDF"."FMSMFC_FileCategoryName",
        "FC"."FMSMFC_Id",
        "FC"."FMSCOR_CreatedBy",
        "IMFY"."IMFY_FinancialYear",
        "FC"."IMFY_Id",
        "FC"."MI_Id",
        "MI"."MI_Name";
END;
$$;