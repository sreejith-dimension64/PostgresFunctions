CREATE OR REPLACE FUNCTION "dbo"."AT_AssetsReport_Details"(
    "@MI_Id" BIGINT,
    "@selectionflag" VARCHAR(50)
)
RETURNS TABLE (
    "INVMLO_Id" BIGINT,
    "INVMLO_LocationRoomName" TEXT,
    "Year" VARCHAR(30)
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "@Checkoutdate" DATE;
    "@Year" VARCHAR(100);
BEGIN

    DROP TABLE IF EXISTS "AssertTag_Temp";
    
    CREATE TEMP TABLE "AssertTag_Temp"("Year" VARCHAR(30));

    IF ("@selectionflag" = 'Location') THEN
        
        RETURN QUERY
        SELECT DISTINCT a."INVMLO_Id", a."INVMLO_LocationRoomName", NULL::VARCHAR(30) AS "Year"
        FROM "INV"."INV_Master_Location" a
        LEFT JOIN "INV"."INV_Asset_CheckOut" b ON a."INVMLO_Id" = b."INVMLO_Id" AND a."MI_Id" = b."MI_Id"
        LEFT JOIN "INV"."INV_Asset_Dispose" c ON a."INVMLO_Id" = c."INVMLO_Id" AND a."MI_Id" = c."MI_Id"
        WHERE a."MI_Id" = "@MI_Id" AND a."INVMLO_ActiveFlg" = 1
        ORDER BY a."INVMLO_LocationRoomName";

    ELSIF ("@selectionflag" = 'year') THEN
        
        FOR "@Checkoutdate" IN 
            SELECT DISTINCT "INVACO_CheckoutDate"::DATE 
            FROM "INV"."INV_Asset_CheckOut" 
            WHERE "MI_Id" = "@MI_Id"
        LOOP
            
            SELECT "ASMAY_Year" INTO "@Year"
            FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id" = "@MI_Id" 
                AND "@Checkoutdate" >= "ASMAY_From_Date"::DATE 
                AND "@Checkoutdate" <= "ASMAY_To_Date"::DATE
            LIMIT 1;
            
            INSERT INTO "AssertTag_Temp"("Year") VALUES("@Year");
            
        END LOOP;
        
        RETURN QUERY
        SELECT NULL::BIGINT AS "INVMLO_Id", NULL::TEXT AS "INVMLO_LocationRoomName", DISTINCT at."Year"
        FROM "AssertTag_Temp" at;

    END IF;

    RETURN;

END;
$$;