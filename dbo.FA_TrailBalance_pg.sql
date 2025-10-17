CREATE OR REPLACE FUNCTION "dbo"."FA_TrailBalance"(
    p_IMFY_Id bigint,
    p_MI_Id bigint,
    p_FAMCOMP_Id bigint,
    p_sdate varchar(10),
    p_edate varchar(10)
)
RETURNS TABLE (
    "FAMGRP_Id" bigint,
    "FAMGRP_GroupName" varchar,
    "levelcode" bigint,
    "FAMGRP_ParentId" bigint,
    "FAMLED_LedgerName" varchar,
    "FAMLED_Id" bigint,
    "mg_type" varchar(10),
    "Amt" float,
    "FAMGRP_Position" bigint,
    "ChildRecords" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_mg_code nvarchar(10);
    v_mg_Name nvarchar(100);
    v_mg_type nvarchar(10);
    v_FAMGRP_Id bigint;
    v_FAMGRP_GroupCode varchar;
    v_FAMGRP_GroupName varchar;
    v_FAMGRP_BSPLFlg varchar;
    v_FAMGRP_CRDRFlg varchar;
    v_FAMGRP_Position varchar;
    v_FAMGRP_ParentId bigint;
    v_FAMGRP_MasterGroupFlg boolean;
    
    v_FAMGRP_Id1 bigint;
    v_FAMGRP_GroupCode1 varchar;
    v_FAMGRP_GroupName1 varchar;
    v_FAMGRP_BSPLFlg1 varchar;
    v_FAMGRP_CRDRFlg1 varchar;
    v_FAMGRP_Position1 varchar;
    v_FAMGRP_ParentId1 bigint;
    v_FAMGRP_MasterGroupFlg1 boolean;
    
    v_FAMGRP_Id2 bigint;
    v_FAMGRP_ParentId2 bigint;
    v_FAMGRP_Positionnew bigint;
    
    v_level bigint;
    v_grpcount bigint;
    v_maxlevel bigint;
    v_parentIDdublicatecheck bigint;
    
    v_L_Code bigint;
    v_L_Name varchar;
    v_groupcode bigint;
    v_groupname varchar;
    v_levelcode bigint;
    v_parentid bigint;
    
    v_intOpenBalDR decimal;
    v_intOpenBalCR decimal;
    v_IntTranCr FLOAT;
    v_IntTranDr FLOAT;
    
    rec_maingroup RECORD;
    rec_subgroup RECORD;
    rec_groupcount RECORD;
    rec_ledgroup RECORD;
    rec_sumdr RECORD;
    rec_sumcr RECORD;
BEGIN
    
    DROP TABLE IF EXISTS "tmpBS";
    
    CREATE TEMP TABLE "tmpBS" (
        "FAMGRP_Id" bigint,
        "FAMGRP_GroupName" varchar,
        "levelcode" bigint,
        "FAMGRP_ParentId" bigint,
        "FAMLED_LedgerName" varchar,
        "FAMLED_Id" bigint,
        "mg_type" varchar(10),
        "Amt" float,
        "FAMGRP_Position" bigint
    );
    
    DROP TABLE IF EXISTS "tmpallgroupBS";
    
    CREATE TEMP TABLE "tmpallgroupBS" (
        "FAMGRP_Id" bigint,
        "FAMGRP_ParentId" bigint,
        "grouplevel" bigint
    );
    
    DROP TABLE IF EXISTS "tmpallgroupBSSkip";
    
    CREATE TEMP TABLE "tmpallgroupBSSkip" (
        "FAMGRP_Id" bigint,
        "FAMGRP_ParentId" bigint,
        "grouplevel" bigint
    );
    
    -- master group start
    FOR rec_maingroup IN 
        SELECT "FAMGRP_Id", "FAMGRP_GroupCode", "FAMGRP_GroupName", "FAMGRP_BSPLFlg", 
               "FAMGRP_CRDRFlg", "FAMGRP_ParentId", "FAMGRP_MasterGroupFlg"
        FROM "FA_Master_Group" 
        WHERE "FAMGRP_ParentId" = 0 AND "MI_Id" = p_MI_Id
        ORDER BY "FAMGRP_Id"
    LOOP
        v_FAMGRP_Id := rec_maingroup."FAMGRP_Id";
        v_FAMGRP_GroupCode := rec_maingroup."FAMGRP_GroupCode";
        v_FAMGRP_GroupName := rec_maingroup."FAMGRP_GroupName";
        v_FAMGRP_BSPLFlg := rec_maingroup."FAMGRP_BSPLFlg";
        v_FAMGRP_CRDRFlg := rec_maingroup."FAMGRP_CRDRFlg";
        v_FAMGRP_ParentId := rec_maingroup."FAMGRP_ParentId";
        v_FAMGRP_MasterGroupFlg := rec_maingroup."FAMGRP_MasterGroupFlg";
        
        v_level := 1;
        
        INSERT INTO "tmpallgroupBS" VALUES (v_FAMGRP_Id, v_FAMGRP_ParentId, v_level);
        
        -- SUB group start
        FOR rec_subgroup IN 
            SELECT "FAMGRP_Id", "FAMGRP_GroupCode", "FAMGRP_GroupName", "FAMGRP_BSPLFlg", 
                   "FAMGRP_CRDRFlg", "FAMGRP_ParentId", "FAMGRP_MasterGroupFlg"
            FROM "FA_Master_Group" 
            WHERE "MI_Id" = p_MI_Id 
              AND "FAMGRP_ParentId" IN (
                  SELECT "FAMGRP_Id" FROM "tmpallgroupBS" 
                  WHERE "FAMGRP_Id" NOT IN (SELECT "FAMGRP_Id" FROM "tmpallgroupBSSkip")
              )
            ORDER BY "FAMGRP_Id"
        LOOP
            v_FAMGRP_Id1 := rec_subgroup."FAMGRP_Id";
            v_FAMGRP_GroupCode1 := rec_subgroup."FAMGRP_GroupCode";
            v_FAMGRP_GroupName1 := rec_subgroup."FAMGRP_GroupName";
            v_FAMGRP_BSPLFlg1 := rec_subgroup."FAMGRP_BSPLFlg";
            v_FAMGRP_CRDRFlg1 := rec_subgroup."FAMGRP_CRDRFlg";
            v_FAMGRP_ParentId1 := rec_subgroup."FAMGRP_ParentId";
            v_FAMGRP_MasterGroupFlg1 := rec_subgroup."FAMGRP_MasterGroupFlg";
            
            v_maxlevel := 0;
            SELECT "grouplevel" INTO v_maxlevel 
            FROM "tmpallgroupBS" 
            WHERE "FAMGRP_Id" = v_FAMGRP_ParentId1 
            LIMIT 1;
            
            v_maxlevel := COALESCE(v_maxlevel, 0);
            v_level := v_maxlevel + 1;
            
            INSERT INTO "tmpallgroupBS" VALUES (v_FAMGRP_Id1, v_FAMGRP_ParentId1, v_level);
            
            SELECT COUNT(*) INTO v_grpcount 
            FROM "FA_Master_Group" 
            WHERE "FAMGRP_ParentId" = v_FAMGRP_Id1;
            
            IF v_grpcount > 0 THEN
                v_parentIDdublicatecheck := 0;
                
                FOR rec_groupcount IN 
                    SELECT "FAMGRP_Id", "FAMGRP_ParentId"
                    FROM "FA_Master_Group" 
                    WHERE "MI_Id" = p_MI_Id AND "FAMGRP_ParentId" = v_FAMGRP_Id1
                    ORDER BY "FAMGRP_GroupCode"
                LOOP
                    v_FAMGRP_Id2 := rec_groupcount."FAMGRP_Id";
                    v_FAMGRP_ParentId2 := rec_groupcount."FAMGRP_ParentId";
                    
                    v_maxlevel := 0;
                    SELECT "grouplevel" INTO v_maxlevel 
                    FROM "tmpallgroupBS" 
                    WHERE "FAMGRP_Id" = v_FAMGRP_ParentId2 
                    LIMIT 1;
                    
                    v_maxlevel := COALESCE(v_maxlevel, 0);
                    v_level := v_maxlevel + 1;
                    
                    INSERT INTO "tmpallgroupBS" VALUES (v_FAMGRP_Id2, v_FAMGRP_ParentId2, v_level);
                END LOOP;
            END IF;
            
            INSERT INTO "tmpallgroupBSSkip" VALUES (v_FAMGRP_Id1, v_FAMGRP_ParentId1, v_level);
            v_level := v_level - 1;
        END LOOP;
        -- SUB group end
        
        INSERT INTO "tmpallgroupBSSkip" VALUES (v_FAMGRP_Id, v_FAMGRP_ParentId, v_level);
    END LOOP;
    -- master group end
    
    -- Ledger Insert Start
    FOR rec_ledgroup IN 
        SELECT DISTINCT "FAMLED_Id", "FAMLED_LedgerName", a."FAMGRP_Id", "FAMGRP_GroupName", 
               "grouplevel", b."FAMGRP_ParentId", "FAMGRP_CRDRFlg"
        FROM "tmpallgroupBS" a
        INNER JOIN "FA_Master_Group" b ON a."FAMGRP_Id" = b."FAMGRP_Id"
        LEFT JOIN "FA_M_Ledger" c ON c."FAMGRP_Id" = b."FAMGRP_Id"
    LOOP
        v_l_code := rec_ledgroup."FAMLED_Id";
        v_L_Name := rec_ledgroup."FAMLED_LedgerName";
        v_groupcode := rec_ledgroup."FAMGRP_Id";
        v_groupname := rec_ledgroup."FAMGRP_GroupName";
        v_levelcode := rec_ledgroup."grouplevel";
        v_parentid := rec_ledgroup."FAMGRP_ParentId";
        v_mg_type := rec_ledgroup."FAMGRP_CRDRFlg";
        
        v_intOpenBalDR := 0;
        v_intOpenBalCR := 0;
        
        IF v_l_code IS NOT NULL THEN
            SELECT * INTO v_intOpenBalCR, v_intOpenBalDR 
            FROM "FA_OpeningbalanceSingLeAcc"(v_l_code, p_MI_Id, p_FAMCOMP_Id, v_groupcode, p_sdate);
            
            v_intOpenBalCR := COALESCE(v_intOpenBalCR, 0);
            v_intOpenBalDR := COALESCE(v_intOpenBalDR, 0);
            
            RAISE NOTICE '%', v_intOpenBalCR;
            RAISE NOTICE '@intOpenBalCR';
            RAISE NOTICE '%', v_intOpenBalDR;
        END IF;
        
        v_IntTranDr := 0;
        v_IntTranCr := 0;
        
        SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0) INTO v_IntTranCr
        FROM "FA_T_Voucher", "FA_M_Voucher" 
        WHERE "FA_T_Voucher"."FAMLED_Id" = v_l_code 
          AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN CAST(p_sdate AS date) AND CAST(p_edate AS date)
          AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
          AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
          AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'CR';
        
        v_IntTranCr := COALESCE(v_IntTranCr + v_intOpenBalCR, 0);
        
        SELECT COALESCE(SUM("FA_T_Voucher"."FATVOU_Amount"), 0) INTO v_IntTranDr
        FROM "FA_T_Voucher", "FA_M_Voucher" 
        WHERE "FA_T_Voucher"."FAMLED_Id" = v_l_code 
          AND CAST("FA_M_Voucher"."FAMVOU_VoucherDate" AS date) BETWEEN CAST(p_sdate AS date) AND CAST(p_edate AS date)
          AND "FA_M_Voucher"."IMFY_Id" = p_IMFY_Id 
          AND "FA_T_Voucher"."FAMVOU_Id" = "FA_M_Voucher"."FAMVOU_Id" 
          AND "FA_T_Voucher"."FATVOU_CRDRFlg" = 'DR';
        
        v_IntTranDr := COALESCE(v_IntTranDr + v_intOpenBalDR, 0);
        
        -- Insert Statement
        IF (v_IntTranDr > v_IntTranCr) THEN
            INSERT INTO "tmpBS" VALUES (
                v_groupcode, v_groupname, v_levelcode, v_parentid, v_L_Name, 
                v_l_code, v_mg_type, v_IntTranDr - v_IntTranCr, v_FAMGRP_Positionnew::bigint
            );
        ELSE
            INSERT INTO "tmpBS" VALUES (
                v_groupcode, v_groupname, v_levelcode, v_parentid, v_L_Name, 
                v_l_code, v_mg_type, v_IntTranCr - v_IntTranDr, v_FAMGRP_Positionnew::bigint
            );
        END IF;
    END LOOP;
    -- Ledger Insert End
    
    PERFORM "totalbalancesheet"(p_MI_Id, p_IMFY_Id);
    PERFORM "totalbalancesheet"(p_MI_Id, p_IMFY_Id);
    
    RETURN QUERY
    SELECT a.*, 
           (SELECT COUNT(*) FROM "Balancesheettemp" WHERE "FAMGRP_ParentId" = a."FAMGRP_Id")::bigint AS "ChildRecords"
    FROM "Balancesheettemp" a;
    
END;
$$;