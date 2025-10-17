CREATE OR REPLACE FUNCTION "dbo"."INVPI_SMSMAILPARAMETER" (
    "UserID" BIGINT,
    "INVMS_Id" BIGINT,
    "INVMPI_Id" BIGINT,
    "template" VARCHAR(200)
)
RETURNS TABLE (
    column1 TEXT,
    column2 TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "supname" TEXT;
    "pinumber" TEXT;
BEGIN

    IF "template" = 'StaffUserCreation' THEN
        RETURN QUERY
        SELECT 
            "UserName"::TEXT AS "[USR]", 
            'Password@123'::TEXT AS "[PWD]"
        FROM "ApplicationUser"
        WHERE "Id" = "UserID";
        RETURN;
    END IF;

    IF "template" = 'REG' THEN
        RETURN QUERY
        SELECT 
            "UserName"::TEXT AS "[NAME]",
            NULL::TEXT
        FROM "ApplicationUser"
        WHERE "Id" = "UserID";
        RETURN;
    END IF;

    IF "template" = 'PINotification' THEN
        
        DROP TABLE IF EXISTS "Temp_PI_Status";
        
        CREATE TEMP TABLE "Temp_PI_Status" (
            "INVMPI_Id" BIGINT,
            "Supplier_Name" TEXT,
            "PI_Number" TEXT
        );

        SELECT "INVMS_SupplierName"
        INTO "supname"
        FROM "INV"."INV_Master_Supplier"
        WHERE "INVMS_Id" = "INVMS_Id";

        SELECT DISTINCT "INVMPI_PINo"
        INTO "pinumber"
        FROM "INV"."INV_M_PurchaseIndent"
        WHERE "INVMPI_Id" = "INVMPI_Id";

        INSERT INTO "Temp_PI_Status" VALUES("INVMPI_Id", "supname", "pinumber");

        RETURN QUERY
        SELECT 
            "Supplier_Name"::TEXT AS "[Supplier_Name]", 
            "PI_Number"::TEXT AS "[PI_Number]"
        FROM "Temp_PI_Status"
        WHERE "INVMPI_Id" = "INVMPI_Id";
        
        DROP TABLE IF EXISTS "Temp_PI_Status";
        RETURN;
    END IF;

END;
$$;