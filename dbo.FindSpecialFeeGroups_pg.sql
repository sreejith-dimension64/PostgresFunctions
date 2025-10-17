CREATE OR REPLACE FUNCTION "dbo"."FindSpecialFeeGroups" (
    "p_fmg_id" bigint,
    "p_acm_id1" bigint,
    "p_callCount" int,
    "p_yearid1" bigint,
    INOUT "p_strGrp" varchar(100),
    INOUT "p_grpCount" int
)
RETURNS RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "v_strTemp" varchar(100);
    "v_subGrpid" bigint;
    "v_subGrpname" varchar(100);
    "v_FYG_Id" bigint;
    "v_cnt1" int;
    "v_callCnt" int;
    "v_curName" varchar(100);
    "rec" RECORD;
    "v_result" RECORD;
BEGIN
    "v_strTemp" := '';
    "v_subGrpid" := 0;
    "v_subGrpname" := '';
    "v_FYG_Id" := 0;
    "v_cnt1" := 0;
    "p_strGrp" := '';
    "p_grpCount" := 0;

    IF "p_callCount" = 0 THEN
        FOR "rec" IN 
            SELECT "fmg_id", "FMG_GroupName" 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" = "p_fmg_id" AND "FMG_Id" <> "FMG_Id"
        LOOP
            "v_subGrpid" := "rec"."fmg_id";
            "v_subGrpname" := "rec"."FMG_GroupName";
            
            RAISE NOTICE '@subGrpid %', "v_subGrpid";
            
            SELECT "FYG_Id" INTO "v_FYG_Id" 
            FROM "Fee_Yearly_Group" 
            WHERE "FMG_Id" = "v_subGrpid" AND "MI_Id" = "p_acm_id1" AND "ASMAY_Id" = "p_yearid1";
            
            IF "v_FYG_Id" > 0 THEN
                IF "p_strGrp" = '' THEN
                    "p_strGrp" := '-' || CAST("v_FYG_Id" AS varchar) || '-';
                    RAISE NOTICE '@FYG_Id %', "v_FYG_Id";
                ELSE
                    "p_strGrp" := "p_strGrp" || '-' || CAST("v_FYG_Id" AS varchar) || '-';
                END IF;
                RAISE NOTICE '@strGrp %', "p_strGrp";
            END IF;
            
            "v_strTemp" := '';
            "v_cnt1" := 0;
            "v_callCnt" := ("p_callCount" + 1);
            
            SELECT * INTO "v_result" FROM "dbo"."FindSpecialFeeGroups"("v_subGrpid", "p_acm_id1", "v_callCnt", "p_yearid1", "v_strTemp", "v_cnt1");
            "v_strTemp" := "v_result"."p_strGrp";
            "v_cnt1" := "v_result"."p_grpCount";
            
            IF "v_strTemp" <> '' THEN
                "p_strGrp" := "p_strGrp" || '-' || "v_strTemp" || '-';
            END IF;
            
            "p_grpCount" := "p_grpCount" + 1;
        END LOOP;
        
        RAISE NOTICE 'strGrp %', "p_strGrp";
        RAISE NOTICE 'grpCount %', "p_grpCount";
        
    ELSIF "p_callCount" = 1 THEN
        FOR "rec" IN 
            SELECT "fmg_id", "FMG_GroupName" 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" = "p_fmg_id" AND "FMG_Id" <> "FMG_Id"
        LOOP
            "v_subGrpid" := "rec"."fmg_id";
            "v_subGrpname" := "rec"."FMG_GroupName";
            
            SELECT "FYG_Id" INTO "v_FYG_Id" 
            FROM "Fee_Yearly_Group" 
            WHERE "FMG_Id" = "p_fmg_id" AND "MI_Id" = "p_acm_id1" AND "ASMAY_Id" = "p_yearid1";
            
            IF "v_FYG_Id" > 0 THEN
                IF "p_strGrp" = '' THEN
                    "p_strGrp" := '-' || CAST("v_FYG_Id" AS varchar) || '-';
                    RAISE NOTICE '@FYG_Id %', "v_FYG_Id";
                ELSE
                    "p_strGrp" := "p_strGrp" || '-' || CAST("v_FYG_Id" AS varchar) || '-';
                END IF;
                RAISE NOTICE '@strGrp %', "p_strGrp";
            END IF;
            
            "v_strTemp" := '';
            "v_cnt1" := 0;
            "v_callCnt" := ("p_callCount" + 1);
            
            SELECT * INTO "v_result" FROM "dbo"."FindSpecialFeeGroups"("v_subGrpid", "p_acm_id1", "v_callCnt", "p_yearid1", "v_strTemp", "v_cnt1");
            "v_strTemp" := "v_result"."p_strGrp";
            "v_cnt1" := "v_result"."p_grpCount";
            
            IF "v_strTemp" <> '' THEN
                "p_strGrp" := "p_strGrp" || '-' || "v_strTemp" || '-';
            END IF;
            
            "p_grpCount" := "p_grpCount" + 1;
        END LOOP;
        
        RAISE NOTICE 'strGrp %', "p_strGrp";
        RAISE NOTICE 'grpCount %', "p_grpCount";
        
    ELSIF "p_callCount" IN (2, 3, 4, 5, 6, 7, 8, 9, 10) THEN
        FOR "rec" IN 
            SELECT "fmg_id", "FMG_GroupName" 
            FROM "Fee_Master_Group" 
            WHERE "fmg_id" = "p_fmg_id" AND "FMG_Id" <> "FMG_Id"
        LOOP
            "v_subGrpid" := "rec"."fmg_id";
            "v_subGrpname" := "rec"."FMG_GroupName";
            
            SELECT "FYG_Id" INTO "v_FYG_Id" 
            FROM "Fee_Yearly_Group" 
            WHERE "FMG_Id" = "p_fmg_id" AND "MI_Id" = "p_acm_id1" AND "ASMAY_Id" = "p_yearid1";
            
            IF "v_FYG_Id" > 0 THEN
                IF "p_strGrp" = '' THEN
                    "p_strGrp" := '-' || CAST("v_FYG_Id" AS varchar) || '-';
                    RAISE NOTICE '@FYG_Id %', "v_FYG_Id";
                ELSE
                    "p_strGrp" := "p_strGrp" || '-' || CAST("v_FYG_Id" AS varchar) || '-';
                END IF;
                RAISE NOTICE '@strGrp %', "p_strGrp";
            END IF;
            
            "v_strTemp" := '';
            "v_cnt1" := 0;
            "v_callCnt" := ("p_callCount" + 1);
            
            SELECT * INTO "v_result" FROM "dbo"."FindSpecialFeeGroups"("v_subGrpid", "p_acm_id1", "v_callCnt", "p_yearid1", "v_strTemp", "v_cnt1");
            "v_strTemp" := "v_result"."p_strGrp";
            "v_cnt1" := "v_result"."p_grpCount";
            
            IF "v_strTemp" <> '' THEN
                "p_strGrp" := "p_strGrp" || '-' || "v_strTemp" || '-';
            END IF;
            
            "p_grpCount" := "p_grpCount" + 1;
        END LOOP;
        
        RAISE NOTICE 'strGrp %', "p_strGrp";
        RAISE NOTICE 'grpCount %', "p_grpCount";
    END IF;
    
END;
$$;