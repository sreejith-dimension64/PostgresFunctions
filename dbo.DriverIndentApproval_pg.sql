CREATE OR REPLACE FUNCTION "dbo"."DriverIndentApproval"(
    "Type" VARCHAR(100)
)
RETURNS TABLE(
    "ISMDIT_Id" INTEGER,
    "ISMDIT_Date" TIMESTAMP,
    "TRMV_Id" INTEGER,
    "TRMV_VehicleName" VARCHAR,
    "TRMV_VehicleNo" VARCHAR,
    "ISMDIT_BillNo" VARCHAR,
    "ISMDIT_Qty" NUMERIC,
    "ISMDIT_Amount" NUMERIC,
    "ISMDIT_Remark" TEXT,
    "ISMDIT_PreparedByUserId" INTEGER,
    "ISMDIT_OpeningKM" NUMERIC,
    "ISMDIT_ClosingKM" NUMERIC,
    "HRME_EmployeeFirstName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF ("Type" = 'ADMIN') THEN
        RETURN QUERY
        SELECT 
            "DI"."ISMDIT_Id",
            "DI"."ISMDIT_Date" AS "ISMDIT_Date",
            "DI"."TRMV_Id",
            "TRN"."TRMV_VehicleName",
            "TRN"."TRMV_VehicleNo",
            "DI"."ISMDIT_BillNo",
            "DI"."ISMDIT_Qty",
            "DI"."ISMDIT_Amount",
            "DIA"."ISMDIT_Remark",
            "DIA"."ISMDIT_PreparedByUserId",
            "DI"."ISMDIT_OpeningKM",
            "DI"."ISMDIT_ClosingKM",
            CONCAT("EMP"."HRME_EmployeeFirstName", ' ', "EMP"."HRME_EmployeeMiddleName", ' ', "EMP"."HRME_EmployeeLastName") AS "HRME_EmployeeFirstName"
        FROM "ISM_Driver_Indent" "DI"
        INNER JOIN "ISM_Driver_Indent_Approval" "DIA" ON "DI"."ISMDIT_Id" = "DIA"."ISMDIT_Id"
        INNER JOIN "TRN"."TR_Master_Vehicle" "TRN" ON "DI"."TRMV_Id" = "TRN"."TRMV_Id"
        INNER JOIN "IVRM_Staff_User_Login" "LOIN" ON "LOIN"."Id" = "DIA"."ISMDIT_PreparedByUserId"
        INNER JOIN "HR_Master_Employee" "EMP" ON "EMP"."HRME_Id" = "LOIN"."Emp_Code"
        WHERE "DIA"."ISMDIT_Id" NOT IN (
            SELECT DISTINCT "ISMDIT_Id" 
            FROM "ISM_Driver_Indent_Approval" 
            WHERE "ISMDIT_PreparedByFlag" = 'ADMIN'
        );
    
    ELSIF ("Type" = 'ACCOUNTANT') THEN
        RETURN QUERY
        SELECT DISTINCT
            "DI"."ISMDIT_Id",
            "DI"."ISMDIT_Date" AS "ISMDIT_Date",
            "DI"."TRMV_Id",
            "TRN"."TRMV_VehicleName",
            "TRN"."TRMV_VehicleNo",
            "DI"."ISMDIT_BillNo",
            "DI"."ISMDIT_Qty",
            "DI"."ISMDIT_Amount",
            "DIA"."ISMDIT_Remark",
            "DIA"."ISMDIT_PreparedByUserId",
            "DI"."ISMDIT_OpeningKM",
            "DI"."ISMDIT_ClosingKM",
            CONCAT("EMP"."HRME_EmployeeFirstName", ' ', "EMP"."HRME_EmployeeMiddleName", ' ', "EMP"."HRME_EmployeeLastName") AS "HRME_EmployeeFirstName"
        FROM "ISM_Driver_Indent" "DI"
        INNER JOIN "ISM_Driver_Indent_Approval" "DIA" ON "DI"."ISMDIT_Id" = "DIA"."ISMDIT_Id" AND "DIA"."ISMDIT_PreparedByFlag" = 'ADMIN'
        INNER JOIN "TRN"."TR_Master_Vehicle" "TRN" ON "DI"."TRMV_Id" = "TRN"."TRMV_Id"
        INNER JOIN "IVRM_Staff_User_Login" "LOIN" ON "LOIN"."Id" = "DIA"."ISMDIT_PreparedByUserId"
        INNER JOIN "HR_Master_Employee" "EMP" ON "EMP"."HRME_Id" = "LOIN"."Emp_Code"
        WHERE "DIA"."ISMDIT_Id" IN (
            SELECT DISTINCT "ISMDIT_Id" 
            FROM "ISM_Driver_Indent_Approval" 
            WHERE "ISMDIT_PreparedByFlag" = 'ADMIN' AND "ISMDIT_ApprovalUserId" <> 0
        );
    
    END IF;

    RETURN;

END;
$$;