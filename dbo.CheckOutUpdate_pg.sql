CREATE OR REPLACE FUNCTION "dbo"."CheckOutUpdate"()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "@SourceCheckOutQty" bigint;
    "@TargetCheckOutQty" bigint;
    "@INVMI_Id" bigint;
    "@INVMST_Id" bigint;
    "@Itemcount" bigint;
    "@PlusStock" decimal(18,2);
    "@MinusStock" decimal(18,2);
    updatecheckout_rec RECORD;
BEGIN
    FOR updatecheckout_rec IN 
        SELECT "INVMST_Id", "INVMI_Id", COUNT(*) AS "Itemcount" 
        FROM "INV"."INV_stock" 
        WHERE "MI_Id" = 4 AND "INVSTO_CheckedOutQty" <> 0 
        GROUP BY "INVMST_Id", "INVMI_Id" 
        HAVING COUNT(*) = 1
    LOOP
        "@INVMST_Id" := updatecheckout_rec."INVMST_Id";
        "@INVMI_Id" := updatecheckout_rec."INVMI_Id";
        "@Itemcount" := updatecheckout_rec."Itemcount";
        
        SELECT SUM(COALESCE("INVACO_CheckOutQty", 0)) 
        INTO "@SourceCheckOutQty"
        FROM "INV"."INV_Asset_CheckOut" 
        WHERE "MI_Id" = 4 
            AND "INVMST_Id" = "@INVMST_Id" 
            AND "INVMI_Id" = "@INVMI_Id" 
            AND "INVACO_ActiveFlg" = 1;
        
        SELECT "INVSTO_CheckedOutQty" 
        INTO "@TargetCheckOutQty"
        FROM "INV"."INV_stock" 
        WHERE "MI_Id" = 4 
            AND "INVSTO_CheckedOutQty" <> 0 
            AND "INVMI_Id" = "@INVMI_Id" 
            AND "INVMST_Id" = "@INVMST_Id";
        
        IF ("@SourceCheckOutQty" <> "@TargetCheckOutQty") THEN
            IF ("@SourceCheckOutQty" > "@TargetCheckOutQty") THEN
                "@MinusStock" := "@SourceCheckOutQty" - "@TargetCheckOutQty";
                
                UPDATE "INV"."INV_stock" 
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" - "@MinusStock",
                    "INVSTO_CheckedOutQty" = "INVSTO_CheckedOutQty" + "@MinusStock"
                WHERE "MI_Id" = 4 
                    AND "INVMST_Id" = "@INVMST_Id" 
                    AND "INVMI_Id" = "@INVMI_Id";
            ELSIF ("@SourceCheckOutQty" <= "@TargetCheckOutQty") THEN
                "@PlusStock" := "@TargetCheckOutQty" - "@SourceCheckOutQty";
                
                UPDATE "INV"."INV_stock" 
                SET "INVSTO_AvaiableStock" = "INVSTO_AvaiableStock" + "@PlusStock",
                    "INVSTO_CheckedOutQty" = "INVSTO_CheckedOutQty" - "@PlusStock"
                WHERE "MI_Id" = 4 
                    AND "INVMST_Id" = "@INVMST_Id" 
                    AND "INVMI_Id" = "@INVMI_Id";
            END IF;
        END IF;
    END LOOP;
    
    RETURN;
END;
$$;