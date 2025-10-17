CREATE OR REPLACE FUNCTION "FO"."FO_Biometric_Logs_Clear"(
    "MI_Id" bigint,
    "DeviceId" varchar(50),
    "FileName" varchar(50),
    "LogRecord" varchar(50)
)
RETURNS TABLE(
    "MI_Id" bigint,
    "FOBLC_DeviceId" varchar(50),
    "FOBLC_ClearedDateTime" timestamp,
    "FOBLC_FileName" varchar(50),
    "FOBLC_LogRecords" varchar(50),
    "CreatedDate" timestamp,
    "UpdatedDate" timestamp,
    "FOBLC_CreatedBy" integer,
    "FOBLC_UpdatedBy" integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    "LastClearDay" timestamp;
    "Datediffcount" bigint;
    "RecordExist" bigint;
BEGIN
    SELECT COUNT(*) INTO "RecordExist" 
    FROM "FO"."FO_Biometric_Log_Clear" 
    WHERE "MI_Id" = $1;

    IF ("RecordExist" > 0) THEN
        SELECT "FOBLC_ClearedDateTime" INTO "LastClearDay" 
        FROM "FO"."FO_Biometric_Log_Clear" 
        WHERE "MI_Id" = $1 
        ORDER BY "FOBLC_ClearedDateTime" DESC 
        LIMIT 1;

        SELECT EXTRACT(DAY FROM (CURRENT_TIMESTAMP - "LastClearDay"))::bigint INTO "Datediffcount";
        
        IF ("Datediffcount" >= 3) THEN
            INSERT INTO "FO"."FO_Biometric_Log_Clear"(
                "MI_Id",
                "FOBLC_DeviceId",
                "FOBLC_ClearedDateTime",
                "FOBLC_FileName",
                "FOBLC_LogRecords",
                "CreatedDate",
                "UpdatedDate",
                "FOBLC_CreatedBy",
                "FOBLC_UpdatedBy"
            )
            VALUES(
                $1,
                $2,
                CURRENT_TIMESTAMP,
                $3,
                $4,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP,
                0,
                0
            );
        END IF;
    ELSE
        INSERT INTO "FO"."FO_Biometric_Log_Clear"(
            "MI_Id",
            "FOBLC_DeviceId",
            "FOBLC_ClearedDateTime",
            "FOBLC_FileName",
            "FOBLC_LogRecords",
            "CreatedDate",
            "UpdatedDate",
            "FOBLC_CreatedBy",
            "FOBLC_UpdatedBy"
        )
        VALUES(
            $1,
            $2,
            CURRENT_TIMESTAMP,
            $3,
            $4,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            0,
            0
        );
    END IF;

    IF ("RecordExist" > 1) THEN
        RETURN QUERY
        SELECT 
            t."MI_Id",
            t."FOBLC_DeviceId",
            t."FOBLC_ClearedDateTime",
            t."FOBLC_FileName",
            t."FOBLC_LogRecords",
            t."CreatedDate",
            t."UpdatedDate",
            t."FOBLC_CreatedBy",
            t."FOBLC_UpdatedBy"
        FROM "FO"."FO_Biometric_Log_Clear" t
        WHERE t."MI_Id" = $1 
        AND t."FOBLC_DeviceId" = $2 
        AND DATE(t."FOBLC_ClearedDateTime") = DATE(CURRENT_TIMESTAMP);
    END IF;

    RETURN;
END;
$$;