CREATE OR REPLACE FUNCTION "dbo"."INV_PI_DETAILS_NEW"(
    "MI_Id" TEXT,
    "optionflag" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "sqlexec" TEXT;
    "rec" RECORD;
BEGIN

    IF "optionflag" = 'PIno' THEN
        "sqlexec" := '
SELECT DISTINCT "INVMPI_Id", "INVMPI_PINo" 
FROM "INV"."INV_M_PurchaseIndent" 
WHERE "MI_Id" IN(' || "MI_Id" || ') AND "INVMPI_ActiveFlg" = true
ORDER BY "INVMPI_Id"';
        
        FOR "rec" IN EXECUTE "sqlexec"
        LOOP
            RETURN NEXT "rec";
        END LOOP;
        
    ELSIF "optionflag" = 'Item' THEN
        "sqlexec" := '
SELECT DISTINCT a."INVMI_Id", a."INVMI_ItemName", a."INVMI_ItemCode"
FROM "INV"."INV_Master_Item" a,
     "INV"."INV_M_PurchaseIndent" b,
     "INV"."INV_T_PurchaseIndent" c
WHERE a."INVMI_Id" = c."INVMI_Id" 
  AND b."INVMPI_Id" = c."INVMPI_Id" 
  AND a."MI_Id" IN(' || "MI_Id" || ')
ORDER BY a."INVMI_ItemName"';
        
        FOR "rec" IN EXECUTE "sqlexec"
        LOOP
            RETURN NEXT "rec";
        END LOOP;
        
    END IF;

    RETURN;
END;
$$;