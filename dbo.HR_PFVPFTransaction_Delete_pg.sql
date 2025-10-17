CREATE OR REPLACE FUNCTION "dbo"."HR_PFVPFTransaction_Delete"(
    "@TransactionID" BIGINT,
    "@PFVPFflag" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@IMFY_Id" BIGINT;
    "@HRME_Id" BIGINT;
BEGIN
    IF ("@PFVPFflag" = 'PF') THEN
        SELECT "IMFY_Id", "HRME_Id" 
        INTO "@IMFY_Id", "@HRME_Id" 
        FROM "HR_Employee_PF_Status" 
        WHERE "HREPFST_Id" = "@TransactionID";
        
        DELETE FROM "HR_Employee_PF_Status" 
        WHERE "HRME_Id" = "@HRME_Id" 
        AND "HREPFST_Id" >= "@TransactionID" 
        AND "IMFY_Id" = "@IMFY_Id";
    ELSE
        SELECT "IMFY_Id", "HRME_Id" 
        INTO "@IMFY_Id", "@HRME_Id" 
        FROM "HR_Employee_VPF_Status" 
        WHERE "HREVPFST_Id" = "@TransactionID";
        
        DELETE FROM "HR_Employee_VPF_Status" 
        WHERE "HRME_Id" = "@HRME_Id" 
        AND "HREVPFST_Id" >= "@TransactionID" 
        AND "IMFY_Id" = "@IMFY_Id";
    END IF;
END;
$$;