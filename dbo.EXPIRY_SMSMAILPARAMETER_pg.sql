CREATE OR REPLACE FUNCTION "dbo"."EXPIRY_SMSMAILPARAMETER"(
    "MI_Id" bigint,
    "TEMPLATE" TEXT,
    "TYPE" TEXT,
    "ID" bigint
)
RETURNS TABLE(
    "DATE" TIMESTAMP,
    "NAME" TEXT,
    "VEHICLEDETAILS" TEXT,
    "TITLE" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "TYPE" = 'LICENCE' THEN
        RETURN QUERY
        SELECT 
            "B"."TRMD_DLExpiryDate" as "DATE",
            "B"."TRMD_DriverName" AS "NAME",
            "C"."TRMV_VehicleNo" AS "VEHICLEDETAILS",
            'DRIVING LICENCE' AS "TITLE"
        FROM "TRN"."TR_VehicleDriver" as "A"
        INNER JOIN "TRN"."TR_Master_Driver" AS "B" ON "B"."TRMD_Id" = "A"."TRMD_Id"
        INNER JOIN "TRN"."TR_Master_Vehicle" AS "C" ON "C"."TRMV_Id" = "A"."TRMV_Id"
        WHERE "A"."MI_Id" = "MI_Id" AND "A"."TRMD_Id" = "ID"
        LIMIT 1;
        
    ELSIF "TYPE" = 'INSURANCE' THEN
        RETURN QUERY
        SELECT 
            "D"."TRVCT_ValidTillDate" as "DATE",
            "B"."TRMD_DriverName" AS "NAME",
            "C"."TRMV_VehicleNo" AS "VEHICLEDETAILS",
            'INSURANCE' AS "TITLE"
        FROM "TRN"."TR_VehicleDriver" as "A"
        INNER JOIN "TRN"."TR_Master_Driver" AS "B" ON "B"."TRMD_Id" = "A"."TRMD_Id"
        INNER JOIN "TRN"."TR_Master_Vehicle" AS "C" ON "C"."TRMV_Id" = "A"."TRMV_Id"
        INNER JOIN "TRN"."TR_Vehicle_Certificates" AS "D" ON "D"."TRMV_Id" = "A"."TRMV_Id"
        WHERE "A"."MI_Id" = "MI_Id" AND "D"."TRVCT_Id" = "ID" AND "D"."TRVCT_CertificateType" = 'Vehicle Insurance'
        LIMIT 1;
        
    ELSIF "TYPE" = 'TAX' THEN
        RETURN QUERY
        SELECT 
            "D"."TRVCT_ValidTillDate" as "DATE",
            "B"."TRMD_DriverName" AS "NAME",
            "C"."TRMV_VehicleNo" AS "VEHICLEDETAILS",
            'VEHICLE TAX' AS "TITLE"
        FROM "TRN"."TR_VehicleDriver" as "A"
        INNER JOIN "TRN"."TR_Master_Driver" AS "B" ON "B"."TRMD_Id" = "A"."TRMD_Id"
        INNER JOIN "TRN"."TR_Master_Vehicle" AS "C" ON "C"."TRMV_Id" = "A"."TRMV_Id"
        INNER JOIN "TRN"."TR_Vehicle_Certificates" AS "D" ON "D"."TRMV_Id" = "A"."TRMV_Id"
        WHERE "A"."MI_Id" = "MI_Id" AND "D"."TRMV_Id" = "ID" AND "D"."TRVCT_CertificateType" = 'Vehicle Tax'
        LIMIT 1;
        
    END IF;
    
    RETURN;
END;
$$;