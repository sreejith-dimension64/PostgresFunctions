CREATE OR REPLACE FUNCTION "dbo"."INVPI_SMSMAILPARAMETER_NEW"(
    "UserID" bigint,
    "INVMS_Id" bigint,
    "INVMPI_Id" bigint,
    "template" varchar(200)
)
RETURNS TABLE (
    column1 varchar,
    column2 varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" text;
    "supname" text;
    "pinumber" text;
BEGIN

    IF "template" = 'StaffUserCreation' THEN
        RETURN QUERY
        SELECT 
            "UserName"::varchar AS column1,
            'Password@123'::varchar AS column2
        FROM "ApplicationUser"
        WHERE "Id" = "UserID";
        RETURN;
    END IF;

    IF "template" = 'REG' THEN
        RETURN QUERY
        SELECT 
            "UserName"::varchar AS column1,
            NULL::varchar AS column2
        FROM "ApplicationUser"
        WHERE "Id" = "UserID";
        RETURN;
    END IF;

    IF "template" = 'PINotification' THEN
        
        DROP TABLE IF EXISTS "Temp_PI_Status";
        
        CREATE TEMP TABLE "Temp_PI_Status" (
            "INVMPI_Id" bigint,
            "Supplier_Name" text,
            "PI_Number" text
        );

        SELECT "INVPITS_SupplierName"
        INTO "supname"
        FROM "INV"."INV_PurchaseIndent_ToSupplier"
        WHERE "INVPITS_Id" = "INVMS_Id";

        SELECT DISTINCT "INVMPI_PINo"
        INTO "pinumber"
        FROM "INV"."INV_M_PurchaseIndent"
        WHERE "INVMPI_Id" = "INVMPI_Id";

        INSERT INTO "Temp_PI_Status" VALUES("INVMPI_Id", "supname", "pinumber");
        
        RETURN QUERY
        SELECT 
            "Supplier_Name"::varchar AS column1,
            "PI_Number"::varchar AS column2
        FROM "Temp_PI_Status"
        WHERE "INVMPI_Id" = "INVMPI_Id";
        
        RETURN;
    END IF;

END;
$$;