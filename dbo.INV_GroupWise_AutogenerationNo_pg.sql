CREATE OR REPLACE FUNCTION "INV"."INV_GroupWise_AutogenerationNo"(
    "p_MI_Id" VARCHAR(100),
    "p_INVMG_Id" TEXT,
    OUT "p_AutoGenerateNo" TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Prefixname" TEXT;
    "v_Suffixname" TEXT;
    "v_Prefixnamelen" BIGINT;
    "v_suffixnamelen" BIGINT;
    "v_Rowcount" BIGINT;
    "v_Group_Starting_No" BIGINT;
    "v_GroupItemMaxno" BIGINT;
    "v_cursor_rec" RECORD;
    "v_temp_value" TEXT;
BEGIN
    "v_Rowcount" := 0;

    DROP TABLE IF EXISTS "INV_GroupWise_AutogenerationNo_Temp1";
    DROP TABLE IF EXISTS "INV_GroupWise_AutogenerationNo_Temp2";

    FOR "v_cursor_rec" IN 
        EXECUTE 'SELECT DISTINCT COALESCE("INVMG_GroupPrefix",'''') AS "INVMG_GroupPrefix",
                        COALESCE("INVMG_GroupSuffix",'''') AS "INVMG_GroupSuffix",
                        "INVMG_GroupStartingNo" 
                 FROM "INV"."INV_Master_group" 
                 WHERE "MI_Id"=' || "p_MI_Id" || ' AND "INVMG_Id" IN (' || "p_INVMG_Id" || ')'
    LOOP
        "v_Prefixname" := COALESCE("v_cursor_rec"."INVMG_GroupPrefix", '');
        "v_Suffixname" := COALESCE("v_cursor_rec"."INVMG_GroupSuffix", '');
        "v_Group_Starting_No" := "v_cursor_rec"."INVMG_GroupStartingNo";
    END LOOP;

    RAISE NOTICE 'Prefix : %', "v_Prefixname";
    RAISE NOTICE 'Suffixname : %', "v_Suffixname";

    "v_Prefixname" := COALESCE("v_Prefixname", '');
    "v_Suffixname" := COALESCE("v_Suffixname", '');

    "v_Prefixnamelen" := LENGTH("v_Prefixname");
    "v_suffixnamelen" := LENGTH("v_Suffixname");

    "v_suffixnamelen" := "v_suffixnamelen" + "v_Prefixnamelen";
    "v_Prefixnamelen" := "v_Prefixnamelen" + 1;

    -- 1 case
    IF ("v_Prefixname" != '' AND "v_Suffixname" = '') THEN
        SELECT COUNT(*) INTO "v_Rowcount" 
        FROM "INV"."INV_Master_Item" 
        WHERE "MI_Id" = "p_MI_Id" AND "INVMI_GroupItemNo" LIKE "v_Prefixname" || '%';

        RAISE NOTICE '@Rowcount: %', "v_Rowcount";

        IF "v_Rowcount" = 0 THEN
            "p_AutoGenerateNo" := "v_Group_Starting_No"::TEXT;
            RAISE NOTICE '%', "v_Prefixname" || "p_AutoGenerateNo";
            "p_AutoGenerateNo" := "v_Prefixname" || "p_AutoGenerateNo";
        ELSE
            SELECT MAX(SUBSTRING("INVMI_GroupItemNo", "v_Prefixnamelen", (LENGTH("INVMI_GroupItemNo") - "v_suffixnamelen"))::BIGINT)::TEXT 
            INTO "p_AutoGenerateNo"
            FROM "INV"."INV_Master_Item" 
            WHERE "MI_Id" = "p_MI_Id" AND "INVMI_GroupItemNo" LIKE "v_Prefixname" || '%';
            
            "p_AutoGenerateNo" := ("p_AutoGenerateNo"::BIGINT + 1)::TEXT;
            RAISE NOTICE '%', "v_Prefixname" || "p_AutoGenerateNo";
            "p_AutoGenerateNo" := "v_Prefixname" || "p_AutoGenerateNo";
        END IF;
    END IF;

    -- 2 case
    IF ("v_Prefixname" != '' AND "v_Suffixname" != '') THEN
        SELECT COUNT(*) INTO "v_Rowcount" 
        FROM "INV"."INV_Master_Item" 
        WHERE "MI_Id" = "p_MI_Id" AND "INVMI_GroupItemNo" LIKE "v_Prefixname" || '%' || "v_Suffixname";

        RAISE NOTICE '@Rowcount: %', "v_Rowcount";

        IF "v_Rowcount" = 0 THEN
            "p_AutoGenerateNo" := "v_Group_Starting_No"::TEXT;
            RAISE NOTICE '%', "v_Prefixname" || "p_AutoGenerateNo" || "v_Suffixname";
            "p_AutoGenerateNo" := "v_Prefixname" || "p_AutoGenerateNo" || "v_Suffixname";
        ELSE
            SELECT MAX(SUBSTRING("INVMI_GroupItemNo", "v_Prefixnamelen", (LENGTH("INVMI_GroupItemNo") - "v_suffixnamelen"))::BIGINT)::TEXT 
            INTO "p_AutoGenerateNo"
            FROM "INV"."INV_Master_Item" 
            WHERE "MI_Id" = "p_MI_Id" AND "INVMI_GroupItemNo" LIKE "v_Prefixname" || '%' || "v_Suffixname";
            
            "p_AutoGenerateNo" := ("p_AutoGenerateNo"::BIGINT + 1)::TEXT;
            RAISE NOTICE '%', "v_Prefixname" || "p_AutoGenerateNo" || "v_Suffixname";
            "p_AutoGenerateNo" := "v_Prefixname" || "p_AutoGenerateNo" || "v_Suffixname";
        END IF;
    END IF;

    -- 3 case
    IF ("v_Prefixname" = '' AND "v_Suffixname" = '') THEN
        EXECUTE 'CREATE TEMP TABLE "INV_GroupWise_AutogenerationNo_Temp1" AS 
                 SELECT COUNT(*) AS "Rcount"
                 FROM "INV"."INV_Master_Item" "MI" 
                 INNER JOIN "INV"."INV_Master_Group" "MG" ON "MG"."INVMG_Id"="MI"."INVMG_Id" AND "MI"."MI_Id"="MG"."MI_Id"
                 WHERE "MI"."MI_Id"=' || "p_MI_Id" || ' AND "MG"."MI_Id"=' || "p_MI_Id" || ' AND "MI"."INVMG_Id" IN (' || "p_INVMG_Id" || ')';

        SELECT "Rcount" INTO "v_Rowcount" FROM "INV_GroupWise_AutogenerationNo_Temp1";

        RAISE NOTICE '@Rowcount: %', "v_Rowcount";

        IF "v_Rowcount" = 0 THEN
            "p_AutoGenerateNo" := "v_Group_Starting_No"::TEXT;
            RAISE NOTICE '%', "v_Prefixname" || "p_AutoGenerateNo";
            "p_AutoGenerateNo" := "v_Prefixname" || "p_AutoGenerateNo";
        ELSE
            EXECUTE 'CREATE TEMP TABLE "INV_GroupWise_AutogenerationNo_Temp2" AS  
                     SELECT MAX("MI"."INVMI_GroupItemNo"::BIGINT) AS "MaxRecepNo"
                     FROM "INV"."INV_Master_Item" "MI" 
                     INNER JOIN "INV"."INV_Master_Group" "MG" ON "MG"."INVMG_Id"="MI"."INVMG_Id" AND "MI"."MI_Id"="MG"."MI_Id"
                     WHERE "MI"."MI_Id"=' || "p_MI_Id" || ' AND "MG"."MI_Id"=' || "p_MI_Id" || ' AND "MI"."INVMG_Id" IN (' || "p_INVMG_Id" || ')';

            SELECT "MaxRecepNo" INTO "v_GroupItemMaxno" FROM "INV_GroupWise_AutogenerationNo_Temp2";

            "p_AutoGenerateNo" := ("v_GroupItemMaxno" + 1)::TEXT;
            RAISE NOTICE '%', "v_Prefixname" || "p_AutoGenerateNo";
            "p_AutoGenerateNo" := "v_Prefixname" || "p_AutoGenerateNo";
        END IF;
    END IF;

    DROP TABLE IF EXISTS "INV_GroupWise_AutogenerationNo_Temp1";
    DROP TABLE IF EXISTS "INV_GroupWise_AutogenerationNo_Temp2";

END;
$$;